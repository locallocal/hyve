import 'dart:typed_data';

final class StoredProjectBlob {
  const StoredProjectBlob({
    required this.relativePath,
    required this.contentDigest,
    required this.byteLength,
    required this.extractedText,
  });

  final String relativePath;
  final String contentDigest;
  final int byteLength;
  final String extractedText;
}

abstract interface class StagedProjectArtifactDeletion {
  Future<void> rollback();

  Future<void> commit();
}

abstract interface class ProjectStorageRepository {
  Future<StoredProjectBlob> writeBytes({
    required String projectId,
    required String artifactId,
    required String versionId,
    required Uint8List bytes,
    required String mimeType,
  });

  Future<StoredProjectBlob> importFile({
    required String projectId,
    required String artifactId,
    required String versionId,
    required String sourcePath,
    required String mimeType,
  });

  Future<Uint8List> read({
    required String projectId,
    required String relativeBlobPath,
    required int offset,
    required int length,
  });

  Future<void> deleteBlob(String projectId, String relativeBlobPath);

  Future<StagedProjectArtifactDeletion?> stageArtifactDeletion(
    String projectId,
    String artifactId,
  );
}
