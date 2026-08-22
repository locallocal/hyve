import 'package:hyve/data/models/agent_memory_evolution_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/agent_memory.dart';
import 'package:hyve/domain/repositories/agent_memory_evolution_repository.dart';

final class SqliteAgentMemoryEvolutionRepository
    implements AgentMemoryEvolutionRepository {
  const SqliteAgentMemoryEvolutionRepository({
    required LocalDatabaseService localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;

  @override
  Future<void> save(AgentMemoryEvolutionRun run) =>
      _localDatabase.saveAgentMemoryEvolutionRun(
        AgentMemoryEvolutionRunRecord.fromDomain(run).values,
      );

  @override
  Future<List<AgentMemoryEvolutionRun>> getForAgent(
    String agentId, {
    int limit = 50,
  }) async {
    if (limit < 1 || limit > 200) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 200.');
    }
    return List<AgentMemoryEvolutionRun>.unmodifiable(
      (await _localDatabase.loadAgentMemoryEvolutionRuns(
        agentId,
        limit: limit,
      )).map((row) => AgentMemoryEvolutionRunRecord(row).toDomain()),
    );
  }
}
