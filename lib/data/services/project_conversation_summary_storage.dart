import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/conversation_summary.dart';
import 'package:path/path.dart' as path;

final class StoredProjectConversationSummary {
  const StoredProjectConversationSummary({
    required this.fileName,
    required this.contentDigest,
    required this.contentBytes,
  });

  final String fileName;
  final String contentDigest;
  final int contentBytes;
}

final class ProjectConversationSummaryStorage {
  const ProjectConversationSummaryStorage({
    required ProjectAgentStorageService storage,
  }) : _storage = storage;

  final ProjectAgentStorageService _storage;

  Future<StoredProjectConversationSummary> write({
    required String projectId,
    required String segmentId,
    required String markdown,
  }) async {
    _validateSegment(segmentId, 'segmentId');
    final normalized = markdown.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final bytes = utf8.encode(normalized);
    final directory = await _directory(projectId);
    await directory.create(recursive: true);
    final fileName = '$segmentId.md';
    final destination = File(path.join(directory.path, fileName));
    if (await destination.exists()) {
      throw StateError('Conversation summary segments are immutable.');
    }
    final temporary = File(
      path.join(
        directory.path,
        '.$segmentId-${DateTime.now().microsecondsSinceEpoch}.tmp',
      ),
    );
    try {
      final sink = temporary.openWrite();
      sink.add(bytes);
      await sink.flush();
      await sink.close();
      await temporary.rename(destination.path);
    } on Object {
      if (await temporary.exists()) await temporary.delete();
      rethrow;
    }
    return StoredProjectConversationSummary(
      fileName: fileName,
      contentDigest: sha256.convert(bytes).toString(),
      contentBytes: bytes.length,
    );
  }

  Future<String> read(ConversationSummarySegment segment) async {
    _validateSegment(segment.id, 'segmentId');
    if (segment.fileName != '${segment.id}.md') {
      throw const FormatException('Conversation summary file name is invalid.');
    }
    final directory = await _directory(segment.projectId);
    final file = File(path.join(directory.path, segment.fileName));
    if (!await file.exists()) {
      throw const FormatException('Conversation summary body is missing.');
    }
    final bytes = await file.readAsBytes();
    if (bytes.length != segment.contentBytes ||
        sha256.convert(bytes).toString() != segment.contentDigest) {
      throw const FormatException(
        'Conversation summary integrity check failed.',
      );
    }
    return utf8.decode(bytes);
  }

  Future<void> delete(String projectId, String segmentId) async {
    _validateSegment(segmentId, 'segmentId');
    final file = File(
      path.join((await _directory(projectId)).path, '$segmentId.md'),
    );
    if (await file.exists()) await file.delete();
  }

  Future<void> clear(String projectId) async {
    final directory = await _directory(projectId);
    if (await directory.exists()) await directory.delete(recursive: true);
    await directory.create(recursive: true);
  }

  Future<Directory> _directory(String projectId) async {
    final root = await _storage.ensureProjectRoot(projectId);
    return Directory(path.join(root.path, 'context', 'summaries'));
  }

  static void _validateSegment(String value, String field) {
    if (value.isEmpty ||
        value == '.' ||
        value == '..' ||
        path.basename(value) != value ||
        value.contains('/') ||
        value.contains('\\')) {
      throw ArgumentError.value(value, field, 'Must be a safe path segment.');
    }
  }
}
