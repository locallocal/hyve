enum AgentMessageReceiptOutcome {
  replied,
  passed,
  observed,
  notTargeted,
  ownMessage,
  invisible,
  cancelled,
  failedSkipped,
  chainLimitReached,
}

final class AgentMessageReceipt {
  const AgentMessageReceipt({
    required this.projectId,
    required this.agentId,
    required this.messageSequence,
    required this.messageEventId,
    required this.turnId,
    required this.outcome,
    this.decisionRunId = '',
    this.replyRunId = '',
    this.replyEventId = '',
    this.startedAt,
    required this.completedAt,
    this.errorCode = '',
  }) : assert(messageSequence > 0);

  final String projectId;
  final String agentId;
  final int messageSequence;
  final String messageEventId;
  final String turnId;
  final AgentMessageReceiptOutcome outcome;
  final String decisionRunId;
  final String replyRunId;
  final String replyEventId;
  final DateTime? startedAt;
  final DateTime completedAt;
  final String errorCode;
}
