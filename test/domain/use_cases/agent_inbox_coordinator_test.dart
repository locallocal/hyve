import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/repositories/sqlite_agent_message_receipt_repository.dart';
import 'package:hyve/data/repositories/sqlite_agent_delivery_repository.dart';
import 'package:hyve/data/repositories/sqlite_agent_repository.dart';
import 'package:hyve/data/repositories/sqlite_agent_run_repository.dart';
import 'package:hyve/data/repositories/sqlite_model_usage_repository.dart';
import 'package:hyve/data/repositories/sqlite_participation_decision_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_agent_cursor_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_event_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_membership_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_message_route_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_turn_repository.dart';
import 'package:hyve/data/services/bot_api_key_cipher.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/project_agent_execution_gateway.dart';
import 'package:hyve/domain/use_cases/agent_inbox_coordinator.dart';
import 'package:hyve/domain/use_cases/deliver_to_project_agent.dart';
import 'package:hyve/domain/use_cases/execute_project_agent_reply.dart';
import 'package:hyve/domain/use_cases/project_turn_coordinator.dart';
import 'package:hyve/domain/use_cases/route_project_message.dart';
import 'package:hyve/domain/use_cases/run_broadcast_participation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late Directory support;
  late SqliteAgentRepository agents;
  late SqliteProjectRepository projects;
  late SqliteProjectMembershipRepository memberships;
  late SqliteProjectEventRepository events;
  late SqliteProjectTurnRepository turns;
  late SqliteAgentRunRepository runs;
  late SqliteProjectAgentCursorRepository cursors;
  late SqliteAgentMessageReceiptRepository receipts;
  late SqliteParticipationDecisionRepository decisions;
  late SqliteAgentDeliveryRepository deliveries;
  late _ExecutionGateway gateway;
  late RouteProjectMessage route;
  late AgentInboxCoordinator inbox;
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
    support = await Directory.systemTemp.createTemp('hyve_phase_two_inbox_');
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
    events = SqliteProjectEventRepository(localDatabase: localDatabase);
    turns = SqliteProjectTurnRepository(localDatabase: localDatabase);
    runs = SqliteAgentRunRepository(localDatabase: localDatabase);
    cursors = SqliteProjectAgentCursorRepository(localDatabase: localDatabase);
    receipts = SqliteAgentMessageReceiptRepository(
      localDatabase: localDatabase,
    );
    decisions = SqliteParticipationDecisionRepository(
      localDatabase: localDatabase,
    );
    deliveries = SqliteAgentDeliveryRepository(
      localDatabase: localDatabase,
      projectRepository: projects,
    );
    final modelUsage = SqliteModelUsageRepository(localDatabase: localDatabase);
    gateway = _ExecutionGateway();
    final routeRepository = SqliteProjectMessageRouteRepository(
      localDatabase: localDatabase,
      projectRepository: projects,
    );
    late final AgentInboxCoordinator coordinator;
    route = RouteProjectMessage(
      repository: routeRepository,
      clock: DateTime.now,
      idFactory: (prefix) => '$prefix-${idSequence++}',
      wakeup:
          (projectId, agentIds) =>
              coordinator.wakeProject(projectId, agentIds).ignore(),
    );
    final deliverToProjectAgent = DeliverToProjectAgent(
      repository: deliveries,
      wakeup:
          (projectId, agentIds) =>
              coordinator.wakeProject(projectId, agentIds).ignore(),
    );
    final turnCoordinator = ProjectTurnCoordinator(
      turnRepository: turns,
      eventRepository: events,
      receiptRepository: receipts,
      runRepository: runs,
    );
    coordinator = AgentInboxCoordinator(
      cursorRepository: cursors,
      projectRepository: projects,
      membershipRepository: memberships,
      eventRepository: events,
      turnRepository: turns,
      runRepository: runs,
      decisionRepository: decisions,
      agentRepository: agents,
      runBroadcastParticipation: RunBroadcastParticipation(
        runRepository: runs,
        decisionRepository: decisions,
        gateway: gateway,
        modelUsageRepository: modelUsage,
      ),
      executeReply: ExecuteProjectAgentReply(
        runRepository: runs,
        gateway: gateway,
        routeProjectMessage: route,
        deliverToProjectAgent: deliverToProjectAgent,
        modelUsageRepository: modelUsage,
      ),
      turnCoordinator: turnCoordinator,
    );
    inbox = coordinator;

    await agents.addAgent(_agent('agent-1'));
    await agents.addAgent(_agent('agent-2'));
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
    await inbox.dispose();
    await deliveries.dispose();
    await agents.dispose();
    await projects.dispose();
    await memberships.dispose();
    await events.dispose();
    await cursors.dispose();
    await database.close();
    await support.delete(recursive: true);
  });

  test(
    'targeted routing runs only target and every cursor catches up',
    () async {
      gateway.decision = (_, _) => ParticipationChoice.pass;
      final routed = await route(
        projectId: 'project-1',
        draft: ProjectMessageDraft(
          text: '@Agent 1 answer',
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
      await inbox.wakeProject('project-1');
      await inbox.waitForIdle(projectId: 'project-1');

      final sourceRuns = await runs.getForTurn(routed.turn.id);
      expect(sourceRuns, hasLength(1));
      expect(sourceRuns.single.agentId, 'agent-1');
      expect(sourceRuns.single.phase, AgentRunPhase.reply);
      expect(
        (await receipts.getReceipt('project-1', 'agent-2', 1))?.outcome,
        AgentMessageReceiptOutcome.notTargeted,
      );
      expect(
        (await receipts.getReceipt('project-1', 'agent-1', 1))?.outcome,
        AgentMessageReceiptOutcome.replied,
      );
      expect(
        (await cursors.getCursor(
          'project-1',
          'agent-1',
        ))?.lastProcessedMessageSequence,
        2,
      );
      expect(
        (await cursors.getCursor(
          'project-1',
          'agent-2',
        ))?.lastProcessedMessageSequence,
        2,
      );
      expect(
        gateway.replyRequests.single.visibleHistory.every(
          (event) =>
              event.messageSequence! <=
              gateway.replyRequests.single.contextThroughMessageSequence,
        ),
        isTrue,
      );
      final usage = await database.query(
        'token_usage_records',
        where: 'operation_kind = ?',
        whereArgs: <Object?>['chat_reply'],
      );
      expect(usage, isNotEmpty);
      expect(
        usage.every((row) => (row['run_id'] as String).isNotEmpty),
        isTrue,
      );
    },
  );

  test(
    'decision failure becomes one persisted pass and all-pass completes',
    () async {
      gateway.failDecisionAgentId = 'agent-2';
      gateway.decision = (_, _) => ParticipationChoice.pass;
      final routed = await route(
        projectId: 'project-1',
        draft: ProjectMessageDraft(text: 'broadcast question'),
      );
      await inbox.wakeProject('project-1');
      await inbox.waitForIdle(projectId: 'project-1');

      final persisted = await decisions.getForTurn(routed.turn.id);
      expect(persisted, hasLength(2));
      final auditEvents = (await events.getEvents('project-1')).where(
        (event) => event.eventType == ProjectEventType.participationDecision,
      );
      expect(auditEvents, hasLength(2));
      expect(
        auditEvents.every((event) => event.messageSequence == null),
        isTrue,
      );
      expect(
        persisted.singleWhere((item) => item.agentId == 'agent-2').reasonCode,
        'decision_failed',
      );
      expect(gateway.decisionCallsFor(routed.event.id, 'agent-1'), 1);
      expect(gateway.decisionCallsFor(routed.event.id, 'agent-2'), 1);
      final decisionUsage = await database.query(
        'token_usage_records',
        where: 'operation_kind = ?',
        whereArgs: <Object?>['participation_decision'],
      );
      expect(decisionUsage, hasLength(1));
      expect(decisionUsage.single['agent_id'], 'agent-1');
      final completed = await turns.getTurn(routed.turn.id);
      expect(completed?.status, ProjectTurnStatus.completed);
      expect(completed?.noParticipant, isTrue);
      expect(
        (await receipts.getReceipt('project-1', 'agent-2', 1))?.outcome,
        AgentMessageReceiptOutcome.passed,
      );
    },
  );

  test('decision budget preserves the current message and hard caps', () async {
    final original = (await agents.getAgent('agent-1'))!;
    await agents.updateAgent(
      original.copyWith(systemPrompt: List.filled(12000, 'identity').join(' ')),
    );
    final routed = await route(
      projectId: 'project-1',
      draft: ProjectMessageDraft(
        text: 'CURRENT_MESSAGE ${List.filled(12000, 'context').join(' ')}',
      ),
    );
    await inbox.wakeProject('project-1');
    await inbox.waitForIdle(projectId: 'project-1');

    final request = gateway.decisionRequests.singleWhere(
      (item) => item.agent.id == 'agent-1',
    );
    expect(request.maxInputTokens, 4096);
    expect(request.maxOutputTokens, 128);
    expect(request.estimatedInputTokens, lessThanOrEqualTo(4096));
    expect(request.decisionSystemPrompt, contains('Agent 1'));
    expect(request.visibleHistory.last.id, routed.event.id);
    expect(request.visibleHistory.last.content, startsWith('CURRENT_MESSAGE'));
  });

  test(
    'paused Agent resumes from its cursor without joining old broadcast',
    () async {
      final member = (await memberships.getMembership('project-1', 'agent-2'))!;
      await memberships.save(
        member.copyWith(
          status: ProjectMembershipStatus.paused,
          updatedAt: DateTime.now(),
        ),
      );
      final routed = await route(
        projectId: 'project-1',
        draft: ProjectMessageDraft(text: 'broadcast while paused'),
      );
      await inbox.waitForIdle(projectId: 'project-1');

      await memberships.save(
        member.copyWith(
          status: ProjectMembershipStatus.active,
          updatedAt: DateTime.now(),
        ),
      );
      await inbox.wakeProject('project-1');
      await inbox.waitForIdle(projectId: 'project-1');

      expect(routed.event.targetAgentIds, <String>['agent-1']);
      expect(gateway.decisionCallsFor(routed.event.id, 'agent-2'), 0);
      expect(
        (await receipts.getReceipt('project-1', 'agent-2', 1))?.outcome,
        AgentMessageReceiptOutcome.notTargeted,
      );
      expect(
        (await cursors.getCursor(
          'project-1',
          'agent-2',
        ))?.lastProcessedMessageSequence,
        1,
      );
    },
  );

  test(
    'autonomous depth limit advances cursor without another decision',
    () async {
      final project = (await projects.getProject('project-1'))!;
      await projects.updateProject(
        project.copyWith(
          responsePolicy: const ProjectResponsePolicy(
            autonomousChainMaxDepth: 1,
          ),
        ),
      );
      final routed = await route(
        projectId: 'project-1',
        draft: ProjectMessageDraft(
          text: '@Agent 1 start',
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
      await inbox.wakeProject('project-1');
      await inbox.waitForIdle(projectId: 'project-1');

      final reply = (await events.getEvents(
        'project-1',
      )).singleWhere((event) => event.replyToEventId == routed.event.id);
      expect(reply.autonomousDepth, 1);
      expect(gateway.decisionCallsFor(reply.id, 'agent-2'), 0);
      expect(
        (await receipts.getReceipt(
          'project-1',
          'agent-2',
          reply.messageSequence!,
        ))?.outcome,
        AgentMessageReceiptOutcome.chainLimitReached,
      );
    },
  );

  test(
    'same Agent is serial while different Agents reply in parallel',
    () async {
      gateway.replyDelay = const Duration(milliseconds: 80);
      final first = route(
        projectId: 'project-1',
        draft: ProjectMessageDraft(
          text: '@Agent 1 first',
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
      final second = route(
        projectId: 'project-1',
        draft: ProjectMessageDraft(
          text: '@Agent 2 second',
          mentions: const <MentionSpan>[
            MentionSpan(
              agentId: 'agent-2',
              start: 0,
              length: 8,
              displayTextSnapshot: '@Agent 2',
            ),
          ],
        ),
      );
      await Future.wait(<Future<RoutedProjectMessage>>[first, second]);
      await inbox.wakeProject('project-1');
      await inbox.waitForIdle(projectId: 'project-1');

      expect(gateway.maxReplyConcurrencyByAgent['agent-1'], 1);
      expect(gateway.maxReplyConcurrencyByAgent['agent-2'], 1);
      expect(gateway.maxGlobalReplyConcurrency, 2);
      final latest =
          (await projects.getProject('project-1'))!.lastMessageSequence;
      expect(
        (await cursors.getCursor(
          'project-1',
          'agent-1',
        ))?.lastProcessedMessageSequence,
        latest,
      );
      expect(
        (await cursors.getCursor(
          'project-1',
          'agent-2',
        ))?.lastProcessedMessageSequence,
        latest,
      );
    },
  );

  test('cancelling one Turn reaches terminal receipt and run states', () async {
    gateway.replyDelay = const Duration(milliseconds: 100);
    final routed = await route(
      projectId: 'project-1',
      draft: ProjectMessageDraft(
        text: '@Agent 1 stop',
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
    await inbox.wakeProject('project-1');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(await inbox.cancelTurn(routed.turn.id), 1);
    await inbox.waitForIdle(projectId: 'project-1');

    final turnRuns = await runs.getForTurn(routed.turn.id);
    expect(turnRuns.single.status, AgentRunStatus.cancelled);
    expect(
      (await receipts.getReceipt('project-1', 'agent-1', 1))?.outcome,
      AgentMessageReceiptOutcome.cancelled,
    );
    expect(
      (await turns.getTurn(routed.turn.id))?.status,
      ProjectTurnStatus.cancelled,
    );
  });

  test('cancelling a Turn also stops recipients waiting for a slot', () async {
    await agents.addAgent(_agent('agent-3'));
    final now = DateTime.now();
    await memberships.save(
      ProjectMembership(
        projectId: 'project-1',
        agentId: 'agent-3',
        position: 2,
        joinedAt: now,
        updatedAt: now,
      ),
    );
    gateway.replyDelay = const Duration(milliseconds: 100);
    final routed = await route(
      projectId: 'project-1',
      draft: ProjectMessageDraft(
        text: '@Agent 1 @Agent 2 @Agent 2',
        mentions: const <MentionSpan>[
          MentionSpan(
            agentId: 'agent-1',
            start: 0,
            length: 8,
            displayTextSnapshot: '@Agent 1',
          ),
          MentionSpan(
            agentId: 'agent-2',
            start: 9,
            length: 8,
            displayTextSnapshot: '@Agent 2',
          ),
          MentionSpan(
            agentId: 'agent-3',
            start: 18,
            length: 8,
            displayTextSnapshot: '@Agent 2',
          ),
        ],
      ),
    );
    await inbox.wakeProject('project-1');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await inbox.cancelTurn(routed.turn.id);
    await inbox.waitForIdle(projectId: 'project-1');

    expect(
      (await turns.getTurn(routed.turn.id))?.status,
      ProjectTurnStatus.cancelled,
    );
    for (final agentId in <String>['agent-1', 'agent-2', 'agent-3']) {
      expect(
        (await receipts.getReceipt('project-1', agentId, 1))?.outcome,
        AgentMessageReceiptOutcome.cancelled,
      );
    }
    expect(
      (await runs.getForTurn(routed.turn.id)).every((run) => run.isTerminal),
      isTrue,
    );
  });

  test('one target failure does not cancel another target reply', () async {
    gateway.failReplyAgentId = 'agent-2';
    final routed = await route(
      projectId: 'project-1',
      draft: ProjectMessageDraft(
        text: '@Agent 1 @Agent 2 answer',
        mentions: const <MentionSpan>[
          MentionSpan(
            agentId: 'agent-1',
            start: 0,
            length: 8,
            displayTextSnapshot: '@Agent 1',
          ),
          MentionSpan(
            agentId: 'agent-2',
            start: 9,
            length: 8,
            displayTextSnapshot: '@Agent 2',
          ),
        ],
      ),
    );
    await inbox.wakeProject('project-1');
    await inbox.waitForIdle(projectId: 'project-1');

    expect(
      (await receipts.getReceipt('project-1', 'agent-1', 1))?.outcome,
      AgentMessageReceiptOutcome.replied,
    );
    expect(
      (await receipts.getReceipt('project-1', 'agent-2', 1))?.outcome,
      AgentMessageReceiptOutcome.failedSkipped,
    );
    expect(
      (await turns.getTurn(routed.turn.id))?.status,
      ProjectTurnStatus.partial,
    );
  });

  test(
    'targets delivery is invisible to observers and chains target reply',
    () async {
      await agents.addAgent(_agent('agent-3'));
      final now = DateTime.now();
      await memberships.save(
        ProjectMembership(
          projectId: 'project-1',
          agentId: 'agent-3',
          position: 2,
          joinedAt: now,
          updatedAt: now,
        ),
      );
      gateway.nextDelivery = AgentDeliveryRequest(
        targetAgentIds: const <String>['agent-2'],
        kind: AgentDeliveryKind.task,
        summary: 'Review privately',
        payload: 'Inspect the source response.',
        visibility: AgentDeliveryVisibility.targets,
        requestPublicReply: true,
      );

      final source = await route(
        projectId: 'project-1',
        draft: ProjectMessageDraft(
          text: '@Agent 1 delegate',
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
      await inbox.wakeProject('project-1');
      await inbox.waitForIdle(projectId: 'project-1');

      final deliveryEvent = (await events.getEvents('project-1')).singleWhere(
        (event) => event.eventType == ProjectEventType.agentDelivery,
      );
      expect(deliveryEvent.visibility, ProjectEventVisibility.targets);
      expect(
        (await receipts.getReceipt(
          'project-1',
          'agent-3',
          deliveryEvent.messageSequence!,
        ))?.outcome,
        AgentMessageReceiptOutcome.invisible,
      );
      expect(
        (await receipts.getReceipt(
          'project-1',
          'agent-2',
          deliveryEvent.messageSequence!,
        ))?.outcome,
        AgentMessageReceiptOutcome.replied,
      );

      final sourceReplyRun = (await runs.getForTurn(
        source.turn.id,
      )).singleWhere(
        (run) => run.phase == AgentRunPhase.reply && run.agentId == 'agent-1',
      );
      final deliveryRun = (await runs.getRun(deliveryEvent.runId))!;
      final targetReplyRun = (await runs.getForTurn(
        deliveryEvent.turnId,
      )).singleWhere(
        (run) => run.phase == AgentRunPhase.reply && run.agentId == 'agent-2',
      );
      expect(deliveryRun.parentRunId, sourceReplyRun.id);
      expect(targetReplyRun.parentRunId, deliveryRun.id);
      expect(targetReplyRun.rootRunId, sourceReplyRun.rootRunId);
      expect(targetReplyRun.deliveryDepth, 1);
    },
  );

  test(
    'project delivery is observed by non-targets and target may pass',
    () async {
      await agents.addAgent(_agent('agent-3'));
      final now = DateTime.now();
      await memberships.save(
        ProjectMembership(
          projectId: 'project-1',
          agentId: 'agent-3',
          position: 2,
          joinedAt: now,
          updatedAt: now,
        ),
      );
      gateway.nextDelivery = AgentDeliveryRequest(
        targetAgentIds: const <String>['agent-2'],
        kind: AgentDeliveryKind.information,
        summary: 'Context only',
        payload: 'No public response is required.',
      );

      await route(
        projectId: 'project-1',
        draft: ProjectMessageDraft(
          text: '@Agent 1 share context',
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
      await inbox.wakeProject('project-1');
      await inbox.waitForIdle(projectId: 'project-1');

      final deliveryEvent = (await events.getEvents('project-1')).singleWhere(
        (event) => event.eventType == ProjectEventType.agentDelivery,
      );
      expect(deliveryEvent.visibility, ProjectEventVisibility.project);
      expect(
        (await receipts.getReceipt(
          'project-1',
          'agent-3',
          deliveryEvent.messageSequence!,
        ))?.outcome,
        AgentMessageReceiptOutcome.observed,
      );
      expect(
        (await receipts.getReceipt(
          'project-1',
          'agent-2',
          deliveryEvent.messageSequence!,
        ))?.outcome,
        AgentMessageReceiptOutcome.passed,
      );
      final targetRuns = await runs.getForTurn(deliveryEvent.turnId);
      expect(
        targetRuns.singleWhere((run) => run.agentId == 'agent-2').phase,
        AgentRunPhase.decision,
      );
      expect(
        targetRuns.singleWhere((run) => run.agentId == 'agent-2').parentRunId,
        deliveryEvent.runId,
      );
    },
  );

  test('cancelling a root Turn cancels delivery descendants', () async {
    gateway.nextDelivery = AgentDeliveryRequest(
      targetAgentIds: const <String>['agent-2'],
      kind: AgentDeliveryKind.task,
      summary: 'Long review',
      payload: 'This review should be cancelled with the root Turn.',
      requestPublicReply: true,
    );
    gateway.replyDelay = const Duration(milliseconds: 300);
    final source = await route(
      projectId: 'project-1',
      draft: ProjectMessageDraft(
        text: '@Agent 1 start cancellable delivery',
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
    await inbox.wakeProject('project-1');

    ProjectEvent? deliveryEvent;
    for (var attempt = 0; attempt < 20 && deliveryEvent == null; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      for (final event in await events.getEvents('project-1')) {
        if (event.eventType == ProjectEventType.agentDelivery) {
          deliveryEvent = event;
          break;
        }
      }
    }
    expect(deliveryEvent, isNotNull);

    await inbox.cancelTurn(source.turn.id);
    await inbox.waitForIdle(projectId: 'project-1');

    expect(
      (await turns.getTurn(source.turn.id))?.status,
      ProjectTurnStatus.cancelled,
    );
    expect(
      (await turns.getTurn(deliveryEvent!.turnId))?.status,
      ProjectTurnStatus.cancelled,
    );
    expect(
      (await receipts.getReceipt(
        'project-1',
        'agent-2',
        deliveryEvent.messageSequence!,
      ))?.outcome,
      AgentMessageReceiptOutcome.cancelled,
    );
    expect(
      (await runs.getForTurn(
        deliveryEvent.turnId,
      )).every((run) => run.isTerminal),
      isTrue,
    );
  });

  test('a target reply timeout terminates its delivery Turn', () async {
    gateway.timeoutReplyAgentId = 'agent-2';
    gateway.nextDelivery = AgentDeliveryRequest(
      targetAgentIds: const <String>['agent-2'],
      kind: AgentDeliveryKind.question,
      summary: 'Timed question',
      payload: 'This target will time out.',
      requestPublicReply: true,
    );
    await route(
      projectId: 'project-1',
      draft: ProjectMessageDraft(
        text: '@Agent 1 ask reviewer',
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
    await inbox.wakeProject('project-1');
    await inbox.waitForIdle(projectId: 'project-1');

    final deliveryEvent = (await events.getEvents('project-1')).singleWhere(
      (event) => event.eventType == ProjectEventType.agentDelivery,
    );
    final targetRun = (await runs.getForTurn(deliveryEvent.turnId)).singleWhere(
      (run) => run.agentId == 'agent-2' && run.phase == AgentRunPhase.reply,
    );
    expect(targetRun.status, AgentRunStatus.timedOut);
    expect(
      (await receipts.getReceipt(
        'project-1',
        'agent-2',
        deliveryEvent.messageSequence!,
      ))?.outcome,
      AgentMessageReceiptOutcome.failedSkipped,
    );
    expect(
      (await turns.getTurn(deliveryEvent.turnId))?.status,
      ProjectTurnStatus.failed,
    );
  });

  test('last target failure remains visible on an idle cursor', () async {
    gateway.timeoutReplyAgentId = 'agent-2';
    final routed = await route(
      projectId: 'project-1',
      draft: ProjectMessageDraft(
        text: '@Agent 2 time out',
        mentions: const <MentionSpan>[
          MentionSpan(
            agentId: 'agent-2',
            start: 0,
            length: 8,
            displayTextSnapshot: '@Agent 2',
          ),
        ],
      ),
    );
    await inbox.wakeProject('project-1');
    await inbox.waitForIdle(projectId: 'project-1');

    final failedCursor = await cursors.getCursor('project-1', 'agent-2');
    expect(failedCursor?.workerState, AgentInboxWorkerState.idle);
    expect(failedCursor?.lastError, 'simulated_reply_timeout');
    expect(
      (await receipts.getReceipt('project-1', 'agent-2', 1))?.outcome,
      AgentMessageReceiptOutcome.failedSkipped,
    );
    expect(
      (await turns.getTurn(routed.turn.id))?.status,
      ProjectTurnStatus.failed,
    );
  });
}

final class _ExecutionGateway implements ProjectAgentExecutionGateway {
  ParticipationChoice Function(String agentId, ProjectEvent event) decision =
      (_, _) => ParticipationChoice.pass;
  String failDecisionAgentId = '';
  String failReplyAgentId = '';
  String timeoutReplyAgentId = '';
  Duration replyDelay = Duration.zero;
  AgentDeliveryRequest? nextDelivery;
  final List<BroadcastParticipationRequest> decisionRequests = [];
  final List<ProjectAgentReplyRequest> replyRequests = [];
  final Map<String, int> _activeReplies = {};
  final Map<String, int> maxReplyConcurrencyByAgent = {};
  int _globalActiveReplies = 0;
  int maxGlobalReplyConcurrency = 0;

  int decisionCallsFor(String eventId, String agentId) =>
      decisionRequests
          .where(
            (request) =>
                request.sourceEvent.id == eventId &&
                request.agent.id == agentId,
          )
          .length;

  @override
  Future<BroadcastParticipationResult> decide(
    BroadcastParticipationRequest request,
  ) async {
    decisionRequests.add(request);
    if (request.agent.id == failDecisionAgentId) {
      throw StateError('simulated decision failure');
    }
    final choice = decision(request.agent.id, request.sourceEvent);
    return BroadcastParticipationResult(
      choice: choice,
      reasonCode: choice == ParticipationChoice.reply ? 'useful' : 'no_value',
      intendedContribution: choice == ParticipationChoice.reply ? 'answer' : '',
      tokenUsage: const ModelTokenUsage(
        model: 'decision-model',
        inputTokens: 30,
        outputTokens: 4,
      ),
    );
  }

  @override
  Future<ProjectAgentReplyResult> reply(
    ProjectAgentReplyRequest request,
  ) async {
    replyRequests.add(request);
    final agentId = request.agent.id;
    _activeReplies[agentId] = (_activeReplies[agentId] ?? 0) + 1;
    maxReplyConcurrencyByAgent[agentId] =
        (_activeReplies[agentId]! > (maxReplyConcurrencyByAgent[agentId] ?? 0))
            ? _activeReplies[agentId]!
            : maxReplyConcurrencyByAgent[agentId] ?? 0;
    _globalActiveReplies++;
    if (_globalActiveReplies > maxGlobalReplyConcurrency) {
      maxGlobalReplyConcurrency = _globalActiveReplies;
    }
    try {
      request.cancellationToken.throwIfCancelled();
      final delivery = nextDelivery;
      if (delivery != null && request.deliveryExecutor != null) {
        nextDelivery = null;
        await request.deliveryExecutor!(delivery);
      }
      if (replyDelay > Duration.zero) {
        await Future<void>.delayed(replyDelay);
      }
      if (agentId == failReplyAgentId) {
        return const ProjectAgentReplyResult(
          status: ProjectAgentReplyStatus.failed,
          errorCode: 'simulated_reply_failure',
        );
      }
      if (agentId == timeoutReplyAgentId) {
        return const ProjectAgentReplyResult(
          status: ProjectAgentReplyStatus.timedOut,
          errorCode: 'simulated_reply_timeout',
        );
      }
      return ProjectAgentReplyResult(
        status: ProjectAgentReplyStatus.completed,
        text: 'reply from ${request.agent.name}',
        tokenUsage: const ModelTokenUsage(
          model: 'reply-model',
          inputTokens: 40,
          outputTokens: 8,
        ),
      );
    } finally {
      _activeReplies[agentId] = _activeReplies[agentId]! - 1;
      _globalActiveReplies--;
    }
  }
}

Agent _agent(String id) => Agent(
  id: id,
  name: id == 'agent-1' ? 'Agent 1' : 'Agent 2',
  avatar: '',
  provider: 'test',
  baseUrl: '',
  apiKey: 'secret',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: 'Be useful.',
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
