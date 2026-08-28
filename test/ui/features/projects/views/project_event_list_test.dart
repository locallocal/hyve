import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/views/project_event_list.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  testWidgets('empty timeline matches the desktop shadcn empty state', (
    tester,
  ) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        shadHarness(
          brightness: brightness,
          locale: const Locale('zh', 'CN'),
          homeBuilder:
              (_) => const Scaffold(
                body: ProjectEventList(
                  events: <ProjectEvent>[],
                  turns: <String, ProjectTurn>{},
                  deliveries: <String, AgentDelivery>{},
                  runs: <String, AgentRun>{},
                  agentNames: <String, String>{},
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      final titleFinder = find.text('暂无消息');
      final descriptionFinder = find.text('发送消息开始协作；不使用 @ 时将广播。');
      final title = tester.widget<Text>(titleFinder);
      final description = tester.widget<Text>(descriptionFinder);
      final materialTheme = Theme.of(tester.element(titleFinder));

      expect(find.byIcon(LucideIcons.messageSquareText), findsOneWidget);
      expect(
        tester.widget<Icon>(find.byIcon(LucideIcons.messageSquareText)).size,
        18,
      );
      expect(
        title.style?.fontSize,
        materialTheme.textTheme.titleMedium?.fontSize,
      );
      expect(title.style?.fontWeight, FontWeight.w600);
      expect(
        title.style?.fontFamilyFallback,
        materialTheme.textTheme.titleMedium?.fontFamilyFallback,
      );
      expect(
        description.style?.fontSize,
        materialTheme.textTheme.bodyMedium?.fontSize,
      );
      expect(
        description.style?.fontFamilyFallback,
        materialTheme.textTheme.bodyMedium?.fontFamilyFallback,
      );
      expect(tester.takeException(), isNull, reason: brightness.name);
    }
  });

  testWidgets('empty timeline accepts a no-agent action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (_) => Scaffold(
              body: ProjectEventList(
                events: const <ProjectEvent>[],
                turns: const <String, ProjectTurn>{},
                deliveries: const <String, AgentDelivery>{},
                runs: const <String, AgentRun>{},
                agentNames: const <String, String>{},
                emptyIcon: LucideIcons.bot,
                emptyTitle: '暂无活跃智能体',
                emptyDescription: '添加智能体后即可开始协作。',
                emptyAction: ShadButton(
                  onPressed: () => tapped = true,
                  child: const Text('添加智能体'),
                ),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂无活跃智能体'), findsOneWidget);
    expect(find.text('添加智能体后即可开始协作。'), findsOneWidget);
    await tester.tap(find.text('添加智能体'));
    expect(tapped, isTrue);
  });

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

  testWidgets('user without custom avatar matches the profile default avatar', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 8, 23);
    final event = _message(
      id: 'user-message',
      turnId: 'user-turn',
      sequence: 1,
      messageSequence: 1,
      actorType: ProjectEventActorType.user,
      content: 'Message from current profile',
      now: now,
      actorAvatarSnapshot: '/stale/user-avatar.png',
    );

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        locale: const Locale('zh', 'CN'),
        homeBuilder:
            (_) => Scaffold(
              body: ProjectEventList(
                events: <ProjectEvent>[event],
                turns: const <String, ProjectTurn>{},
                deliveries: const <String, AgentDelivery>{},
                runs: const <String, AgentRun>{},
                agentNames: const <String, String>{},
                currentUserProfile: _profile('我的名字', '', now),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    final avatar = tester.widget<ShadAvatar>(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('project-message-avatar-user-message'),
        ),
        matching: find.byType(ShadAvatar),
      ),
    );
    expect(avatar.src, 'assets/images/profile/avatar.png');
    expect(
      tester
          .widget<Text>(
            find.byKey(
              const ValueKey<String>('project-message-actor-user-message'),
            ),
          )
          .data,
      '我的名字',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'user avatar is right and agent avatar is left in shadcn layout',
    (tester) async {
      final now = DateTime.utc(2026, 8, 23);
      final avatarPath = File('assets/images/profile/avatar.png').absolute.path;
      final event = _message(
        id: 'current-message',
        turnId: 'current-turn',
        sequence: 1,
        messageSequence: 1,
        actorType: ProjectEventActorType.user,
        content: 'Current project message',
        now: now,
        actorAvatarSnapshot: '/stale/user-avatar.png',
      );
      final agentEvent = _message(
        id: 'agent-message',
        turnId: 'agent-turn',
        sequence: 2,
        messageSequence: 2,
        actorType: ProjectEventActorType.agent,
        content: 'Agent response',
        now: now,
        actorAvatarSnapshot: '/stale/agent-avatar.png',
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
                    agentsById: <String, Agent>{
                      'agent-1': _agent(
                        'agent-1',
                        'Researcher',
                        avatarPath,
                        now,
                      ),
                    },
                    currentUserProfile: _profile(
                      'Current User',
                      avatarPath,
                      now,
                    ),
                  ),
                ),
          ),
        );
        await tester.pumpAndSettle();

        final scrollConfigurationFinder = find.byKey(
          const ValueKey<String>('project-event-scroll-configuration'),
        );
        final scrollConfiguration = tester.widget<ScrollConfiguration>(
          scrollConfigurationFinder,
        );
        const scrollChild = SizedBox();
        final decoratedScrollChild = scrollConfiguration.behavior
            .buildScrollbar(
              tester.element(scrollConfigurationFinder),
              scrollChild,
              const ScrollableDetails(direction: AxisDirection.down),
            );
        expect(decoratedScrollChild, same(scrollChild));

        final bubbleFinder = find.byKey(
          const ValueKey<String>('project-message-bubble-current-message'),
        );
        final userCard = tester.widget<ShadCard>(
          find.descendant(of: bubbleFinder, matching: find.byType(ShadCard)),
        );
        final shadTheme = ShadTheme.of(tester.element(bubbleFinder));
        expect(
          userCard.backgroundColor,
          shadTheme.colorScheme.muted,
          reason: brightness.name,
        );
        expect(userCard.border, same(ShadBorder.none));
        expect(userCard.shadows, isEmpty, reason: brightness.name);

        final agentBubbleFinder = find.byKey(
          const ValueKey<String>('project-message-bubble-agent-message'),
        );
        final agentCard = tester.widget<ShadCard>(
          find.descendant(
            of: agentBubbleFinder,
            matching: find.byType(ShadCard),
          ),
        );
        expect(
          agentCard.backgroundColor,
          shadTheme.colorScheme.muted,
          reason: brightness.name,
        );
        expect(agentCard.border, same(ShadBorder.none));
        expect(agentCard.shadows, isEmpty, reason: brightness.name);

        final userMessage = find.byKey(
          const ValueKey<String>('project-actor-message-current-message'),
        );
        final agentMessage = find.byKey(
          const ValueKey<String>('project-actor-message-agent-message'),
        );
        final userEventFinder = find.byKey(
          const ValueKey<String>('project-event-current-message'),
        );
        final agentEventFinder = find.byKey(
          const ValueKey<String>('project-event-agent-message'),
        );
        final userAvatarFinder = find.byKey(
          const ValueKey<String>('project-message-avatar-current-message'),
        );
        final agentAvatarFinder = find.byKey(
          const ValueKey<String>('project-message-avatar-agent-message'),
        );
        final userAvatar = tester.widget<ShadAvatar>(
          find.descendant(
            of: userAvatarFinder,
            matching: find.byType(ShadAvatar),
          ),
        );
        final agentAvatar = tester.widget<ShadAvatar>(
          find.descendant(
            of: agentAvatarFinder,
            matching: find.byType(ShadAvatar),
          ),
        );
        final userName = find.byKey(
          const ValueKey<String>('project-message-actor-current-message'),
        );
        final agentName = find.byKey(
          const ValueKey<String>('project-message-actor-agent-message'),
        );
        expect(userAvatar.src, avatarPath);
        expect(userAvatar.size, const Size.square(40));
        expect(agentAvatar.src, avatarPath);
        expect(agentAvatar.size, const Size.square(40));
        expect(tester.widget<Text>(userName).data, 'Current User');
        expect(tester.widget<Text>(agentName).data, 'Researcher');
        expect(
          tester.widget<Text>(userName).style?.fontWeight,
          FontWeight.w600,
        );
        expect(
          tester.widget<Text>(agentName).style?.fontWeight,
          FontWeight.w600,
        );
        expect(
          find.descendant(of: userMessage, matching: userName),
          findsOneWidget,
        );
        expect(
          find.descendant(of: agentMessage, matching: agentName),
          findsOneWidget,
        );
        expect(
          find.descendant(of: bubbleFinder, matching: userName),
          findsNothing,
        );
        expect(
          find.descendant(of: agentBubbleFinder, matching: agentName),
          findsNothing,
        );
        expect(
          tester.getTopRight(userMessage).dx,
          tester.getTopRight(userEventFinder).dx,
        );
        expect(
          tester.getTopLeft(agentMessage).dx,
          tester.getTopLeft(agentEventFinder).dx,
        );
        expect(
          tester.getTopLeft(userMessage).dx,
          greaterThan(tester.getTopLeft(agentMessage).dx),
        );
        expect(
          tester.getTopRight(bubbleFinder).dx,
          lessThan(tester.getTopLeft(userAvatarFinder).dx),
        );
        expect(
          tester.getTopRight(agentAvatarFinder).dx,
          lessThan(tester.getTopLeft(agentBubbleFinder).dx),
        );
        expect(
          tester.getTopRight(userName).dx,
          tester.getTopRight(bubbleFinder).dx,
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

Agent _agent(String id, String name, String avatar, DateTime now) => Agent(
  id: id,
  name: name,
  avatar: avatar,
  provider: 'test',
  baseUrl: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: '',
  createdAt: now,
  updatedAt: now,
);

Profile _profile(String name, String avatar, DateTime now) => Profile(
  name: name,
  avatar: avatar,
  fontSize: 16,
  themeMode: 0,
  language: 'zh_CN',
  createTimestamp: now,
  modifyTimestamp: now,
);

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
  String actorAvatarSnapshot = '',
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
  actorAvatarSnapshot: actorAvatarSnapshot,
  replyToEventId: replyToEventId,
  replyToMessageSequence: replyToMessageSequence,
  content: content,
  payload: ProjectMessagePayload(),
  createdAt: now,
  updatedAt: now,
);
