import 'package:sqflite/sqflite.dart';

typedef DatabaseProvider = Future<Database> Function();

/// Stateless boundary around sqflite. Repositories never open databases or
/// assemble cross-table transactions themselves.
class LocalDatabaseService {
  const LocalDatabaseService({required DatabaseProvider databaseProvider})
    : _databaseProvider = databaseProvider;

  final DatabaseProvider _databaseProvider;

  Future<List<Map<String, Object?>>> loadBots() async {
    final database = await _databaseProvider();
    return database.query('bots', orderBy: 'create_timestamp ASC');
  }

  Future<List<Map<String, Object?>>> loadBot(String id) async {
    final database = await _databaseProvider();
    return database.query('bots', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  Future<void> insertBot(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.insert(
      'bots',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateBot(String id, Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.update('bots', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteBot(String id) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.delete(
        'bot_skill_bindings',
        where: 'bot_id = ?',
        whereArgs: [id],
      );
      await transaction.delete('bots', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Map<String, Object?>>> loadSkills() async {
    final database = await _databaseProvider();
    return database.query('skills', orderBy: 'name ASC');
  }

  Future<List<Map<String, Object?>>> loadSkill(String id) async {
    final database = await _databaseProvider();
    return database.query('skills', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  Future<List<Map<String, Object?>>> loadSkillByScopeAndName(
    String scope,
    String name,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'skills',
      where: 'scope = ? AND name = ?',
      whereArgs: [scope, name],
      limit: 1,
    );
  }

  Future<void> upsertSkill(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.insert(
      'skills',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSkill(String id) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.delete(
        'bot_skill_bindings',
        where: 'skill_id = ?',
        whereArgs: [id],
      );
      await transaction.delete('skills', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Map<String, Object?>>> loadBotSkillBindings(String botId) async {
    final database = await _databaseProvider();
    return database.query(
      'bot_skill_bindings',
      where: 'bot_id = ?',
      whereArgs: [botId],
      orderBy: 'priority DESC, skill_id ASC',
    );
  }

  Future<void> upsertBotSkillBinding(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.insert(
      'bot_skill_bindings',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBotSkillBinding(String botId, String skillId) async {
    final database = await _databaseProvider();
    await database.delete(
      'bot_skill_bindings',
      where: 'bot_id = ? AND skill_id = ?',
      whereArgs: [botId, skillId],
    );
  }

  Future<void> upsertSkillActivations(
    Iterable<Map<String, Object?>> records,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      for (final values in records) {
        await transaction.insert(
          'skill_activations',
          values,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Map<String, Object?>>> loadSkillActivationsForRun(
    String runId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'skill_activations',
      where: 'run_id = ?',
      whereArgs: [runId],
      orderBy: 'started_at ASC, id ASC',
    );
  }

  Future<List<Map<String, Object?>>> loadChats() async {
    final database = await _databaseProvider();
    return database.query('chats', orderBy: 'last_message_timestamp DESC');
  }

  Future<List<Map<String, Object?>>> loadChat(String id) async {
    final database = await _databaseProvider();
    return database.query('chats', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  Future<void> insertChat(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.insert(
      'chats',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteChat(String id) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.delete(
        'messages',
        where: 'chat_id = ?',
        whereArgs: [id],
      );
      await transaction.delete(
        'token_usage_records',
        where: 'chat_id = ?',
        whereArgs: [id],
      );
      await transaction.delete('chats', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> updateChatPreview(
    String id, {
    required String content,
    required DateTime timestamp,
  }) async {
    final database = await _databaseProvider();
    await database.update(
      'chats',
      {
        'last_message': content,
        'last_message_timestamp': timestamp.millisecondsSinceEpoch,
        'modify_timestamp': timestamp.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearChatHistory(String id, DateTime timestamp) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.delete(
        'messages',
        where: 'chat_id = ?',
        whereArgs: [id],
      );
      await transaction.update(
        'chats',
        {
          'last_message': '',
          'last_message_timestamp': timestamp.millisecondsSinceEpoch,
          'modify_timestamp': timestamp.millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<List<Map<String, Object?>>> loadMessages(String chatId) async {
    final database = await _databaseProvider();
    return database.query(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );
  }

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
      WHERE bot_id = ?
      ''',
      [botId],
    );
    return rows.single;
  }

  Future<List<Map<String, Object?>>> loadTokenUsageByChatForBot(
    String botId,
  ) async {
    final database = await _databaseProvider();
    return database.rawQuery(
      '''
      SELECT
        chat_id,
        input_token_count,
        output_token_count,
        total_token_count
      FROM (
        SELECT
          chat_id,
          COALESCE(SUM(input_token_count), 0) AS input_token_count,
          COALESCE(SUM(output_token_count), 0) AS output_token_count,
          COALESCE(SUM(
            CASE
              WHEN total_token_count > 0 THEN total_token_count
              ELSE input_token_count + output_token_count
            END
          ), 0) AS total_token_count
        FROM token_usage_records
        WHERE bot_id = ?
        GROUP BY chat_id
      ) AS usage_by_chat
      WHERE total_token_count > 0
      ORDER BY total_token_count DESC, chat_id ASC
      ''',
      [botId],
    );
  }

  Future<List<Map<String, Object?>>> loadTokenUsageRecordsForChat(
    String chatId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'token_usage_records',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );
  }

  Future<List<Map<String, Object?>>> loadTokenUsageRecordsForBot(
    String botId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'token_usage_records',
      where: 'bot_id = ?',
      whereArgs: [botId],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> upsertMessage(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await _upsertMessageAndTokenUsage(transaction, values);
    });
  }

  Future<void> upsertMessages(Iterable<Map<String, Object?>> records) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      for (final values in records) {
        await _upsertMessageAndTokenUsage(transaction, values);
      }
    });
  }

  Future<void> deleteMessages(String chatId) async {
    final database = await _databaseProvider();
    await database.delete(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );
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
    await database.insert(
      'messages',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final messageId = values['message_id']?.toString() ?? '';
    if (messageId.isEmpty) return;
    final inputTokens = _readCount(values['input_token_count']);
    final outputTokens = _readCount(values['output_token_count']);
    final totalTokens = _readCount(values['total_token_count']);
    final hasUsage = inputTokens > 0 || outputTokens > 0 || totalTokens > 0;
    if (!hasUsage) {
      await database.delete(
        'token_usage_records',
        where: 'message_id = ?',
        whereArgs: [messageId],
      );
      return;
    }

    await database.insert('token_usage_records', <String, Object?>{
      'message_id': messageId,
      'chat_id': values['chat_id']?.toString() ?? '',
      'bot_id': values['bot_id']?.toString() ?? '',
      'token_model': values['token_model']?.toString() ?? '',
      'input_token_count': inputTokens,
      'output_token_count': outputTokens,
      'total_token_count': totalTokens,
      'timestamp': _readCount(values['timestamp']),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

int _readCount(Object? value) {
  return switch (value) {
    final int count => count,
    final num count => count.toInt(),
    _ => int.tryParse(value?.toString() ?? '') ?? 0,
  };
}
