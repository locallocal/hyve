import 'package:hyve/domain/models/conversation_summary.dart';
import 'package:hyve/domain/models/message.dart';
import 'package:hyve/domain/models/project_event.dart';

final class ProjectContextSummaryRequest {
  ProjectContextSummaryRequest({
    required this.projectId,
    required this.segmentId,
    required this.kind,
    required Iterable<ProjectEvent> sourceEvents,
    Iterable<ProjectConversationSummary> previousSummaries = const [],
    required this.targetTokens,
  }) : sourceEvents = List<ProjectEvent>.unmodifiable(sourceEvents),
       previousSummaries = List<ProjectConversationSummary>.unmodifiable(
         previousSummaries,
       );

  final String projectId;
  final String segmentId;
  final ConversationSummaryKind kind;
  final List<ProjectEvent> sourceEvents;
  final List<ProjectConversationSummary> previousSummaries;
  final int targetTokens;
}

final class ProjectContextSummaryResult {
  const ProjectContextSummaryResult({
    required this.markdown,
    this.usage = ModelTokenUsage.empty,
    this.provider = '',
    this.model = '',
  });

  final String markdown;
  final ModelTokenUsage usage;
  final String provider;
  final String model;
}

abstract interface class ProjectContextSummarizer {
  Future<ProjectContextSummaryResult> summarize(
    ProjectContextSummaryRequest request,
  );
}
