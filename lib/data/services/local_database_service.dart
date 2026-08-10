import 'package:sqflite/sqflite.dart';

typedef DatabaseProvider = Future<Database> Function();

/// Boundary around sqflite. Repositories never open databases or assemble
/// cross-table transactions themselves.
class LocalDatabaseService {
  LocalDatabaseService({required DatabaseProvider databaseProvider})
    : _databaseProvider = databaseProvider;

  final DatabaseProvider _databaseProvider;
  final Map<String, int> _messageRevisions = <String, int>{};

  int messageRevision(String chatId) => _messageRevisions[chatId] ?? 0;

  void _advanceMessageRevision(String chatId) {
    _messageRevisions[chatId] = messageRevision(chatId) + 1;
  }

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
      await transaction.delete(
        'token_usage_records',
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

  Future<List<Map<String, Object?>>> queryInstalledSkillInventory({
    required String query,
    required int limit,
  }) async {
    final database = await _databaseProvider();
    return database.rawQuery(
      '''
      SELECT
        s.id,
        s.name,
        s.description,
        s.version,
        s.scope,
        s.trust_state,
        s.validation_status,
        s.signature_status,
        s.installed_at,
        s.updated_at,
        COUNT(DISTINCT b.bot_id) AS bound_bot_count,
        COUNT(DISTINCT CASE WHEN b.enabled = 1 THEN b.bot_id END)
          AS enabled_bot_count
      FROM skills AS s
      LEFT JOIN bot_skill_bindings AS b ON b.skill_id = s.id
      WHERE ? = ''
        OR instr(lower(s.name), ?) > 0
        OR instr(lower(s.description), ?) > 0
      GROUP BY s.id
      ORDER BY lower(s.name) ASC, s.id ASC
      LIMIT ?
    ''',
      [query, query, query, limit],
    );
  }

  Future<List<Map<String, Object?>>> queryConversationSkillInventory(
    String chatId,
  ) async {
    final database = await _databaseProvider();
    return database.rawQuery(
      '''
      WITH current_chat AS (
        SELECT id AS chat_id, bot_id
        FROM chats
        WHERE id = ?
        LIMIT 1
      ),
      skill_ids AS (
        SELECT b.skill_id
        FROM bot_skill_bindings AS b
        JOIN current_chat AS c ON c.bot_id = b.bot_id
        UNION
        SELECT p.skill_id
        FROM conversation_skill_pins AS p
        JOIN current_chat AS c ON c.chat_id = p.chat_id
      )
      SELECT
        ids.skill_id AS id,
        COALESCE(
          s.name,
          CASE
            WHEN instr(ids.skill_id, ':') > 0
              THEN substr(ids.skill_id, instr(ids.skill_id, ':') + 1)
            ELSE ids.skill_id
          END
        ) AS name,
        COALESCE(s.version, '') AS version,
        COALESCE(
          s.scope,
          CASE WHEN ids.skill_id LIKE 'system:%' THEN 'bundled' ELSE '' END
        ) AS scope,
        CASE WHEN s.id IS NULL THEN 0 ELSE 1 END AS installed,
        CASE WHEN ids.skill_id LIKE 'system:%' THEN 1 ELSE 0 END AS bundled,
        CASE
          WHEN s.id IS NOT NULL OR ids.skill_id LIKE 'system:%' THEN 1
          ELSE 0
        END AS available,
        COALESCE(b.enabled, 0) AS configured_enabled,
        CASE WHEN p.skill_id IS NULL THEN 0 ELSE 1 END
          AS pinned_to_conversation,
        COALESCE(b.activation_mode, '') AS activation_mode,
        COALESCE(b.priority, 0) AS priority,
        COALESCE((
          SELECT a.status
          FROM skill_activations AS a
          WHERE a.chat_id = c.chat_id AND a.skill_id = ids.skill_id
          ORDER BY a.started_at DESC, a.id DESC
          LIMIT 1
        ), '') AS last_activation_status,
        (
          SELECT a.started_at
          FROM skill_activations AS a
          WHERE a.chat_id = c.chat_id AND a.skill_id = ids.skill_id
          ORDER BY a.started_at DESC, a.id DESC
          LIMIT 1
        ) AS last_activated_at
      FROM skill_ids AS ids
      CROSS JOIN current_chat AS c
      LEFT JOIN skills AS s ON s.id = ids.skill_id
      LEFT JOIN bot_skill_bindings AS b
        ON b.bot_id = c.bot_id AND b.skill_id = ids.skill_id
      LEFT JOIN conversation_skill_pins AS p
        ON p.chat_id = c.chat_id AND p.skill_id = ids.skill_id
      ORDER BY configured_enabled DESC, priority DESC, lower(name) ASC, id ASC
    ''',
      [chatId],
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
      await transaction.delete(
        'conversation_skill_pins',
        where: 'skill_id = ?',
        whereArgs: [id],
      );
      await transaction.delete(
        'skill_script_grants',
        where: 'skill_id = ?',
        whereArgs: [id],
      );
      await transaction.delete('skills', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Map<String, Object?>>> loadSkillPublishers() async {
    final database = await _databaseProvider();
    return database.query('skill_publishers', orderBy: 'name ASC');
  }

  Future<List<Map<String, Object?>>> loadSkillPublisher(String id) async {
    final database = await _databaseProvider();
    return database.query(
      'skill_publishers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
  }

  Future<void> upsertSkillPublisher(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.insert(
      'skill_publishers',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> loadSkillCatalogs() async {
    final database = await _databaseProvider();
    return database.query('skill_catalogs', orderBy: 'name ASC');
  }

  Future<void> upsertSkillCatalog(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.insert(
      'skill_catalogs',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> setSkillUpdatePolicy(String skillId, String policy) async {
    final database = await _databaseProvider();
    await database.update(
      'skills',
      {
        'update_policy': policy,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [skillId],
    );
  }

  Future<List<Map<String, Object?>>> loadSkillOrganizationPolicy() async {
    final database = await _databaseProvider();
    return database.query(
      'skill_organization_policy',
      where: 'id = 1',
      limit: 1,
    );
  }

  Future<void> saveSkillOrganizationPolicy(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.insert('skill_organization_policy', {
      'id': 1,
      ...values,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, Object?>>> loadSkillScriptGrant(
    String skillId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'skill_script_grants',
      where: 'skill_id = ?',
      whereArgs: [skillId],
      limit: 1,
    );
  }

  Future<void> upsertSkillScriptGrant(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.insert(
      'skill_script_grants',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSkillScriptGrant(String skillId) async {
    final database = await _databaseProvider();
    await database.delete(
      'skill_script_grants',
      where: 'skill_id = ?',
      whereArgs: [skillId],
    );
  }

  Future<void> insertSkillComplianceEvent(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.insert(
        'skill_compliance_events',
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await transaction.rawDelete('''
        DELETE FROM skill_compliance_events
        WHERE id IN (
          SELECT id
          FROM skill_compliance_events
          ORDER BY timestamp DESC
          LIMIT -1 OFFSET 10000
        )
      ''');
    });
  }

  Future<List<Map<String, Object?>>> loadSkillComplianceEvents({
    String? skillId,
    int limit = 100,
  }) async {
    final database = await _databaseProvider();
    return database.query(
      'skill_compliance_events',
      where: skillId == null ? null : 'skill_id = ?',
      whereArgs: skillId == null ? null : [skillId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, Object?>>> loadMcpServers() async {
    final database = await _databaseProvider();
    return database.query('mcp_servers', orderBy: 'name ASC');
  }

  Future<List<Map<String, Object?>>> queryInstalledMcpInventory({
    required String query,
    required int limit,
  }) async {
    final database = await _databaseProvider();
    return database.rawQuery(
      '''
      SELECT
        s.id,
        s.name,
        s.transport_type,
        s.remote_server_name,
        s.remote_server_version,
        s.connection_status,
        s.last_error_code,
        s.last_connected_at,
        s.created_at,
        s.updated_at,
        COUNT(t.remote_name) AS tool_count
      FROM mcp_servers AS s
      LEFT JOIN mcp_tools AS t ON t.server_id = s.id
      WHERE ? = '' OR instr(lower(s.name), ?) > 0
      GROUP BY s.id
      ORDER BY lower(s.name) ASC, s.id ASC
      LIMIT ?
    ''',
      [query, query, limit],
    );
  }

  Future<List<Map<String, Object?>>> queryConversationMcpIdentity(
    String chatId,
  ) async {
    final database = await _databaseProvider();
    return database.rawQuery(
      '''
      SELECT
        c.id AS chat_id,
        b.id AS bot_id,
        b.name AS bot_name,
        b.parameters AS bot_parameters
      FROM chats AS c
      JOIN bots AS b ON b.id = c.bot_id
      WHERE c.id = ?
      LIMIT 1
    ''',
      [chatId],
    );
  }

  Future<List<Map<String, Object?>>> loadAllMcpTools() async {
    final database = await _databaseProvider();
    return database.query(
      'mcp_tools',
      orderBy: 'server_id ASC, remote_name ASC',
    );
  }

  Future<List<Map<String, Object?>>> loadMcpServer(String id) async {
    final database = await _databaseProvider();
    return database.query(
      'mcp_servers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
  }

  Future<void> upsertMcpServer(
    Map<String, Object?> values, {
    bool clearTools = false,
  }) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await _upsertMcpServer(transaction, values);
      if (clearTools) {
        await transaction.delete(
          'mcp_tools',
          where: 'server_id = ?',
          whereArgs: [values['id']],
        );
      }
    });
  }

  Future<void> deleteMcpServer(String id) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.delete(
        'mcp_tools',
        where: 'server_id = ?',
        whereArgs: [id],
      );
      await transaction.delete('mcp_servers', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Map<String, Object?>>> loadMcpTools(String serverId) async {
    final database = await _databaseProvider();
    return database.query(
      'mcp_tools',
      where: 'server_id = ?',
      whereArgs: [serverId],
      orderBy: 'remote_name ASC',
    );
  }

  Future<void> replaceMcpCatalog(
    Map<String, Object?> server,
    Iterable<Map<String, Object?>> tools,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await _upsertMcpServer(transaction, server);
      await transaction.delete(
        'mcp_tools',
        where: 'server_id = ?',
        whereArgs: [server['id']],
      );
      for (final values in tools) {
        await transaction.insert('mcp_tools', values);
      }
    });
  }

  Future<void> _upsertMcpServer(
    DatabaseExecutor database,
    Map<String, Object?> values,
  ) async {
    final updated = await database.update(
      'mcp_servers',
      values,
      where: 'id = ?',
      whereArgs: [values['id']],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    if (updated == 0) {
      await database.insert(
        'mcp_servers',
        values,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
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

  Future<List<Map<String, Object?>>> loadConversationSkillPins(
    String chatId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'conversation_skill_pins',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'created_at ASC, skill_id ASC',
    );
  }

  Future<void> upsertConversationSkillPin(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.insert(
      'conversation_skill_pins',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteConversationSkillPin(String chatId, String skillId) async {
    final database = await _databaseProvider();
    await database.delete(
      'conversation_skill_pins',
      where: 'chat_id = ? AND skill_id = ?',
      whereArgs: [chatId, skillId],
    );
  }

  Future<void> clearConversationSkillPins(String chatId) async {
    final database = await _databaseProvider();
    await database.delete(
      'conversation_skill_pins',
      where: 'chat_id = ?',
      whereArgs: [chatId],
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
        'conversation_skill_pins',
        where: 'chat_id = ?',
        whereArgs: [id],
      );
      await _deleteConversationMemory(transaction, id);
      await transaction.delete(
        'token_usage_records',
        where: 'chat_id = ?',
        whereArgs: [id],
      );
      await transaction.delete('chats', where: 'id = ?', whereArgs: [id]);
    });
    _advanceMessageRevision(id);
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
      await _deleteConversationMemory(transaction, id);
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
    _advanceMessageRevision(id);
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
    await database.insert(
      'token_usage_records',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMessages(String chatId) async {
    final database = await _databaseProvider();
    await database.delete(
      'messages',
      where: 'chat_id = ?',
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
      'operation_kind': 'chat_reply',
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
