part of 'local_database_service.dart';

extension LocalDatabaseProjectRouting on LocalDatabaseService {
  Future<void> saveParticipationDecision(
    Map<String, Object?> decisionValues,
    Map<String, Object?> eventValues,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      final runId = decisionValues['run_id']! as String;
      final existing = await transaction.query(
        'participation_decisions',
        where: 'run_id = ?',
        whereArgs: <Object?>[runId],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        await transaction.update(
          'participation_decisions',
          decisionValues,
          where: 'run_id = ?',
          whereArgs: <Object?>[runId],
        );
        return;
      }
      final projectId = decisionValues['project_id']! as String;
      final projects = await transaction.query(
        'projects',
        columns: const <String>['last_event_sequence'],
        where: 'id = ?',
        whereArgs: <Object?>[projectId],
        limit: 1,
      );
      if (projects.isEmpty) throw StateError('project_not_found');
      final eventSequence =
          (projects.single['last_event_sequence']! as int) + 1;
      final event = Map<String, Object?>.from(eventValues)
        ..['sequence'] = eventSequence;
      await transaction.insert('participation_decisions', decisionValues);
      await transaction.insert('project_events', event);
      await transaction.update(
        'projects',
        <String, Object?>{
          'last_event_sequence': eventSequence,
          'updated_at': event['updated_at'],
        },
        where: 'id = ?',
        whereArgs: <Object?>[projectId],
      );
    });
  }

  Future<ProjectMessageAppendRecord> appendProjectMessage(
    Map<String, Object?> eventValues,
    Map<String, Object?> turnValues,
    Iterable<String> requestedTargetAgentIds,
    String routingMode,
  ) async {
    final database = await _databaseProvider();
    final result = await database.transaction((transaction) async {
      final projectId = eventValues['project_id']! as String;
      final projects = await transaction.query(
        'projects',
        columns: const <String>['last_event_sequence', 'last_message_sequence'],
        where: 'id = ?',
        whereArgs: <Object?>[projectId],
        limit: 1,
      );
      if (projects.isEmpty) {
        throw StateError('project_not_found');
      }
      final memberships = await transaction.query(
        'project_memberships',
        where: "project_id = ? AND status != 'removed'",
        whereArgs: <Object?>[projectId],
        orderBy: 'position ASC',
      );
      for (final membership in memberships) {
        await _ensureMembershipCursor(transaction, membership);
      }
      final activeAgentIds = <String>[
        for (final membership in memberships)
          if (membership['status'] == 'active')
            membership['agent_id']! as String,
      ];
      final activeSet = activeAgentIds.toSet();
      final requested = requestedTargetAgentIds.toSet().toList(growable: false);
      if (routingMode == 'targeted' &&
          requested.any((agentId) => !activeSet.contains(agentId))) {
        throw StateError('project_message_target_not_active');
      }
      final targets = routingMode == 'broadcast' ? activeAgentIds : requested;
      final project = projects.single;
      final eventSequence = (project['last_event_sequence']! as int) + 1;
      final messageSequence = (project['last_message_sequence']! as int) + 1;
      final event =
          Map<String, Object?>.from(eventValues)
            ..['sequence'] = eventSequence
            ..['message_sequence'] = messageSequence;
      final turn =
          Map<String, Object?>.from(turnValues)
            ..['source_message_sequence'] = messageSequence
            ..['recipient_count'] = targets.length;
      if (targets.isEmpty) {
        turn
          ..['status'] = 'completed'
          ..['no_participant'] = routingMode == 'broadcast' ? 1 : 0
          ..['completed_at'] = event['created_at'];
      }

      await transaction.insert('project_events', event);
      var position = 0;
      for (final agentId in targets) {
        await transaction.insert('project_event_targets', <String, Object?>{
          'event_id': event['id'],
          'agent_id': agentId,
          'target_kind': switch (routingMode) {
            'broadcast' => 'broadcast',
            'delivery' => 'delivery',
            _ => 'mention',
          },
          'position': position++,
        });
      }
      await transaction.insert('project_turns', turn);
      await transaction.update(
        'projects',
        <String, Object?>{
          'last_event_sequence': eventSequence,
          'last_message_sequence': messageSequence,
          'last_message': event['content'],
          'last_message_at': event['created_at'],
          'updated_at': event['updated_at'],
        },
        where: 'id = ?',
        whereArgs: <Object?>[projectId],
      );
      return ProjectMessageAppendRecord(
        eventValues: event,
        turnValues: turn,
        targetAgentIds: targets,
        activeAgentIds: activeAgentIds,
      );
    });
    _advanceMessageRevision(eventValues['project_id']! as String);
    return result;
  }
}

final class ProjectMessageAppendRecord {
  const ProjectMessageAppendRecord({
    required this.eventValues,
    required this.turnValues,
    required this.targetAgentIds,
    required this.activeAgentIds,
  });

  final Map<String, Object?> eventValues;
  final Map<String, Object?> turnValues;
  final List<String> targetAgentIds;
  final List<String> activeAgentIds;
}

final class AgentMessageClaimRecord {
  const AgentMessageClaimRecord({
    required this.cursorValues,
    required this.eventValues,
  });

  final Map<String, Object?> cursorValues;
  final Map<String, Object?> eventValues;
}

Future<void> _saveMembershipAndCursor(
  DatabaseExecutor database,
  Map<String, Object?> membership,
) async {
  final existing = await database.query(
    'project_memberships',
    columns: const <String>['membership_generation', 'status'],
    where: 'project_id = ? AND agent_id = ?',
    whereArgs: <Object?>[membership['project_id'], membership['agent_id']],
    limit: 1,
  );
  await database.insert(
    'project_memberships',
    membership,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  final generationChanged =
      existing.isEmpty ||
      existing.single['membership_generation'] !=
          membership['membership_generation'];
  if (generationChanged) {
    await database.insert('project_agent_cursors', <String, Object?>{
      'project_id': membership['project_id'],
      'agent_id': membership['agent_id'],
      'last_processed_message_sequence': membership['join_message_sequence'],
      'processing_message_sequence': null,
      'worker_state': membership['status'] == 'active' ? 'idle' : 'paused',
      'active_run_id': null,
      'lease_owner': '',
      'lease_expires_at': null,
      'last_error': '',
      'updated_at': membership['updated_at'],
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return;
  }
  final state = switch (membership['status']) {
    'active' => existing.single['status'] == 'active' ? null : 'scheduled',
    _ => 'paused',
  };
  if (state != null) {
    await database.update(
      'project_agent_cursors',
      <String, Object?>{
        'worker_state': state,
        'updated_at': membership['updated_at'],
      },
      where: 'project_id = ? AND agent_id = ?',
      whereArgs: <Object?>[membership['project_id'], membership['agent_id']],
    );
  }
}

Future<void> _ensureMembershipCursor(
  DatabaseExecutor database,
  Map<String, Object?> membership,
) async {
  await database.insert('project_agent_cursors', <String, Object?>{
    'project_id': membership['project_id'],
    'agent_id': membership['agent_id'],
    'last_processed_message_sequence': membership['join_message_sequence'],
    'processing_message_sequence': null,
    'worker_state': membership['status'] == 'active' ? 'idle' : 'paused',
    'active_run_id': null,
    'lease_owner': '',
    'lease_expires_at': null,
    'last_error': '',
    'updated_at': membership['updated_at'],
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}
