import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stars/data/services/database_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('current database schema', () {
    test('creates exactly the current schema', () async {
      final database = await _openCurrentDatabase();
      addTearDown(database.close);

      await _expectCurrentSchema(database);
    });

    test('replacing a duplicate message id leaves exactly one row', () async {
      final database = await _openCurrentDatabase();
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
  });

  group('database version reset policy', () {
    test('reopens a database that already uses the current schema', () async {
      final directory = await Directory.systemTemp.createTemp(
        'stars_current_database_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final databasePath = path.join(directory.path, 'app.db');
      final initialDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: DatabaseService.databaseVersion,
          onCreate: DatabaseService.createSchema,
        ),
      );
      await initialDatabase.insert('bots', <String, Object?>{
        'id': 'current-bot',
        'name': 'Current Bot',
      });
      await initialDatabase.close();

      final service = DatabaseService(
        applicationDocumentsDirectoryProvider: () async => directory,
      );
      final reopenedDatabase = await service.initDatabase();
      addTearDown(reopenedDatabase.close);

      expect(
        await reopenedDatabase.getVersion(),
        DatabaseService.databaseVersion,
      );
      expect(
        await reopenedDatabase.query(
          'bots',
          where: 'id = ?',
          whereArgs: const <Object?>['current-bot'],
        ),
        hasLength(1),
      );
    });

    test(
      'deletes any non-current database before creating the current schema',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'stars_obsolete_database_',
        );
        addTearDown(() => directory.delete(recursive: true));
        final databasePath = path.join(directory.path, 'app.db');
        final obsoleteDatabase = await databaseFactoryFfi.openDatabase(
          databasePath,
          options: OpenDatabaseOptions(
            version: DatabaseService.databaseVersion - 1,
            onCreate: (database, _) async {
              await database.execute('''
                CREATE TABLE obsolete_data (
                  id TEXT PRIMARY KEY,
                  value TEXT NOT NULL
                )
              ''');
            },
          ),
        );
        await obsoleteDatabase.insert('obsolete_data', <String, Object?>{
          'id': 'obsolete-1',
          'value': 'must be deleted',
        });
        await obsoleteDatabase.close();

        final service = DatabaseService(
          applicationDocumentsDirectoryProvider: () async => directory,
        );
        final resetDatabase = await service.initDatabase();
        addTearDown(resetDatabase.close);

        expect(
          await resetDatabase.getVersion(),
          DatabaseService.databaseVersion,
        );
        await _expectCurrentSchema(resetDatabase);
        expect(
          await resetDatabase.rawQuery('''
            SELECT name
            FROM sqlite_master
            WHERE type = 'table' AND name = 'obsolete_data'
          '''),
          isEmpty,
        );
        expect(await resetDatabase.query('messages'), isEmpty);
      },
    );
  });
}

Future<void> _expectCurrentSchema(Database database) async {
  final tables = await database.rawQuery('''
    SELECT name
    FROM sqlite_master
    WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
  ''');
  expect(
    tables.map((table) => table['name']),
    unorderedEquals(<String>[
      'chats',
      'messages',
      'token_usage_records',
      'skills',
      'bot_skill_bindings',
      'skill_activations',
      'skill_publishers',
      'skill_catalogs',
      'skill_script_grants',
      'skill_organization_policy',
      'skill_compliance_events',
      'conversation_skill_pins',
      'mcp_servers',
      'mcp_tools',
      'conversation_memory_state',
      'conversation_summary_segments',
      'conversation_memory_items',
      'bots',
      'profile',
    ]),
  );

  final indexes = await database.rawQuery('''
    SELECT name
    FROM sqlite_master
    WHERE type = 'index' AND name NOT LIKE 'sqlite_autoindex_%'
  ''');
  expect(
    indexes.map((index) => index['name']),
    unorderedEquals(<String>[
      'messages_message_id_unique',
      'messages_bot_id_index',
      'token_usage_records_chat_id_index',
      'token_usage_records_bot_id_index',
      'bot_skill_bindings_skill_id_index',
      'skill_activations_run_id_index',
      'skill_activations_chat_id_index',
      'skill_compliance_events_skill_id_index',
      'conversation_skill_pins_skill_id_index',
      'conversation_summary_chat_status_index',
      'conversation_memory_chat_key_index',
      'messages_chat_timestamp_message_index',
      'mcp_tools_server_id_index',
    ]),
  );

  final messageColumns = await database.rawQuery('PRAGMA table_info(messages)');
  expect(
    messageColumns.map((column) => column['name']),
    orderedEquals(<String>[
      'message_id',
      'turn_id',
      'run_id',
      'chat_id',
      'bot_id',
      'sender_id',
      'content',
      'reasoning',
      'process_info',
      'images',
      'files',
      'audio',
      'music',
      'video',
      'token_model',
      'input_token_count',
      'output_token_count',
      'total_token_count',
      'terminal_state',
      'has_partial_content',
      'timestamp',
    ]),
  );
  expect(
    messageColumns.singleWhere(
      (column) => column['name'] == 'message_id',
    )['notnull'],
    1,
  );
  expect(
    messageColumns.singleWhere(
      (column) => column['name'] == 'turn_id',
    )['notnull'],
    1,
  );

  final mcpColumns = await database.rawQuery('PRAGMA table_info(mcp_servers)');
  expect(
    mcpColumns.map((column) => column['name']),
    orderedEquals(<String>[
      'id',
      'name',
      'transport_type',
      'transport_config_json',
      'remote_server_name',
      'remote_server_version',
      'capabilities_json',
      'connection_status',
      'last_error_code',
      'last_connected_at',
      'created_at',
      'updated_at',
    ]),
  );

  final tokenUsageColumns = await database.rawQuery(
    'PRAGMA table_info(token_usage_records)',
  );
  expect(
    tokenUsageColumns.map((column) => column['name']),
    orderedEquals(<String>[
      'message_id',
      'chat_id',
      'bot_id',
      'operation_kind',
      'token_model',
      'input_token_count',
      'output_token_count',
      'total_token_count',
      'timestamp',
    ]),
  );
}

Future<Database> _openCurrentDatabase() {
  return databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: DatabaseService.databaseVersion,
      onCreate: DatabaseService.createSchema,
    ),
  );
}
