import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stars/data/repositories/sqlite_mcp_server_repository.dart';
import 'package:stars/data/services/database_service.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  sqfliteFfiInit();

  late Database database;
  late SqliteMcpServerRepository repository;

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
  });

  tearDown(() async {
    await repository.dispose();
    await database.close();
  });

  test('persists server metadata but never credential material', () async {
    final server = _server();
    await repository.saveServer(server);

    final restored = await repository.getServer(server.id);
    expect(restored?.transport, server.transport);
    expect(restored?.capabilities.toolListChanged, isTrue);

    final columns = await database.rawQuery('PRAGMA table_info(mcp_servers)');
    expect(
      columns.map((column) => column['name']),
      isNot(contains(anyOf('access_token', 'refresh_token', 'api_key'))),
    );
    expect(
      (await database.query('mcp_servers')).single.values,
      isNot(contains('secret')),
    );
  });

  test('persists stdio command and arguments', () async {
    final timestamp = DateTime(2026, 7, 30);
    final server = McpServer(
      id: 'stdio-1',
      name: 'Local',
      transport: McpStdioServerTransport(
        command: 'npx',
        arguments: const ['-y', '@example/mcp'],
      ),
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await repository.saveServer(server);
    final restored = await repository.getServer(server.id);

    final transport = restored?.transport as McpStdioServerTransport;
    expect(transport.command, 'npx');
    expect(transport.arguments, ['-y', '@example/mcp']);
  });

  test('refresh replaces the catalog and delete clears it', () async {
    final server = _server();
    await repository.saveServer(server);

    await repository.replaceCatalog(server, [_tool()]);
    expect(await repository.getTools(server.id), hasLength(1));
    await repository.replaceCatalog(server, [_tool(remoteName: 'write')]);
    expect((await repository.getTools(server.id)).single.remoteName, 'write');

    await repository.deleteServer(server.id);
    expect(await repository.getServer(server.id), isNull);
    expect(await repository.getTools(server.id), isEmpty);
  });

  test('distinct server ids coexist without a separate namespace', () async {
    final original = _server();
    await repository.saveServer(original);
    final timestamp = DateTime(2026, 7, 29);
    final duplicate = McpServer(
      id: 'server-2',
      name: 'Second',
      transport: McpStreamableHttpServerTransport(
        endpoint: Uri.parse('https://second.example.com/mcp'),
      ),
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await repository.saveServer(duplicate);

    final rows = await database.query('mcp_servers');
    expect(rows, hasLength(2));
    expect(rows.map((row) => row['id']), containsAll(['server-1', 'server-2']));
  });

  test(
    'invalid current MCP records fail instead of silently falling back',
    () async {
      final server = _server();
      await repository.saveServer(server);
      await database.update(
        'mcp_servers',
        {'transport_config_json': '{}'},
        where: 'id = ?',
        whereArgs: [server.id],
      );

      await expectLater(repository.getServer(server.id), throwsFormatException);
    },
  );
}

McpServer _server() {
  final timestamp = DateTime(2026, 7, 29);
  return McpServer(
    id: 'server-1',
    name: 'Example',
    transport: McpStreamableHttpServerTransport(
      endpoint: Uri.parse('https://example.com/mcp'),
    ),
    capabilities: const McpServerCapabilities(
      tools: true,
      toolListChanged: true,
    ),
    status: McpConnectionStatus.connected,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

McpToolDescriptor _tool({String remoteName = 'search'}) {
  return McpToolDescriptor(
    serverId: 'server-1',
    remoteName: remoteName,
    title: 'Search',
    description: 'Search remote data.',
    inputSchema: const {'type': 'object'},
    annotations: const McpToolAnnotations(
      readOnlyHint: true,
      destructiveHint: false,
    ),
    updatedAt: DateTime(2026, 7, 29),
  );
}
