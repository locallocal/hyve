import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/core/view_models/token_usage_timeline.dart';
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

  testWidgets('panel appends the shared daily usage bars', (tester) async {
    TokenUsageBucket? selectedBucket;
    final buckets = [
      TokenUsageBucket(
        start: DateTime(2026, 7, 24),
        usage: const ModelTokenUsage(totalTokens: 25),
      ),
      TokenUsageBucket(
        start: DateTime(2026, 7, 25),
        usage: const ModelTokenUsage(totalTokens: 75),
      ),
    ];

    await tester.pumpWidget(
      _Harness(
        width: 800,
        child: BotTokenUsagePanel(
          usage: const ModelTokenUsage(totalTokens: 100),
          conversationUsages: const [],
          dailyBuckets: buckets,
          visibleBuckets: buckets,
          onBucketSelected: (bucket) => selectedBucket = bucket,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('每日用量'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('bot-token-usage-timeline-divider')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('token-usage-bar-day-2026-07-24')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('token-usage-bar-day-2026-07-25')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('token-usage-chart-vertical')),
      findsOneWidget,
    );
    final tallestDailyBar = find.byKey(
      const ValueKey<String>('token-usage-bar-day-2026-07-25'),
    );
    expect(
      tester.getSize(tallestDailyBar).height,
      greaterThan(tester.getSize(tallestDailyBar).width),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('token-usage-bucket-day-2026-07-24')),
    );
    expect(selectedBucket?.start, DateTime(2026, 7, 24));
  });

  testWidgets('panel renders hourly usage as scrollable vertical bars', (
    tester,
  ) async {
    final hourlyBuckets = List<TokenUsageBucket>.generate(24, (hour) {
      return TokenUsageBucket(
        start: DateTime(2026, 7, 24, hour),
        usage: ModelTokenUsage(totalTokens: 24 - hour),
      );
    });

    await tester.pumpWidget(
      _Harness(
        width: 600,
        child: BotTokenUsagePanel(
          usage: const ModelTokenUsage(totalTokens: 300),
          conversationUsages: const [],
          dailyBuckets: [
            TokenUsageBucket(
              start: DateTime(2026, 7, 24),
              usage: const ModelTokenUsage(totalTokens: 300),
            ),
          ],
          visibleBuckets: hourlyBuckets,
          granularity: TokenUsageGranularity.hour,
          selectedDay: DateTime(2026, 7, 24),
          onShowDaily: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('小时用量'), findsOneWidget);
    final firstHourlyBar = find.byKey(
      const ValueKey<String>('token-usage-bar-hour-0'),
    );
    expect(firstHourlyBar, findsOneWidget);
    expect(
      tester.getSize(firstHourlyBar).height,
      greaterThan(tester.getSize(firstHourlyBar).width),
    );
    final verticalChart = find.byKey(
      const ValueKey<String>('token-usage-chart-vertical'),
    );
    final scrollable = find.descendant(
      of: verticalChart,
      matching: find.byType(Scrollable),
    );
    expect(scrollable, findsOneWidget);
    expect(
      tester.state<ScrollableState>(scrollable).position.maxScrollExtent,
      greaterThan(0),
    );
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
