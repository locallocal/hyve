import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stars/data/services/database_service.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'schema migration backfills stable identities and creates a unique index',
    () async {
      final database = await _openMigratedV2Database();
      addTearDown(database.close);

      final rows = await database.query('messages', orderBy: 'rowid ASC');
      expect(rows, hasLength(2));
      expect(
        rows.map((row) => row['message_id']),
        orderedEquals(<String>['legacy:chat-1:1', 'legacy:chat-1:2']),
      );
      expect(
        rows.map((row) => row['turn_id']),
        orderedEquals(<String>['legacy-turn:chat-1:1', 'legacy-turn:chat-1:2']),
      );
      expect(rows.map((row) => row['run_id']), everyElement(''));
      expect(rows.map((row) => row['terminal_state']), everyElement(''));
      expect(rows.map((row) => row['has_partial_content']), everyElement(0));
      expect(rows.map((row) => row['token_model']), everyElement(''));
      expect(rows.map((row) => row['input_token_count']), everyElement(0));
      expect(rows.map((row) => row['output_token_count']), everyElement(0));
      expect(rows.map((row) => row['total_token_count']), everyElement(0));
      final profiles = await database.query('profile');
      expect(profiles.single['show_execution_status'], 1);

      final indexes = await database.rawQuery('PRAGMA index_list(messages)');
      final identityIndex = indexes.singleWhere(
        (index) => index['name'] == 'messages_message_id_unique',
      );
      expect(identityIndex['unique'], 1);
      expect(
        indexes.any((index) => index['name'] == 'messages_bot_id_index'),
        isTrue,
      );
      final tokenUsageColumns = await database.rawQuery(
        'PRAGMA table_info(token_usage_records)',
      );
      expect(
        tokenUsageColumns.map((column) => column['name']),
        containsAll(<String>[
          'message_id',
          'chat_id',
          'bot_id',
          'token_model',
          'input_token_count',
          'output_token_count',
          'total_token_count',
          'timestamp',
        ]),
      );
    },
  );

  test('version 6 migration backfills token usage records', () async {
    final database = await _openMigratedV5Database();
    addTearDown(database.close);

    final records = await database.query('token_usage_records');
    expect(records, hasLength(1));
    expect(records.single['message_id'], 'assistant-with-usage');
    expect(records.single['chat_id'], 'chat-1');
    expect(records.single['bot_id'], 'bot-1');
    expect(records.single['token_model'], 'model-a');
    expect(records.single['input_token_count'], 120);
    expect(records.single['output_token_count'], 30);
    expect(records.single['total_token_count'], 150);
  });

  test('version 7 migration creates Skill storage and audit tables', () async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);

    await DatabaseService.migrateSchema(database, 6, 7);

    final tables = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    expect(
      tables.map((table) => table['name']),
      containsAll(<String>[
        'skills',
        'bot_skill_bindings',
        'skill_activations',
      ]),
    );
    final activationColumns = await database.rawQuery(
      'PRAGMA table_info(skill_activations)',
    );
    expect(
      activationColumns.map((column) => column['name']),
      containsAll(<String>[
        'run_id',
        'chat_id',
        'message_id',
        'skill_id',
        'skill_name',
        'content_digest',
        'trigger_type',
        'status',
      ]),
    );
  });

  test('version 8 migration creates conversation Skill pins', () async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);

    await DatabaseService.migrateSchema(database, 7, 8);

    final columns = await database.rawQuery(
      'PRAGMA table_info(conversation_skill_pins)',
    );
    expect(columns.map((column) => column['name']), [
      'chat_id',
      'skill_id',
      'created_at',
    ]);
  });

  test('version 9 migration creates MCP server and Tool catalogs', () async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);

    await DatabaseService.migrateSchema(database, 8, 9);

    final tables = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    expect(
      tables.map((table) => table['name']),
      containsAll(<String>['mcp_servers', 'mcp_tools']),
    );
    final serverColumns = await database.rawQuery(
      'PRAGMA table_info(mcp_servers)',
    );
    expect(
      serverColumns.map((column) => column['name']),
      containsAll(<String>[
        'namespace',
        'endpoint_uri',
        'auth_type',
        'capabilities_json',
        'connection_status',
      ]),
    );
    expect(
      serverColumns.map((column) => column['name']),
      isNot(contains('access_token')),
    );
  });

  test('replacing a duplicate message id leaves exactly one row', () async {
    final database = await _openMigratedV2Database();
    addTearDown(database.close);

    const messageId = 'assistant:stable-id';
    await database.insert('messages', <String, Object?>{
      'message_id': messageId,
      'turn_id': 'turn-1',
      'chat_id': 'chat-1',
      'content': 'first response',
    });
    await database.insert('messages', <String, Object?>{
      'message_id': messageId,
      'turn_id': 'turn-1',
      'chat_id': 'chat-1',
      'content': 'updated response',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    final rows = await database.query(
      'messages',
      where: 'message_id = ?',
      whereArgs: <Object?>[messageId],
    );
    expect(rows, hasLength(1));
    expect(rows.single['content'], 'updated response');
  });
}

Future<Database> _openMigratedV2Database() async {
  final database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  await database.execute('''
    CREATE TABLE messages (
      chat_id TEXT,
      bot_id TEXT,
      sender_id TEXT,
      content TEXT,
      reasoning TEXT,
      process_info TEXT,
      images TEXT,
      files TEXT,
      audio TEXT,
      music TEXT,
      video TEXT,
      timestamp INTEGER
    )
  ''');
  await database.execute('''
    CREATE TABLE profile (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      avatar TEXT,
      font_size DOUBLE,
      theme_mode INTEGER,
      language TEXT,
      create_timestamp INTEGER,
      modify_timestamp INTEGER
    )
  ''');
  await database.insert('profile', <String, Object?>{
    'name': 'Legacy User',
    'font_size': 16,
    'theme_mode': 0,
    'language': 'zh_CN',
    'create_timestamp': 0,
    'modify_timestamp': 0,
  });
  await database.insert('messages', <String, Object?>{
    'chat_id': 'chat-1',
    'content': 'legacy user message',
  });
  await database.insert('messages', <String, Object?>{
    'chat_id': 'chat-1',
    'content': 'legacy assistant message',
  });

  await DatabaseService.migrateSchema(
    database,
    2,
    DatabaseService.databaseVersion,
  );
  return database;
}

Future<Database> _openMigratedV5Database() async {
  final database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  await DatabaseService.createSchema(database, 5);
  await database.execute('DROP TABLE token_usage_records');
  await database.insert('messages', <String, Object?>{
    'message_id': 'assistant-with-usage',
    'turn_id': 'turn-1',
    'chat_id': 'chat-1',
    'bot_id': 'bot-1',
    'sender_id': 'bot-1',
    'content': 'response',
    'token_model': 'model-a',
    'input_token_count': 120,
    'output_token_count': 30,
    'total_token_count': 150,
    'timestamp': DateTime(2026, 7, 25, 10).millisecondsSinceEpoch,
  });

  await DatabaseService.migrateSchema(
    database,
    5,
    DatabaseService.databaseVersion,
  );
  return database;
}
