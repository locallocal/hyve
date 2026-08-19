import 'package:hyve/domain/models/agent.dart';

abstract interface class AgentRepository {
  Stream<List<Agent>> get changes;

  Future<List<Agent>> getAgents({bool forceRefresh = false});

  Future<Agent?> getAgent(String id);

  Future<void> addAgent(Agent agent);

  Future<void> updateAgent(Agent agent);

  /// Deletes the Agent aggregate without deleting any Project.
  Future<void> deleteAgent(String id);
}
