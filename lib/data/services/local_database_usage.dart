part of 'local_database_service.dart';

extension LocalDatabaseUsage on LocalDatabaseService {
  Future<Map<String, Object?>> loadTokenUsageForBot(String botId) async {
    final database = await _databaseProvider();
    final rows = await database.rawQuery(
      '''
      SELECT
        COALESCE(SUM(input_token_count), 0) AS input_token_count,
        COALESCE(SUM(output_token_count), 0) AS output_token_count,
        COALESCE(SUM(
          CASE
            WHEN total_token_count > 0 THEN total_token_count
            ELSE input_token_count + output_token_count
          END
        ), 0) AS total_token_count
      FROM token_usage_records
      WHERE agent_id = ?
      ''',
      [botId],
    );
    return rows.single;
  }

  Future<List<Map<String, Object?>>> loadTokenUsageForBots(
    Iterable<String> botIds,
  ) async {
    final ids = botIds.toSet().toList(growable: false);
    if (ids.isEmpty) return const [];
    final database = await _databaseProvider();
    final placeholders = List.filled(ids.length, '?').join(',');
    return database.rawQuery('''
      SELECT
        agent_id AS bot_id,
        COALESCE(SUM(input_token_count), 0) AS input_token_count,
        COALESCE(SUM(output_token_count), 0) AS output_token_count,
        COALESCE(SUM(
          CASE
            WHEN total_token_count > 0 THEN total_token_count
            ELSE input_token_count + output_token_count
          END
        ), 0) AS total_token_count
      FROM token_usage_records
      WHERE agent_id IN ($placeholders)
      GROUP BY agent_id
      ''', ids);
  }

  Future<List<Map<String, Object?>>> loadTokenUsageByChatForBot(
    String botId,
  ) async {
    final database = await _databaseProvider();
    return database.rawQuery(
      '''
      SELECT
        project_id AS chat_id,
        input_token_count,
        output_token_count,
        total_token_count
      FROM (
        SELECT
          project_id,
          COALESCE(SUM(input_token_count), 0) AS input_token_count,
          COALESCE(SUM(output_token_count), 0) AS output_token_count,
          COALESCE(SUM(
            CASE
              WHEN total_token_count > 0 THEN total_token_count
              ELSE input_token_count + output_token_count
            END
          ), 0) AS total_token_count
        FROM token_usage_records
        WHERE agent_id = ?
        GROUP BY project_id
      ) AS usage_by_chat
      WHERE total_token_count > 0
      ORDER BY total_token_count DESC, project_id ASC
      ''',
      [botId],
    );
  }

  Future<List<Map<String, Object?>>> loadTokenUsageRecordsForChat(
    String chatId,
  ) async {
    final database = await _databaseProvider();
    return database.rawQuery(
      '${_legacyUsageSelect()} WHERE project_id = ? '
      'ORDER BY timestamp ASC, operation_id ASC',
      [chatId],
    );
  }

  Future<List<Map<String, Object?>>> loadTokenUsageRecordsForBot(
    String botId,
  ) async {
    final database = await _databaseProvider();
    return database.rawQuery(
      '${_legacyUsageSelect()} WHERE agent_id = ? '
      'ORDER BY timestamp ASC, operation_id ASC',
      [botId],
    );
  }

  Future<void> upsertMessage(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await _upsertMessageAndTokenUsage(transaction, values);
    });
    final chatId = values['chat_id']?.toString();
    if (chatId != null && chatId.isNotEmpty) _advanceMessageRevision(chatId);
  }

  Future<void> upsertMessages(Iterable<Map<String, Object?>> records) async {
    final rows = records.toList(growable: false);
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      for (final values in rows) {
        await _upsertMessageAndTokenUsage(transaction, values);
      }
    });
    final chatIds = <String>{
      for (final values in rows)
        if ((values['chat_id']?.toString() ?? '').isNotEmpty)
          values['chat_id']!.toString(),
    };
    for (final chatId in chatIds) {
      _advanceMessageRevision(chatId);
    }
  }

  Future<void> upsertModelUsage(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    final normalized = _legacyUsageToCurrent(values);
    await database.insert(
      'token_usage_records',
      normalized,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMessages(String chatId) async {
    final database = await _databaseProvider();
    await database.delete(
      'project_events',
      where: 'project_id = ?',
      whereArgs: [chatId],
    );
    _advanceMessageRevision(chatId);
  }

  Future<List<Map<String, Object?>>> loadProfiles() async {
    final database = await _databaseProvider();
    return database.query('profile', limit: 1);
  }

  Future<void> insertProfile(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.insert('profile', values);
  }

  Future<void> updateProfile(Object id, Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.update('profile', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _upsertMessageAndTokenUsage(
    DatabaseExecutor database,
    Map<String, Object?> values,
  ) async {
    await _upsertLegacyMessageAsEvent(database, values);

    final messageId = values['message_id']?.toString() ?? '';
    if (messageId.isEmpty) return;
    final inputTokens = _readCount(values['input_token_count']);
    final outputTokens = _readCount(values['output_token_count']);
    final totalTokens = _readCount(values['total_token_count']);
    final hasUsage = inputTokens > 0 || outputTokens > 0 || totalTokens > 0;
    if (!hasUsage) {
      await database.delete(
        'token_usage_records',
        where: 'operation_id = ?',
        whereArgs: [messageId],
      );
      return;
    }

    await database.insert('token_usage_records', <String, Object?>{
      'operation_id': messageId,
      'project_id': values['chat_id']?.toString() ?? '',
      'agent_id': values['bot_id']?.toString() ?? '',
      'run_id': values['run_id']?.toString() ?? '',
      'operation_kind': 'chat_reply',
      'token_model': values['token_model']?.toString() ?? '',
      'input_token_count': inputTokens,
      'output_token_count': outputTokens,
      'total_token_count': totalTokens,
      'timestamp': _readCount(values['timestamp']),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

Future<void> _upsertLegacyMessageAsEvent(
  DatabaseExecutor database,
  Map<String, Object?> values,
) async {
  final messageId = values['message_id']?.toString() ?? '';
  final projectId = values['chat_id']?.toString() ?? '';
  if (messageId.isEmpty || projectId.isEmpty) {
    throw const FormatException('A persisted message requires stable ids.');
  }
  final existing = await database.query(
    'project_events',
    columns: const ['sequence', 'message_sequence', 'created_at'],
    where: 'id = ?',
    whereArgs: [messageId],
    limit: 1,
  );
  final projectRows = await database.query(
    'projects',
    columns: const ['last_event_sequence', 'last_message_sequence'],
    where: 'id = ?',
    whereArgs: [projectId],
    limit: 1,
  );
  if (projectRows.isEmpty) {
    throw StateError('Cannot persist a message for a missing Project.');
  }
  final project = projectRows.single;
  final sequence =
      existing.isEmpty
          ? _readCount(project['last_event_sequence']) + 1
          : _readCount(existing.single['sequence']);
  final messageSequence =
      existing.isEmpty
          ? _readCount(project['last_message_sequence']) + 1
          : _readCount(existing.single['message_sequence']);
  final botId = values['bot_id']?.toString() ?? '';
  final senderId = values['sender_id']?.toString() ?? '';
  final timestamp = _readCount(values['timestamp']);
  final payload = jsonEncode(<String, Object?>{
    'reasoning': values['reasoning']?.toString() ?? '',
    'processInfoJson': values['process_info']?.toString() ?? '',
    'images': _decodeStringList(values['images'], 'images'),
    'files': _decodeStringList(values['files'], 'files'),
    'audio': values['audio']?.toString() ?? '',
    'music': values['music']?.toString() ?? '',
    'video': values['video']?.toString() ?? '',
  });
  final oldTerminal = values['terminal_state']?.toString() ?? '';
  final terminal = switch (oldTerminal) {
    '' || 'completed' => 'completed',
    'cancelled' => 'cancelled',
    _ => 'failed',
  };
  final eventValues = <String, Object?>{
    'id': messageId,
    'project_id': projectId,
    'turn_id': values['turn_id']?.toString() ?? '',
    'run_id': values['run_id']?.toString() ?? '',
    'sequence': sequence,
    'message_sequence': messageSequence,
    'event_type': botId.isEmpty ? 'userMessage' : 'agentMessage',
    'actor_type': botId.isEmpty ? 'user' : 'agent',
    'actor_id': botId.isEmpty ? senderId : botId,
    'actor_name_snapshot': '',
    'actor_avatar_snapshot': '',
    'visibility': 'project',
    'reply_to_event_id': '',
    'reply_to_message_sequence': null,
    'root_message_id': messageId,
    'autonomous_depth': 0,
    'content': values['content']?.toString() ?? '',
    'payload_json': payload,
    'terminal_state': terminal,
    'has_partial_content': _readCount(values['has_partial_content']),
    'created_at':
        existing.isEmpty
            ? timestamp
            : _readCount(existing.single['created_at']),
    'updated_at': timestamp,
  };
  final updated = await database.update(
    'project_events',
    eventValues,
    where: 'id = ?',
    whereArgs: [messageId],
  );
  if (updated == 0) await database.insert('project_events', eventValues);
  await database.delete(
    'project_event_targets',
    where: 'event_id = ?',
    whereArgs: [messageId],
  );
  var position = 0;
  for (final targetId in _decodeStringList(
    values['target_bot_ids'],
    'target_bot_ids',
  )) {
    await database.insert('project_event_targets', <String, Object?>{
      'event_id': messageId,
      'agent_id': targetId,
      'target_kind': 'mention',
      'position': position++,
    });
  }
  await database.rawUpdate(
    '''
    UPDATE projects
    SET last_event_sequence = MAX(last_event_sequence, ?),
        last_message_sequence = MAX(last_message_sequence, ?),
        last_message = ?,
        last_message_at = ?,
        updated_at = MAX(updated_at, ?)
    WHERE id = ?
    ''',
    [
      sequence,
      messageSequence,
      values['content'],
      timestamp,
      timestamp,
      projectId,
    ],
  );
}

List<String> _decodeStringList(Object? raw, String field) {
  if (raw is! String) throw FormatException('$field must be JSON text.');
  final decoded = jsonDecode(raw);
  if (decoded is! List<Object?> || decoded.any((item) => item is! String)) {
    throw FormatException('$field must contain a string list.');
  }
  return decoded.cast<String>();
}

Map<String, Object?> _legacyUsageToCurrent(Map<String, Object?> values) =>
    <String, Object?>{
      'operation_id': values['operation_id'] ?? values['message_id'],
      'project_id': values['project_id'] ?? values['chat_id'] ?? '',
      'agent_id': values['agent_id'] ?? values['bot_id'] ?? '',
      'run_id': values['run_id'] ?? '',
      'operation_kind': values['operation_kind'] ?? 'chat_reply',
      'token_model': values['token_model'] ?? '',
      'input_token_count': _readCount(values['input_token_count']),
      'output_token_count': _readCount(values['output_token_count']),
      'total_token_count': _readCount(values['total_token_count']),
      'timestamp': _readCount(values['timestamp']),
    };

String _legacyUsageSelect() => '''
  SELECT
    operation_id AS message_id,
    project_id AS chat_id,
    agent_id AS bot_id,
    operation_kind,
    token_model,
    input_token_count,
    output_token_count,
    total_token_count,
    timestamp
  FROM token_usage_records
''';

int _readCount(Object? value) {
  return switch (value) {
    final int count => count,
    final num count => count.toInt(),
    _ => int.tryParse(value?.toString() ?? '') ?? 0,
  };
}
