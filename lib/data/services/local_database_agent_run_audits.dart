part of 'local_database_service.dart';

extension LocalDatabaseAgentRunAudits on LocalDatabaseService {
  Future<void> saveAgentRunWithAudit(Map<String, Object?> runValues) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      final previous = await transaction.query(
        'agent_runs',
        columns: const <String>['status'],
        where: 'id = ?',
        whereArgs: <Object?>[runValues['id']],
        limit: 1,
      );
      await _upsertByPrimaryKey(transaction, 'agent_runs', runValues, 'id');
      await _appendRunStatusAuditIfChanged(
        transaction,
        runValues: runValues,
        previousStatus:
            previous.isEmpty ? '' : previous.single['status']! as String,
      );
    });
    _advanceMessageRevision(runValues['project_id']! as String);
  }

  Future<void> recoverInterruptedProjectAgentClaims(int now) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      final interruptedRuns = await transaction.query(
        'agent_runs',
        where:
            "status NOT IN ('passed', 'completed', 'failed', 'cancelled', "
            "'timedOut', 'limitExceeded', 'interrupted')",
      );
      await transaction.rawUpdate(
        '''
        UPDATE project_agent_cursors
        SET processing_message_sequence = NULL,
            worker_state = CASE
              WHEN EXISTS (
                SELECT 1 FROM project_memberships AS membership
                WHERE membership.project_id = project_agent_cursors.project_id
                  AND membership.agent_id = project_agent_cursors.agent_id
                  AND membership.status = 'active'
              ) THEN 'scheduled'
              ELSE 'paused'
            END,
            active_run_id = NULL,
            lease_owner = '',
            lease_expires_at = NULL,
            last_error = 'interrupted',
            updated_at = ?
        WHERE processing_message_sequence IS NOT NULL
        ''',
        <Object?>[now],
      );
      for (final run in interruptedRuns) {
        final interrupted =
            Map<String, Object?>.from(run)
              ..['status'] = 'interrupted'
              ..['completed_at'] = now
              ..['error_code'] = 'interrupted';
        await transaction.update(
          'agent_runs',
          <String, Object?>{
            'status': 'interrupted',
            'completed_at': now,
            'error_code': 'interrupted',
          },
          where: 'id = ?',
          whereArgs: <Object?>[run['id']],
        );
        await _appendRunStatusAuditIfChanged(
          transaction,
          runValues: interrupted,
          previousStatus: run['status']! as String,
        );
      }
    });
  }
}

Future<void> _appendRunStatusAuditIfChanged(
  DatabaseExecutor database, {
  required Map<String, Object?> runValues,
  required String previousStatus,
}) async {
  final status = runValues['status']! as String;
  if (previousStatus == status) return;
  final projectId = runValues['project_id']! as String;
  final sequence = await _nextProjectEventSequence(
    database,
    projectId,
    missingProjectError: 'run_project_not_found',
  );
  final changedAt =
      runValues['completed_at'] as int? ??
      runValues['started_at'] as int? ??
      runValues['created_at']! as int;
  final snapshot = _runSnapshot(runValues['agent_snapshot_json']);
  final runId = runValues['id']! as String;
  await database.insert('project_events', <String, Object?>{
    'id': 'run-$runId-$status-$sequence',
    'project_id': projectId,
    'turn_id': runValues['turn_id'],
    'run_id': runId,
    'sequence': sequence,
    'message_sequence': null,
    'event_type': 'runStatusChanged',
    'actor_type': 'agent',
    'actor_id': runValues['agent_id'],
    'actor_name_snapshot': snapshot['agentName']?.toString() ?? '',
    'actor_avatar_snapshot': '',
    'visibility': 'audit',
    'reply_to_event_id': '',
    'reply_to_message_sequence': runValues['source_message_sequence'],
    'root_message_id': runValues['source_message_event_id'],
    'autonomous_depth': runValues['delivery_depth'] ?? 0,
    'content': '',
    'payload_json': jsonEncode(<String, Object?>{
      'runId': runId,
      'phase': runValues['phase'],
      'status': status,
      'errorCode': runValues['error_code'] ?? '',
    }),
    'terminal_state': 'completed',
    'has_partial_content': 0,
    'created_at': changedAt,
    'updated_at': changedAt,
  });
  await database.update(
    'projects',
    <String, Object?>{'last_event_sequence': sequence, 'updated_at': changedAt},
    where: 'id = ?',
    whereArgs: <Object?>[projectId],
  );
}

Future<int> _nextProjectEventSequence(
  DatabaseExecutor database,
  String projectId, {
  required String missingProjectError,
}) async {
  final rows = await database.rawQuery(
    '''
    SELECT project.last_event_sequence AS project_sequence,
           COALESCE(MAX(event.sequence), 0) AS event_sequence
    FROM projects AS project
    LEFT JOIN project_events AS event ON event.project_id = project.id
    WHERE project.id = ?
    GROUP BY project.id, project.last_event_sequence
    LIMIT 1
    ''',
    <Object?>[projectId],
  );
  if (rows.isEmpty) throw StateError(missingProjectError);
  final projectSequence = rows.single['project_sequence']! as int;
  final eventSequence = rows.single['event_sequence']! as int;
  return (projectSequence > eventSequence ? projectSequence : eventSequence) +
      1;
}

Map<String, Object?> _runSnapshot(Object? value) {
  if (value is! String || value.isEmpty) return const <String, Object?>{};
  try {
    final decoded = jsonDecode(value);
    return decoded is Map<String, Object?>
        ? decoded
        : const <String, Object?>{};
  } on FormatException {
    return const <String, Object?>{};
  }
}
