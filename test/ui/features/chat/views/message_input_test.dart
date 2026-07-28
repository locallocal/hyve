import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/l10n/app_localizations.dart';
import 'package:stars/ui/features/chat/views/message_input.dart';
import 'package:stars/domain/models/ai_models.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/utils/theme.dart';

void main() {
  group('desktop MessageInput', () {
    testWidgets('does not show provider or model metadata', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await _pumpMessageInput(tester, controller: controller);

      expect(find.text('test · test-model'), findsNothing);
      expect(find.text('test-model'), findsNothing);
    });

    testWidgets('empty input keeps send disabled', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      var sendCalls = 0;

      await _pumpMessageInput(
        tester,
        controller: controller,
        onSend: () => sendCalls += 1,
      );

      final sendButton = find.widgetWithText(ShadButton, '发送');
      expect(sendButton, findsOneWidget);
      final button = tester.widget<ShadButton>(sendButton);
      final sendButtonContext = tester.element(sendButton);
      expect(
        button.backgroundColor,
        DesktopThemeTokens.primaryActionColor(sendButtonContext),
      );
      expect(
        DesktopThemeTokens.inactivePrimaryActionColor(sendButtonContext),
        button.backgroundColor?.withValues(alpha: 0.5),
      );
      expect(
        tester
            .widgetList<Opacity>(
              find.descendant(of: sendButton, matching: find.byType(Opacity)),
            )
            .any((widget) => widget.opacity == 0.5),
        isTrue,
      );
      expect(button.enabled, isFalse);
      expect(button.onPressed, isNull);

      await tester.tap(sendButton, warnIfMissed: false);
      await tester.pump();
      expect(sendCalls, 0);
    });

    testWidgets('plain Enter sends the current message', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      var sendCalls = 0;

      await _pumpMessageInput(
        tester,
        controller: controller,
        onSend: () => sendCalls += 1,
      );
      await _focusAndEnterText(tester, 'Hello');

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(sendCalls, 1);
    });

    testWidgets('Skill picker exposes bound Skills and reports selection', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final toggledSkillIds = <String>[];

      await _pumpMessageInput(
        tester,
        controller: controller,
        availableSkills: [_skill()],
        onSkillToggled: toggledSkillIds.add,
      );

      expect(find.byIcon(LucideIcons.wrench), findsOneWidget);
      await tester.tap(find.text('技能'));
      await tester.pumpAndSettle();
      expect(find.text('release-notes'), findsOneWidget);

      await tester.tap(find.text('release-notes'));
      await tester.pump();

      expect(toggledSkillIds, ['user:release-notes']);
    });

    testWidgets('Skill picker aligns selection at right and spaces items', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final firstSkill = _skill();
      final secondSkill = _skill(
        id: 'user:weekly-summary',
        name: 'weekly-summary',
      );

      await _pumpMessageInput(
        tester,
        controller: controller,
        availableSkills: [firstSkill, secondSkill],
        selectedSkillIds: {firstSkill.id},
      );

      await tester.tap(find.text('技能 1'));
      await tester.pumpAndSettle();

      final firstItem = find.ancestor(
        of: find.text(firstSkill.name),
        matching: find.byType(ShadButton),
      );
      final secondItem = find.ancestor(
        of: find.text(secondSkill.name),
        matching: find.byType(ShadButton),
      );
      final firstRect = tester.getRect(firstItem);
      final secondRect = tester.getRect(secondItem);
      final checkRect = tester.getRect(find.byIcon(LucideIcons.check));

      expect(firstRect.width, 300);
      expect(firstRect.right - checkRect.right, 8);
      expect(secondRect.top - firstRect.bottom, 4);
    });

    testWidgets('web search mirrors empty and ready send button styles', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final provider = _FakeProvider(_bot, supportsWebSearch: true);

      await _pumpMessageInput(
        tester,
        controller: controller,
        provider: provider,
      );

      ShadButton button(String label) =>
          tester.widget<ShadButton>(find.widgetWithText(ShadButton, label));

      Opacity webSearchOpacity() => tester.widget<Opacity>(
        find
            .ancestor(
              of: find.widgetWithText(ShadButton, '联网搜索'),
              matching: find.byType(Opacity),
            )
            .first,
      );

      var sendButton = button('发送');
      var webSearchButton = button('联网搜索');
      expect(sendButton.enabled, isFalse);
      expect(webSearchButton.variant, ShadButtonVariant.primary);
      expect(webSearchButton.backgroundColor, sendButton.backgroundColor);
      expect(webSearchButton.hoverBackgroundColor, sendButton.backgroundColor);
      expect(
        webSearchButton.pressedBackgroundColor,
        sendButton.backgroundColor,
      );
      expect(webSearchOpacity().opacity, 0.5);
      expect(
        tester.getSize(find.widgetWithText(ShadButton, '联网搜索')).height,
        36,
      );

      await tester.tap(find.widgetWithText(ShadButton, '联网搜索'));
      await tester.pump();
      await _focusAndEnterText(tester, 'Hello');

      sendButton = button('发送');
      webSearchButton = button('联网搜索');
      expect(provider.getWebSearch(), isTrue);
      expect(sendButton.enabled, isTrue);
      expect(webSearchButton.variant, sendButton.variant);
      expect(webSearchButton.backgroundColor, sendButton.backgroundColor);
      expect(webSearchButton.foregroundColor, sendButton.foregroundColor);
      expect(webSearchButton.hoverBackgroundColor, isNull);
      expect(webSearchOpacity().opacity, 1);
    });

    testWidgets('Shift+Enter does not send', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      var sendCalls = 0;

      await _pumpMessageInput(
        tester,
        controller: controller,
        onSend: () => sendCalls += 1,
      );
      await _focusAndEnterText(tester, 'First line');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(sendCalls, 0);
      expect(controller.text, startsWith('First line'));
    });

    testWidgets('Enter cannot submit again while a request is in progress', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Already submitted');
      addTearDown(controller.dispose);
      var sendCalls = 0;
      var cancelCalls = 0;

      await _pumpMessageInput(
        tester,
        controller: controller,
        requestInProgress: true,
        canCancel: true,
        onSend: () => sendCalls += 1,
        onCancel: () => cancelCalls += 1,
      );
      await tester.tap(find.byType(ShadTextarea));

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(sendCalls, 0);
      expect(cancelCalls, 0);
      expect(find.widgetWithText(ShadButton, '停止'), findsOneWidget);
    });

    testWidgets('cancellable request swaps send for a same-size stop action', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Ready');
      addTearDown(controller.dispose);
      var sendCalls = 0;
      var cancelCalls = 0;

      await _pumpMessageInput(
        tester,
        controller: controller,
        onSend: () => sendCalls += 1,
        onCancel: () => cancelCalls += 1,
      );
      final sendButton = find.widgetWithText(ShadButton, '发送');
      final sendSize = tester.getSize(sendButton);
      final sendCenter = tester.getCenter(sendButton);

      await _pumpMessageInput(
        tester,
        controller: controller,
        requestInProgress: true,
        canCancel: true,
        onSend: () => sendCalls += 1,
        onCancel: () => cancelCalls += 1,
      );

      final stopButton = find.widgetWithText(ShadButton, '停止');
      expect(stopButton, findsOneWidget);
      expect(tester.getSize(stopButton), sendSize);
      expect(tester.getCenter(stopButton), sendCenter);
      expect(tester.getSize(stopButton), const Size(96, 36));

      await tester.tap(stopButton);
      await tester.pump();

      expect(cancelCalls, 1);
      expect(sendCalls, 0);
    });

    testWidgets('request status actions expand without overflowing', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Ready');
      addTearDown(controller.dispose);

      await _pumpMessageInput(
        tester,
        controller: controller,
        requestInProgress: true,
      );

      final generatingButton = find.widgetWithText(ShadButton, '正在生成…');
      expect(generatingButton, findsOneWidget);
      expect(tester.getSize(generatingButton).width, greaterThan(96));
      expect(tester.takeException(), isNull);

      await _pumpMessageInput(
        tester,
        controller: controller,
        requestInProgress: true,
        canCancel: true,
        isStopping: true,
      );

      final stoppingButton = find.widgetWithText(ShadButton, '正在停止…');
      expect(stoppingButton, findsOneWidget);
      expect(tester.getSize(stoppingButton).width, greaterThan(96));
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _pumpMessageInput(
  WidgetTester tester, {
  required TextEditingController controller,
  bool requestInProgress = false,
  bool canCancel = false,
  bool isStopping = false,
  AiProvider? provider,
  VoidCallback? onSend,
  VoidCallback? onCancel,
  List<SkillDescriptor> availableSkills = const [],
  Set<String> selectedSkillIds = const {},
  bool Function(String skillId)? isSkillAlways,
  ValueChanged<String>? onSkillToggled,
}) async {
  final shadTheme = buildStarsShadTheme(
    brightness: Brightness.light,
    fontSize: 16,
  ).copyWith(
    tooltipTheme: const ShadTooltipTheme(
      waitDuration: Duration.zero,
      showDuration: Duration.zero,
      duration: Duration.zero,
      reverseDuration: Duration.zero,
      effects: [],
    ),
  );

  await tester.pumpWidget(
    ShadApp.custom(
      themeMode: ThemeMode.light,
      theme: shadTheme,
      appBuilder:
          (shadContext) => MaterialApp(
            theme: buildShadMaterialBridgeTheme(
              context: shadContext,
              fontSize: 16,
            ),
            locale: const Locale('zh', 'CN'),
            supportedLocales: supportedLocales,
            localizationsDelegates: const [
              GlobalShadLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              S.delegate,
            ],
            builder: (context, child) => ShadAppBuilder(child: child!),
            home: Builder(
              builder:
                  (context) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: const Size(1000, 800),
                      disableAnimations: true,
                    ),
                    child: Scaffold(
                      body: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: 700,
                          child: MessageInput(
                            provider: provider ?? _FakeProvider(_bot),
                            controller: controller,
                            requestInProgress: requestInProgress,
                            canCancel: canCancel,
                            isStopping: isStopping,
                            desktopMode: true,
                            onCameraPressed: _noop,
                            onGalleryPressed: _noop,
                            onFilePressed: _noop,
                            onImageSizeSelected: _ignoreString,
                            onImageStyleSelected: _ignoreString,
                            onVideoRatioSelected: _ignoreString,
                            onSend: onSend ?? _noop,
                            onCancelRequest: onCancel ?? _noop,
                            availableSkills: availableSkills,
                            selectedSkillIds: selectedSkillIds,
                            isSkillAlways: isSkillAlways,
                            onSkillToggled: onSkillToggled,
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _focusAndEnterText(WidgetTester tester, String text) async {
  final textarea = find.byType(ShadTextarea);
  expect(textarea, findsOneWidget);
  await tester.tap(textarea);
  await tester.enterText(textarea, text);
  await tester.pump();
}

void _noop() {}

void _ignoreString(String _) {}

SkillDescriptor _skill({
  String id = 'user:release-notes',
  String name = 'release-notes',
}) {
  final timestamp = DateTime(2026, 7, 26);
  return SkillDescriptor(
    id: id,
    name: name,
    description: 'Prepare concise release notes.',
    version: '1.0.0',
    scope: SkillScope.user,
    sourceUri: 'file:///release-notes',
    rootPath: '/skills/release-notes',
    contentDigest: 'abc123',
    trustState: SkillTrustState.userReviewed,
    validationStatus: SkillValidationStatus.valid,
    compatibility: '',
    installedAt: timestamp,
    updatedAt: timestamp,
  );
}

class _FakeProvider extends AiProvider {
  _FakeProvider(super.bot, {this.supportsWebSearch = false});

  final bool supportsWebSearch;

  @override
  bool supportWebSearch() => supportsWebSearch;

  @override
  Future<void> generateText(List<ChatMessage> messages) async {}
}

final _bot = Bot(
  id: 'bot-1',
  name: 'Test bot',
  avatar: '',
  provider: 'test',
  baseURL: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'test-model',
  systemPrompt: '',
  createTimestamp: DateTime.fromMillisecondsSinceEpoch(1),
  modifyTimestamp: DateTime.fromMillisecondsSinceEpoch(1),
);
