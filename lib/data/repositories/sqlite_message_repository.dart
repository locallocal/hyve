import 'dart:async';
import 'dart:collection';

import 'package:stars/data/models/local_records.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/message_repository.dart';

class SqliteMessageRepository implements CachedMessageRepository {
  SqliteMessageRepository({required LocalDatabaseService localDatabase})
    : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  final LinkedHashMap<String, _CachedMessages> _messageCache =
      LinkedHashMap<String, _CachedMessages>();
  int _identitySequence = 0;

  static const int _maxCachedChats = 5;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  String createId(String prefix) {
    _identitySequence = (_identitySequence + 1) & 0x7fffffff;
    return '$prefix:${DateTime.now().microsecondsSinceEpoch}:'
        '$_identitySequence';
  }

  Message _ensureIdentity(Message message) {
    final messageId =
        message.messageId.isEmpty ? createId('message') : message.messageId;
    final turnId = message.turnId.isEmpty ? createId('turn') : message.turnId;
    return message.copyWith(messageId: messageId, turnId: turnId);
  }

  @override
  Future<List<Message>> getMessages(String chatId) async {
    final cached = peekMessages(chatId);
    if (cached != null) return cached;

    final revisionBeforeLoad = _localDatabase.messageRevision(chatId);
    final records = await _localDatabase.loadMessages(chatId);
    final messages = List<Message>.unmodifiable(
      records.map((record) => MessageRecord(record).toDomain()),
    );
    if (_localDatabase.messageRevision(chatId) == revisionBeforeLoad) {
      _cacheMessages(chatId, revisionBeforeLoad, messages);
    }
    return messages;
  }

  @override
  List<Message>? peekMessages(String chatId) {
    final cached = _messageCache.remove(chatId);
    if (cached == null) return null;
    if (cached.revision != _localDatabase.messageRevision(chatId)) return null;

    // Removing and reinserting makes this a small LRU cache. It keeps recent
    // conversations fast without retaining every chat opened by the user.
    _messageCache[chatId] = cached;
    return cached.messages;
  }

  void _cacheMessages(String chatId, int revision, List<Message> messages) {
    _messageCache.remove(chatId);
    _messageCache[chatId] = _CachedMessages(
      revision: revision,
      messages: messages,
    );
    while (_messageCache.length > _maxCachedChats) {
      _messageCache.remove(_messageCache.keys.first);
    }
  }

  @override
  Future<List<ModelTokenUsageRecord>> getTokenUsageRecordsForChat(
    String chatId,
  ) async {
    final records = await _localDatabase.loadTokenUsageRecordsForChat(chatId);
    return _toTokenUsageRecords(records);
  }

  @override
  Future<List<ModelTokenUsageRecord>> getTokenUsageRecordsForBot(
    String botId,
  ) async {
    final records = await _localDatabase.loadTokenUsageRecordsForBot(botId);
    return _toTokenUsageRecords(records);
  }

  @override
  Future<ModelTokenUsage> getTokenUsageForBot(String botId) async {
    final record = await _localDatabase.loadTokenUsageForBot(botId);
    return ModelTokenUsage(
      inputTokens: _readCount(record['input_token_count']),
      outputTokens: _readCount(record['output_token_count']),
      totalTokens: _readCount(record['total_token_count']),
    );
  }

  @override
  Future<Map<String, ModelTokenUsage>> getTokenUsageByChatForBot(
    String botId,
  ) async {
    final records = await _localDatabase.loadTokenUsageByChatForBot(botId);
    return Map<String, ModelTokenUsage>.unmodifiable({
      for (final record in records)
        record['chat_id']?.toString() ?? '': ModelTokenUsage(
          inputTokens: _readCount(record['input_token_count']),
          outputTokens: _readCount(record['output_token_count']),
          totalTokens: _readCount(record['total_token_count']),
        ),
    });
  }

  @override
  Future<Message> upsertMessage(Message message) async {
    final identified = _ensureIdentity(message);
    await _localDatabase.upsertMessage(
      MessageRecord.fromDomain(identified).values,
    );
    _updateCachedMessages(identified.chatId, [identified]);
    _changes.add(null);
    return identified;
  }

  @override
  Future<List<Message>> upsertMessages(Iterable<Message> messages) async {
    final identified = messages.map(_ensureIdentity).toList(growable: false);
    await _localDatabase.upsertMessages(
      identified.map((message) => MessageRecord.fromDomain(message).values),
    );
    final messagesByChat = <String, List<Message>>{};
    for (final message in identified) {
      (messagesByChat[message.chatId] ??= <Message>[]).add(message);
    }
    for (final entry in messagesByChat.entries) {
      _updateCachedMessages(entry.key, entry.value);
    }
    _changes.add(null);
    return List<Message>.unmodifiable(identified);
  }

  @override
  Future<void> deleteMessages(String chatId) async {
    await _localDatabase.deleteMessages(chatId);
    _messageCache.remove(chatId);
    _changes.add(null);
  }

  void _updateCachedMessages(String chatId, Iterable<Message> updates) {
    final cached = _messageCache.remove(chatId);
    if (cached == null) return;
    final currentRevision = _localDatabase.messageRevision(chatId);
    if (currentRevision != cached.revision + 1) return;

    final messages = List<Message>.of(cached.messages);
    final indexesById = <String, int>{
      for (var index = 0; index < messages.length; index++)
        if (messages[index].messageId.isNotEmpty)
          messages[index].messageId: index,
    };
    for (final message in updates) {
      final index = indexesById[message.messageId];
      if (index == null) {
        indexesById[message.messageId] = messages.length;
        messages.add(message);
      } else {
        messages[index] = message;
      }
    }
    messages.sort((left, right) => left.timestamp.compareTo(right.timestamp));
    _cacheMessages(
      chatId,
      currentRevision,
      List<Message>.unmodifiable(messages),
    );
  }

  List<ModelTokenUsageRecord> _toTokenUsageRecords(
    Iterable<Map<String, Object?>> records,
  ) {
    return List<ModelTokenUsageRecord>.unmodifiable(
      records.map((record) {
        return ModelTokenUsageRecord(
          messageId: record['message_id']?.toString() ?? '',
          chatId: record['chat_id']?.toString() ?? '',
          botId: record['bot_id']?.toString() ?? '',
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            _readCount(record['timestamp']),
          ),
          operationKind: record['operation_kind']?.toString() ?? 'chat_reply',
          usage: ModelTokenUsage(
            model: record['token_model']?.toString() ?? '',
            inputTokens: _readCount(record['input_token_count']),
            outputTokens: _readCount(record['output_token_count']),
            totalTokens: _readCount(record['total_token_count']),
          ),
        );
      }),
    );
  }
}

class _CachedMessages {
  const _CachedMessages({required this.revision, required this.messages});

  final int revision;
  final List<Message> messages;
}

int _readCount(Object? value) {
  return switch (value) {
    final int count => count,
    final num count => count.toInt(),
    _ => int.tryParse(value?.toString() ?? '') ?? 0,
  };
}
