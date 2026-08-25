import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/use_cases/create_chat.dart';
import 'package:hyve/ui/features/app/views/desktop_layout.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/ui/features/bots/view_models/bot_list_view_model.dart';
import 'package:hyve/ui/features/bots/views/bots.dart';
import 'package:hyve/ui/features/chat/views/stop_generation_dialog.dart';
import 'package:hyve/ui/features/chats/view_models/chat_list_view_model.dart';
import 'package:hyve/ui/features/chats/views/chats.dart';
import 'package:hyve/ui/features/chats/views/chat_item.dart';
import 'package:hyve/utils/theme.dart';

import '../support/widget_test_support.dart';

void main() {
  testWidgets('Project actions share one desktop toolbar group', (
    tester,
  ) async {
    var members = 0;
    var artifacts = 0;
    var execution = 0;
    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (context) => Scaffold(
              body: Center(
                child: ProjectWorkspaceToolbarActions(
                  onShowMembers: () => members += 1,
                  onShowArtifacts: () => artifacts += 1,
                  onShowExecution: () => execution += 1,
                ),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    for (final key in const <String>[
      'project-members-button',
      'project-artifacts-button',
      'project-execution-button',
    ]) {
      expect(find.byKey(ValueKey<String>(key)), findsOneWidget);
      await tester.tap(find.byKey(ValueKey<String>(key)));
      await tester.pump();
    }

    expect((members, artifacts, execution), (1, 1, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop project toolbar exposes one shared project chat', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(tester.view.reset);
    final primary = _shellBot('project-primary', '研究员');
    final reviewer = _shellBot('project-reviewer', '审阅员');
    await withDesktopPlatform(() async {
      await tester.pumpWidget(
        desktopHarness(
          selectedChatBot: primary,
          selectedChatBots: [primary, reviewer],
          selectedProjectName: '发布项目',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('发布项目'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('desktop-project-agent-selector')),
        findsNothing,
      );
      expect(find.text('审阅员'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('desktop empty state renders without a card shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(brightness: Brightness.light, fontSize: 16),
        home: const Scaffold(
          body: DesktopEmptyStateCard(
            icon: Icons.forum_outlined,
            title: '尚未选择项目',
            description: '从侧边栏选择项目。',
          ),
        ),
      ),
    );

    expect(find.text('尚未选择项目'), findsOneWidget);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('desktop bot and chat empty states match Skill styling', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(tester.view.reset);

    final botRepository = BotCardTestBotRepository(const []);
    final botViewModel = BotListViewModel(
      botRepository: botRepository,
      createChat: CreateChat(chatRepository: BotCardTestChatRepository()),
      aiProviderRepository: UnusedAiProviderRepository(),
      attachmentRepository: UnusedAttachmentRepository(),
    );
    final chatViewModel = ChatListViewModel(
      chatRepository: BotCardTestChatRepository(),
      botRepository: botRepository,
    );
    addTearDown(botViewModel.dispose);
    addTearDown(chatViewModel.dispose);
    await botViewModel.load();
    await chatViewModel.load();

    await withDesktopPlatform(() async {
      await tester.pumpWidget(
        shadHarness(
          brightness: Brightness.light,
          homeBuilder:
              (context) => Scaffold(
                body: ContactsPage(
                  viewModel: botViewModel,
                  onBotSelected: (_) {},
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('没有可用的智能体'), findsOneWidget);
      final botEmptyStateFinder = find.byType(DesktopEmptyStateCard);
      final botEmptyState = tester.widget<DesktopEmptyStateCard>(
        botEmptyStateFinder,
      );
      expect(botEmptyState.icon, desktopBotIcon);
      expect(botEmptyState.imageAsset, isNull);
      expect(botEmptyState.supportingText, isNull);
      expect(
        find.descendant(
          of: botEmptyStateFinder,
          matching: find.byIcon(desktopBotIcon),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: botEmptyStateFinder, matching: find.byType(Image)),
        findsNothing,
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        shadHarness(
          brightness: Brightness.light,
          homeBuilder:
              (context) => Scaffold(
                body: ChatListPage(
                  viewModel: chatViewModel,
                  onProjectSelected: (_) {},
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('还没有项目记录'), findsOneWidget);
      final chatEmptyStateFinder = find.byType(DesktopEmptyStateCard);
      final chatEmptyState = tester.widget<DesktopEmptyStateCard>(
        chatEmptyStateFinder,
      );
      expect(chatEmptyState.icon, desktopProjectIcon);
      expect(chatEmptyState.imageAsset, isNull);
      expect(chatEmptyState.supportingText, isNull);
      expect(
        find.descendant(
          of: chatEmptyStateFinder,
          matching: find.byIcon(desktopProjectIcon),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: chatEmptyStateFinder, matching: find.byType(Image)),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('desktop home empty state has no duplicate new chat action', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.reset);

    await withDesktopPlatform(() async {
      await tester.pumpWidget(desktopHarness(onCreateChat: () {}));
      await tester.pumpAndSettle();

      final emptyState = find.byType(DesktopEmptyStateCard);
      expect(emptyState, findsOneWidget);
      final emptyStateImage = find.descendant(
        of: emptyState,
        matching: find.byType(Image),
      );
      final emptyStateImageClip = find.ancestor(
        of: emptyStateImage,
        matching: find.byType(ClipRRect),
      );
      expect(emptyStateImage, findsOneWidget);
      expect(emptyStateImageClip, findsOneWidget);
      expect(
        tester.widget<ClipRRect>(emptyStateImageClip).borderRadius,
        desktopAppIconBorderRadius(DesktopEmptyStateCard.imageSize),
      );
      expect(
        find.descendant(of: emptyState, matching: find.text('点击新建项目创建项目')),
        findsOneWidget,
      );
      expect(find.textContaining('聊天'), findsNothing);
      expect(
        find.byKey(const ValueKey<String>('desktop-toolbar-clear-chat')),
        findsNothing,
      );
      expect(
        find.descendant(of: emptyState, matching: find.byType(ShadButton)),
        findsNothing,
      );
    });
  });

  testWidgets('desktop selected chat has no clear-history action', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.reset);

    await withDesktopPlatform(() async {
      await tester.pumpWidget(desktopHarness(selectedChatId: 'chat-1'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('desktop-toolbar-clear-chat')),
        findsNothing,
      );
      expect(find.bySemanticsLabel('清空项目记录'), findsNothing);
    });
  });

  testWidgets('desktop project toolbar omits the agent information panel', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);
    final bot = Bot(
      id: 'bot-1',
      name: 'Researcher',
      avatar: '',
      provider: 'OpenAI',
      baseURL: 'https://example.invalid',
      apiKey: '',
      apiType: Bot.apiTypeOpenAI,
      model: 'gpt-test',
      systemPrompt: '',
      parameters: const {
        Bot.parameterInputModalities: ['text', 'image', 'audio'],
        Bot.parameterOutputModalities: ['text'],
      },
      createTimestamp: DateTime(2026),
      modifyTimestamp: DateTime(2026),
    );

    await withDesktopPlatform(() async {
      await tester.pumpWidget(desktopHarness(selectedChatBot: bot));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('desktop-toolbar-inspector')),
        findsNothing,
      );
      expect(
        find.byKey(const PageStorageKey<String>('desktop-context-inspector')),
        findsNothing,
      );
      expect(find.byType(ShadSheet), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('desktop stop generation dialog uses Shad alert actions', (
    tester,
  ) async {
    await withDesktopPlatform(() async {
      await tester.pumpWidget(
        shadHarness(
          brightness: Brightness.light,
          homeBuilder:
              (context) => Scaffold(
                body: ShadButton(
                  onPressed:
                      () => unawaited(
                        showStopGenerationBeforeLeavingDialog(context),
                      ),
                  child: const Text('打开停止生成弹窗'),
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('打开停止生成弹窗'));
      await tester.pumpAndSettle();

      expect(find.text('离开前停止生成？'), findsOneWidget);
      expect(find.text('已生成的部分回复会被保留。'), findsOneWidget);

      final cancelButtonFinder =
          find
              .ancestor(of: find.text('取消'), matching: find.byType(ShadButton))
              .first;
      final stopButtonFinder =
          find
              .ancestor(
                of: find.text('停止并继续'),
                matching: find.byType(ShadButton),
              )
              .first;
      final cancelButton = tester.widget<ShadButton>(cancelButtonFinder);
      final stopButton = tester.widget<ShadButton>(stopButtonFinder);

      expect(cancelButton.variant, ShadButtonVariant.outline);
      expect(cancelButton.autofocus, isFalse);
      expect(stopButton.variant, ShadButtonVariant.destructive);
      expect(stopButton.leading, isNull);

      await tester.tap(cancelButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('离开前停止生成？'), findsNothing);
    });
  });

  testWidgets('desktop sidebar keeps Skill and MCP entries under My', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.reset);

    for (final selectedPage in [1, 2, 3, 4]) {
      await tester.pumpWidget(desktopHarness(currentIndex: selectedPage));
      await tester.pumpAndSettle();

      final label = selectedPage == 1 ? '智能体' : '我的';
      final selectedButtonFinder =
          find
              .ancestor(of: find.text(label), matching: find.byType(ShadButton))
              .first;
      final selectedButton = tester.widget<ShadButton>(selectedButtonFinder);
      final selectedButtonContext = tester.element(selectedButtonFinder);

      expect(selectedButton.variant, ShadButtonVariant.primary);
      expect(
        selectedButton.backgroundColor,
        HyveDesktopThemeSpec.inactivePrimaryActionColor(selectedButtonContext),
      );
      expect(
        selectedButton.hoverBackgroundColor,
        selectedButton.backgroundColor,
      );
      expect(
        selectedButton.pressedBackgroundColor,
        selectedButton.backgroundColor,
      );
      final selectedForeground =
          ShadTheme.of(selectedButtonContext).colorScheme.primaryForeground;
      expect(selectedButton.foregroundColor, selectedForeground);
      expect(selectedButton.hoverForegroundColor, selectedForeground);
      expect(selectedButton.pressedForegroundColor, selectedForeground);

      final textFinder = find.text(label).first;
      final text = tester.widget<Text>(textFinder);
      final inheritedTextStyle =
          DefaultTextStyle.of(tester.element(textFinder)).style;
      expect(inheritedTextStyle.merge(text.style).color, selectedForeground);
      expect(
        tester.getSize(selectedButtonFinder).height,
        HyveDesktopThemeSpec.botFormFieldHeight,
      );
      expect(selectedButton.mainAxisAlignment, MainAxisAlignment.start);

      if (selectedPage == 1) {
        final newChatButtonFinder =
            find
                .ancestor(
                  of: find.byIcon(desktopProjectIcon),
                  matching: find.byType(ShadButton),
                )
                .first;
        final newChatButton = tester.widget<ShadButton>(newChatButtonFinder);
        final agentIcon = tester.widget<Icon>(
          find
              .descendant(
                of: selectedButtonFinder,
                matching: find.byIcon(LucideIcons.bot),
              )
              .first,
        );
        final newChatIcon = tester.widget<Icon>(
          find
              .descendant(
                of: newChatButtonFinder,
                matching: find.byIcon(desktopProjectIcon),
              )
              .first,
        );

        expect(
          tester.getSize(newChatButtonFinder).height,
          HyveDesktopThemeSpec.botFormFieldHeight,
        );
        expect(selectedButton.size, newChatButton.size);
        expect(selectedButton.expands, newChatButton.expands);
        expect(
          selectedButton.mainAxisAlignment,
          newChatButton.mainAxisAlignment,
        );
        expect(selectedButton.padding, newChatButton.padding);
        expect(selectedButton.gap, newChatButton.gap);
        expect(selectedButton.leading, isNull);
        expect(newChatButton.leading, isNull);
        expect(selectedButton.expands, isTrue);
        expect(agentIcon.size, newChatIcon.size);
      }

      final primaryNavigation = find.byKey(
        const ValueKey<String>('desktop-primary-navigation'),
      );
      expect(
        find.descendant(of: primaryNavigation, matching: find.text('技能')),
        findsNothing,
      );
      expect(
        find.descendant(of: primaryNavigation, matching: find.text('MCP 服务器')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: primaryNavigation,
          matching: find.byIcon(LucideIcons.wrench),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: primaryNavigation,
          matching: find.byIcon(LucideIcons.server),
        ),
        findsNothing,
      );
    }
  });

  testWidgets(
    'desktop primary navigation icons align with conversation avatars',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1440, 900);
      addTearDown(tester.view.reset);

      final timestamp = DateTime(2026);
      final bot = Bot(
        id: 'sidebar-alignment-bot',
        name: '对齐测试',
        avatar: '',
        provider: 'OpenAI',
        baseURL: '',
        apiKey: '',
        apiType: Bot.apiTypeOpenAI,
        model: 'gpt-test',
        systemPrompt: '',
        createTimestamp: timestamp,
        modifyTimestamp: timestamp,
      );

      await tester.pumpWidget(
        desktopHarness(
          onCreateChat: () {},
          chatListPage: DesktopListPanel(
            title: '',
            description: '',
            searchHintText: '搜索项目',
            onSearchChanged: (_) {},
            action: const SizedBox.shrink(),
            showHeader: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ChatListItem(
                bot: bot,
                lastMessage: '测试消息',
                timestamp: '刚刚',
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final conversationIconLeft =
          tester.getTopLeft(find.byType(ShadAvatar)).dx;
      for (final icon in [desktopProjectIcon, LucideIcons.bot]) {
        final iconFinder = find.byIcon(icon).first;
        final buttonFinder =
            find
                .ancestor(of: iconFinder, matching: find.byType(ShadButton))
                .first;
        final labelFinder =
            find
                .descendant(of: buttonFinder, matching: find.byType(Text))
                .first;
        expect(
          tester.getTopLeft(iconFinder).dx,
          closeTo(conversationIconLeft, 0.01),
        );
        expect(
          tester.getCenter(labelFinder).dx,
          closeTo(tester.getCenter(buttonFinder).dx, 0.01),
        );
      }
    },
  );

  testWidgets('desktop sidebar divider remains visible after resizing', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(desktopHarness(currentIndex: 4));
    await tester.pumpAndSettle();

    final handle = find.byKey(
      const ValueKey<String>('desktop-sidebar-resize-handle'),
    );
    expect(handle, findsOneWidget);
    final initialCenter = tester.getCenter(handle);

    await tester.drag(handle, const Offset(32, 0));
    await tester.pumpAndSettle();
    expect(tester.getCenter(handle).dx, greaterThan(initialCenter.dx));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    final divider = find.descendant(
      of: handle,
      matching: find.byType(ColoredBox),
    );
    expect(divider, findsOneWidget);
    expect(
      tester.widget<ColoredBox>(divider).color,
      ShadTheme.of(tester.element(handle)).colorScheme.border,
    );
  });

  testWidgets('desktop shell uses one toolbar and overlays sidebar at 800px', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 600);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(desktopHarness());
    await tester.pumpAndSettle();

    expect(find.text('文件'), findsNothing);
    expect(find.text('编辑'), findsNothing);
    expect(find.text('视图'), findsNothing);
    expect(find.text('帮助'), findsNothing);
    expect(find.text('Hyve'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('desktop-toolbar-sidebar')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hyve'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Hyve'), findsNothing);
  });

  testWidgets('desktop chat and bot list share toolbar geometry and divider', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.reset);
    const toolbarKey = ValueKey<String>('desktop-unified-toolbar');

    await tester.pumpWidget(desktopHarness());
    await tester.pumpAndSettle();

    final chatToolbarFinder = find.byKey(toolbarKey);
    final chatToolbar = tester.widget<Container>(chatToolbarFinder);
    final chatDecoration = chatToolbar.decoration! as BoxDecoration;
    final chatBorder = chatDecoration.border! as Border;
    final chatSize = tester.getSize(chatToolbarFinder);

    await tester.pumpWidget(desktopHarness(currentIndex: 1));
    await tester.pumpAndSettle();

    final botToolbarFinder = find.byKey(toolbarKey);
    final botToolbar = tester.widget<Container>(botToolbarFinder);
    final botDecoration = botToolbar.decoration! as BoxDecoration;
    final botBorder = botDecoration.border! as Border;
    final botSize = tester.getSize(botToolbarFinder);

    expect(chatSize.height, HyveDesktopThemeSpec.toolbarHeight);
    expect(chatSize, botSize);
    expect(chatDecoration.color, botDecoration.color);
    expect(chatBorder.bottom, botBorder.bottom);
    expect(chatBorder.bottom.width, 0);
    expect(chatBorder.bottom.style, BorderStyle.solid);
  });
}

Bot _shellBot(String id, String name) => Bot(
  id: id,
  name: name,
  avatar: '',
  provider: 'OpenAI',
  baseURL: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'gpt-test',
  systemPrompt: '',
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);
