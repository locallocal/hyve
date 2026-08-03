import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/l10n/app_localizations.dart';
import 'package:stars/ui/features/chat/views/message_list.dart';
import 'package:stars/utils/theme.dart';

void main() {
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
