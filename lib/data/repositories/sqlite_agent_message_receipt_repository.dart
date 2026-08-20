import 'package:hyve/data/models/project_inbox_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/agent_message_receipt.dart';
import 'package:hyve/domain/repositories/agent_message_receipt_repository.dart';

final class SqliteAgentMessageReceiptRepository
    implements AgentMessageReceiptRepository {
  const SqliteAgentMessageReceiptRepository({
    required LocalDatabaseService localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;

  @override
  Future<AgentMessageReceipt?> getReceipt(
    String projectId,
    String agentId,
    int messageSequence,
  ) async {
    final records = await _localDatabase.loadAgentMessageReceipt(
      projectId,
      agentId,
      messageSequence,
    );
    return records.isEmpty
        ? null
        : AgentMessageReceiptRecord(records.single).toDomain();
  }

  @override
  Future<List<AgentMessageReceipt>> getForTurn(String turnId) async =>
      (await _localDatabase.loadAgentMessageReceiptsForTurn(turnId))
          .map((record) => AgentMessageReceiptRecord(record).toDomain())
          .toList(growable: false);
}
