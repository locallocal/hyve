import 'dart:convert';

import 'package:hyve/domain/models/project_artifact.dart';

final class ProjectArtifactRecord {
  const ProjectArtifactRecord(this.values);

  factory ProjectArtifactRecord.fromDomain(ProjectArtifact artifact) {
    return ProjectArtifactRecord(<String, Object?>{
      'id': artifact.id,
      'project_id': artifact.projectId,
      'name': artifact.name,
      'relative_path': artifact.relativePath,
      'kind': artifact.kind.name,
      'mime_type': artifact.mimeType,
      'current_version_id': artifact.currentVersionId,
      'search_status': artifact.searchStatus.name,
      'metadata_json': jsonEncode(artifact.metadata),
      'created_by_type': artifact.createdByType.name,
      'created_by_id': artifact.createdById,
      'source_run_id': artifact.sourceRunId,
      'created_at': artifact.createdAt.millisecondsSinceEpoch,
      'updated_at': artifact.updatedAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  ProjectArtifact toDomain() {
    return ProjectArtifact(
      id: _text(values['id'], 'id'),
      projectId: _text(values['project_id'], 'project_id'),
      name: _text(values['name'], 'name'),
      relativePath: _text(values['relative_path'], 'relative_path'),
      kind: _enumValue(
        ProjectArtifactKind.values,
        _text(values['kind'], 'kind'),
        'kind',
      ),
      mimeType: _text(values['mime_type'], 'mime_type'),
      currentVersionId: _text(
        values['current_version_id'],
        'current_version_id',
      ),
      searchStatus: _enumValue(
        ProjectArtifactSearchStatus.values,
        _text(values['search_status'], 'search_status'),
        'search_status',
      ),
      metadata: _jsonMap(values['metadata_json'], 'metadata_json'),
      createdByType: _enumValue(
        ProjectArtifactActorType.values,
        _text(values['created_by_type'], 'created_by_type'),
        'created_by_type',
      ),
      createdById: _text(values['created_by_id'], 'created_by_id'),
      sourceRunId: _text(values['source_run_id'], 'source_run_id'),
      createdAt: _date(values['created_at'], 'created_at'),
      updatedAt: _date(values['updated_at'], 'updated_at'),
    );
  }
}

final class ProjectArtifactVersionRecord {
  const ProjectArtifactVersionRecord(this.values);

  factory ProjectArtifactVersionRecord.fromDomain(
    ProjectArtifactVersion version,
  ) {
    return ProjectArtifactVersionRecord(<String, Object?>{
      'id': version.id,
      'artifact_id': version.artifactId,
      'version_number': version.versionNumber,
      'relative_blob_path': version.relativeBlobPath,
      'content_digest': version.contentDigest,
      'byte_length': version.byteLength,
      'mime_type': version.mimeType,
      'created_by_type': version.createdByType.name,
      'created_by_id': version.createdById,
      'source_run_id': version.sourceRunId,
      'created_at': version.createdAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  ProjectArtifactVersion toDomain() {
    return ProjectArtifactVersion(
      id: _text(values['id'], 'id'),
      artifactId: _text(values['artifact_id'], 'artifact_id'),
      versionNumber: _integer(values['version_number'], 'version_number'),
      relativeBlobPath: _text(
        values['relative_blob_path'],
        'relative_blob_path',
      ),
      contentDigest: _text(values['content_digest'], 'content_digest'),
      byteLength: _integer(values['byte_length'], 'byte_length'),
      mimeType: _text(values['mime_type'], 'mime_type'),
      createdByType: _enumValue(
        ProjectArtifactActorType.values,
        _text(values['created_by_type'], 'created_by_type'),
        'created_by_type',
      ),
      createdById: _text(values['created_by_id'], 'created_by_id'),
      sourceRunId: _text(values['source_run_id'], 'source_run_id'),
      createdAt: _date(values['created_at'], 'created_at'),
    );
  }
}

String _text(Object? value, String field) {
  if (value is! String) throw FormatException('$field must be text.');
  return value;
}

int _integer(Object? value, String field) {
  if (value is! int) throw FormatException('$field must be an integer.');
  return value;
}

DateTime _date(Object? value, String field) {
  return DateTime.fromMillisecondsSinceEpoch(_integer(value, field));
}

T _enumValue<T extends Enum>(List<T> values, String name, String field) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('$field has an unsupported enum value.');
}

Map<String, Object?> _jsonMap(Object? value, String field) {
  if (value is! String) throw FormatException('$field must be JSON text.');
  final decoded = jsonDecode(value);
  if (decoded is! Map<Object?, Object?> ||
      decoded.keys.any((key) => key is! String)) {
    throw FormatException('$field must contain a JSON object.');
  }
  return <String, Object?>{
    for (final entry in decoded.entries) entry.key! as String: entry.value,
  };
}
