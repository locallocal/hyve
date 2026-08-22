import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hyve/data/repositories/external_vector_agent_memory_repository.dart';
import 'package:hyve/data/repositories/file_agent_memory_repository.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/agent_memory.dart';
import 'package:hyve/domain/repositories/agent_memory_repository.dart';

void main() {
  group('file AgentMemory contract', () {
    late Directory support;
    late FileAgentMemoryRepository repository;

    setUp(() async {
      support = await Directory.systemTemp.createTemp('hyve-memory-contract-');
      repository = FileAgentMemoryRepository(
        storage: ProjectAgentStorageService(
          supportDirectoryProvider: () async => support,
        ),
        clock: () => DateTime.utc(2026, 8, 22, 12),
      );
    });
    tearDown(() async {
      await repository.dispose();
      await support.delete(recursive: true);
    });
    _agentMemoryContract(() => repository);
  });

  group('external-vector AgentMemory contract', () {
    late _MemoryVectorStore store;
    late ExternalVectorAgentMemoryRepository repository;

    setUp(() {
      store = _MemoryVectorStore();
      repository = ExternalVectorAgentMemoryRepository(
        store: store,
        clock: () => DateTime.utc(2026, 8, 22, 12),
      );
    });
    tearDown(() => store.dispose());
    _agentMemoryContract(() => repository);

    test('rebuilds its derived vector index from stored heads', () async {
      await repository.propose(_memory(id: 'indexed'));
      store.dropIndex();
      await store.rebuildIndex('agent-1');

      final result = await repository.search(_search('concise'));

      expect(result.items.single.memoryKey, 'user.answer_style');
    });
  });

  test('HTTP provider uses HTTPS, authorization, and revision CAS', () async {
    final requests = <http.BaseRequest>[];
    final provider = HttpExternalAgentMemoryRepositoryProvider(
      client: MockClient((request) async {
        requests.add(request);
        if (request.method == 'GET') {
          return http.Response('{"revision":0,"items":[]}', 200);
        }
        return http.Response('{"revision":1}', 200);
      }),
      authorizationProvider: (_) async => 'Bearer secure-token',
    );
    final repository = await provider.call('https://memory.example/base');

    final saved = await repository.propose(_memory(id: 'remote'));

    expect(saved.revision, 1);
    expect(requests.map((request) => request.method), ['GET', 'PUT']);
    expect(requests.last.url.path, '/base/v1/agents/agent-1/memory/head');
    expect(requests.last.headers['if-match'], '0');
    expect(requests.last.headers['authorization'], 'Bearer secure-token');
    await expectLater(
      provider.call('http://memory.example'),
      throwsArgumentError,
    );
  });
}

void _agentMemoryContract(AgentMemoryRepository Function() repository) {
  test('uses immutable versions and revision CAS', () async {
    final first = await repository().propose(_memory(id: 'memory-1'));
    final second = await repository().propose(
      _memory(id: 'memory-2', content: 'Prefer verified concise answers.'),
      expectedRevision: first.revision,
    );

    expect(first.revision, 1);
    expect(second.revision, 2);
    expect(second.memory.version, 2);
    expect(second.memory.supersedesId, first.memory.id);
    expect(await repository().list('agent-1'), hasLength(1));
    expect(
      await repository().list('agent-1', includeHistory: true),
      hasLength(2),
    );
    await expectLater(
      repository().propose(
        _memory(id: 'stale', content: 'stale update'),
        expectedRevision: 0,
      ),
      throwsA(isA<AgentMemoryRevisionConflict>()),
    );
  });

  test('rejects secrets before create and correction', () async {
    await expectLater(
      repository().propose(
        _memory(id: 'secret', content: 'api_key=abcdefghijklmnop'),
      ),
      throwsA(isA<AgentMemorySecretLikeException>()),
    );
    final saved = await repository().propose(_memory(id: 'safe'));
    await expectLater(
      repository().correct(
        agentId: 'agent-1',
        memoryId: saved.memory.id,
        content: 'password: extremely-secret-value',
        reuseScope: AgentMemoryReuseScope.crossProject,
      ),
      throwsA(isA<AgentMemorySecretLikeException>()),
    );
  });

  test('isolates agents, source projects, and future evidence', () async {
    await repository().propose(_memory(id: 'cross'));
    await repository().propose(
      _memory(
        id: 'local',
        key: 'project.fact',
        content: 'Project launch is Friday.',
        scope: AgentMemoryReuseScope.sourceProjectOnly,
        sourceSequence: 8,
      ),
    );
    await repository().propose(
      _memory(id: 'other-agent', agentId: 'agent-2', key: 'private.fact'),
    );

    final otherProject = await repository().search(
      _search('answers Friday', currentProjectId: 'project-2'),
    );
    expect(otherProject.items.map((item) => item.memoryKey), [
      'user.answer_style',
    ]);
    final beforeEvidence = await repository().search(
      _search('Friday', contextThroughMessageSequence: 7),
    );
    expect(
      beforeEvidence.items.map((item) => item.memoryKey),
      isNot(contains('project.fact')),
    );
    expect(await repository().list('agent-1'), hasLength(2));
    expect(await repository().list('agent-2'), hasLength(1));
  });
}

AgentMemorySearchRequest _search(
  String query, {
  String currentProjectId = 'project-1',
  int contextThroughMessageSequence = 20,
}) => AgentMemorySearchRequest(
  agentId: 'agent-1',
  query: query,
  currentProjectId: currentProjectId,
  contextThroughMessageSequence: contextThroughMessageSequence,
  minConfidence: 0,
);

AgentMemory _memory({
  required String id,
  String agentId = 'agent-1',
  String key = 'user.answer_style',
  String content = 'Prefer concise answers.',
  AgentMemoryReuseScope scope = AgentMemoryReuseScope.crossProject,
  int sourceSequence = 3,
}) => AgentMemory(
  id: id,
  agentId: agentId,
  memoryKey: key,
  kind: AgentMemoryKind.userPreference,
  content: content,
  state: AgentMemoryState.active,
  reuseScope: scope,
  importance: 0.8,
  confidence: 0.9,
  sourceProjectId: 'project-1',
  sourceEventIds: const <String>['event-1'],
  sourceMessageSequence: sourceSequence,
  sourceDigest: 'source-digest',
  createdAt: DateTime.utc(2026, 8, 22),
  updatedAt: DateTime.utc(2026, 8, 22),
);

final class _MemoryVectorStore implements ExternalVectorMemoryStore {
  final Map<String, int> _revisions = <String, int>{};
  final Map<String, Map<String, AgentMemory>> _heads =
      <String, Map<String, AgentMemory>>{};
  final Map<String, List<AgentMemory>> _history = <String, List<AgentMemory>>{};
  final Map<String, List<String>> _index = <String, List<String>>{};
  final StreamController<String> _changes = StreamController.broadcast();

  @override
  Stream<String> get changes => _changes.stream;

  @override
  Future<ExternalVectorMemoryState> load(
    String agentId, {
    bool includeHistory = false,
  }) async => ExternalVectorMemoryState(
    revision: _revisions[agentId] ?? 0,
    items:
        includeHistory
            ? _history[agentId] ?? const <AgentMemory>[]
            : _heads[agentId]?.values ?? const <AgentMemory>[],
  );

  @override
  Future<ExternalVectorMemoryState> search(
    AgentMemorySearchRequest request,
  ) async {
    final indexed = _index[request.agentId] ?? const <String>[];
    final heads = _heads[request.agentId] ?? const <String, AgentMemory>{};
    final query = request.query.toLowerCase();
    final items = <AgentMemory>[
      for (final key in indexed)
        if (heads[key] case final memory?) memory,
    ]..sort((left, right) {
      final leftMatch = left.content.toLowerCase().contains(query) ? 1 : 0;
      final rightMatch = right.content.toLowerCase().contains(query) ? 1 : 0;
      return rightMatch.compareTo(leftMatch);
    });
    return ExternalVectorMemoryState(
      revision: _revisions[request.agentId] ?? 0,
      items: items,
    );
  }

  @override
  Future<int> compareAndSwap({
    required String agentId,
    required int expectedRevision,
    required String previousMemoryId,
    required AgentMemory memory,
  }) async {
    if ((_revisions[agentId] ?? 0) != expectedRevision) {
      throw const AgentMemoryRevisionConflict();
    }
    final heads = _heads.putIfAbsent(agentId, () => <String, AgentMemory>{});
    final current = heads[memory.memoryKey];
    if ((current?.id ?? '') != previousMemoryId) {
      throw const AgentMemoryRevisionConflict();
    }
    heads[memory.memoryKey] = memory;
    _history.putIfAbsent(agentId, () => <AgentMemory>[]).add(memory);
    _index.putIfAbsent(agentId, () => <String>[])
      ..remove(memory.memoryKey)
      ..add(memory.memoryKey);
    final revision = expectedRevision + 1;
    _revisions[agentId] = revision;
    _changes.add(agentId);
    return revision;
  }

  void dropIndex() => _index.clear();

  Future<void> rebuildIndex(String agentId) async {
    _index[agentId] = _heads[agentId]?.keys.toList(growable: false) ?? const [];
  }

  Future<void> dispose() => _changes.close();
}
