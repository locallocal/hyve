import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hyve/domain/models/agent.dart';
import 'package:hyve/domain/models/agent_memory.dart';
import 'package:hyve/domain/models/project_event.dart';
import 'package:hyve/domain/repositories/agent_memory_candidate_extractor.dart';
import 'package:hyve/domain/repositories/agent_memory_evolution_repository.dart';
import 'package:hyve/domain/repositories/agent_memory_repository.dart';
import 'package:hyve/domain/services/agent_memory_safety.dart';

typedef AgentMemoryEvolutionClock = DateTime Function();
typedef AgentMemoryEvolutionIdFactory = String Function(String prefix);

final class EvolveAgentMemoryResult {
  EvolveAgentMemoryResult({
    required this.run,
    required Iterable<AgentMemory> memories,
    this.rejectedCount = 0,
  }) : memories = List<AgentMemory>.unmodifiable(memories);

  final AgentMemoryEvolutionRun run;
  final List<AgentMemory> memories;
  final int rejectedCount;
}

/// Extracts and evolves only the current Agent's observable evidence.
final class EvolveAgentMemory {
  EvolveAgentMemory({
    required AgentMemoryRepository memoryRepository,
    required AgentMemoryCandidateExtractor extractor,
    AgentMemoryEvolutionRepository? evolutionRepository,
    AgentMemorySafety safety = const AgentMemorySafety(),
    AgentMemoryEvolutionClock? clock,
    AgentMemoryEvolutionIdFactory? idFactory,
  }) : _memoryRepository = memoryRepository,
       _extractor = extractor,
       _evolutionRepository = evolutionRepository,
       _safety = safety,
       _clock = clock ?? DateTime.now,
       _idFactory = idFactory ?? _defaultId;

  final AgentMemoryRepository _memoryRepository;
  final AgentMemoryCandidateExtractor _extractor;
  final AgentMemoryEvolutionRepository? _evolutionRepository;
  final AgentMemorySafety _safety;
  final AgentMemoryEvolutionClock _clock;
  final AgentMemoryEvolutionIdFactory _idFactory;

  Future<EvolveAgentMemoryResult> call({
    required Agent agent,
    required String projectId,
    required List<ProjectEvent> observedEvents,
    required int contextThroughMessageSequence,
    String agentResponse = '',
  }) async {
    final now = _clock();
    final runId = _idFactory('memory-evolution');
    final boundedEvents = <ProjectEvent>[
      for (final event in observedEvents)
        if (event.messageSequence != null &&
            event.messageSequence! <= contextThroughMessageSequence)
          event,
    ];
    final inputDigest = _inputDigest(boundedEvents);
    if (!agent.memoryPolicy.autoEvolutionEnabled) {
      final run = AgentMemoryEvolutionRun(
        id: runId,
        agentId: agent.id,
        sourceProjectId: projectId,
        sourceEventIds: boundedEvents.map((event) => event.id),
        inputDigest: inputDigest,
        inputCount: boundedEvents.length,
        status: AgentMemoryEvolutionStatus.disabled,
        createdAt: now,
        completedAt: now,
      );
      await _evolutionRepository?.save(run);
      return EvolveAgentMemoryResult(run: run, memories: const []);
    }
    try {
      final extraction = await _extractor.extract(
        AgentMemoryCandidateExtractionRequest(
          agent: agent,
          projectId: projectId,
          observedEvents: boundedEvents,
          contextThroughMessageSequence: contextThroughMessageSequence,
          agentResponse: _safety.redact(agentResponse),
        ),
      );
      final allowedEvidence = <String, ProjectEvent>{
        for (final event in boundedEvents) event.id: event,
      };
      final memories = <AgentMemory>[];
      var rejected = 0;
      for (final draft in extraction.candidates) {
        final evidence = <ProjectEvent>[
          for (final id in draft.sourceEventIds)
            if (allowedEvidence[id] case final event?) event,
        ];
        if (evidence.isEmpty ||
            evidence.length != draft.sourceEventIds.toSet().length ||
            _safety.isSecretLike(draft.content)) {
          rejected++;
          continue;
        }
        final scope = _scopeFor(agent.memoryPolicy, draft);
        final requiresApproval = scope == AgentMemoryReuseScope.userApproved;
        final memory = AgentMemory(
          id: _idFactory('memory'),
          agentId: agent.id,
          memoryKey: draft.memoryKey,
          kind: draft.kind,
          content: draft.content,
          state:
              requiresApproval
                  ? AgentMemoryState.candidate
                  : AgentMemoryState.active,
          reuseScope: scope,
          sensitivity: draft.sensitivity,
          importance: draft.importance,
          confidence: draft.confidence,
          sourceProjectId: projectId,
          sourceEventIds: evidence.map((event) => event.id),
          sourceMessageSequence: evidence
              .map((event) => event.messageSequence!)
              .reduce((left, right) => left > right ? left : right),
          sourceDigest: _inputDigest(evidence),
          createdAt: now,
          updatedAt: now,
        );
        memories.add((await _memoryRepository.propose(memory)).memory);
      }
      final completed = _clock();
      final run = AgentMemoryEvolutionRun(
        id: runId,
        agentId: agent.id,
        sourceProjectId: projectId,
        sourceEventIds: boundedEvents.map((event) => event.id),
        provider: extraction.provider,
        model: extraction.model,
        inputDigest: inputDigest,
        inputCount: boundedEvents.length,
        resultCount: memories.length,
        inputTokenCount: extraction.usage.inputTokens,
        outputTokenCount: extraction.usage.outputTokens,
        status:
            rejected > 0 && memories.isEmpty
                ? AgentMemoryEvolutionStatus.rejected
                : AgentMemoryEvolutionStatus.completed,
        errorCode: rejected > 0 ? 'agent_memory_candidates_rejected' : '',
        createdAt: now,
        completedAt: completed,
      );
      await _evolutionRepository?.save(run);
      return EvolveAgentMemoryResult(
        run: run,
        memories: memories,
        rejectedCount: rejected,
      );
    } on Object {
      final run = AgentMemoryEvolutionRun(
        id: runId,
        agentId: agent.id,
        sourceProjectId: projectId,
        sourceEventIds: boundedEvents.map((event) => event.id),
        inputDigest: inputDigest,
        inputCount: boundedEvents.length,
        status: AgentMemoryEvolutionStatus.failed,
        errorCode: 'agent_memory_evolution_failed',
        createdAt: now,
        completedAt: _clock(),
      );
      await _evolutionRepository?.save(run);
      rethrow;
    }
  }
}

AgentMemoryReuseScope _scopeFor(
  AgentMemoryPolicy policy,
  AgentMemoryCandidateDraft draft,
) {
  final crossProject = policy.autoCrossProjectKinds.contains(draft.kind.name);
  if (!crossProject) return AgentMemoryReuseScope.sourceProjectOnly;
  if (draft.sensitivity == AgentMemorySensitivity.private ||
      draft.confidence < policy.retrieval.minConfidence) {
    return AgentMemoryReuseScope.userApproved;
  }
  return AgentMemoryReuseScope.crossProject;
}

String _inputDigest(Iterable<ProjectEvent> events) =>
    sha256
        .convert(
          utf8.encode(
            jsonEncode(<Map<String, Object?>>[
              for (final event in events)
                <String, Object?>{
                  'id': event.id,
                  'messageSequence': event.messageSequence,
                  'content': event.content,
                },
            ]),
          ),
        )
        .toString();

int _sequence = 0;
String _defaultId(String prefix) {
  _sequence = (_sequence + 1) & 0x7fffffff;
  return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_sequence';
}
