import 'package:hyve/domain/models/conversation_summary.dart';

abstract interface class ConversationSummaryRepository {
  Stream<String> get changes;

  Future<ConversationSummaryState> getState(String projectId);

  Future<List<ProjectConversationSummary>> getActiveRollingSummaries(
    String projectId, {
    required int throughMessageSequence,
  });

  Future<List<ProjectConversationSummary>> getRangeExtracts(
    String projectId, {
    int limit = 50,
  });

  /// Commits one immutable segment and advances summary state with CAS.
  Future<bool> commitRolling({
    required int expectedRevision,
    required ProjectConversationSummary summary,
  });

  Future<void> saveRangeExtract(ProjectConversationSummary summary);

  Future<void> setCompactionStatus(
    String projectId,
    ConversationSummaryCompactionStatus status, {
    String lastError = '',
  });

  Future<void> markSourceRangeStale(
    String projectId, {
    required int startMessageSequence,
    required int endMessageSequence,
  });

  Future<void> clear(String projectId);
}
