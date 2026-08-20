enum ProjectTurnInitiatorType { user, agent, system }

enum ProjectTurnRoutingMode { targeted, broadcast, delivery }

enum ProjectTurnStatus {
  created,
  dispatching,
  deciding,
  replying,
  delivering,
  completed,
  partial,
  failed,
  cancelled,
}

final class ProjectTurn {
  const ProjectTurn({
    required this.id,
    required this.projectId,
    required this.rootEventId,
    required this.initiatorType,
    this.initiatorId = '',
    required this.routingMode,
    required this.sourceMessageId,
    required this.sourceMessageSequence,
    required this.recipientCount,
    required this.rootTurnId,
    this.autonomousDepth = 0,
    this.status = ProjectTurnStatus.created,
    this.noParticipant = false,
    required this.createdAt,
    this.completedAt,
  }) : assert(sourceMessageSequence > 0),
       assert(recipientCount >= 0),
       assert(autonomousDepth >= 0);

  final String id;
  final String projectId;
  final String rootEventId;
  final ProjectTurnInitiatorType initiatorType;
  final String initiatorId;
  final ProjectTurnRoutingMode routingMode;
  final String sourceMessageId;
  final int sourceMessageSequence;
  final int recipientCount;
  final String rootTurnId;
  final int autonomousDepth;
  final ProjectTurnStatus status;
  final bool noParticipant;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isTerminal => switch (status) {
    ProjectTurnStatus.completed ||
    ProjectTurnStatus.partial ||
    ProjectTurnStatus.failed ||
    ProjectTurnStatus.cancelled => true,
    _ => false,
  };

  ProjectTurn copyWith({
    ProjectTurnStatus? status,
    bool? noParticipant,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) => ProjectTurn(
    id: id,
    projectId: projectId,
    rootEventId: rootEventId,
    initiatorType: initiatorType,
    initiatorId: initiatorId,
    routingMode: routingMode,
    sourceMessageId: sourceMessageId,
    sourceMessageSequence: sourceMessageSequence,
    recipientCount: recipientCount,
    rootTurnId: rootTurnId,
    autonomousDepth: autonomousDepth,
    status: status ?? this.status,
    noParticipant: noParticipant ?? this.noParticipant,
    createdAt: createdAt,
    completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
  );
}
