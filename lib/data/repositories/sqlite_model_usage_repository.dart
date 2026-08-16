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
        'token_model': record.usage.model,
        'input_token_count': record.usage.inputTokens,
        'output_token_count': record.usage.outputTokens,
        'total_token_count': record.usage.effectiveTotalTokens,
        'timestamp': record.timestamp.millisecondsSinceEpoch,
      });
}
