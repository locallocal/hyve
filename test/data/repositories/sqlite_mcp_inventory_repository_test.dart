import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stars/data/models/local_records.dart';
import 'package:stars/data/models/mcp_records.dart';
import 'package:stars/data/repositories/sqlite_mcp_inventory_repository.dart';
import 'package:stars/data/services/database_service.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  sqfliteFfiInit();
  late Database database;
  late LocalDatabaseService localDatabase;
  late SqliteMcpInventoryRepository repository;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseService.databaseVersion,
        onConfigure: DatabaseService.configure,
        onCreate: DatabaseService.createSchema,
      ),
    );
    localDatabase = LocalDatabaseService(
      databaseProvider: () async => database,
    );
    repository = SqliteMcpInventoryRepository(localDatabase: localDatabase);
  });

  tearDown(() => database.close());

  test('queries installed MCP servers and Tool counts from SQLite', () async {
    final now = DateTime(2026, 8, 10, 12);
    await localDatabase.upsertMcpServer(
      McpServerRecord.fromDomain(_server(now)).values,
    );
    await localDatabase.replaceMcpCatalog(
      McpServerRecord.fromDomain(
        _server(now, status: McpConnectionStatus.connected),
      ).values,
      [McpToolRecord.fromDomain(_tool(now)).values],
    );

    final page = await repository.listInstalled(query: 'files', limit: 10);

    expect(page.truncated, isFalse);
    expect(page.items, hasLength(1));
    expect(page.items.single.id, 'server-1');
    expect(page.items.single.transportType, 'streamable_http');
    expect(page.items.single.connectionStatus, 'connected');
    expect(page.items.single.toolCount, 1);

    final injection = await repository.listInstalled(
      query: "' OR 1=1 --",
      limit: 10,
    );
    expect(injection.items, isEmpty);
  });

  test('binds conversation MCP configuration through chats and bots', () async {
    final now = DateTime(2026, 8, 10, 12);
    await localDatabase.insertBot(
      BotRecord.fromDomain(_bot(now), storedApiKey: 'encrypted-key').values,
    );
    await localDatabase.insertChat(
      ChatRecord.fromDomain(
        Chat(
          id: 'chat-1',
          botId: 'bot-1',
          lastMessage: '',
          lastMessageTimestamp: now,
          createTimestamp: now,
          modifyTimestamp: now,
        ),
      ).values,
    );
    await localDatabase.replaceMcpCatalog(
      McpServerRecord.fromDomain(
        _server(now, status: McpConnectionStatus.connected),
      ).values,
      [McpToolRecord.fromDomain(_tool(now)).values],
    );

    final inventory = await repository.listForConversation('chat-1');

    expect(inventory.conversationFound, isTrue);
    expect(inventory.botId, 'bot-1');
    expect(inventory.botName, 'Agent One');
    expect(inventory.modelSupportsMcp, isTrue);
    expect(inventory.servers.map((server) => server.id), [
      'missing-server',
      'server-1',
    ]);
    final byId = {for (final server in inventory.servers) server.id: server};
    expect(byId['server-1']?.installed, isTrue);
    expect(byId['server-1']?.availableToolCount, 1);
    expect(byId['server-1']?.tools.single.remoteName, 'read_file');
    expect(byId['server-1']?.tools.single.available, isTrue);
    expect(byId['server-1']?.tools.single.requiresApproval, isFalse);
    expect(byId['missing-server']?.installed, isFalse);
    expect(byId['missing-server']?.tools.single.available, isFalse);

    final missing = await repository.listForConversation('chat-other');
    expect(missing.conversationFound, isFalse);
    expect(missing.servers, isEmpty);
  });
}

McpServer _server(
  DateTime now, {
  McpConnectionStatus status = McpConnectionStatus.disconnected,
}) => McpServer(
  id: 'server-1',
  name: 'Files MCP',
  transport: McpStreamableHttpServerTransport(
    endpoint: Uri.parse('https://mcp.example.com'),
  ),
  status: status,
  createdAt: now,
  updatedAt: now,
);

McpToolDescriptor _tool(DateTime now) => McpToolDescriptor(
  serverId: 'server-1',
  remoteName: 'read_file',
  title: 'Read file',
  description: 'Read one file.',
  inputSchema: const {'type': 'object', 'properties': <String, Object?>{}},
  taskSupport: McpToolTaskSupport.optional,
  updatedAt: now,
);

Bot _bot(DateTime now) => Bot(
  id: 'bot-1',
  name: 'Agent One',
  avatar: '',
  provider: 'Provider',
  baseURL: 'https://api.example.com',
  apiKey: 'key',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: '',
  parameters: {
    Bot.parameterSupportsMcp: true,
    Bot.parameterMcpServers: ['server-1', 'missing-server'],
    Bot.parameterMcpTools: [
      McpToolConfiguration(
        serverId: 'server-1',
        remoteName: 'read_file',
        requiresApproval: false,
      ).toMap(),
      McpToolConfiguration(
        serverId: 'missing-server',
        remoteName: 'missing_tool',
      ).toMap(),
    ],
  },
  createTimestamp: now,
  modifyTimestamp: now,
);
