import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/data/services/mcp/mcp_catalog_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/mcp_client.dart';
import 'package:stars/domain/repositories/mcp_credential_store.dart';
import 'package:stars/domain/repositories/mcp_server_repository.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/l10n/app_localizations.dart';
import 'package:stars/ui/features/mcp/view_models/mcp_servers_view_model.dart';
import 'package:stars/ui/features/mcp/views/mcp_servers_page.dart';
import 'package:stars/utils/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('desktop MCP page matches the Skill page content alignment', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;

    final repository = _FakeMcpServerRepository();
    final viewModel = McpServersViewModel(
      repository: repository,
      credentialStore: const _UnusedCredentialStore(),
      catalogService: McpCatalogService(
        repository: repository,
        client: const _UnusedMcpClient(),
        toolRegistry: DynamicToolRegistry(const []),
      ),
    );
    addTearDown(viewModel.dispose);

    try {
      await tester.pumpWidget(_harness(viewModel));
      await tester.pumpAndSettle();

      final content = find.byKey(
        const ValueKey<String>('mcp-servers-desktop-content'),
      );
      expect(content, findsOneWidget);
      expect(tester.getSize(content).width, 920);
      expect(tester.getTopLeft(content), const Offset(240, 28));
      expect(find.text('MCP 服务器'), findsOneWidget);
      expect(find.text('添加 MCP 服务器'), findsNWidgets(2));
      expect(
        find.byKey(const ValueKey<String>('add-mcp-server-desktop')),
        findsOneWidget,
      );
      final searchField = find.byKey(
        const ValueKey<String>('mcp-search-field'),
      );
      final securityAlert = find.ancestor(
        of: find.text('本地进程安全'),
        matching: find.byType(ShadAlert),
      );
      expect(searchField, findsOneWidget);
      expect(tester.getSize(searchField).width, 920);
      expect(
        tester.getTopLeft(searchField).dy,
        greaterThan(tester.getBottomLeft(securityAlert).dy),
      );
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('desktop MCP cards show Tool counts and details in a dialog', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;

    final now = DateTime.utc(2026, 7, 30);
    final servers = [
      McpServer(
        id: 'github',
        name: 'GitHub',
        namespace: 'github',
        endpoint: Uri.parse('https://example.com/github/mcp'),
        status: McpConnectionStatus.connected,
        createdAt: now,
        updatedAt: now,
      ),
      McpServer(
        id: 'filesystem',
        name: 'Filesystem',
        namespace: 'files',
        transportType: McpTransportType.stdio,
        command: 'npx',
        arguments: const ['-y', '@example/filesystem-mcp'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
    final repository = _FakeMcpServerRepository(
      servers: servers,
      toolsByServer: {
        'github': [
          McpToolDescriptor(
            serverId: 'github',
            namespace: 'github',
            remoteName: 'search_issues',
            title: '搜索议题',
            description: '搜索仓库中的议题。',
            inputSchema: const {
              'type': 'object',
              'properties': <String, Object?>{},
            },
            enabled: true,
            updatedAt: now,
          ),
        ],
        'filesystem': [
          McpToolDescriptor(
            serverId: 'filesystem',
            namespace: 'files',
            remoteName: 'read_file',
            title: '读取文件',
            description: '读取工作区中的文件。',
            inputSchema: const {
              'type': 'object',
              'properties': <String, Object?>{},
            },
            updatedAt: now,
          ),
        ],
      },
    );
    final viewModel = McpServersViewModel(
      repository: repository,
      credentialStore: const _UnusedCredentialStore(),
      catalogService: McpCatalogService(
        repository: repository,
        client: const _UnusedMcpClient(),
        toolRegistry: DynamicToolRegistry(const []),
      ),
    );
    addTearDown(viewModel.dispose);

    try {
      await tester.pumpWidget(_harness(viewModel));
      await tester.pumpAndSettle();

      final githubCard = find.byKey(
        const ValueKey<String>('desktop-mcp-server-github'),
      );
      final filesystemCard = find.byKey(
        const ValueKey<String>('desktop-mcp-server-filesystem'),
      );
      expect(githubCard, findsOneWidget);
      expect(filesystemCard, findsOneWidget);

      final githubRect = tester.getRect(githubCard);
      final filesystemRect = tester.getRect(filesystemCard);
      expect(githubRect.width, 453);
      expect(filesystemRect.width, 453);
      expect(githubRect.top, filesystemRect.top);
      expect(filesystemRect.left - githubRect.right, 14);

      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.text('1 工具'), findsNWidgets(2));
      expect(
        find.byKey(
          const ValueKey<String>('desktop-mcp-tool-github-search_issues'),
        ),
        findsNothing,
      );
      expect(
        find.byKey(
          const ValueKey<String>('desktop-mcp-tool-filesystem-read_file'),
        ),
        findsNothing,
      );
      expect(find.text('搜索议题'), findsNothing);
      expect(find.text('读取文件'), findsNothing);

      final githubActions = find.byKey(
        const ValueKey<String>('desktop-mcp-server-actions-github'),
      );
      expect(githubActions, findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('desktop-mcp-server-refresh-github')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('desktop-mcp-server-details-github')),
        findsNothing,
      );

      await tester.tap(githubActions);
      await tester.pumpAndSettle();
      final githubActionMenu = find.byKey(
        const ValueKey<String>('desktop-mcp-server-action-menu-github'),
      );
      expect(githubActionMenu, findsOneWidget);
      expect(
        tester.getRect(githubActionMenu).right,
        closeTo(tester.getRect(githubActions).right, 1),
      );
      expect(
        find.descendant(
          of: githubActionMenu,
          matching: find.byType(ShadButton),
        ),
        findsNWidgets(4),
      );
      final githubDetails = find.byKey(
        const ValueKey<String>('desktop-mcp-server-details-github'),
      );
      expect(githubDetails, findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('desktop-mcp-server-refresh-github')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('desktop-mcp-server-edit-github')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('desktop-mcp-server-delete-github')),
        findsOneWidget,
      );
      expect(find.text('服务器详情'), findsOneWidget);
      expect(find.text('刷新工具'), findsOneWidget);
      expect(find.text('编辑'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);
      expect(find.text('编辑 MCP 服务器'), findsNothing);
      expect(find.text('删除 MCP 服务器'), findsNothing);

      await tester.tap(githubDetails);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('desktop-mcp-server-refresh-github')),
        findsNothing,
      );
      expect(
        find.byKey(
          const ValueKey<String>('desktop-mcp-server-details-dialog-github'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('desktop-mcp-tool-github-search_issues'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('desktop-mcp-tool-filesystem-read_file'),
        ),
        findsNothing,
      );
      expect(find.text('搜索议题'), findsOneWidget);
      expect(find.text('读取文件'), findsNothing);
      expect(
        find.byKey(
          const ValueKey<String>(
            'desktop-mcp-tool-toggle-github-search_issues',
          ),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(
          const ValueKey<String>('desktop-mcp-tool-github-search_issues'),
        ),
        findsNothing,
      );

      final searchInput = find.descendant(
        of: find.byKey(const ValueKey<String>('mcp-search-field')),
        matching: find.byType(EditableText),
      );
      await tester.enterText(searchInput, 'read_file');
      await tester.pump();
      expect(githubCard, findsNothing);
      expect(filesystemCard, findsOneWidget);
      expect(find.text('读取文件'), findsNothing);

      await tester.enterText(searchInput, 'not-found');
      await tester.pump();
      expect(githubCard, findsNothing);
      expect(filesystemCard, findsNothing);
      expect(find.text('未找到匹配的 MCP 服务器'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('clear-mcp-search')));
      await tester.pump();
      expect(githubCard, findsOneWidget);
      expect(filesystemCard, findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('desktop MCP editor matches the Add Bot form dialog', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;

    final repository = _FakeMcpServerRepository();
    final viewModel = McpServersViewModel(
      repository: repository,
      credentialStore: const _UnusedCredentialStore(),
      catalogService: McpCatalogService(
        repository: repository,
        client: const _UnusedMcpClient(),
        toolRegistry: DynamicToolRegistry(const []),
      ),
    );
    addTearDown(viewModel.dispose);

    try {
      await tester.pumpWidget(_harness(viewModel));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('add-mcp-server-desktop')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ShadDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(ShadForm), findsOneWidget);
      expect(find.byType(ShadCard), findsNWidgets(2));
      expect(find.byType(MenuAnchor), findsNWidgets(2));
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.link_rounded), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('保存并连接'), findsOneWidget);
      expect(
        tester.getSize(
          find.byKey(const ValueKey<String>('mcp-server-dialog-content')),
        ),
        const Size(840, 720),
      );

      final basicSection = find.byKey(
        const ValueKey<String>('mcp-server-basic-section'),
      );
      final connectionSection = find.byKey(
        const ValueKey<String>('mcp-server-connection-section'),
      );
      expect(basicSection, findsOneWidget);
      expect(connectionSection, findsOneWidget);
      expect(
        tester.getRect(basicSection).bottom,
        lessThan(tester.getRect(connectionSection).top),
      );

      Size inputSize(String key) {
        return tester.getSize(
          find.descendant(
            of: find.byKey(ValueKey<String>(key)),
            matching: find.byType(ShadInput),
          ),
        );
      }

      final inputSizes = [
        inputSize('mcp-server-name'),
        inputSize('mcp-server-namespace'),
        inputSize('mcp-server-transport'),
        inputSize('mcp-server-endpoint'),
        inputSize('mcp-server-authentication'),
      ];
      expect(inputSizes.map((size) => size.width).toSet(), {
        DesktopThemeTokens.addBotFormFieldWidth,
      });
      expect(inputSizes.map((size) => size.height).toSet(), {
        DesktopThemeTokens.botFormFieldHeight,
      });

      final authenticationMenu = find.byKey(
        const ValueKey<String>('mcp-server-authentication-menu'),
      );
      await tester.ensureVisible(authenticationMenu);
      await tester.pumpAndSettle();
      await tester.tap(authenticationMenu);
      await tester.pumpAndSettle();
      final authenticationField = find.byKey(
        const ValueKey<String>('mcp-server-authentication'),
      );
      final authenticationInputStyle =
          tester
              .widget<EditableText>(
                find.descendant(
                  of: authenticationField,
                  matching: find.byType(EditableText),
                ),
              )
              .style;
      final accessTokenOption = find.ancestor(
        of: find.text('OAuth / Bearer 访问令牌').last,
        matching: find.byType(MenuItemButton),
      );
      expect(accessTokenOption, findsOneWidget);
      expect(
        tester.widget<Text>(find.text('OAuth / Bearer 访问令牌').last).style,
        authenticationInputStyle,
      );
      await tester.tap(accessTokenOption);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('mcp-server-access-token')),
        findsOneWidget,
      );
      expect(
        inputSize('mcp-server-access-token'),
        const Size(
          DesktopThemeTokens.addBotFormFieldWidth,
          DesktopThemeTokens.botFormFieldHeight,
        ),
      );

      final transportMenu = find.byKey(
        const ValueKey<String>('mcp-server-transport-menu'),
      );
      await tester.ensureVisible(transportMenu);
      await tester.pumpAndSettle();
      await tester.tap(transportMenu);
      await tester.pumpAndSettle();
      final transportField = find.byKey(
        const ValueKey<String>('mcp-server-transport'),
      );
      final transportInputStyle =
          tester
              .widget<EditableText>(
                find.descendant(
                  of: transportField,
                  matching: find.byType(EditableText),
                ),
              )
              .style;
      final stdioOption = find.ancestor(
        of: find.text('stdio（本地进程）').last,
        matching: find.byType(MenuItemButton),
      );
      expect(stdioOption, findsOneWidget);
      expect(
        tester.widget<Text>(find.text('stdio（本地进程）').last).style,
        transportInputStyle,
      );
      await tester.tap(stdioOption);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('mcp-server-command')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('mcp-server-arguments')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('mcp-server-environment')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('mcp-server-endpoint')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('mcp-server-authentication')),
        findsNothing,
      );
      expect(
        inputSize('mcp-server-command'),
        const Size(
          DesktopThemeTokens.addBotFormFieldWidth,
          DesktopThemeTokens.botFormFieldHeight,
        ),
      );
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });
}

Widget _harness(McpServersViewModel viewModel) {
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
          home: McpServersPage(viewModel: viewModel),
        ),
  );
}

final class _FakeMcpServerRepository implements McpServerRepository {
  const _FakeMcpServerRepository({
    this.servers = const [],
    this.toolsByServer = const {},
  });

  final List<McpServer> servers;
  final Map<String, List<McpToolDescriptor>> toolsByServer;

  @override
  Stream<List<McpServer>> get changes => const Stream.empty();

  @override
  Future<void> deleteServer(String id) async {}

  @override
  Future<McpServer?> getServer(String id) async {
    for (final server in servers) {
      if (server.id == id) return server;
    }
    return null;
  }

  @override
  Future<List<McpServer>> getServers({bool forceRefresh = false}) async =>
      servers;

  @override
  Future<List<McpToolDescriptor>> getTools(
    String serverId, {
    bool enabledOnly = false,
  }) async {
    final tools = toolsByServer[serverId] ?? const [];
    return enabledOnly
        ? tools.where((tool) => tool.enabled).toList(growable: false)
        : tools;
  }

  @override
  Future<void> replaceTools(
    String serverId,
    List<McpToolDescriptor> tools,
  ) async {}

  @override
  Future<void> saveServer(McpServer server) async {}

  @override
  Future<void> setToolEnabled(
    String serverId,
    String remoteName, {
    required bool enabled,
  }) async {}
}

final class _UnusedCredentialStore implements McpCredentialStore {
  const _UnusedCredentialStore();

  @override
  Future<void> delete(String serverId) => throw UnimplementedError();

  @override
  Future<McpCredential?> read(String serverId) => throw UnimplementedError();

  @override
  Future<void> write(String serverId, McpCredential credential) =>
      throw UnimplementedError();
}

final class _UnusedMcpClient implements McpClient {
  const _UnusedMcpClient();

  @override
  Future<McpToolCallResult> callTool({
    required McpServer server,
    required String remoteName,
    required Map<String, Object?> arguments,
    required AgentCancellationToken cancellationToken,
  }) => throw UnimplementedError();

  @override
  Future<void> disconnect(McpServer server) => throw UnimplementedError();

  @override
  Future<McpInitializeResult> initialize(
    McpServer server, {
    AgentCancellationToken? cancellationToken,
  }) => throw UnimplementedError();

  @override
  Future<List<McpToolDescriptor>> listTools(
    McpServer server, {
    AgentCancellationToken? cancellationToken,
  }) => throw UnimplementedError();
}
