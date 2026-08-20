import 'package:hyve/domain/models/project_event.dart';
import 'package:hyve/domain/models/project_turn.dart';

final class ProjectMessageAppendRequest {
  ProjectMessageAppendRequest({
    required this.eventId,
    required this.turnId,
    this.runId = '',
    required this.projectId,
    required this.initiatorType,
    this.initiatorId = '',
    required this.actorType,
    this.actorId = '',
    this.actorNameSnapshot = '',
    this.actorAvatarSnapshot = '',
    required this.eventType,
    required this.routingMode,
    required this.content,
    required this.payload,
    Iterable<String> targetAgentIds = const <String>[],
    this.replyToEventId = '',
    this.replyToMessageSequence,
    this.rootMessageId = '',
    this.rootTurnId = '',
    this.autonomousDepth = 0,
    required this.createdAt,
  }) : targetAgentIds = List<String>.unmodifiable(targetAgentIds),
       assert(autonomousDepth >= 0);

  final String eventId;
  final String turnId;
  final String runId;
  final String projectId;
  final ProjectTurnInitiatorType initiatorType;
  final String initiatorId;
  final ProjectEventActorType actorType;
  final String actorId;
  final String actorNameSnapshot;
  final String actorAvatarSnapshot;
  final ProjectEventType eventType;
  final ProjectTurnRoutingMode routingMode;
  final String content;
  final ProjectMessagePayload payload;
  final List<String> targetAgentIds;
  final String replyToEventId;
  final int? replyToMessageSequence;
  final String rootMessageId;
  final String rootTurnId;
  final int autonomousDepth;
  final DateTime createdAt;
}

final class RoutedProjectMessage {
  RoutedProjectMessage({
    required this.event,
    required this.turn,
    required Iterable<String> activeAgentIds,
  }) : activeAgentIds = List<String>.unmodifiable(activeAgentIds);

  final ProjectEvent event;
  final ProjectTurn turn;
  final List<String> activeAgentIds;
}
