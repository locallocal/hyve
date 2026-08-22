import 'dart:convert';

import 'package:hyve/domain/models/agent_memory.dart';

final class AgentMemoryEvolutionRunRecord {
  const AgentMemoryEvolutionRunRecord(this.values);

  factory AgentMemoryEvolutionRunRecord.fromDomain(
    AgentMemoryEvolutionRun run,
  ) => AgentMemoryEvolutionRunRecord(<String, Object?>{
    'id': run.id,
    'agent_id': run.agentId,
    'source_project_id': run.sourceProjectId,
    'source_event_ids_json': jsonEncode(run.sourceEventIds),
    'provider': run.provider,
    'model': run.model,
    'prompt_version': run.promptVersion,
    'input_digest': run.inputDigest,
    'input_count': run.inputCount,
    'result_count': run.resultCount,
    'input_token_count': run.inputTokenCount,
    'output_token_count': run.outputTokenCount,
    'status': run.status.name,
    'error_code': run.errorCode,
    'created_at': run.createdAt.millisecondsSinceEpoch,
    'completed_at': run.completedAt?.millisecondsSinceEpoch,
  });

  final Map<String, Object?> values;

  AgentMemoryEvolutionRun toDomain() {
    final idsSource = values['source_event_ids_json'];
    if (idsSource is! String) {
      throw const FormatException('Evolution source IDs must be JSON text.');
    }
    final ids = jsonDecode(idsSource);
    if (ids is! List<Object?> || ids.any((id) => id is! String)) {
      throw const FormatException('Evolution source IDs must be strings.');
    }
    final completedAt = _nullableInt(values['completed_at'], 'completed_at');
    return AgentMemoryEvolutionRun(
      id: _text(values['id'], 'id'),
      agentId: _text(values['agent_id'], 'agent_id'),
      sourceProjectId: _text(values['source_project_id'], 'source_project_id'),
      sourceEventIds: ids.cast<String>(),
      provider: _text(values['provider'], 'provider'),
      model: _text(values['model'], 'model'),
      promptVersion: _int(values['prompt_version'], 'prompt_version'),
      inputDigest: _text(values['input_digest'], 'input_digest'),
      inputCount: _int(values['input_count'], 'input_count'),
      resultCount: _int(values['result_count'], 'result_count'),
      inputTokenCount: _int(values['input_token_count'], 'input_token_count'),
      outputTokenCount: _int(
        values['output_token_count'],
        'output_token_count',
      ),
      status: _enumByName(
        AgentMemoryEvolutionStatus.values,
        _text(values['status'], 'status'),
      ),
      errorCode: _text(values['error_code'], 'error_code'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        _int(values['created_at'], 'created_at'),
      ),
      completedAt:
          completedAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(completedAt),
    );
  }
}

String _text(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('$field must be text.');
}

int _int(Object? value, String field) {
  if (value is int) return value;
  throw FormatException('$field must be an integer.');
}

int? _nullableInt(Object? value, String field) =>
    value == null ? null : _int(value, field);

T _enumByName<T extends Enum>(List<T> values, String name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw const FormatException('Evolution status is unknown.');
}
