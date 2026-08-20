import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_run_repository.dart';
import 'package:hyve/domain/repositories/model_usage_repository.dart';
import 'package:hyve/domain/repositories/project_agent_execution_gateway.dart';
import 'package:hyve/domain/use_cases/route_project_message.dart';

typedef ReplyRunIdFactory = String Function(String prefix);
typedef ReplyRunClock = DateTime Function();
typedef ReplyRunStarted =
    Future<void> Function(
      AgentRun run,
      ProjectRunCancellationToken cancellationToken,
    );

final class ProjectAgentReplyExecution {
  const ProjectAgentReplyExecution({
    required this.run,
    this.replyEvent,
    required this.result,
  });

  final AgentRun run;
  final ProjectEvent? replyEvent;
  final ProjectAgentReplyResult result;
}

final class ExecuteProjectAgentReply {
  ExecuteProjectAgentReply({
    required AgentRunRepository runRepository,
    required ProjectAgentExecutionGateway gateway,
    required RouteProjectMessage routeProjectMessage,
    ModelUsageRepository? modelUsageRepository,
    ReplyRunIdFactory? idFactory,
    ReplyRunClock? clock,
  }) : _runRepository = runRepository,
       _gateway = gateway,
       _routeProjectMessage = routeProjectMessage,
       _modelUsageRepository = modelUsageRepository,
       _idFactory = idFactory ?? _defaultReplyRunIdFactory,
       _clock = clock ?? DateTime.now;

  final AgentRunRepository _runRepository;
  final ProjectAgentExecutionGateway _gateway;
  final RouteProjectMessage _routeProjectMessage;
  final ModelUsageRepository? _modelUsageRepository;
  final ReplyRunIdFactory _idFactory;
  final ReplyRunClock _clock;

  Future<ProjectAgentReplyExecution> call({
    required Project project,
    required Agent agent,
    required ProjectTurn turn,
    required ProjectEvent sourceEvent,
    required List<ProjectEvent> visibleHistory,
    ReplyRunStarted? onRunStarted,
  }) async {
    final now = _clock();
    final runId = _idFactory('reply-run');
    var run = AgentRun(
      id: runId,
      projectId: project.id,
      turnId: turn.id,
      agentId: agent.id,
      sourceMessageEventId: sourceEvent.id,
      sourceMessageSequence: sourceEvent.messageSequence!,
      contextThroughMessageSequence: sourceEvent.messageSequence!,
      rootRunId: runId,
      phase: AgentRunPhase.reply,
      status: AgentRunStatus.queued,
      agentSnapshot: _replySnapshot(agent),
      createdAt: now,
    );
    await _runRepository.save(run);
    final cancellationToken = ProjectRunCancellationToken();
    await onRunStarted?.call(run, cancellationToken);
    run = run.copyWith(status: AgentRunStatus.running, startedAt: now);
    await _runRepository.save(run);

    ProjectAgentReplyResult result;
    ProjectEvent? replyEvent;
    try {
      cancellationToken.throwIfCancelled();
      result = await _gateway.reply(
        ProjectAgentReplyRequest(
          runId: runId,
          projectId: project.id,
          agent: agent,
          sourceEvent: sourceEvent,
          contextThroughMessageSequence: sourceEvent.messageSequence!,
          visibleHistory: visibleHistory,
          cancellationToken: cancellationToken,
        ),
      );
      if (result.status == ProjectAgentReplyStatus.completed &&
          result.text.trim().isEmpty) {
        result = ProjectAgentReplyResult(
          status: ProjectAgentReplyStatus.failed,
          reasoning: result.reasoning,
          tokenUsage: result.tokenUsage,
          errorCode: 'empty_agent_reply',
        );
      }
      if (result.status == ProjectAgentReplyStatus.completed) {
        cancellationToken.throwIfCancelled();
        replyEvent =
            (await _routeProjectMessage.appendAgentReply(
              projectId: project.id,
              agent: agent,
              content: result.text,
              reasoning: result.reasoning,
              runId: runId,
              sourceEvent: sourceEvent,
              sourceTurn: turn,
            )).event;
      }
    } on ProjectRunCancelledException {
      result = const ProjectAgentReplyResult(
        status: ProjectAgentReplyStatus.cancelled,
        errorCode: 'reply_cancelled',
      );
    } on Object {
      result = const ProjectAgentReplyResult(
        status: ProjectAgentReplyStatus.failed,
        errorCode: 'reply_failed',
      );
    }
    final completedAt = _clock();
    if (result.tokenUsage.hasData) {
      await _modelUsageRepository?.upsert(
        ModelTokenUsageRecord(
          messageId: runId,
          chatId: project.id,
          botId: agent.id,
          runId: runId,
          operationKind: 'chat_reply',
          timestamp: completedAt,
          usage: result.tokenUsage,
        ),
      );
    }
    run = run.copyWith(
      status: _replyRunStatus(result.status),
      completedAt: completedAt,
      errorCode: result.errorCode,
    );
    await _runRepository.save(run);
    return ProjectAgentReplyExecution(
      run: run,
      replyEvent: replyEvent,
      result: result,
    );
  }
}

AgentRunStatus _replyRunStatus(ProjectAgentReplyStatus status) =>
    switch (status) {
      ProjectAgentReplyStatus.completed => AgentRunStatus.completed,
      ProjectAgentReplyStatus.cancelled => AgentRunStatus.cancelled,
      ProjectAgentReplyStatus.failed => AgentRunStatus.failed,
      ProjectAgentReplyStatus.timedOut => AgentRunStatus.timedOut,
      ProjectAgentReplyStatus.limitExceeded => AgentRunStatus.limitExceeded,
    };

AgentRunSnapshot _replySnapshot(Agent agent) => AgentRunSnapshot(
  agentName: agent.name,
  provider: agent.provider,
  model: agent.model,
  systemPromptDigest:
      sha256.convert(utf8.encode(agent.systemPrompt)).toString(),
  capabilityDigest:
      sha256.convert(utf8.encode('${agent.parameters}')).toString(),
);

int _replyRunSequence = 0;

String _defaultReplyRunIdFactory(String prefix) {
  _replyRunSequence = (_replyRunSequence + 1) & 0x7fffffff;
  return '$prefix:${DateTime.now().microsecondsSinceEpoch}:'
      '$_replyRunSequence';
}
