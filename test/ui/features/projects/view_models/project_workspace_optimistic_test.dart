import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_delivery_repository.dart';
import 'package:hyve/domain/repositories/agent_message_receipt_repository.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/domain/repositories/agent_run_repository.dart';
import 'package:hyve/domain/repositories/attachment_repository.dart';
import 'package:hyve/domain/repositories/message_action_repository.dart';
import 'package:hyve/domain/repositories/model_usage_repository.dart';
import 'package:hyve/domain/repositories/participation_decision_repository.dart';
import 'package:hyve/domain/repositories/profile_repository.dart';
import 'package:hyve/domain/repositories/project_agent_cursor_repository.dart';
import 'package:hyve/domain/repositories/project_agent_execution_gateway.dart';
import 'package:hyve/domain/repositories/project_artifact_repository.dart';
import 'package:hyve/domain/repositories/project_event_repository.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';
import 'package:hyve/domain/repositories/project_message_route_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';
import 'package:hyve/domain/repositories/project_temporary_attachment_repository.dart';
import 'package:hyve/domain/repositories/project_turn_repository.dart';
import 'package:hyve/domain/use_cases/agent_inbox_coordinator.dart';
import 'package:hyve/domain/use_cases/execute_project_agent_reply.dart';
import 'package:hyve/domain/use_cases/project_turn_coordinator.dart';
import 'package:hyve/domain/use_cases/route_project_message.dart';
import 'package:hyve/domain/use_cases/run_broadcast_participation.dart';
import 'package:hyve/ui/features/projects/view_models/project_workspace_cache.dart';
import 'package:hyve/ui/features/projects/view_models/project_workspace_view_model.dart';

void main() {
  test('submit publishes before the route repository completes', () async {
    final routeRepository = _BlockingRouteRepository();
    final route = RouteProjectMessage(
      repository: routeRepository,
      clock: () => DateTime.utc(2026, 8, 31, 12),
      idFactory: (prefix) => '$prefix-1',
    );
    final membershipRepository = _MembershipRepository();
    final eventRepository = _EventRepository();
    final turnRepository = _TurnRepository();
    final runRepository = _RunRepository();
    final decisionRepository = _DecisionRepository();
    final receiptRepository = _ReceiptRepository();
    final agentRepository = _AgentRepository();
    final cursorRepository = _CursorRepository();
    final projectRepository = _ProjectRepository();
    final deliveryRepository = _DeliveryRepository();
    final usageRepository = _UsageRepository();
    final gateway = _ExecutionGateway();
    final inbox = AgentInboxCoordinator(
      cursorRepository: cursorRepository,
      projectRepository: projectRepository,
      membershipRepository: membershipRepository,
      eventRepository: eventRepository,
      turnRepository: turnRepository,
      runRepository: runRepository,
      decisionRepository: decisionRepository,
      agentRepository: agentRepository,
      runBroadcastParticipation: RunBroadcastParticipation(
        runRepository: runRepository,
        decisionRepository: decisionRepository,
        gateway: gateway,
        modelUsageRepository: usageRepository,
      ),
      executeReply: ExecuteProjectAgentReply(
        runRepository: runRepository,
        gateway: gateway,
        routeProjectMessage: route,
        modelUsageRepository: usageRepository,
      ),
      turnCoordinator: ProjectTurnCoordinator(
        turnRepository: turnRepository,
        eventRepository: eventRepository,
        receiptRepository: receiptRepository,
        runRepository: runRepository,
      ),
    );
    final viewModel = ProjectWorkspaceViewModel(
      projectId: 'project-1',
      routeProjectMessage: route,
      projectRepository: projectRepository,
      membershipRepository: membershipRepository,
      eventRepository: eventRepository,
      turnRepository: turnRepository,
      agentRepository: agentRepository,
      cursorRepository: cursorRepository,
      runRepository: runRepository,
      deliveryRepository: deliveryRepository,
      receiptRepository: receiptRepository,
      decisionRepository: decisionRepository,
      modelUsageRepository: usageRepository,
      inboxCoordinator: inbox,
      artifactRepository: _ArtifactRepository(),
      messageActionRepository: _MessageActionRepository(),
      attachmentRepository: _AttachmentRepository(),
      temporaryAttachmentRepository: _TemporaryAttachmentRepository(),
      profileRepository: _ProfileRepository(),
      workspaceCache: ProjectWorkspaceCache(),
    );
    addTearDown(() async {
      viewModel.dispose();
      await inbox.dispose();
    });

    final submission = viewModel.submit(
      ProjectMessageDraft(text: 'Render me first'),
    );

    expect(viewModel.submitting, isTrue);
    expect(viewModel.events, hasLength(1));
    expect(viewModel.events.single.content, 'Render me first');
    expect(
      viewModel.events.single.terminalState,
      ProjectEventTerminalState.draft,
    );
    expect(viewModel.events.single.messageSequence, isNull);

    await routeRepository.appendStarted.future;
    expect(
      viewModel.events.single.terminalState,
      ProjectEventTerminalState.draft,
      reason: 'database completion must not gate optimistic presentation',
    );

    routeRepository.complete();
    final routed = await submission;

    expect(routed, isNotNull);
    expect(viewModel.submitting, isFalse);
    expect(viewModel.events, hasLength(1));
    expect(viewModel.events.single.id, routed!.event.id);
    expect(
      viewModel.events.single.terminalState,
      ProjectEventTerminalState.completed,
    );
    expect(viewModel.events.single.messageSequence, 1);
  });
}

abstract class _UnsupportedRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError(invocation.memberName.toString());
}

final class _BlockingRouteRepository implements ProjectMessageRouteRepository {
  final Completer<void> appendStarted = Completer<void>();
  final Completer<RoutedProjectMessage> _result =
      Completer<RoutedProjectMessage>();
  ProjectMessageAppendRequest? _request;

  @override
  Future<RoutedProjectMessage> append(ProjectMessageAppendRequest request) {
    _request = request;
    appendStarted.complete();
    return _result.future;
  }

  void complete() {
    final request = _request!;
    final event = ProjectEvent(
      id: request.eventId,
      projectId: request.projectId,
      turnId: request.turnId,
      sequence: 1,
      messageSequence: 1,
      eventType: request.eventType,
      actorType: request.actorType,
      actorId: request.actorId,
      actorNameSnapshot: request.actorNameSnapshot,
      actorAvatarSnapshot: request.actorAvatarSnapshot,
      rootMessageId: request.eventId,
      content: request.content,
      payload: request.payload,
      targetAgentIds: request.targetAgentIds,
      createdAt: request.createdAt,
      updatedAt: request.createdAt,
    );
    _result.complete(
      RoutedProjectMessage(
        event: event,
        turn: ProjectTurn(
          id: request.turnId,
          projectId: request.projectId,
          rootEventId: request.eventId,
          initiatorType: request.initiatorType,
          initiatorId: request.initiatorId,
          routingMode: request.routingMode,
          sourceMessageId: request.eventId,
          sourceMessageSequence: 1,
          recipientCount: 0,
          rootTurnId: request.turnId,
          createdAt: request.createdAt,
        ),
        activeAgentIds: const <String>[],
      ),
    );
  }
}

final class _ProjectRepository extends _UnsupportedRepository
    implements ProjectRepository {
  @override
  Stream<List<Project>> get changes => const Stream<List<Project>>.empty();
}

final class _MembershipRepository extends _UnsupportedRepository
    implements ProjectMembershipRepository {
  @override
  Stream<String> get changes => const Stream<String>.empty();
}

final class _EventRepository extends _UnsupportedRepository
    implements ProjectEventRepository {
  @override
  Stream<String> get changes => const Stream<String>.empty();
}

final class _TurnRepository extends _UnsupportedRepository
    implements ProjectTurnRepository {}

final class _AgentRepository extends _UnsupportedRepository
    implements AgentRepository {
  @override
  Stream<List<Agent>> get changes => const Stream<List<Agent>>.empty();
}

final class _CursorRepository extends _UnsupportedRepository
    implements ProjectAgentCursorRepository {
  @override
  Stream<ProjectAgentInboxKey> get changes =>
      const Stream<ProjectAgentInboxKey>.empty();
}

final class _RunRepository extends _UnsupportedRepository
    implements AgentRunRepository {}

final class _DeliveryRepository extends _UnsupportedRepository
    implements AgentDeliveryRepository {
  @override
  Stream<String> get changes => const Stream<String>.empty();
}

final class _ReceiptRepository extends _UnsupportedRepository
    implements AgentMessageReceiptRepository {}

final class _DecisionRepository extends _UnsupportedRepository
    implements ParticipationDecisionRepository {}

final class _UsageRepository extends _UnsupportedRepository
    implements ModelUsageRepository {}

final class _ArtifactRepository extends _UnsupportedRepository
    implements ProjectArtifactRepository {
  @override
  Stream<String> get changes => const Stream<String>.empty();
}

final class _AttachmentRepository extends _UnsupportedRepository
    implements AttachmentRepository {}

final class _MessageActionRepository extends _UnsupportedRepository
    implements MessageActionRepository {}

final class _TemporaryAttachmentRepository extends _UnsupportedRepository
    implements ProjectTemporaryAttachmentRepository {}

final class _ProfileRepository extends _UnsupportedRepository
    implements ProfileRepository {
  @override
  Stream<Profile> get changes => const Stream<Profile>.empty();

  @override
  Future<Profile> getProfile() async {
    final now = DateTime.utc(2026, 8, 31);
    return Profile(
      name: 'User',
      avatar: '',
      fontSize: 14,
      themeMode: 0,
      language: 'en',
      createTimestamp: now,
      modifyTimestamp: now,
    );
  }
}

final class _ExecutionGateway extends _UnsupportedRepository
    implements ProjectAgentExecutionGateway {}
