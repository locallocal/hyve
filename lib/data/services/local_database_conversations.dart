part of 'local_database_service.dart';

extension LocalDatabaseConversations on LocalDatabaseService {
  Future<List<Map<String, Object?>>> loadChats() async {
    final database = await _databaseProvider();
    final chats = await database.rawQuery('''
      SELECT
        id,
        last_message,
        last_message_at AS last_message_timestamp,
        created_at AS create_timestamp,
        updated_at AS modify_timestamp,
        name AS project_name
      FROM projects
      WHERE EXISTS (
        SELECT 1 FROM project_memberships AS membership
        WHERE membership.project_id = projects.id
          AND membership.status != 'removed'
      )
      ORDER BY last_message_at DESC
      ''');
    return _attachProjectMetadata(database, chats);
  }

  Future<List<Map<String, Object?>>> loadChat(String id) async {
    final database = await _databaseProvider();
    final chats = await database.rawQuery(
      '''
      SELECT
        id,
        last_message,
        last_message_at AS last_message_timestamp,
        created_at AS create_timestamp,
        updated_at AS modify_timestamp,
        name AS project_name
      FROM projects
      WHERE id = ? AND EXISTS (
        SELECT 1 FROM project_memberships AS membership
        WHERE membership.project_id = projects.id
          AND membership.status != 'removed'
      )
      LIMIT 1
      ''',
      [id],
    );
    return _attachProjectMetadata(database, chats);
  }

  Future<void> insertChat(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await _upsertByPrimaryKey(
      database,
      'projects',
      _legacyChatToProject(values, name: ''),
      'id',
    );
  }

  Future<void> insertChatProject({
    required Map<String, Object?> chat,
    required String name,
    required Iterable<String> botIds,
  }) async {
    final database = await _databaseProvider();
    final ids = <String>{...botIds}..remove('');
    await database.transaction((transaction) async {
      final chatId = chat['id']?.toString() ?? '';
      await _upsertByPrimaryKey(
        transaction,
        'projects',
        _legacyChatToProject(chat, name: name),
        'id',
      );
      await transaction.delete(
        'project_memberships',
        where: 'project_id = ?',
        whereArgs: [chatId],
      );
      var position = 0;
      for (final botId in ids) {
        final timestamp =
            chat['modify_timestamp'] as int? ??
            DateTime.now().millisecondsSinceEpoch;
        await transaction.insert('project_memberships', <String, Object?>{
          'project_id': chatId,
          'agent_id': botId,
          'status': 'active',
          'position': position++,
          'project_storage_access': 'read',
          'capability_restrictions_json': '{}',
          'membership_generation': 1,
          'join_message_sequence': 0,
          'joined_at': timestamp,
          'removed_at': null,
          'updated_at': timestamp,
        });
      }
    });
  }

  Future<List<Map<String, Object?>>> _attachProjectMetadata(
    DatabaseExecutor database,
    List<Map<String, Object?>> chats,
  ) async {
    if (chats.isEmpty) return chats;
    final bindings = await database.query(
      'project_memberships',
      where: "status != 'removed'",
      orderBy: 'project_id ASC, position ASC',
    );
    final botIds = <String, List<String>>{};
    for (final binding in bindings) {
      final chatId = binding['project_id']?.toString() ?? '';
      final botId = binding['agent_id']?.toString() ?? '';
      if (chatId.isEmpty || botId.isEmpty) continue;
      botIds.putIfAbsent(chatId, () => <String>[]).add(botId);
    }
    return <Map<String, Object?>>[
      for (final chat in chats)
        <String, Object?>{
          ...chat,
          'project_bot_ids': jsonEncode(botIds[chat['id']] ?? const <String>[]),
        },
    ];
  }

  Future<void> deleteChat(String id) async {
    final database = await _databaseProvider();
    await database.delete('projects', where: 'id = ?', whereArgs: [id]);
    _advanceMessageRevision(id);
  }

  Future<void> updateChatPreview(
    String id, {
    required String content,
    required DateTime timestamp,
  }) async {
    final database = await _databaseProvider();
    await database.update(
      'projects',
      {
        'last_message': content,
        'last_message_at': timestamp.millisecondsSinceEpoch,
        'updated_at': timestamp.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearChatHistory(String id, DateTime timestamp) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.delete(
        'project_events',
        where: 'project_id = ?',
        whereArgs: [id],
      );
      await transaction.delete(
        'conversation_summary_segments',
        where: 'project_id = ?',
        whereArgs: [id],
      );
      await transaction.delete(
        'conversation_summary_state',
        where: 'project_id = ?',
        whereArgs: [id],
      );
      await transaction.update(
        'projects',
        {
          'last_message': '',
          'last_event_sequence': 0,
          'last_message_sequence': 0,
          'last_message_at': timestamp.millisecondsSinceEpoch,
          'updated_at': timestamp.millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });
    _advanceMessageRevision(id);
  }

  Future<List<Map<String, Object?>>> loadMessages(String chatId) async {
    final database = await _databaseProvider();
    return database.rawQuery(
      '${_legacyMessageSelect()} '
      'WHERE event.project_id = ? AND event.message_sequence IS NOT NULL '
      'ORDER BY event.created_at ASC, event.id ASC',
      [chatId],
    );
  }

  Future<List<Map<String, Object?>>> loadMessagePage(
    String chatId, {
    int? beforeTimestamp,
    String? beforeMessageId,
    required int limit,
  }) async {
    if (limit < 1 || limit > 200) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 200.');
    }
    final database = await _databaseProvider();
    final hasCursor = beforeTimestamp != null && beforeMessageId != null;
    return database.rawQuery(
      '${_legacyMessageSelect()} '
      'WHERE event.project_id = ? AND event.message_sequence IS NOT NULL '
      '${hasCursor ? 'AND (event.created_at < ? OR '
              '(event.created_at = ? AND event.id < ?)) ' : ''}'
      'ORDER BY event.created_at DESC, event.id DESC LIMIT ?',
      hasCursor
          ? [
            chatId,
            beforeTimestamp,
            beforeTimestamp,
            beforeMessageId,
            limit + 1,
          ]
          : [chatId, limit + 1],
    );
  }

  Future<Set<String>> loadBotIdsForChat(String chatId) async {
    final database = await _databaseProvider();
    final records = await database.query(
      'project_events',
      columns: const ['actor_id'],
      distinct: true,
      where: "project_id = ? AND actor_type = 'agent' AND actor_id != ''",
      whereArgs: [chatId],
    );
    return {for (final record in records) record['actor_id']?.toString() ?? ''}
      ..remove('');
  }

  Future<List<Map<String, Object?>>> loadConversationMemoryState(
    String chatId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'conversation_memory_state',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      limit: 1,
    );
  }

  Future<List<Map<String, Object?>>> loadActiveConversationSummary(
    String chatId,
  ) async {
    final database = await _databaseProvider();
    return database.rawQuery(
      '''
      SELECT segment.*
      FROM conversation_summary_segments AS segment
      INNER JOIN conversation_memory_state AS state
        ON state.chat_id = segment.chat_id
       AND state.active_summary_id = segment.id
      WHERE segment.chat_id = ? AND segment.status = 'active'
      LIMIT 1
      ''',
      [chatId],
    );
  }

  Future<List<Map<String, Object?>>> loadConversationMemoryItems(
    String chatId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'conversation_memory_items',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: "CASE state WHEN 'pinned' THEN 0 ELSE 1 END, updated_at DESC",
    );
  }

  Future<void> invalidateConversationSummary(
    String chatId,
    String summaryId,
    String error,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await transaction.update(
        'conversation_summary_segments',
        {'status': 'invalid', 'updated_at': now},
        where: 'chat_id = ? AND id = ?',
        whereArgs: [chatId, summaryId],
      );
      await transaction.rawUpdate(
        '''
        UPDATE conversation_memory_state
        SET revision = revision + 1,
            active_summary_id = '',
            covered_through_message_id = '',
            compaction_status = 'failed',
            last_error = ?,
            updated_at = ?
        WHERE chat_id = ? AND active_summary_id = ?
        ''',
        [error, now, chatId, summaryId],
      );
    });
  }

  Future<bool> commitConversationCompaction({
    required String chatId,
    required int expectedRevision,
    required Map<String, Object?> summary,
    required Iterable<Map<String, Object?>> items,
  }) async {
    final database = await _databaseProvider();
    return database.transaction((transaction) async {
      final stateRows = await transaction.query(
        'conversation_memory_state',
        where: 'chat_id = ?',
        whereArgs: [chatId],
        limit: 1,
      );
      final currentRevision =
          stateRows.isEmpty ? 0 : _readCount(stateRows.first['revision']);
      if (currentRevision != expectedRevision) return false;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (stateRows.isNotEmpty) {
        final activeId = stateRows.first['active_summary_id']?.toString() ?? '';
        if (activeId.isNotEmpty) {
          await transaction.update(
            'conversation_summary_segments',
            {'status': 'superseded', 'updated_at': now},
            where: 'id = ? AND chat_id = ?',
            whereArgs: [activeId, chatId],
          );
        }
      }
      await transaction.insert(
        'conversation_summary_segments',
        {...summary, 'status': 'active', 'updated_at': now},
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      for (final item in items) {
        final memoryKey = item['memory_key']?.toString() ?? '';
        final existing = await transaction.query(
          'conversation_memory_items',
          columns: ['state', 'origin'],
          where: 'chat_id = ? AND memory_key = ?',
          whereArgs: [chatId, memoryKey],
          limit: 1,
        );
        final protected =
            existing.isNotEmpty &&
            (existing.first['origin'] == 'user' ||
                existing.first['state'] == 'pinned' ||
                existing.first['state'] == 'forgotten');
        if (!protected) {
          await transaction.insert(
            'conversation_memory_items',
            item,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      final state = <String, Object?>{
        'chat_id': chatId,
        'revision': currentRevision + 1,
        'active_summary_id': summary['id'],
        'covered_through_message_id': summary['source_end_message_id'],
        'auto_memory_enabled':
            stateRows.isEmpty
                ? 1
                : _readCount(stateRows.first['auto_memory_enabled']),
        'compaction_status': 'idle',
        'last_error': '',
        'last_compacted_at': now,
        'updated_at': now,
      };
      await transaction.insert(
        'conversation_memory_state',
        state,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    });
  }

  Future<void> upsertConversationMemoryItem(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.insert(
      'conversation_memory_items',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateConversationMemoryItemState(
    String chatId,
    String itemId,
    String state,
  ) async {
    final database = await _databaseProvider();
    await database.update(
      'conversation_memory_items',
      {'state': state, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'chat_id = ? AND id = ?',
      whereArgs: [chatId, itemId],
    );
  }

  Future<void> setConversationAutoMemoryEnabled(
    String chatId,
    bool enabled,
  ) async {
    final database = await _databaseProvider();
    final now = DateTime.now().millisecondsSinceEpoch;
    await database.rawInsert(
      '''
      INSERT INTO conversation_memory_state (
        chat_id, auto_memory_enabled, updated_at
      ) VALUES (?, ?, ?)
      ON CONFLICT(chat_id) DO UPDATE SET
        auto_memory_enabled = excluded.auto_memory_enabled,
        updated_at = excluded.updated_at
      ''',
      [chatId, enabled ? 1 : 0, now],
    );
  }

  Future<void> setConversationCompactionStatus(
    String chatId,
    String status,
    String lastError,
  ) async {
    final database = await _databaseProvider();
    final now = DateTime.now().millisecondsSinceEpoch;
    await database.rawInsert(
      '''
      INSERT INTO conversation_memory_state (
        chat_id, compaction_status, last_error, updated_at
      ) VALUES (?, ?, ?, ?)
      ON CONFLICT(chat_id) DO UPDATE SET
        compaction_status = excluded.compaction_status,
        last_error = excluded.last_error,
        updated_at = excluded.updated_at
      ''',
      [chatId, status, lastError, now],
    );
  }

  Future<void> clearAutomaticConversationMemory(String chatId) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.delete(
        'conversation_summary_segments',
        where: 'chat_id = ?',
        whereArgs: [chatId],
      );
      await transaction.delete(
        'conversation_memory_items',
        where: "chat_id = ? AND origin = 'auto' AND state != 'forgotten'",
        whereArgs: [chatId],
      );
      final updated = await transaction.update(
        'conversation_memory_state',
        {
          'revision': 0,
          'active_summary_id': '',
          'covered_through_message_id': '',
          'compaction_status': 'idle',
          'last_error': '',
          'last_compacted_at': null,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'chat_id = ?',
        whereArgs: [chatId],
      );
      if (updated == 0) {
        await transaction.insert('conversation_memory_state', {
          'chat_id': chatId,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
  }

  Future<void> deleteConversationMemory(String chatId) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await _deleteConversationMemory(transaction, chatId);
    });
  }

  static Future<void> _deleteConversationMemory(
    DatabaseExecutor database,
    String chatId,
  ) async {
    await database.delete(
      'conversation_summary_segments',
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );
    await database.delete(
      'conversation_memory_items',
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );
    await database.delete(
      'conversation_memory_state',
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );
  }
}

Map<String, Object?> _legacyChatToProject(
  Map<String, Object?> chat, {
  required String name,
}) {
  final createdAt = _readCount(chat['create_timestamp']);
  final updatedAt = _readCount(chat['modify_timestamp']);
  final lastMessageAt = _readCount(chat['last_message_timestamp']);
  return <String, Object?>{
    'id': chat['id'],
    'name': name.trim().isEmpty ? 'Project' : name.trim(),
    'ui_metadata_json': '{}',
    'response_policy_json': _defaultProjectResponsePolicyJson,
    'last_event_sequence': 0,
    'last_message_sequence': 0,
    'last_message': chat['last_message']?.toString() ?? '',
    'last_message_at': lastMessageAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

const _defaultProjectResponsePolicyJson =
    '{"schemaVersion":1,"broadcastDecision":{"concurrency":4,'
    '"maxInputTokens":4096,"maxOutputTokens":128,"timeoutMs":10000,'
    '"maxAttempts":1,"failureOutcome":"pass"},"replyConcurrency":2,'
    '"autonomousChain":{"maxDepth":4,"maxAgentMessagesPerRoot":16},'
    '"delivery":{"defaultVisibility":"project","maxDepth":4,'
    '"maxDeliveriesPerTurn":8}}';

String _legacyMessageSelect() => '''
  SELECT
    event.id AS message_id,
    event.turn_id,
    event.run_id,
    event.project_id AS chat_id,
    CASE WHEN event.actor_type = 'agent' THEN event.actor_id ELSE '' END
      AS bot_id,
    COALESCE((
      SELECT json_group_array(agent_id)
      FROM project_event_targets
      WHERE event_id = event.id
      ORDER BY position ASC
    ), '[]') AS target_bot_ids,
    event.actor_id AS sender_id,
    event.content,
    json_extract(event.payload_json, '\$.reasoning') AS reasoning,
    json_extract(event.payload_json, '\$.processInfoJson') AS process_info,
    json_extract(event.payload_json, '\$.images') AS images,
    json_extract(event.payload_json, '\$.files') AS files,
    json_extract(event.payload_json, '\$.audio') AS audio,
    json_extract(event.payload_json, '\$.music') AS music,
    json_extract(event.payload_json, '\$.video') AS video,
    COALESCE(usage.token_model, '') AS token_model,
    COALESCE(usage.input_token_count, 0) AS input_token_count,
    COALESCE(usage.output_token_count, 0) AS output_token_count,
    COALESCE(usage.total_token_count, 0) AS total_token_count,
    event.terminal_state,
    event.has_partial_content,
    event.created_at AS timestamp
  FROM project_events AS event
  LEFT JOIN token_usage_records AS usage ON usage.operation_id = event.id
''';
