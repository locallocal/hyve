import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/conversation_summary_repository.dart';
import 'package:hyve/domain/repositories/project_context_summarizer.dart';
import 'package:hyve/domain/repositories/project_event_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';
import 'package:hyve/domain/use_cases/compact_conversation_messages.dart';

void main() {
  test(
    'rolling summary commits one continuous range before recent messages',
    () async {
      final summaries = _SummaryRepository(coveredThrough: 2);
      final summarizer = _Summarizer();
      final useCase = CompactConversationMessages(
        projectRepository: _ProjectRepository(),
        eventRepository: _EventRepository(),
        summaryRepository: summaries,
        summarizerFactory: (_) => summarizer,
        protectedRecentMessages: 2,
        maximumMessagesPerSegment: 4,
        clock: () => DateTime.utc(2026, 8, 22),
      );

      final result = await useCase(agent: _agent(), projectId: 'project-1');

      expect(result, CompactConversationMessagesResult.committed);
      expect(
        summarizer.request!.sourceEvents.map((event) => event.messageSequence),
        <int?>[3, 4, 5, 6],
      );
      expect(summaries.rolling!.segment.sourceStartMessageSequence, 3);
      expect(summaries.rolling!.segment.sourceEndMessageSequence, 6);
      expect(summaries.rolling!.segment.sourceDigest, isNotEmpty);
    },
  );

  test(
    'range extraction preserves the exact requested evidence range',
    () async {
      final summaries = _SummaryRepository();
      final summarizer = _Summarizer();
      final useCase = CompactConversationMessages(
        projectRepository: _ProjectRepository(),
        eventRepository: _EventRepository(),
        summaryRepository: summaries,
        summarizerFactory: (_) => summarizer,
      );

      final result = await useCase(
        agent: _agent(),
        projectId: 'project-1',
        kind: ConversationSummaryKind.rangeExtract,
        startMessageSequence: 4,
        endMessageSequence: 7,
        manual: true,
      );

      expect(result, CompactConversationMessagesResult.committed);
      expect(
        summaries.range!.segment.kind,
        ConversationSummaryKind.rangeExtract,
      );
      expect(summaries.range!.segment.sourceEventIds, <String>[
        'event-4',
        'event-5',
        'event-6',
        'event-7',
      ]);
    },
  );
}

final class _ProjectRepository implements ProjectRepository {
  @override
  Stream<List<Project>> get changes => const Stream<List<Project>>.empty();

  @override
  Future<Project?> getProject(String id) async => Project(
    id: id,
    name: 'Project',
    lastEventSequence: 10,
    lastMessageSequence: 10,
    lastMessage: 'message 10',
    lastMessageAt: DateTime.utc(2026, 8, 22),
    createdAt: DateTime.utc(2026, 8, 22),
    updatedAt: DateTime.utc(2026, 8, 22),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _EventRepository implements ProjectEventRepository {
  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<List<ProjectEvent>> getMessageRange(
    String projectId, {
    required int startMessageSequence,
    required int endMessageSequence,
  }) async => <ProjectEvent>[
    for (
      var sequence = startMessageSequence;
      sequence <= endMessageSequence;
      sequence++
    )
      ProjectEvent(
        id: 'event-$sequence',
        projectId: projectId,
        turnId: 'turn-$sequence',
        sequence: sequence,
        messageSequence: sequence,
        eventType: ProjectEventType.userMessage,
        actorType: ProjectEventActorType.user,
        actorId: 'user-1',
        content: 'message $sequence',
        payload: ProjectMessagePayload(),
        createdAt: DateTime.utc(2026, 8, 22),
        updatedAt: DateTime.utc(2026, 8, 22),
      ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _SummaryRepository implements ConversationSummaryRepository {
  _SummaryRepository({this.coveredThrough = 0});

  final int coveredThrough;
  ProjectConversationSummary? rolling;
  ProjectConversationSummary? range;

  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<ConversationSummaryState> getState(String projectId) async =>
      ConversationSummaryState(
        projectId: projectId,
        coveredThroughMessageSequence: coveredThrough,
        activeSummarySetId: coveredThrough == 0 ? '' : 'set-existing',
        updatedAt: DateTime.utc(2026, 8, 22),
      );

  @override
  Future<List<ProjectConversationSummary>> getActiveRollingSummaries(
    String projectId, {
    required int throughMessageSequence,
  }) async => const <ProjectConversationSummary>[];

  @override
  Future<bool> commitRolling({
    required int expectedRevision,
    required ProjectConversationSummary summary,
  }) async {
    rolling = summary;
    return true;
  }

  @override
  Future<void> saveRangeExtract(ProjectConversationSummary summary) async {
    range = summary;
  }

  @override
  Future<void> setCompactionStatus(
    String projectId,
    ConversationSummaryCompactionStatus status, {
    String lastError = '',
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Summarizer implements ProjectContextSummarizer {
  ProjectContextSummaryRequest? request;

  @override
  Future<ProjectContextSummaryResult> summarize(
    ProjectContextSummaryRequest request,
  ) async {
    this.request = request;
    return const ProjectContextSummaryResult(markdown: '# Summary\n\n- data');
  }
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
  systemPrompt: '',
  createdAt: DateTime.utc(2026, 8, 22),
  updatedAt: DateTime.utc(2026, 8, 22),
);
