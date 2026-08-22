import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:hyve/data/models/agent_memory_records.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/agent_memory.dart';
import 'package:hyve/domain/repositories/agent_memory_repository.dart';
import 'package:hyve/domain/services/agent_memory_safety.dart';
import 'package:path/path.dart' as path;

typedef AgentMemoryClock = DateTime Function();

/// File-backed AgentMemory with immutable item versions and manifest CAS.
final class FileAgentMemoryRepository implements AgentMemoryRepository {
  FileAgentMemoryRepository({
    required ProjectAgentStorageService storage,
    AgentMemoryClock? clock,
    AgentMemorySafety safety = const AgentMemorySafety(),
  }) : _storage = storage,
       _clock = clock ?? DateTime.now,
       _safety = safety;

  final ProjectAgentStorageService _storage;
  final AgentMemoryClock _clock;
  final AgentMemorySafety _safety;
  final StreamController<String> _changes = StreamController.broadcast();

  @override
  Stream<String> get changes => _changes.stream;

  @override
  Future<int> getRevision(String agentId) async =>
      (await _readManifest(agentId)).revision;

  @override
  Future<List<AgentMemory>> list(
    String agentId, {
    bool includeHistory = false,
  }) async {
    final manifest = await _readManifest(agentId);
    final result = <AgentMemory>[];
    if (!includeHistory) {
      for (final head in manifest.heads.values) {
        result.add(await _readHead(agentId, head));
      }
    } else {
      final root = await _memoryRoot(agentId);
      final items = Directory(path.join(root.path, 'items'));
      if (await items.exists()) {
        await for (final entity in items.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File && path.extension(entity.path) == '.json') {
            final memory =
                AgentMemoryRecord.decode(
                  await entity.readAsString(),
                ).toDomain();
            if (memory.agentId != agentId) {
              throw const FormatException('Agent memory owner mismatch.');
            }
            result.add(memory);
          }
        }
      }
    }
    result.sort((left, right) {
      final updated = right.updatedAt.compareTo(left.updatedAt);
      return updated != 0 ? updated : left.memoryKey.compareTo(right.memoryKey);
    });
    return List<AgentMemory>.unmodifiable(result);
  }

  @override
  Future<AgentMemory?> read(String agentId, String memoryId) async {
    _validateSegment(memoryId, 'memoryId');
    final manifest = await _readManifest(agentId);
    for (final head in manifest.heads.values) {
      if (head.id == memoryId) return _readHead(agentId, head);
    }
    return null;
  }

  @override
  Future<AgentMemorySearchResult> search(
    AgentMemorySearchRequest request,
  ) async {
    final manifest = await _readManifest(request.agentId);
    final terms = _searchTerms(request.query);
    final ranked = <({AgentMemory memory, double score, int tokens})>[];
    for (final head in manifest.heads.values) {
      final memory = await _readHead(request.agentId, head);
      if (!_withinScope(memory, request) ||
          memory.confidence < request.minConfidence) {
        continue;
      }
      final normalized = memory.content.toLowerCase();
      final matches = terms.where(normalized.contains).length;
      final relevance =
          terms.isEmpty ? 0.25 : matches / math.max(1, terms.length);
      final ageDays = math.max(
        0,
        _clock().difference(memory.lastUsedAt ?? memory.updatedAt).inDays,
      );
      final recency = 1 / (1 + ageDays / 30);
      final tokens = math.max(1, (memory.content.runes.length / 4).ceil());
      ranked.add((
        memory: memory,
        score:
            relevance * 0.5 +
            memory.importance * 0.2 +
            memory.confidence * 0.2 +
            recency * 0.1,
        tokens: tokens,
      ));
    }
    ranked.sort((left, right) {
      final score = right.score.compareTo(left.score);
      return score != 0
          ? score
          : right.memory.updatedAt.compareTo(left.memory.updatedAt);
    });
    final selected = <AgentMemory>[];
    var used = 0;
    for (final candidate in ranked) {
      if (selected.length >= request.maxItems) break;
      if (used + candidate.tokens > request.tokenBudget) continue;
      selected.add(candidate.memory);
      used += candidate.tokens;
    }
    return AgentMemorySearchResult(
      items: selected,
      estimatedTokenCount: used,
      revision: manifest.revision,
    );
  }

  @override
  Future<AgentMemoryMutationResult> propose(
    AgentMemory candidate, {
    int? expectedRevision,
  }) async {
    if (_safety.isSecretLike(candidate.content)) {
      throw const AgentMemorySecretLikeException();
    }
    return _mutate(candidate.agentId, expectedRevision, (manifest) async {
      final currentHead = manifest.heads[candidate.memoryKey];
      final current =
          currentHead == null
              ? null
              : await _readHead(candidate.agentId, currentHead);
      if (current != null &&
          current.content.trim() == candidate.content.trim() &&
          current.sourceDigest == candidate.sourceDigest &&
          current.state == candidate.state &&
          current.reuseScope == candidate.reuseScope) {
        return _PendingMemoryMutation.unchanged(current);
      }
      final now = _clock();
      final id = _uniqueVersionId(
        candidate.id,
        previous: current,
        version: (current?.version ?? 0) + 1,
      );
      final next = AgentMemory(
        id: id,
        agentId: candidate.agentId,
        memoryKey: candidate.memoryKey,
        kind: candidate.kind,
        content: candidate.content.trim(),
        state: candidate.state,
        reuseScope: candidate.reuseScope,
        sensitivity: candidate.sensitivity,
        importance: candidate.importance,
        confidence: candidate.confidence,
        sourceProjectId: candidate.sourceProjectId,
        sourceEventIds: candidate.sourceEventIds,
        sourceMessageSequence: candidate.sourceMessageSequence,
        sourceDigest: candidate.sourceDigest,
        version: (current?.version ?? 0) + 1,
        supersedesId: current?.id ?? candidate.supersedesId,
        createdAt: now,
        updatedAt: now,
      );
      return _PendingMemoryMutation.changed(next);
    });
  }

  @override
  Future<AgentMemoryMutationResult> correct({
    required String agentId,
    required String memoryId,
    required String content,
    required AgentMemoryReuseScope reuseScope,
    int? expectedRevision,
  }) async {
    if (_safety.isSecretLike(content)) {
      throw const AgentMemorySecretLikeException();
    }
    return _mutate(agentId, expectedRevision, (manifest) async {
      final current = await _findCurrent(manifest, agentId, memoryId);
      if (current == null) {
        throw StateError('Agent memory does not exist or is not current.');
      }
      final now = _clock();
      return _PendingMemoryMutation.changed(
        AgentMemory(
          id: _uniqueVersionId(
            current.id,
            previous: current,
            version: current.version + 1,
          ),
          agentId: agentId,
          memoryKey: current.memoryKey,
          kind: current.kind,
          content: content.trim(),
          state: AgentMemoryState.active,
          reuseScope: reuseScope,
          sensitivity: current.sensitivity,
          importance: current.importance,
          confidence: 1,
          sourceProjectId: current.sourceProjectId,
          sourceEventIds: current.sourceEventIds,
          sourceMessageSequence: current.sourceMessageSequence,
          sourceDigest: current.sourceDigest,
          version: current.version + 1,
          supersedesId: current.id,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });
  }

  @override
  Future<AgentMemoryMutationResult> forget({
    required String agentId,
    required String memoryId,
    int? expectedRevision,
  }) {
    return _mutate(agentId, expectedRevision, (manifest) async {
      final current = await _findCurrent(manifest, agentId, memoryId);
      if (current == null) {
        throw StateError('Agent memory does not exist or is not current.');
      }
      if (current.state == AgentMemoryState.forgotten) {
        return _PendingMemoryMutation.unchanged(current);
      }
      final now = _clock();
      return _PendingMemoryMutation.changed(
        AgentMemory(
          id: _uniqueVersionId(
            current.id,
            previous: current,
            version: current.version + 1,
          ),
          agentId: current.agentId,
          memoryKey: current.memoryKey,
          kind: current.kind,
          content: current.content,
          state: AgentMemoryState.forgotten,
          reuseScope: current.reuseScope,
          sensitivity: current.sensitivity,
          importance: current.importance,
          confidence: current.confidence,
          sourceProjectId: current.sourceProjectId,
          sourceEventIds: current.sourceEventIds,
          sourceMessageSequence: current.sourceMessageSequence,
          sourceDigest: current.sourceDigest,
          version: current.version + 1,
          supersedesId: current.id,
          createdAt: now,
          updatedAt: now,
          lastUsedAt: current.lastUsedAt,
        ),
      );
    });
  }

  Future<AgentMemoryMutationResult> _mutate(
    String agentId,
    int? expectedRevision,
    Future<_PendingMemoryMutation> Function(AgentMemoryManifestRecord manifest)
    build,
  ) async {
    _validateSegment(agentId, 'agentId');
    final root = await _memoryRoot(agentId);
    final lockFile = File(path.join(root.path, 'manifest.lock'));
    await lockFile.create(recursive: true);
    final lock = await lockFile.open(mode: FileMode.append);
    await lock.lock(FileLock.exclusive);
    try {
      final manifest = await _readManifest(agentId);
      if (expectedRevision != null && manifest.revision != expectedRevision) {
        throw const AgentMemoryRevisionConflict();
      }
      final pending = await build(manifest);
      if (!pending.changed) {
        return AgentMemoryMutationResult(
          memory: pending.memory,
          revision: manifest.revision,
          changed: false,
        );
      }
      final memory = pending.memory;
      if (memory.agentId != agentId) {
        throw ArgumentError('Agent memory owner does not match the manifest.');
      }
      _validateSegment(memory.id, 'memoryId');
      final stored = await _writeImmutableVersion(root, memory);
      final heads = Map<String, AgentMemoryManifestHead>.from(manifest.heads)
        ..[memory.memoryKey] = stored;
      final next = AgentMemoryManifestRecord(
        agentId: agentId,
        revision: manifest.revision + 1,
        heads: heads,
      );
      await _writeManifest(root, next);
      if (!_changes.isClosed) _changes.add(agentId);
      return AgentMemoryMutationResult(memory: memory, revision: next.revision);
    } finally {
      await lock.unlock();
      await lock.close();
    }
  }

  Future<AgentMemory?> _findCurrent(
    AgentMemoryManifestRecord manifest,
    String agentId,
    String memoryId,
  ) async {
    for (final head in manifest.heads.values) {
      if (head.id == memoryId) return _readHead(agentId, head);
    }
    return null;
  }

  Future<AgentMemoryManifestHead> _writeImmutableVersion(
    Directory root,
    AgentMemory memory,
  ) async {
    final record = AgentMemoryRecord.fromDomain(memory).encode();
    final bytes = utf8.encode(record);
    final digest = sha256.convert(bytes).toString();
    final relative = path.join('items', memory.id, '${memory.version}.json');
    final destination = File(path.join(root.path, relative));
    if (await destination.exists()) {
      throw StateError('Agent memory version already exists and is immutable.');
    }
    await destination.parent.create(recursive: true);
    final staging = File(
      path.join(
        root.path,
        'staging',
        '${memory.id}-${memory.version}-${_clock().microsecondsSinceEpoch}.tmp',
      ),
    );
    await staging.parent.create(recursive: true);
    try {
      final sink = staging.openWrite();
      sink.add(bytes);
      await sink.flush();
      await sink.close();
      await staging.rename(destination.path);
    } on Object {
      if (await staging.exists()) await staging.delete();
      rethrow;
    }
    return AgentMemoryManifestHead(
      id: memory.id,
      version: memory.version,
      relativePath: relative.replaceAll('\\', '/'),
      contentDigest: digest,
    );
  }

  Future<AgentMemory> _readHead(
    String agentId,
    AgentMemoryManifestHead head,
  ) async {
    _validateHeadPath(head);
    final root = await _memoryRoot(agentId);
    final file = File(path.join(root.path, head.relativePath));
    if (!await file.exists()) {
      throw const FormatException('Agent memory version file is missing.');
    }
    final bytes = await file.readAsBytes();
    if (sha256.convert(bytes).toString() != head.contentDigest) {
      throw const FormatException('Agent memory digest does not match.');
    }
    final memory = AgentMemoryRecord.decode(utf8.decode(bytes)).toDomain();
    if (memory.agentId != agentId ||
        memory.id != head.id ||
        memory.version != head.version) {
      throw const FormatException(
        'Agent memory manifest head is inconsistent.',
      );
    }
    return memory;
  }

  Future<AgentMemoryManifestRecord> _readManifest(String agentId) async {
    final root = await _memoryRoot(agentId);
    final file = File(path.join(root.path, 'manifest.json'));
    if (!await file.exists()) {
      final empty = AgentMemoryManifestRecord(
        agentId: agentId,
        revision: 0,
        heads: const <String, AgentMemoryManifestHead>{},
      );
      await _writeManifest(root, empty);
      return empty;
    }
    final manifest = AgentMemoryManifestRecord.decode(
      await file.readAsString(),
    );
    if (manifest.agentId != agentId || manifest.revision < 0) {
      throw const FormatException('Agent memory manifest owner is invalid.');
    }
    return manifest;
  }

  Future<void> _writeManifest(
    Directory root,
    AgentMemoryManifestRecord manifest,
  ) async {
    final destination = File(path.join(root.path, 'manifest.json'));
    final temporary = File(
      path.join(
        root.path,
        'staging',
        'manifest-${_clock().microsecondsSinceEpoch}.tmp',
      ),
    );
    await temporary.parent.create(recursive: true);
    final sink = temporary.openWrite();
    sink.write(manifest.encode());
    await sink.flush();
    await sink.close();
    if (await destination.exists()) {
      final backup = File('${destination.path}.previous');
      if (await backup.exists()) await backup.delete();
      await destination.rename(backup.path);
      try {
        await temporary.rename(destination.path);
        await backup.delete();
      } on Object {
        if (!await destination.exists() && await backup.exists()) {
          await backup.rename(destination.path);
        }
        rethrow;
      }
    } else {
      await temporary.rename(destination.path);
    }
  }

  Future<Directory> _memoryRoot(String agentId) async {
    _validateSegment(agentId, 'agentId');
    final agentRoot = await _storage.ensureAgentRoot(agentId);
    return Directory(path.join(agentRoot.path, 'memory'));
  }

  bool _withinScope(AgentMemory memory, AgentMemorySearchRequest request) {
    if (!memory.isRecallable) return false;
    if (memory.sourceProjectId == request.currentProjectId &&
        memory.sourceMessageSequence != null &&
        memory.sourceMessageSequence! > request.contextThroughMessageSequence) {
      return false;
    }
    return switch (memory.reuseScope) {
      AgentMemoryReuseScope.crossProject => true,
      AgentMemoryReuseScope.userApproved => true,
      AgentMemoryReuseScope.sourceProjectOnly =>
        memory.sourceProjectId == request.currentProjectId &&
            (request.sourceProjectExists?.call(memory.sourceProjectId) ?? true),
    };
  }

  void _validateHeadPath(AgentMemoryManifestHead head) {
    final normalized = path.posix.normalize(head.relativePath);
    final expected = 'items/${head.id}/${head.version}.json';
    if (normalized != expected || path.posix.isAbsolute(normalized)) {
      throw const FormatException('Agent memory path escapes its root.');
    }
  }

  String _uniqueVersionId(
    String requested, {
    required AgentMemory? previous,
    required int version,
  }) {
    var base = requested.trim();
    if (base.isEmpty) base = 'memory_${_clock().microsecondsSinceEpoch}';
    base = base.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    if (previous == null || base != previous.id) return base;
    return '${base}_v$version';
  }

  static List<String> _searchTerms(String query) {
    final normalized = query.toLowerCase().trim();
    if (normalized.isEmpty) return const <String>[];
    final terms =
        normalized
            .split(RegExp(r'[^\p{L}\p{N}_]+', unicode: true))
            .where((term) => term.isNotEmpty)
            .toSet();
    if (terms.isEmpty) terms.add(normalized);
    return terms.toList(growable: false);
  }

  static void _validateSegment(String value, String name) {
    if (value.isEmpty ||
        value == '.' ||
        value == '..' ||
        path.basename(value) != value ||
        value.contains('/') ||
        value.contains('\\')) {
      throw ArgumentError.value(value, name, 'Must be a safe path segment.');
    }
  }

  Future<void> dispose() => _changes.close();
}

final class _PendingMemoryMutation {
  const _PendingMemoryMutation(this.memory, this.changed);

  factory _PendingMemoryMutation.changed(AgentMemory memory) =>
      _PendingMemoryMutation(memory, true);

  factory _PendingMemoryMutation.unchanged(AgentMemory memory) =>
      _PendingMemoryMutation(memory, false);

  final AgentMemory memory;
  final bool changed;
}
