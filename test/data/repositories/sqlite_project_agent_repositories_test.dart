import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/models/project_agent_records.dart';
import 'package:hyve/data/repositories/sqlite_agent_repository.dart';
import 'package:hyve/data/repositories/sqlite_agent_run_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_event_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_membership_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_turn_repository.dart';
import 'package:hyve/data/services/bot_api_key_cipher.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late Directory support;
  late LocalDatabaseService localDatabase;
  late ProjectAgentStorageService storage;
  late SqliteAgentRepository agentRepository;
  late SqliteProjectRepository projectRepository;
  late SqliteProjectMembershipRepository membershipRepository;
  late SqliteProjectEventRepository eventRepository;
  late SqliteProjectTurnRepository turnRepository;
  late SqliteAgentRunRepository runRepository;
  late Future<void> Function() createMembershipGraph;

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
    support = await Directory.systemTemp.createTemp('hyve_phase_one_repo_');
    localDatabase = LocalDatabaseService(
      databaseProvider: () async => database,
    );
    storage = ProjectAgentStorageService(
      supportDirectoryProvider: () async => support,
    );
    agentRepository = SqliteAgentRepository(
      localDatabase: localDatabase,
      apiKeyCipher: const _TestApiKeyCipher(),
      storage: storage,
    );
    projectRepository = SqliteProjectRepository(
      localDatabase: localDatabase,
      storage: storage,
    );
    membershipRepository = SqliteProjectMembershipRepository(
      localDatabase: localDatabase,
    );
    eventRepository = SqliteProjectEventRepository(
      localDatabase: localDatabase,
    );
    turnRepository = SqliteProjectTurnRepository(localDatabase: localDatabase);
    runRepository = SqliteAgentRunRepository(localDatabase: localDatabase);
    createMembershipGraph = () async {
      final now = DateTime(2026, 8, 20);
      await agentRepository.addAgent(_agent('agent-1'));
      await projectRepository
          .addProjectWithMemberships(_project('project-1'), <ProjectMembership>[
            ProjectMembership(
              projectId: 'project-1',
              agentId: 'agent-1',
              position: 0,
              joinedAt: now,
              updatedAt: now,
            ),
          ]);
    };
  });

  tearDown(() async {
    await agentRepository.dispose();
    await projectRepository.dispose();
    await membershipRepository.dispose();
    await eventRepository.dispose();
    await database.close();
    await support.delete(recursive: true);
  });

  test(
    'round-trips strict Agent policy and creates its private file root',
    () async {
      final agent = _agent('agent-1');

      await agentRepository.addAgent(agent);
      final restored = await agentRepository.getAgent(agent.id);

      expect(restored?.apiKey, agent.apiKey);
      expect(restored?.memoryPolicy.retrieval.maxItems, 12);
      expect(restored?.memoryPolicy.retrieval.tokenBudget, 2048);
      expect(restored?.memoryPolicy.retrieval.minConfidence, 0.65);
      expect(
        Directory(
          path.join(support.path, 'agents', agent.id, 'memory', 'items'),
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory(
          path.join(support.path, 'agents', agent.id, 'memory', 'index'),
        ).existsSync(),
        isTrue,
      );
      expect(await database.query('agents', columns: const ['api_key']), [
        <String, Object?>{'api_key': 'encrypted:secret'},
      ]);
    },
  );

  test(
    'creates Project and memberships atomically with default read access',
    () async {
      final now = DateTime(2026, 8, 20);
      await agentRepository.addAgent(_agent('agent-1'));
      await agentRepository.addAgent(_agent('agent-2'));
      final project = _project('project-1');

      await projectRepository
          .addProjectWithMemberships(project, <ProjectMembership>[
            ProjectMembership(
              projectId: project.id,
              agentId: 'agent-1',
              position: 0,
              joinedAt: now,
              updatedAt: now,
            ),
            ProjectMembership(
              projectId: project.id,
              agentId: 'agent-2',
              position: 1,
              joinedAt: now,
              updatedAt: now,
            ),
          ]);

      final memberships = await membershipRepository.getForProject(project.id);
      expect(memberships.map((item) => item.agentId), ['agent-1', 'agent-2']);
      expect(
        memberships.map((item) => item.projectStorageAccess),
        everyElement(ProjectStorageAccess.read),
      );
      expect(
        Directory(
          path.join(support.path, 'projects', project.id, 'artifacts', 'blobs'),
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory(
          path.join(
            support.path,
            'projects',
            project.id,
            'context',
            'summaries',
          ),
        ).existsSync(),
        isTrue,
      );
    },
  );

  test(
    'rolls back a newly created Project root when membership insert fails',
    () async {
      final project = _project('project-with-missing-agent');
      final now = DateTime(2026, 8, 20);

      await expectLater(
        projectRepository
            .addProjectWithMemberships(project, <ProjectMembership>[
              ProjectMembership(
                projectId: project.id,
                agentId: 'missing-agent',
                position: 0,
                joinedAt: now,
                updatedAt: now,
              ),
            ]),
        throwsA(isA<DatabaseException>()),
      );

      expect(await projectRepository.getProject(project.id), isNull);
      expect((await storage.projectRoot(project.id)).existsSync(), isFalse);
    },
  );

  test(
    'Project deletion removes its root and preserves Agent memory',
    () async {
      await createMembershipGraph();
      final memory = File(
        path.join(
          support.path,
          'agents',
          'agent-1',
          'memory',
          'items',
          'memory.json',
        ),
      );
      await memory.parent.create(recursive: true);
      await memory.writeAsString('outside SQLite');

      await projectRepository.deleteProject('project-1');

      expect(await projectRepository.getProject('project-1'), isNull);
      expect(await agentRepository.getAgent('agent-1'), isNotNull);
      expect(memory.existsSync(), isTrue);
      expect((await storage.projectRoot('project-1')).existsSync(), isFalse);
    },
  );

  test(
    'Agent deletion removes its root and preserves Project and event snapshot',
    () async {
      await createMembershipGraph();
      final now = DateTime(2026, 8, 20);
      await eventRepository.save(
        ProjectEvent(
          id: 'event-1',
          projectId: 'project-1',
          sequence: 1,
          messageSequence: 1,
          eventType: ProjectEventType.agentMessage,
          actorType: ProjectEventActorType.agent,
          actorId: 'agent-1',
          actorNameSnapshot: 'Researcher',
          content: 'persisted history',
          payload: ProjectMessagePayload(reasoning: 'reason'),
          targetAgentIds: const ['agent-1'],
          createdAt: now,
          updatedAt: now,
        ),
      );

      await agentRepository.deleteAgent('agent-1');

      expect(await agentRepository.getAgent('agent-1'), isNull);
      expect(await projectRepository.getProject('project-1'), isNotNull);
      expect(await membershipRepository.getForProject('project-1'), isEmpty);
      expect((await storage.agentRoot('agent-1')).existsSync(), isFalse);
      final event = await eventRepository.getEvent('event-1');
      expect(event?.actorNameSnapshot, 'Researcher');
      expect(event?.targetAgentIds, ['agent-1']);
    },
  );

  test('round-trips typed Event, Turn, and Run records', () async {
    await createMembershipGraph();
    final now = DateTime(2026, 8, 20);
    final event = ProjectEvent(
      id: 'event-1',
      projectId: 'project-1',
      turnId: 'turn-1',
      runId: 'run-1',
      sequence: 1,
      messageSequence: 1,
      eventType: ProjectEventType.agentDelivery,
      actorType: ProjectEventActorType.agent,
      actorId: 'agent-1',
      actorNameSnapshot: 'Researcher',
      visibility: ProjectEventVisibility.targets,
      content: 'delivery',
      payload: AgentDeliveryPayload(
        kind: AgentDeliveryKind.information,
        summary: 'summary',
        payload: 'payload',
        requestPublicReply: true,
      ),
      targetAgentIds: const ['agent-1'],
      createdAt: now,
      updatedAt: now,
    );
    final turn = ProjectTurn(
      id: 'turn-1',
      projectId: 'project-1',
      rootEventId: 'event-1',
      initiatorType: ProjectTurnInitiatorType.agent,
      initiatorId: 'agent-1',
      routingMode: ProjectTurnRoutingMode.delivery,
      sourceMessageId: 'event-1',
      sourceMessageSequence: 1,
      recipientCount: 1,
      rootTurnId: 'turn-1',
      createdAt: now,
    );
    final run = AgentRun(
      id: 'run-1',
      projectId: 'project-1',
      turnId: 'turn-1',
      agentId: 'agent-1',
      sourceMessageEventId: 'event-1',
      sourceMessageSequence: 1,
      contextThroughMessageSequence: 1,
      rootRunId: 'run-1',
      phase: AgentRunPhase.delivery,
      status: AgentRunStatus.running,
      agentSnapshot: const AgentRunSnapshot(
        agentName: 'Researcher',
        provider: 'Provider',
        model: 'model',
        systemPromptDigest: 'prompt-digest',
        capabilityDigest: 'capability-digest',
      ),
      createdAt: now,
    );

    await turnRepository.save(turn);
    await runRepository.save(run);
    await eventRepository.save(event);

    final restoredEvent = await eventRepository.getEvent(event.id);
    expect(restoredEvent?.payload, isA<AgentDeliveryPayload>());
    expect(restoredEvent?.targetAgentIds, ['agent-1']);
    expect(
      (await turnRepository.getTurn(turn.id))?.routingMode,
      ProjectTurnRoutingMode.delivery,
    );
    expect(
      (await runRepository.getRun(run.id))?.agentSnapshot.agentName,
      'Researcher',
    );
    expect(await runRepository.getActiveForProject('project-1'), hasLength(1));
  });

  test('strict JSON records reject missing or extra policy fields', () {
    final agentValues = Map<String, Object?>.from(
      AgentRecord.fromDomain(_agent('agent-1'), storedApiKey: '').values,
    )..['memory_policy_json'] = '{"schemaVersion":1,"unexpected":true}';
    final projectValues = Map<String, Object?>.from(
        ProjectRecord.fromDomain(_project('project-1')).values,
      )
      ..['response_policy_json'] =
          '{"schemaVersion":1,"broadcastDecision":{},'
          '"replyConcurrency":2,"autonomousChain":{},"delivery":{}}';

    expect(
      () => AgentRecord(agentValues).toDomain(apiKey: ''),
      throwsFormatException,
    );
    expect(
      () => ProjectRecord(projectValues).toDomain(),
      throwsFormatException,
    );
  });

  test('staged directory deletion can be rolled back', () async {
    await storage.ensureProjectRoot('project-rollback');
    final marker = File(
      path.join(
        support.path,
        'projects',
        'project-rollback',
        'audit',
        'marker',
      ),
    );
    await marker.writeAsString('keep');

    final staged = await storage.stageProjectDeletion('project-rollback');
    expect(marker.existsSync(), isFalse);
    await staged?.rollback();

    expect(marker.existsSync(), isTrue);
    expect(
      Directory(path.join(support.path, '.pending_deletions')).existsSync(),
      isFalse,
    );
  });
}

Agent _agent(String id) {
  final timestamp = DateTime(2026, 8, 20);
  return Agent(
    id: id,
    name: 'Researcher',
    avatar: '',
    provider: 'Provider',
    baseUrl: 'https://example.test',
    apiKey: 'secret',
    apiType: 'openai',
    model: 'model',
    systemPrompt: 'Research carefully.',
    parameters: const <String, Object?>{'temperature': 0.2},
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

Project _project(String id) {
  final timestamp = DateTime(2026, 8, 20);
  return Project(
    id: id,
    name: 'Launch',
    lastMessageAt: timestamp,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

final class _TestApiKeyCipher implements BotApiKeyCipher {
  const _TestApiKeyCipher();

  @override
  bool isEncrypted(String value) => value.startsWith('encrypted:');

  @override
  Future<String> encrypt({
    required String botId,
    required String apiKey,
  }) async {
    return apiKey.isEmpty ? '' : 'encrypted:$apiKey';
  }

  @override
  Future<String> decrypt({
    required String botId,
    required String encrypted,
  }) async {
    return encrypted.substring('encrypted:'.length);
  }
}
