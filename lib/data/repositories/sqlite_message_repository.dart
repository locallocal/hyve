import 'dart:async';

import 'package:stars/data/models/local_records.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/message_repository.dart';

class SqliteMessageRepository implements MessageRepository {
  SqliteMessageRepository({required LocalDatabaseService localDatabase})
    : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _identitySequence = 0;

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
    final records = await _localDatabase.loadMessages(chatId);
    return List<Message>.unmodifiable(
      records.map((record) => MessageRecord(record).toDomain()),
    );
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
    _changes.add(null);
    return identified;
  }

  @override
  Future<List<Message>> upsertMessages(Iterable<Message> messages) async {
    final identified = messages.map(_ensureIdentity).toList(growable: false);
    await _localDatabase.upsertMessages(
      identified.map((message) => MessageRecord.fromDomain(message).values),
    );
    _changes.add(null);
    return List<Message>.unmodifiable(identified);
  }

  @override
  Future<void> deleteMessages(String chatId) async {
    await _localDatabase.deleteMessages(chatId);
    _changes.add(null);
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

int _readCount(Object? value) {
  return switch (value) {
    final int count => count,
    final num count => count.toInt(),
    _ => int.tryParse(value?.toString() ?? '') ?? 0,
  };
}
