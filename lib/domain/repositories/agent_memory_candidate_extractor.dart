import 'package:hyve/domain/models/agent.dart';
import 'package:hyve/domain/models/agent_memory.dart';
import 'package:hyve/domain/models/message.dart';
import 'package:hyve/domain/models/project_event.dart';

final class AgentMemoryCandidateDraft {
  AgentMemoryCandidateDraft({
    required this.memoryKey,
    required this.kind,
    required this.content,
    this.sensitivity = AgentMemorySensitivity.normal,
    this.importance = 0.5,
    this.confidence = 0.5,
    required Iterable<String> sourceEventIds,
  }) : sourceEventIds = List<String>.unmodifiable(sourceEventIds);

  final String memoryKey;
  final AgentMemoryKind kind;
  final String content;
  final AgentMemorySensitivity sensitivity;
  final double importance;
  final double confidence;
  final List<String> sourceEventIds;
}

final class AgentMemoryCandidateExtractionRequest {
  AgentMemoryCandidateExtractionRequest({
    required this.agent,
    required this.projectId,
    required Iterable<ProjectEvent> observedEvents,
    required this.contextThroughMessageSequence,
    this.agentResponse = '',
  }) : observedEvents = List<ProjectEvent>.unmodifiable(observedEvents);

  final Agent agent;
  final String projectId;
  final List<ProjectEvent> observedEvents;
  final int contextThroughMessageSequence;
  final String agentResponse;
}

final class AgentMemoryCandidateExtractionResult {
  AgentMemoryCandidateExtractionResult({
    required Iterable<AgentMemoryCandidateDraft> candidates,
    this.usage = ModelTokenUsage.empty,
    this.provider = '',
    this.model = '',
  }) : candidates = List<AgentMemoryCandidateDraft>.unmodifiable(candidates);

  final List<AgentMemoryCandidateDraft> candidates;
  final ModelTokenUsage usage;
  final String provider;
  final String model;
}

abstract interface class AgentMemoryCandidateExtractor {
  Future<AgentMemoryCandidateExtractionResult> extract(
    AgentMemoryCandidateExtractionRequest request,
  );
}
