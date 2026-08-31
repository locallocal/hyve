import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/views/project_event_list.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  testWidgets('reveals the time and copy action when hovering a message', (
    tester,
  ) async {
    final clipboardWrites = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') clipboardWrites.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final createdAt = DateTime(2026, 8, 31, 14, 5, 9);
    final event = _message(
      id: 'copyable-message',
      turnId: 'copyable-turn',
      sequence: 1,
      messageSequence: 1,
      actorType: ProjectEventActorType.user,
      content: '需要复制的项目消息',
      now: createdAt,
      updatedAt: createdAt.add(const Duration(minutes: 5)),
    );

    await withDesktopPlatform(() async {
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
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      final expectedTimestamp = intl.DateFormat.yMd(
        'zh_CN',
      ).add_Hms().format(createdAt);
      final timestampFinder = find.byKey(
        const ValueKey<String>('project-message-time-copyable-message'),
      );
      final metadataOpacityFinder = find.byKey(
        const ValueKey<String>(
          'project-message-metadata-opacity-copyable-message',
        ),
      );
      final copyAction = find.byKey(
        const ValueKey<String>('project-message-copy-copyable-message'),
      );
      final bubbleFinder = find.byKey(
        const ValueKey<String>('project-message-bubble-copyable-message'),
      );

      expect(tester.widget<Text>(timestampFinder).data, expectedTimestamp);
      expect(find.textContaining('写入于'), findsNothing);
      expect(
        find.descendant(of: bubbleFinder, matching: timestampFinder),
        findsNothing,
      );
      expect(tester.widget<AnimatedOpacity>(metadataOpacityFinder).opacity, 0);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(bubbleFinder));
      await tester.pumpAndSettle();

      expect(tester.widget<AnimatedOpacity>(metadataOpacityFinder).opacity, 1);
      expect(copyAction, findsOneWidget);
      expect(find.byIcon(LucideIcons.copy), findsOneWidget);
      expect(
        tester.getSemantics(copyAction),
        matchesSemantics(
          label: '复制',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedOpacity>(metadataOpacityFinder).opacity, 0);

      await mouse.moveTo(tester.getCenter(bubbleFinder));
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedOpacity>(metadataOpacityFinder).opacity, 1);

      await tester.tap(copyAction);
      await tester.pump();

      expect(clipboardWrites, hasLength(1));
      expect(clipboardWrites.single.arguments, <String, dynamic>{
        'text': '需要复制的项目消息',
      });
      expect(find.text('消息已复制到剪贴板'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

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

  testWidgets('timeline anchors user sends and follows new agent messages', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 8, 24);
    final initialEvents = <ProjectEvent>[
      for (var sequence = 2; sequence <= 13; sequence++)
        _message(
          id: 'event-$sequence',
          turnId: 'turn-$sequence',
          sequence: sequence,
          messageSequence: sequence,
          actorType: ProjectEventActorType.user,
          content: 'Project message $sequence',
          now: now.add(Duration(seconds: sequence)),
        ),
    ];
    final events = ValueNotifier<List<ProjectEvent>>(initialEvents);
    addTearDown(events.dispose);

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (_) => Scaffold(
              body: SizedBox(
                height: 240,
                child: ValueListenableBuilder<List<ProjectEvent>>(
                  valueListenable: events,
                  builder:
                      (_, value, _) => ProjectEventList(
                        events: value,
                        turns: const <String, ProjectTurn>{},
                        deliveries: const <String, AgentDelivery>{},
                        runs: const <String, AgentRun>{},
                        agentNames: const <String, String>{},
                      ),
                ),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    final timeline = find.byKey(
      const ValueKey<String>('project-event-timeline'),
    );
    final scrollable = find.descendant(
      of: timeline,
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(scrollable.first).position;
    expect(position.maxScrollExtent, greaterThan(0));
    expect(position.pixels, closeTo(position.minScrollExtent, 0.5));

    events.value = <ProjectEvent>[
      ...events.value,
      _message(
        id: 'event-14',
        turnId: 'turn-14',
        sequence: 14,
        messageSequence: 14,
        actorType: ProjectEventActorType.user,
        content: 'New user message',
        now: now.add(const Duration(seconds: 14)),
      ),
    ];
    await tester.pump();
    expect(position.pixels, closeTo(position.minScrollExtent, 0.5));
    expect(position.isScrollingNotifier.value, isFalse);
    await tester.pumpAndSettle();
    expect(position.pixels, closeTo(position.minScrollExtent, 0.5));

    position.jumpTo(position.maxScrollExtent);
    await tester.pump();
    final positionBeforeEarlierHistory = position.pixels;
    events.value = <ProjectEvent>[
      _message(
        id: 'event-1',
        turnId: 'turn-1',
        sequence: 1,
        messageSequence: 1,
        actorType: ProjectEventActorType.user,
        content: 'Earlier project message',
        now: now,
      ),
      ...events.value,
    ];
    await tester.pumpAndSettle();
    expect(position.pixels, closeTo(positionBeforeEarlierHistory, 0.5));

    events.value = <ProjectEvent>[
      ...events.value,
      _message(
        id: 'event-15',
        turnId: 'turn-15',
        sequence: 15,
        messageSequence: 15,
        actorType: ProjectEventActorType.agent,
        content: 'Latest agent response',
        now: now.add(const Duration(seconds: 15)),
      ),
    ];
    await tester.pumpAndSettle();
    expect(position.pixels, closeTo(position.minScrollExtent, 0.5));

    events.value = <ProjectEvent>[
      ...events.value.take(events.value.length - 1),
      _message(
        id: 'event-15',
        turnId: 'turn-15',
        sequence: 15,
        messageSequence: 15,
        actorType: ProjectEventActorType.agent,
        content: 'Latest agent response is still being generated',
        now: now.add(const Duration(seconds: 16)),
      ),
    ];
    await tester.pumpAndSettle();
    expect(position.pixels, closeTo(position.minScrollExtent, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'optimistic user message stays mounted when persistence finishes',
    (tester) async {
      final now = DateTime.utc(2026, 8, 31);
      final events = ValueNotifier<List<ProjectEvent>>(<ProjectEvent>[
        for (var sequence = 1; sequence <= 16; sequence++)
          _message(
            id: 'event-$sequence',
            turnId: 'turn-$sequence',
            sequence: sequence,
            messageSequence: sequence,
            actorType: ProjectEventActorType.user,
            content: 'Message $sequence',
            now: now.add(Duration(seconds: sequence)),
          ),
      ]);
      addTearDown(events.dispose);

      await tester.pumpWidget(
        shadHarness(
          brightness: Brightness.light,
          homeBuilder:
              (_) => Scaffold(
                body: SizedBox(
                  height: 240,
                  child: ValueListenableBuilder<List<ProjectEvent>>(
                    valueListenable: events,
                    builder:
                        (_, value, _) => ProjectEventList(
                          events: value,
                          turns: const <String, ProjectTurn>{},
                          deliveries: const <String, AgentDelivery>{},
                          runs: const <String, AgentRun>{},
                          agentNames: const <String, String>{},
                        ),
                  ),
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();
      final timeline = find.byKey(
        const ValueKey<String>('project-event-timeline'),
      );
      final scrollable = find.descendant(
        of: timeline,
        matching: find.byType(Scrollable),
      );
      final position = tester.state<ScrollableState>(scrollable.first).position;
      position.jumpTo(position.maxScrollExtent);

      final pending = _message(
        id: 'optimistic-event',
        turnId: 'optimistic-turn',
        sequence: 17,
        messageSequence: null,
        actorType: ProjectEventActorType.user,
        content: 'Optimistic message',
        now: now.add(const Duration(seconds: 17)),
        terminalState: ProjectEventTerminalState.draft,
      );
      events.value = <ProjectEvent>[...events.value, pending];
      await tester.pumpAndSettle();

      expect(position.pixels, closeTo(position.minScrollExtent, 0.5));
      expect(
        find.byKey(
          const ValueKey<String>('project-message-pending-optimistic-event'),
        ),
        findsOneWidget,
      );
      expect(find.text('Optimistic message'), findsOneWidget);

      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      events.value = <ProjectEvent>[
        ...events.value.take(events.value.length - 1),
        _message(
          id: pending.id,
          turnId: pending.turnId,
          sequence: 17,
          messageSequence: 17,
          actorType: ProjectEventActorType.user,
          content: pending.content,
          now: pending.createdAt,
        ),
      ];
      await tester.pumpAndSettle();

      expect(position.pixels, closeTo(position.maxScrollExtent, 0.5));
      expect(position.pixels, greaterThan(position.minScrollExtent));
      expect(
        tester.widget<ListView>(timeline).childrenDelegate.estimatedChildCount,
        events.value.length,
      );

      position.jumpTo(position.minScrollExtent);
      await tester.pump();
      expect(
        find.byKey(
          const ValueKey<String>('project-message-pending-optimistic-event'),
        ),
        findsNothing,
      );
      expect(find.text('Optimistic message'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

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

  testWidgets('loads older messages when the history edge is reached', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 8, 31);
    final events = <ProjectEvent>[
      for (var sequence = 1; sequence <= 16; sequence++)
        _message(
          id: 'event-$sequence',
          turnId: 'turn-$sequence',
          sequence: sequence,
          messageSequence: sequence,
          actorType: ProjectEventActorType.user,
          content: 'Message $sequence with enough content for the timeline',
          now: now.add(Duration(seconds: sequence)),
        ),
    ];
    var loadEarlierCalls = 0;

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (_) => Scaffold(
              body: SizedBox(
                height: 240,
                child: ProjectEventList(
                  events: events,
                  turns: const <String, ProjectTurn>{},
                  deliveries: const <String, AgentDelivery>{},
                  runs: const <String, AgentRun>{},
                  agentNames: const <String, String>{},
                  hasEarlier: true,
                  onLoadEarlier: () => loadEarlierCalls += 1,
                ),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    final timeline = find.byKey(
      const ValueKey<String>('project-event-timeline'),
    );
    final scrollable = find.descendant(
      of: timeline,
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(scrollable.first).position;
    expect(position.maxScrollExtent, greaterThan(240));
    expect(loadEarlierCalls, 0);

    position.jumpTo(position.maxScrollExtent);
    await tester.pump();

    expect(loadEarlierCalls, 1);
    expect(
      find.byKey(const ValueKey<String>('project-load-earlier-events')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('restores the cached timeline position', (tester) async {
    final now = DateTime.utc(2026, 8, 31);

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (_) => Scaffold(
              body: SizedBox(
                height: 240,
                child: ProjectEventList(
                  events: <ProjectEvent>[
                    for (var sequence = 1; sequence <= 16; sequence++)
                      _message(
                        id: 'cached-event-$sequence',
                        turnId: 'cached-turn-$sequence',
                        sequence: sequence,
                        messageSequence: sequence,
                        actorType: ProjectEventActorType.user,
                        content: 'Cached message $sequence',
                        now: now.add(Duration(seconds: sequence)),
                      ),
                  ],
                  turns: const <String, ProjectTurn>{},
                  deliveries: const <String, AgentDelivery>{},
                  runs: const <String, AgentRun>{},
                  agentNames: const <String, String>{},
                  initialScrollOffset: 320,
                ),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    final timeline = find.byKey(
      const ValueKey<String>('project-event-timeline'),
    );
    final scrollable = find.descendant(
      of: timeline,
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(scrollable.first).position;

    expect(position.maxScrollExtent, greaterThan(320));
    expect(position.pixels, closeTo(320, 0.5));
    expect(tester.takeException(), isNull);
  });
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
  required int? messageSequence,
  required ProjectEventActorType actorType,
  required String content,
  required DateTime now,
  DateTime? updatedAt,
  String replyToEventId = '',
  int? replyToMessageSequence,
  String actorAvatarSnapshot = '',
  ProjectEventTerminalState terminalState = ProjectEventTerminalState.completed,
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
  terminalState: terminalState,
  createdAt: now,
  updatedAt: updatedAt ?? now,
);
