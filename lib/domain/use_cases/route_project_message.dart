import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/project_message_route_repository.dart';

typedef ProjectRouteClock = DateTime Function();
typedef ProjectRouteIdFactory = String Function(String prefix);
typedef ProjectInboxWakeup =
    void Function(String projectId, Iterable<String> agentIds);

final class ProjectMessageRouteFailure implements Exception {
  const ProjectMessageRouteFailure(this.code);

  final String code;

  @override
  String toString() => 'ProjectMessageRouteFailure($code)';
}

final class ProjectMessageRouteIdentity {
  const ProjectMessageRouteIdentity({
    required this.eventId,
    required this.turnId,
    required this.createdAt,
  });

  final String eventId;
  final String turnId;
  final DateTime createdAt;
}

/// A user message with stable identities, ready for optimistic presentation or
/// durable routing. The repository still allocates authoritative sequences.
final class PreparedProjectMessageRoute {
  const PreparedProjectMessageRoute({
    required this.identity,
    required this.request,
  });

  final ProjectMessageRouteIdentity identity;
  final ProjectMessageAppendRequest request;

  ProjectEvent optimisticEvent({required int sequence}) => ProjectEvent(
    id: request.eventId,
    projectId: request.projectId,
    turnId: request.turnId,
    sequence: sequence,
    eventType: request.eventType,
    actorType: request.actorType,
    actorId: request.actorId,
    actorNameSnapshot: request.actorNameSnapshot,
    actorAvatarSnapshot: request.actorAvatarSnapshot,
    visibility: ProjectEventVisibility.project,
    rootMessageId: request.eventId,
    content: request.content,
    payload: request.payload,
    terminalState: ProjectEventTerminalState.draft,
    targetAgentIds: request.targetAgentIds,
    createdAt: request.createdAt,
    updatedAt: request.createdAt,
  );
}

final class RouteProjectMessage {
  RouteProjectMessage({
    required ProjectMessageRouteRepository repository,
    ProjectRouteClock? clock,
    ProjectRouteIdFactory? idFactory,
    ProjectInboxWakeup? wakeup,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now,
       _idFactory = idFactory ?? _defaultIdFactory,
       _wakeup = wakeup;

  final ProjectMessageRouteRepository _repository;
  final ProjectRouteClock _clock;
  final ProjectRouteIdFactory _idFactory;
  final ProjectInboxWakeup? _wakeup;

  Future<RoutedProjectMessage> call({
    required String projectId,
    required ProjectMessageDraft draft,
    String currentUserId = 'me',
    String currentUserName = '',
    String currentUserAvatar = '',
  }) async {
    return commit(
      prepareUserMessage(
        projectId: projectId,
        draft: draft,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserAvatar: currentUserAvatar,
      ),
    );
  }

  PreparedProjectMessageRoute prepareUserMessage({
    required String projectId,
    required ProjectMessageDraft draft,
    String currentUserId = 'me',
    String currentUserName = '',
    String currentUserAvatar = '',
    ProjectMessageRouteIdentity? identity,
  }) {
    if (projectId.trim().isEmpty || draft.isEmpty) {
      throw const ProjectMessageRouteFailure('invalid_project_message');
    }
    final targetAgentIds = draft.mentionedAgentIds;
    final routingMode =
        targetAgentIds.isEmpty
            ? ProjectTurnRoutingMode.broadcast
            : ProjectTurnRoutingMode.targeted;
    final routeIdentity =
        identity ??
        ProjectMessageRouteIdentity(
          eventId: _idFactory('event'),
          turnId: _idFactory('turn'),
          createdAt: _clock(),
        );
    final images = <String>[];
    final files = <String>[];
    for (final attachment in draft.attachments) {
      if (attachment.kind == PendingAttachmentKind.image) {
        images.add(attachment.sourcePath);
      } else {
        files.add(attachment.sourcePath);
      }
    }
    return PreparedProjectMessageRoute(
      identity: routeIdentity,
      request: ProjectMessageAppendRequest(
        eventId: routeIdentity.eventId,
        turnId: routeIdentity.turnId,
        projectId: projectId,
        initiatorType: ProjectTurnInitiatorType.user,
        initiatorId: currentUserId,
        actorType: ProjectEventActorType.user,
        actorId: currentUserId,
        actorNameSnapshot: currentUserName,
        actorAvatarSnapshot: currentUserAvatar,
        eventType: ProjectEventType.userMessage,
        routingMode: routingMode,
        content: draft.text,
        payload: ProjectMessagePayload(
          images: images,
          files: files,
          projectArtifactVersionIds: draft.projectArtifactVersionIds,
        ),
        targetAgentIds: targetAgentIds,
        createdAt: routeIdentity.createdAt,
      ),
    );
  }

  Future<RoutedProjectMessage> commit(PreparedProjectMessageRoute prepared) =>
      _appendAndWake(prepared.request);

  Future<RoutedProjectMessage> appendAgentReply({
    required String projectId,
    required Agent agent,
    required String content,
    String reasoning = '',
    String processInfoJson = '',
    required String runId,
    required ProjectEvent sourceEvent,
    required ProjectTurn sourceTurn,
  }) {
    final now = _clock();
    final payload =
        processInfoJson.isEmpty
            ? ProjectMessagePayload(reasoning: reasoning)
            : ProjectMessagePayload(
              reasoning: reasoning,
              processInfoJson: processInfoJson,
            );
    return _appendAndWake(
      ProjectMessageAppendRequest(
        eventId: _idFactory('event'),
        turnId: _idFactory('turn'),
        runId: runId,
        projectId: projectId,
        initiatorType: ProjectTurnInitiatorType.agent,
        initiatorId: agent.id,
        actorType: ProjectEventActorType.agent,
        actorId: agent.id,
        actorNameSnapshot: agent.name,
        actorAvatarSnapshot: agent.avatar,
        eventType: ProjectEventType.agentMessage,
        routingMode: ProjectTurnRoutingMode.broadcast,
        content: content,
        payload: payload,
        replyToEventId: sourceEvent.id,
        replyToMessageSequence: sourceEvent.messageSequence,
        rootMessageId:
            sourceEvent.rootMessageId.isEmpty
                ? sourceEvent.id
                : sourceEvent.rootMessageId,
        rootTurnId: sourceTurn.rootTurnId,
        autonomousDepth: sourceEvent.autonomousDepth + 1,
        createdAt: now,
      ),
    );
  }

  Future<RoutedProjectMessage> _appendAndWake(
    ProjectMessageAppendRequest request,
  ) async {
    try {
      final routed = await _repository.append(request);
      _wakeup?.call(routed.event.projectId, routed.activeAgentIds);
      return routed;
    } on StateError catch (error) {
      throw ProjectMessageRouteFailure(error.message);
    }
  }
}

int _routeIdentitySequence = 0;

String _defaultIdFactory(String prefix) {
  _routeIdentitySequence = (_routeIdentitySequence + 1) & 0x7fffffff;
  return '$prefix:${DateTime.now().microsecondsSinceEpoch}:'
      '$_routeIdentitySequence';
}
