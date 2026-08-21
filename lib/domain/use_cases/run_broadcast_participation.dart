import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_run_repository.dart';
import 'package:hyve/domain/repositories/model_usage_repository.dart';
import 'package:hyve/domain/repositories/participation_decision_repository.dart';
import 'package:hyve/domain/repositories/project_agent_execution_gateway.dart';

typedef BroadcastRunIdFactory = String Function(String prefix);
typedef BroadcastRunClock = DateTime Function();
typedef BroadcastRunStarted =
    Future<void> Function(
      AgentRun run,
      ProjectRunCancellationToken cancellationToken,
    );

final class BroadcastParticipationExecution {
  const BroadcastParticipationExecution({
    required this.run,
    required this.decision,
  });

  final AgentRun run;
  final ParticipationDecision decision;
}

final class RunBroadcastParticipation {
  RunBroadcastParticipation({
    required AgentRunRepository runRepository,
    required ParticipationDecisionRepository decisionRepository,
    required ProjectAgentExecutionGateway gateway,
    ModelUsageRepository? modelUsageRepository,
    BroadcastRunIdFactory? idFactory,
    BroadcastRunClock? clock,
  }) : _runRepository = runRepository,
       _decisionRepository = decisionRepository,
       _gateway = gateway,
       _modelUsageRepository = modelUsageRepository,
       _idFactory = idFactory ?? _defaultBroadcastRunIdFactory,
       _clock = clock ?? DateTime.now;

  final AgentRunRepository _runRepository;
  final ParticipationDecisionRepository _decisionRepository;
  final ProjectAgentExecutionGateway _gateway;
  final ModelUsageRepository? _modelUsageRepository;
  final BroadcastRunIdFactory _idFactory;
  final BroadcastRunClock _clock;

  Future<BroadcastParticipationExecution> call({
    required Project project,
    required Agent agent,
    required ProjectTurn turn,
    required ProjectEvent sourceEvent,
    required List<ProjectEvent> visibleHistory,
    BroadcastRunStarted? onRunStarted,
  }) async {
    final now = _clock();
    final runId = _idFactory('decision-run');
    final deliveryParent =
        sourceEvent.eventType == ProjectEventType.agentDelivery &&
                sourceEvent.runId.isNotEmpty
            ? await _runRepository.getRun(sourceEvent.runId)
            : null;
    var run = AgentRun(
      id: runId,
      projectId: project.id,
      turnId: turn.id,
      agentId: agent.id,
      sourceMessageEventId: sourceEvent.id,
      sourceMessageSequence: sourceEvent.messageSequence!,
      contextThroughMessageSequence: sourceEvent.messageSequence!,
      parentRunId: deliveryParent?.id ?? '',
      rootRunId: deliveryParent?.rootRunId ?? runId,
      deliveryDepth: deliveryParent?.deliveryDepth ?? 0,
      phase: AgentRunPhase.decision,
      status: AgentRunStatus.queued,
      agentSnapshot: _snapshot(agent),
      createdAt: now,
    );
    await _runRepository.save(run);
    final cancellationToken = ProjectRunCancellationToken();
    await onRunStarted?.call(run, cancellationToken);
    run = run.copyWith(status: AgentRunStatus.deciding, startedAt: now);
    await _runRepository.save(run);

    final policy = project.responsePolicy.broadcastDecision;
    final maxInputTokens = math.min(policy.maxInputTokens, 4096);
    final maxOutputTokens = math.min(policy.maxOutputTokens, 128);
    final bounded = _boundDecisionHistory(
      agent: agent,
      sourceEvent: sourceEvent,
      history: visibleHistory,
      maxInputTokens: maxInputTokens,
      maxOutputTokens: maxOutputTokens,
    );
    BroadcastParticipationResult result;
    var terminalStatus = AgentRunStatus.passed;
    try {
      cancellationToken.throwIfCancelled();
      result = await _gateway
          .decide(
            BroadcastParticipationRequest(
              runId: runId,
              projectId: project.id,
              agent: agent,
              sourceEvent: sourceEvent,
              decisionSystemPrompt: bounded.systemPrompt,
              visibleHistory: bounded.events,
              maxInputTokens: maxInputTokens,
              maxOutputTokens: maxOutputTokens,
              estimatedInputTokens: bounded.estimatedTokens,
              cancellationToken: cancellationToken,
            ),
          )
          .timeout(
            policy.timeout > const Duration(seconds: 10)
                ? const Duration(seconds: 10)
                : policy.timeout,
          );
      if (result.reasonCode.trim().isEmpty) {
        throw const FormatException('missing participation reasonCode');
      }
      terminalStatus =
          result.choice == ParticipationChoice.pass
              ? AgentRunStatus.passed
              : AgentRunStatus.completed;
    } on ProjectRunCancelledException {
      result = const BroadcastParticipationResult(
        choice: ParticipationChoice.pass,
        reasonCode: 'decision_cancelled',
      );
      terminalStatus = AgentRunStatus.cancelled;
    } on TimeoutException {
      result = const BroadcastParticipationResult(
        choice: ParticipationChoice.pass,
        reasonCode: 'decision_timeout',
      );
      terminalStatus = AgentRunStatus.timedOut;
    } on FormatException {
      result = const BroadcastParticipationResult(
        choice: ParticipationChoice.pass,
        reasonCode: 'decision_invalid',
      );
      terminalStatus = AgentRunStatus.failed;
    } on Object {
      result = const BroadcastParticipationResult(
        choice: ParticipationChoice.pass,
        reasonCode: 'decision_failed',
      );
      terminalStatus = AgentRunStatus.failed;
    }
    final completedAt = _clock();
    final decision = ParticipationDecision(
      runId: runId,
      agentId: agent.id,
      projectId: project.id,
      turnId: turn.id,
      messageSequence: sourceEvent.messageSequence!,
      choice: result.choice,
      reasonCode: result.reasonCode,
      intendedContribution: result.intendedContribution,
      createdAt: completedAt,
    );
    await _decisionRepository.save(decision);
    if (result.tokenUsage.hasData) {
      await _modelUsageRepository?.upsert(
        ModelTokenUsageRecord(
          messageId: runId,
          chatId: project.id,
          botId: agent.id,
          runId: runId,
          operationKind: 'participation_decision',
          timestamp: completedAt,
          usage: result.tokenUsage,
        ),
      );
    }
    run = run.copyWith(
      status: terminalStatus,
      completedAt: completedAt,
      errorCode:
          terminalStatus == AgentRunStatus.failed ||
                  terminalStatus == AgentRunStatus.timedOut
              ? result.reasonCode
              : '',
    );
    await _runRepository.save(run);
    return BroadcastParticipationExecution(run: run, decision: decision);
  }
}

final class _BoundedDecisionHistory {
  const _BoundedDecisionHistory(
    this.systemPrompt,
    this.events,
    this.estimatedTokens,
  );

  final String systemPrompt;
  final List<ProjectEvent> events;
  final int estimatedTokens;
}

_BoundedDecisionHistory _boundDecisionHistory({
  required Agent agent,
  required ProjectEvent sourceEvent,
  required List<ProjectEvent> history,
  required int maxInputTokens,
  required int maxOutputTokens,
}) {
  final instruction =
      'Decide whether this agent should answer the latest project message. '
      'Tools are disabled. Return one JSON object only with exact keys '
      'choice, reasonCode, intendedContribution. choice must be reply or '
      'pass. Keep the whole response below $maxOutputTokens tokens.\n'
      'Agent identity:';
  final instructionTokens = _estimateTokens(instruction) + 8;
  final identitySource =
      '${agent.name}\n${agent.systemPrompt}\n${agent.parameters}';
  final remainingAfterInstruction = math.max(
    0,
    maxInputTokens - instructionTokens,
  );
  final identityBudget = math.min(1024, remainingAfterInstruction ~/ 3);
  final identity = _truncateToEstimatedTokens(identitySource, identityBudget);
  final systemPrompt =
      identity.isEmpty ? instruction : '$instruction\n$identity';
  var used = _estimateTokens(systemPrompt) + 8;
  final selected = <ProjectEvent>[];
  final older = history.reversed.where((event) => event.id != sourceEvent.id);
  for (final event in <ProjectEvent>[sourceEvent, ...older]) {
    final remaining = maxInputTokens - used - 8;
    if (remaining <= 0) break;
    final content = _truncateToEstimatedTokens(
      _decisionEventContent(event),
      remaining,
    );
    if (content.isEmpty) continue;
    final bounded = _eventWithContent(event, content);
    used += _estimateTokens(content) + 8;
    selected.add(bounded);
  }
  selected.sort(
    (left, right) => left.messageSequence!.compareTo(right.messageSequence!),
  );
  return _BoundedDecisionHistory(
    systemPrompt,
    List<ProjectEvent>.unmodifiable(selected),
    used.clamp(0, maxInputTokens),
  );
}

String _decisionEventContent(ProjectEvent event) {
  final payload = event.payload;
  if (payload is AgentDeliveryPayload) {
    return '${payload.summary}\n${payload.payload}';
  }
  return event.content;
}

int _estimateTokens(String text) => (utf8.encode(text).length + 2) ~/ 3;

String _truncateToEstimatedTokens(String text, int availableTokens) {
  if (availableTokens <= 0) return '';
  if (_estimateTokens(text) <= availableTokens) return text;
  var low = 0;
  var high = text.length;
  while (low < high) {
    final middle = (low + high + 1) ~/ 2;
    if (_estimateTokens(text.substring(0, middle)) <= availableTokens) {
      low = middle;
    } else {
      high = middle - 1;
    }
  }
  return text.substring(0, low);
}

ProjectEvent _eventWithContent(ProjectEvent source, String content) =>
    ProjectEvent(
      id: source.id,
      projectId: source.projectId,
      turnId: source.turnId,
      runId: source.runId,
      sequence: source.sequence,
      messageSequence: source.messageSequence,
      eventType: source.eventType,
      actorType: source.actorType,
      actorId: source.actorId,
      actorNameSnapshot: source.actorNameSnapshot,
      actorAvatarSnapshot: source.actorAvatarSnapshot,
      visibility: source.visibility,
      replyToEventId: source.replyToEventId,
      replyToMessageSequence: source.replyToMessageSequence,
      rootMessageId: source.rootMessageId,
      autonomousDepth: source.autonomousDepth,
      content: content,
      payload: source.payload,
      terminalState: source.terminalState,
      hasPartialContent: source.hasPartialContent,
      targetAgentIds: source.targetAgentIds,
      createdAt: source.createdAt,
      updatedAt: source.updatedAt,
    );

AgentRunSnapshot _snapshot(Agent agent) => AgentRunSnapshot(
  agentName: agent.name,
  provider: agent.provider,
  model: agent.model,
  systemPromptDigest:
      sha256.convert(utf8.encode(agent.systemPrompt)).toString(),
  capabilityDigest:
      sha256.convert(utf8.encode('${agent.parameters}')).toString(),
);

int _broadcastRunSequence = 0;

String _defaultBroadcastRunIdFactory(String prefix) {
  _broadcastRunSequence = (_broadcastRunSequence + 1) & 0x7fffffff;
  return '$prefix:${DateTime.now().microsecondsSinceEpoch}:'
      '$_broadcastRunSequence';
}
