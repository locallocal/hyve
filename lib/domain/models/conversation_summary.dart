enum ConversationSummaryKind { rolling, rangeExtract }

enum ConversationSummarySegmentStatus {
  pending,
  active,
  superseded,
  stale,
  invalid,
}

enum ConversationSummaryCompactionStatus {
  idle,
  background,
  synchronous,
  failed,
}

final class ConversationSummaryState {
  const ConversationSummaryState({
    required this.projectId,
    this.revision = 0,
    this.activeSummarySetId = '',
    this.coveredThroughMessageSequence = 0,
    this.compactionStatus = ConversationSummaryCompactionStatus.idle,
    this.lastError = '',
    this.lastCompactedAt,
    required this.updatedAt,
  }) : assert(revision >= 0),
       assert(coveredThroughMessageSequence >= 0);

  final String projectId;
  final int revision;
  final String activeSummarySetId;
  final int coveredThroughMessageSequence;
  final ConversationSummaryCompactionStatus compactionStatus;
  final String lastError;
  final DateTime? lastCompactedAt;
  final DateTime updatedAt;
}

/// Immutable metadata for a summary whose body lives below the Project root.
final class ConversationSummarySegment {
  ConversationSummarySegment({
    required this.id,
    required this.projectId,
    required this.summarySetId,
    required this.sourceStartMessageSequence,
    required this.sourceEndMessageSequence,
    required this.kind,
    required Iterable<String> sourceEventIds,
    required this.sourceDigest,
    required this.fileName,
    required this.contentDigest,
    this.contentBytes = 0,
    this.estimatedTokenCount = 0,
    this.provider = '',
    this.model = '',
    this.promptVersion = 1,
    this.status = ConversationSummarySegmentStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  }) : sourceEventIds = List<String>.unmodifiable(sourceEventIds) {
    if (id.trim().isEmpty ||
        projectId.trim().isEmpty ||
        summarySetId.trim().isEmpty) {
      throw ArgumentError('Summary identity fields cannot be empty.');
    }
    if (sourceStartMessageSequence < 1 ||
        sourceEndMessageSequence < sourceStartMessageSequence) {
      throw ArgumentError('Summary source range must be positive and ordered.');
    }
    if (sourceEventIds.isEmpty) {
      throw ArgumentError('A summary must identify its source events.');
    }
    if (promptVersion < 1 || contentBytes < 0 || estimatedTokenCount < 0) {
      throw ArgumentError('Summary version and sizes must be non-negative.');
    }
  }

  final String id;
  final String projectId;
  final String summarySetId;
  final int sourceStartMessageSequence;
  final int sourceEndMessageSequence;
  final ConversationSummaryKind kind;
  final List<String> sourceEventIds;
  final String sourceDigest;
  final String fileName;
  final String contentDigest;
  final int contentBytes;
  final int estimatedTokenCount;
  final String provider;
  final String model;
  final int promptVersion;
  final ConversationSummarySegmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isUsable => status == ConversationSummarySegmentStatus.active;

  ConversationSummarySegment copyWith({
    String? fileName,
    String? contentDigest,
    int? contentBytes,
    ConversationSummarySegmentStatus? status,
    DateTime? updatedAt,
  }) => ConversationSummarySegment(
    id: id,
    projectId: projectId,
    summarySetId: summarySetId,
    sourceStartMessageSequence: sourceStartMessageSequence,
    sourceEndMessageSequence: sourceEndMessageSequence,
    kind: kind,
    sourceEventIds: sourceEventIds,
    sourceDigest: sourceDigest,
    fileName: fileName ?? this.fileName,
    contentDigest: contentDigest ?? this.contentDigest,
    contentBytes: contentBytes ?? this.contentBytes,
    estimatedTokenCount: estimatedTokenCount,
    provider: provider,
    model: model,
    promptVersion: promptVersion,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

final class ProjectConversationSummary {
  const ProjectConversationSummary({
    required this.segment,
    required this.markdown,
  });

  final ConversationSummarySegment segment;
  final String markdown;
}
