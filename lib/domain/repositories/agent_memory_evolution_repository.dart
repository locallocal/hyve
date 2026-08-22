import 'package:hyve/domain/models/agent_memory.dart';

abstract interface class AgentMemoryEvolutionRepository {
  Future<void> save(AgentMemoryEvolutionRun run);

  Future<List<AgentMemoryEvolutionRun>> getForAgent(
    String agentId, {
    int limit = 50,
  });
}
