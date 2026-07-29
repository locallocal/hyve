import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stars/data/repositories/sqlite_mcp_server_repository.dart';
import 'package:stars/data/services/database_service.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/data/services/mcp/mcp_catalog_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/mcp_client.dart';
import 'package:stars/domain/repositories/mcp_credential_store.dart';
import 'package:stars/ui/features/mcp/view_models/mcp_servers_view_model.dart';

void main() {
  sqfliteFfiInit();

  late Database database;
  late SqliteMcpServerRepository repository;
  late _MemoryCredentialStore credentials;
  late DynamicToolRegistry registry;
  late McpServersViewModel viewModel;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseService.databaseVersion,
        onCreate: DatabaseService.createSchema,
      ),
    );
    repository = SqliteMcpServerRepository(
      localDatabase: LocalDatabaseService(
        databaseProvider: () async => database,
      ),
    );
    credentials = _MemoryCredentialStore();
    registry = DynamicToolRegistry(const []);
    final catalog = McpCatalogService(
      repository: repository,
      client: _FakeMcpClient(),
      toolRegistry: registry,
    );
    viewModel = McpServersViewModel(
      repository: repository,
      credentialStore: credentials,
      catalogService: catalog,
      now: () => DateTime(2026, 7, 29, 10),
    );
  });

  tearDown(() async {
    viewModel.dispose();
    await repository.dispose();
    await database.close();
  });

  test('saves credentials separately and connects a new server', () async {
    final saved = await viewModel.saveAndConnect(
      const McpServerDraft(
        name: 'Example',
        namespace: 'example',
        endpoint: 'https://example.com/mcp',
        authType: McpAuthType.oauthAccessToken,
        accessToken: 'secret-token',
      ),
    );

    expect(saved, isTrue);
    expect(viewModel.servers, hasLength(1));
    final server = viewModel.servers.single;
    expect(server.status, McpConnectionStatus.connected);
    expect(credentials.values[server.id]?.accessToken, 'secret-token');
    expect(viewModel.toolsFor(server.id), hasLength(1));
    expect(viewModel.toolsFor(server.id).single.enabled, isFalse);
  });

  test('enabling a discovered Tool updates the runtime registry', () async {
    await viewModel.saveAndConnect(
      const McpServerDraft(
        name: 'Example',
        namespace: 'example',
        endpoint: 'https://example.com/mcp',
        authType: McpAuthType.none,
      ),
    );
    final tool = viewModel.toolsFor(viewModel.servers.single.id).single;

    await viewModel.setToolEnabled(tool, true);

    expect(registry.find(tool.canonicalName), isNotNull);
  });

  test('saves stdio process settings and secure environment', () async {
    final saved = await viewModel.saveAndConnect(
      const McpServerDraft(
        name: 'Local files',
        namespace: 'local_files',
        transportType: McpTransportType.stdio,
        command: 'npx',
        arguments: '-y\n@modelcontextprotocol/server-filesystem\n/tmp',
        environment: 'API_KEY=local-secret\nMCP_MODE=read_only',
      ),
    );

    expect(saved, isTrue);
    final server = viewModel.servers.single;
    expect(server.transportType, McpTransportType.stdio);
    expect(server.command, 'npx');
    expect(server.arguments, [
      '-y',
      '@modelcontextprotocol/server-filesystem',
      '/tmp',
    ]);
    expect(server.authType, McpAuthType.none);
    expect(credentials.values[server.id]?.environment, {
      'API_KEY': 'local-secret',
      'MCP_MODE': 'read_only',
    });
  });

  test('rejects malformed stdio environment variables', () async {
    final saved = await viewModel.saveAndConnect(
      const McpServerDraft(
        name: 'Local',
        namespace: 'local',
        transportType: McpTransportType.stdio,
        command: 'npx',
        environment: 'NOT VALID',
      ),
    );

    expect(saved, isFalse);
    expect(viewModel.error, isA<McpException>());
    expect(
      (viewModel.error! as McpException).code,
      'mcp_invalid_stdio_environment',
    );
    expect(viewModel.servers, isEmpty);
  });
}

final class _MemoryCredentialStore implements McpCredentialStore {
  final Map<String, McpCredential> values = {};

  @override
  Future<void> delete(String serverId) async => values.remove(serverId);

  @override
  Future<McpCredential?> read(String serverId) async => values[serverId];

  @override
  Future<void> write(String serverId, McpCredential credential) async {
    values[serverId] = credential;
  }
}

final class _FakeMcpClient implements McpClient {
  @override
  Future<McpInitializeResult> initialize(
    McpServer server, {
    AgentCancellationToken? cancellationToken,
  }) async {
    return const McpInitializeResult(
      protocolVersion: '2025-11-25',
      serverName: 'Remote Example',
      serverVersion: '1.0.0',
      capabilities: McpServerCapabilities(tools: true),
    );
  }

  @override
  Future<List<McpToolDescriptor>> listTools(
    McpServer server, {
    AgentCancellationToken? cancellationToken,
  }) async {
    return [
      McpToolDescriptor(
        serverId: server.id,
        namespace: server.namespace,
        remoteName: 'search',
        title: 'Search',
        description: 'Search remote data.',
        inputSchema: const {'type': 'object'},
        annotations: const McpToolAnnotations(
          readOnlyHint: true,
          destructiveHint: false,
        ),
        updatedAt: DateTime(2026, 7, 29),
      ),
    ];
  }

  @override
  Future<McpToolCallResult> callTool({
    required McpServer server,
    required String remoteName,
    required Map<String, Object?> arguments,
    required AgentCancellationToken cancellationToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect(McpServer server) async {}
}
