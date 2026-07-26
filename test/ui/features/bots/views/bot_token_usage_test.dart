import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/features/bots/view_models/bot_token_usage_view_model.dart';
import 'package:stars/ui/features/bots/views/bot_token_usage.dart';

void main() {
  testWidgets('desktop panel shows summary and conversation pie side by side', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const _Harness(
        width: 800,
        child: BotTokenUsagePanel(
          usage: ModelTokenUsage(
            inputTokens: 80,
            outputTokens: 20,
            totalTokens: 100,
          ),
          conversationUsages: [
            BotConversationTokenUsage(
              chatId: 'chat-large',
              preview: '第一段会话',
              usage: ModelTokenUsage(totalTokens: 75),
            ),
            BotConversationTokenUsage(
              chatId: 'chat-small',
              preview: '第二段会话',
              usage: ModelTokenUsage(totalTokens: 25),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final summary = find.byKey(
      const ValueKey<String>('bot-token-usage-summary'),
    );
    final chart = find.byKey(
      const ValueKey<String>('bot-conversation-token-share'),
    );
    expect(
      find.byKey(const ValueKey<String>('bot-token-usage-two-columns')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('bot-conversation-token-pie-chart')),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(summary).dx,
      lessThan(tester.getTopLeft(chart).dx),
    );
    expect(find.text('第一段会话'), findsOneWidget);
    expect(find.text('第二段会话'), findsOneWidget);
    expect(find.text('75.0%'), findsOneWidget);
    expect(find.text('25.0%'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'会话 Token 占比, 第一段会话 75\.0%, 第二段会话 25\.0%')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('panel stacks when its parent is too narrow', (tester) async {
    await tester.pumpWidget(
      const _Harness(
        width: 600,
        child: BotTokenUsagePanel(
          usage: ModelTokenUsage(totalTokens: 10),
          conversationUsages: [
            BotConversationTokenUsage(
              chatId: 'chat-1',
              preview: '',
              usage: ModelTokenUsage(totalTokens: 10),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final summary = find.byKey(
      const ValueKey<String>('bot-token-usage-summary'),
    );
    final chart = find.byKey(
      const ValueKey<String>('bot-conversation-token-share'),
    );
    expect(
      find.byKey(const ValueKey<String>('bot-token-usage-stacked')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('bot-conversation-token-pie-chart')),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(summary).dy,
      lessThan(tester.getTopLeft(chart).dy),
    );
    expect(find.text('聊天 1'), findsOneWidget);
    expect(find.text('100.0%'), findsOneWidget);
  });
}

class _Harness extends StatelessWidget {
  const _Harness({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('zh', 'CN'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: child),
        ),
      ),
    );
  }
}
