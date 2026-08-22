part of 'local_database_service.dart';

extension LocalDatabaseConversationSummaries on LocalDatabaseService {
  Future<List<Map<String, Object?>>> loadProjectMessageRange(
    String projectId, {
    required int startMessageSequence,
    required int endMessageSequence,
  }) async {
    final database = await _databaseProvider();
    return database.query(
      'project_events',
      where:
          'project_id = ? AND message_sequence >= ? '
          "AND message_sequence <= ? AND terminal_state != 'draft'",
      whereArgs: <Object?>[projectId, startMessageSequence, endMessageSequence],
      orderBy: 'message_sequence ASC',
    );
  }

  Future<List<Map<String, Object?>>> loadConversationSummaryStateV19(
    String projectId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'conversation_summary_state',
      where: 'project_id = ?',
      whereArgs: <Object?>[projectId],
      limit: 1,
    );
  }

  Future<List<Map<String, Object?>>> loadActiveRollingSummariesV19(
    String projectId,
    int throughMessageSequence,
  ) async {
    final database = await _databaseProvider();
    return database.rawQuery(
      '''
      SELECT segment.*
      FROM conversation_summary_segments AS segment
      INNER JOIN conversation_summary_state AS state
        ON state.project_id = segment.project_id
       AND state.active_summary_set_id = segment.summary_set_id
      WHERE segment.project_id = ?
        AND segment.summary_kind = 'rolling'
        AND segment.status = 'active'
        AND segment.source_end_message_sequence <= ?
      ORDER BY segment.source_start_message_sequence ASC
      ''',
      <Object?>[projectId, throughMessageSequence],
    );
  }

  Future<List<Map<String, Object?>>> loadRangeConversationSummariesV19(
    String projectId, {
    required int limit,
  }) async {
    final database = await _databaseProvider();
    return database.query(
      'conversation_summary_segments',
      where:
          "project_id = ? AND summary_kind = 'rangeExtract' "
          "AND status = 'active'",
      whereArgs: <Object?>[projectId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  Future<bool> commitRollingConversationSummaryV19({
    required String projectId,
    required int expectedRevision,
    required Map<String, Object?> segment,
  }) async {
    final database = await _databaseProvider();
    return database.transaction((transaction) async {
      final states = await transaction.query(
        'conversation_summary_state',
        where: 'project_id = ?',
        whereArgs: <Object?>[projectId],
        limit: 1,
      );
      final revision =
          states.isEmpty ? 0 : _readCount(states.single['revision']);
      if (revision != expectedRevision) return false;
      final now = DateTime.now().millisecondsSinceEpoch;
      final previousSet =
          states.isEmpty
              ? ''
              : states.single['active_summary_set_id']?.toString() ?? '';
      final nextSet = segment['summary_set_id']?.toString() ?? '';
      final start = _readCount(segment['source_start_message_sequence']);
      final end = _readCount(segment['source_end_message_sequence']);
      final previousCoverage =
          states.isEmpty
              ? 0
              : _readCount(states.single['covered_through_message_sequence']);
      final expectedStart =
          previousSet.isEmpty || previousSet != nextSet
              ? 1
              : previousCoverage + 1;
      if (segment['project_id'] != projectId ||
          segment['summary_kind'] != 'rolling' ||
          nextSet.isEmpty ||
          start != expectedStart ||
          end < start) {
        return false;
      }
      if (previousSet.isNotEmpty && previousSet != nextSet) {
        await transaction.update(
          'conversation_summary_segments',
          <String, Object?>{'status': 'superseded', 'updated_at': now},
          where:
              "project_id = ? AND summary_set_id = ? "
              "AND summary_kind = 'rolling' AND status = 'active'",
          whereArgs: <Object?>[projectId, previousSet],
        );
      }
      await transaction.insert(
        'conversation_summary_segments',
        <String, Object?>{...segment, 'status': 'active', 'updated_at': now},
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      final coverage = end;
      await transaction.insert('conversation_summary_state', <String, Object?>{
        'project_id': projectId,
        'revision': revision + 1,
        'active_summary_set_id': nextSet,
        'covered_through_message_sequence': coverage,
        'compaction_status': 'idle',
        'last_error': '',
        'last_compacted_at': now,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    });
  }

  Future<void> saveRangeConversationSummaryV19(
    Map<String, Object?> segment,
  ) async {
    final database = await _databaseProvider();
    await database.insert('conversation_summary_segments', <String, Object?>{
      ...segment,
      'status': 'active',
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<void> setConversationSummaryCompactionStatusV19(
    String projectId,
    String status,
    String lastError,
  ) async {
    final database = await _databaseProvider();
    final now = DateTime.now().millisecondsSinceEpoch;
    await database.rawInsert(
      '''
      INSERT INTO conversation_summary_state (
        project_id, compaction_status, last_error, updated_at
      ) VALUES (?, ?, ?, ?)
      ON CONFLICT(project_id) DO UPDATE SET
        compaction_status = excluded.compaction_status,
        last_error = excluded.last_error,
        updated_at = excluded.updated_at
      ''',
      <Object?>[projectId, status, lastError, now],
    );
  }

  Future<void> invalidateConversationSummaryV19(
    String projectId,
    String segmentId,
    String error,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final rows = await transaction.query(
        'conversation_summary_segments',
        columns: const <String>[
          'summary_set_id',
          'summary_kind',
          'source_start_message_sequence',
        ],
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, segmentId],
        limit: 1,
      );
      await transaction.update(
        'conversation_summary_segments',
        <String, Object?>{'status': 'invalid', 'updated_at': now},
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, segmentId],
      );
      if (rows.isNotEmpty && rows.single['summary_kind'] == 'rolling') {
        await transaction.update(
          'conversation_summary_segments',
          <String, Object?>{'status': 'stale', 'updated_at': now},
          where:
              "project_id = ? AND summary_set_id = ? "
              "AND summary_kind = 'rolling' AND status = 'active' "
              'AND source_start_message_sequence >= ?',
          whereArgs: <Object?>[
            projectId,
            rows.single['summary_set_id'],
            rows.single['source_start_message_sequence'],
          ],
        );
      }
      await _refreshConversationSummaryStateV19(
        transaction,
        projectId,
        now: now,
        error: error,
      );
    });
  }

  Future<void> markConversationSummaryRangeStaleV19(
    String projectId,
    int startMessageSequence,
    int endMessageSequence,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await transaction.update(
        'conversation_summary_segments',
        <String, Object?>{'status': 'stale', 'updated_at': now},
        where:
            "project_id = ? AND status = 'active' "
            "AND summary_kind = 'rangeExtract' "
            'AND source_start_message_sequence <= ? '
            'AND source_end_message_sequence >= ?',
        whereArgs: <Object?>[
          projectId,
          endMessageSequence,
          startMessageSequence,
        ],
      );
      await transaction.update(
        'conversation_summary_segments',
        <String, Object?>{'status': 'stale', 'updated_at': now},
        where:
            "project_id = ? AND status = 'active' "
            "AND summary_kind = 'rolling' "
            'AND source_end_message_sequence >= ?',
        whereArgs: <Object?>[projectId, startMessageSequence],
      );
      await _refreshConversationSummaryStateV19(
        transaction,
        projectId,
        now: now,
        error: 'summary_source_changed',
      );
    });
  }

  Future<void> deleteConversationSummariesV19(String projectId) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.delete(
        'conversation_summary_segments',
        where: 'project_id = ?',
        whereArgs: <Object?>[projectId],
      );
      await transaction.delete(
        'conversation_summary_state',
        where: 'project_id = ?',
        whereArgs: <Object?>[projectId],
      );
    });
  }

  Future<void> saveAgentMemoryEvolutionRun(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await _upsertByPrimaryKey(
      database,
      'agent_memory_evolution_runs',
      values,
      'id',
    );
  }

  Future<List<Map<String, Object?>>> loadAgentMemoryEvolutionRuns(
    String agentId, {
    required int limit,
  }) async {
    final database = await _databaseProvider();
    return database.query(
      'agent_memory_evolution_runs',
      where: 'agent_id = ?',
      whereArgs: <Object?>[agentId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  static Future<void> _refreshConversationSummaryStateV19(
    DatabaseExecutor transaction,
    String projectId, {
    required int now,
    required String error,
  }) async {
    final states = await transaction.query(
      'conversation_summary_state',
      where: 'project_id = ?',
      whereArgs: <Object?>[projectId],
      limit: 1,
    );
    if (states.isEmpty) return;
    final activeSet = states.single['active_summary_set_id']?.toString() ?? '';
    final coverageRows = await transaction.rawQuery(
      '''
      SELECT COALESCE(MAX(source_end_message_sequence), 0) AS coverage
      FROM conversation_summary_segments
      WHERE project_id = ? AND summary_set_id = ?
        AND summary_kind = 'rolling' AND status = 'active'
      ''',
      <Object?>[projectId, activeSet],
    );
    final coverage = _readCount(coverageRows.single['coverage']);
    await transaction.update(
      'conversation_summary_state',
      <String, Object?>{
        'revision': _readCount(states.single['revision']) + 1,
        'active_summary_set_id': coverage == 0 ? '' : activeSet,
        'covered_through_message_sequence': coverage,
        'compaction_status': 'failed',
        'last_error': error,
        'updated_at': now,
      },
      where: 'project_id = ?',
      whereArgs: <Object?>[projectId],
    );
  }
}
