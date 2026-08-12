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
    test('creates every table required by schema version 15', () async {
      final database = await _openCurrentDatabase();
      addTearDown(database.close);

      final tables = await database.rawQuery('''
        SELECT name
        FROM sqlite_master
        WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
      ''');
      expect(
        tables.map((table) => table['name']),
        containsAll(<String>[
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

      final messageColumns = await database.rawQuery(
        'PRAGMA table_info(messages)',
      );
      expect(
        messageColumns.map((column) => column['name']),
        containsAll(<String>[
          'message_id',
          'turn_id',
          'run_id',
          'process_info',
          'token_model',
          'input_token_count',
          'output_token_count',
          'total_token_count',
          'terminal_state',
          'has_partial_content',
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

      final mcpColumns = await database.rawQuery(
        'PRAGMA table_info(mcp_servers)',
      );
      expect(
        mcpColumns.map((column) => column['name']),
        containsAll(<String>[
          'transport_type',
          'transport_config_json',
          'capabilities_json',
          'connection_status',
        ]),
      );

      final tokenUsageColumns = await database.rawQuery(
        'PRAGMA table_info(token_usage_records)',
      );
      expect(
        tokenUsageColumns.map((column) => column['name']),
        contains('operation_kind'),
      );
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

  group('database version policy', () {
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
      'rejects a historical schema without upgrading or deleting its data',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'stars_historical_database_',
        );
        addTearDown(() => directory.delete(recursive: true));
        final databasePath = path.join(directory.path, 'app.db');
        final historicalDatabase = await databaseFactoryFfi.openDatabase(
          databasePath,
          options: OpenDatabaseOptions(
            version: DatabaseService.databaseVersion - 1,
            onCreate: (database, _) async {
              await database.execute('''
                CREATE TABLE legacy_records (
                  id TEXT PRIMARY KEY,
                  value TEXT NOT NULL
                )
              ''');
            },
          ),
        );
        await historicalDatabase.insert('legacy_records', <String, Object?>{
          'id': 'legacy-1',
          'value': 'preserved',
        });
        await historicalDatabase.close();

        final service = DatabaseService(
          applicationDocumentsDirectoryProvider: () async => directory,
        );
        await expectLater(
          service.initDatabase(),
          throwsA(
            isA<UnsupportedDatabaseVersionException>()
                .having(
                  (error) => error.actualVersion,
                  'actualVersion',
                  DatabaseService.databaseVersion - 1,
                )
                .having(
                  (error) => error.expectedVersion,
                  'expectedVersion',
                  DatabaseService.databaseVersion,
                ),
          ),
        );

        final unchangedDatabase = await databaseFactoryFfi.openDatabase(
          databasePath,
        );
        addTearDown(unchangedDatabase.close);
        expect(
          await unchangedDatabase.getVersion(),
          DatabaseService.databaseVersion - 1,
        );
        expect(await unchangedDatabase.query('legacy_records'), <Object?>[
          <String, Object?>{'id': 'legacy-1', 'value': 'preserved'},
        ]);
      },
    );
  });
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
