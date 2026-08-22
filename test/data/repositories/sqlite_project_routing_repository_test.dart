import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/repositories/sqlite_agent_message_receipt_repository.dart';
import 'package:hyve/data/repositories/sqlite_agent_repository.dart';
import 'package:hyve/data/repositories/sqlite_agent_run_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_agent_cursor_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_membership_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_message_route_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_repository.dart';
import 'package:hyve/data/services/bot_api_key_cipher.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/use_cases/route_project_message.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late Directory support;
  late SqliteAgentRepository agents;
  late SqliteProjectRepository projects;
  late SqliteProjectMembershipRepository memberships;
  late SqliteProjectAgentCursorRepository cursors;
  late SqliteAgentMessageReceiptRepository receipts;
  late SqliteAgentRunRepository runs;
  late RouteProjectMessage route;
  var id = 0;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseService.databaseVersion,
        onConfigure: DatabaseService.configure,
        onCreate: DatabaseService.createSchema,
      ),
    );
    support = await Directory.systemTemp.createTemp('hyve_phase_two_route_');
    final localDatabase = LocalDatabaseService(
      databaseProvider: () async => database,
    );
    final storage = ProjectAgentStorageService(
      supportDirectoryProvider: () async => support,
    );
    agents = SqliteAgentRepository(
      localDatabase: localDatabase,
      apiKeyCipher: const _Cipher(),
      storage: storage,
    );
    projects = SqliteProjectRepository(
      localDatabase: localDatabase,
      storage: storage,
    );
    memberships = SqliteProjectMembershipRepository(
      localDatabase: localDatabase,
    );
    cursors = SqliteProjectAgentCursorRepository(localDatabase: localDatabase);
    receipts = SqliteAgentMessageReceiptRepository(
      localDatabase: localDatabase,
    );
    runs = SqliteAgentRunRepository(localDatabase: localDatabase);
    route = RouteProjectMessage(
      repository: SqliteProjectMessageRouteRepository(
        localDatabase: localDatabase,
      ),
      clock: () => DateTime(2026, 8, 21),
      idFactory: (prefix) => '$prefix-${id++}',
    );
    await agents.addAgent(_agent('agent-1', '同名'));
    await agents.addAgent(_agent('agent-2', '同名'));
    final now = DateTime(2026, 8, 21);
    await projects.addProjectWithMemberships(_project(), <ProjectMembership>[
      ProjectMembership(
        projectId: 'project-1',
        agentId: 'agent-1',
        position: 0,
        joinedAt: now,
        updatedAt: now,
      ),
      ProjectMembership(
        projectId: 'project-1',
        agentId: 'agent-2',
        position: 1,
        joinedAt: now,
        updatedAt: now,
      ),
    ]);
  });

  tearDown(() async {
    await agents.dispose();
    await projects.dispose();
    await memberships.dispose();
    await cursors.dispose();
    await database.close();
    await support.delete(recursive: true);
  });

  test(
    'routes same-name mentions by stable id and deduplicates targets',
    () async {
      final routed = await route(
        projectId: 'project-1',
        draft: ProjectMessageDraft(
          text: '@同名 请处理，再请 @同名 确认',
          mentions: const <MentionSpan>[
            MentionSpan(
              agentId: 'agent-2',
              start: 0,
              length: 3,
              displayTextSnapshot: '@同名',
            ),
            MentionSpan(
              agentId: 'agent-2',
              start: 11,
              length: 3,
              displayTextSnapshot: '@同名',
            ),
          ],
        ),
      );

      expect(routed.turn.routingMode, ProjectTurnRoutingMode.targeted);
      expect(routed.turn.recipientCount, 1);
      expect(routed.event.messageSequence, 1);
      expect(routed.event.targetAgentIds, <String>['agent-2']);
      expect(routed.activeAgentIds, <String>['agent-1', 'agent-2']);
      expect(
        (await cursors.getCursor(
          'project-1',
          'agent-1',
        ))?.lastProcessedMessageSequence,
        0,
      );
      expect(
        (await cursors.getCursor(
          'project-1',
          'agent-2',
        ))?.lastProcessedMessageSequence,
        0,
      );
    },
  );

  test(
    'rejects a removed mention without allocating a message index',
    () async {
      await memberships.remove(
        'project-1',
        'agent-2',
        DateTime(2026, 8, 21, 1),
      );

      await expectLater(
        route(
          projectId: 'project-1',
          draft: ProjectMessageDraft(
            text: '@同名 处理',
            mentions: const <MentionSpan>[
              MentionSpan(
                agentId: 'agent-2',
                start: 0,
                length: 3,
                displayTextSnapshot: '@同名',
              ),
            ],
          ),
        ),
        throwsA(
          isA<ProjectMessageRouteFailure>().having(
            (failure) => failure.code,
            'code',
            'project_message_target_not_active',
          ),
        ),
      );

      expect((await projects.getProject('project-1'))?.lastMessageSequence, 0);
      final events = await database.query('project_events');
      expect(events, hasLength(1));
      expect(events.single['event_type'], 'membershipChanged');
      expect(events.single['message_sequence'], isNull);
      expect(await database.query('project_turns'), isEmpty);
    },
  );

  test(
    'broadcast snapshots active agents and receipt advances atomically',
    () async {
      final routed = await route(
        projectId: 'project-1',
        draft: ProjectMessageDraft(text: '大家给出意见'),
      );
      expect(routed.turn.routingMode, ProjectTurnRoutingMode.broadcast);
      expect(routed.event.targetAgentIds, <String>['agent-1', 'agent-2']);

      final claim = await cursors.claimNext(
        projectId: 'project-1',
        agentId: 'agent-1',
        leaseOwner: 'test-worker',
        now: DateTime(2026, 8, 21, 1),
      );
      expect(claim?.event.id, routed.event.id);
      await cursors.complete(
        AgentMessageReceipt(
          projectId: 'project-1',
          agentId: 'agent-1',
          messageSequence: 1,
          messageEventId: routed.event.id,
          turnId: routed.turn.id,
          outcome: AgentMessageReceiptOutcome.passed,
          completedAt: DateTime(2026, 8, 21, 1, 1),
        ),
        leaseOwner: 'test-worker',
      );

      expect(
        (await receipts.getReceipt('project-1', 'agent-1', 1))?.outcome,
        AgentMessageReceiptOutcome.passed,
      );
      expect(
        (await cursors.getCursor(
          'project-1',
          'agent-1',
        ))?.lastProcessedMessageSequence,
        1,
      );
      await expectLater(
        cursors.complete(
          AgentMessageReceipt(
            projectId: 'project-1',
            agentId: 'agent-2',
            messageSequence: 1,
            messageEventId: routed.event.id,
            turnId: routed.turn.id,
            outcome: AgentMessageReceiptOutcome.passed,
            completedAt: DateTime(2026, 8, 21, 1, 1),
          ),
          leaseOwner: 'not-claimed',
        ),
        throwsStateError,
      );
    },
  );

  test('startup recovery releases an unexpired orphan claim', () async {
    final routed = await route(
      projectId: 'project-1',
      draft: ProjectMessageDraft(text: 'recover this backlog'),
    );
    final claimedAt = DateTime(2026, 8, 21, 1);
    final claim = await cursors.claimNext(
      projectId: 'project-1',
      agentId: 'agent-1',
      leaseOwner: 'old-process',
      now: claimedAt,
      leaseDuration: const Duration(minutes: 10),
    );
    expect(claim, isNotNull);
    const runId = 'orphan-run';
    await runs.save(
      AgentRun(
        id: runId,
        projectId: 'project-1',
        turnId: routed.turn.id,
        agentId: 'agent-1',
        sourceMessageEventId: routed.event.id,
        sourceMessageSequence: 1,
        contextThroughMessageSequence: 1,
        rootRunId: runId,
        phase: AgentRunPhase.reply,
        status: AgentRunStatus.running,
        agentSnapshot: const AgentRunSnapshot(
          agentName: '同名',
          provider: 'test',
          model: 'model',
          systemPromptDigest: 'prompt',
          capabilityDigest: 'capability',
        ),
        startedAt: claimedAt,
        createdAt: claimedAt,
      ),
    );
    await cursors.setActiveRun(
      projectId: 'project-1',
      agentId: 'agent-1',
      leaseOwner: 'old-process',
      runId: runId,
      now: claimedAt,
    );

    await cursors.recoverInterrupted(claimedAt.add(const Duration(seconds: 1)));

    final recovered = await cursors.getCursor('project-1', 'agent-1');
    expect(recovered?.processingMessageSequence, isNull);
    expect(recovered?.activeRunId, isNull);
    expect(recovered?.workerState, AgentInboxWorkerState.scheduled);
    expect((await runs.getRun(runId))?.status, AgentRunStatus.interrupted);
    final runAudits = (await database.query(
      'project_events',
      where: 'event_type = ?',
      whereArgs: const <Object?>['runStatusChanged'],
      orderBy: 'sequence ASC',
    ));
    expect(runAudits, hasLength(2));
    expect(runAudits.last['payload_json'], contains('interrupted'));
    final reclaimed = await cursors.claimNext(
      projectId: 'project-1',
      agentId: 'agent-1',
      leaseOwner: 'new-process',
      now: claimedAt.add(const Duration(seconds: 2)),
    );
    expect(reclaimed?.event.id, routed.event.id);
  });

  test(
    'stores only valid fixed artifact version references atomically',
    () async {
      final now = DateTime(2026, 8, 21).millisecondsSinceEpoch;
      await database.insert('project_artifacts', <String, Object?>{
        'id': 'artifact-1',
        'project_id': 'project-1',
        'name': 'brief.md',
        'relative_path': 'docs/brief.md',
        'kind': 'document',
        'mime_type': 'text/markdown',
        'current_version_id': 'version-1',
        'search_status': 'indexed',
        'metadata_json': '{}',
        'created_by_type': 'user',
        'created_by_id': 'me',
        'source_run_id': '',
        'created_at': now,
        'updated_at': now,
      });
      await database.insert('project_artifact_versions', <String, Object?>{
        'id': 'version-1',
        'artifact_id': 'artifact-1',
        'version_number': 1,
        'relative_blob_path': 'artifacts/blobs/artifact-1/version-1/content',
        'content_digest':
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        'byte_length': 5,
        'mime_type': 'text/markdown',
        'created_by_type': 'user',
        'created_by_id': 'me',
        'source_run_id': '',
        'created_at': now,
      });

      final routed = await route(
        projectId: 'project-1',
        draft: ProjectMessageDraft(
          text: 'review the brief',
          attachments: const <PendingAttachment>[
            PendingAttachment(
              sourcePath: '/persisted/project-1/report.txt',
              kind: PendingAttachmentKind.file,
              displayName: 'report.txt',
            ),
          ],
          projectArtifactVersionIds: const <String>['version-1'],
        ),
      );

      expect((routed.event.payload as ProjectMessagePayload).files, <String>[
        '/persisted/project-1/report.txt',
      ]);
      expect(
        (routed.event.payload as ProjectMessagePayload)
            .projectArtifactVersionIds,
        <String>['version-1'],
      );
      expect(await database.query('project_event_artifacts'), [
        <String, Object?>{
          'event_id': routed.event.id,
          'artifact_id': 'artifact-1',
          'artifact_version_id': 'version-1',
          'relation': 'attachment',
          'position': 0,
        },
      ]);

      await expectLater(
        route(
          projectId: 'project-1',
          draft: ProjectMessageDraft(
            text: 'invalid reference',
            projectArtifactVersionIds: const <String>['missing-version'],
          ),
        ),
        throwsA(
          isA<ProjectMessageRouteFailure>().having(
            (failure) => failure.code,
            'code',
            'project_message_artifact_version_not_found',
          ),
        ),
      );
      expect(await database.query('project_events'), hasLength(1));
      expect(
        (await database.query(
          'projects',
          columns: const <String>['last_message_sequence'],
        )).single['last_message_sequence'],
        1,
      );
    },
  );

  test('broadcast in a zero-member Project completes without a run', () async {
    final removedAt = DateTime(2026, 8, 21, 2);
    await memberships.remove('project-1', 'agent-1', removedAt);
    await memberships.remove('project-1', 'agent-2', removedAt);

    final routed = await route(
      projectId: 'project-1',
      draft: ProjectMessageDraft(text: 'message for an empty project'),
    );

    expect(routed.activeAgentIds, isEmpty);
    expect(routed.event.targetAgentIds, isEmpty);
    expect(routed.turn.status, ProjectTurnStatus.completed);
    expect(routed.turn.noParticipant, isTrue);
    expect(routed.turn.completedAt, isNotNull);
    expect(await database.query('agent_runs'), isEmpty);
  });
}

Agent _agent(String id, String name) => Agent(
  id: id,
  name: name,
  avatar: '',
  provider: 'test',
  baseUrl: '',
  apiKey: 'secret',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: 'help',
  createdAt: DateTime(2026, 8, 21),
  updatedAt: DateTime(2026, 8, 21),
);

Project _project() => Project(
  id: 'project-1',
  name: 'Project',
  lastMessageAt: DateTime(2026, 8, 21),
  createdAt: DateTime(2026, 8, 21),
  updatedAt: DateTime(2026, 8, 21),
);

final class _Cipher implements BotApiKeyCipher {
  const _Cipher();

  @override
  bool isEncrypted(String value) => value.startsWith('encrypted:');

  @override
  Future<String> encrypt({
    required String botId,
    required String apiKey,
  }) async => apiKey.isEmpty ? '' : 'encrypted:$apiKey';

  @override
  Future<String> decrypt({
    required String botId,
    required String encrypted,
  }) async => encrypted.substring('encrypted:'.length);
}
