import 'package:hyve/domain/models/agent_memory.dart';

abstract interface class AgentMemoryRepository {
  Stream<String> get changes;

  Future<int> getRevision(String agentId);

  Future<List<AgentMemory>> list(String agentId, {bool includeHistory = false});

  Future<AgentMemory?> read(String agentId, String memoryId);

  Future<AgentMemorySearchResult> search(AgentMemorySearchRequest request);

  /// Creates or evolves a logical `(agentId, memoryKey)` record.
  Future<AgentMemoryMutationResult> propose(
    AgentMemory candidate, {
    int? expectedRevision,
  });

  /// User correction is an explicit new immutable version.
  Future<AgentMemoryMutationResult> correct({
    required String agentId,
    required String memoryId,
    required String content,
    required AgentMemoryReuseScope reuseScope,
    int? expectedRevision,
  });

  Future<AgentMemoryMutationResult> forget({
    required String agentId,
    required String memoryId,
    int? expectedRevision,
  });
}
