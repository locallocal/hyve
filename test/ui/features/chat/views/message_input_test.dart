import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/l10n/app_localizations.dart';
import 'package:stars/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:stars/ui/features/chat/views/chat.dart';
import 'package:stars/ui/features/chat/views/message_input.dart';
import 'package:stars/domain/models/ai_models.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/utils/theme.dart';

void main() {
  testWidgets('generation error alert is compact and centers its message', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 720,
          child: ChatGenerationErrorAlert(
            error: '请求失败',
            isDesktop: true,
            onDismiss: _noop,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final alert = find.byKey(
      const ValueKey<String>('chat-generation-error-alert'),
    );
    final message = find.byKey(
      const ValueKey<String>('chat-generation-error-message'),
    );
    expect(alert, findsOneWidget);
    expect(find.byType(StarsInlineErrorAlert), findsOneWidget);
    expect(tester.getSize(alert).height, lessThanOrEqualTo(44));
    expect(
      tester.getCenter(message).dy,
      closeTo(tester.getCenter(alert).dy, 1),
    );
    expect(
      tester.getCenter(message).dx,
      closeTo(tester.getCenter(alert).dx, 1),
    );
    expect(
      tester.widget<ShadAlert>(alert).crossAxisAlignment,
      CrossAxisAlignment.center,
    );
  });

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

    testWidgets('does not expose a manual Skill picker', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await _pumpMessageInput(tester, controller: controller);

      expect(find.byIcon(LucideIcons.wrench), findsNothing);
      expect(find.text('技能'), findsNothing);
    });

    testWidgets('does not show model capability controls', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final provider = _FakeProvider(
        _bot,
        supportsWebSearch: true,
        supportsDeepThinking: true,
      );

      await _pumpMessageInput(
        tester,
        controller: controller,
        provider: provider,
      );

      expect(find.text('联网搜索'), findsNothing);
      expect(find.text('深度思考'), findsNothing);
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
      final sendIcon = find.descendant(
        of: sendButton,
        matching: find.byIcon(LucideIcons.send),
      );
      final sendSize = tester.getSize(sendButton);
      final sendCenter = tester.getCenter(sendButton);
      final sendIconSize = tester.getSize(sendIcon);

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
      final stopIcon = find.descendant(
        of: stopButton,
        matching: find.byKey(const ValueKey('desktop-stop-icon')),
      );
      final stopGlyph = find.descendant(
        of: stopIcon,
        matching: find.byKey(const ValueKey('desktop-stop-glyph')),
      );
      expect(stopIcon, findsOneWidget);
      expect(tester.getSize(stopIcon), sendIconSize);
      expect(sendIconSize, const Size.square(17));
      expect(tester.getSize(stopGlyph), const Size.square(15));

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

Widget _harness(Widget child) {
  final shadTheme = buildStarsShadTheme(
    brightness: Brightness.light,
    fontSize: 16,
  );
  return ShadApp.custom(
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
          home: Scaffold(
            body: Align(alignment: Alignment.topCenter, child: child),
          ),
        ),
  );
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

class _FakeProvider extends AiProvider {
  _FakeProvider(
    super.bot, {
    this.supportsWebSearch = false,
    this.supportsDeepThinking = false,
  });

  final bool supportsWebSearch;
  final bool supportsDeepThinking;

  @override
  bool supportWebSearch() => supportsWebSearch;

  @override
  bool supportDeepThinking() => supportsDeepThinking;

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
