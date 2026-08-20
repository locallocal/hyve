import 'package:hyve/domain/models/agent_message_cursor.dart';
import 'package:hyve/domain/models/agent_message_receipt.dart';
import 'package:hyve/domain/models/participation_decision.dart';
import 'package:hyve/domain/models/project_event.dart';

final class AgentMessageCursorRecord {
  const AgentMessageCursorRecord(this.values);

  factory AgentMessageCursorRecord.fromDomain(AgentMessageCursor cursor) {
    return AgentMessageCursorRecord(<String, Object?>{
      'project_id': cursor.projectId,
      'agent_id': cursor.agentId,
      'last_processed_message_sequence': cursor.lastProcessedMessageSequence,
      'processing_message_sequence': cursor.processingMessageSequence,
      'worker_state': cursor.workerState.name,
      'active_run_id': cursor.activeRunId,
      'lease_owner': cursor.leaseOwner,
      'lease_expires_at': cursor.leaseExpiresAt?.millisecondsSinceEpoch,
      'last_error': cursor.lastError,
      'updated_at': cursor.updatedAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  AgentMessageCursor toDomain() => AgentMessageCursor(
    projectId: _text(values['project_id'], 'project_id'),
    agentId: _text(values['agent_id'], 'agent_id'),
    lastProcessedMessageSequence: _integer(
      values['last_processed_message_sequence'],
      'last_processed_message_sequence',
    ),
    processingMessageSequence: _nullableInteger(
      values['processing_message_sequence'],
      'processing_message_sequence',
    ),
    workerState: _enumByName(
      AgentInboxWorkerState.values,
      _text(values['worker_state'], 'worker_state'),
      'worker_state',
    ),
    activeRunId: _nullableText(values['active_run_id'], 'active_run_id'),
    leaseOwner: _text(values['lease_owner'], 'lease_owner'),
    leaseExpiresAt: _nullableDate(
      values['lease_expires_at'],
      'lease_expires_at',
    ),
    lastError: _text(values['last_error'], 'last_error'),
    updatedAt: _date(values['updated_at'], 'updated_at'),
  );
}

final class AgentMessageReceiptRecord {
  const AgentMessageReceiptRecord(this.values);

  factory AgentMessageReceiptRecord.fromDomain(AgentMessageReceipt receipt) {
    return AgentMessageReceiptRecord(<String, Object?>{
      'project_id': receipt.projectId,
      'agent_id': receipt.agentId,
      'message_sequence': receipt.messageSequence,
      'message_event_id': receipt.messageEventId,
      'turn_id': receipt.turnId,
      'outcome': receipt.outcome.name,
      'decision_run_id': receipt.decisionRunId,
      'reply_run_id': receipt.replyRunId,
      'reply_event_id': receipt.replyEventId,
      'started_at': receipt.startedAt?.millisecondsSinceEpoch,
      'completed_at': receipt.completedAt.millisecondsSinceEpoch,
      'error_code': receipt.errorCode,
    });
  }

  final Map<String, Object?> values;

  AgentMessageReceipt toDomain() => AgentMessageReceipt(
    projectId: _text(values['project_id'], 'project_id'),
    agentId: _text(values['agent_id'], 'agent_id'),
    messageSequence: _integer(values['message_sequence'], 'message_sequence'),
    messageEventId: _text(values['message_event_id'], 'message_event_id'),
    turnId: _text(values['turn_id'], 'turn_id'),
    outcome: _enumByName(
      AgentMessageReceiptOutcome.values,
      _text(values['outcome'], 'outcome'),
      'outcome',
    ),
    decisionRunId: _text(values['decision_run_id'], 'decision_run_id'),
    replyRunId: _text(values['reply_run_id'], 'reply_run_id'),
    replyEventId: _text(values['reply_event_id'], 'reply_event_id'),
    startedAt: _nullableDate(values['started_at'], 'started_at'),
    completedAt: _date(values['completed_at'], 'completed_at'),
    errorCode: _text(values['error_code'], 'error_code'),
  );
}

final class ParticipationDecisionRecord {
  const ParticipationDecisionRecord(this.values);

  factory ParticipationDecisionRecord.fromDomain(
    ParticipationDecision decision,
  ) => ParticipationDecisionRecord(<String, Object?>{
    'run_id': decision.runId,
    'agent_id': decision.agentId,
    'project_id': decision.projectId,
    'turn_id': decision.turnId,
    'message_sequence': decision.messageSequence,
    'choice': decision.choice.name,
    'reason_code': decision.reasonCode,
    'intended_contribution': decision.intendedContribution,
    'created_at': decision.createdAt.millisecondsSinceEpoch,
  });

  final Map<String, Object?> values;

  ParticipationDecision toDomain() => ParticipationDecision(
    runId: _text(values['run_id'], 'run_id'),
    agentId: _text(values['agent_id'], 'agent_id'),
    projectId: _text(values['project_id'], 'project_id'),
    turnId: _text(values['turn_id'], 'turn_id'),
    messageSequence: _integer(values['message_sequence'], 'message_sequence'),
    choice: _enumByName(
      ParticipationChoice.values,
      _text(values['choice'], 'choice'),
      'choice',
    ),
    reasonCode: _text(values['reason_code'], 'reason_code'),
    intendedContribution: _text(
      values['intended_contribution'],
      'intended_contribution',
    ),
    createdAt: _date(values['created_at'], 'created_at'),
  );
}

String _text(Object? value, String field) {
  if (value is! String) throw FormatException('$field must be text.');
  return value;
}

String? _nullableText(Object? value, String field) {
  if (value == null) return null;
  return _text(value, field);
}

int _integer(Object? value, String field) {
  if (value is! int) throw FormatException('$field must be an integer.');
  return value;
}

int? _nullableInteger(Object? value, String field) {
  if (value == null) return null;
  return _integer(value, field);
}

DateTime _date(Object? value, String field) =>
    DateTime.fromMillisecondsSinceEpoch(_integer(value, field));

DateTime? _nullableDate(Object? value, String field) {
  if (value == null) return null;
  return _date(value, field);
}

T _enumByName<T extends Enum>(List<T> values, String name, String field) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('$field has an unsupported value: $name.');
}
