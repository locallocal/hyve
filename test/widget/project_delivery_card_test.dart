import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/views/project_workspace_page.dart';

import '../support/widget_test_support.dart';

void main() {
  testWidgets('delivery card expands to visible audit and run-chain details', (
    tester,
  ) async {
    final now = DateTime(2026, 8, 22);
    final event = ProjectEvent(
      id: 'delivery-event-1',
      projectId: 'project-1',
      turnId: 'delivery-turn-1',
      runId: 'delivery-run-1',
      sequence: 2,
      messageSequence: 2,
      eventType: ProjectEventType.agentDelivery,
      actorType: ProjectEventActorType.agent,
      actorId: 'agent-1',
      actorNameSnapshot: 'Researcher',
      visibility: ProjectEventVisibility.targets,
      content: 'Review the findings',
      payload: AgentDeliveryPayload(
        kind: AgentDeliveryKind.task,
        summary: 'Review the findings',
        payload: 'Audit the evidence and report any unsupported claims.',
        requestPublicReply: true,
      ),
      targetAgentIds: const <String>['agent-2'],
      createdAt: now,
      updatedAt: now,
    );
    final delivery = AgentDelivery(
      eventId: event.id,
      deliveryRunId: event.runId,
      sourceRunId: 'reply-run-1',
      sourceAgentId: 'agent-1',
      kind: AgentDeliveryKind.task,
      summary: 'Review the findings',
      payload: 'Audit the evidence and report any unsupported claims.',
      visibility: AgentDeliveryVisibility.targets,
      requestPublicReply: true,
      rootTurnId: 'root-turn-1',
      depth: 1,
      payloadDigest: 'digest',
      targetAgentIds: const <String>['agent-2'],
    );
    final deliveryRun = AgentRun(
      id: event.runId,
      projectId: event.projectId,
      turnId: 'root-turn-1',
      agentId: 'agent-1',
      sourceMessageEventId: 'source-event-1',
      sourceMessageSequence: 1,
      contextThroughMessageSequence: 1,
      parentRunId: 'reply-run-1',
      rootRunId: 'reply-run-1',
      deliveryDepth: 1,
      phase: AgentRunPhase.delivery,
      status: AgentRunStatus.completed,
      agentSnapshot: const AgentRunSnapshot(
        agentName: 'Researcher',
        provider: 'test',
        model: 'model',
        systemPromptDigest: 'prompt',
        capabilityDigest: 'capability',
      ),
      startedAt: now,
      completedAt: now,
      createdAt: now,
    );
    final childRun = AgentRun(
      id: 'reply-run-2',
      projectId: event.projectId,
      turnId: event.turnId,
      agentId: 'agent-2',
      sourceMessageEventId: event.id,
      sourceMessageSequence: 2,
      contextThroughMessageSequence: 2,
      parentRunId: event.runId,
      rootRunId: 'reply-run-1',
      deliveryDepth: 1,
      phase: AgentRunPhase.reply,
      status: AgentRunStatus.running,
      agentSnapshot: const AgentRunSnapshot(
        agentName: 'Reviewer',
        provider: 'test',
        model: 'model',
        systemPromptDigest: 'prompt',
        capabilityDigest: 'capability',
      ),
      startedAt: now,
      createdAt: now,
    );

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        locale: const Locale('en'),
        homeBuilder:
            (context) => Scaffold(
              body: Center(
                child: SizedBox(
                  width: 640,
                  child: ProjectDeliveryCard(
                    event: event,
                    delivery: delivery,
                    turn: ProjectTurn(
                      id: event.turnId,
                      projectId: event.projectId,
                      rootEventId: 'source-event-1',
                      initiatorType: ProjectTurnInitiatorType.agent,
                      initiatorId: 'agent-1',
                      routingMode: ProjectTurnRoutingMode.delivery,
                      sourceMessageId: event.id,
                      sourceMessageSequence: 2,
                      recipientCount: 1,
                      rootTurnId: 'root-turn-1',
                      status: ProjectTurnStatus.delivering,
                      createdAt: now,
                    ),
                    agentNames: const <String, String>{
                      'agent-1': 'Researcher',
                      'agent-2': 'Reviewer',
                    },
                    runs: <String, AgentRun>{
                      deliveryRun.id: deliveryRun,
                      childRun.id: childRun,
                    },
                  ),
                ),
              ),
            ),
      ),
    );

    expect(find.byType(ShadAccordion<String>), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);
    expect(find.text('Review the findings'), findsOneWidget);
    expect(find.textContaining('Researcher → Reviewer'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>('project-delivery-audit-delivery-event-1'),
      ),
      findsNothing,
    );

    await tester.tap(
      find.byKey(
        const ValueKey<String>('project-delivery-expansion-delivery-event-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Audit the evidence and report any unsupported claims.'),
      findsOneWidget,
    );
    expect(find.text('Public reply requested'), findsOneWidget);
    expect(find.textContaining('Source run: reply-run-1'), findsOneWidget);
    expect(find.textContaining('Delivery depth: 1'), findsOneWidget);
    expect(find.textContaining('Reviewer:running'), findsOneWidget);
  });
}
