import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/repositories/sqlite_agent_delivery_repository.dart';
import 'package:hyve/data/repositories/sqlite_agent_repository.dart';
import 'package:hyve/data/repositories/sqlite_agent_run_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_membership_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_message_route_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_repository.dart';
import 'package:hyve/data/services/bot_api_key_cipher.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/use_cases/deliver_to_project_agent.dart';
import 'package:hyve/domain/use_cases/route_project_message.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late Directory support;
  late SqliteAgentRepository agents;
  late SqliteProjectRepository projects;
  late SqliteProjectMembershipRepository memberships;
  late SqliteAgentRunRepository runs;
  late SqliteAgentDeliveryRepository deliveries;
  late DeliverToProjectAgent deliver;
  late Agent sourceAgent;
  late RoutedProjectMessage source;
  late AgentRun sourceRun;
  var idSequence = 0;

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
    support = await Directory.systemTemp.createTemp(
      'hyve_phase_three_delivery_',
    );
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
    runs = SqliteAgentRunRepository(localDatabase: localDatabase);
    deliveries = SqliteAgentDeliveryRepository(
      localDatabase: localDatabase,
      projectRepository: projects,
    );
    for (final id in <String>['agent-1', 'agent-2', 'agent-3']) {
      await agents.addAgent(_agent(id));
    }
    final now = DateTime(2026, 8, 22);
    await projects.addProjectWithMemberships(_project(), <ProjectMembership>[
      for (var index = 0; index < 3; index++)
        ProjectMembership(
          projectId: 'project-1',
          agentId: 'agent-${index + 1}',
          position: index,
          joinedAt: now,
          updatedAt: now,
        ),
    ]);
    final route = RouteProjectMessage(
      repository: SqliteProjectMessageRouteRepository(
        localDatabase: localDatabase,
        projectRepository: projects,
      ),
      clock: () => now,
      idFactory: (prefix) => '$prefix-${idSequence++}',
    );
    source = await route(
      projectId: 'project-1',
      draft: ProjectMessageDraft(
        text: '@Agent 1 coordinate',
        mentions: const <MentionSpan>[
          MentionSpan(
            agentId: 'agent-1',
            start: 0,
            length: 8,
            displayTextSnapshot: '@Agent 1',
          ),
        ],
      ),
    );
    sourceAgent = (await agents.getAgent('agent-1'))!;
    sourceRun = AgentRun(
      id: 'reply-run-1',
      projectId: 'project-1',
      turnId: source.turn.id,
      agentId: sourceAgent.id,
      sourceMessageEventId: source.event.id,
      sourceMessageSequence: source.event.messageSequence!,
      contextThroughMessageSequence: source.event.messageSequence!,
      rootRunId: 'reply-run-1',
      phase: AgentRunPhase.reply,
      status: AgentRunStatus.running,
      agentSnapshot: const AgentRunSnapshot(
        agentName: 'Agent 1',
        provider: 'test',
        model: 'model',
        systemPromptDigest: 'prompt',
        capabilityDigest: 'capability',
      ),
      startedAt: now,
      createdAt: now,
    );
    await runs.save(sourceRun);
    deliver = DeliverToProjectAgent(
      repository: deliveries,
      clock: () => now,
      idFactory: (prefix) => '$prefix-${idSequence++}',
    );
  });

  tearDown(() async {
    await deliveries.dispose();
    await agents.dispose();
    await projects.dispose();
    await memberships.dispose();
    await database.close();
    await support.delete(recursive: true);
  });

  test(
    'persists a default-project delivery and deduplicates retries',
    () async {
      final project = (await projects.getProject('project-1'))!;
      final request = AgentDeliveryRequest(
        targetAgentIds: const <String>['agent-2', 'agent-2'],
        kind: AgentDeliveryKind.task,
        summary: 'Review the draft',
        payload: 'Check the assumptions and report the risks.',
        requestPublicReply: true,
      );

      final first = await deliver(
        project: project,
        sourceAgent: sourceAgent,
        sourceRun: sourceRun,
        sourceTurn: source.turn,
        sourceEvent: source.event,
        request: request,
      );
      final retry = await deliver(
        project: project,
        sourceAgent: sourceAgent,
        sourceRun: sourceRun,
        sourceTurn: source.turn,
        sourceEvent: source.event,
        request: request,
      );

      expect(first.duplicate, isFalse);
      expect(retry.duplicate, isTrue);
      expect(retry.eventId, first.eventId);
      expect(first.messageSequence, 2);

      final stored = await deliveries.getForEvent(first.eventId);
      expect(stored, isNotNull);
      expect(stored!.visibility, AgentDeliveryVisibility.project);
      expect(stored.targetAgentIds, const <String>['agent-2']);
      expect(stored.sourceRunId, sourceRun.id);
      expect(stored.depth, 1);

      final deliveryRun = (await runs.getRun(first.deliveryRunId))!;
      expect(deliveryRun.phase, AgentRunPhase.delivery);
      expect(deliveryRun.status, AgentRunStatus.completed);
      expect(deliveryRun.parentRunId, sourceRun.id);
      expect(deliveryRun.rootRunId, sourceRun.rootRunId);
      expect(deliveryRun.deliveryDepth, 1);

      final rows = await database.query('agent_deliveries');
      expect(rows, hasLength(1));
      final eventRows = await database.query(
        'project_events',
        where: 'event_type = ?',
        whereArgs: <Object?>['agentDelivery'],
      );
      expect(eventRows, hasLength(1));
      expect(eventRows.single['visibility'], 'project');
    },
  );

  test(
    'enforces depth and active membership at the transaction boundary',
    () async {
      final originalProject = (await projects.getProject('project-1'))!;
      await projects.updateProject(
        originalProject.copyWith(
          responsePolicy: const ProjectResponsePolicy(deliveryMaxDepth: 0),
        ),
      );

      await expectLater(
        deliver(
          project: (await projects.getProject('project-1'))!,
          sourceAgent: sourceAgent,
          sourceRun: sourceRun,
          sourceTurn: source.turn,
          sourceEvent: source.event,
          request: AgentDeliveryRequest(
            targetAgentIds: const <String>['agent-2'],
            kind: AgentDeliveryKind.information,
            summary: 'Too deep',
            payload: 'This must be rejected.',
          ),
        ),
        throwsA(
          isA<AgentDeliveryFailure>().having(
            (failure) => failure.code,
            'code',
            'delivery_depth_limit_reached',
          ),
        ),
      );
      await projects.updateProject(
        (await projects.getProject('project-1'))!.copyWith(
          responsePolicy: const ProjectResponsePolicy(
            deliveryMaxDeliveriesPerTurn: 0,
          ),
        ),
      );
      await expectLater(
        deliver(
          project: (await projects.getProject('project-1'))!,
          sourceAgent: sourceAgent,
          sourceRun: sourceRun,
          sourceTurn: source.turn,
          sourceEvent: source.event,
          request: AgentDeliveryRequest(
            targetAgentIds: const <String>['agent-2'],
            kind: AgentDeliveryKind.information,
            summary: 'Too many',
            payload: 'The per-root delivery count is already exhausted.',
          ),
        ),
        throwsA(
          isA<AgentDeliveryFailure>().having(
            (failure) => failure.code,
            'code',
            'delivery_count_limit_reached',
          ),
        ),
      );

      await projects.updateProject(
        (await projects.getProject(
          'project-1',
        ))!.copyWith(responsePolicy: ProjectResponsePolicy.defaults),
      );
      await memberships.remove('project-1', 'agent-2', DateTime(2026, 8, 22));
      await expectLater(
        deliver(
          project: (await projects.getProject('project-1'))!,
          sourceAgent: sourceAgent,
          sourceRun: sourceRun,
          sourceTurn: source.turn,
          sourceEvent: source.event,
          request: AgentDeliveryRequest(
            targetAgentIds: const <String>['agent-2'],
            kind: AgentDeliveryKind.question,
            summary: 'Are you active?',
            payload: 'Answer only if membership is still active.',
            visibility: AgentDeliveryVisibility.targets,
          ),
        ),
        throwsA(
          isA<AgentDeliveryFailure>().having(
            (failure) => failure.code,
            'code',
            'delivery_target_not_active',
          ),
        ),
      );
      expect(await database.query('agent_deliveries'), isEmpty);
      final notices = await database.query(
        'project_events',
        where: 'event_type = ?',
        whereArgs: <Object?>['systemNotice'],
        orderBy: 'sequence ASC',
      );
      expect(notices, hasLength(3));
      expect(notices.first['terminal_state'], 'limitExceeded');
      expect(notices[1]['terminal_state'], 'limitExceeded');
      expect(notices.last['terminal_state'], 'failed');
      final deliveryRuns = await database.query('agent_runs');
      expect(
        deliveryRuns.map((row) => row['status']),
        contains('limitExceeded'),
      );
      expect(deliveryRuns.map((row) => row['status']), contains('failed'));
    },
  );
}

Agent _agent(String id) => Agent(
  id: id,
  name: 'Agent ${id.split('-').last}',
  avatar: '',
  provider: 'test',
  baseUrl: '',
  apiKey: 'secret',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: 'Collaborate.',
  createdAt: DateTime(2026, 8, 22),
  updatedAt: DateTime(2026, 8, 22),
);

Project _project() => Project(
  id: 'project-1',
  name: 'Project',
  lastMessageAt: DateTime(2026, 8, 22),
  createdAt: DateTime(2026, 8, 22),
  updatedAt: DateTime(2026, 8, 22),
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
  }) async => encrypted.replaceFirst('encrypted:', '');
}
