import 'package:hyve/data/models/project_execution_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/agent_run.dart';
import 'package:hyve/domain/repositories/agent_run_repository.dart';

final class SqliteAgentRunRepository implements AgentRunRepository {
  const SqliteAgentRunRepository({required LocalDatabaseService localDatabase})
    : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;

  @override
  Future<AgentRun?> getRun(String id) async {
    final records = await _localDatabase.loadAgentRun(id);
    return records.isEmpty ? null : AgentRunRecord(records.single).toDomain();
  }

  @override
  Future<List<AgentRun>> getForTurn(String turnId) async {
    return (await _localDatabase.loadAgentRunsForTurn(turnId))
        .map((record) => AgentRunRecord(record).toDomain())
        .toList(growable: false);
  }

  @override
  Future<List<AgentRun>> getActiveForProject(String projectId) async {
    return (await _localDatabase.loadActiveAgentRunsForProject(projectId))
        .map((record) => AgentRunRecord(record).toDomain())
        .toList(growable: false);
  }

  @override
  Future<void> save(AgentRun run) {
    return _localDatabase.saveAgentRunWithAudit(
      AgentRunRecord.fromDomain(run).values,
    );
  }
}
