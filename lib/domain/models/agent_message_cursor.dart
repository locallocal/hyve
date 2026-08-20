enum AgentInboxWorkerState { idle, scheduled, processing, paused, error }

final class AgentMessageCursor {
  const AgentMessageCursor({
    required this.projectId,
    required this.agentId,
    required this.lastProcessedMessageSequence,
    this.processingMessageSequence,
    this.workerState = AgentInboxWorkerState.idle,
    this.activeRunId,
    this.leaseOwner = '',
    this.leaseExpiresAt,
    this.lastError = '',
    required this.updatedAt,
  }) : assert(lastProcessedMessageSequence >= 0),
       assert(
         processingMessageSequence == null || processingMessageSequence > 0,
       );

  final String projectId;
  final String agentId;
  final int lastProcessedMessageSequence;
  final int? processingMessageSequence;
  final AgentInboxWorkerState workerState;
  final String? activeRunId;
  final String leaseOwner;
  final DateTime? leaseExpiresAt;
  final String lastError;
  final DateTime updatedAt;

  int backlogThrough(int latestMessageSequence) =>
      latestMessageSequence <= lastProcessedMessageSequence
          ? 0
          : latestMessageSequence - lastProcessedMessageSequence;
}
