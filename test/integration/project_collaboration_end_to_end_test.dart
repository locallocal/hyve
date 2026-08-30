import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/repositories/sqlite_agent_delivery_repository.dart';
import 'package:hyve/data/repositories/sqlite_agent_message_receipt_repository.dart';
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
import 'package:hyve/data/services/ai/provider_project_agent_execution_gateway.dart';
import 'package:hyve/data/services/bot_api_key_cipher.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/ai_models.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/ai_provider_repository.dart';
import 'package:hyve/domain/repositories/project_agent_execution_gateway.dart';
import 'package:hyve/domain/use_cases/agent_inbox_coordinator.dart';
import 'package:hyve/domain/use_cases/deliver_to_project_agent.dart';
import 'package:hyve/domain/use_cases/execute_project_agent_reply.dart';
import 'package:hyve/domain/use_cases/project_turn_coordinator.dart';
import 'package:hyve/domain/use_cases/route_project_message.dart';
import 'package:hyve/domain/use_cases/run_broadcast_participation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test(
    'two Projects share Agent capabilities and complete the full flow',
    () async {
      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: DatabaseService.databaseVersion,
          onConfigure: DatabaseService.configure,
          onCreate: DatabaseService.createSchema,
        ),
      );
      final support = await Directory.systemTemp.createTemp('hyve-e2e-');
      final localDatabase = LocalDatabaseService(
        databaseProvider: () async => database,
      );
      final storage = ProjectAgentStorageService(
        supportDirectoryProvider: () async => support,
      );
      final agents = SqliteAgentRepository(
        localDatabase: localDatabase,
        apiKeyCipher: const _Cipher(),
        storage: storage,
      );
      final projects = SqliteProjectRepository(
        localDatabase: localDatabase,
        storage: storage,
      );
      final memberships = SqliteProjectMembershipRepository(
        localDatabase: localDatabase,
      );
      final events = SqliteProjectEventRepository(localDatabase: localDatabase);
      final turns = SqliteProjectTurnRepository(localDatabase: localDatabase);
      final runs = SqliteAgentRunRepository(localDatabase: localDatabase);
      final cursors = SqliteProjectAgentCursorRepository(
        localDatabase: localDatabase,
      );
      final receipts = SqliteAgentMessageReceiptRepository(
        localDatabase: localDatabase,
      );
      final decisions = SqliteParticipationDecisionRepository(
        localDatabase: localDatabase,
      );
      final deliveries = SqliteAgentDeliveryRepository(
        localDatabase: localDatabase,
        projectRepository: projects,
      );
      final usage = SqliteModelUsageRepository(localDatabase: localDatabase);
      final gateway = _Gateway();
      var identity = 0;
      late final AgentInboxCoordinator inbox;
      final route = RouteProjectMessage(
        repository: SqliteProjectMessageRouteRepository(
          localDatabase: localDatabase,
          projectRepository: projects,
        ),
        idFactory: (prefix) => '$prefix-${identity++}',
        wakeup:
            (projectId, agentIds) =>
                inbox.wakeProject(projectId, agentIds).ignore(),
      );
      final deliver = DeliverToProjectAgent(
        repository: deliveries,
        wakeup:
            (projectId, agentIds) =>
                inbox.wakeProject(projectId, agentIds).ignore(),
      );
      inbox = AgentInboxCoordinator(
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
          modelUsageRepository: usage,
        ),
        executeReply: ExecuteProjectAgentReply(
          runRepository: runs,
          gateway: gateway,
          routeProjectMessage: route,
          deliverToProjectAgent: deliver,
          modelUsageRepository: usage,
        ),
        turnCoordinator: ProjectTurnCoordinator(
          turnRepository: turns,
          eventRepository: events,
          receiptRepository: receipts,
          runRepository: runs,
        ),
      );
      addTearDown(() async {
        await inbox.dispose();
        await deliveries.dispose();
        await events.dispose();
        await cursors.dispose();
        await memberships.dispose();
        await projects.dispose();
        await agents.dispose();
        await database.close();
        await support.delete(recursive: true);
      });

      final now = DateTime.utc(2026, 8, 22);
      final agent = Agent(
        id: 'shared-agent',
        name: 'Shared Agent',
        avatar: '',
        provider: 'test',
        baseUrl: '',
        apiKey: 'secret',
        apiType: Bot.apiTypeOpenAI,
        model: 'model',
        systemPrompt: 'Use the configured tools.',
        parameters: const <String, Object?>{
          'mcpServerIds': <String>['mcp-research'],
        },
        createdAt: now,
        updatedAt: now,
      );
      await agents.addAgent(agent);
      for (final projectId in <String>['project-a', 'project-b']) {
        await projects.addProjectWithMemberships(
          Project(
            id: projectId,
            name: projectId,
            lastMessageAt: now,
            createdAt: now,
            updatedAt: now,
          ),
          <ProjectMembership>[
            ProjectMembership(
              projectId: projectId,
              agentId: agent.id,
              position: 0,
              joinedAt: now,
              updatedAt: now,
            ),
          ],
        );
      }
      await localDatabase.upsertSkill(<String, Object?>{
        'id': 'skill-global',
        'name': 'global-research',
        'description': 'Shared research workflow',
        'version': '1',
        'scope': 'user',
        'source_uri': '',
        'root_path': '/skills/global-research',
        'content_digest': 'digest',
        'trust_state': 'trusted',
        'validation_status': 'valid',
        'compatibility': '',
        'requested_tools_json': '[]',
        'diagnostics_json': '[]',
        'has_scripts': 0,
        'has_references': 0,
        'has_assets': 0,
        'publisher_id': '',
        'publisher_name': '',
        'signature_status': 'unsigned',
        'catalog_id': '',
        'catalog_entry_id': '',
        'update_policy': 'manual',
        'installed_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      });
      await localDatabase.upsertBotSkillBinding(<String, Object?>{
        'agent_id': agent.id,
        'skill_id': 'skill-global',
        'enabled': 1,
        'activation_mode': 'auto',
        'priority': 0,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      });

      final routedByProject = <String, RoutedProjectMessage>{};
      for (final projectId in <String>['project-a', 'project-b']) {
        final skillInventory = await localDatabase
            .queryConversationSkillInventory(projectId, agent.id);
        expect(
          skillInventory.map((row) => row['id']),
          contains('skill-global'),
        );
        routedByProject[projectId] = await route(
          projectId: projectId,
          draft: ProjectMessageDraft(text: 'Research in $projectId'),
        );
      }
      await inbox.wakeProject('project-a');
      await inbox.wakeProject('project-b');
      await inbox.waitForIdle(projectId: 'project-a');
      await inbox.waitForIdle(projectId: 'project-b');

      expect(
        gateway.replyRequests.map((request) => request.projectId).toSet(),
        <String>{'project-a', 'project-b'},
      );
      expect(
        gateway.replyRequests.every(
          (request) =>
              (request.agent.parameters['mcpServerIds'] as List<Object?>)
                  .contains('mcp-research'),
        ),
        isTrue,
      );
      for (final projectId in <String>['project-a', 'project-b']) {
        final participation = await decisions.getForTurn(
          routedByProject[projectId]!.turn.id,
        );
        expect(participation, hasLength(1));
        expect(participation.single.choice, ParticipationChoice.reply);
        expect(participation.single.reasonCode, 'useful');
        final project = (await projects.getProject(projectId))!;
        final cursor = await cursors.getCursor(projectId, agent.id);
        expect(
          cursor?.lastProcessedMessageSequence,
          project.lastMessageSequence,
        );
        expect(
          (await receipts.getReceipt(projectId, agent.id, 1))?.outcome,
          AgentMessageReceiptOutcome.replied,
        );
        final timeline = await events.getEvents(projectId, limit: 200);
        expect(
          timeline.where(
            (event) => event.eventType == ProjectEventType.runStatusChanged,
          ),
          isNotEmpty,
        );
        expect(
          timeline.map((event) => event.sequence),
          orderedEquals(<int>[
            for (var sequence = 1; sequence <= timeline.length; sequence++)
              sequence,
          ]),
        );
      }
      expect(await database.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );
}

final class _Gateway implements ProjectAgentExecutionGateway {
  _Gateway()
    : _decisionGateway = ProviderProjectAgentExecutionGateway(
        providers: const _DecisionProviders(),
      );

  final ProviderProjectAgentExecutionGateway _decisionGateway;
  final List<ProjectAgentReplyRequest> replyRequests = [];

  @override
  Future<BroadcastParticipationResult> decide(
    BroadcastParticipationRequest request,
  ) => _decisionGateway.decide(request);

  @override
  Future<ProjectAgentReplyResult> reply(
    ProjectAgentReplyRequest request,
  ) async {
    replyRequests.add(request);
    return ProjectAgentReplyResult(
      status: ProjectAgentReplyStatus.completed,
      text: 'Completed ${request.projectId}',
    );
  }
}

final class _DecisionProviders implements AiProviderRepository {
  const _DecisionProviders();

  @override
  AiProvider create(Bot bot) => _DecisionProvider(bot);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _DecisionProvider extends AiProvider {
  _DecisionProvider(super.bot);

  @override
  Future<void> generateText(List<ChatMessage> messages) async {
    expect(messages.first.role, 'system');
    expect(messages.first.content, contains('"choice":"pass"'));
    onReasoningResponse?.call('The message needs a response.');
    onResponse('Here is the decision:\n```JSON\n');
    onResponse(
      '{"choice":"REPLY","reason_code":"useful",'
      '"intended_contribution":"answer"}',
    );
    onResponse('\n```');
    onTokenUsage?.call(
      const ModelTokenUsage(
        model: 'decision-model',
        inputTokens: 24,
        outputTokens: 8,
      ),
    );
  }
}

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
