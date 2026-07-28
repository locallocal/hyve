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
    expect(restored?.endpoint, server.endpoint);
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

  test(
    'refresh preserves per-Tool enablement and delete clears catalog',
    () async {
      final server = _server();
      await repository.saveServer(server);
      final tool = _tool();

      await repository.replaceTools(server.id, [tool]);
      expect((await repository.getTools(server.id)).single.enabled, isFalse);
      await repository.setToolEnabled(
        server.id,
        tool.remoteName,
        enabled: true,
      );
      await repository.replaceTools(server.id, [tool]);

      expect((await repository.getTools(server.id)).single.enabled, isTrue);

      await repository.deleteServer(server.id);
      expect(await repository.getServer(server.id), isNull);
      expect(await repository.getTools(server.id), isEmpty);
    },
  );

  test('a duplicate namespace never replaces another server', () async {
    final original = _server();
    await repository.saveServer(original);
    final timestamp = DateTime(2026, 7, 29);
    final duplicate = McpServer(
      id: 'server-2',
      name: 'Duplicate',
      namespace: original.namespace,
      endpoint: Uri.parse('https://second.example.com/mcp'),
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await expectLater(repository.saveServer(duplicate), throwsA(anything));

    final rows = await database.query('mcp_servers');
    expect(rows, hasLength(1));
    expect(rows.single['id'], original.id);
  });
}

McpServer _server() {
  final timestamp = DateTime(2026, 7, 29);
  return McpServer(
    id: 'server-1',
    name: 'Example',
    namespace: 'example',
    endpoint: Uri.parse('https://example.com/mcp'),
    protocolVersion: '2025-11-25',
    capabilities: const McpServerCapabilities(
      tools: true,
      toolListChanged: true,
    ),
    status: McpConnectionStatus.connected,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

McpToolDescriptor _tool() {
  return McpToolDescriptor(
    serverId: 'server-1',
    namespace: 'example',
    remoteName: 'search',
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
