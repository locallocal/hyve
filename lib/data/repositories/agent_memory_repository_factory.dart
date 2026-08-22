import 'dart:async';

import 'package:hyve/domain/models/agent.dart';
import 'package:hyve/domain/models/agent_memory.dart';
import 'package:hyve/domain/repositories/agent_memory_repository.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';

typedef ExternalAgentMemoryRepositoryProvider =
    Future<AgentMemoryRepository> Function(String backendReference);

final class AgentMemoryBackendUnavailableException implements Exception {
  const AgentMemoryBackendUnavailableException(this.backendReference);

  final String backendReference;

  @override
  String toString() => 'Agent memory backend is unavailable.';
}

final class AgentMemoryRepositoryFactory {
  const AgentMemoryRepositoryFactory({
    required AgentMemoryRepository fileRepository,
    ExternalAgentMemoryRepositoryProvider? externalProvider,
  }) : _fileRepository = fileRepository,
       _externalProvider = externalProvider;

  final AgentMemoryRepository _fileRepository;
  final ExternalAgentMemoryRepositoryProvider? _externalProvider;

  Stream<String> get changes => _fileRepository.changes;

  Future<AgentMemoryRepository> forAgent(Agent agent) async {
    if (agent.memoryBackend == AgentMemoryBackend.file) return _fileRepository;
    final provider = _externalProvider;
    if (provider == null) {
      throw AgentMemoryBackendUnavailableException(agent.memoryBackendRef);
    }
    return provider(agent.memoryBackendRef);
  }
}

/// Resolves storage from trusted Agent configuration instead of model input.
final class AgentMemoryRepositoryRouter implements AgentMemoryRepository {
  AgentMemoryRepositoryRouter({
    required AgentRepository agentRepository,
    required AgentMemoryRepositoryFactory factory,
  }) : _agentRepository = agentRepository,
       _factory = factory;

  final AgentRepository _agentRepository;
  final AgentMemoryRepositoryFactory _factory;

  @override
  Stream<String> get changes => _factory.changes;

  @override
  Future<int> getRevision(String agentId) async =>
      (await _resolve(agentId)).getRevision(agentId);

  @override
  Future<List<AgentMemory>> list(
    String agentId, {
    bool includeHistory = false,
  }) async =>
      (await _resolve(agentId)).list(agentId, includeHistory: includeHistory);

  @override
  Future<AgentMemory?> read(String agentId, String memoryId) async =>
      (await _resolve(agentId)).read(agentId, memoryId);

  @override
  Future<AgentMemorySearchResult> search(
    AgentMemorySearchRequest request,
  ) async => (await _resolve(request.agentId)).search(request);

  @override
  Future<AgentMemoryMutationResult> propose(
    AgentMemory candidate, {
    int? expectedRevision,
  }) async => (await _resolve(
    candidate.agentId,
  )).propose(candidate, expectedRevision: expectedRevision);

  @override
  Future<AgentMemoryMutationResult> correct({
    required String agentId,
    required String memoryId,
    required String content,
    required AgentMemoryReuseScope reuseScope,
    int? expectedRevision,
  }) async => (await _resolve(agentId)).correct(
    agentId: agentId,
    memoryId: memoryId,
    content: content,
    reuseScope: reuseScope,
    expectedRevision: expectedRevision,
  );

  @override
  Future<AgentMemoryMutationResult> forget({
    required String agentId,
    required String memoryId,
    int? expectedRevision,
  }) async => (await _resolve(agentId)).forget(
    agentId: agentId,
    memoryId: memoryId,
    expectedRevision: expectedRevision,
  );

  Future<AgentMemoryRepository> _resolve(String agentId) async {
    final agent = await _agentRepository.getAgent(agentId);
    if (agent == null) throw StateError('Agent does not exist.');
    return _factory.forAgent(agent);
  }
}
