import 'dart:convert';

import 'package:hyve/domain/models/agent.dart';
import 'package:hyve/domain/models/project.dart';
import 'package:hyve/domain/models/project_membership.dart';

final class AgentRecord {
  const AgentRecord(this.values);

  factory AgentRecord.fromDomain(Agent agent, {required String storedApiKey}) {
    return AgentRecord(<String, Object?>{
      'id': agent.id,
      'name': agent.name,
      'avatar': agent.avatar,
      'provider': agent.provider,
      'base_url': agent.baseUrl,
      'api_key': storedApiKey,
      'api_type': agent.apiType,
      'model': agent.model,
      'system_prompt': agent.systemPrompt,
      'parameters_json': jsonEncode(agent.parameters),
      'memory_policy_json': jsonEncode(_memoryPolicyToJson(agent.memoryPolicy)),
      'memory_backend': agent.memoryBackend.name,
      'memory_backend_ref': agent.memoryBackendRef,
      'created_at': agent.createdAt.millisecondsSinceEpoch,
      'updated_at': agent.updatedAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  String get id => _text(values['id'], 'id');

  String get storedApiKey => _text(values['api_key'], 'api_key');

  Agent toDomain({required String apiKey}) {
    return Agent(
      id: id,
      name: _text(values['name'], 'name'),
      avatar: _text(values['avatar'], 'avatar'),
      provider: _text(values['provider'], 'provider'),
      baseUrl: _text(values['base_url'], 'base_url'),
      apiKey: apiKey,
      apiType: _text(values['api_type'], 'api_type'),
      model: _text(values['model'], 'model'),
      systemPrompt: _text(values['system_prompt'], 'system_prompt'),
      parameters: _jsonObject(values['parameters_json'], 'parameters_json'),
      memoryPolicy: _memoryPolicyFromJson(
        _jsonObject(values['memory_policy_json'], 'memory_policy_json'),
      ),
      memoryBackend: _enumByName(
        AgentMemoryBackend.values,
        _text(values['memory_backend'], 'memory_backend'),
        'memory_backend',
      ),
      memoryBackendRef: _text(
        values['memory_backend_ref'],
        'memory_backend_ref',
      ),
      createdAt: _date(values['created_at'], 'created_at'),
      updatedAt: _date(values['updated_at'], 'updated_at'),
    );
  }
}

final class ProjectRecord {
  const ProjectRecord(this.values);

  factory ProjectRecord.fromDomain(Project project) {
    return ProjectRecord(<String, Object?>{
      'id': project.id,
      'name': project.name,
      'ui_metadata_json': jsonEncode(project.uiMetadata),
      'response_policy_json': jsonEncode(
        _responsePolicyToJson(project.responsePolicy),
      ),
      'last_event_sequence': project.lastEventSequence,
      'last_message_sequence': project.lastMessageSequence,
      'last_message': project.lastMessage,
      'last_message_at': project.lastMessageAt.millisecondsSinceEpoch,
      'created_at': project.createdAt.millisecondsSinceEpoch,
      'updated_at': project.updatedAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  Project toDomain() {
    return Project(
      id: _text(values['id'], 'id'),
      name: _text(values['name'], 'name'),
      uiMetadata: _jsonObject(values['ui_metadata_json'], 'ui_metadata_json'),
      responsePolicy: _responsePolicyFromJson(
        _jsonObject(values['response_policy_json'], 'response_policy_json'),
      ),
      lastEventSequence: _integer(
        values['last_event_sequence'],
        'last_event_sequence',
      ),
      lastMessageSequence: _integer(
        values['last_message_sequence'],
        'last_message_sequence',
      ),
      lastMessage: _text(values['last_message'], 'last_message'),
      lastMessageAt: _date(values['last_message_at'], 'last_message_at'),
      createdAt: _date(values['created_at'], 'created_at'),
      updatedAt: _date(values['updated_at'], 'updated_at'),
    );
  }
}

final class ProjectMembershipRecord {
  const ProjectMembershipRecord(this.values);

  factory ProjectMembershipRecord.fromDomain(ProjectMembership membership) {
    return ProjectMembershipRecord(<String, Object?>{
      'project_id': membership.projectId,
      'agent_id': membership.agentId,
      'status': membership.status.name,
      'position': membership.position,
      'project_storage_access': membership.projectStorageAccess.name,
      'capability_restrictions_json': jsonEncode(
        membership.capabilityRestrictions,
      ),
      'membership_generation': membership.membershipGeneration,
      'join_message_sequence': membership.joinMessageSequence,
      'joined_at': membership.joinedAt.millisecondsSinceEpoch,
      'removed_at': membership.removedAt?.millisecondsSinceEpoch,
      'updated_at': membership.updatedAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  ProjectMembership toDomain() {
    final removedAt = _nullableInteger(values['removed_at'], 'removed_at');
    return ProjectMembership(
      projectId: _text(values['project_id'], 'project_id'),
      agentId: _text(values['agent_id'], 'agent_id'),
      status: _enumByName(
        ProjectMembershipStatus.values,
        _text(values['status'], 'status'),
        'status',
      ),
      position: _integer(values['position'], 'position'),
      projectStorageAccess: _enumByName(
        ProjectStorageAccess.values,
        _text(values['project_storage_access'], 'project_storage_access'),
        'project_storage_access',
      ),
      capabilityRestrictions: _jsonObject(
        values['capability_restrictions_json'],
        'capability_restrictions_json',
      ),
      membershipGeneration: _integer(
        values['membership_generation'],
        'membership_generation',
      ),
      joinMessageSequence: _integer(
        values['join_message_sequence'],
        'join_message_sequence',
      ),
      joinedAt: _date(values['joined_at'], 'joined_at'),
      removedAt:
          removedAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(removedAt),
      updatedAt: _date(values['updated_at'], 'updated_at'),
    );
  }
}

Map<String, Object?> _memoryPolicyToJson(AgentMemoryPolicy policy) => {
  'schemaVersion': policy.schemaVersion,
  'autoEvolutionEnabled': policy.autoEvolutionEnabled,
  'projectFactDefaultScope': policy.projectFactDefaultScope,
  'autoCrossProjectKinds': policy.autoCrossProjectKinds.toList()..sort(),
  'privateCrossProject': policy.privateCrossProject,
  'uncertainCrossProject': policy.uncertainCrossProject,
  'secretLike': policy.secretLike,
  'retrieval': <String, Object?>{
    'maxItems': policy.retrieval.maxItems,
    'tokenBudget': policy.retrieval.tokenBudget,
    'minConfidence': policy.retrieval.minConfidence,
  },
};

AgentMemoryPolicy _memoryPolicyFromJson(Map<String, Object?> json) {
  _requireKeys(json, const <String>{
    'schemaVersion',
    'autoEvolutionEnabled',
    'projectFactDefaultScope',
    'autoCrossProjectKinds',
    'privateCrossProject',
    'uncertainCrossProject',
    'secretLike',
    'retrieval',
  }, 'memory_policy_json');
  final retrieval = _object(json['retrieval'], 'retrieval');
  _requireKeys(retrieval, const <String>{
    'maxItems',
    'tokenBudget',
    'minConfidence',
  }, 'memory_policy_json.retrieval');
  return AgentMemoryPolicy(
    schemaVersion: _integer(json['schemaVersion'], 'schemaVersion'),
    autoEvolutionEnabled: _boolean(
      json['autoEvolutionEnabled'],
      'autoEvolutionEnabled',
    ),
    projectFactDefaultScope: _text(
      json['projectFactDefaultScope'],
      'projectFactDefaultScope',
    ),
    autoCrossProjectKinds: _stringList(
      json['autoCrossProjectKinds'],
      'autoCrossProjectKinds',
    ),
    privateCrossProject: _text(
      json['privateCrossProject'],
      'privateCrossProject',
    ),
    uncertainCrossProject: _text(
      json['uncertainCrossProject'],
      'uncertainCrossProject',
    ),
    secretLike: _text(json['secretLike'], 'secretLike'),
    retrieval: AgentMemoryRetrievalPolicy(
      maxItems: _integer(retrieval['maxItems'], 'maxItems'),
      tokenBudget: _integer(retrieval['tokenBudget'], 'tokenBudget'),
      minConfidence: _number(retrieval['minConfidence'], 'minConfidence'),
    ),
  );
}

Map<String, Object?> _responsePolicyToJson(ProjectResponsePolicy policy) => {
  'schemaVersion': policy.schemaVersion,
  'broadcastDecision': <String, Object?>{
    'concurrency': policy.broadcastDecision.concurrency,
    'maxInputTokens': policy.broadcastDecision.maxInputTokens,
    'maxOutputTokens': policy.broadcastDecision.maxOutputTokens,
    'timeoutMs': policy.broadcastDecision.timeout.inMilliseconds,
    'maxAttempts': policy.broadcastDecision.maxAttempts,
    'failureOutcome': policy.broadcastDecision.failureOutcome,
  },
  'replyConcurrency': policy.replyConcurrency,
  'autonomousChain': <String, Object?>{
    'maxDepth': policy.autonomousChainMaxDepth,
    'maxAgentMessagesPerRoot': policy.autonomousChainMaxAgentMessagesPerRoot,
  },
  'delivery': <String, Object?>{
    'defaultVisibility': policy.deliveryDefaultVisibility,
    'maxDepth': policy.deliveryMaxDepth,
    'maxDeliveriesPerTurn': policy.deliveryMaxDeliveriesPerTurn,
  },
};

ProjectResponsePolicy _responsePolicyFromJson(Map<String, Object?> json) {
  _requireKeys(json, const <String>{
    'schemaVersion',
    'broadcastDecision',
    'replyConcurrency',
    'autonomousChain',
    'delivery',
  }, 'response_policy_json');
  final broadcast = _object(json['broadcastDecision'], 'broadcastDecision');
  final chain = _object(json['autonomousChain'], 'autonomousChain');
  final delivery = _object(json['delivery'], 'delivery');
  _requireKeys(broadcast, const <String>{
    'concurrency',
    'maxInputTokens',
    'maxOutputTokens',
    'timeoutMs',
    'maxAttempts',
    'failureOutcome',
  }, 'response_policy_json.broadcastDecision');
  _requireKeys(chain, const <String>{
    'maxDepth',
    'maxAgentMessagesPerRoot',
  }, 'response_policy_json.autonomousChain');
  _requireKeys(delivery, const <String>{
    'defaultVisibility',
    'maxDepth',
    'maxDeliveriesPerTurn',
  }, 'response_policy_json.delivery');
  return ProjectResponsePolicy(
    schemaVersion: _integer(json['schemaVersion'], 'schemaVersion'),
    broadcastDecision: BroadcastDecisionPolicy(
      concurrency: _integer(broadcast['concurrency'], 'concurrency'),
      maxInputTokens: _integer(broadcast['maxInputTokens'], 'maxInputTokens'),
      maxOutputTokens: _integer(
        broadcast['maxOutputTokens'],
        'maxOutputTokens',
      ),
      timeout: Duration(
        milliseconds: _integer(broadcast['timeoutMs'], 'timeoutMs'),
      ),
      maxAttempts: _integer(broadcast['maxAttempts'], 'maxAttempts'),
      failureOutcome: _text(broadcast['failureOutcome'], 'failureOutcome'),
    ),
    replyConcurrency: _integer(json['replyConcurrency'], 'replyConcurrency'),
    autonomousChainMaxDepth: _integer(chain['maxDepth'], 'maxDepth'),
    autonomousChainMaxAgentMessagesPerRoot: _integer(
      chain['maxAgentMessagesPerRoot'],
      'maxAgentMessagesPerRoot',
    ),
    deliveryDefaultVisibility: _text(
      delivery['defaultVisibility'],
      'defaultVisibility',
    ),
    deliveryMaxDepth: _integer(delivery['maxDepth'], 'maxDepth'),
    deliveryMaxDeliveriesPerTurn: _integer(
      delivery['maxDeliveriesPerTurn'],
      'maxDeliveriesPerTurn',
    ),
  );
}

Map<String, Object?> _jsonObject(Object? raw, String field) {
  if (raw is! String) throw FormatException('$field must be JSON text.');
  return _object(jsonDecode(raw), field);
}

Map<String, Object?> _object(Object? raw, String field) {
  if (raw is! Map<Object?, Object?> || raw.keys.any((key) => key is! String)) {
    throw FormatException('$field must be a JSON object.');
  }
  return <String, Object?>{
    for (final entry in raw.entries) entry.key! as String: entry.value,
  };
}

void _requireKeys(
  Map<String, Object?> values,
  Set<String> required,
  String field,
) {
  if (values.keys.toSet().difference(required).isNotEmpty ||
      required.difference(values.keys.toSet()).isNotEmpty) {
    throw FormatException('$field does not match schema version 1.');
  }
}

List<String> _stringList(Object? value, String field) {
  if (value is! List<Object?> || value.any((item) => item is! String)) {
    throw FormatException('$field must be a string list.');
  }
  return List<String>.unmodifiable(value.cast<String>());
}

T _enumByName<T extends Enum>(List<T> values, String name, String field) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('$field has an unknown value.');
}

String _text(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('$field must be text.');
}

int _integer(Object? value, String field) {
  if (value is int) return value;
  throw FormatException('$field must be an integer.');
}

int? _nullableInteger(Object? value, String field) {
  if (value == null || value is int) return value as int?;
  throw FormatException('$field must be an integer or null.');
}

double _number(Object? value, String field) {
  if (value is num) return value.toDouble();
  throw FormatException('$field must be numeric.');
}

bool _boolean(Object? value, String field) {
  if (value is bool) return value;
  throw FormatException('$field must be a boolean.');
}

DateTime _date(Object? value, String field) =>
    DateTime.fromMillisecondsSinceEpoch(_integer(value, field));
