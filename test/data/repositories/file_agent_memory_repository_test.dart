import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/repositories/file_agent_memory_repository.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/agent_memory.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory support;
  late FileAgentMemoryRepository repository;

  setUp(() async {
    support = await Directory.systemTemp.createTemp('hyve-agent-memory-');
    repository = FileAgentMemoryRepository(
      storage: ProjectAgentStorageService(
        supportDirectoryProvider: () async => support,
      ),
      clock: () => DateTime.utc(2026, 8, 22, 12),
    );
  });

  tearDown(() async {
    await repository.dispose();
    if (await support.exists()) await support.delete(recursive: true);
  });

  test('commits immutable versions and enforces manifest CAS', () async {
    final first = await repository.propose(_memory(id: 'memory-1'));
    final second = await repository.propose(
      _memory(id: 'memory-2', content: 'Prefer short verified answers.'),
      expectedRevision: first.revision,
    );

    expect(first.revision, 1);
    expect(second.revision, 2);
    expect(second.memory.version, 2);
    expect(second.memory.supersedesId, first.memory.id);
    expect(await repository.list('agent-1'), hasLength(1));
    expect(
      await repository.list('agent-1', includeHistory: true),
      hasLength(2),
    );
    expect(
      File(
        path.join(
          support.path,
          'agents',
          'agent-1',
          'memory',
          'items',
          first.memory.id,
          '1.json',
        ),
      ).existsSync(),
      isTrue,
    );
    await expectLater(
      repository.propose(
        _memory(id: 'memory-3', content: 'new'),
        expectedRevision: 0,
      ),
      throwsA(isA<AgentMemoryRevisionConflict>()),
    );
  });

  test('rejects secret-like content on create and correction', () async {
    await expectLater(
      repository.propose(
        _memory(id: 'secret', content: 'api_key=abcdefghijklmnop'),
      ),
      throwsA(isA<AgentMemorySecretLikeException>()),
    );
    final saved = await repository.propose(_memory(id: 'safe'));
    await expectLater(
      repository.correct(
        agentId: 'agent-1',
        memoryId: saved.memory.id,
        content: 'password: extremely-secret-value',
        reuseScope: AgentMemoryReuseScope.crossProject,
      ),
      throwsA(isA<AgentMemorySecretLikeException>()),
    );
  });

  test('filters scope and source sequence before relevance ranking', () async {
    await repository.propose(_memory(id: 'cross'));
    await repository.propose(
      _memory(
        id: 'local',
        key: 'project.fact',
        content: 'Project launch is Friday.',
        scope: AgentMemoryReuseScope.sourceProjectOnly,
        sourceSequence: 8,
      ),
    );
    await repository.propose(
      _memory(
        id: 'candidate',
        key: 'private.preference',
        content: 'Private candidate',
        state: AgentMemoryState.candidate,
        scope: AgentMemoryReuseScope.userApproved,
      ),
    );

    final otherProject = await repository.search(
      const AgentMemorySearchRequest(
        agentId: 'agent-1',
        query: 'answers Friday',
        currentProjectId: 'project-2',
        contextThroughMessageSequence: 20,
        minConfidence: 0,
      ),
    );
    expect(otherProject.items.map((item) => item.id), ['cross']);

    final beforeEvidence = await repository.search(
      const AgentMemorySearchRequest(
        agentId: 'agent-1',
        query: 'Friday',
        currentProjectId: 'project-1',
        contextThroughMessageSequence: 7,
        minConfidence: 0,
      ),
    );
    expect(
      beforeEvidence.items.map((item) => item.id),
      isNot(contains('local')),
    );
  });

  test('digest corruption fails closed', () async {
    final saved = await repository.propose(_memory(id: 'memory-1'));
    final file = File(
      path.join(
        support.path,
        'agents',
        'agent-1',
        'memory',
        'items',
        saved.memory.id,
        '1.json',
      ),
    );
    await file.writeAsString('tampered');

    await expectLater(
      repository.search(
        const AgentMemorySearchRequest(
          agentId: 'agent-1',
          query: 'answers',
          currentProjectId: 'project-1',
          contextThroughMessageSequence: 10,
          minConfidence: 0,
        ),
      ),
      throwsA(isA<FormatException>()),
    );
  });
}

AgentMemory _memory({
  required String id,
  String key = 'user.answer_style',
  String content = 'Prefer concise answers.',
  AgentMemoryState state = AgentMemoryState.active,
  AgentMemoryReuseScope scope = AgentMemoryReuseScope.crossProject,
  int sourceSequence = 3,
}) => AgentMemory(
  id: id,
  agentId: 'agent-1',
  memoryKey: key,
  kind: AgentMemoryKind.userPreference,
  content: content,
  state: state,
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
