import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:hyve/data/models/agent_memory_records.dart';
import 'package:hyve/domain/models/agent_memory.dart';
import 'package:hyve/domain/repositories/agent_memory_repository.dart';
import 'package:hyve/domain/services/agent_memory_safety.dart';

typedef ExternalMemoryAuthorizationProvider =
    Future<String?> Function(Uri endpoint);

final class ExternalVectorMemoryState {
  ExternalVectorMemoryState({
    required this.revision,
    required Iterable<AgentMemory> items,
  }) : items = List<AgentMemory>.unmodifiable(items);

  final int revision;
  final List<AgentMemory> items;
}

abstract interface class ExternalVectorMemoryStore {
  Stream<String> get changes;

  Future<ExternalVectorMemoryState> load(
    String agentId, {
    bool includeHistory = false,
  });

  Future<ExternalVectorMemoryState> search(AgentMemorySearchRequest request);

  /// Atomically replaces the logical key head and returns the new revision.
  Future<int> compareAndSwap({
    required String agentId,
    required int expectedRevision,
    required String previousMemoryId,
    required AgentMemory memory,
  });
}

/// AgentMemory adapter for a remote vector store with revision-based CAS.
final class ExternalVectorAgentMemoryRepository
    implements AgentMemoryRepository {
  ExternalVectorAgentMemoryRepository({
    required ExternalVectorMemoryStore store,
    ExternalAgentMemoryClock? clock,
    AgentMemorySafety safety = const AgentMemorySafety(),
  }) : _store = store,
       _clock = clock ?? DateTime.now,
       _safety = safety;

  final ExternalVectorMemoryStore _store;
  final ExternalAgentMemoryClock _clock;
  final AgentMemorySafety _safety;

  @override
  Stream<String> get changes => _store.changes;

  @override
  Future<int> getRevision(String agentId) async =>
      (await _store.load(agentId)).revision;

  @override
  Future<List<AgentMemory>> list(
    String agentId, {
    bool includeHistory = false,
  }) async {
    final state = await _store.load(agentId, includeHistory: includeHistory);
    _validateOwners(agentId, state.items);
    final result = state.items.toList(growable: false)..sort((left, right) {
      final updated = right.updatedAt.compareTo(left.updatedAt);
      return updated != 0 ? updated : left.memoryKey.compareTo(right.memoryKey);
    });
    return List<AgentMemory>.unmodifiable(result);
  }

  @override
  Future<AgentMemory?> read(String agentId, String memoryId) async {
    final state = await _store.load(agentId);
    _validateOwners(agentId, state.items);
    for (final memory in state.items) {
      if (memory.id == memoryId) return memory;
    }
    return null;
  }

  @override
  Future<AgentMemorySearchResult> search(
    AgentMemorySearchRequest request,
  ) async {
    final state = await _store.search(request);
    _validateOwners(request.agentId, state.items);
    final selected = <AgentMemory>[];
    var used = 0;
    for (final memory in state.items) {
      if (!_withinScope(memory, request) ||
          memory.confidence < request.minConfidence) {
        continue;
      }
      final tokens = math.max(1, (memory.content.runes.length / 4).ceil());
      if (used + tokens > request.tokenBudget) continue;
      selected.add(memory);
      used += tokens;
      if (selected.length >= request.maxItems) break;
    }
    return AgentMemorySearchResult(
      items: selected,
      estimatedTokenCount: used,
      revision: state.revision,
    );
  }

  @override
  Future<AgentMemoryMutationResult> propose(
    AgentMemory candidate, {
    int? expectedRevision,
  }) async {
    _rejectSecret(candidate.content);
    return _mutate(candidate.agentId, expectedRevision, (state) {
      final current = _headForKey(state.items, candidate.memoryKey);
      if (current != null &&
          current.content.trim() == candidate.content.trim() &&
          current.sourceDigest == candidate.sourceDigest &&
          current.state == candidate.state &&
          current.reuseScope == candidate.reuseScope) {
        return _ExternalPendingMutation.unchanged(current);
      }
      final now = _clock();
      final version = (current?.version ?? 0) + 1;
      return _ExternalPendingMutation.changed(
        AgentMemory(
          id: _uniqueVersionId(candidate.id, current, version),
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
          version: version,
          supersedesId: current?.id ?? candidate.supersedesId,
          createdAt: now,
          updatedAt: now,
        ),
        previousMemoryId: current?.id ?? '',
      );
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
    _rejectSecret(content);
    return _mutate(agentId, expectedRevision, (state) {
      final current = _currentById(state.items, memoryId);
      if (current == null) {
        throw StateError('Agent memory does not exist or is not current.');
      }
      final now = _clock();
      return _ExternalPendingMutation.changed(
        current.copyWith(
          id: _uniqueVersionId(current.id, current, current.version + 1),
          content: content.trim(),
          state: AgentMemoryState.active,
          reuseScope: reuseScope,
          confidence: 1,
          version: current.version + 1,
          supersedesId: current.id,
          updatedAt: now,
        ),
        previousMemoryId: current.id,
      );
    });
  }

  @override
  Future<AgentMemoryMutationResult> forget({
    required String agentId,
    required String memoryId,
    int? expectedRevision,
  }) => _mutate(agentId, expectedRevision, (state) {
    final current = _currentById(state.items, memoryId);
    if (current == null) {
      throw StateError('Agent memory does not exist or is not current.');
    }
    if (current.state == AgentMemoryState.forgotten) {
      return _ExternalPendingMutation.unchanged(current);
    }
    return _ExternalPendingMutation.changed(
      current.copyWith(
        id: _uniqueVersionId(current.id, current, current.version + 1),
        state: AgentMemoryState.forgotten,
        version: current.version + 1,
        supersedesId: current.id,
        updatedAt: _clock(),
      ),
      previousMemoryId: current.id,
    );
  });

  Future<AgentMemoryMutationResult> _mutate(
    String agentId,
    int? expectedRevision,
    _ExternalPendingMutation Function(ExternalVectorMemoryState state) build,
  ) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      final state = await _store.load(agentId);
      _validateOwners(agentId, state.items);
      if (expectedRevision != null && state.revision != expectedRevision) {
        throw const AgentMemoryRevisionConflict();
      }
      final pending = build(state);
      if (!pending.changed) {
        return AgentMemoryMutationResult(
          memory: pending.memory,
          revision: state.revision,
          changed: false,
        );
      }
      try {
        final revision = await _store.compareAndSwap(
          agentId: agentId,
          expectedRevision: state.revision,
          previousMemoryId: pending.previousMemoryId,
          memory: pending.memory,
        );
        return AgentMemoryMutationResult(
          memory: pending.memory,
          revision: revision,
        );
      } on AgentMemoryRevisionConflict {
        if (expectedRevision != null || attempt == 2) rethrow;
      }
    }
    throw const AgentMemoryRevisionConflict();
  }

  void _rejectSecret(String content) {
    if (_safety.isSecretLike(content)) {
      throw const AgentMemorySecretLikeException();
    }
  }
}

/// Vendor-neutral HTTP transport for the Hyve external-vector protocol.
final class HttpExternalVectorMemoryStore implements ExternalVectorMemoryStore {
  HttpExternalVectorMemoryStore({
    required Uri endpoint,
    required http.Client client,
    ExternalMemoryAuthorizationProvider? authorizationProvider,
  }) : _endpoint = _validateEndpoint(endpoint),
       _client = client,
       _authorizationProvider = authorizationProvider;

  final Uri _endpoint;
  final http.Client _client;
  final ExternalMemoryAuthorizationProvider? _authorizationProvider;
  final StreamController<String> _changes = StreamController.broadcast();

  @override
  Stream<String> get changes => _changes.stream;

  @override
  Future<ExternalVectorMemoryState> load(
    String agentId, {
    bool includeHistory = false,
  }) async {
    final response = await _client.get(
      _uri(
        agentId,
        query: <String, String>{'includeHistory': includeHistory.toString()},
      ),
      headers: await _headers(),
    );
    if (response.statusCode == 404) {
      return ExternalVectorMemoryState(revision: 0, items: const []);
    }
    return _decodeState(response);
  }

  @override
  Future<ExternalVectorMemoryState> search(
    AgentMemorySearchRequest request,
  ) async {
    final response = await _client.post(
      _uri(request.agentId, operation: 'search'),
      headers: await _headers(json: true),
      body: jsonEncode(<String, Object?>{
        'query': request.query,
        'currentProjectId': request.currentProjectId,
        'contextThroughMessageSequence': request.contextThroughMessageSequence,
        'maxItems': request.maxItems,
        'tokenBudget': request.tokenBudget,
        'minConfidence': request.minConfidence,
      }),
    );
    return _decodeState(response);
  }

  @override
  Future<int> compareAndSwap({
    required String agentId,
    required int expectedRevision,
    required String previousMemoryId,
    required AgentMemory memory,
  }) async {
    final response = await _client.put(
      _uri(agentId, operation: 'head'),
      headers: <String, String>{
        ...await _headers(json: true),
        'if-match': '$expectedRevision',
      },
      body: jsonEncode(<String, Object?>{
        'previousMemoryId': previousMemoryId,
        'memory': AgentMemoryRecord.fromDomain(memory).values,
      }),
    );
    if (response.statusCode == 409 || response.statusCode == 412) {
      throw const AgentMemoryRevisionConflict();
    }
    final body = _decodeObject(response);
    final revision = body['revision'];
    if (revision is! int || revision != expectedRevision + 1) {
      throw const FormatException(
        'External Agent memory revision response is invalid.',
      );
    }
    if (!_changes.isClosed) _changes.add(agentId);
    return revision;
  }

  Future<Map<String, String>> _headers({bool json = false}) async {
    final authorization = await _authorizationProvider?.call(_endpoint);
    return <String, String>{
      'accept': 'application/json',
      if (json) 'content-type': 'application/json',
      if (authorization != null && authorization.isNotEmpty)
        'authorization': authorization,
    };
  }

  Uri _uri(
    String agentId, {
    String operation = '',
    Map<String, String>? query,
  }) => _endpoint.replace(
    pathSegments: <String>[
      ..._endpoint.pathSegments.where((segment) => segment.isNotEmpty),
      'v1',
      'agents',
      agentId,
      'memory',
      if (operation.isNotEmpty) operation,
    ],
    queryParameters: query,
  );

  ExternalVectorMemoryState _decodeState(http.Response response) {
    final body = _decodeObject(response);
    final revision = body['revision'];
    final rawItems = body['items'];
    if (revision is! int || rawItems is! List<Object?>) {
      throw const FormatException('External Agent memory response is invalid.');
    }
    return ExternalVectorMemoryState(
      revision: revision,
      items: <AgentMemory>[
        for (final item in rawItems)
          if (item is Map<String, Object?>)
            AgentMemoryRecord(item).toDomain()
          else
            throw const FormatException(
              'External Agent memory item is invalid.',
            ),
      ],
    );
  }

  Map<String, Object?> _decodeObject(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ExternalVectorMemoryException(response.statusCode);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException(
        'External Agent memory response must be an object.',
      );
    }
    return decoded;
  }

  Future<void> dispose() => _changes.close();
}

/// Resolves backend references to cached HTTP repositories.
final class HttpExternalAgentMemoryRepositoryProvider {
  HttpExternalAgentMemoryRepositoryProvider({
    http.Client? client,
    ExternalMemoryAuthorizationProvider? authorizationProvider,
  }) : _client = client ?? http.Client(),
       _authorizationProvider = authorizationProvider;

  final http.Client _client;
  final ExternalMemoryAuthorizationProvider? _authorizationProvider;
  final Map<String, AgentMemoryRepository> _repositories =
      <String, AgentMemoryRepository>{};

  Future<AgentMemoryRepository> call(String backendReference) async {
    final reference = backendReference.trim();
    return _repositories.putIfAbsent(reference, () {
      final endpoint = Uri.tryParse(reference);
      if (endpoint == null) {
        throw ArgumentError.value(
          backendReference,
          'backendReference',
          'External memory reference must be an endpoint URI.',
        );
      }
      return ExternalVectorAgentMemoryRepository(
        store: HttpExternalVectorMemoryStore(
          endpoint: endpoint,
          client: _client,
          authorizationProvider: _authorizationProvider,
        ),
      );
    });
  }
}

final class ExternalVectorMemoryException implements Exception {
  const ExternalVectorMemoryException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'External Agent memory request failed ($statusCode).';
}

Uri _validateEndpoint(Uri endpoint) {
  final localhost =
      endpoint.host == 'localhost' ||
      endpoint.host == '127.0.0.1' ||
      endpoint.host == '::1';
  if (!endpoint.hasScheme ||
      !endpoint.hasAuthority ||
      (endpoint.scheme != 'https' &&
          !(endpoint.scheme == 'http' && localhost))) {
    throw ArgumentError.value(
      endpoint,
      'endpoint',
      'External memory endpoint must use HTTPS (HTTP is localhost-only).',
    );
  }
  return endpoint;
}

void _validateOwners(String agentId, Iterable<AgentMemory> memories) {
  if (memories.any((memory) => memory.agentId != agentId)) {
    throw const FormatException('External Agent memory owner mismatch.');
  }
}

AgentMemory? _headForKey(Iterable<AgentMemory> items, String memoryKey) {
  for (final item in items) {
    if (item.memoryKey == memoryKey) return item;
  }
  return null;
}

AgentMemory? _currentById(Iterable<AgentMemory> items, String memoryId) {
  for (final item in items) {
    if (item.id == memoryId) return item;
  }
  return null;
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

String _uniqueVersionId(String requested, AgentMemory? previous, int version) {
  var base = requested.trim();
  if (base.isEmpty) base = 'memory_${DateTime.now().microsecondsSinceEpoch}';
  base = base.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  if (previous == null || base != previous.id) return base;
  return '${base}_v$version';
}

final class _ExternalPendingMutation {
  const _ExternalPendingMutation(
    this.memory,
    this.changed,
    this.previousMemoryId,
  );

  factory _ExternalPendingMutation.changed(
    AgentMemory memory, {
    required String previousMemoryId,
  }) => _ExternalPendingMutation(memory, true, previousMemoryId);

  factory _ExternalPendingMutation.unchanged(AgentMemory memory) =>
      _ExternalPendingMutation(memory, false, '');

  final AgentMemory memory;
  final bool changed;
  final String previousMemoryId;
}

typedef ExternalAgentMemoryClock = DateTime Function();
