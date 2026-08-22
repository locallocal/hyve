part of 'local_database_service.dart';

extension LocalDatabaseProjectMembershipAudits on LocalDatabaseService {
  Future<void> saveProjectMembershipWithAudit(
    Map<String, Object?> membership,
    Map<String, Object?> eventValues,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      final previous = await transaction.query(
        'project_memberships',
        columns: const <String>['status'],
        where: 'project_id = ? AND agent_id = ?',
        whereArgs: <Object?>[membership['project_id'], membership['agent_id']],
        limit: 1,
      );
      await _saveMembershipAndCursor(transaction, membership);
      await _appendMembershipAuditIfChanged(
        transaction,
        membership: membership,
        eventValues: eventValues,
        previousStatus:
            previous.isEmpty ? '' : previous.single['status']! as String,
      );
    });
  }

  Future<void> markProjectMembershipRemovedWithAudit(
    String projectId,
    String agentId,
    int removedAt,
    Map<String, Object?> eventValues,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      final previous = await transaction.query(
        'project_memberships',
        columns: const <String>['status'],
        where: 'project_id = ? AND agent_id = ?',
        whereArgs: <Object?>[projectId, agentId],
        limit: 1,
      );
      await transaction.update(
        'project_memberships',
        <String, Object?>{
          'status': 'removed',
          'removed_at': removedAt,
          'updated_at': removedAt,
        },
        where: 'project_id = ? AND agent_id = ?',
        whereArgs: <Object?>[projectId, agentId],
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
        whereArgs: <Object?>[projectId, agentId],
      );
      await _appendMembershipAuditIfChanged(
        transaction,
        membership: <String, Object?>{
          'project_id': projectId,
          'agent_id': agentId,
          'status': 'removed',
          'updated_at': removedAt,
        },
        eventValues: eventValues,
        previousStatus:
            previous.isEmpty ? '' : previous.single['status']! as String,
      );
    });
  }
}

Future<void> _appendMembershipAuditIfChanged(
  DatabaseExecutor database, {
  required Map<String, Object?> membership,
  required Map<String, Object?> eventValues,
  required String previousStatus,
}) async {
  final currentStatus = membership['status']! as String;
  if (previousStatus == currentStatus) return;
  final projectId = membership['project_id']! as String;
  final projects = await database.query(
    'projects',
    columns: const <String>['last_event_sequence'],
    where: 'id = ?',
    whereArgs: <Object?>[projectId],
    limit: 1,
  );
  if (projects.isEmpty) throw StateError('membership_project_not_found');
  final sequence = (projects.single['last_event_sequence']! as int) + 1;
  final event =
      Map<String, Object?>.from(eventValues)
        ..['sequence'] = sequence
        ..['payload_json'] = jsonEncode(<String, Object?>{
          'agentId': membership['agent_id'],
          'previousStatus': previousStatus,
          'currentStatus': currentStatus,
        });
  await database.insert('project_events', event);
  await database.update(
    'projects',
    <String, Object?>{
      'last_event_sequence': sequence,
      'updated_at': membership['updated_at'],
    },
    where: 'id = ?',
    whereArgs: <Object?>[projectId],
  );
}
