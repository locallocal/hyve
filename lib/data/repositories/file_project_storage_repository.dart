import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/project_artifact.dart';
import 'package:hyve/domain/repositories/project_storage_repository.dart';

final class FileProjectStorageRepository implements ProjectStorageRepository {
  FileProjectStorageRepository({
    required ProjectAgentStorageService storage,
    this.maxBlobBytes = 64 * 1024 * 1024,
    this.maxIndexedTextBytes = 256 * 1024,
  }) : _storage = storage;

  final ProjectAgentStorageService _storage;
  final int maxBlobBytes;
  final int maxIndexedTextBytes;

  @override
  Future<StoredProjectBlob> writeBytes({
    required String projectId,
    required String artifactId,
    required String versionId,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    if (bytes.length > maxBlobBytes) {
      throw const ProjectArtifactFailure('artifact_size_limit_exceeded');
    }
    return _commitBlob(
      projectId: projectId,
      artifactId: artifactId,
      versionId: versionId,
      mimeType: mimeType,
      write: (file) async {
        final handle = await file.open(mode: FileMode.writeOnly);
        try {
          await handle.writeFrom(bytes);
          await handle.flush();
        } finally {
          await handle.close();
        }
      },
    );
  }

  @override
  Future<StoredProjectBlob> importFile({
    required String projectId,
    required String artifactId,
    required String versionId,
    required String sourcePath,
    required String mimeType,
  }) async {
    final source = File(sourcePath);
    final type = await FileSystemEntity.type(source.path, followLinks: false);
    if (type == FileSystemEntityType.link) {
      throw const ProjectArtifactFailure('artifact_source_symlink_rejected');
    }
    if (type != FileSystemEntityType.file) {
      throw const ProjectArtifactFailure('artifact_source_missing');
    }
    final length = await source.length();
    if (length > maxBlobBytes) {
      throw const ProjectArtifactFailure('artifact_size_limit_exceeded');
    }
    return _commitBlob(
      projectId: projectId,
      artifactId: artifactId,
      versionId: versionId,
      mimeType: mimeType,
      write: (file) async {
        final input = await source.open();
        final output = await file.open(mode: FileMode.writeOnly);
        try {
          var written = 0;
          while (true) {
            final chunk = await input.read(64 * 1024);
            if (chunk.isEmpty) break;
            written += chunk.length;
            if (written > maxBlobBytes) {
              throw const ProjectArtifactFailure(
                'artifact_size_limit_exceeded',
              );
            }
            await output.writeFrom(chunk);
          }
          await output.flush();
        } finally {
          await input.close();
          await output.close();
        }
      },
    );
  }

  Future<StoredProjectBlob> _commitBlob({
    required String projectId,
    required String artifactId,
    required String versionId,
    required String mimeType,
    required Future<void> Function(File file) write,
  }) async {
    _validateIdentity(artifactId, 'artifactId');
    _validateIdentity(versionId, 'versionId');
    final root = await _storage.ensureProjectRoot(projectId);
    await _rejectRootLink(root);
    final staging = Directory(path.join(root.path, 'artifacts', 'staging'));
    final temporary = File(
      path.join(
        staging.path,
        '$artifactId-$versionId-${DateTime.now().microsecondsSinceEpoch}.tmp',
      ),
    );
    final versionDirectory = Directory(
      path.join(root.path, 'artifacts', 'blobs', artifactId, versionId),
    );
    final destination = File(path.join(versionDirectory.path, 'content'));
    if (await destination.exists()) {
      throw const ProjectArtifactFailure('artifact_blob_already_exists');
    }
    try {
      await write(temporary);
      final length = await temporary.length();
      if (length > maxBlobBytes) {
        throw const ProjectArtifactFailure('artifact_size_limit_exceeded');
      }
      final digest = await sha256.bind(temporary.openRead()).first;
      final extractedText = await _extractText(temporary, mimeType);
      await versionDirectory.create(recursive: true);
      await _rejectLinks(
        root,
        path.relative(versionDirectory.path, from: root.path),
      );
      await temporary.rename(destination.path);
      return StoredProjectBlob(
        relativePath: path.posix.join(
          'artifacts',
          'blobs',
          artifactId,
          versionId,
          'content',
        ),
        contentDigest: digest.toString(),
        byteLength: length,
        extractedText: extractedText,
      );
    } on ProjectArtifactFailure {
      await _cleanupFailedWrite(temporary, versionDirectory);
      rethrow;
    } on Object catch (error) {
      await _cleanupFailedWrite(temporary, versionDirectory);
      throw ProjectArtifactFailure('artifact_blob_write_failed', cause: error);
    }
  }

  @override
  Future<Uint8List> read({
    required String projectId,
    required String relativeBlobPath,
    required int offset,
    required int length,
  }) async {
    if (offset < 0 || length < 1 || length > 32768) {
      throw const ProjectArtifactFailure('artifact_read_range_invalid');
    }
    final normalized = _normalizeBlobPath(relativeBlobPath);
    final root = await _storage.projectRoot(projectId);
    await _rejectRootLink(root);
    final file = File(path.join(root.path, path.fromUri(normalized)));
    await _rejectLinks(root, normalized);
    if (!await file.exists()) {
      throw const ProjectArtifactFailure('artifact_blob_missing');
    }
    final total = await file.length();
    if (offset >= total) return Uint8List(0);
    final handle = await file.open();
    try {
      await handle.setPosition(offset);
      return Uint8List.fromList(await handle.read(length));
    } on Object catch (error) {
      throw ProjectArtifactFailure('artifact_blob_read_failed', cause: error);
    } finally {
      await handle.close();
    }
  }

  @override
  Future<String> materializeArtifact({
    required String projectId,
    required String artifactId,
    required String versionId,
    required String relativeBlobPath,
    required String fileName,
  }) async {
    _validateIdentity(artifactId, 'artifactId');
    _validateIdentity(versionId, 'versionId');
    final normalized = _normalizeBlobPath(relativeBlobPath);
    final safeName = path.basename(fileName.replaceAll('\\', '/')).trim();
    if (safeName.isEmpty || safeName == '.' || safeName == '..') {
      throw const ProjectArtifactFailure('artifact_file_name_invalid');
    }

    final root = await _storage.projectRoot(projectId);
    await _rejectRootLink(root);
    await _rejectLinks(root, normalized);
    final source = File(path.join(root.path, path.fromUri(normalized)));
    if (!await source.exists()) {
      throw const ProjectArtifactFailure('artifact_blob_missing');
    }

    final relativeDirectory = path.posix.join(
      path.posix.dirname(normalized),
      'open',
    );
    await _rejectLinks(root, relativeDirectory);
    final directory = Directory(
      path.join(root.path, path.fromUri(relativeDirectory)),
    );
    await directory.create(recursive: true);
    final destination = File(path.join(directory.path, safeName));
    await _rejectLinks(
      root,
      path.posix.join(relativeDirectory, safeName.replaceAll('\\', '/')),
    );
    final sourceModified = await source.lastModified();
    if (await destination.exists()) {
      final sameLength = await destination.length() == await source.length();
      final destinationModified = await destination.lastModified();
      if (sameLength && destinationModified.isAtSameMomentAs(sourceModified)) {
        return destination.path;
      }
    }
    final temporary = File(
      '${destination.path}.${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    try {
      await source.copy(temporary.path);
      if (await destination.exists()) await destination.delete();
      await temporary.rename(destination.path);
      await destination.setLastModified(sourceModified);
      return destination.path;
    } on Object catch (error) {
      if (await temporary.exists()) await temporary.delete();
      if (error is ProjectArtifactFailure) rethrow;
      throw ProjectArtifactFailure('artifact_materialize_failed', cause: error);
    }
  }

  @override
  Future<void> deleteBlob(String projectId, String relativeBlobPath) async {
    final normalized = _normalizeBlobPath(relativeBlobPath);
    final root = await _storage.projectRoot(projectId);
    await _rejectRootLink(root);
    final file = File(path.join(root.path, path.fromUri(normalized)));
    await _rejectLinks(root, normalized);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<StagedProjectArtifactDeletion?> stageArtifactDeletion(
    String projectId,
    String artifactId,
  ) async {
    _validateIdentity(artifactId, 'artifactId');
    final root = await _storage.projectRoot(projectId);
    await _rejectRootLink(root);
    final source = Directory(
      path.join(root.path, 'artifacts', 'blobs', artifactId),
    );
    final type = await FileSystemEntity.type(source.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return null;
    if (type == FileSystemEntityType.link) {
      throw const ProjectArtifactFailure('artifact_symlink_rejected');
    }
    if (type != FileSystemEntityType.directory) {
      throw const ProjectArtifactFailure('artifact_blob_layout_invalid');
    }
    final staged = Directory(
      path.join(
        root.path,
        'artifacts',
        'staging',
        'deletions',
        '$artifactId-${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await staged.parent.create(recursive: true);
    await source.rename(staged.path);
    return _FileArtifactDeletion(original: source, staged: staged);
  }

  Future<String> _extractText(File file, String mimeType) async {
    if (!_isTextMimeType(mimeType)) return '';
    final length = await file.length();
    final handle = await file.open();
    try {
      final bytes = await handle.read(
        length < maxIndexedTextBytes ? length : maxIndexedTextBytes,
      );
      return utf8.decode(bytes, allowMalformed: true).replaceAll('\u0000', '');
    } finally {
      await handle.close();
    }
  }

  Future<void> _rejectRootLink(Directory root) async {
    final type = await FileSystemEntity.type(root.path, followLinks: false);
    if (type == FileSystemEntityType.link) {
      throw const ProjectArtifactFailure('artifact_root_symlink_rejected');
    }
  }

  Future<void> _rejectLinks(Directory root, String relativePath) async {
    var current = root.path;
    for (final segment in path.posix.split(
      relativePath.replaceAll('\\', '/'),
    )) {
      current = path.join(current, segment);
      final type = await FileSystemEntity.type(current, followLinks: false);
      if (type == FileSystemEntityType.link) {
        throw const ProjectArtifactFailure('artifact_symlink_rejected');
      }
      if (type == FileSystemEntityType.notFound) return;
    }
  }

  static String _normalizeBlobPath(String input) {
    final replaced = input.replaceAll('\\', '/').trim();
    if (replaced.isEmpty ||
        path.posix.isAbsolute(replaced) ||
        replaced.split('/').contains('..')) {
      throw const ProjectArtifactFailure('artifact_blob_path_invalid');
    }
    final normalized = path.posix.normalize(replaced);
    if (!normalized.startsWith('artifacts/blobs/') ||
        normalized == 'artifacts/blobs') {
      throw const ProjectArtifactFailure('artifact_blob_path_invalid');
    }
    return normalized;
  }

  static void _validateIdentity(String value, String name) {
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.:-]{0,191}$').hasMatch(value)) {
      throw ProjectArtifactFailure('invalid_$name');
    }
  }

  static bool _isTextMimeType(String mimeType) {
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
        }.contains(normalized);
  }

  static Future<void> _cleanupFailedWrite(
    File temporary,
    Directory versionDirectory,
  ) async {
    try {
      if (await temporary.exists()) await temporary.delete();
      if (await versionDirectory.exists() &&
          await versionDirectory.list(followLinks: false).isEmpty) {
        await versionDirectory.delete();
      }
    } on FileSystemException {
      // Orphan staging and empty version directories are safe to recover later.
    }
  }
}

final class _FileArtifactDeletion implements StagedProjectArtifactDeletion {
  const _FileArtifactDeletion({required this.original, required this.staged});

  final Directory original;
  final Directory staged;

  @override
  Future<void> rollback() async {
    if (!await staged.exists()) return;
    if (await original.exists()) {
      throw const ProjectArtifactFailure(
        'artifact_delete_rollback_target_exists',
      );
    }
    await original.parent.create(recursive: true);
    await staged.rename(original.path);
  }

  @override
  Future<void> commit() async {
    if (await staged.exists()) await staged.delete(recursive: true);
    final parent = staged.parent;
    if (await parent.exists() &&
        await parent.list(followLinks: false).isEmpty) {
      await parent.delete();
    }
  }
}
