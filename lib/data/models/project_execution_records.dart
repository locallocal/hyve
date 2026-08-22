import 'dart:convert';

import 'package:hyve/domain/models/agent_delivery.dart';
import 'package:hyve/domain/models/agent_run.dart';
import 'package:hyve/domain/models/project_event.dart';
import 'package:hyve/domain/models/project_turn.dart';

final class ProjectEventRecord {
  const ProjectEventRecord(this.values);

  factory ProjectEventRecord.fromDomain(ProjectEvent event) {
    return ProjectEventRecord(<String, Object?>{
      'id': event.id,
      'project_id': event.projectId,
      'turn_id': event.turnId,
      'run_id': event.runId,
      'sequence': event.sequence,
      'message_sequence': event.messageSequence,
      'event_type': event.eventType.name,
      'actor_type': event.actorType.name,
      'actor_id': event.actorId,
      'actor_name_snapshot': event.actorNameSnapshot,
      'actor_avatar_snapshot': event.actorAvatarSnapshot,
      'visibility': event.visibility.name,
      'reply_to_event_id': event.replyToEventId,
      'reply_to_message_sequence': event.replyToMessageSequence,
      'root_message_id': event.rootMessageId,
      'autonomous_depth': event.autonomousDepth,
      'content': event.content,
      'payload_json': jsonEncode(_payloadToJson(event.payload)),
      'terminal_state': event.terminalState.name,
      'has_partial_content': event.hasPartialContent ? 1 : 0,
      'created_at': event.createdAt.millisecondsSinceEpoch,
      'updated_at': event.updatedAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  ProjectEvent toDomain({Iterable<String> targetAgentIds = const []}) {
    final type = _enumByName(
      ProjectEventType.values,
      _text(values['event_type'], 'event_type'),
      'event_type',
    );
    return ProjectEvent(
      id: _text(values['id'], 'id'),
      projectId: _text(values['project_id'], 'project_id'),
      turnId: _text(values['turn_id'], 'turn_id'),
      runId: _text(values['run_id'], 'run_id'),
      sequence: _integer(values['sequence'], 'sequence'),
      messageSequence: _nullableInteger(
        values['message_sequence'],
        'message_sequence',
      ),
      eventType: type,
      actorType: _enumByName(
        ProjectEventActorType.values,
        _text(values['actor_type'], 'actor_type'),
        'actor_type',
      ),
      actorId: _text(values['actor_id'], 'actor_id'),
      actorNameSnapshot: _text(
        values['actor_name_snapshot'],
        'actor_name_snapshot',
      ),
      actorAvatarSnapshot: _text(
        values['actor_avatar_snapshot'],
        'actor_avatar_snapshot',
      ),
      visibility: _enumByName(
        ProjectEventVisibility.values,
        _text(values['visibility'], 'visibility'),
        'visibility',
      ),
      replyToEventId: _text(values['reply_to_event_id'], 'reply_to_event_id'),
      replyToMessageSequence: _nullableInteger(
        values['reply_to_message_sequence'],
        'reply_to_message_sequence',
      ),
      rootMessageId: _text(values['root_message_id'], 'root_message_id'),
      autonomousDepth: _integer(values['autonomous_depth'], 'autonomous_depth'),
      content: _text(values['content'], 'content'),
      payload: _payloadFromJson(
        type,
        _jsonObject(values['payload_json'], 'payload_json'),
      ),
      terminalState: _enumByName(
        ProjectEventTerminalState.values,
        _text(values['terminal_state'], 'terminal_state'),
        'terminal_state',
      ),
      hasPartialContent: _storageBool(
        values['has_partial_content'],
        'has_partial_content',
      ),
      targetAgentIds: targetAgentIds,
      createdAt: _date(values['created_at'], 'created_at'),
      updatedAt: _date(values['updated_at'], 'updated_at'),
    );
  }
}

final class ProjectTurnRecord {
  const ProjectTurnRecord(this.values);

  factory ProjectTurnRecord.fromDomain(ProjectTurn turn) {
    return ProjectTurnRecord(<String, Object?>{
      'id': turn.id,
      'project_id': turn.projectId,
      'root_event_id': turn.rootEventId,
      'initiator_type': turn.initiatorType.name,
      'initiator_id': turn.initiatorId,
      'routing_mode': turn.routingMode.name,
      'source_message_id': turn.sourceMessageId,
      'source_message_sequence': turn.sourceMessageSequence,
      'recipient_count': turn.recipientCount,
      'root_turn_id': turn.rootTurnId,
      'autonomous_depth': turn.autonomousDepth,
      'status': turn.status.name,
      'no_participant': turn.noParticipant ? 1 : 0,
      'created_at': turn.createdAt.millisecondsSinceEpoch,
      'completed_at': turn.completedAt?.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  ProjectTurn toDomain() {
    return ProjectTurn(
      id: _text(values['id'], 'id'),
      projectId: _text(values['project_id'], 'project_id'),
      rootEventId: _text(values['root_event_id'], 'root_event_id'),
      initiatorType: _enumByName(
        ProjectTurnInitiatorType.values,
        _text(values['initiator_type'], 'initiator_type'),
        'initiator_type',
      ),
      initiatorId: _text(values['initiator_id'], 'initiator_id'),
      routingMode: _enumByName(
        ProjectTurnRoutingMode.values,
        _text(values['routing_mode'], 'routing_mode'),
        'routing_mode',
      ),
      sourceMessageId: _text(values['source_message_id'], 'source_message_id'),
      sourceMessageSequence: _integer(
        values['source_message_sequence'],
        'source_message_sequence',
      ),
      recipientCount: _integer(values['recipient_count'], 'recipient_count'),
      rootTurnId: _text(values['root_turn_id'], 'root_turn_id'),
      autonomousDepth: _integer(values['autonomous_depth'], 'autonomous_depth'),
      status: _enumByName(
        ProjectTurnStatus.values,
        _text(values['status'], 'status'),
        'status',
      ),
      noParticipant: _storageBool(values['no_participant'], 'no_participant'),
      createdAt: _date(values['created_at'], 'created_at'),
      completedAt: _nullableDate(values['completed_at'], 'completed_at'),
    );
  }
}

final class AgentRunRecord {
  const AgentRunRecord(this.values);

  factory AgentRunRecord.fromDomain(AgentRun run) {
    return AgentRunRecord(<String, Object?>{
      'id': run.id,
      'project_id': run.projectId,
      'turn_id': run.turnId,
      'agent_id': run.agentId,
      'source_message_event_id': run.sourceMessageEventId,
      'source_message_sequence': run.sourceMessageSequence,
      'context_through_message_sequence': run.contextThroughMessageSequence,
      'parent_run_id': run.parentRunId,
      'root_run_id': run.rootRunId,
      'delivery_depth': run.deliveryDepth,
      'phase': run.phase.name,
      'status': run.status.name,
      'agent_snapshot_json': jsonEncode(<String, Object?>{
        'agentName': run.agentSnapshot.agentName,
        'provider': run.agentSnapshot.provider,
        'model': run.agentSnapshot.model,
        'systemPromptDigest': run.agentSnapshot.systemPromptDigest,
        'capabilityDigest': run.agentSnapshot.capabilityDigest,
      }),
      'context_report_json': jsonEncode(<String, Object?>{
        'conversationSummarySegmentIds':
            run.contextReport.conversationSummarySegmentIds,
        'agentMemoryIds': run.contextReport.agentMemoryIds,
        'projectArtifactVersionIds':
            run.contextReport.projectArtifactVersionIds,
        'skillDigests': run.contextReport.skillDigests,
        'toolNames': run.contextReport.toolNames,
        'agentMemoryRevision': run.contextReport.agentMemoryRevision,
        'coveredThroughMessageSequence':
            run.contextReport.coveredThroughMessageSequence,
      }),
      'started_at': run.startedAt?.millisecondsSinceEpoch,
      'completed_at': run.completedAt?.millisecondsSinceEpoch,
      'error_code': run.errorCode,
      'created_at': run.createdAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  AgentRun toDomain() {
    final snapshot = _jsonObject(
      values['agent_snapshot_json'],
      'agent_snapshot_json',
    );
    _requireExactKeys(snapshot, const <String>{
      'agentName',
      'provider',
      'model',
      'systemPromptDigest',
      'capabilityDigest',
    }, 'agent_snapshot_json');
    final contextReport = _jsonObject(
      values['context_report_json'],
      'context_report_json',
    );
    _requireExactKeys(contextReport, const <String>{
      'conversationSummarySegmentIds',
      'agentMemoryIds',
      'projectArtifactVersionIds',
      'skillDigests',
      'toolNames',
      'agentMemoryRevision',
      'coveredThroughMessageSequence',
    }, 'context_report_json');
    return AgentRun(
      id: _text(values['id'], 'id'),
      projectId: _text(values['project_id'], 'project_id'),
      turnId: _text(values['turn_id'], 'turn_id'),
      agentId: _text(values['agent_id'], 'agent_id'),
      sourceMessageEventId: _text(
        values['source_message_event_id'],
        'source_message_event_id',
      ),
      sourceMessageSequence: _integer(
        values['source_message_sequence'],
        'source_message_sequence',
      ),
      contextThroughMessageSequence: _integer(
        values['context_through_message_sequence'],
        'context_through_message_sequence',
      ),
      parentRunId: _text(values['parent_run_id'], 'parent_run_id'),
      rootRunId: _text(values['root_run_id'], 'root_run_id'),
      deliveryDepth: _integer(values['delivery_depth'], 'delivery_depth'),
      phase: _enumByName(
        AgentRunPhase.values,
        _text(values['phase'], 'phase'),
        'phase',
      ),
      status: _enumByName(
        AgentRunStatus.values,
        _text(values['status'], 'status'),
        'status',
      ),
      agentSnapshot: AgentRunSnapshot(
        agentName: _text(snapshot['agentName'], 'agentName'),
        provider: _text(snapshot['provider'], 'provider'),
        model: _text(snapshot['model'], 'model'),
        systemPromptDigest: _text(
          snapshot['systemPromptDigest'],
          'systemPromptDigest',
        ),
        capabilityDigest: _text(
          snapshot['capabilityDigest'],
          'capabilityDigest',
        ),
      ),
      startedAt: _nullableDate(values['started_at'], 'started_at'),
      completedAt: _nullableDate(values['completed_at'], 'completed_at'),
      errorCode: _text(values['error_code'], 'error_code'),
      contextReport: AgentRunContextReport(
        conversationSummarySegmentIds: _stringList(
          contextReport['conversationSummarySegmentIds'],
          'conversationSummarySegmentIds',
        ),
        agentMemoryIds: _stringList(
          contextReport['agentMemoryIds'],
          'agentMemoryIds',
        ),
        projectArtifactVersionIds: _stringList(
          contextReport['projectArtifactVersionIds'],
          'projectArtifactVersionIds',
        ),
        skillDigests: _stringList(
          contextReport['skillDigests'],
          'skillDigests',
        ),
        toolNames: _stringList(contextReport['toolNames'], 'toolNames'),
        agentMemoryRevision: _integer(
          contextReport['agentMemoryRevision'],
          'agentMemoryRevision',
        ),
        coveredThroughMessageSequence: _integer(
          contextReport['coveredThroughMessageSequence'],
          'coveredThroughMessageSequence',
        ),
      ),
      createdAt: _date(values['created_at'], 'created_at'),
    );
  }
}

final class AgentDeliveryRecord {
  const AgentDeliveryRecord(this.values);

  factory AgentDeliveryRecord.fromDomain(AgentDelivery delivery) {
    return AgentDeliveryRecord(<String, Object?>{
      'event_id': delivery.eventId,
      'source_run_id': delivery.sourceRunId,
      'source_agent_id': delivery.sourceAgentId,
      'kind': delivery.kind.name,
      'summary': delivery.summary,
      'payload': delivery.payload,
      'visibility': delivery.visibility.name,
      'request_public_reply': delivery.requestPublicReply ? 1 : 0,
      'root_turn_id': delivery.rootTurnId,
      'depth': delivery.depth,
      'payload_digest': delivery.payloadDigest,
    });
  }

  final Map<String, Object?> values;

  AgentDelivery toDomain({
    required String deliveryRunId,
    Iterable<String> targetAgentIds = const <String>[],
    Iterable<String> projectArtifactVersionIds = const <String>[],
  }) {
    return AgentDelivery(
      eventId: _text(values['event_id'], 'event_id'),
      deliveryRunId: deliveryRunId,
      sourceRunId: _text(values['source_run_id'], 'source_run_id'),
      sourceAgentId: _text(values['source_agent_id'], 'source_agent_id'),
      kind: _enumByName(
        AgentDeliveryKind.values,
        _text(values['kind'], 'kind'),
        'kind',
      ),
      summary: _text(values['summary'], 'summary'),
      payload: _text(values['payload'], 'payload'),
      visibility: _enumByName(
        AgentDeliveryVisibility.values,
        _text(values['visibility'], 'visibility'),
        'visibility',
      ),
      requestPublicReply: _storageBool(
        values['request_public_reply'],
        'request_public_reply',
      ),
      rootTurnId: _text(values['root_turn_id'], 'root_turn_id'),
      depth: _integer(values['depth'], 'depth'),
      payloadDigest: _text(values['payload_digest'], 'payload_digest'),
      targetAgentIds: targetAgentIds,
      projectArtifactVersionIds: projectArtifactVersionIds,
    );
  }
}

Map<String, Object?> _payloadToJson(ProjectEventPayload payload) {
  return switch (payload) {
    ProjectMessagePayload(
      :final reasoning,
      :final processInfoJson,
      :final images,
      :final files,
      :final projectArtifactVersionIds,
      :final audio,
      :final music,
      :final video,
    ) =>
      <String, Object?>{
        'reasoning': reasoning,
        'processInfoJson': processInfoJson,
        'images': images,
        'files': files,
        'projectArtifactVersionIds': projectArtifactVersionIds,
        'audio': audio,
        'music': music,
        'video': video,
      },
    ParticipationDecisionPayload(
      :final choice,
      :final reasonCode,
      :final intendedContribution,
    ) =>
      <String, Object?>{
        'choice': choice.name,
        'reasonCode': reasonCode,
        'intendedContribution': intendedContribution,
      },
    AgentDeliveryPayload(
      :final kind,
      :final summary,
      :final payload,
      :final projectArtifactVersionIds,
      :final requestPublicReply,
    ) =>
      <String, Object?>{
        'kind': kind.name,
        'summary': summary,
        'payload': payload,
        'projectArtifactVersionIds': projectArtifactVersionIds,
        'requestPublicReply': requestPublicReply,
      },
    MembershipChangedPayload(
      :final agentId,
      :final previousStatus,
      :final currentStatus,
    ) =>
      <String, Object?>{
        'agentId': agentId,
        'previousStatus': previousStatus,
        'currentStatus': currentStatus,
      },
    ProjectArtifactChangedPayload(
      :final artifactId,
      :final versionId,
      :final changeKind,
    ) =>
      <String, Object?>{
        'artifactId': artifactId,
        'versionId': versionId,
        'changeKind': changeKind,
      },
    RunStatusChangedPayload(
      :final runId,
      :final phase,
      :final status,
      :final errorCode,
    ) =>
      <String, Object?>{
        'runId': runId,
        'phase': phase,
        'status': status,
        'errorCode': errorCode,
      },
    SystemNoticePayload(:final code, :final detail) => <String, Object?>{
      'code': code,
      'detail': detail,
    },
  };
}

ProjectEventPayload _payloadFromJson(
  ProjectEventType type,
  Map<String, Object?> values,
) {
  return switch (type) {
    ProjectEventType.userMessage || ProjectEventType.agentMessage => () {
      _requireExactKeys(values, const {
        'reasoning',
        'processInfoJson',
        'images',
        'files',
        'projectArtifactVersionIds',
        'audio',
        'music',
        'video',
      }, 'message payload');
      return ProjectMessagePayload(
        reasoning: _text(values['reasoning'], 'reasoning'),
        processInfoJson: _text(values['processInfoJson'], 'processInfoJson'),
        images: _stringList(values['images'], 'images'),
        files: _stringList(values['files'], 'files'),
        projectArtifactVersionIds: _stringList(
          values['projectArtifactVersionIds'],
          'projectArtifactVersionIds',
        ),
        audio: _text(values['audio'], 'audio'),
        music: _text(values['music'], 'music'),
        video: _text(values['video'], 'video'),
      );
    }(),
    ProjectEventType.participationDecision => () {
      _requireExactKeys(values, const {
        'choice',
        'reasonCode',
        'intendedContribution',
      }, 'participation payload');
      return ParticipationDecisionPayload(
        choice: _enumByName(
          ParticipationChoice.values,
          _text(values['choice'], 'choice'),
          'choice',
        ),
        reasonCode: _text(values['reasonCode'], 'reasonCode'),
        intendedContribution: _text(
          values['intendedContribution'],
          'intendedContribution',
        ),
      );
    }(),
    ProjectEventType.agentDelivery => () {
      _requireExactKeys(values, const {
        'kind',
        'summary',
        'payload',
        'projectArtifactVersionIds',
        'requestPublicReply',
      }, 'delivery payload');
      return AgentDeliveryPayload(
        kind: _enumByName(
          AgentDeliveryKind.values,
          _text(values['kind'], 'kind'),
          'kind',
        ),
        summary: _text(values['summary'], 'summary'),
        payload: _text(values['payload'], 'payload'),
        projectArtifactVersionIds: _stringList(
          values['projectArtifactVersionIds'],
          'projectArtifactVersionIds',
        ),
        requestPublicReply: _boolean(
          values['requestPublicReply'],
          'requestPublicReply',
        ),
      );
    }(),
    ProjectEventType.membershipChanged => () {
      _requireExactKeys(values, const {
        'agentId',
        'previousStatus',
        'currentStatus',
      }, 'membership payload');
      return MembershipChangedPayload(
        agentId: _text(values['agentId'], 'agentId'),
        previousStatus: _text(values['previousStatus'], 'previousStatus'),
        currentStatus: _text(values['currentStatus'], 'currentStatus'),
      );
    }(),
    ProjectEventType.projectArtifactChanged => () {
      _requireExactKeys(values, const {
        'artifactId',
        'versionId',
        'changeKind',
      }, 'artifact payload');
      return ProjectArtifactChangedPayload(
        artifactId: _text(values['artifactId'], 'artifactId'),
        versionId: _text(values['versionId'], 'versionId'),
        changeKind: _text(values['changeKind'], 'changeKind'),
      );
    }(),
    ProjectEventType.runStatusChanged => () {
      _requireExactKeys(values, const {
        'runId',
        'phase',
        'status',
        'errorCode',
      }, 'run status payload');
      return RunStatusChangedPayload(
        runId: _text(values['runId'], 'runId'),
        phase: _text(values['phase'], 'phase'),
        status: _text(values['status'], 'status'),
        errorCode: _text(values['errorCode'], 'errorCode'),
      );
    }(),
    ProjectEventType.systemNotice => () {
      _requireExactKeys(values, const {'code', 'detail'}, 'notice payload');
      return SystemNoticePayload(
        code: _text(values['code'], 'code'),
        detail: _text(values['detail'], 'detail'),
      );
    }(),
  };
}

Map<String, Object?> _jsonObject(Object? raw, String field) {
  if (raw is! String) throw FormatException('$field must be JSON text.');
  final decoded = jsonDecode(raw);
  if (decoded is! Map<Object?, Object?> ||
      decoded.keys.any((key) => key is! String)) {
    throw FormatException('$field must be a JSON object.');
  }
  return <String, Object?>{
    for (final entry in decoded.entries) entry.key! as String: entry.value,
  };
}

void _requireExactKeys(
  Map<String, Object?> values,
  Set<String> keys,
  String field,
) {
  if (values.keys.toSet().difference(keys).isNotEmpty ||
      keys.difference(values.keys.toSet()).isNotEmpty) {
    throw FormatException('$field contains unexpected or missing fields.');
  }
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

bool _boolean(Object? value, String field) {
  if (value is bool) return value;
  throw FormatException('$field must be a boolean.');
}

List<String> _stringList(Object? value, String field) {
  if (value is! List<Object?> || value.any((item) => item is! String)) {
    throw FormatException('$field must be a string list.');
  }
  return List<String>.unmodifiable(value.cast<String>());
}

bool _storageBool(Object? value, String field) => switch (value) {
  0 => false,
  1 => true,
  _ => throw FormatException('$field must be 0 or 1.'),
};

DateTime _date(Object? value, String field) =>
    DateTime.fromMillisecondsSinceEpoch(_integer(value, field));

DateTime? _nullableDate(Object? value, String field) {
  final timestamp = _nullableInteger(value, field);
  return timestamp == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(timestamp);
}
