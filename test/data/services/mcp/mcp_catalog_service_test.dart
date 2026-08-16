import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:hyve/data/repositories/sqlite_mcp_server_repository.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/data/services/mcp/mcp_catalog_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/mcp_client.dart';

void main() {
  sqfliteFfiInit();

  late Database database;
  late SqliteMcpServerRepository repository;
  late DynamicToolRegistry registry;
  late _FakeMcpClient client;
  late McpCatalogService service;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseService.databaseVersion,
        onConfigure: DatabaseService.configure,
        onCreate: DatabaseService.createSchema,
      ),
    );
    repository = SqliteMcpServerRepository(
      localDatabase: LocalDatabaseService(
        databaseProvider: () async => database,
      ),
    );
    registry = DynamicToolRegistry(const []);
    client = _FakeMcpClient();
    service = McpCatalogService(
      repository: repository,
      client: client,
      toolRegistry: registry,
    );
    await repository.saveServer(_server());
  });

  tearDown(() async {
    await repository.dispose();
    await database.close();
  });

  test('hydrates every supported cached Tool into the registry', () async {
    final search = _tool('search');
    final write = _tool('write');
    await repository.replaceCatalog(_server(), [search, write]);

    await service.hydrateFromCache();

    expect(registry.find(search.canonicalName), isNotNull);
    expect(registry.find(write.canonicalName), isNotNull);
  });

  test('refresh negotiates capabilities and replaces Tool catalog', () async {
    final existing = _tool('search');
    await repository.replaceCatalog(_server(), [existing]);
    client.tools = [existing, _tool('new_tool')];

    final connected = await service.refreshServer('server-1');

    expect(connected.status, McpConnectionStatus.connected);
    expect(connected.capabilities.toolListChanged, isTrue);
    final tools = await repository.getTools('server-1');
    expect(
      tools.map((tool) => tool.remoteName),
      containsAll(['search', 'new_tool']),
    );
    expect(registry.find(existing.canonicalName), isNotNull);
  });

  test('refresh records an error when startup fails', () async {
    client.initializeError = const McpException('mcp_stdio_start_failed');

    await expectLater(
      service.refreshServer('server-1'),
      throwsA(
        isA<McpException>().having(
          (error) => error.code,
          'code',
          'mcp_stdio_start_failed',
        ),
      ),
    );

    final failed = await repository.getServer('server-1');
    expect(failed, isNotNull);
    expect(failed!.status, McpConnectionStatus.error);
    expect(failed.lastErrorCode, 'mcp_stdio_start_failed');
  });

  test('refresh records an unknown failure', () async {
    client.initializeError = StateError('process exited');

    await expectLater(
      service.refreshServer('server-1'),
      throwsA(isA<StateError>()),
    );

    final failed = await repository.getServer('server-1');
    expect(failed, isNotNull);
    expect(failed!.status, McpConnectionStatus.error);
    expect(failed.lastErrorCode, 'mcp_catalog_refresh_failed');
  });
}

McpServer _server() {
  final timestamp = DateTime(2026, 7, 29);
  return McpServer(
    id: 'server-1',
    name: 'Example',
    transport: McpStreamableHttpServerTransport(
      endpoint: Uri.parse('https://example.com/mcp'),
    ),
    status: McpConnectionStatus.connected,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

McpToolDescriptor _tool(String name) {
  return McpToolDescriptor(
    serverId: 'server-1',
    remoteName: name,
    title: name,
    description: '$name Tool',
    inputSchema: const {'type': 'object'},
    annotations: const McpToolAnnotations(
      readOnlyHint: true,
      destructiveHint: false,
    ),
    updatedAt: DateTime(2026, 7, 29),
  );
}

final class _FakeMcpClient implements McpClient {
  List<McpToolDescriptor> tools = const [];
  Object? initializeError;

  @override
  Future<McpServerCatalog> discoverTools(
    McpServer server, {
    AgentCancellationToken? cancellationToken,
  }) async {
    if (initializeError case final error?) throw error;
    return McpServerCatalog(
      serverName: 'Remote Example',
      serverVersion: '1.0.0',
      capabilities: const McpServerCapabilities(
        tools: true,
        toolListChanged: true,
      ),
      tools: tools,
    );
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
