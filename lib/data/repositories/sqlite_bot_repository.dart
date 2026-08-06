import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stars/data/models/local_records.dart';
import 'package:stars/data/services/bot_api_key_cipher.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/bot_repository.dart';
import 'package:stars/domain/repositories/chat_repository.dart';

class SqliteBotRepository implements BotRepository {
  SqliteBotRepository({
    required LocalDatabaseService localDatabase,
    required ChatRepository chatRepository,
    required BotApiKeyCipher apiKeyCipher,
  }) : _localDatabase = localDatabase,
       _chatRepository = chatRepository,
       _apiKeyCipher = apiKeyCipher;

  final LocalDatabaseService _localDatabase;
  final ChatRepository _chatRepository;
  final BotApiKeyCipher _apiKeyCipher;
  final StreamController<List<Bot>> _changes =
      StreamController<List<Bot>>.broadcast();
  List<Bot>? _cache;

  @override
  Stream<List<Bot>> get changes => _changes.stream;

  @override
  Future<List<Bot>> getBots({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _snapshot;

    final records = await _localDatabase.loadBots();
    _cache = await _restoreBots(records);
    return _snapshot;
  }

  @override
  Future<Bot?> getBot(String id) async {
    final cached = _cache?.where((bot) => bot.id == id).firstOrNull;
    if (cached != null) return cached;

    final records = await _localDatabase.loadBot(id);
    if (records.isEmpty) return null;
    final bot = await _restoreBot(records.first);
    final cache = _cache;
    if (cache != null) _cache = [...cache, bot];
    return bot;
  }

  @override
  Future<void> addBot(Bot bot) async {
    final encryptedApiKey = await _apiKeyCipher.encrypt(
      botId: bot.id,
      apiKey: bot.apiKey,
    );
    await _localDatabase.insertBot(
      BotRecord.fromDomain(bot, storedApiKey: encryptedApiKey).values,
    );
    final cache = _cache;
    if (cache == null) {
      await _refreshCache();
    } else {
      _cache = [...cache.where((item) => item.id != bot.id), bot];
    }
    _emit();
  }

  @override
  Future<void> updateBot(Bot bot) async {
    final encryptedApiKey = await _apiKeyCipher.encrypt(
      botId: bot.id,
      apiKey: bot.apiKey,
    );
    final values = Map<String, Object?>.from(
      BotRecord.fromDomain(bot, storedApiKey: encryptedApiKey).values,
    )..remove('id');
    await _localDatabase.updateBot(bot.id, values);

    final cache = _cache;
    if (cache == null) {
      await _refreshCache();
    } else {
      _cache = [
        for (final item in cache)
          if (item.id == bot.id) bot else item,
      ];
    }
    _emit();
  }

  @override
  Future<void> deleteBot(String id) async {
    await _chatRepository.deleteChatsForBot(id);
    await _localDatabase.deleteBot(id);
    final cache = _cache;
    if (cache == null) {
      await _refreshCache();
    } else {
      _cache = cache.where((bot) => bot.id != id).toList();
    }
    _emit();
  }

  Future<void> _refreshCache() async {
    final records = await _localDatabase.loadBots();
    _cache = await _restoreBots(records);
  }

  Future<List<Bot>> _restoreBots(List<Map<String, Object?>> records) async {
    final bots = <Bot>[];
    for (final values in records) {
      bots.add(await _restoreBot(values));
    }
    return bots;
  }

  Future<Bot> _restoreBot(Map<String, Object?> values) async {
    final record = BotRecord(values);
    final storedApiKey = record.storedApiKey;
    if (storedApiKey.isEmpty) return record.toDomain(apiKey: '');

    if (_apiKeyCipher.isEncrypted(storedApiKey)) {
      final apiKey = await _apiKeyCipher.decrypt(
        botId: record.id,
        encrypted: storedApiKey,
      );
      return record.toDomain(apiKey: apiKey);
    }

    final encryptedApiKey = await _apiKeyCipher.encrypt(
      botId: record.id,
      apiKey: storedApiKey,
    );
    await _localDatabase.updateBot(record.id, {'api_key': encryptedApiKey});
    return record.toDomain(apiKey: storedApiKey);
  }

  List<Bot> get _snapshot => List<Bot>.unmodifiable(_cache ?? const []);

  void _emit() {
    if (!_changes.isClosed) _changes.add(_snapshot);
  }

  @visibleForTesting
  Future<void> dispose() => _changes.close();
}
