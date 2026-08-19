import 'dart:collection';

enum AgentMemoryBackend { file, externalVector }

final class AgentMemoryRetrievalPolicy {
  const AgentMemoryRetrievalPolicy({
    this.maxItems = 12,
    this.tokenBudget = 2048,
    this.minConfidence = 0.65,
  }) : assert(maxItems > 0),
       assert(tokenBudget > 0),
       assert(minConfidence >= 0 && minConfidence <= 1);

  final int maxItems;
  final int tokenBudget;
  final double minConfidence;
}

final class AgentMemoryPolicy {
  AgentMemoryPolicy({
    this.schemaVersion = 1,
    this.autoEvolutionEnabled = true,
    this.projectFactDefaultScope = 'sourceProjectOnly',
    Iterable<String> autoCrossProjectKinds = const <String>{
      'userPreference',
      'learnedPattern',
      'capabilityNote',
      'reflection',
    },
    this.privateCrossProject = 'requireUserApproval',
    this.uncertainCrossProject = 'requireUserApproval',
    this.secretLike = 'reject',
    this.retrieval = const AgentMemoryRetrievalPolicy(),
  }) : autoCrossProjectKinds = Set<String>.unmodifiable(autoCrossProjectKinds) {
    if (schemaVersion != 1) {
      throw ArgumentError.value(
        schemaVersion,
        'schemaVersion',
        'Only Agent memory policy schema version 1 is supported.',
      );
    }
  }

  static final defaults = AgentMemoryPolicy();

  final int schemaVersion;
  final bool autoEvolutionEnabled;
  final String projectFactDefaultScope;
  final Set<String> autoCrossProjectKinds;
  final String privateCrossProject;
  final String uncertainCrossProject;
  final String secretLike;
  final AgentMemoryRetrievalPolicy retrieval;
}

final class Agent {
  Agent({
    required this.id,
    required this.name,
    required this.avatar,
    required this.provider,
    required this.baseUrl,
    required this.apiKey,
    required this.apiType,
    required this.model,
    required this.systemPrompt,
    Map<String, Object?> parameters = const <String, Object?>{},
    AgentMemoryPolicy? memoryPolicy,
    this.memoryBackend = AgentMemoryBackend.file,
    this.memoryBackendRef = '',
    required this.createdAt,
    required this.updatedAt,
  }) : parameters = UnmodifiableMapView(Map<String, Object?>.from(parameters)),
       memoryPolicy = memoryPolicy ?? AgentMemoryPolicy.defaults {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Agent id cannot be empty.');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Agent name cannot be empty.');
    }
    if (memoryBackend == AgentMemoryBackend.file &&
        memoryBackendRef.isNotEmpty) {
      throw ArgumentError.value(
        memoryBackendRef,
        'memoryBackendRef',
        'The file memory backend does not accept an external reference.',
      );
    }
    if (memoryBackend == AgentMemoryBackend.externalVector &&
        memoryBackendRef.trim().isEmpty) {
      throw ArgumentError.value(
        memoryBackendRef,
        'memoryBackendRef',
        'An external vector memory backend requires a connection reference.',
      );
    }
  }

  final String id;
  final String name;
  final String avatar;
  final String provider;
  final String baseUrl;
  final String apiKey;
  final String apiType;
  final String model;
  final String systemPrompt;
  final Map<String, Object?> parameters;
  final AgentMemoryPolicy memoryPolicy;
  final AgentMemoryBackend memoryBackend;
  final String memoryBackendRef;
  final DateTime createdAt;
  final DateTime updatedAt;

  Agent copyWith({
    String? name,
    String? avatar,
    String? provider,
    String? baseUrl,
    String? apiKey,
    String? apiType,
    String? model,
    String? systemPrompt,
    Map<String, Object?>? parameters,
    AgentMemoryPolicy? memoryPolicy,
    AgentMemoryBackend? memoryBackend,
    String? memoryBackendRef,
    DateTime? updatedAt,
  }) {
    return Agent(
      id: id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      provider: provider ?? this.provider,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      apiType: apiType ?? this.apiType,
      model: model ?? this.model,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      parameters: parameters ?? this.parameters,
      memoryPolicy: memoryPolicy ?? this.memoryPolicy,
      memoryBackend: memoryBackend ?? this.memoryBackend,
      memoryBackendRef: memoryBackendRef ?? this.memoryBackendRef,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
