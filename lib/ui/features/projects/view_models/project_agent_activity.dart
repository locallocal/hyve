import 'package:hyve/domain/models/models.dart';

enum ProjectAgentActivity {
  idle,
  deciding,
  willReply,
  skipped,
  replying,
  catchingUp,
  paused,
  failed,
}

ProjectAgentActivity resolveProjectAgentActivity(
  ProjectMembership membership,
  AgentMessageCursor? cursor,
  AgentRun? run,
  ParticipationDecision? latestDecision,
  AgentMessageReceipt? latestReceipt,
  Project project,
) {
  if (membership.status != ProjectMembershipStatus.active ||
      cursor?.workerState == AgentInboxWorkerState.paused) {
    return ProjectAgentActivity.paused;
  }
  if (cursor?.workerState == AgentInboxWorkerState.error) {
    return ProjectAgentActivity.failed;
  }
  if (run?.phase == AgentRunPhase.decision && !run!.isTerminal) {
    return ProjectAgentActivity.deciding;
  }
  if (run?.phase == AgentRunPhase.reply &&
      (run?.status == AgentRunStatus.queued ||
          run?.status == AgentRunStatus.preparing)) {
    return ProjectAgentActivity.willReply;
  }
  if (run?.phase == AgentRunPhase.reply && !run!.isTerminal) {
    return ProjectAgentActivity.replying;
  }
  final processing = cursor?.processingMessageSequence;
  if (processing != null && latestDecision?.messageSequence == processing) {
    return latestDecision?.choice == ParticipationChoice.reply
        ? ProjectAgentActivity.willReply
        : ProjectAgentActivity.skipped;
  }
  if ((cursor?.lastProcessedMessageSequence ?? membership.joinMessageSequence) <
      project.lastMessageSequence) {
    return ProjectAgentActivity.catchingUp;
  }
  if (latestReceipt?.messageSequence == project.lastMessageSequence &&
      latestReceipt?.outcome == AgentMessageReceiptOutcome.passed) {
    return ProjectAgentActivity.skipped;
  }
  if (latestReceipt?.messageSequence == project.lastMessageSequence &&
      latestReceipt?.outcome == AgentMessageReceiptOutcome.failedSkipped) {
    return ProjectAgentActivity.failed;
  }
  return ProjectAgentActivity.idle;
}
