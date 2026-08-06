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

  testWidgets('existing bot enables an MCP Tool without confirmation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Bot? saved;
    await tester.pumpWidget(
      _editHarness(
        bot: _bot(supportsMcp: true),
        onSaved: (bot) async => saved = bot,
      ),
    );
    await tester.pumpAndSettle();

    final toolToggle = find.byKey(
      const ValueKey<String>('bot-mcp-tool-toggle-server-1-search'),
    );
    await tester.ensureVisible(toolToggle);
    expect(tester.widget<Switch>(toolToggle).value, isFalse);
    await tester.tap(toolToggle);
    await tester.pump();

    final noApprovalToggle = find.byKey(
      const ValueKey<String>('bot-mcp-tool-no-approval-server-1-search'),
    );
    expect(tester.widget<Switch>(noApprovalToggle).value, isFalse);
    await tester.tap(noApprovalToggle);
    await tester.pump();

    await tester.ensureVisible(find.text('保存修改'));
    await tester.tap(find.text('保存修改'));
    await tester.pumpAndSettle();

    expect(saved?.configuredSupportsMcp, isTrue);
    expect(saved?.mcpTools, {
      McpToolConfiguration(
        serverId: 'server-1',
        remoteName: 'search',
        requiresApproval: false,
      ),
    });
  });

  testWidgets('existing bot can disable a configured MCP Tool', (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Bot? saved;
    await tester.pumpWidget(
      _editHarness(
        bot: _bot(
          supportsMcp: true,
          tools: {
            McpToolConfiguration(serverId: 'server-1', remoteName: 'search'),
          },
        ),
        onSaved: (bot) async => saved = bot,
      ),
    );
    await tester.pumpAndSettle();

    final toolToggle = find.byKey(
      const ValueKey<String>('bot-mcp-tool-toggle-server-1-search'),
    );
    await tester.ensureVisible(toolToggle);
    expect(tester.widget<Switch>(toolToggle).value, isTrue);
    await tester.tap(toolToggle);
    await tester.pump();

    await tester.ensureVisible(find.text('保存修改'));
    await tester.tap(find.text('保存修改'));
    await tester.pumpAndSettle();

    expect(saved?.mcpTools, isEmpty);
  });

  testWidgets('bot without MCP model support hides Tool configuration', (
    tester,
  ) async {
    await tester.pumpWidget(
      _editHarness(bot: _bot(supportsMcp: false), onSaved: (_) async {}),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('bot-mcp-tool-toggle-server-1-search')),
      findsNothing,
    );
  });

  testWidgets('read-only bot details disable MCP Tool changes', (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Bot? saved;
    await tester.pumpWidget(
      _editHarness(
        bot: _bot(supportsMcp: true),
        readOnly: true,
        onSaved: (bot) async => saved = bot,
      ),
    );
    await tester.pumpAndSettle();

    final toolToggle = find.byKey(
      const ValueKey<String>('bot-mcp-tool-toggle-server-1-search'),
    );
    await tester.ensureVisible(toolToggle);
    expect(tester.widget<Switch>(toolToggle).onChanged, isNull);
    await tester.tap(toolToggle, warnIfMissed: false);
    await tester.pump();

    expect(tester.widget<Switch>(toolToggle).value, isFalse);
    expect(find.text('保存修改'), findsNothing);
    expect(saved, isNull);
  });

  testWidgets('a bot is created without MCP Tool configuration', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Bot? added;
    await tester.pumpWidget(
      _addHarness(onAdded: (bot, _) async => added = bot),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('bot-mcp-tools-empty')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('bot-mcp-tool-toggle-server-1-search')),
      findsNothing,
    );

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
    await tester.tap(find.byKey(const ValueKey<String>('add-bot-submit')));
    await tester.pumpAndSettle();

    expect(added?.mcpTools, isEmpty);
  });
}

Widget _editHarness({
  required Bot bot,
  required Future<void> Function(Bot) onSaved,
  bool readOnly = false,
}) {
  final server = _server();
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
      readOnly: readOnly,
      mcpCatalogLoader:
          () async => (
            servers: [server],
            toolsByServer: {
              server.id: [_tool(server)],
            },
          ),
      onBotUpdated: onSaved,
      onBotDeleted: () async {},
    ),
  );
}

Widget _addHarness({
  required Future<void> Function(Bot, List<BotSkillBinding>) onAdded,
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
            onBotAdded: onAdded,
          ),
        ),
  );
}

Bot _bot({
  required bool supportsMcp,
  Set<McpToolConfiguration> tools = const {},
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
    Bot.parameterMcpTools: [
      for (final configuration in tools) configuration.toMap(),
    ],
  },
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);

McpServer _server() => McpServer(
  id: 'server-1',
  name: 'Docs',
  namespace: 'docs',
  transport: McpStreamableHttpServerTransport(
    endpoint: Uri.parse('https://mcp.example.test/docs'),
  ),
  status: McpConnectionStatus.connected,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

McpToolDescriptor _tool(McpServer server) => McpToolDescriptor(
  serverId: server.id,
  namespace: server.namespace,
  remoteName: 'search',
  title: 'Search',
  description: 'Search documentation.',
  inputSchema: const {'type': 'object'},
  updatedAt: DateTime(2026),
);
