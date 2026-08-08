import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stars/data/repositories/sqlite_model_usage_repository.dart';
import 'package:stars/data/services/database_service.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/message.dart';

void main() {
  sqfliteFfiInit();

  test('stores compaction usage as an idempotent model operation', () async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseService.databaseVersion,
        onCreate: DatabaseService.createSchema,
      ),
    );
    addTearDown(database.close);
    final repository = SqliteModelUsageRepository(
      localDatabase: LocalDatabaseService(
        databaseProvider: () async => database,
      ),
    );
    final record = ModelTokenUsageRecord(
      messageId: 'context_compaction:summary_1',
      chatId: 'chat_1',
      botId: 'bot_1',
      timestamp: DateTime(2026, 8, 8),
      usage: const ModelTokenUsage(
        model: 'model',
        inputTokens: 100,
        outputTokens: 20,
        totalTokens: 120,
      ),
      operationKind: 'context_compaction',
    );

    await repository.upsert(record);
    await repository.upsert(record);

    final rows = await database.query('token_usage_records');
    expect(rows, hasLength(1));
    expect(rows.single['operation_kind'], 'context_compaction');
    expect(rows.single['total_token_count'], 120);
  });
}
