import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/views/project_event_list.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  testWidgets(
    'shows reply navigation and keeps pass decisions out of bubbles',
    (tester) async {
      final now = DateTime.utc(2026, 8, 22);
      final events = <ProjectEvent>[
        _message(
          id: 'event-1',
          turnId: 'turn-user',
          sequence: 1,
          messageSequence: 1,
          actorType: ProjectEventActorType.user,
          content: 'Investigate this',
          now: now,
        ),
        _message(
          id: 'event-2',
          turnId: 'turn-agent',
          sequence: 2,
          messageSequence: 2,
          actorType: ProjectEventActorType.agent,
          content: 'I found the cause',
          now: now,
          replyToEventId: 'event-1',
          replyToMessageSequence: 1,
        ),
        ProjectEvent(
          id: 'decision-1',
          projectId: 'project-1',
          turnId: 'turn-user',
          sequence: 3,
          eventType: ProjectEventType.participationDecision,
          actorType: ProjectEventActorType.agent,
          actorId: 'agent-1',
          content: 'must-not-be-a-bubble',
          payload: const ParticipationDecisionPayload(
            choice: ParticipationChoice.pass,
            reasonCode: 'no_contribution',
          ),
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final turn = ProjectTurn(
        id: 'turn-agent',
        projectId: 'project-1',
        rootEventId: 'event-1',
        initiatorType: ProjectTurnInitiatorType.agent,
        initiatorId: 'agent-1',
        routingMode: ProjectTurnRoutingMode.targeted,
        sourceMessageId: 'event-2',
        sourceMessageSequence: 2,
        recipientCount: 0,
        rootTurnId: 'turn-user',
        status: ProjectTurnStatus.completed,
        noParticipant: true,
        createdAt: now,
        completedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          home: Scaffold(
            body: ProjectEventList(
              events: events,
              turns: <String, ProjectTurn>{turn.id: turn},
              deliveries: const <String, AgentDelivery>{},
              runs: const <String, AgentRun>{},
              agentNames: const <String, String>{'agent-1': 'Researcher'},
            ),
          ),
        ),
      );

      expect(find.text('Investigate this'), findsOneWidget);
      expect(find.text('I found the cause'), findsOneWidget);
      expect(find.text('Replying to message #1'), findsOneWidget);
      expect(
        find.text('No agent needed to add anything to this message.'),
        findsOneWidget,
      );
      expect(find.text('must-not-be-a-bubble'), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey<String>('project-reply-link-event-2')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'message backgrounds are subtle and current-message hint is visible',
    (tester) async {
      final now = DateTime.utc(2026, 8, 23);
      final event = _message(
        id: 'current-message',
        turnId: 'current-turn',
        sequence: 1,
        messageSequence: 1,
        actorType: ProjectEventActorType.user,
        content: 'Current project message',
        now: now,
      );
      final agentEvent = _message(
        id: 'agent-message',
        turnId: 'agent-turn',
        sequence: 2,
        messageSequence: 2,
        actorType: ProjectEventActorType.agent,
        content: 'Agent response',
        now: now,
      );
      final turn = ProjectTurn(
        id: 'current-turn',
        projectId: 'project-1',
        rootEventId: event.id,
        initiatorType: ProjectTurnInitiatorType.user,
        initiatorId: 'user',
        routingMode: ProjectTurnRoutingMode.broadcast,
        sourceMessageId: event.id,
        sourceMessageSequence: 1,
        recipientCount: 0,
        rootTurnId: 'current-turn',
        status: ProjectTurnStatus.completed,
        noParticipant: true,
        createdAt: now,
        completedAt: now,
      );

      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          shadHarness(
            brightness: brightness,
            locale: const Locale('zh', 'CN'),
            homeBuilder:
                (_) => Scaffold(
                  body: ProjectEventList(
                    events: <ProjectEvent>[event, agentEvent],
                    turns: <String, ProjectTurn>{turn.id: turn},
                    deliveries: const <String, AgentDelivery>{},
                    runs: const <String, AgentRun>{},
                    agentNames: const <String, String>{'agent-1': 'Researcher'},
                  ),
                ),
          ),
        );
        await tester.pumpAndSettle();

        final bubbleFinder = find.byKey(
          const ValueKey<String>('project-message-bubble-current-message'),
        );
        final bubble = tester.widget<Container>(
          find
              .descendant(of: bubbleFinder, matching: find.byType(Container))
              .first,
        );
        final decoration = bubble.decoration! as BoxDecoration;
        final shadTheme = ShadTheme.of(tester.element(bubbleFinder));
        expect(decoration.border, isNull, reason: brightness.name);
        expect(
          _colorDistance(decoration.color!, shadTheme.colorScheme.background),
          lessThan(
            _colorDistance(
                  shadTheme.colorScheme.primary,
                  shadTheme.colorScheme.background,
                ) *
                0.025,
          ),
          reason: brightness.name,
        );

        final agentBubbleFinder = find.byKey(
          const ValueKey<String>('project-message-bubble-agent-message'),
        );
        final agentBubble = tester.widget<Container>(
          find
              .descendant(
                of: agentBubbleFinder,
                matching: find.byType(Container),
              )
              .first,
        );
        final agentDecoration = agentBubble.decoration! as BoxDecoration;
        expect(agentDecoration.border, isNull, reason: brightness.name);
        expect(
          _colorDistance(
            agentDecoration.color!,
            shadTheme.colorScheme.background,
          ),
          lessThan(
            _colorDistance(
                  shadTheme.colorScheme.muted,
                  shadTheme.colorScheme.background,
                ) *
                0.20,
          ),
          reason: brightness.name,
        );

        final hint = tester.widget<Text>(
          find.byKey(const ValueKey<String>('no-participant-current-message')),
        );
        expect(hint.data, '本条消息没有智能体需要补充。');
        expect(hint.style?.color, shadTheme.colorScheme.mutedForeground);
        expect(tester.takeException(), isNull);
      }
    },
  );
}

double _colorDistance(Color left, Color right) {
  final red = left.r - right.r;
  final green = left.g - right.g;
  final blue = left.b - right.b;
  return red * red + green * green + blue * blue;
}

ProjectEvent _message({
  required String id,
  required String turnId,
  required int sequence,
  required int messageSequence,
  required ProjectEventActorType actorType,
  required String content,
  required DateTime now,
  String replyToEventId = '',
  int? replyToMessageSequence,
}) => ProjectEvent(
  id: id,
  projectId: 'project-1',
  turnId: turnId,
  sequence: sequence,
  messageSequence: messageSequence,
  eventType:
      actorType == ProjectEventActorType.user
          ? ProjectEventType.userMessage
          : ProjectEventType.agentMessage,
  actorType: actorType,
  actorId: actorType == ProjectEventActorType.user ? 'user' : 'agent-1',
  actorNameSnapshot:
      actorType == ProjectEventActorType.user ? 'User' : 'Researcher',
  replyToEventId: replyToEventId,
  replyToMessageSequence: replyToMessageSequence,
  content: content,
  payload: ProjectMessagePayload(),
  createdAt: now,
  updatedAt: now,
);
