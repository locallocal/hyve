import 'dart:convert';

import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_memory_repository.dart';

abstract final class AgentMemoryToolNames {
  static const search = 'agent.memory.search';
  static const read = 'agent.memory.read';
  static const propose = 'agent.memory.propose';
  static const forget = 'agent.memory.forget';

  static const readOnly = <String>{search, read};
  static const write = <String>{propose};
  static const destructive = <String>{forget};
  static const all = <String>{...readOnly, ...write, ...destructive};
}

/// Tools are constructed with a trusted run scope and never accept agentId.
final class AgentMemoryToolSet {
  AgentMemoryToolSet({
    required AgentMemoryRepository repository,
    required Agent agent,
    required String projectId,
    required String sourceEventId,
    required int sourceMessageSequence,
    required String sourceDigest,
    DateTime Function()? clock,
  }) : tools = List<ExecutableTool>.unmodifiable(<ExecutableTool>[
         for (final name in AgentMemoryToolNames.all)
           _AgentMemoryTool(
             name: name,
             repository: repository,
             agent: agent,
             projectId: projectId,
             sourceEventId: sourceEventId,
             sourceMessageSequence: sourceMessageSequence,
             sourceDigest: sourceDigest,
             clock: clock ?? DateTime.now,
           ),
       ]);

  final List<ExecutableTool> tools;
}

final class _AgentMemoryTool implements ExecutableTool {
  const _AgentMemoryTool({
    required String name,
    required AgentMemoryRepository repository,
    required Agent agent,
    required String projectId,
    required String sourceEventId,
    required int sourceMessageSequence,
    required String sourceDigest,
    required DateTime Function() clock,
  }) : _name = name,
       _repository = repository,
       _agent = agent,
       _projectId = projectId,
       _sourceEventId = sourceEventId,
       _sourceMessageSequence = sourceMessageSequence,
       _sourceDigest = sourceDigest,
       _clock = clock;

  final String _name;
  final AgentMemoryRepository _repository;
  final Agent _agent;
  final String _projectId;
  final String _sourceEventId;
  final int _sourceMessageSequence;
  final String _sourceDigest;
  final DateTime Function() _clock;

  @override
  ToolDefinition get definition => ToolDefinition(
    name: _name,
    title: switch (_name) {
      AgentMemoryToolNames.search => 'Search own long-term memory',
      AgentMemoryToolNames.read => 'Read own long-term memory',
      AgentMemoryToolNames.propose => 'Propose own long-term memory',
      AgentMemoryToolNames.forget => 'Forget own long-term memory',
      _ => 'Agent memory',
    },
    description:
        'Access only the current Agent private memory scope. Project memory '
        'does not exist and no arbitrary agentId is accepted.',
    inputSchema: _schema,
    outputSchema: const <String, Object?>{'type': 'object'},
    source: ToolSource.builtIn,
    riskLevel:
        AgentMemoryToolNames.destructive.contains(_name)
            ? ToolRiskLevel.destructive
            : AgentMemoryToolNames.write.contains(_name)
            ? ToolRiskLevel.write
            : ToolRiskLevel.readOnly,
    capabilities: <ToolCapability>{
      AgentMemoryToolNames.readOnly.contains(_name)
          ? ToolCapability.localRead
          : ToolCapability.localWrite,
    },
  );

  Map<String, Object?> get _schema => switch (_name) {
    AgentMemoryToolNames.search => const <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'query': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 1024,
        },
      },
      'required': <String>['query'],
      'additionalProperties': false,
    },
    AgentMemoryToolNames.read ||
    AgentMemoryToolNames.forget => const <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'memoryId': <String, Object?>{'type': 'string', 'minLength': 1},
      },
      'required': <String>['memoryId'],
      'additionalProperties': false,
    },
    AgentMemoryToolNames.propose => const <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'memoryKey': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 256,
        },
        'kind': <String, Object?>{
          'type': 'string',
          'enum': <String>[
            'userPreference',
            'learnedPattern',
            'capabilityNote',
            'relationship',
            'fact',
            'reflection',
          ],
        },
        'content': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 4096,
        },
        'sensitivity': <String, Object?>{
          'type': 'string',
          'enum': <String>['normal', 'private'],
          'default': 'normal',
        },
        'importance': <String, Object?>{
          'type': 'number',
          'minimum': 0,
          'maximum': 1,
          'default': 0.5,
        },
        'confidence': <String, Object?>{
          'type': 'number',
          'minimum': 0,
          'maximum': 1,
          'default': 0.5,
        },
      },
      'required': <String>['memoryKey', 'kind', 'content'],
      'additionalProperties': false,
    },
    _ => const <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
    },
  };

  @override
  Future<ToolResult> execute(
    ToolCallRequest call,
    AgentCancellationToken cancellationToken,
  ) async {
    cancellationToken.throwIfCancelled();
    try {
      final result = switch (_name) {
        AgentMemoryToolNames.search => await _search(call.arguments),
        AgentMemoryToolNames.read => await _read(call.arguments),
        AgentMemoryToolNames.propose => await _propose(call.arguments),
        AgentMemoryToolNames.forget => await _forget(call.arguments),
        _ => throw StateError('Unknown Agent memory tool.'),
      };
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content: jsonEncode(result),
        structuredContent: result,
      );
    } on AgentMemorySecretLikeException catch (error) {
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'Secret-like content was rejected.',
        isError: true,
        errorCode: error.errorCode,
      );
    }
  }

  Future<Map<String, Object?>> _search(Map<String, Object?> arguments) async {
    final policy = _agent.memoryPolicy.retrieval;
    final result = await _repository.search(
      AgentMemorySearchRequest(
        agentId: _agent.id,
        query: arguments['query']! as String,
        currentProjectId: _projectId,
        contextThroughMessageSequence: _sourceMessageSequence,
        maxItems: policy.maxItems,
        tokenBudget: policy.tokenBudget,
        minConfidence: policy.minConfidence,
        sourceProjectExists: (id) => id == _projectId,
      ),
    );
    return <String, Object?>{
      'revision': result.revision,
      'items': <Map<String, Object?>>[
        for (final item in result.items)
          <String, Object?>{
            'id': item.id,
            'memoryKey': item.memoryKey,
            'kind': item.kind.name,
            'content': _bounded(item.content),
            'reuseScope': item.reuseScope.name,
            'confidence': item.confidence,
          },
      ],
    };
  }

  Future<Map<String, Object?>> _read(Map<String, Object?> arguments) async {
    final memory = await _repository.read(
      _agent.id,
      arguments['memoryId']! as String,
    );
    if (memory == null || memory.state != AgentMemoryState.active) {
      throw StateError('Agent memory was not found.');
    }
    return <String, Object?>{
      'id': memory.id,
      'memoryKey': memory.memoryKey,
      'kind': memory.kind.name,
      'content': _bounded(memory.content),
      'reuseScope': memory.reuseScope.name,
      'version': memory.version,
    };
  }

  Future<Map<String, Object?>> _propose(Map<String, Object?> arguments) async {
    final kind = AgentMemoryKind.values.byName(arguments['kind']! as String);
    final sensitivity = AgentMemorySensitivity.values.byName(
      arguments['sensitivity'] as String? ?? 'normal',
    );
    final confidence = (arguments['confidence'] as num? ?? 0.5).toDouble();
    final crossProject = _agent.memoryPolicy.autoCrossProjectKinds.contains(
      kind.name,
    );
    final approval =
        crossProject &&
        (sensitivity == AgentMemorySensitivity.private ||
            confidence < _agent.memoryPolicy.retrieval.minConfidence);
    final scope =
        !crossProject
            ? AgentMemoryReuseScope.sourceProjectOnly
            : approval
            ? AgentMemoryReuseScope.userApproved
            : AgentMemoryReuseScope.crossProject;
    final now = _clock();
    final mutation = await _repository.propose(
      AgentMemory(
        id: 'memory_${now.microsecondsSinceEpoch}',
        agentId: _agent.id,
        memoryKey: arguments['memoryKey']! as String,
        kind: kind,
        content: arguments['content']! as String,
        state: approval ? AgentMemoryState.candidate : AgentMemoryState.active,
        reuseScope: scope,
        sensitivity: sensitivity,
        importance: (arguments['importance'] as num? ?? 0.5).toDouble(),
        confidence: confidence,
        sourceProjectId: _projectId,
        sourceEventIds: <String>[_sourceEventId],
        sourceMessageSequence: _sourceMessageSequence,
        sourceDigest: _sourceDigest,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return <String, Object?>{
      'id': mutation.memory.id,
      'state': mutation.memory.state.name,
      'reuseScope': mutation.memory.reuseScope.name,
      'version': mutation.memory.version,
      'revision': mutation.revision,
      'changed': mutation.changed,
    };
  }

  Future<Map<String, Object?>> _forget(Map<String, Object?> arguments) async {
    final result = await _repository.forget(
      agentId: _agent.id,
      memoryId: arguments['memoryId']! as String,
    );
    return <String, Object?>{
      'id': result.memory.id,
      'state': result.memory.state.name,
      'revision': result.revision,
    };
  }
}

String _bounded(String content) {
  const limit = 8192;
  return content.length <= limit
      ? content
      : '${content.substring(0, limit)}\n[Agent memory truncated]';
}
