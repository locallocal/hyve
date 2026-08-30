import 'dart:collection';

final class BroadcastDecisionPolicy {
  const BroadcastDecisionPolicy({
    this.concurrency = 4,
    this.maxInputTokens = 4096,
    this.maxOutputTokens = 128,
    this.timeout = const Duration(seconds: 10),
    this.maxAttempts = 1,
    this.failureOutcome = 'pass',
  }) : assert(concurrency > 0),
       assert(maxInputTokens > 0),
       assert(maxOutputTokens > 0),
       assert(maxAttempts == 1);

  final int concurrency;
  final int maxInputTokens;
  final int maxOutputTokens;

  /// Retained for response-policy persistence compatibility.
  ///
  /// Broadcast participation execution no longer applies a time limit.
  final Duration timeout;
  final int maxAttempts;
  final String failureOutcome;
}

final class ProjectResponsePolicy {
  const ProjectResponsePolicy({
    this.schemaVersion = 1,
    this.broadcastDecision = const BroadcastDecisionPolicy(),
    this.replyConcurrency = 2,
    this.autonomousChainMaxDepth = 4,
    this.autonomousChainMaxAgentMessagesPerRoot = 16,
    this.deliveryDefaultVisibility = 'project',
    this.deliveryMaxDepth = 4,
    this.deliveryMaxDeliveriesPerTurn = 8,
  }) : assert(schemaVersion == 1),
       assert(replyConcurrency > 0),
       assert(autonomousChainMaxDepth >= 0),
       assert(autonomousChainMaxAgentMessagesPerRoot >= 0),
       assert(deliveryMaxDepth >= 0),
       assert(deliveryMaxDeliveriesPerTurn >= 0);

  static const defaults = ProjectResponsePolicy();

  final int schemaVersion;
  final BroadcastDecisionPolicy broadcastDecision;
  final int replyConcurrency;
  final int autonomousChainMaxDepth;
  final int autonomousChainMaxAgentMessagesPerRoot;
  final String deliveryDefaultVisibility;
  final int deliveryMaxDepth;
  final int deliveryMaxDeliveriesPerTurn;
}

final class Project {
  Project({
    required this.id,
    required this.name,
    Map<String, Object?> uiMetadata = const <String, Object?>{},
    this.responsePolicy = ProjectResponsePolicy.defaults,
    this.lastEventSequence = 0,
    this.lastMessageSequence = 0,
    this.lastMessage = '',
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  }) : uiMetadata = UnmodifiableMapView(Map<String, Object?>.from(uiMetadata)) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Project id cannot be empty.');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Project name cannot be empty.');
    }
    if (lastEventSequence < 0 || lastMessageSequence < 0) {
      throw ArgumentError('Project sequences cannot be negative.');
    }
  }

  final String id;
  final String name;
  final Map<String, Object?> uiMetadata;
  final ProjectResponsePolicy responsePolicy;
  final int lastEventSequence;
  final int lastMessageSequence;
  final String lastMessage;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project copyWith({
    String? name,
    Map<String, Object?>? uiMetadata,
    ProjectResponsePolicy? responsePolicy,
    int? lastEventSequence,
    int? lastMessageSequence,
    String? lastMessage,
    DateTime? lastMessageAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      uiMetadata: uiMetadata ?? this.uiMetadata,
      responsePolicy: responsePolicy ?? this.responsePolicy,
      lastEventSequence: lastEventSequence ?? this.lastEventSequence,
      lastMessageSequence: lastMessageSequence ?? this.lastMessageSequence,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
