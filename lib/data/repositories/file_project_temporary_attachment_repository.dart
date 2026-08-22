import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/repositories/project_temporary_attachment_repository.dart';
import 'package:path/path.dart' as path;

final class FileProjectTemporaryAttachmentRepository
    implements ProjectTemporaryAttachmentRepository {
  FileProjectTemporaryAttachmentRepository({
    required ProjectAgentStorageService storage,
    this.maxAttachmentBytes = 100 * 1024 * 1024,
  }) : _storage = storage;

  final ProjectAgentStorageService _storage;
  final int maxAttachmentBytes;

  @override
  Future<List<String>> persist({
    required String projectId,
    required Iterable<String> sourcePaths,
  }) async {
    final sources = sourcePaths.toList(growable: false);
    if (sources.isEmpty) return const <String>[];
    final projectRoot = await _storage.ensureProjectRoot(projectId);
    final root = Directory(
      path.join(projectRoot.path, 'tmp', 'message_attachments'),
    );
    final staging = Directory(path.join(projectRoot.path, 'tmp', 'staging'));
    await root.create(recursive: true);
    await staging.create(recursive: true);
    final pending = <({File temporary, File destination})>[];
    final result = <String>[];
    try {
      for (var index = 0; index < sources.length; index++) {
        final sourcePath = sources[index];
        if (await FileSystemEntity.type(sourcePath, followLinks: false) !=
            FileSystemEntityType.file) {
          throw const FileSystemException(
            'Project attachment source must be a regular file.',
          );
        }
        final source = File(sourcePath);
        final length = await source.length();
        if (length > maxAttachmentBytes) {
          throw const FileSystemException(
            'Project attachment exceeds the size limit.',
          );
        }
        final digest = await sha256.bind(source.openRead()).first;
        final extension = path.extension(source.path).toLowerCase();
        final destination = File(
          path.join(root.path, '${digest.toString()}$extension'),
        );
        result.add(destination.path);
        if (await destination.exists() ||
            pending.any((item) => item.destination.path == destination.path)) {
          continue;
        }
        final temporary = File(
          path.join(
            staging.path,
            'attachment_${digest}_${index}_'
            '${DateTime.now().microsecondsSinceEpoch}.tmp',
          ),
        );
        await source.copy(temporary.path);
        pending.add((temporary: temporary, destination: destination));
      }
      for (final item in pending) {
        await item.temporary.rename(item.destination.path);
      }
      return List<String>.unmodifiable(result);
    } on Object {
      for (final item in pending) {
        if (await item.temporary.exists()) await item.temporary.delete();
      }
      rethrow;
    }
  }

  @override
  Future<void> clear(String projectId) =>
      _storage.clearProjectTemporaryAttachments(projectId);
}
