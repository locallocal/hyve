import 'package:hyve/domain/models/agent_run.dart';

abstract interface class AgentRunRepository {
  Future<AgentRun?> getRun(String id);

  Future<List<AgentRun>> getForTurn(String turnId);

  Future<List<AgentRun>> getActiveForProject(String projectId);

  Future<void> save(AgentRun run);
}
