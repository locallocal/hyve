import 'dart:async';

import 'package:hyve/data/models/project_execution_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/project_event.dart';
import 'package:hyve/domain/repositories/project_event_repository.dart';

final class SqliteProjectEventRepository implements ProjectEventRepository {
  SqliteProjectEventRepository({required LocalDatabaseService localDatabase})
    : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;
  final StreamController<String> _changes =
      StreamController<String>.broadcast();

  @override
  Stream<String> get changes => _changes.stream;

  @override
  Future<ProjectEvent?> getEvent(String id) async {
    final records = await _localDatabase.loadProjectEvent(id);
    if (records.isEmpty) return null;
    return _restore(records.single);
  }

  @override
  Future<List<ProjectEvent>> getEvents(
    String projectId, {
    int? afterSequence,
    int limit = 100,
  }) async {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'Must be positive.');
    }
    final events = <ProjectEvent>[];
    for (final record in await _localDatabase.loadProjectEvents(
      projectId,
      afterSequence: afterSequence,
      limit: limit,
    )) {
      events.add(await _restore(record));
    }
    return List<ProjectEvent>.unmodifiable(events);
  }

  @override
  Future<void> save(ProjectEvent event) async {
    await _localDatabase.saveProjectEvent(
      ProjectEventRecord.fromDomain(event).values,
      event.targetAgentIds,
    );
    if (!_changes.isClosed) _changes.add(event.projectId);
  }

  Future<ProjectEvent> _restore(Map<String, Object?> values) async {
    final eventId = values['id']! as String;
    final targets = await _localDatabase.loadProjectEventTargets(eventId);
    return ProjectEventRecord(values).toDomain(
      targetAgentIds: targets.map((target) => target['agent_id']! as String),
    );
  }

  Future<void> dispose() => _changes.close();
}
