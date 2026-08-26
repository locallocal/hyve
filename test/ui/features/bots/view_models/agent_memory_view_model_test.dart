import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_memory_evolution_repository.dart';
import 'package:hyve/domain/repositories/agent_memory_repository.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/ui/features/bots/view_models/agent_memory_view_model.dart';

void main() {
  test(
    'loads and compacts only redundant memories for the selected agent',
    () async {
      final repository = _MemoryRepository(<AgentMemory>[
        _memory(
          id: 'preferred',
          key: 'answer.style',
          content: 'Prefer concise answers.',
          confidence: 0.95,
        ),
        _memory(
          id: 'duplicate',
          key: 'response.style',
          content: '  prefer   CONCISE answers. ',
          confidence: 0.7,
        ),
        _memory(
          id: 'project-a',
          key: 'project-a.style',
          content: 'Prefer concise answers.',
          scope: AgentMemoryReuseScope.sourceProjectOnly,
          sourceProjectId: 'project-a',
        ),
        _memory(
          id: 'project-b',
          key: 'project-b.style',
          content: 'Prefer concise answers.',
          scope: AgentMemoryReuseScope.sourceProjectOnly,
          sourceProjectId: 'project-b',
        ),
        _memory(
          id: 'candidate',
          key: 'candidate.style',
          content: 'Use verified sources.',
          state: AgentMemoryState.candidate,
        ),
      ]);
      final viewModel = AgentMemoryViewModel(
        agentId: 'agent-1',
        agentRepository: _AgentRepository(),
        memoryRepository: repository,
        evolutionRepository: const _EvolutionRepository(),
      );
      addTearDown(viewModel.dispose);

      await viewModel.load();
      expect(viewModel.summaryItems.map((memory) => memory.id), <String>[
        'preferred',
        'duplicate',
        'project-a',
        'project-b',
      ]);

      final compacted = await viewModel.compactNow();

      expect(compacted, 1);
      expect(repository.forgottenIds, <String>['duplicate']);
      expect(repository.requestedAgentIds, everyElement('agent-1'));
      expect(viewModel.compacting, isFalse);
      expect(viewModel.summaryItems.map((memory) => memory.id), <String>[
        'preferred',
        'project-a',
        'project-b',
      ]);
    },
  );
}

AgentMemory _memory({
  required String id,
  required String key,
  required String content,
  double confidence = 0.9,
  AgentMemoryState state = AgentMemoryState.active,
  AgentMemoryReuseScope scope = AgentMemoryReuseScope.crossProject,
  String sourceProjectId = '',
}) => AgentMemory(
  id: id,
  agentId: 'agent-1',
  memoryKey: key,
  kind: AgentMemoryKind.userPreference,
  content: content,
  state: state,
  reuseScope: scope,
  confidence: confidence,
  sourceProjectId: sourceProjectId,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

final class _AgentRepository implements AgentRepository {
  @override
  Stream<List<Agent>> get changes => const Stream<List<Agent>>.empty();

  @override
  Future<Agent?> getAgent(String id) async => Agent(
    id: id,
    name: 'Agent',
    avatar: '',
    provider: 'OpenAI',
    baseUrl: '',
    apiKey: '',
    apiType: Bot.apiTypeOpenAI,
    model: 'model',
    systemPrompt: '',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _MemoryRepository implements AgentMemoryRepository {
  _MemoryRepository(Iterable<AgentMemory> memories)
    : memories = List<AgentMemory>.of(memories);

  final List<AgentMemory> memories;
  final List<String> requestedAgentIds = <String>[];
  final List<String> forgottenIds = <String>[];

  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<List<AgentMemory>> list(
    String agentId, {
    bool includeHistory = false,
  }) async {
    requestedAgentIds.add(agentId);
    return List<AgentMemory>.unmodifiable(memories);
  }

  @override
  Future<AgentMemoryMutationResult> forget({
    required String agentId,
    required String memoryId,
    int? expectedRevision,
  }) async {
    requestedAgentIds.add(agentId);
    forgottenIds.add(memoryId);
    final index = memories.indexWhere((memory) => memory.id == memoryId);
    final forgotten = memories[index].copyWith(
      state: AgentMemoryState.forgotten,
      updatedAt: DateTime(2026, 2),
    );
    memories[index] = forgotten;
    return AgentMemoryMutationResult(memory: forgotten, revision: 1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _EvolutionRepository implements AgentMemoryEvolutionRepository {
  const _EvolutionRepository();

  @override
  Future<List<AgentMemoryEvolutionRun>> getForAgent(
    String agentId, {
    int limit = 50,
  }) async => const <AgentMemoryEvolutionRun>[];

  @override
  Future<void> save(AgentMemoryEvolutionRun run) async {}
}
