import 'dart:typed_data';

import 'package:hyve/domain/models/project_artifact.dart';

abstract interface class ProjectArtifactRepository {
  Stream<String> get changes;

  Future<List<ProjectArtifactEntry>> list({
    required String projectId,
    required ProjectArtifactActor actor,
    int limit = 50,
  });

  Future<List<ProjectArtifactEntry>> search({
    required String projectId,
    required ProjectArtifactActor actor,
    required ProjectArtifactQuery query,
  });

  Future<ProjectArtifactEntry?> get({
    required String projectId,
    required String artifactId,
    required ProjectArtifactActor actor,
  });

  Future<List<ProjectArtifactVersion>> versions({
    required String projectId,
    required String artifactId,
    required ProjectArtifactActor actor,
  });

  Future<ProjectArtifactReadResult> read({
    required String projectId,
    required String artifactId,
    String versionId = '',
    required ProjectArtifactActor actor,
    int offset = 0,
    int length = 8192,
  });

  Future<ProjectArtifactMutationResult> create({
    required String projectId,
    required String relativePath,
    required ProjectArtifactKind kind,
    required String mimeType,
    required Uint8List bytes,
    required ProjectArtifactActor actor,
    Map<String, Object?> metadata = const <String, Object?>{},
  });

  Future<ProjectArtifactMutationResult> import({
    required String projectId,
    required String sourcePath,
    required String relativePath,
    required ProjectArtifactKind kind,
    required String mimeType,
    required ProjectArtifactActor actor,
    Map<String, Object?> metadata = const <String, Object?>{},
  });

  Future<ProjectArtifactMutationResult> writeVersion({
    required String projectId,
    required String artifactId,
    required Uint8List bytes,
    required ProjectArtifactActor actor,
    String mimeType = '',
    String expectedCurrentVersionId = '',
  });

  Future<ProjectArtifactMutationResult> move({
    required String projectId,
    required String artifactId,
    required String relativePath,
    required ProjectArtifactActor actor,
  });

  Future<void> delete({
    required String projectId,
    required String artifactId,
    required ProjectArtifactActor actor,
  });
}
