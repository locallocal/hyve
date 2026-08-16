import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/l10n/app_localizations.dart';
import 'package:hyve/ui/features/app/views/desktop_layout.dart';
import 'package:hyve/utils/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final (width, sidebarDocked) in const [
    (959.0, false),
    (960.0, true),
    (961.0, true),
  ]) {
    testWidgets(
      'sidebar uses ${sidebarDocked ? 'dock' : 'sheet'} at ${width.toInt()}px',
      (tester) async {
        await _withDesktopPlatform(() async {
          await _pumpLayout(tester, width: width);

          final handle = find.byKey(
            const ValueKey<String>('desktop-sidebar-resize-handle'),
          );
          expect(handle, sidebarDocked ? findsOneWidget : findsNothing);

          await tester.tap(
            sidebarDocked
                ? find.byIcon(LucideIcons.panelLeftClose)
                : find.byKey(const ValueKey<String>('desktop-toolbar-sidebar')),
          );
          await tester.pumpAndSettle();

          expect(
            find.byType(ShadSheet),
            sidebarDocked ? findsNothing : findsOneWidget,
          );
          expect(handle, findsNothing);
          expect(tester.takeException(), isNull);
        });
      },
    );
  }

  for (final (width, expectedSidebarWidth) in const [
    (1199.0, '280 px'),
    (1200.0, '300 px'),
    (1201.0, '300 px'),
  ]) {
    testWidgets(
      'sidebar width is $expectedSidebarWidth at ${width.toInt()}px',
      (tester) async {
        await _withDesktopPlatform(() async {
          await _pumpLayout(tester, width: width);

          final handle = find.byKey(
            const ValueKey<String>('desktop-sidebar-resize-handle'),
          );
          final semantics = tester.widgetList<Semantics>(
            find.descendant(of: handle, matching: find.byType(Semantics)),
          );

          expect(handle, findsOneWidget);
          expect(
            semantics.any(
              (widget) => widget.properties.value == expectedSidebarWidth,
            ),
            isTrue,
          );
          expect(tester.takeException(), isNull);
        });
      },
    );
  }

  for (final (width, inspectorDocked) in const [
    (1499.0, false),
    (1500.0, true),
    (1501.0, true),
  ]) {
    testWidgets(
      'inspector uses ${inspectorDocked ? 'dock' : 'sheet'} at ${width.toInt()}px',
      (tester) async {
        await _withDesktopPlatform(() async {
          await _pumpLayout(tester, width: width, selectedChatBot: _bot);

          await tester.tap(
            find.byKey(const ValueKey<String>('desktop-toolbar-inspector')),
          );
          await tester.pumpAndSettle();

          final inspector = find.byKey(
            const PageStorageKey<String>('desktop-context-inspector'),
          );
          final inspectorSheet = find.ancestor(
            of: inspector,
            matching: find.byType(ShadSheet),
          );

          expect(inspector, findsOneWidget);
          expect(
            inspectorSheet,
            inspectorDocked ? findsNothing : findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        });
      },
    );
  }
}

Future<void> _withDesktopPlatform(Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.linux;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

Future<void> _pumpLayout(
  WidgetTester tester, {
  required double width,
  Bot? selectedChatBot,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 800);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_harness(selectedChatBot: selectedChatBot));
  await tester.pumpAndSettle();
}

Widget _harness({Bot? selectedChatBot}) {
  final shadTheme = buildHyveShadTheme(
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
            body: DesktopLayout(
              currentIndex: 0,
              onPageChanged: (_) {},
              pages: const [
                Center(child: Text('chat list')),
                Center(child: Text('bot list')),
                Center(child: Text('skills')),
                Center(child: Text('mcp servers')),
                Center(child: Text('profile')),
              ],
              selectedChatBot: selectedChatBot,
              onBotUpdated: (_) async {},
              onBotDeleted: () async {},
            ),
          ),
        ),
  );
}

final _bot = Bot(
  id: 'breakpoint-bot',
  name: 'Breakpoint Bot',
  avatar: '',
  provider: 'OpenAI',
  baseURL: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'gpt-test',
  systemPrompt: '',
  createTimestamp: DateTime.fromMillisecondsSinceEpoch(1),
  modifyTimestamp: DateTime.fromMillisecondsSinceEpoch(1),
);
