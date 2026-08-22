import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_memory_candidate_extractor.dart';
import 'package:hyve/domain/repositories/agent_memory_evolution_repository.dart';
import 'package:hyve/domain/repositories/agent_memory_repository.dart';
import 'package:hyve/domain/repositories/conversation_summary_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';
import 'package:hyve/domain/use_cases/assemble_agent_run_context.dart';
import 'package:hyve/domain/use_cases/evolve_agent_memory.dart';

void main() {
  test(
    'assembles AgentMemory then routing, summary, and uncovered messages',
    () async {
      final events = <ProjectEvent>[
        for (var sequence = 1; sequence <= 4; sequence++)
          _event(sequence, 'message $sequence'),
      ];
      final memory = _memory(kind: AgentMemoryKind.userPreference);
      final assembler = AssembleAgentRunContext(
        summaryRepository: _SummaryRepository(_summary()),
        memoryRepository: _MemoryRepository(<AgentMemory>[memory]),
        projectRepository: _ProjectRepository(),
      );

      final result = await assembler(
        agent: _agent(),
        projectId: 'project-1',
        sourceEvent: events[3],
        contextThroughMessageSequence: 4,
        visibleHistory: <ProjectEvent>[...events, _event(5, 'future')],
      );

      expect(result.contextMessages, hasLength(3));
      expect(result.contextMessages[0].content, contains('<agent_memory'));
      expect(
        result.contextMessages[1].content,
        contains('<project_run_context>'),
      );
      expect(
        result.contextMessages[2].content,
        contains('<conversation_summary'),
      );
      expect(
        result.visibleHistory.map((event) => event.messageSequence),
        <int?>[3, 4],
      );
      expect(result.report.agentMemoryIds, <String>['memory-1']);
      expect(result.report.conversationSummarySegmentIds, <String>[
        'summary-1',
      ]);
      expect(result.report.coveredThroughMessageSequence, 2);
    },
  );

  test(
    'evolution applies source scope, approval policy, and secret filter',
    () async {
      final memoryRepository = _MemoryRepository(const <AgentMemory>[]);
      final audit = _EvolutionRepository();
      final useCase = EvolveAgentMemory(
        memoryRepository: memoryRepository,
        extractor: _Extractor(<AgentMemoryCandidateDraft>[
          AgentMemoryCandidateDraft(
            memoryKey: 'project.deadline',
            kind: AgentMemoryKind.fact,
            content: 'The project deadline is Friday.',
            confidence: 0.9,
            sourceEventIds: const <String>['event-1'],
          ),
          AgentMemoryCandidateDraft(
            memoryKey: 'user.private_style',
            kind: AgentMemoryKind.userPreference,
            content: 'User privately prefers a terse tone.',
            sensitivity: AgentMemorySensitivity.private,
            confidence: 0.9,
            sourceEventIds: const <String>['event-1'],
          ),
          AgentMemoryCandidateDraft(
            memoryKey: 'secret.bad',
            kind: AgentMemoryKind.fact,
            content: 'api_key=abcdefghijklmnop',
            confidence: 1,
            sourceEventIds: const <String>['event-1'],
          ),
        ]),
        evolutionRepository: audit,
        clock: () => DateTime.utc(2026, 8, 22),
        idFactory:
            (prefix) => '$prefix-${memoryRepository.mutations.length + 1}',
      );

      final result = await useCase(
        agent: _agent(),
        projectId: 'project-1',
        observedEvents: <ProjectEvent>[_event(1, 'evidence')],
        contextThroughMessageSequence: 1,
      );

      expect(result.memories, hasLength(2));
      expect(result.rejectedCount, 1);
      expect(
        result.memories[0].reuseScope,
        AgentMemoryReuseScope.sourceProjectOnly,
      );
      expect(result.memories[0].state, AgentMemoryState.active);
      expect(result.memories[1].reuseScope, AgentMemoryReuseScope.userApproved);
      expect(result.memories[1].state, AgentMemoryState.candidate);
      expect(audit.saved.single.inputDigest, isNotEmpty);
      expect(audit.saved.single.resultCount, 2);
    },
  );
}

Agent _agent() => Agent(
  id: 'agent-1',
  name: 'Agent',
  avatar: '',
  provider: 'test',
  baseUrl: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: 'help',
  createdAt: DateTime.utc(2026, 8, 22),
  updatedAt: DateTime.utc(2026, 8, 22),
);

AgentMemory _memory({required AgentMemoryKind kind}) => AgentMemory(
  id: 'memory-1',
  agentId: 'agent-1',
  memoryKey: 'user.style',
  kind: kind,
  content: 'Prefer concise answers.',
  state: AgentMemoryState.active,
  reuseScope: AgentMemoryReuseScope.crossProject,
  confidence: 0.9,
  createdAt: DateTime.utc(2026, 8, 22),
  updatedAt: DateTime.utc(2026, 8, 22),
);

ProjectEvent _event(int sequence, String content) => ProjectEvent(
  id: 'event-$sequence',
  projectId: 'project-1',
  turnId: 'turn-$sequence',
  sequence: sequence,
  messageSequence: sequence,
  eventType: ProjectEventType.userMessage,
  actorType: ProjectEventActorType.user,
  actorId: 'user-1',
  content: content,
  payload: ProjectMessagePayload(),
  createdAt: DateTime.utc(2026, 8, 22),
  updatedAt: DateTime.utc(2026, 8, 22),
);

ProjectConversationSummary _summary() {
  final now = DateTime.utc(2026, 8, 22);
  return ProjectConversationSummary(
    segment: ConversationSummarySegment(
      id: 'summary-1',
      projectId: 'project-1',
      summarySetId: 'set-1',
      sourceStartMessageSequence: 1,
      sourceEndMessageSequence: 2,
      kind: ConversationSummaryKind.rolling,
      sourceEventIds: const <String>['event-1', 'event-2'],
      sourceDigest: 'digest',
      fileName: 'summary-1.md',
      contentDigest: 'content',
      contentBytes: 7,
      estimatedTokenCount: 10,
      status: ConversationSummarySegmentStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
    markdown: 'summary',
  );
}

final class _MemoryRepository implements AgentMemoryRepository {
  _MemoryRepository(this.initial);

  final List<AgentMemory> initial;
  final List<AgentMemory> mutations = <AgentMemory>[];

  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<int> getRevision(String agentId) async => mutations.length;

  @override
  Future<AgentMemoryMutationResult> propose(
    AgentMemory candidate, {
    int? expectedRevision,
  }) async {
    mutations.add(candidate);
    return AgentMemoryMutationResult(
      memory: candidate,
      revision: mutations.length,
    );
  }

  @override
  Future<AgentMemorySearchResult> search(
    AgentMemorySearchRequest request,
  ) async {
    return AgentMemorySearchResult(
      items: initial,
      estimatedTokenCount: 10,
      revision: 4,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _SummaryRepository implements ConversationSummaryRepository {
  _SummaryRepository(this.summary);

  final ProjectConversationSummary summary;

  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<List<ProjectConversationSummary>> getActiveRollingSummaries(
    String projectId, {
    required int throughMessageSequence,
  }) async => <ProjectConversationSummary>[summary];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _ProjectRepository implements ProjectRepository {
  @override
  Stream<List<Project>> get changes => const Stream<List<Project>>.empty();

  @override
  Future<List<Project>> getProjects({bool forceRefresh = false}) async =>
      <Project>[_project()];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Project _project() => Project(
  id: 'project-1',
  name: 'Project',
  lastEventSequence: 5,
  lastMessageSequence: 5,
  lastMessage: 'future',
  lastMessageAt: DateTime.utc(2026, 8, 22),
  createdAt: DateTime.utc(2026, 8, 22),
  updatedAt: DateTime.utc(2026, 8, 22),
);

final class _Extractor implements AgentMemoryCandidateExtractor {
  _Extractor(this.candidates);

  final List<AgentMemoryCandidateDraft> candidates;

  @override
  Future<AgentMemoryCandidateExtractionResult> extract(
    AgentMemoryCandidateExtractionRequest request,
  ) async => AgentMemoryCandidateExtractionResult(candidates: candidates);
}

final class _EvolutionRepository implements AgentMemoryEvolutionRepository {
  final List<AgentMemoryEvolutionRun> saved = <AgentMemoryEvolutionRun>[];

  @override
  Future<void> save(AgentMemoryEvolutionRun run) async => saved.add(run);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
