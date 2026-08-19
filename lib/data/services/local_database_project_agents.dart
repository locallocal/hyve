part of 'local_database_service.dart';

extension LocalDatabaseProjectAgents on LocalDatabaseService {
  Future<List<Map<String, Object?>>> loadAgents() async {
    final database = await _databaseProvider();
    return database.query('agents', orderBy: 'created_at ASC');
  }

  Future<List<Map<String, Object?>>> loadAgent(String id) async {
    final database = await _databaseProvider();
    return database.query('agents', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  Future<void> insertAgent(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await _upsertByPrimaryKey(database, 'agents', values, 'id');
  }

  Future<void> updateAgent(String id, Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.update('agents', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAgent(String id) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.delete(
        'token_usage_records',
        where: 'agent_id = ?',
        whereArgs: [id],
      );
      await transaction.delete('agents', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Map<String, Object?>>> loadProjects() async {
    final database = await _databaseProvider();
    return database.query('projects', orderBy: 'updated_at DESC');
  }

  Future<List<Map<String, Object?>>> loadProject(String id) async {
    final database = await _databaseProvider();
    return database.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
  }

  Future<void> insertProject(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await _upsertByPrimaryKey(database, 'projects', values, 'id');
  }

  Future<void> insertProjectWithMemberships(
    Map<String, Object?> project,
    Iterable<Map<String, Object?>> memberships,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await _upsertByPrimaryKey(transaction, 'projects', project, 'id');
      for (final membership in memberships) {
        await transaction.insert(
          'project_memberships',
          membership,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> updateProject(String id, Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.update('projects', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteProject(String id) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.delete(
        'token_usage_records',
        where: 'project_id = ?',
        whereArgs: [id],
      );
      await transaction.delete('projects', where: 'id = ?', whereArgs: [id]);
    });
    _advanceMessageRevision(id);
  }

  Future<List<Map<String, Object?>>> loadProjectMemberships(
    String projectId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'project_memberships',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'position ASC',
    );
  }

  Future<List<Map<String, Object?>>> loadAgentMemberships(
    String agentId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'project_memberships',
      where: 'agent_id = ?',
      whereArgs: [agentId],
      orderBy: 'updated_at DESC',
    );
  }

  Future<List<Map<String, Object?>>> loadProjectMembership(
    String projectId,
    String agentId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'project_memberships',
      where: 'project_id = ? AND agent_id = ?',
      whereArgs: [projectId, agentId],
      limit: 1,
    );
  }

  Future<void> saveProjectMembership(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await database.insert(
      'project_memberships',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveProjectMemberships(
    Iterable<Map<String, Object?>> values,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      for (final membership in values) {
        await transaction.insert(
          'project_memberships',
          membership,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> markProjectMembershipRemoved(
    String projectId,
    String agentId,
    int removedAt,
  ) async {
    final database = await _databaseProvider();
    await database.update(
      'project_memberships',
      <String, Object?>{
        'status': 'removed',
        'removed_at': removedAt,
        'updated_at': removedAt,
      },
      where: 'project_id = ? AND agent_id = ?',
      whereArgs: [projectId, agentId],
    );
  }

  Future<List<Map<String, Object?>>> loadProjectEvent(String id) async {
    final database = await _databaseProvider();
    return database.query(
      'project_events',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
  }

  Future<List<Map<String, Object?>>> loadProjectEvents(
    String projectId, {
    int? afterSequence,
    required int limit,
  }) async {
    final database = await _databaseProvider();
    return database.query(
      'project_events',
      where:
          afterSequence == null
              ? 'project_id = ?'
              : 'project_id = ? AND sequence > ?',
      whereArgs:
          afterSequence == null
              ? <Object?>[projectId]
              : <Object?>[projectId, afterSequence],
      orderBy: 'sequence ASC',
      limit: limit,
    );
  }

  Future<List<Map<String, Object?>>> loadProjectEventTargets(
    String eventId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'project_event_targets',
      columns: const <String>['agent_id'],
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'position ASC',
    );
  }

  Future<void> saveProjectEvent(
    Map<String, Object?> event,
    Iterable<String> targetAgentIds,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await _upsertByPrimaryKey(transaction, 'project_events', event, 'id');
      final eventId = event['id']! as String;
      await transaction.delete(
        'project_event_targets',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      var position = 0;
      for (final agentId in targetAgentIds) {
        await transaction.insert('project_event_targets', <String, Object?>{
          'event_id': eventId,
          'agent_id': agentId,
          'target_kind':
              event['event_type'] == 'agentDelivery' ? 'delivery' : 'mention',
          'position': position++,
        });
      }
      await transaction.rawUpdate(
        '''
        UPDATE projects
        SET last_event_sequence = MAX(last_event_sequence, ?),
            last_message_sequence = MAX(
              last_message_sequence,
              COALESCE(?, last_message_sequence)
            ),
            last_message = CASE WHEN ? IS NULL THEN last_message ELSE ? END,
            last_message_at = CASE WHEN ? IS NULL THEN last_message_at ELSE ? END,
            updated_at = MAX(updated_at, ?)
        WHERE id = ?
        ''',
        <Object?>[
          event['sequence'],
          event['message_sequence'],
          event['message_sequence'],
          event['content'],
          event['message_sequence'],
          event['created_at'],
          event['updated_at'],
          event['project_id'],
        ],
      );
    });
    _advanceMessageRevision(event['project_id']! as String);
  }

  Future<List<Map<String, Object?>>> loadProjectTurn(String id) async {
    final database = await _databaseProvider();
    return database.query(
      'project_turns',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
  }

  Future<List<Map<String, Object?>>> loadProjectTurns(
    String projectId, {
    required int limit,
  }) async {
    final database = await _databaseProvider();
    return database.query(
      'project_turns',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  Future<void> saveProjectTurn(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await _upsertByPrimaryKey(database, 'project_turns', values, 'id');
  }

  Future<List<Map<String, Object?>>> loadAgentRun(String id) async {
    final database = await _databaseProvider();
    return database.query(
      'agent_runs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
  }

  Future<List<Map<String, Object?>>> loadAgentRunsForTurn(String turnId) async {
    final database = await _databaseProvider();
    return database.query(
      'agent_runs',
      where: 'turn_id = ?',
      whereArgs: [turnId],
      orderBy: 'created_at ASC',
    );
  }

  Future<List<Map<String, Object?>>> loadActiveAgentRunsForProject(
    String projectId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'agent_runs',
      where:
          "project_id = ? AND status NOT IN "
          "('passed', 'completed', 'failed', 'cancelled', "
          "'timedOut', 'limitExceeded', 'interrupted')",
      whereArgs: [projectId],
      orderBy: 'created_at ASC',
    );
  }

  Future<void> saveAgentRun(Map<String, Object?> values) async {
    final database = await _databaseProvider();
    await _upsertByPrimaryKey(database, 'agent_runs', values, 'id');
  }
}
