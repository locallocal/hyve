import 'package:sqflite/sqflite.dart';

abstract final class DatabaseMigrations {
  static const int oldestSupportedVersion = 19;
  static const int currentVersion = 20;

  static const String _emptyContextReport =
      '{"conversationSummarySegmentIds":[],"agentMemoryIds":[],'
      '"projectArtifactVersionIds":[],"skillDigests":[],"toolNames":[],'
      '"agentMemoryRevision":0,"coveredThroughMessageSequence":0}';

  static Future<void> upgrade(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < oldestSupportedVersion || newVersion > currentVersion) {
      throw StateError(
        'Unsupported database upgrade: $oldVersion -> $newVersion',
      );
    }
    if (oldVersion < 20 && newVersion >= 20) {
      await _upgradeV19ToV20(database);
    }
  }

  static Future<void> verifyCurrentSchema(Database database) async {
    await _requireColumns(database, 'agent_runs', const <String>{
      'context_report_json',
    });
    await _requireColumns(
      database,
      'conversation_summary_segments',
      const <String>{'summary_content_bytes'},
    );
  }

  static Future<void> _upgradeV19ToV20(Database database) async {
    final runColumns = await _columnNames(database, 'agent_runs');
    final summaryColumns = await _columnNames(
      database,
      'conversation_summary_segments',
    );
    final repairsPreRunFailures =
        !runColumns.contains('context_report_json') ||
        !summaryColumns.contains('summary_content_bytes');
    await _addColumnIfMissing(
      database,
      table: 'agent_runs',
      column: 'context_report_json',
      definition:
          "TEXT NOT NULL DEFAULT '${_emptyContextReport.replaceAll("'", "''")}'",
    );
    await _addColumnIfMissing(
      database,
      table: 'conversation_summary_segments',
      column: 'summary_content_bytes',
      definition:
          'INTEGER NOT NULL DEFAULT 0 CHECK (summary_content_bytes >= 0)',
    );
    if (repairsPreRunFailures) {
      await _requeuePreRunInboxFailures(database);
    }
  }

  static Future<void> _addColumnIfMissing(
    Database database, {
    required String table,
    required String column,
    required String definition,
  }) async {
    final columns = await _columnNames(database, table);
    if (columns.contains(column)) return;
    await database.execute(
      'ALTER TABLE "$table" ADD COLUMN "$column" $definition',
    );
  }

  static Future<void> _requeuePreRunInboxFailures(Database database) async {
    final affected = await database.rawQuery('''
      SELECT receipt.project_id,
             receipt.agent_id,
             MIN(receipt.message_sequence) AS retry_from
      FROM agent_message_receipts AS receipt
      WHERE receipt.outcome = 'failedSkipped'
        AND receipt.error_code = 'inbox_message_failed'
        AND NOT EXISTS (
          SELECT 1
          FROM agent_runs AS run
          WHERE run.project_id = receipt.project_id
            AND run.agent_id = receipt.agent_id
            AND run.source_message_sequence = receipt.message_sequence
        )
      GROUP BY receipt.project_id, receipt.agent_id
    ''');
    for (final row in affected) {
      final projectId = row['project_id']! as String;
      final agentId = row['agent_id']! as String;
      final retryFrom = row['retry_from']! as int;
      await database.rawUpdate(
        '''
        UPDATE project_turns
        SET status = 'dispatching',
            no_participant = 0,
            completed_at = NULL
        WHERE status != 'cancelled'
          AND id IN (
            SELECT receipt.turn_id
            FROM agent_message_receipts AS receipt
            WHERE receipt.project_id = ?
              AND receipt.agent_id = ?
              AND receipt.message_sequence >= ?
              AND receipt.outcome = 'failedSkipped'
              AND receipt.error_code = 'inbox_message_failed'
          )
        ''',
        <Object?>[projectId, agentId, retryFrom],
      );
      await database.delete(
        'agent_message_receipts',
        where: 'project_id = ? AND agent_id = ? AND message_sequence >= ?',
        whereArgs: <Object?>[projectId, agentId, retryFrom],
      );
      await database.update(
        'project_agent_cursors',
        <String, Object?>{
          'last_processed_message_sequence': retryFrom - 1,
          'processing_message_sequence': null,
          'worker_state': 'scheduled',
          'active_run_id': null,
          'lease_owner': '',
          'lease_expires_at': null,
          'last_error': '',
        },
        where: 'project_id = ? AND agent_id = ?',
        whereArgs: <Object?>[projectId, agentId],
      );
    }
  }

  static Future<void> _requireColumns(
    Database database,
    String table,
    Set<String> required,
  ) async {
    final columns = await _columnNames(database, table);
    final missing = required.difference(columns);
    if (missing.isNotEmpty) {
      throw FormatException(
        'Database table $table is missing columns: ${missing.join(', ')}',
      );
    }
  }

  static Future<Set<String>> _columnNames(
    Database database,
    String table,
  ) async =>
      (await database.rawQuery(
        'PRAGMA table_info("$table")',
      )).map((column) => column['name']! as String).toSet();
}
