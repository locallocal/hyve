import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/view_models/project_agent_activity.dart';

void main() {
  final now = DateTime.utc(2026, 8, 22);
  final membership = ProjectMembership(
    projectId: 'project-1',
    agentId: 'agent-1',
    position: 0,
    joinedAt: now,
    updatedAt: now,
  );
  final project = Project(
    id: 'project-1',
    name: 'Project',
    lastMessageSequence: 1,
    lastMessageAt: now,
    createdAt: now,
    updatedAt: now,
  );

  test('queued reply is shown as will reply', () {
    final activity = resolveProjectAgentActivity(
      membership,
      AgentMessageCursor(
        projectId: 'project-1',
        agentId: 'agent-1',
        lastProcessedMessageSequence: 0,
        processingMessageSequence: 1,
        workerState: AgentInboxWorkerState.processing,
        activeRunId: 'reply-run',
        updatedAt: now,
      ),
      AgentRun(
        id: 'reply-run',
        projectId: 'project-1',
        turnId: 'turn-1',
        agentId: 'agent-1',
        sourceMessageEventId: 'event-1',
        sourceMessageSequence: 1,
        contextThroughMessageSequence: 1,
        rootRunId: 'reply-run',
        phase: AgentRunPhase.reply,
        agentSnapshot: const AgentRunSnapshot(
          agentName: 'Agent',
          provider: 'test',
          model: 'model',
          systemPromptDigest: 'prompt',
          capabilityDigest: 'capability',
        ),
        createdAt: now,
      ),
      null,
      null,
      project,
    );

    expect(activity, ProjectAgentActivity.willReply);
  });

  test('terminal pass receipt remains visible as skipped', () {
    final activity = resolveProjectAgentActivity(
      membership,
      AgentMessageCursor(
        projectId: 'project-1',
        agentId: 'agent-1',
        lastProcessedMessageSequence: 1,
        updatedAt: now,
      ),
      null,
      null,
      AgentMessageReceipt(
        projectId: 'project-1',
        agentId: 'agent-1',
        messageSequence: 1,
        messageEventId: 'event-1',
        turnId: 'turn-1',
        outcome: AgentMessageReceiptOutcome.passed,
        completedAt: now,
      ),
      project,
    );

    expect(activity, ProjectAgentActivity.skipped);
  });

  test('terminal failure receipt remains visible as failed', () {
    final activity = resolveProjectAgentActivity(
      membership,
      AgentMessageCursor(
        projectId: 'project-1',
        agentId: 'agent-1',
        lastProcessedMessageSequence: 1,
        updatedAt: now,
      ),
      null,
      null,
      AgentMessageReceipt(
        projectId: 'project-1',
        agentId: 'agent-1',
        messageSequence: 1,
        messageEventId: 'event-1',
        turnId: 'turn-1',
        outcome: AgentMessageReceiptOutcome.failedSkipped,
        completedAt: now,
        errorCode: 'reply_failed',
      ),
      project,
    );

    expect(activity, ProjectAgentActivity.failed);
  });
}
