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
  Future<ProjectEvent?> getMessageAt(
    String projectId,
    int messageSequence,
  ) async {
    if (messageSequence <= 0) {
      throw ArgumentError.value(messageSequence, 'messageSequence');
    }
    final records = await _localDatabase.loadProjectMessageAt(
      projectId,
      messageSequence,
    );
    return records.isEmpty ? null : _restore(records.single);
  }

  @override
  Future<List<ProjectEvent>> getMessageRange(
    String projectId, {
    required int startMessageSequence,
    required int endMessageSequence,
  }) async {
    if (startMessageSequence < 1 || endMessageSequence < startMessageSequence) {
      throw ArgumentError('Project message range is invalid.');
    }
    final events = <ProjectEvent>[];
    for (final record in await _localDatabase.loadProjectMessageRange(
      projectId,
      startMessageSequence: startMessageSequence,
      endMessageSequence: endMessageSequence,
    )) {
      events.add(await _restore(record));
    }
    return List<ProjectEvent>.unmodifiable(events);
  }

  @override
  Future<ProjectEvent?> getAgentReplyForRun(String runId) async {
    final records = await _localDatabase.loadAgentReplyForRun(runId);
    return records.isEmpty ? null : _restore(records.single);
  }

  @override
  Future<int> countAgentMessagesForRoot(
    String projectId,
    String rootMessageId,
  ) => _localDatabase.countAgentMessagesForRoot(projectId, rootMessageId);

  @override
  Future<List<ProjectEvent>> getVisibleMessagesThrough(
    String projectId,
    String agentId,
    int throughMessageSequence, {
    int limit = 200,
  }) async {
    if (throughMessageSequence <= 0 || limit <= 0) {
      throw ArgumentError('Message sequence and limit must be positive.');
    }
    final events = <ProjectEvent>[];
    for (final record in await _localDatabase.loadVisibleProjectMessages(
      projectId,
      agentId,
      throughMessageSequence,
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
