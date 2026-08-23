import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Database database;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseService.databaseVersion,
        onConfigure: DatabaseService.configure,
        onCreate: DatabaseService.createSchema,
      ),
    );
  });

  tearDown(() => database.close());

  test(
    'current schema has no SQLite-backed Project or Agent memory items',
    () async {
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final names = tables.map((row) => row['name']).toSet();

      expect(names, isNot(contains('conversation_memory_state')));
      expect(names, isNot(contains('conversation_memory_items')));
      expect(names, isNot(contains('project_memory_items')));
      expect(names, isNot(contains('agent_memory_items')));
      expect(names, isNot(contains('agent_memory_state')));
    },
  );

  test('conversation summaries store metadata but no summary body', () async {
    final columns = await database.rawQuery(
      'PRAGMA table_info(conversation_summary_segments)',
    );
    final names = columns.map((row) => row['name']).toSet();

    expect(names, contains('summary_file_name'));
    expect(names, contains('summary_content_digest'));
    expect(names, isNot(contains('content')));
    expect(names, isNot(contains('markdown')));
    expect(names, isNot(contains('narrative_summary')));
    expect(names, isNot(contains('embedding')));
  });
}
