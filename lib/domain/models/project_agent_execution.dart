import 'dart:async';

import 'package:hyve/domain/models/agent.dart';
import 'package:hyve/domain/models/message.dart';
import 'package:hyve/domain/models/project_event.dart';

final class ProjectRunCancellationToken {
  final Completer<void> _cancelled = Completer<void>();

  bool get isCancelled => _cancelled.isCompleted;
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
  }

  void throwIfCancelled() {
    if (isCancelled) throw const ProjectRunCancelledException();
  }
}

final class ProjectRunCancelledException implements Exception {
  const ProjectRunCancelledException();
}

final class BroadcastParticipationRequest {
  BroadcastParticipationRequest({
    required this.runId,
    required this.projectId,
    required this.agent,
    required this.sourceEvent,
    required this.decisionSystemPrompt,
    required Iterable<ProjectEvent> visibleHistory,
    required this.maxInputTokens,
    required this.maxOutputTokens,
    required this.estimatedInputTokens,
    required this.cancellationToken,
  }) : visibleHistory = List<ProjectEvent>.unmodifiable(visibleHistory);

  final String runId;
  final String projectId;
  final Agent agent;
  final ProjectEvent sourceEvent;

  /// Fully assembled and input-budgeted prompt for the tool-free decision.
  final String decisionSystemPrompt;
  final List<ProjectEvent> visibleHistory;
  final int maxInputTokens;
  final int maxOutputTokens;
  final int estimatedInputTokens;
  final ProjectRunCancellationToken cancellationToken;

  bool get toolsAllowed => false;
}

final class BroadcastParticipationResult {
  const BroadcastParticipationResult({
    required this.choice,
    required this.reasonCode,
    this.intendedContribution = '',
    this.tokenUsage = ModelTokenUsage.empty,
  });

  final ParticipationChoice choice;
  final String reasonCode;
  final String intendedContribution;
  final ModelTokenUsage tokenUsage;
}

final class ProjectAgentReplyRequest {
  ProjectAgentReplyRequest({
    required this.runId,
    required this.projectId,
    required this.agent,
    required this.sourceEvent,
    required this.contextThroughMessageSequence,
    required Iterable<ProjectEvent> visibleHistory,
    required this.cancellationToken,
  }) : visibleHistory = List<ProjectEvent>.unmodifiable(visibleHistory);

  final String runId;
  final String projectId;
  final Agent agent;
  final ProjectEvent sourceEvent;
  final int contextThroughMessageSequence;
  final List<ProjectEvent> visibleHistory;
  final ProjectRunCancellationToken cancellationToken;
}

enum ProjectAgentReplyStatus {
  completed,
  cancelled,
  failed,
  timedOut,
  limitExceeded,
}

final class ProjectAgentReplyResult {
  const ProjectAgentReplyResult({
    required this.status,
    this.text = '',
    this.reasoning = '',
    this.tokenUsage = ModelTokenUsage.empty,
    this.errorCode = '',
  });

  final ProjectAgentReplyStatus status;
  final String text;
  final String reasoning;
  final ModelTokenUsage tokenUsage;
  final String errorCode;
}
