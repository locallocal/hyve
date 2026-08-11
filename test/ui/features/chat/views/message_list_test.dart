import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/l10n/app_localizations.dart';
import 'package:stars/ui/features/chat/views/message_list.dart';
import 'package:stars/utils/theme.dart';

void main() {
  testWidgets('message list starts at the latest lazily built messages', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 600);
    addTearDown(tester.view.reset);
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    final messages = [
      for (var index = 0; index < 500; index++)
        Message(
          messageId: 'message-$index',
          chatId: 'chat-1',
          botId: 'bot-1',
          senderId: 'bot-1',
          content: 'content-$index',
          timestamp: DateTime(2026).add(Duration(seconds: index)),
        ),
    ];

    await tester.pumpWidget(
      _messageListHarness(
        MessageList(
          messages: messages,
          scrollController: scrollController,
          isStreaming: false,
          streamingResponse: '',
          currentUserId: 'me',
        ),
      ),
    );
    await tester.pump();

    expect(tester.widget<ListView>(find.byType(ListView)).reverse, isTrue);
    expect(find.text('content-499'), findsOneWidget);
    expect(find.text('content-0'), findsNothing);
    expect(scrollController.offset, 0);
  });

  testWidgets('assistant code blocks copy only their command or code', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(600, 800);
    addTearDown(tester.view.reset);
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
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    final message = Message(
      messageId: 'assistant-code',
      chatId: 'chat-1',
      botId: 'bot-1',
      senderId: 'bot-1',
      content: '''Run the command:

```bash
flutter test test/widget_test.dart
```

Then use this code:

```dart
void main() => print('done');
```''',
      timestamp: DateTime(2026, 8, 11),
    );

    await tester.pumpWidget(
      _messageListHarness(
        MessageList(
          messages: [message],
          scrollController: scrollController,
          isStreaming: false,
          streamingResponse: '',
          currentUserId: 'me',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('bash'), findsOneWidget);
    expect(find.text('dart'), findsOneWidget);
    final copyButtons = find.byKey(
      const ValueKey<String>('message-code-copy-button'),
    );
    expect(copyButtons, findsNWidgets(2));

    await tester.tap(copyButtons.at(1));
    await tester.pump();

    expect(clipboardWrites, hasLength(1));
    expect(clipboardWrites.single.arguments, {
      'text': "void main() => print('done');",
    });
  });

  testWidgets('desktop reasoning icon rotates while the model is thinking', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(isStreaming: true));
    await tester.pump(const Duration(milliseconds: 200));

    final spinner = find.byKey(
      const ValueKey<String>('reasoning-streaming-spinner'),
    );
    expect(spinner, findsOneWidget);
    final initialTurns = tester.widget<RotationTransition>(spinner).turns.value;

    await tester.pump(const Duration(milliseconds: 225));

    final rotatedTurns = tester.widget<RotationTransition>(spinner).turns.value;
    expect(rotatedTurns, isNot(closeTo(initialTurns, 0.01)));
    expect(rotatedTurns, closeTo(0.25, 0.05));

    await tester.pumpWidget(_harness(isStreaming: false));
    await tester.pump();

    expect(spinner, findsNothing);
    expect(find.byIcon(LucideIcons.brain), findsOneWidget);
  });

  testWidgets('desktop reasoning icon respects disabled animations', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(isStreaming: true, disableAnimations: true),
    );
    await tester.pump(const Duration(milliseconds: 200));

    final spinner = find.byKey(
      const ValueKey<String>('reasoning-streaming-spinner'),
    );
    final initialTurns = tester.widget<RotationTransition>(spinner).turns.value;

    await tester.pump(const Duration(milliseconds: 225));

    expect(
      tester.widget<RotationTransition>(spinner).turns.value,
      initialTurns,
    );
  });
}

Widget _messageListHarness(Widget child) {
  return MaterialApp(
    locale: const Locale('zh', 'CN'),
    supportedLocales: supportedLocales,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ],
    home: Scaffold(body: Column(children: [child])),
  );
}

Widget _harness({required bool isStreaming, bool disableAnimations = false}) {
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
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(disableAnimations: disableAnimations),
                child: ShadAppBuilder(child: child!),
              ),
          home: Scaffold(
            body: ReasoningSection(
              reasoning: 'reasoning',
              isDesktop: true,
              isStreaming: isStreaming,
            ),
          ),
        ),
  );
}
