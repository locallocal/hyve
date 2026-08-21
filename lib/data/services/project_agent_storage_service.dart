import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

typedef ProjectAgentSupportDirectoryProvider = Future<Directory> Function();

/// Owns the filesystem roots whose contents must never be stored in SQLite.
///
/// Project artifacts and summaries live below `projects/<projectId>`. Agent
/// memory items, indexes, and state live below `agents/<agentId>`. Deletions
/// are staged so a repository can roll the directory back when its database
/// transaction fails.
final class ProjectAgentStorageService {
  ProjectAgentStorageService({
    ProjectAgentSupportDirectoryProvider? supportDirectoryProvider,
  }) : _supportDirectoryProvider =
           supportDirectoryProvider ?? getApplicationSupportDirectory;

  final ProjectAgentSupportDirectoryProvider _supportDirectoryProvider;

  Future<Directory> ensureProjectRoot(String projectId) async {
    final root = await projectRoot(projectId);
    for (final relativePath in const <String>[
      'artifacts/blobs',
      'artifacts/index',
      'artifacts/staging',
      'context/summaries',
      'audit',
      'tmp',
    ]) {
      await Directory(join(root.path, relativePath)).create(recursive: true);
    }
    return root;
  }

  Future<Directory> ensureAgentRoot(String agentId) async {
    final root = await agentRoot(agentId);
    for (final relativePath in const <String>[
      'memory/items',
      'memory/blobs',
      'memory/index',
      'memory/staging',
      'memory/state',
    ]) {
      await Directory(join(root.path, relativePath)).create(recursive: true);
    }
    return root;
  }

  Future<Directory> projectRoot(String projectId) async {
    _validateId(projectId, 'projectId');
    return Directory(
      join((await _supportDirectoryProvider()).path, 'projects', projectId),
    );
  }

  Future<Directory> agentRoot(String agentId) async {
    _validateId(agentId, 'agentId');
    return Directory(
      join((await _supportDirectoryProvider()).path, 'agents', agentId),
    );
  }

  Future<StagedEntityDeletion?> stageProjectDeletion(String projectId) {
    return _stage(kind: 'project', id: projectId, root: projectRoot(projectId));
  }

  Future<StagedEntityDeletion?> stageAgentDeletion(String agentId) {
    return _stage(kind: 'agent', id: agentId, root: agentRoot(agentId));
  }

  /// Finishes or rolls back project deletions interrupted by a process crash.
  ///
  /// A staged directory with a live database record is restored. When the
  /// record is gone, the database transaction committed and the staged files
  /// can be removed.
  Future<void> recoverPendingProjectDeletions(
    Set<String> activeProjectIds,
  ) async {
    final support = await _supportDirectoryProvider();
    final pending = Directory(join(support.path, '.pending_deletions'));
    if (!await pending.exists()) return;
    await for (final entity in pending.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final name = basename(entity.path);
      final match = RegExp(r'^project-(.+)-(\d+)$').firstMatch(name);
      if (match == null) continue;
      final projectId = match.group(1)!;
      if (!activeProjectIds.contains(projectId)) {
        await entity.delete(recursive: true);
        continue;
      }
      final original = await projectRoot(projectId);
      if (await original.exists()) {
        // A canonical directory already exists, so this is an obsolete staged
        // copy from an older interrupted cleanup.
        await entity.delete(recursive: true);
        continue;
      }
      await original.parent.create(recursive: true);
      await entity.rename(original.path);
    }
    await StagedEntityDeletion._deletePendingParentIfEmpty(pending);
  }

  Future<void> deleteProjectRoot(String projectId) async {
    final root = await projectRoot(projectId);
    if (await root.exists()) await root.delete(recursive: true);
  }

  Future<void> deleteAgentRoot(String agentId) async {
    final root = await agentRoot(agentId);
    if (await root.exists()) await root.delete(recursive: true);
  }

  Future<StagedEntityDeletion?> _stage({
    required String kind,
    required String id,
    required Future<Directory> root,
  }) async {
    final original = await root;
    if (!await original.exists()) return null;
    final support = await _supportDirectoryProvider();
    final pending = Directory(join(support.path, '.pending_deletions'));
    await pending.create(recursive: true);
    final staged = Directory(
      join(pending.path, '$kind-$id-${DateTime.now().microsecondsSinceEpoch}'),
    );
    await original.rename(staged.path);
    return StagedEntityDeletion(original: original, staged: staged);
  }

  static void _validateId(String id, String name) {
    if (id.isEmpty ||
        id == '.' ||
        id == '..' ||
        basename(id) != id ||
        id.contains('/') ||
        id.contains('\\')) {
      throw ArgumentError.value(id, name, 'Must be a safe path segment.');
    }
  }
}

final class StagedEntityDeletion {
  const StagedEntityDeletion({required this.original, required this.staged});

  final Directory original;
  final Directory staged;

  Future<void> rollback() async {
    if (!await staged.exists()) return;
    if (await original.exists()) {
      throw FileSystemException(
        'Cannot restore a staged deletion over an existing directory.',
        original.path,
      );
    }
    await original.parent.create(recursive: true);
    await staged.rename(original.path);
    await _deletePendingParentIfEmpty(staged.parent);
  }

  Future<void> commit() async {
    if (await staged.exists()) await staged.delete(recursive: true);
    await _deletePendingParentIfEmpty(staged.parent);
  }

  static Future<void> _deletePendingParentIfEmpty(Directory directory) async {
    if (!await directory.exists()) return;
    if (!await directory.list(followLinks: false).isEmpty) return;
    await directory.delete();
  }
}
