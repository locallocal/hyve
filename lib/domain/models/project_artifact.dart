import 'dart:collection';
import 'dart:typed_data';

enum ProjectArtifactKind {
  attachment,
  document,
  code,
  image,
  audio,
  video,
  dataset,
  archive,
  generated,
  other,
}

enum ProjectArtifactSearchStatus { pending, indexed, unsupported, failed }

enum ProjectArtifactActorType { user, agent, system }

enum ProjectArtifactChangeKind {
  created,
  imported,
  versionAdded,
  moved,
  deleted,
}

final class ProjectArtifactActor {
  const ProjectArtifactActor({
    required this.type,
    this.id = '',
    this.name = '',
    this.avatar = '',
    this.sourceRunId = '',
  });

  final ProjectArtifactActorType type;
  final String id;
  final String name;
  final String avatar;
  final String sourceRunId;
}

final class ProjectArtifact {
  ProjectArtifact({
    required this.id,
    required this.projectId,
    required this.name,
    required this.relativePath,
    required this.kind,
    required this.mimeType,
    required this.currentVersionId,
    required this.searchStatus,
    Map<String, Object?> metadata = const <String, Object?>{},
    required this.createdByType,
    required this.createdById,
    required this.sourceRunId,
    required this.createdAt,
    required this.updatedAt,
  }) : metadata = UnmodifiableMapView(Map<String, Object?>.from(metadata)) {
    if (id.trim().isEmpty ||
        projectId.trim().isEmpty ||
        name.trim().isEmpty ||
        relativePath.trim().isEmpty ||
        currentVersionId.trim().isEmpty) {
      throw ArgumentError(
        'Artifact identity, name, path and version are required.',
      );
    }
  }

  final String id;
  final String projectId;
  final String name;
  final String relativePath;
  final ProjectArtifactKind kind;
  final String mimeType;
  final String currentVersionId;
  final ProjectArtifactSearchStatus searchStatus;
  final Map<String, Object?> metadata;
  final ProjectArtifactActorType createdByType;
  final String createdById;
  final String sourceRunId;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class ProjectArtifactVersion {
  const ProjectArtifactVersion({
    required this.id,
    required this.artifactId,
    required this.versionNumber,
    required this.relativeBlobPath,
    required this.contentDigest,
    required this.byteLength,
    required this.mimeType,
    required this.createdByType,
    required this.createdById,
    required this.sourceRunId,
    required this.createdAt,
  }) : assert(versionNumber > 0),
       assert(byteLength >= 0);

  final String id;
  final String artifactId;
  final int versionNumber;
  final String relativeBlobPath;
  final String contentDigest;
  final int byteLength;
  final String mimeType;
  final ProjectArtifactActorType createdByType;
  final String createdById;
  final String sourceRunId;
  final DateTime createdAt;
}

final class ProjectArtifactEntry {
  const ProjectArtifactEntry({
    required this.artifact,
    required this.currentVersion,
    this.snippet = '',
  });

  final ProjectArtifact artifact;
  final ProjectArtifactVersion currentVersion;
  final String snippet;
}

final class ProjectArtifactQuery {
  ProjectArtifactQuery({
    this.text = '',
    Iterable<ProjectArtifactKind> kinds = const <ProjectArtifactKind>[],
    this.createdByType,
    this.updatedAfter,
    this.updatedBefore,
    this.limit = 20,
  }) : kinds = Set<ProjectArtifactKind>.unmodifiable(kinds) {
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 100.');
    }
  }

  final String text;
  final Set<ProjectArtifactKind> kinds;
  final ProjectArtifactActorType? createdByType;
  final DateTime? updatedAfter;
  final DateTime? updatedBefore;
  final int limit;
}

final class ProjectArtifactReadResult {
  ProjectArtifactReadResult({
    required this.artifact,
    required this.version,
    required Uint8List bytes,
    required this.offset,
    required this.nextOffset,
    required this.endOfFile,
    this.text,
  }) : bytes = Uint8List.fromList(bytes);

  final ProjectArtifact artifact;
  final ProjectArtifactVersion version;
  final Uint8List bytes;
  final int offset;
  final int nextOffset;
  final bool endOfFile;
  final String? text;
}

final class ProjectArtifactMutationResult {
  const ProjectArtifactMutationResult({
    required this.artifact,
    required this.version,
    required this.auditEventId,
  });

  final ProjectArtifact artifact;
  final ProjectArtifactVersion version;
  final String auditEventId;
}

final class ProjectArtifactFailure implements Exception {
  const ProjectArtifactFailure(this.code, {this.cause});

  final String code;
  final Object? cause;

  @override
  String toString() => 'ProjectArtifactFailure($code)';
}
