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

  testWidgets(
    'bot can add only healthy MCP servers and control their enabled state',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Bot? saved;
      await tester.pumpWidget(
        _harness(
          bot: _bot(supportsMcp: true),
          servers: [
            _server(),
            _server(
              id: 'server-disconnected',
              name: 'Offline',
              status: McpConnectionStatus.disconnected,
            ),
            _server(id: 'server-disabled', name: 'Disabled', enabled: false),
          ],
          onSaved: (bot) async => saved = bot,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('bot-mcp-server-server-1')),
        findsNothing,
      );
      final addButton = find.byKey(
        const ValueKey<String>('add-bot-mcp-server'),
      );
      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('available-bot-mcp-server-server-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>(
            'available-bot-mcp-server-server-disconnected',
          ),
        ),
        findsNothing,
      );
      expect(
        find.byKey(
          const ValueKey<String>('available-bot-mcp-server-server-disabled'),
        ),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('select-bot-mcp-server-server-1')),
      );
      await tester.pumpAndSettle();

      final serverToggle = find.byKey(
        const ValueKey<String>('bot-mcp-server-toggle-server-1'),
      );
      expect(
        find.byKey(const ValueKey<String>('bot-mcp-server-server-1')),
        findsOneWidget,
      );
      expect(tester.widget<Switch>(serverToggle).value, isTrue);
      expect(find.text('已开启'), findsOneWidget);

      await tester.tap(serverToggle);
      await tester.pump();
      expect(tester.widget<Switch>(serverToggle).value, isFalse);
      expect(find.text('已关闭'), findsOneWidget);

      await tester.tap(find.text('保存修改'));
      await tester.pumpAndSettle();

      expect(saved?.configuredSupportsMcp, isTrue);
      expect(saved?.mcpServerIds, {'server-1'});
      expect(saved?.disabledMcpServerIds, {'server-1'});
      expect(saved?.enabledMcpServerIds, isEmpty);
    },
  );

  testWidgets('bot can remove an added MCP server', (tester) async {
    tester.view.physicalSize = const Size(900, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Bot? saved;
    await tester.pumpWidget(
      _harness(
        bot: _bot(
          supportsMcp: true,
          mcpServerIds: const {'server-1'},
          disabledMcpServerIds: const {'server-1'},
        ),
        servers: [_server()],
        onSaved: (bot) async => saved = bot,
      ),
    );
    await tester.pumpAndSettle();

    final removeButton = find.byKey(
      const ValueKey<String>('remove-bot-mcp-server-server-1'),
    );
    await tester.ensureVisible(removeButton);
    await tester.tap(removeButton);
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('bot-mcp-server-server-1')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('bot-mcp-none-added')),
      findsOneWidget,
    );

    await tester.tap(find.text('保存修改'));
    await tester.pumpAndSettle();

    expect(saved?.mcpServerIds, isEmpty);
    expect(saved?.disabledMcpServerIds, isEmpty);
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
      find.byKey(const ValueKey<String>('add-bot-mcp-server')),
      findsNothing,
    );
  });

  testWidgets('MCP-capable model can add a server while creating a bot', (
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

    final addButton = find.byKey(const ValueKey<String>('add-bot-mcp-server'));
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('select-bot-mcp-server-server-1')),
    );
    await tester.pumpAndSettle();

    final serverToggle = find.byKey(
      const ValueKey<String>('bot-mcp-server-toggle-server-1'),
    );
    expect(tester.widget<ShadSwitch>(serverToggle).value, isTrue);

    await tester.tap(find.byKey(const ValueKey<String>('add-bot-submit')));
    await tester.pumpAndSettle();

    expect(added?.configuredSupportsMcp, isTrue);
    expect(added?.mcpServerIds, {'server-1'});
    expect(added?.disabledMcpServerIds, isEmpty);
    expect(added?.enabledMcpServerIds, {'server-1'});
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

Bot _bot({
  required bool supportsMcp,
  Set<String> mcpServerIds = const {},
  Set<String> disabledMcpServerIds = const {},
}) => Bot(
  id: 'bot-1',
  name: 'Assistant',
  avatar: '',
  provider: 'OpenAI',
  baseURL: 'https://api.example.test',
  apiKey: 'secret',
  apiType: Bot.apiTypeOpenAI,
  model: 'test-model',
  systemPrompt: '',
  parameters: {
    Bot.parameterSupportsMcp: supportsMcp,
    Bot.parameterMcpServerIds: mcpServerIds.toList(),
    Bot.parameterDisabledMcpServerIds: disabledMcpServerIds.toList(),
  },
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);

McpServer _server({
  String id = 'server-1',
  String name = 'Docs',
  bool enabled = true,
  McpConnectionStatus status = McpConnectionStatus.connected,
}) => McpServer(
  id: id,
  name: name,
  namespace: id.replaceAll('-', '_'),
  endpoint: Uri.parse('https://mcp.example.test/$id'),
  enabled: enabled,
  status: status,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
