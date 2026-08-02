import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/l10n/app_localizations.dart';
import 'package:stars/ui/features/bots/views/add_bot.dart';
import 'package:stars/ui/features/bots/views/edit_bot.dart';
import 'package:stars/utils/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MCP-capable bot can select and save a configured server', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Bot? saved;
    await tester.pumpWidget(
      _harness(
        bot: _bot(supportsMcp: true),
        servers: [_server()],
        onSaved: (bot) async => saved = bot,
      ),
    );
    await tester.pumpAndSettle();

    final serverTile = find.byKey(
      const ValueKey<String>('bot-mcp-server-server-1'),
    );
    expect(serverTile, findsOneWidget);
    expect(tester.widget<CheckboxListTile>(serverTile).value, isFalse);

    await tester.ensureVisible(serverTile);
    await tester.tap(serverTile);
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(serverTile).value, isTrue);

    await tester.tap(find.text('保存修改'));
    await tester.pumpAndSettle();

    expect(saved?.configuredSupportsMcp, isTrue);
    expect(saved?.mcpServerIds, {'server-1'});
  });

  testWidgets('bot without MCP model support hides server selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        bot: _bot(supportsMcp: false),
        servers: [_server()],
        onSaved: (_) async {},
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('bot-mcp-server-server-1')),
      findsNothing,
    );
  });

  testWidgets('MCP-capable model enables server selection while creating bot', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Bot? added;
    await tester.pumpWidget(
      _addHarness(onAdded: (bot, _) async => added = bot, servers: [_server()]),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey<String>('add-bot-name')),
        matching: find.byType(EditableText),
      ),
      'Assistant',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey<String>('add-bot-api-key')),
        matching: find.byType(EditableText),
      ),
      'secret',
    );
    final modelField = find.byKey(const ValueKey<String>('add-bot-model'));
    await tester.ensureVisible(modelField);
    await tester.tap(
      find.descendant(
        of: modelField,
        matching: find.byIcon(Icons.refresh_rounded),
      ),
    );
    await tester.pumpAndSettle();

    final serverTile = find.byKey(
      const ValueKey<String>('bot-mcp-server-server-1'),
    );
    expect(serverTile, findsOneWidget);
    await tester.ensureVisible(serverTile);
    await tester.tap(serverTile);
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey<String>('add-bot-submit')));
    await tester.pumpAndSettle();

    expect(added?.configuredSupportsMcp, isTrue);
    expect(added?.mcpServerIds, {'server-1'});
  });
}

Widget _harness({
  required Bot bot,
  required List<McpServer> servers,
  required Future<void> Function(Bot) onSaved,
}) {
  return MaterialApp(
    locale: const Locale('zh', 'CN'),
    supportedLocales: supportedLocales,
    localizationsDelegates: const [
      GlobalShadLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ],
    home: EditBotPage(
      bot: bot,
      mcpServerLoader: () async => servers,
      onBotUpdated: onSaved,
      onBotDeleted: () async {},
    ),
  );
}

Widget _addHarness({
  required Future<void> Function(Bot, List<BotSkillBinding>) onAdded,
  required List<McpServer> servers,
}) {
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
          home: AddBotPage(
            embedded: true,
            botId: 'bot-new',
            modelLoader:
                (_) async => [
                  AiModelInfo(
                    modelId: 'mcp-model',
                    providerId: Bot.apiTypeOpenAI,
                    inputModalities: const [InputModality.text],
                    outputModalities: const [OutputModality.text],
                    supportsMcp: true,
                  ),
                ],
            mcpServerLoader: () async => servers,
            onBotAdded: onAdded,
          ),
        ),
  );
}

Bot _bot({required bool supportsMcp}) => Bot(
  id: 'bot-1',
  name: 'Assistant',
  avatar: '',
  provider: 'OpenAI',
  baseURL: 'https://api.example.test',
  apiKey: 'secret',
  apiType: Bot.apiTypeOpenAI,
  model: 'test-model',
  systemPrompt: '',
  parameters: {Bot.parameterSupportsMcp: supportsMcp},
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);

McpServer _server() => McpServer(
  id: 'server-1',
  name: 'Docs',
  namespace: 'docs',
  endpoint: Uri.parse('https://mcp.example.test'),
  enabled: true,
  status: McpConnectionStatus.connected,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
