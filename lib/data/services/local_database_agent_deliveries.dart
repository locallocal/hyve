part of 'local_database_service.dart';

extension LocalDatabaseAgentDeliveries on LocalDatabaseService {
  Future<AgentDeliveryDatabaseRecord?> loadAgentDelivery(String eventId) async {
    final database = await _databaseProvider();
    return database.transaction((transaction) async {
      final rows = await transaction.rawQuery(
        '''
        SELECT delivery.*, event.run_id AS delivery_run_id
        FROM agent_deliveries AS delivery
        JOIN project_events AS event ON event.id = delivery.event_id
        WHERE delivery.event_id = ?
        LIMIT 1
        ''',
        <Object?>[eventId],
      );
      if (rows.isEmpty) return null;
      return AgentDeliveryDatabaseRecord(
        deliveryValues: rows.single,
        targetAgentIds: await _loadDeliveryTargets(transaction, eventId),
        artifactVersionIds: await _loadDeliveryArtifacts(transaction, eventId),
      );
    });
  }

  Future<void> appendAgentDeliveryRejection(
    Map<String, Object?> eventValues,
    Map<String, Object?> deliveryRunValues,
  ) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      final projectId = eventValues['project_id']! as String;
      final eventSequence = await _nextProjectEventSequence(
        transaction,
        projectId,
        missingProjectError: 'delivery_project_not_found',
      );
      final event = Map<String, Object?>.from(eventValues)
        ..['sequence'] = eventSequence;
      await transaction.insert('agent_runs', deliveryRunValues);
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
      await _appendRunStatusAuditIfChanged(
        transaction,
        runValues: deliveryRunValues,
        previousStatus: '',
      );
    });
    _advanceMessageRevision(eventValues['project_id']! as String);
  }

  Future<AgentDeliveryAppendDatabaseRecord> appendAgentDelivery(
    Map<String, Object?> eventValues,
    Map<String, Object?> turnValues,
    Map<String, Object?> deliveryRunValues,
    Map<String, Object?> deliveryValues,
    Iterable<String> requestedTargetAgentIds,
    Iterable<String> requestedArtifactVersionIds, {
    required int maxDeliveriesPerTurn,
  }) async {
    final database = await _databaseProvider();
    final record = await database.transaction((transaction) async {
      final projectId = eventValues['project_id']! as String;
      final sourceAgentId = deliveryValues['source_agent_id']! as String;
      final sourceTurnId = deliveryRunValues['turn_id']! as String;
      final rootTurnId = deliveryValues['root_turn_id']! as String;
      final targets = requestedTargetAgentIds.toSet().toList(growable: false);
      final artifactVersionIds = requestedArtifactVersionIds.toSet().toList(
        growable: false,
      );

      final projects = await transaction.query(
        'projects',
        columns: const <String>['last_event_sequence', 'last_message_sequence'],
        where: 'id = ?',
        whereArgs: <Object?>[projectId],
        limit: 1,
      );
      if (projects.isEmpty) throw StateError('delivery_project_not_found');

      final sourceTurns = await transaction.query(
        'project_turns',
        columns: const <String>['status'],
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[sourceTurnId, projectId],
        limit: 1,
      );
      if (sourceTurns.isEmpty) throw StateError('delivery_source_turn_missing');
      if (sourceTurns.single['status'] == 'cancelled') {
        throw StateError('delivery_source_cancelled');
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
      if (!activeSet.contains(sourceAgentId)) {
        throw StateError('delivery_source_not_active');
      }
      if (targets.any((agentId) => !activeSet.contains(agentId))) {
        throw StateError('delivery_target_not_active');
      }

      final duplicates = await transaction.query(
        'agent_deliveries',
        where:
            'root_turn_id = ? AND source_agent_id = ? '
            'AND payload_digest = ?',
        whereArgs: <Object?>[
          rootTurnId,
          sourceAgentId,
          deliveryValues['payload_digest'],
        ],
      );
      for (final duplicate in duplicates) {
        final duplicateEventId = duplicate['event_id']! as String;
        final duplicateTargets = await _loadDeliveryTargets(
          transaction,
          duplicateEventId,
        );
        if (!_sameStringSet(duplicateTargets, targets)) continue;
        final existingEvent = await transaction.query(
          'project_events',
          where: 'id = ?',
          whereArgs: <Object?>[duplicateEventId],
          limit: 1,
        );
        if (existingEvent.isEmpty) continue;
        final existingTurn = await transaction.query(
          'project_turns',
          where: 'id = ?',
          whereArgs: <Object?>[existingEvent.single['turn_id']],
          limit: 1,
        );
        final existingRun = await transaction.query(
          'agent_runs',
          where: 'id = ?',
          whereArgs: <Object?>[existingEvent.single['run_id']],
          limit: 1,
        );
        if (existingTurn.isEmpty || existingRun.isEmpty) continue;
        return AgentDeliveryAppendDatabaseRecord(
          eventValues: existingEvent.single,
          turnValues: existingTurn.single,
          deliveryRunValues: existingRun.single,
          deliveryValues: duplicate,
          targetAgentIds: duplicateTargets,
          artifactVersionIds: await _loadDeliveryArtifacts(
            transaction,
            duplicateEventId,
          ),
          activeAgentIds: activeAgentIds,
          duplicate: true,
        );
      }

      final deliveryCount =
          Sqflite.firstIntValue(
            await transaction.rawQuery(
              'SELECT COUNT(*) FROM agent_deliveries WHERE root_turn_id = ?',
              <Object?>[rootTurnId],
            ),
          ) ??
          0;
      if (deliveryCount >= maxDeliveriesPerTurn) {
        throw StateError('delivery_count_limit_reached');
      }

      final artifactIds = <String>[];
      for (final versionId in artifactVersionIds) {
        final rows = await transaction.rawQuery(
          '''
          SELECT version.artifact_id
          FROM project_artifact_versions AS version
          JOIN project_artifacts AS artifact ON artifact.id = version.artifact_id
          WHERE version.id = ? AND artifact.project_id = ?
          LIMIT 1
          ''',
          <Object?>[versionId, projectId],
        );
        if (rows.isEmpty) {
          throw StateError('delivery_artifact_version_not_found');
        }
        artifactIds.add(rows.single['artifact_id']! as String);
      }

      final project = projects.single;
      final eventSequence = await _nextProjectEventSequence(
        transaction,
        projectId,
        missingProjectError: 'delivery_project_not_found',
      );
      final messageSequence = (project['last_message_sequence']! as int) + 1;
      final event =
          Map<String, Object?>.from(eventValues)
            ..['sequence'] = eventSequence
            ..['message_sequence'] = messageSequence;
      final turn =
          Map<String, Object?>.from(turnValues)
            ..['source_message_sequence'] = messageSequence
            ..['recipient_count'] = targets.length;

      await transaction.insert('project_events', event);
      var position = 0;
      for (final agentId in targets) {
        await transaction.insert('project_event_targets', <String, Object?>{
          'event_id': event['id'],
          'agent_id': agentId,
          'target_kind': 'delivery',
          'position': position++,
        });
      }
      await transaction.insert('project_turns', turn);
      await transaction.insert('agent_runs', deliveryRunValues);
      await transaction.insert('agent_deliveries', deliveryValues);
      for (var index = 0; index < artifactVersionIds.length; index++) {
        await transaction.insert('project_event_artifacts', <String, Object?>{
          'event_id': event['id'],
          'artifact_id': artifactIds[index],
          'artifact_version_id': artifactVersionIds[index],
          'relation': 'reference',
          'position': index,
        });
      }
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
      await _appendRunStatusAuditIfChanged(
        transaction,
        runValues: deliveryRunValues,
        previousStatus: '',
      );
      return AgentDeliveryAppendDatabaseRecord(
        eventValues: event,
        turnValues: turn,
        deliveryRunValues: deliveryRunValues,
        deliveryValues: deliveryValues,
        targetAgentIds: targets,
        artifactVersionIds: artifactVersionIds,
        activeAgentIds: activeAgentIds,
      );
    });
    _advanceMessageRevision(eventValues['project_id']! as String);
    return record;
  }
}

final class AgentDeliveryDatabaseRecord {
  const AgentDeliveryDatabaseRecord({
    required this.deliveryValues,
    required this.targetAgentIds,
    required this.artifactVersionIds,
  });

  final Map<String, Object?> deliveryValues;
  final List<String> targetAgentIds;
  final List<String> artifactVersionIds;
}

final class AgentDeliveryAppendDatabaseRecord {
  const AgentDeliveryAppendDatabaseRecord({
    required this.eventValues,
    required this.turnValues,
    required this.deliveryRunValues,
    required this.deliveryValues,
    required this.targetAgentIds,
    required this.artifactVersionIds,
    required this.activeAgentIds,
    this.duplicate = false,
  });

  final Map<String, Object?> eventValues;
  final Map<String, Object?> turnValues;
  final Map<String, Object?> deliveryRunValues;
  final Map<String, Object?> deliveryValues;
  final List<String> targetAgentIds;
  final List<String> artifactVersionIds;
  final List<String> activeAgentIds;
  final bool duplicate;
}

Future<List<String>> _loadDeliveryTargets(
  DatabaseExecutor database,
  String eventId,
) async {
  final rows = await database.query(
    'project_event_targets',
    columns: const <String>['agent_id'],
    where: 'event_id = ?',
    whereArgs: <Object?>[eventId],
    orderBy: 'position ASC',
  );
  return <String>[for (final row in rows) row['agent_id']! as String];
}

Future<List<String>> _loadDeliveryArtifacts(
  DatabaseExecutor database,
  String eventId,
) async {
  final rows = await database.query(
    'project_event_artifacts',
    columns: const <String>['artifact_version_id'],
    where: "event_id = ? AND relation = 'reference'",
    whereArgs: <Object?>[eventId],
    orderBy: 'position ASC',
  );
  return <String>[
    for (final row in rows) row['artifact_version_id']! as String,
  ];
}

bool _sameStringSet(Iterable<String> left, Iterable<String> right) {
  final leftSet = left.toSet();
  final rightSet = right.toSet();
  return leftSet.length == rightSet.length && leftSet.containsAll(rightSet);
}
