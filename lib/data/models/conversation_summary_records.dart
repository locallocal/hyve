import 'dart:convert';

import 'package:hyve/domain/models/conversation_summary.dart';

final class ConversationSummaryStateRecord {
  const ConversationSummaryStateRecord(this.values);

  final Map<String, Object?> values;

  ConversationSummaryState toDomain() {
    final compactedAt = _nullableInteger(
      values['last_compacted_at'],
      'last_compacted_at',
    );
    return ConversationSummaryState(
      projectId: _text(values['project_id'], 'project_id'),
      revision: _integer(values['revision'], 'revision'),
      activeSummarySetId: _text(
        values['active_summary_set_id'],
        'active_summary_set_id',
      ),
      coveredThroughMessageSequence: _integer(
        values['covered_through_message_sequence'],
        'covered_through_message_sequence',
      ),
      compactionStatus: _enumByName(
        ConversationSummaryCompactionStatus.values,
        _text(values['compaction_status'], 'compaction_status'),
        'compaction_status',
      ),
      lastError: _text(values['last_error'], 'last_error'),
      lastCompactedAt:
          compactedAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(compactedAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        _integer(values['updated_at'], 'updated_at'),
      ),
    );
  }
}

final class ConversationSummarySegmentRecord {
  const ConversationSummarySegmentRecord(this.values);

  factory ConversationSummarySegmentRecord.fromDomain(
    ConversationSummarySegment segment,
  ) {
    return ConversationSummarySegmentRecord(<String, Object?>{
      'id': segment.id,
      'project_id': segment.projectId,
      'summary_set_id': segment.summarySetId,
      'source_start_message_sequence': segment.sourceStartMessageSequence,
      'source_end_message_sequence': segment.sourceEndMessageSequence,
      'summary_kind': segment.kind.name,
      'source_event_ids_json': jsonEncode(segment.sourceEventIds),
      'source_digest': segment.sourceDigest,
      'summary_file_name': segment.fileName,
      'summary_content_digest': segment.contentDigest,
      'summary_content_bytes': segment.contentBytes,
      'estimated_token_count': segment.estimatedTokenCount,
      'provider': segment.provider,
      'model': segment.model,
      'prompt_version': segment.promptVersion,
      'status': segment.status.name,
      'created_at': segment.createdAt.millisecondsSinceEpoch,
      'updated_at': segment.updatedAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  ConversationSummarySegment toDomain() {
    return ConversationSummarySegment(
      id: _text(values['id'], 'id'),
      projectId: _text(values['project_id'], 'project_id'),
      summarySetId: _text(values['summary_set_id'], 'summary_set_id'),
      sourceStartMessageSequence: _integer(
        values['source_start_message_sequence'],
        'source_start_message_sequence',
      ),
      sourceEndMessageSequence: _integer(
        values['source_end_message_sequence'],
        'source_end_message_sequence',
      ),
      kind: _enumByName(
        ConversationSummaryKind.values,
        _text(values['summary_kind'], 'summary_kind'),
        'summary_kind',
      ),
      sourceEventIds: _stringList(
        values['source_event_ids_json'],
        'source_event_ids_json',
      ),
      sourceDigest: _text(values['source_digest'], 'source_digest'),
      fileName: _text(values['summary_file_name'], 'summary_file_name'),
      contentDigest: _text(
        values['summary_content_digest'],
        'summary_content_digest',
      ),
      contentBytes: _integer(
        values['summary_content_bytes'],
        'summary_content_bytes',
      ),
      estimatedTokenCount: _integer(
        values['estimated_token_count'],
        'estimated_token_count',
      ),
      provider: _text(values['provider'], 'provider'),
      model: _text(values['model'], 'model'),
      promptVersion: _integer(values['prompt_version'], 'prompt_version'),
      status: _enumByName(
        ConversationSummarySegmentStatus.values,
        _text(values['status'], 'status'),
        'status',
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        _integer(values['created_at'], 'created_at'),
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        _integer(values['updated_at'], 'updated_at'),
      ),
    );
  }
}

String _text(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('$field must be text.');
}

int _integer(Object? value, String field) {
  if (value is int) return value;
  throw FormatException('$field must be an integer.');
}

int? _nullableInteger(Object? value, String field) =>
    value == null ? null : _integer(value, field);

List<String> _stringList(Object? source, String field) {
  if (source is! String) throw FormatException('$field must be JSON text.');
  final decoded = jsonDecode(source);
  if (decoded is! List<Object?> || decoded.any((item) => item is! String)) {
    throw FormatException('$field must contain a string list.');
  }
  return List<String>.unmodifiable(decoded.cast<String>());
}

T _enumByName<T extends Enum>(List<T> values, String name, String field) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('$field contains an unknown enum value.');
}
