enum AgentRunPhase { decision, reply, delivery }

enum AgentRunStatus {
  queued,
  deciding,
  passed,
  preparing,
  running,
  delivering,
  completed,
  cancelled,
  failed,
  timedOut,
  limitExceeded,
  interrupted,
}

final class AgentRunSnapshot {
  const AgentRunSnapshot({
    required this.agentName,
    required this.provider,
    required this.model,
    required this.systemPromptDigest,
    required this.capabilityDigest,
  });

  final String agentName;
  final String provider;
  final String model;
  final String systemPromptDigest;
  final String capabilityDigest;
}

final class AgentRun {
  const AgentRun({
    required this.id,
    required this.projectId,
    required this.turnId,
    required this.agentId,
    required this.sourceMessageEventId,
    required this.sourceMessageSequence,
    required this.contextThroughMessageSequence,
    this.parentRunId = '',
    required this.rootRunId,
    this.deliveryDepth = 0,
    required this.phase,
    this.status = AgentRunStatus.queued,
    required this.agentSnapshot,
    this.startedAt,
    this.completedAt,
    this.errorCode = '',
    required this.createdAt,
  }) : assert(sourceMessageSequence > 0),
       assert(contextThroughMessageSequence >= sourceMessageSequence),
       assert(deliveryDepth >= 0);

  final String id;
  final String projectId;
  final String turnId;
  final String agentId;
  final String sourceMessageEventId;
  final int sourceMessageSequence;
  final int contextThroughMessageSequence;
  final String parentRunId;
  final String rootRunId;
  final int deliveryDepth;
  final AgentRunPhase phase;
  final AgentRunStatus status;
  final AgentRunSnapshot agentSnapshot;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String errorCode;
  final DateTime createdAt;

  bool get isTerminal => switch (status) {
    AgentRunStatus.passed ||
    AgentRunStatus.completed ||
    AgentRunStatus.cancelled ||
    AgentRunStatus.failed ||
    AgentRunStatus.timedOut ||
    AgentRunStatus.limitExceeded ||
    AgentRunStatus.interrupted => true,
    _ => false,
  };

  AgentRun copyWith({
    AgentRunStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorCode,
    bool clearStartedAt = false,
    bool clearCompletedAt = false,
  }) => AgentRun(
    id: id,
    projectId: projectId,
    turnId: turnId,
    agentId: agentId,
    sourceMessageEventId: sourceMessageEventId,
    sourceMessageSequence: sourceMessageSequence,
    contextThroughMessageSequence: contextThroughMessageSequence,
    parentRunId: parentRunId,
    rootRunId: rootRunId,
    deliveryDepth: deliveryDepth,
    phase: phase,
    status: status ?? this.status,
    agentSnapshot: agentSnapshot,
    startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
    completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    errorCode: errorCode ?? this.errorCode,
    createdAt: createdAt,
  );
}
