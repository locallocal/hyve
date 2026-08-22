import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/message.dart';
import 'package:hyve/domain/repositories/model_usage_repository.dart';

final class SqliteModelUsageRepository implements ModelUsageRepository {
  const SqliteModelUsageRepository({
    required LocalDatabaseService localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;

  @override
  Future<void> upsert(ModelTokenUsageRecord record) =>
      _localDatabase.upsertModelUsage({
        'message_id': record.messageId,
        'chat_id': record.chatId,
        'bot_id': record.botId,
        'operation_kind': record.operationKind,
        'run_id': record.runId,
        'token_model': record.usage.model,
        'input_token_count': record.usage.inputTokens,
        'output_token_count': record.usage.outputTokens,
        'total_token_count': record.usage.effectiveTotalTokens,
        'timestamp': record.timestamp.millisecondsSinceEpoch,
      });

  @override
  Future<List<ModelTokenUsageRecord>> getForProject(String projectId) async {
    final rows = await _localDatabase.loadTokenUsageRecordsForChat(projectId);
    return List<ModelTokenUsageRecord>.unmodifiable(
      rows.map(
        (row) => ModelTokenUsageRecord(
          messageId: row['message_id']?.toString() ?? '',
          chatId: row['chat_id']?.toString() ?? '',
          botId: row['bot_id']?.toString() ?? '',
          runId: row['run_id']?.toString() ?? '',
          operationKind: row['operation_kind']?.toString() ?? 'chat_reply',
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            _readCount(row['timestamp']),
          ),
          usage: ModelTokenUsage(
            model: row['token_model']?.toString() ?? '',
            inputTokens: _readCount(row['input_token_count']),
            outputTokens: _readCount(row['output_token_count']),
            totalTokens: _readCount(row['total_token_count']),
          ),
        ),
      ),
    );
  }
}

int _readCount(Object? value) => switch (value) {
  final int count => count,
  final num count => count.toInt(),
  _ => int.tryParse(value?.toString() ?? '') ?? 0,
};
