part of 'local_database_service.dart';

extension LocalDatabaseProjectArtifacts on LocalDatabaseService {
  Future<List<ProjectArtifactDatabaseRecord>> queryProjectArtifacts({
    required String projectId,
    required String actorType,
    required String actorId,
    required String text,
    required Iterable<String> kinds,
    String createdByType = '',
    int? updatedAfter,
    int? updatedBefore,
    required int limit,
  }) async {
    final database = await _databaseProvider();
    return database.transaction((transaction) async {
      await _requireProjectArtifactAccess(
        transaction,
        projectId: projectId,
        actorType: actorType,
        actorId: actorId,
        write: false,
      );
      final clauses = <String>['artifact.project_id = ?'];
      final arguments = <Object?>[projectId];
      final normalized = text.trim().toLowerCase();
      if (normalized.isNotEmpty) {
        clauses.add(
          '(LOWER(artifact.name) LIKE ? OR '
          'LOWER(artifact.relative_path) LIKE ? OR '
          'LOWER(search.labels_text) LIKE ? OR '
          'LOWER(search.extracted_text) LIKE ?)',
        );
        final pattern = '%$normalized%';
        arguments.addAll(<Object?>[pattern, pattern, pattern, pattern]);
      }
      final kindList = kinds.toSet().toList(growable: false);
      if (kindList.isNotEmpty) {
        clauses.add(
          'artifact.kind IN (${List.filled(kindList.length, '?').join(',')})',
        );
        arguments.addAll(kindList);
      }
      if (createdByType.isNotEmpty) {
        clauses.add('artifact.created_by_type = ?');
        arguments.add(createdByType);
      }
      if (updatedAfter != null) {
        clauses.add('artifact.updated_at >= ?');
        arguments.add(updatedAfter);
      }
      if (updatedBefore != null) {
        clauses.add('artifact.updated_at <= ?');
        arguments.add(updatedBefore);
      }
      arguments.add(limit);
      final artifacts = await transaction.rawQuery('''
        SELECT artifact.*, search.extracted_text AS search_text
        FROM project_artifacts AS artifact
        LEFT JOIN project_artifact_search_documents AS search
          ON search.artifact_id = artifact.id
        WHERE ${clauses.join(' AND ')}
        ORDER BY artifact.updated_at DESC, artifact.name ASC
        LIMIT ?
        ''', arguments);
      final records = <ProjectArtifactDatabaseRecord>[];
      for (final artifact in artifacts) {
        final versions = await transaction.query(
          'project_artifact_versions',
          where: 'id = ? AND artifact_id = ?',
          whereArgs: <Object?>[artifact['current_version_id'], artifact['id']],
          limit: 1,
        );
        if (versions.isEmpty) {
          throw StateError('artifact_current_version_missing');
        }
        records.add(
          ProjectArtifactDatabaseRecord(
            artifactValues: artifact,
            versionValues: versions.single,
            snippet: _artifactSnippet(
              artifact['search_text'] as String? ?? '',
              normalized,
            ),
          ),
        );
      }
      return records;
    });
  }

  Future<ProjectArtifactDatabaseRecord?> loadProjectArtifact({
    required String projectId,
    required String artifactId,
    required String actorType,
    required String actorId,
  }) async {
    final database = await _databaseProvider();
    return database.transaction((transaction) async {
      await _requireProjectArtifactAccess(
        transaction,
        projectId: projectId,
        actorType: actorType,
        actorId: actorId,
        write: false,
      );
      final artifacts = await transaction.query(
        'project_artifacts',
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[artifactId, projectId],
        limit: 1,
      );
      if (artifacts.isEmpty) return null;
      final artifact = artifacts.single;
      final versions = await transaction.query(
        'project_artifact_versions',
        where: 'id = ? AND artifact_id = ?',
        whereArgs: <Object?>[artifact['current_version_id'], artifactId],
        limit: 1,
      );
      if (versions.isEmpty) {
        throw StateError('artifact_current_version_missing');
      }
      return ProjectArtifactDatabaseRecord(
        artifactValues: artifact,
        versionValues: versions.single,
      );
    });
  }

  Future<List<Map<String, Object?>>> loadProjectArtifactVersions({
    required String projectId,
    required String artifactId,
    required String actorType,
    required String actorId,
  }) async {
    final database = await _databaseProvider();
    return database.transaction((transaction) async {
      await _requireProjectArtifactAccess(
        transaction,
        projectId: projectId,
        actorType: actorType,
        actorId: actorId,
        write: false,
      );
      final artifact = await transaction.query(
        'project_artifacts',
        columns: const <String>['id'],
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[artifactId, projectId],
        limit: 1,
      );
      if (artifact.isEmpty) throw StateError('artifact_not_found');
      return transaction.query(
        'project_artifact_versions',
        where: 'artifact_id = ?',
        whereArgs: <Object?>[artifactId],
        orderBy: 'version_number DESC',
      );
    });
  }

  Future<Map<String, Object?>?> loadProjectArtifactVersion({
    required String projectId,
    required String artifactId,
    required String versionId,
    required String actorType,
    required String actorId,
  }) async {
    final database = await _databaseProvider();
    return database.transaction((transaction) async {
      await _requireProjectArtifactAccess(
        transaction,
        projectId: projectId,
        actorType: actorType,
        actorId: actorId,
        write: false,
      );
      final rows = await transaction.rawQuery(
        '''
        SELECT version.*
        FROM project_artifact_versions AS version
        JOIN project_artifacts AS artifact ON artifact.id = version.artifact_id
        WHERE artifact.project_id = ? AND artifact.id = ? AND version.id = ?
        LIMIT 1
        ''',
        <Object?>[projectId, artifactId, versionId],
      );
      return rows.isEmpty ? null : rows.single;
    });
  }

  Future<ProjectArtifactMutationDatabaseRecord> insertProjectArtifact({
    required Map<String, Object?> artifactValues,
    required Map<String, Object?> versionValues,
    required Map<String, Object?> searchValues,
    required Map<String, Object?> eventValues,
    required String actorType,
    required String actorId,
  }) async {
    final database = await _databaseProvider();
    final record = await database.transaction((transaction) async {
      final projectId = artifactValues['project_id']! as String;
      await _requireProjectArtifactAccess(
        transaction,
        projectId: projectId,
        actorType: actorType,
        actorId: actorId,
        write: true,
      );
      final event = await _prepareArtifactAuditEvent(
        transaction,
        projectId,
        eventValues,
      );
      await transaction.insert('project_artifacts', artifactValues);
      await transaction.insert('project_artifact_versions', versionValues);
      await transaction.insert(
        'project_artifact_search_documents',
        searchValues,
      );
      await transaction.insert('project_events', event);
      await _advanceArtifactAuditSequence(transaction, projectId, event);
      return ProjectArtifactMutationDatabaseRecord(
        artifactValues: artifactValues,
        versionValues: versionValues,
        eventValues: event,
      );
    });
    _advanceMessageRevision(artifactValues['project_id']! as String);
    return record;
  }

  Future<ProjectArtifactMutationDatabaseRecord> appendProjectArtifactVersion({
    required String projectId,
    required String artifactId,
    required String expectedCurrentVersionId,
    required Map<String, Object?> versionValues,
    required Map<String, Object?> searchValues,
    required Map<String, Object?> eventValues,
    required String mimeType,
    required String searchStatus,
    required int updatedAt,
    required String actorType,
    required String actorId,
  }) async {
    final database = await _databaseProvider();
    final record = await database.transaction((transaction) async {
      await _requireProjectArtifactAccess(
        transaction,
        projectId: projectId,
        actorType: actorType,
        actorId: actorId,
        write: true,
      );
      final artifacts = await transaction.query(
        'project_artifacts',
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[artifactId, projectId],
        limit: 1,
      );
      if (artifacts.isEmpty) throw StateError('artifact_not_found');
      final artifact = artifacts.single;
      if (expectedCurrentVersionId.isNotEmpty &&
          artifact['current_version_id'] != expectedCurrentVersionId) {
        throw StateError('artifact_version_conflict');
      }
      final versionNumber =
          (Sqflite.firstIntValue(
                await transaction.rawQuery(
                  'SELECT MAX(version_number) FROM project_artifact_versions '
                  'WHERE artifact_id = ?',
                  <Object?>[artifactId],
                ),
              ) ??
              0) +
          1;
      final version = Map<String, Object?>.from(versionValues)
        ..['version_number'] = versionNumber;
      final event = await _prepareArtifactAuditEvent(
        transaction,
        projectId,
        eventValues,
      );
      await transaction.insert('project_artifact_versions', version);
      await transaction.update(
        'project_artifacts',
        <String, Object?>{
          'current_version_id': version['id'],
          'mime_type': mimeType,
          'search_status': searchStatus,
          'updated_at': updatedAt,
        },
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[artifactId, projectId],
      );
      await transaction.insert(
        'project_artifact_search_documents',
        searchValues,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await transaction.insert('project_events', event);
      await _advanceArtifactAuditSequence(transaction, projectId, event);
      final updated =
          Map<String, Object?>.from(artifact)
            ..['current_version_id'] = version['id']
            ..['mime_type'] = mimeType
            ..['search_status'] = searchStatus
            ..['updated_at'] = updatedAt;
      return ProjectArtifactMutationDatabaseRecord(
        artifactValues: updated,
        versionValues: version,
        eventValues: event,
      );
    });
    _advanceMessageRevision(projectId);
    return record;
  }

  Future<ProjectArtifactMutationDatabaseRecord> moveProjectArtifact({
    required String projectId,
    required String artifactId,
    required String name,
    required String relativePath,
    required Map<String, Object?> eventValues,
    required int updatedAt,
    required String actorType,
    required String actorId,
  }) async {
    final database = await _databaseProvider();
    final record = await database.transaction((transaction) async {
      await _requireProjectArtifactAccess(
        transaction,
        projectId: projectId,
        actorType: actorType,
        actorId: actorId,
        write: true,
      );
      final artifacts = await transaction.query(
        'project_artifacts',
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[artifactId, projectId],
        limit: 1,
      );
      if (artifacts.isEmpty) throw StateError('artifact_not_found');
      final artifact = artifacts.single;
      final versions = await transaction.query(
        'project_artifact_versions',
        where: 'id = ?',
        whereArgs: <Object?>[artifact['current_version_id']],
        limit: 1,
      );
      if (versions.isEmpty) {
        throw StateError('artifact_current_version_missing');
      }
      final event = await _prepareArtifactAuditEvent(
        transaction,
        projectId,
        eventValues,
      );
      await transaction.update(
        'project_artifacts',
        <String, Object?>{
          'name': name,
          'relative_path': relativePath,
          'updated_at': updatedAt,
        },
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[artifactId, projectId],
      );
      await transaction.update(
        'project_artifact_search_documents',
        <String, Object?>{
          'name': name,
          'relative_path': relativePath,
          'updated_at': updatedAt,
        },
        where: 'artifact_id = ?',
        whereArgs: <Object?>[artifactId],
      );
      await transaction.insert('project_events', event);
      await _advanceArtifactAuditSequence(transaction, projectId, event);
      final updated =
          Map<String, Object?>.from(artifact)
            ..['name'] = name
            ..['relative_path'] = relativePath
            ..['updated_at'] = updatedAt;
      return ProjectArtifactMutationDatabaseRecord(
        artifactValues: updated,
        versionValues: versions.single,
        eventValues: event,
      );
    });
    _advanceMessageRevision(projectId);
    return record;
  }

  Future<void> deleteProjectArtifact({
    required String projectId,
    required String artifactId,
    required Map<String, Object?> eventValues,
    required String actorType,
    required String actorId,
  }) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await _requireProjectArtifactAccess(
        transaction,
        projectId: projectId,
        actorType: actorType,
        actorId: actorId,
        write: true,
      );
      final artifacts = await transaction.query(
        'project_artifacts',
        columns: const <String>['id'],
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[artifactId, projectId],
        limit: 1,
      );
      if (artifacts.isEmpty) throw StateError('artifact_not_found');
      final referenceCount =
          Sqflite.firstIntValue(
            await transaction.rawQuery(
              'SELECT COUNT(*) FROM project_event_artifacts '
              'WHERE artifact_id = ?',
              <Object?>[artifactId],
            ),
          ) ??
          0;
      if (referenceCount > 0) throw StateError('artifact_is_referenced');
      final event = await _prepareArtifactAuditEvent(
        transaction,
        projectId,
        eventValues,
      );
      await transaction.insert('project_events', event);
      await transaction.delete(
        'project_artifacts',
        where: 'id = ? AND project_id = ?',
        whereArgs: <Object?>[artifactId, projectId],
      );
      await _advanceArtifactAuditSequence(transaction, projectId, event);
    });
    _advanceMessageRevision(projectId);
  }
}

final class ProjectArtifactDatabaseRecord {
  const ProjectArtifactDatabaseRecord({
    required this.artifactValues,
    required this.versionValues,
    this.snippet = '',
  });

  final Map<String, Object?> artifactValues;
  final Map<String, Object?> versionValues;
  final String snippet;
}

final class ProjectArtifactMutationDatabaseRecord {
  const ProjectArtifactMutationDatabaseRecord({
    required this.artifactValues,
    required this.versionValues,
    required this.eventValues,
  });

  final Map<String, Object?> artifactValues;
  final Map<String, Object?> versionValues;
  final Map<String, Object?> eventValues;
}

Future<void> _requireProjectArtifactAccess(
  DatabaseExecutor database, {
  required String projectId,
  required String actorType,
  required String actorId,
  required bool write,
}) async {
  final projects = await database.query(
    'projects',
    columns: const <String>['id'],
    where: 'id = ?',
    whereArgs: <Object?>[projectId],
    limit: 1,
  );
  if (projects.isEmpty) throw StateError('artifact_project_not_found');
  if (actorType == 'user' || actorType == 'system') return;
  if (actorType != 'agent' || actorId.isEmpty) {
    throw StateError('artifact_actor_invalid');
  }
  final memberships = await database.query(
    'project_memberships',
    columns: const <String>['status', 'project_storage_access'],
    where: 'project_id = ? AND agent_id = ?',
    whereArgs: <Object?>[projectId, actorId],
    limit: 1,
  );
  if (memberships.isEmpty || memberships.single['status'] != 'active') {
    throw StateError('artifact_membership_not_active');
  }
  final access = memberships.single['project_storage_access'];
  if (access == 'none' || (write && access != 'readWrite')) {
    throw StateError(
      write ? 'artifact_write_forbidden' : 'artifact_read_forbidden',
    );
  }
}

Future<Map<String, Object?>> _prepareArtifactAuditEvent(
  DatabaseExecutor database,
  String projectId,
  Map<String, Object?> eventValues,
) async {
  final projects = await database.query(
    'projects',
    columns: const <String>['last_event_sequence'],
    where: 'id = ?',
    whereArgs: <Object?>[projectId],
    limit: 1,
  );
  if (projects.isEmpty) throw StateError('artifact_project_not_found');
  return Map<String, Object?>.from(eventValues)
    ..['sequence'] = (projects.single['last_event_sequence']! as int) + 1;
}

Future<void> _advanceArtifactAuditSequence(
  DatabaseExecutor database,
  String projectId,
  Map<String, Object?> event,
) {
  return database.update(
    'projects',
    <String, Object?>{
      'last_event_sequence': event['sequence'],
      'updated_at': event['updated_at'],
    },
    where: 'id = ?',
    whereArgs: <Object?>[projectId],
  );
}

String _artifactSnippet(String text, String query) {
  if (text.isEmpty) return '';
  if (query.isEmpty) {
    return text.length <= 240 ? text : '${text.substring(0, 240)}…';
  }
  final index = text.toLowerCase().indexOf(query);
  if (index < 0) return '';
  final start = index > 80 ? index - 80 : 0;
  final end = start + 240 < text.length ? start + 240 : text.length;
  return '${start > 0 ? '…' : ''}${text.substring(start, end)}'
      '${end < text.length ? '…' : ''}';
}
