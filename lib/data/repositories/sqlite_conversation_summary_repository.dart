import 'dart:async';

import 'package:hyve/data/models/conversation_summary_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/data/services/project_conversation_summary_storage.dart';
import 'package:hyve/domain/models/conversation_summary.dart';
import 'package:hyve/domain/models/project_event.dart';
import 'package:hyve/domain/repositories/conversation_summary_repository.dart';
import 'package:hyve/domain/repositories/project_event_repository.dart';
import 'package:hyve/domain/services/conversation_summary_source_digest.dart';

final class SqliteConversationSummaryRepository
    implements ConversationSummaryRepository {
  SqliteConversationSummaryRepository({
    required LocalDatabaseService localDatabase,
    required ProjectConversationSummaryStorage storage,
    required ProjectEventRepository eventRepository,
    ConversationSummarySourceDigest sourceDigest =
        const ConversationSummarySourceDigest(),
  }) : _localDatabase = localDatabase,
       _storage = storage,
       _eventRepository = eventRepository,
       _sourceDigest = sourceDigest;

  final LocalDatabaseService _localDatabase;
  final ProjectConversationSummaryStorage _storage;
  final ProjectEventRepository _eventRepository;
  final ConversationSummarySourceDigest _sourceDigest;
  final StreamController<String> _changes = StreamController.broadcast();

  @override
  Stream<String> get changes => _changes.stream;

  @override
  Future<ConversationSummaryState> getState(String projectId) async {
    final rows = await _localDatabase.loadConversationSummaryStateV19(
      projectId,
    );
    return rows.isEmpty
        ? ConversationSummaryState(
          projectId: projectId,
          updatedAt: DateTime.now(),
        )
        : ConversationSummaryStateRecord(rows.single).toDomain();
  }

  @override
  Future<List<ProjectConversationSummary>> getActiveRollingSummaries(
    String projectId, {
    required int throughMessageSequence,
  }) async {
    if (throughMessageSequence <= 0) return const [];
    final rows = await _localDatabase.loadActiveRollingSummariesV19(
      projectId,
      throughMessageSequence,
    );
    return _restoreUsable(rows);
  }

  @override
  Future<List<ProjectConversationSummary>> getRangeExtracts(
    String projectId, {
    int limit = 50,
  }) async {
    if (limit < 1 || limit > 200) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 200.');
    }
    return _restoreUsable(
      await _localDatabase.loadRangeConversationSummariesV19(
        projectId,
        limit: limit,
      ),
    );
  }

  @override
  Future<bool> commitRolling({
    required int expectedRevision,
    required ProjectConversationSummary summary,
  }) async {
    if (summary.segment.kind != ConversationSummaryKind.rolling) {
      throw ArgumentError('commitRolling accepts only rolling summaries.');
    }
    final stored = await _storage.write(
      projectId: summary.segment.projectId,
      segmentId: summary.segment.id,
      markdown: summary.markdown,
    );
    final segment = summary.segment.copyWith(
      fileName: stored.fileName,
      contentDigest: stored.contentDigest,
      contentBytes: stored.contentBytes,
    );
    try {
      final committed = await _localDatabase
          .commitRollingConversationSummaryV19(
            projectId: segment.projectId,
            expectedRevision: expectedRevision,
            segment:
                ConversationSummarySegmentRecord.fromDomain(segment).values,
          );
      if (!committed) {
        await _storage.delete(segment.projectId, segment.id);
        return false;
      }
      _emit(segment.projectId);
      return true;
    } on Object {
      await _storage.delete(segment.projectId, segment.id);
      rethrow;
    }
  }

  @override
  Future<void> saveRangeExtract(ProjectConversationSummary summary) async {
    if (summary.segment.kind != ConversationSummaryKind.rangeExtract) {
      throw ArgumentError('saveRangeExtract requires a rangeExtract summary.');
    }
    final stored = await _storage.write(
      projectId: summary.segment.projectId,
      segmentId: summary.segment.id,
      markdown: summary.markdown,
    );
    final segment = summary.segment.copyWith(
      fileName: stored.fileName,
      contentDigest: stored.contentDigest,
      contentBytes: stored.contentBytes,
    );
    try {
      await _localDatabase.saveRangeConversationSummaryV19(
        ConversationSummarySegmentRecord.fromDomain(segment).values,
      );
      _emit(segment.projectId);
    } on Object {
      await _storage.delete(segment.projectId, segment.id);
      rethrow;
    }
  }

  @override
  Future<void> setCompactionStatus(
    String projectId,
    ConversationSummaryCompactionStatus status, {
    String lastError = '',
  }) async {
    await _localDatabase.setConversationSummaryCompactionStatusV19(
      projectId,
      status.name,
      lastError,
    );
    _emit(projectId);
  }

  @override
  Future<void> markSourceRangeStale(
    String projectId, {
    required int startMessageSequence,
    required int endMessageSequence,
  }) async {
    if (startMessageSequence < 1 || endMessageSequence < startMessageSequence) {
      throw ArgumentError('Summary invalidation range is invalid.');
    }
    await _localDatabase.markConversationSummaryRangeStaleV19(
      projectId,
      startMessageSequence,
      endMessageSequence,
    );
    _emit(projectId);
  }

  @override
  Future<void> clear(String projectId) async {
    await _localDatabase.deleteConversationSummariesV19(projectId);
    await _storage.clear(projectId);
    _emit(projectId);
  }

  Future<List<ProjectConversationSummary>> _restoreUsable(
    Iterable<Map<String, Object?>> rows,
  ) async {
    final result = <ProjectConversationSummary>[];
    for (final row in rows) {
      final segment = ConversationSummarySegmentRecord(row).toDomain();
      final sourceEvents = await _loadSourceEvents(segment);
      if (sourceEvents == null ||
          _sourceDigest(sourceEvents) != segment.sourceDigest) {
        await _invalidate(segment, 'summary_source_digest_mismatch');
        continue;
      }
      try {
        result.add(
          ProjectConversationSummary(
            segment: segment,
            markdown: await _storage.read(segment),
          ),
        );
      } on Object {
        await _invalidate(segment, 'summary_content_integrity_failed');
      }
    }
    return List<ProjectConversationSummary>.unmodifiable(result);
  }

  Future<List<ProjectEvent>?> _loadSourceEvents(
    ConversationSummarySegment segment,
  ) async {
    final events = <ProjectEvent>[];
    for (
      var sequence = segment.sourceStartMessageSequence;
      sequence <= segment.sourceEndMessageSequence;
      sequence++
    ) {
      final event = await _eventRepository.getMessageAt(
        segment.projectId,
        sequence,
      );
      if (event == null) return null;
      events.add(event);
    }
    if (events.map((event) => event.id).toList().join('\u0000') !=
        segment.sourceEventIds.join('\u0000')) {
      return null;
    }
    return events;
  }

  Future<void> _invalidate(
    ConversationSummarySegment segment,
    String error,
  ) async {
    await _localDatabase.invalidateConversationSummaryV19(
      segment.projectId,
      segment.id,
      error,
    );
    _emit(segment.projectId);
  }

  void _emit(String projectId) {
    if (!_changes.isClosed) _changes.add(projectId);
  }

  Future<void> dispose() => _changes.close();
}
