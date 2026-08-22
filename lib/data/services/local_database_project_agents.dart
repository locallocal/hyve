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
        await _saveMembershipAndCursor(transaction, membership);
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
    await database.transaction(
      (transaction) => _saveMembershipAndCursor(transaction, values),
    );
  }

  Future<void> saveProjectMemberships(
    Iterable<Map<String, Object?>> values,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      for (final membership in values) {
        await _saveMembershipAndCursor(transaction, membership);
      }
    });
  }

  Future<void> markProjectMembershipRemoved(
    String projectId,
    String agentId,
    int removedAt,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.update(
        'project_memberships',
        <String, Object?>{
          'status': 'removed',
          'removed_at': removedAt,
          'updated_at': removedAt,
        },
        where: 'project_id = ? AND agent_id = ?',
        whereArgs: [projectId, agentId],
      );
      await transaction.update(
        'project_agent_cursors',
        <String, Object?>{
          'worker_state': 'paused',
          'lease_owner': '',
          'lease_expires_at': null,
          'updated_at': removedAt,
        },
        where: 'project_id = ? AND agent_id = ?',
        whereArgs: [projectId, agentId],
      );
    });
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
    int? beforeSequence,
    required int limit,
  }) async {
    final database = await _databaseProvider();
    final rows = await database.query(
      'project_events',
      where:
          afterSequence != null
              ? 'project_id = ? AND sequence > ?'
              : beforeSequence != null
              ? 'project_id = ? AND sequence < ?'
              : 'project_id = ?',
      whereArgs:
          afterSequence != null
              ? <Object?>[projectId, afterSequence]
              : beforeSequence != null
              ? <Object?>[projectId, beforeSequence]
              : <Object?>[projectId],
      orderBy: afterSequence != null ? 'sequence ASC' : 'sequence DESC',
      limit: limit,
    );
    return afterSequence != null ? rows : rows.reversed.toList(growable: false);
  }

  Future<List<Map<String, Object?>>> loadProjectMessageAt(
    String projectId,
    int messageSequence,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'project_events',
      where:
          'project_id = ? AND message_sequence = ? '
          "AND terminal_state != 'draft'",
      whereArgs: <Object?>[projectId, messageSequence],
      limit: 1,
    );
  }

  Future<List<Map<String, Object?>>> loadAgentReplyForRun(String runId) async {
    final database = await _databaseProvider();
    return database.query(
      'project_events',
      where:
          "run_id = ? AND event_type = 'agentMessage' "
          "AND terminal_state != 'draft'",
      whereArgs: <Object?>[runId],
      limit: 1,
    );
  }

  Future<int> countAgentMessagesForRoot(
    String projectId,
    String rootMessageId,
  ) async {
    final database = await _databaseProvider();
    final rows = await database.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM project_events
      WHERE project_id = ?
        AND root_message_id = ?
        AND event_type = 'agentMessage'
        AND terminal_state != 'draft'
      ''',
      <Object?>[projectId, rootMessageId],
    );
    return (rows.single['count'] as int?) ?? 0;
  }

  Future<List<Map<String, Object?>>> loadVisibleProjectMessages(
    String projectId,
    String agentId,
    int throughMessageSequence, {
    required int limit,
  }) async {
    final database = await _databaseProvider();
    final rows = await database.rawQuery(
      '''
      SELECT event.*
      FROM project_events AS event
      WHERE event.project_id = ?
        AND event.message_sequence IS NOT NULL
        AND event.message_sequence <= ?
        AND event.terminal_state != 'draft'
        AND (
          event.visibility = 'project'
          OR (
            event.visibility = 'targets'
            AND EXISTS (
              SELECT 1
              FROM project_event_targets AS target
              WHERE target.event_id = event.id AND target.agent_id = ?
            )
          )
        )
      ORDER BY event.message_sequence DESC
      LIMIT ?
      ''',
      <Object?>[projectId, throughMessageSequence, agentId, limit],
    );
    return rows.reversed.toList(growable: false);
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

  Future<List<Map<String, Object?>>> loadProjectAgentCursor(
    String projectId,
    String agentId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'project_agent_cursors',
      where: 'project_id = ? AND agent_id = ?',
      whereArgs: <Object?>[projectId, agentId],
      limit: 1,
    );
  }

  Future<List<Map<String, Object?>>> loadProjectAgentCursors(
    String projectId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'project_agent_cursors',
      where: 'project_id = ?',
      whereArgs: <Object?>[projectId],
      orderBy: 'agent_id ASC',
    );
  }

  Future<List<Map<String, Object?>>> loadBackloggedActiveInboxes() async {
    final database = await _databaseProvider();
    return database.rawQuery('''
      SELECT membership.project_id, membership.agent_id
      FROM project_memberships AS membership
      JOIN projects AS project ON project.id = membership.project_id
      LEFT JOIN project_agent_cursors AS cursor
        ON cursor.project_id = membership.project_id
       AND cursor.agent_id = membership.agent_id
      WHERE membership.status = 'active'
        AND project.last_message_sequence > COALESCE(
          cursor.last_processed_message_sequence,
          membership.join_message_sequence
        )
      ORDER BY membership.project_id, membership.position
    ''');
  }

  Future<AgentMessageClaimRecord?> claimNextProjectMessage({
    required String projectId,
    required String agentId,
    required String leaseOwner,
    required int now,
    required int leaseExpiresAt,
  }) async {
    final database = await _databaseProvider();
    return database.transaction((transaction) async {
      final memberships = await transaction.query(
        'project_memberships',
        where: 'project_id = ? AND agent_id = ?',
        whereArgs: <Object?>[projectId, agentId],
        limit: 1,
      );
      if (memberships.isEmpty || memberships.single['status'] != 'active') {
        if (memberships.isNotEmpty) {
          await _ensureMembershipCursor(transaction, memberships.single);
          await transaction.update(
            'project_agent_cursors',
            <String, Object?>{'worker_state': 'paused', 'updated_at': now},
            where: 'project_id = ? AND agent_id = ?',
            whereArgs: <Object?>[projectId, agentId],
          );
        }
        return null;
      }
      await _ensureMembershipCursor(transaction, memberships.single);
      var cursors = await transaction.query(
        'project_agent_cursors',
        where: 'project_id = ? AND agent_id = ?',
        whereArgs: <Object?>[projectId, agentId],
        limit: 1,
      );
      final current = cursors.single;
      final processing = current['processing_message_sequence'] as int?;
      final currentLeaseOwner = current['lease_owner']! as String;
      final currentLeaseExpiresAt = current['lease_expires_at'] as int?;
      if (processing != null &&
          currentLeaseOwner != leaseOwner &&
          currentLeaseExpiresAt != null &&
          currentLeaseExpiresAt > now) {
        return null;
      }
      if (processing != null) {
        await transaction.update(
          'project_agent_cursors',
          <String, Object?>{
            'processing_message_sequence': null,
            'active_run_id': null,
            'lease_owner': '',
            'lease_expires_at': null,
            'worker_state': 'scheduled',
            'updated_at': now,
          },
          where: 'project_id = ? AND agent_id = ?',
          whereArgs: <Object?>[projectId, agentId],
        );
        cursors = await transaction.query(
          'project_agent_cursors',
          where: 'project_id = ? AND agent_id = ?',
          whereArgs: <Object?>[projectId, agentId],
          limit: 1,
        );
      }
      final cursor = cursors.single;
      final nextSequence =
          (cursor['last_processed_message_sequence']! as int) + 1;
      final projects = await transaction.query(
        'projects',
        columns: const <String>['last_message_sequence'],
        where: 'id = ?',
        whereArgs: <Object?>[projectId],
        limit: 1,
      );
      if (projects.isEmpty ||
          nextSequence > (projects.single['last_message_sequence']! as int)) {
        await transaction.update(
          'project_agent_cursors',
          <String, Object?>{
            'worker_state': 'idle',
            'lease_owner': '',
            'lease_expires_at': null,
            'updated_at': now,
          },
          where: 'project_id = ? AND agent_id = ?',
          whereArgs: <Object?>[projectId, agentId],
        );
        return null;
      }
      final messages = await transaction.query(
        'project_events',
        where:
            'project_id = ? AND message_sequence = ? '
            "AND terminal_state != 'draft'",
        whereArgs: <Object?>[projectId, nextSequence],
        limit: 1,
      );
      if (messages.isEmpty) {
        await transaction.update(
          'project_agent_cursors',
          <String, Object?>{
            'worker_state': 'error',
            'last_error': 'message_sequence_gap',
            'updated_at': now,
          },
          where: 'project_id = ? AND agent_id = ?',
          whereArgs: <Object?>[projectId, agentId],
        );
        throw StateError('message_sequence_gap');
      }
      await transaction.update(
        'project_agent_cursors',
        <String, Object?>{
          'processing_message_sequence': nextSequence,
          'worker_state': 'processing',
          'active_run_id': null,
          'lease_owner': leaseOwner,
          'lease_expires_at': leaseExpiresAt,
          'last_error': '',
          'updated_at': now,
        },
        where: 'project_id = ? AND agent_id = ?',
        whereArgs: <Object?>[projectId, agentId],
      );
      final claimedCursor =
          Map<String, Object?>.from(cursor)
            ..['processing_message_sequence'] = nextSequence
            ..['worker_state'] = 'processing'
            ..['active_run_id'] = null
            ..['lease_owner'] = leaseOwner
            ..['lease_expires_at'] = leaseExpiresAt
            ..['last_error'] = ''
            ..['updated_at'] = now;
      return AgentMessageClaimRecord(
        cursorValues: claimedCursor,
        eventValues: messages.single,
      );
    });
  }

  Future<void> setProjectAgentActiveRun({
    required String projectId,
    required String agentId,
    required String leaseOwner,
    required String runId,
    required int now,
  }) async {
    final database = await _databaseProvider();
    final changed = await database.update(
      'project_agent_cursors',
      <String, Object?>{'active_run_id': runId, 'updated_at': now},
      where:
          'project_id = ? AND agent_id = ? AND lease_owner = ? '
          'AND processing_message_sequence IS NOT NULL',
      whereArgs: <Object?>[projectId, agentId, leaseOwner],
    );
    if (changed != 1) throw StateError('agent_cursor_lease_lost');
  }

  Future<void> completeProjectAgentMessage(
    Map<String, Object?> receipt,
    String leaseOwner,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      final projectId = receipt['project_id']! as String;
      final agentId = receipt['agent_id']! as String;
      final messageSequence = receipt['message_sequence']! as int;
      final cursors = await transaction.query(
        'project_agent_cursors',
        where: 'project_id = ? AND agent_id = ?',
        whereArgs: <Object?>[projectId, agentId],
        limit: 1,
      );
      if (cursors.isEmpty) throw StateError('agent_cursor_not_found');
      final cursor = cursors.single;
      final lastProcessed = cursor['last_processed_message_sequence']! as int;
      if (lastProcessed >= messageSequence) {
        final existing = await transaction.query(
          'agent_message_receipts',
          where: 'project_id = ? AND agent_id = ? AND message_sequence = ?',
          whereArgs: <Object?>[projectId, agentId, messageSequence],
          limit: 1,
        );
        if (existing.isNotEmpty) return;
      }
      if (messageSequence != lastProcessed + 1 ||
          cursor['processing_message_sequence'] != messageSequence ||
          cursor['lease_owner'] != leaseOwner) {
        throw StateError('agent_cursor_not_contiguous');
      }
      await transaction.insert('agent_message_receipts', receipt);
      await transaction.update(
        'project_agent_cursors',
        <String, Object?>{
          'last_processed_message_sequence': messageSequence,
          'processing_message_sequence': null,
          'worker_state': 'scheduled',
          'active_run_id': null,
          'lease_owner': '',
          'lease_expires_at': null,
          'last_error': '',
          'updated_at': receipt['completed_at'],
        },
        where: 'project_id = ? AND agent_id = ?',
        whereArgs: <Object?>[projectId, agentId],
      );
    });
  }

  Future<void> releaseProjectAgentClaim({
    required String projectId,
    required String agentId,
    required String leaseOwner,
    required int now,
    required String errorCode,
  }) async {
    final database = await _databaseProvider();
    await database.update(
      'project_agent_cursors',
      <String, Object?>{
        'processing_message_sequence': null,
        'worker_state': errorCode.isEmpty ? 'scheduled' : 'error',
        'active_run_id': null,
        'lease_owner': '',
        'lease_expires_at': null,
        'last_error': errorCode,
        'updated_at': now,
      },
      where: 'project_id = ? AND agent_id = ? AND lease_owner = ?',
      whereArgs: <Object?>[projectId, agentId, leaseOwner],
    );
  }

  Future<List<Map<String, Object?>>> loadAgentMessageReceipt(
    String projectId,
    String agentId,
    int messageSequence,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'agent_message_receipts',
      where: 'project_id = ? AND agent_id = ? AND message_sequence = ?',
      whereArgs: <Object?>[projectId, agentId, messageSequence],
      limit: 1,
    );
  }

  Future<List<Map<String, Object?>>> loadAgentMessageReceiptsForTurn(
    String turnId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'agent_message_receipts',
      where: 'turn_id = ?',
      whereArgs: <Object?>[turnId],
      orderBy: 'agent_id ASC',
    );
  }

  Future<List<Map<String, Object?>>> loadParticipationDecision(
    String runId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'participation_decisions',
      where: 'run_id = ?',
      whereArgs: <Object?>[runId],
      limit: 1,
    );
  }

  Future<List<Map<String, Object?>>> loadParticipationDecisionsForTurn(
    String turnId,
  ) async {
    final database = await _databaseProvider();
    return database.query(
      'participation_decisions',
      where: 'turn_id = ?',
      whereArgs: <Object?>[turnId],
      orderBy: 'created_at ASC',
    );
  }
}
