import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:hyve/data/models/project_artifact_records.dart';
import 'package:hyve/data/models/project_execution_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/project_artifact_repository.dart';
import 'package:hyve/domain/repositories/project_storage_repository.dart';

typedef ProjectArtifactClock = DateTime Function();
typedef ProjectArtifactIdFactory = String Function(String prefix);

final class SqliteProjectArtifactRepository
    implements ProjectArtifactRepository {
  SqliteProjectArtifactRepository({
    required LocalDatabaseService localDatabase,
    required ProjectStorageRepository storage,
    ProjectArtifactClock? clock,
    ProjectArtifactIdFactory? idFactory,
  }) : _localDatabase = localDatabase,
       _storage = storage,
       _clock = clock ?? DateTime.now,
       _idFactory = idFactory ?? _defaultProjectArtifactIdFactory;

  final LocalDatabaseService _localDatabase;
  final ProjectStorageRepository _storage;
  final ProjectArtifactClock _clock;
  final ProjectArtifactIdFactory _idFactory;
  final StreamController<String> _changes =
      StreamController<String>.broadcast();

  @override
  Stream<String> get changes => _changes.stream;

  @override
  Future<List<ProjectArtifactEntry>> list({
    required String projectId,
    required ProjectArtifactActor actor,
    int limit = 50,
  }) {
    return search(
      projectId: projectId,
      actor: actor,
      query: ProjectArtifactQuery(limit: limit),
    );
  }

  @override
  Future<List<ProjectArtifactEntry>> search({
    required String projectId,
    required ProjectArtifactActor actor,
    required ProjectArtifactQuery query,
  }) async {
    try {
      final records = await _localDatabase.queryProjectArtifacts(
        projectId: projectId,
        actorType: actor.type.name,
        actorId: actor.id,
        text: query.text,
        kinds: query.kinds.map((kind) => kind.name),
        createdByType: query.createdByType?.name ?? '',
        updatedAfter: query.updatedAfter?.millisecondsSinceEpoch,
        updatedBefore: query.updatedBefore?.millisecondsSinceEpoch,
        limit: query.limit,
      );
      return List<ProjectArtifactEntry>.unmodifiable(
        records.map(_entryFromRecord),
      );
    } on Object catch (error) {
      throw _artifactFailure(error);
    }
  }

  @override
  Future<ProjectArtifactEntry?> get({
    required String projectId,
    required String artifactId,
    required ProjectArtifactActor actor,
  }) async {
    try {
      final record = await _localDatabase.loadProjectArtifact(
        projectId: projectId,
        artifactId: artifactId,
        actorType: actor.type.name,
        actorId: actor.id,
      );
      return record == null ? null : _entryFromRecord(record);
    } on Object catch (error) {
      throw _artifactFailure(error);
    }
  }

  @override
  Future<List<ProjectArtifactVersion>> versions({
    required String projectId,
    required String artifactId,
    required ProjectArtifactActor actor,
  }) async {
    try {
      final rows = await _localDatabase.loadProjectArtifactVersions(
        projectId: projectId,
        artifactId: artifactId,
        actorType: actor.type.name,
        actorId: actor.id,
      );
      return List<ProjectArtifactVersion>.unmodifiable(
        rows.map((row) => ProjectArtifactVersionRecord(row).toDomain()),
      );
    } on Object catch (error) {
      throw _artifactFailure(error);
    }
  }

  @override
  Future<ProjectArtifactReadResult> read({
    required String projectId,
    required String artifactId,
    String versionId = '',
    required ProjectArtifactActor actor,
    int offset = 0,
    int length = 8192,
  }) async {
    if (offset < 0 || length < 1 || length > 32768) {
      throw const ProjectArtifactFailure('artifact_read_range_invalid');
    }
    try {
      final entry = await get(
        projectId: projectId,
        artifactId: artifactId,
        actor: actor,
      );
      if (entry == null) {
        throw const ProjectArtifactFailure('artifact_not_found');
      }
      var version = entry.currentVersion;
      if (versionId.isNotEmpty && versionId != version.id) {
        final row = await _localDatabase.loadProjectArtifactVersion(
          projectId: projectId,
          artifactId: artifactId,
          versionId: versionId,
          actorType: actor.type.name,
          actorId: actor.id,
        );
        if (row == null) {
          throw const ProjectArtifactFailure('artifact_version_not_found');
        }
        version = ProjectArtifactVersionRecord(row).toDomain();
      }
      final bytes = await _storage.read(
        projectId: projectId,
        relativeBlobPath: version.relativeBlobPath,
        offset: offset,
        length: length,
      );
      final nextOffset = offset + bytes.length;
      return ProjectArtifactReadResult(
        artifact: entry.artifact,
        version: version,
        bytes: bytes,
        offset: offset,
        nextOffset: nextOffset,
        endOfFile: nextOffset >= version.byteLength,
        text:
            isProjectArtifactTextMimeType(version.mimeType)
                ? utf8.decode(bytes, allowMalformed: true)
                : null,
      );
    } on Object catch (error) {
      throw _artifactFailure(error);
    }
  }

  @override
  Future<ProjectArtifactMutationResult> create({
    required String projectId,
    required String relativePath,
    required ProjectArtifactKind kind,
    required String mimeType,
    required Uint8List bytes,
    required ProjectArtifactActor actor,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return _create(
      projectId: projectId,
      relativePath: relativePath,
      kind: kind,
      mimeType: mimeType,
      actor: actor,
      metadata: metadata,
      changeKind: ProjectArtifactChangeKind.created,
      writeBlob:
          (artifactId, versionId, resolvedMimeType) => _storage.writeBytes(
            projectId: projectId,
            artifactId: artifactId,
            versionId: versionId,
            bytes: bytes,
            mimeType: resolvedMimeType,
          ),
    );
  }

  @override
  Future<ProjectArtifactMutationResult> import({
    required String projectId,
    required String sourcePath,
    required String relativePath,
    required ProjectArtifactKind kind,
    required String mimeType,
    required ProjectArtifactActor actor,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return _create(
      projectId: projectId,
      relativePath: relativePath,
      kind: kind,
      mimeType: mimeType,
      actor: actor,
      metadata: metadata,
      changeKind: ProjectArtifactChangeKind.imported,
      writeBlob:
          (artifactId, versionId, resolvedMimeType) => _storage.importFile(
            projectId: projectId,
            artifactId: artifactId,
            versionId: versionId,
            sourcePath: sourcePath,
            mimeType: resolvedMimeType,
          ),
    );
  }

  Future<ProjectArtifactMutationResult> _create({
    required String projectId,
    required String relativePath,
    required ProjectArtifactKind kind,
    required String mimeType,
    required ProjectArtifactActor actor,
    required Map<String, Object?> metadata,
    required ProjectArtifactChangeKind changeKind,
    required Future<StoredProjectBlob> Function(
      String artifactId,
      String versionId,
      String mimeType,
    )
    writeBlob,
  }) async {
    final normalizedPath = normalizeProjectArtifactPath(relativePath);
    final resolvedMimeType =
        mimeType.trim().isEmpty
            ? projectArtifactMimeTypeForPath(normalizedPath)
            : mimeType.trim().toLowerCase();
    final artifactId = _idFactory('artifact');
    final versionId = _idFactory('artifact-version');
    final now = _clock();
    StoredProjectBlob? blob;
    try {
      blob = await writeBlob(artifactId, versionId, resolvedMimeType);
      final searchStatus =
          isProjectArtifactTextMimeType(resolvedMimeType)
              ? ProjectArtifactSearchStatus.indexed
              : ProjectArtifactSearchStatus.unsupported;
      final artifact = ProjectArtifact(
        id: artifactId,
        projectId: projectId,
        name: path.posix.basename(normalizedPath),
        relativePath: normalizedPath,
        kind: kind,
        mimeType: resolvedMimeType,
        currentVersionId: versionId,
        searchStatus: searchStatus,
        metadata: metadata,
        createdByType: actor.type,
        createdById: actor.id,
        sourceRunId: actor.sourceRunId,
        createdAt: now,
        updatedAt: now,
      );
      final version = ProjectArtifactVersion(
        id: versionId,
        artifactId: artifactId,
        versionNumber: 1,
        relativeBlobPath: blob.relativePath,
        contentDigest: blob.contentDigest,
        byteLength: blob.byteLength,
        mimeType: resolvedMimeType,
        createdByType: actor.type,
        createdById: actor.id,
        sourceRunId: actor.sourceRunId,
        createdAt: now,
      );
      final event = _auditEvent(
        projectId: projectId,
        artifactId: artifactId,
        versionId: versionId,
        path: normalizedPath,
        actor: actor,
        changeKind: changeKind,
        at: now,
      );
      final record = await _localDatabase.insertProjectArtifact(
        artifactValues: ProjectArtifactRecord.fromDomain(artifact).values,
        versionValues: ProjectArtifactVersionRecord.fromDomain(version).values,
        searchValues: _searchValues(
          artifact: artifact,
          version: version,
          extractedText: blob.extractedText,
        ),
        eventValues: ProjectEventRecord.fromDomain(event).values,
        actorType: actor.type.name,
        actorId: actor.id,
      );
      _emit(projectId);
      return _mutationFromRecord(record);
    } on Object catch (error) {
      if (blob != null) {
        try {
          await _storage.deleteBlob(projectId, blob.relativePath);
        } on Object {
          // An immutable orphan blob is safer than hiding the database failure.
        }
      }
      throw _artifactFailure(error);
    }
  }

  @override
  Future<ProjectArtifactMutationResult> writeVersion({
    required String projectId,
    required String artifactId,
    required Uint8List bytes,
    required ProjectArtifactActor actor,
    String mimeType = '',
    String expectedCurrentVersionId = '',
  }) async {
    StoredProjectBlob? blob;
    try {
      final entry = await get(
        projectId: projectId,
        artifactId: artifactId,
        actor: actor,
      );
      if (entry == null) {
        throw const ProjectArtifactFailure('artifact_not_found');
      }
      final resolvedMimeType =
          mimeType.trim().isEmpty
              ? entry.artifact.mimeType
              : mimeType.trim().toLowerCase();
      final versionId = _idFactory('artifact-version');
      final now = _clock();
      blob = await _storage.writeBytes(
        projectId: projectId,
        artifactId: artifactId,
        versionId: versionId,
        bytes: bytes,
        mimeType: resolvedMimeType,
      );
      final version = ProjectArtifactVersion(
        id: versionId,
        artifactId: artifactId,
        versionNumber: 1,
        relativeBlobPath: blob.relativePath,
        contentDigest: blob.contentDigest,
        byteLength: blob.byteLength,
        mimeType: resolvedMimeType,
        createdByType: actor.type,
        createdById: actor.id,
        sourceRunId: actor.sourceRunId,
        createdAt: now,
      );
      final searchStatus =
          isProjectArtifactTextMimeType(resolvedMimeType)
              ? ProjectArtifactSearchStatus.indexed
              : ProjectArtifactSearchStatus.unsupported;
      final updatedArtifact = ProjectArtifact(
        id: entry.artifact.id,
        projectId: entry.artifact.projectId,
        name: entry.artifact.name,
        relativePath: entry.artifact.relativePath,
        kind: entry.artifact.kind,
        mimeType: resolvedMimeType,
        currentVersionId: versionId,
        searchStatus: searchStatus,
        metadata: entry.artifact.metadata,
        createdByType: entry.artifact.createdByType,
        createdById: entry.artifact.createdById,
        sourceRunId: entry.artifact.sourceRunId,
        createdAt: entry.artifact.createdAt,
        updatedAt: now,
      );
      final event = _auditEvent(
        projectId: projectId,
        artifactId: artifactId,
        versionId: versionId,
        path: entry.artifact.relativePath,
        actor: actor,
        changeKind: ProjectArtifactChangeKind.versionAdded,
        at: now,
      );
      final record = await _localDatabase.appendProjectArtifactVersion(
        projectId: projectId,
        artifactId: artifactId,
        expectedCurrentVersionId: expectedCurrentVersionId,
        versionValues: ProjectArtifactVersionRecord.fromDomain(version).values,
        searchValues: _searchValues(
          artifact: updatedArtifact,
          version: version,
          extractedText: blob.extractedText,
        ),
        eventValues: ProjectEventRecord.fromDomain(event).values,
        mimeType: resolvedMimeType,
        searchStatus: searchStatus.name,
        updatedAt: now.millisecondsSinceEpoch,
        actorType: actor.type.name,
        actorId: actor.id,
      );
      _emit(projectId);
      return _mutationFromRecord(record);
    } on Object catch (error) {
      if (blob != null) {
        try {
          await _storage.deleteBlob(projectId, blob.relativePath);
        } on Object {
          // A later orphan sweep can remove an unreferenced immutable blob.
        }
      }
      throw _artifactFailure(error);
    }
  }

  @override
  Future<ProjectArtifactMutationResult> move({
    required String projectId,
    required String artifactId,
    required String relativePath,
    required ProjectArtifactActor actor,
  }) async {
    final normalizedPath = normalizeProjectArtifactPath(relativePath);
    try {
      final entry = await get(
        projectId: projectId,
        artifactId: artifactId,
        actor: actor,
      );
      if (entry == null) {
        throw const ProjectArtifactFailure('artifact_not_found');
      }
      final now = _clock();
      final event = _auditEvent(
        projectId: projectId,
        artifactId: artifactId,
        versionId: entry.currentVersion.id,
        path: normalizedPath,
        actor: actor,
        changeKind: ProjectArtifactChangeKind.moved,
        at: now,
      );
      final record = await _localDatabase.moveProjectArtifact(
        projectId: projectId,
        artifactId: artifactId,
        name: path.posix.basename(normalizedPath),
        relativePath: normalizedPath,
        eventValues: ProjectEventRecord.fromDomain(event).values,
        updatedAt: now.millisecondsSinceEpoch,
        actorType: actor.type.name,
        actorId: actor.id,
      );
      _emit(projectId);
      return _mutationFromRecord(record);
    } on Object catch (error) {
      throw _artifactFailure(error);
    }
  }

  @override
  Future<void> delete({
    required String projectId,
    required String artifactId,
    required ProjectArtifactActor actor,
  }) async {
    StagedProjectArtifactDeletion? staged;
    try {
      final entry = await get(
        projectId: projectId,
        artifactId: artifactId,
        actor: actor,
      );
      if (entry == null) {
        throw const ProjectArtifactFailure('artifact_not_found');
      }
      staged = await _storage.stageArtifactDeletion(projectId, artifactId);
      final now = _clock();
      final event = _auditEvent(
        projectId: projectId,
        artifactId: artifactId,
        versionId: entry.currentVersion.id,
        path: entry.artifact.relativePath,
        actor: actor,
        changeKind: ProjectArtifactChangeKind.deleted,
        at: now,
      );
      await _localDatabase.deleteProjectArtifact(
        projectId: projectId,
        artifactId: artifactId,
        eventValues: ProjectEventRecord.fromDomain(event).values,
        actorType: actor.type.name,
        actorId: actor.id,
      );
      await staged?.commit();
      _emit(projectId);
    } on Object catch (error) {
      try {
        await staged?.rollback();
      } on Object catch (rollbackError) {
        throw ProjectArtifactFailure(
          'artifact_delete_rollback_failed',
          cause: (error, rollbackError),
        );
      }
      throw _artifactFailure(error);
    }
  }

  ProjectEvent _auditEvent({
    required String projectId,
    required String artifactId,
    required String versionId,
    required String path,
    required ProjectArtifactActor actor,
    required ProjectArtifactChangeKind changeKind,
    required DateTime at,
  }) {
    return ProjectEvent(
      id: _idFactory('artifact-event'),
      projectId: projectId,
      runId: actor.sourceRunId,
      sequence: 1,
      eventType: ProjectEventType.projectArtifactChanged,
      actorType: switch (actor.type) {
        ProjectArtifactActorType.user => ProjectEventActorType.user,
        ProjectArtifactActorType.agent => ProjectEventActorType.agent,
        ProjectArtifactActorType.system => ProjectEventActorType.system,
      },
      actorId: actor.id,
      actorNameSnapshot: actor.name,
      actorAvatarSnapshot: actor.avatar,
      visibility: ProjectEventVisibility.audit,
      content: '${changeKind.name}: $path',
      payload: ProjectArtifactChangedPayload(
        artifactId: artifactId,
        versionId: versionId,
        changeKind: changeKind.name,
      ),
      createdAt: at,
      updatedAt: at,
    );
  }

  static Map<String, Object?> _searchValues({
    required ProjectArtifact artifact,
    required ProjectArtifactVersion version,
    required String extractedText,
  }) {
    final labels = artifact.metadata['labels'];
    return <String, Object?>{
      'artifact_id': artifact.id,
      'project_id': artifact.projectId,
      'name': artifact.name,
      'relative_path': artifact.relativePath,
      'labels_text':
          labels is Iterable<Object?>
              ? labels.whereType<String>().join(' ')
              : labels is String
              ? labels
              : '',
      'extracted_text': extractedText,
      'content_digest': version.contentDigest,
      'updated_at': artifact.updatedAt.millisecondsSinceEpoch,
    };
  }

  static ProjectArtifactEntry _entryFromRecord(
    ProjectArtifactDatabaseRecord record,
  ) {
    return ProjectArtifactEntry(
      artifact: ProjectArtifactRecord(record.artifactValues).toDomain(),
      currentVersion:
          ProjectArtifactVersionRecord(record.versionValues).toDomain(),
      snippet: record.snippet,
    );
  }

  static ProjectArtifactMutationResult _mutationFromRecord(
    ProjectArtifactMutationDatabaseRecord record,
  ) {
    return ProjectArtifactMutationResult(
      artifact: ProjectArtifactRecord(record.artifactValues).toDomain(),
      version: ProjectArtifactVersionRecord(record.versionValues).toDomain(),
      auditEventId: record.eventValues['id']! as String,
    );
  }

  void _emit(String projectId) {
    if (!_changes.isClosed) _changes.add(projectId);
  }

  Future<void> dispose() => _changes.close();
}

String normalizeProjectArtifactPath(String input) {
  final replaced = input.replaceAll('\\', '/').trim();
  if (replaced.isEmpty ||
      replaced.length > 512 ||
      path.posix.isAbsolute(replaced) ||
      replaced.split('/').contains('..')) {
    throw const ProjectArtifactFailure('artifact_path_invalid');
  }
  final normalized = path.posix.normalize(replaced);
  if (normalized == '.' ||
      normalized.startsWith('../') ||
      normalized
          .split('/')
          .any((segment) => segment.isEmpty || segment == '.')) {
    throw const ProjectArtifactFailure('artifact_path_invalid');
  }
  return normalized;
}

String projectArtifactMimeTypeForPath(String relativePath) {
  return switch (path.posix.extension(relativePath).toLowerCase()) {
    '.txt' => 'text/plain',
    '.md' || '.markdown' => 'text/markdown',
    '.dart' => 'text/x-dart',
    '.js' || '.mjs' => 'text/javascript',
    '.ts' || '.tsx' => 'text/typescript',
    '.json' => 'application/json',
    '.yaml' || '.yml' => 'application/yaml',
    '.xml' => 'application/xml',
    '.csv' => 'text/csv',
    '.html' || '.htm' => 'text/html',
    '.css' => 'text/css',
    '.png' => 'image/png',
    '.jpg' || '.jpeg' => 'image/jpeg',
    '.gif' => 'image/gif',
    '.webp' => 'image/webp',
    '.svg' => 'image/svg+xml',
    '.pdf' => 'application/pdf',
    '.zip' => 'application/zip',
    '.mp3' => 'audio/mpeg',
    '.wav' => 'audio/wav',
    '.mp4' => 'video/mp4',
    _ => 'application/octet-stream',
  };
}

ProjectArtifactKind projectArtifactKindForPath(String relativePath) {
  final mimeType = projectArtifactMimeTypeForPath(relativePath);
  if (mimeType.startsWith('image/')) return ProjectArtifactKind.image;
  if (mimeType.startsWith('audio/')) return ProjectArtifactKind.audio;
  if (mimeType.startsWith('video/')) return ProjectArtifactKind.video;
  if (mimeType == 'application/zip') return ProjectArtifactKind.archive;
  if (mimeType == 'text/csv' || mimeType == 'application/json') {
    return ProjectArtifactKind.dataset;
  }
  final extension = path.posix.extension(relativePath).toLowerCase();
  if (const <String>{
    '.dart',
    '.js',
    '.mjs',
    '.ts',
    '.tsx',
    '.html',
    '.css',
    '.sql',
  }.contains(extension)) {
    return ProjectArtifactKind.code;
  }
  if (isProjectArtifactTextMimeType(mimeType) ||
      mimeType == 'application/pdf') {
    return ProjectArtifactKind.document;
  }
  return ProjectArtifactKind.other;
}

bool isProjectArtifactTextMimeType(String mimeType) {
  final normalized = mimeType.toLowerCase().split(';').first.trim();
  return normalized.startsWith('text/') ||
      const <String>{
        'application/json',
        'application/ld+json',
        'application/xml',
        'application/javascript',
        'application/x-yaml',
        'application/yaml',
        'application/sql',
        'image/svg+xml',
      }.contains(normalized);
}

ProjectArtifactFailure _artifactFailure(Object error) {
  if (error is ProjectArtifactFailure) return error;
  if (error is StateError) return ProjectArtifactFailure(error.message);
  final text = error.toString();
  if (text.contains('UNIQUE constraint failed') &&
      text.contains('project_artifacts.project_id')) {
    return ProjectArtifactFailure('artifact_path_conflict', cause: error);
  }
  return ProjectArtifactFailure('artifact_storage_failed', cause: error);
}

int _projectArtifactIdentitySequence = 0;

String _defaultProjectArtifactIdFactory(String prefix) {
  _projectArtifactIdentitySequence =
      (_projectArtifactIdentitySequence + 1) & 0x7fffffff;
  return '$prefix:${DateTime.now().microsecondsSinceEpoch}:'
      '$_projectArtifactIdentitySequence';
}
