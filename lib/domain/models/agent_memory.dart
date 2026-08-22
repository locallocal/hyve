enum AgentMemoryKind {
  userPreference,
  learnedPattern,
  capabilityNote,
  relationship,
  fact,
  reflection,
}

enum AgentMemoryState { candidate, active, superseded, forgotten }

enum AgentMemoryReuseScope { crossProject, sourceProjectOnly, userApproved }

enum AgentMemorySensitivity { normal, private }

final class AgentMemory {
  AgentMemory({
    required this.id,
    required this.agentId,
    required this.memoryKey,
    required this.kind,
    required this.content,
    this.state = AgentMemoryState.candidate,
    this.reuseScope = AgentMemoryReuseScope.userApproved,
    this.sensitivity = AgentMemorySensitivity.normal,
    this.importance = 0.5,
    this.confidence = 0.5,
    this.sourceProjectId = '',
    Iterable<String> sourceEventIds = const <String>[],
    this.sourceMessageSequence,
    this.sourceDigest = '',
    this.version = 1,
    this.supersedesId = '',
    required this.createdAt,
    required this.updatedAt,
    this.lastUsedAt,
  }) : sourceEventIds = List<String>.unmodifiable(sourceEventIds) {
    if (id.trim().isEmpty ||
        agentId.trim().isEmpty ||
        memoryKey.trim().isEmpty ||
        content.trim().isEmpty) {
      throw ArgumentError('Agent memory identity and content are required.');
    }
    if (importance < 0 || importance > 1 || confidence < 0 || confidence > 1) {
      throw ArgumentError('Agent memory scores must be between zero and one.');
    }
    if (version < 1 ||
        (sourceMessageSequence != null && sourceMessageSequence! < 1)) {
      throw ArgumentError('Agent memory version and source must be positive.');
    }
    if (reuseScope == AgentMemoryReuseScope.sourceProjectOnly &&
        sourceProjectId.isEmpty) {
      throw ArgumentError(
        'sourceProjectOnly Agent memory requires a source Project.',
      );
    }
  }

  final String id;
  final String agentId;
  final String memoryKey;
  final AgentMemoryKind kind;
  final String content;
  final AgentMemoryState state;
  final AgentMemoryReuseScope reuseScope;
  final AgentMemorySensitivity sensitivity;
  final double importance;
  final double confidence;
  final String sourceProjectId;
  final List<String> sourceEventIds;
  final int? sourceMessageSequence;
  final String sourceDigest;
  final int version;
  final String supersedesId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastUsedAt;

  bool get isRecallable => state == AgentMemoryState.active;

  AgentMemory copyWith({
    String? id,
    String? content,
    AgentMemoryState? state,
    AgentMemoryReuseScope? reuseScope,
    AgentMemorySensitivity? sensitivity,
    double? importance,
    double? confidence,
    int? version,
    String? supersedesId,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
  }) => AgentMemory(
    id: id ?? this.id,
    agentId: agentId,
    memoryKey: memoryKey,
    kind: kind,
    content: content ?? this.content,
    state: state ?? this.state,
    reuseScope: reuseScope ?? this.reuseScope,
    sensitivity: sensitivity ?? this.sensitivity,
    importance: importance ?? this.importance,
    confidence: confidence ?? this.confidence,
    sourceProjectId: sourceProjectId,
    sourceEventIds: sourceEventIds,
    sourceMessageSequence: sourceMessageSequence,
    sourceDigest: sourceDigest,
    version: version ?? this.version,
    supersedesId: supersedesId ?? this.supersedesId,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
  );
}

final class AgentMemorySearchRequest {
  const AgentMemorySearchRequest({
    required this.agentId,
    required this.query,
    required this.currentProjectId,
    required this.contextThroughMessageSequence,
    this.maxItems = 12,
    this.tokenBudget = 2048,
    this.minConfidence = 0.65,
    this.sourceProjectExists,
  }) : assert(maxItems > 0),
       assert(tokenBudget > 0),
       assert(minConfidence >= 0 && minConfidence <= 1),
       assert(contextThroughMessageSequence > 0);

  final String agentId;
  final String query;
  final String currentProjectId;
  final int contextThroughMessageSequence;
  final int maxItems;
  final int tokenBudget;
  final double minConfidence;
  final bool Function(String projectId)? sourceProjectExists;
}

final class AgentMemorySearchResult {
  AgentMemorySearchResult({
    required Iterable<AgentMemory> items,
    required this.estimatedTokenCount,
    required this.revision,
  }) : items = List<AgentMemory>.unmodifiable(items);

  final List<AgentMemory> items;
  final int estimatedTokenCount;
  final int revision;
}

final class AgentMemoryMutationResult {
  const AgentMemoryMutationResult({
    required this.memory,
    required this.revision,
    this.changed = true,
  });

  final AgentMemory memory;
  final int revision;
  final bool changed;
}

final class AgentMemoryRevisionConflict implements Exception {
  const AgentMemoryRevisionConflict();

  @override
  String toString() => 'The Agent memory manifest changed concurrently.';
}

final class AgentMemorySecretLikeException implements Exception {
  const AgentMemorySecretLikeException();

  String get errorCode => 'agent_memory_secret_like_rejected';

  @override
  String toString() => 'Secret-like content cannot be stored as Agent memory.';
}

enum AgentMemoryEvolutionStatus {
  running,
  completed,
  disabled,
  failed,
  rejected,
}

final class AgentMemoryEvolutionRun {
  AgentMemoryEvolutionRun({
    required this.id,
    required this.agentId,
    this.sourceProjectId = '',
    Iterable<String> sourceEventIds = const <String>[],
    this.provider = '',
    this.model = '',
    this.promptVersion = 1,
    this.inputDigest = '',
    this.inputCount = 0,
    this.resultCount = 0,
    this.inputTokenCount = 0,
    this.outputTokenCount = 0,
    required this.status,
    this.errorCode = '',
    required this.createdAt,
    this.completedAt,
  }) : sourceEventIds = List<String>.unmodifiable(sourceEventIds);

  final String id;
  final String agentId;
  final String sourceProjectId;
  final List<String> sourceEventIds;
  final String provider;
  final String model;
  final int promptVersion;
  final String inputDigest;
  final int inputCount;
  final int resultCount;
  final int inputTokenCount;
  final int outputTokenCount;
  final AgentMemoryEvolutionStatus status;
  final String errorCode;
  final DateTime createdAt;
  final DateTime? completedAt;
}
