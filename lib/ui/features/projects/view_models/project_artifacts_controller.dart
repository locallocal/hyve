import 'package:flutter/foundation.dart';
import 'package:hyve/domain/models/models.dart';

/// The artifact-specific contract consumed by the Project artifact views.
///
/// Keeping this narrower than the complete workspace view model makes the
/// view's notification lifecycle explicit and keeps artifact UI independently
/// testable.
abstract interface class ProjectArtifactsController implements Listenable {
  List<ProjectArtifactEntry> get artifacts;
  bool get artifactBusy;
  String get errorCode;

  Future<void> refreshArtifacts({
    String? query,
    Set<ProjectArtifactKind>? kinds,
  });

  Future<List<ProjectArtifactEntry>> importPickedArtifacts();

  Future<List<ProjectArtifactEntry>> importArtifactPaths(
    Iterable<String> sourcePaths,
  );

  Future<ProjectArtifactEntry?> createTextArtifact({
    required String relativePath,
    required String content,
  });

  Future<ProjectArtifactReadResult?> previewArtifact(
    ProjectArtifactEntry entry, {
    String versionId = '',
  });

  Future<List<ProjectArtifactVersion>> artifactVersions(
    ProjectArtifactEntry entry,
  );

  Future<List<ProjectArtifactMessageReference>> artifactMessageReferences(
    ProjectArtifactEntry entry, {
    String versionId = '',
  });

  Future<ProjectArtifactEntry?> writeTextArtifactVersion({
    required ProjectArtifactEntry entry,
    required String content,
  });

  Future<bool> moveArtifact(ProjectArtifactEntry entry, String relativePath);

  Future<bool> deleteArtifact(ProjectArtifactEntry entry);
}
