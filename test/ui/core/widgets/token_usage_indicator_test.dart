import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/ui/core/widgets/token_usage_indicator.dart';

void main() {
  testWidgets('compact token usage renders an icon, total, and semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const _Harness(
        child: TokenUsageIndicator(
          usage: ModelTokenUsage(
            inputTokens: 1200,
            outputTokens: 300,
            totalTokens: 1500,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('token-usage-indicator')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.data_usage_rounded), findsOneWidget);
    expect(find.text('1.5K'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Token usage: Total tokens 1500, Input tokens 1200, '
        'Output tokens 300',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('breakdown uses one icon-led metric per token category', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _Harness(
        child: TokenUsageIndicator(
          usage: ModelTokenUsage(inputTokens: 80, outputTokens: 20),
          showBreakdown: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('token-usage-breakdown')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.data_usage_rounded), findsOneWidget);
    expect(find.byIcon(Icons.login_rounded), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
  });
}

class _Harness extends StatelessWidget {
  const _Harness({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );
  }
}
