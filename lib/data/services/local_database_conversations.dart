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
    final updatedAt = timestamp.millisecondsSinceEpoch;
    await database.transaction((transaction) async {
      // Skill activations are execution telemetry keyed by run without a
      // foreign key. Remove them before deleting the run graph so a cleared
      // conversation cannot leave dangling execution records.
      await transaction.delete(
        'skill_activations',
        where: 'project_id = ?',
        whereArgs: [id],
      );
      await transaction.delete(
        'agent_message_receipts',
        where: 'project_id = ?',
        whereArgs: [id],
      );
      await transaction.delete(
        'project_events',
        where: 'project_id = ?',
        whereArgs: [id],
      );
      // Deleting turns cascades to runs and participation decisions.
      await transaction.delete(
        'project_turns',
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
      await transaction.rawUpdate(
        '''
        UPDATE project_agent_cursors
        SET last_processed_message_sequence = 0,
            processing_message_sequence = NULL,
            worker_state = CASE
              WHEN EXISTS (
                SELECT 1 FROM project_memberships AS membership
                WHERE membership.project_id = project_agent_cursors.project_id
                  AND membership.agent_id = project_agent_cursors.agent_id
                  AND membership.status = 'active'
              ) THEN 'idle'
              ELSE 'paused'
            END,
            active_run_id = NULL,
            lease_owner = '',
            lease_expires_at = NULL,
            last_error = '',
            updated_at = ?
        WHERE project_id = ?
        ''',
        <Object?>[updatedAt, id],
      );
      // A membership without a materialized cursor is initialized from this
      // value. Keep that fallback contiguous with the reset project counter.
      await transaction.update(
        'project_memberships',
        <String, Object?>{'join_message_sequence': 0, 'updated_at': updatedAt},
        where: 'project_id = ?',
        whereArgs: [id],
      );
      await transaction.update(
        'projects',
        {
          'last_message': '',
          'last_event_sequence': 0,
          'last_message_sequence': 0,
          'last_message_at': updatedAt,
          'updated_at': updatedAt,
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
