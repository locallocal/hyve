import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/repositories/sqlite_conversation_summary_repository.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/data/services/project_conversation_summary_storage.dart';
import 'package:hyve/domain/models/conversation_summary.dart';
import 'package:hyve/domain/models/project_event.dart';
import 'package:hyve/domain/repositories/project_event_repository.dart';
import 'package:hyve/domain/services/conversation_summary_source_digest.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Database database;
  late Directory support;
  late SqliteConversationSummaryRepository repository;
  late List<ProjectEvent> events;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseService.databaseVersion,
        onConfigure: DatabaseService.configure,
        onCreate: DatabaseService.createSchema,
      ),
    );
    support = await Directory.systemTemp.createTemp('hyve-summary-v19-');
    final now = DateTime.utc(2026, 8, 22);
    await database.insert('projects', <String, Object?>{
      'id': 'project-1',
      'name': 'Project',
      'ui_metadata_json': '{}',
      'response_policy_json': _responsePolicy,
      'last_event_sequence': 2,
      'last_message_sequence': 2,
      'last_message': 'answer',
      'last_message_at': now.millisecondsSinceEpoch,
      'created_at': now.millisecondsSinceEpoch,
      'updated_at': now.millisecondsSinceEpoch,
    });
    events = <ProjectEvent>[
      _event('event-1', 1, 'question', ProjectEventActorType.user),
      _event('event-2', 2, 'answer', ProjectEventActorType.agent),
    ];
    final storage = ProjectAgentStorageService(
      supportDirectoryProvider: () async => support,
    );
    repository = SqliteConversationSummaryRepository(
      localDatabase: LocalDatabaseService(
        databaseProvider: () async => database,
      ),
      storage: ProjectConversationSummaryStorage(storage: storage),
      eventRepository: _EventRepository(events),
    );
  });

  tearDown(() async {
    await repository.dispose();
    await database.close();
    if (await support.exists()) await support.delete(recursive: true);
  });

  test('round-trips immutable body and source digest', () async {
    final summary = _summary(events);
    expect(
      await repository.commitRolling(expectedRevision: 0, summary: summary),
      isTrue,
    );

    final restored = await repository.getActiveRollingSummaries(
      'project-1',
      throughMessageSequence: 2,
    );
    expect(restored.single.markdown, '# Summary\n\n- answer');
    expect(restored.single.segment.sourceStartMessageSequence, 1);
    expect((await repository.getState('project-1')).revision, 1);
  });

  test('rejects a rolling segment that leaves a sequence gap', () async {
    expect(
      await repository.commitRolling(
        expectedRevision: 0,
        summary: _summary(events),
      ),
      isTrue,
    );

    final now = DateTime.utc(2026, 8, 22);
    final gap = ProjectConversationSummary(
      segment: ConversationSummarySegment(
        id: 'summary-gap',
        projectId: 'project-1',
        summarySetId: 'set-1',
        sourceStartMessageSequence: 4,
        sourceEndMessageSequence: 5,
        kind: ConversationSummaryKind.rolling,
        sourceEventIds: const <String>['event-4', 'event-5'],
        sourceDigest: 'digest-gap',
        fileName: 'summary-gap.md',
        contentDigest: '',
        createdAt: now,
        updatedAt: now,
      ),
      markdown: '# Gap',
    );
    expect(
      await repository.commitRolling(expectedRevision: 1, summary: gap),
      isFalse,
    );
    final state = await repository.getState('project-1');
    expect(state.revision, 1);
    expect(state.coveredThroughMessageSequence, 2);
  });

  test(
    'content tampering invalidates the segment and active coverage',
    () async {
      await repository.commitRolling(
        expectedRevision: 0,
        summary: _summary(events),
      );
      final body = File(
        path.join(
          support.path,
          'projects',
          'project-1',
          'context',
          'summaries',
          'summary-1.md',
        ),
      );
      await body.writeAsString('tampered');

      expect(
        await repository.getActiveRollingSummaries(
          'project-1',
          throughMessageSequence: 2,
        ),
        isEmpty,
      );
      final state = await repository.getState('project-1');
      expect(state.coveredThroughMessageSequence, 0);
      expect(
        state.compactionStatus,
        ConversationSummaryCompactionStatus.failed,
      );
    },
  );
}

ProjectConversationSummary _summary(List<ProjectEvent> events) {
  final now = DateTime.utc(2026, 8, 22);
  return ProjectConversationSummary(
    segment: ConversationSummarySegment(
      id: 'summary-1',
      projectId: 'project-1',
      summarySetId: 'set-1',
      sourceStartMessageSequence: 1,
      sourceEndMessageSequence: 2,
      kind: ConversationSummaryKind.rolling,
      sourceEventIds: events.map((event) => event.id),
      sourceDigest: const ConversationSummarySourceDigest()(events),
      fileName: 'summary-1.md',
      contentDigest: '',
      estimatedTokenCount: 10,
      createdAt: now,
      updatedAt: now,
    ),
    markdown: '# Summary\n\n- answer',
  );
}

ProjectEvent _event(
  String id,
  int sequence,
  String content,
  ProjectEventActorType actorType,
) => ProjectEvent(
  id: id,
  projectId: 'project-1',
  turnId: 'turn-$sequence',
  sequence: sequence,
  messageSequence: sequence,
  eventType:
      actorType == ProjectEventActorType.user
          ? ProjectEventType.userMessage
          : ProjectEventType.agentMessage,
  actorType: actorType,
  actorId: actorType == ProjectEventActorType.user ? 'user-1' : 'agent-1',
  content: content,
  payload: ProjectMessagePayload(),
  createdAt: DateTime.utc(2026, 8, 22),
  updatedAt: DateTime.utc(2026, 8, 22),
);

final class _EventRepository implements ProjectEventRepository {
  _EventRepository(this.events);

  final List<ProjectEvent> events;

  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<ProjectEvent?> getMessageAt(
    String projectId,
    int messageSequence,
  ) async {
    return events
        .where((event) => event.messageSequence == messageSequence)
        .firstOrNull;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _responsePolicy =
    '{"schemaVersion":1,"broadcastDecision":{"concurrency":4,'
    '"maxInputTokens":4096,"maxOutputTokens":128,"timeoutMs":10000,'
    '"maxAttempts":1,"failureOutcome":"pass"},"replyConcurrency":2,'
    '"autonomousChain":{"maxDepth":4,"maxAgentMessagesPerRoot":16},'
    '"delivery":{"defaultVisibility":"project","maxDepth":4,'
    '"maxDeliveriesPerTurn":8}}';
