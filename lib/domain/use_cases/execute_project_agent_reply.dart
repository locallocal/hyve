import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_run_repository.dart';
import 'package:hyve/domain/repositories/model_usage_repository.dart';
import 'package:hyve/domain/repositories/project_agent_execution_gateway.dart';
import 'package:hyve/domain/use_cases/deliver_to_project_agent.dart';
import 'package:hyve/domain/use_cases/route_project_message.dart';

typedef ReplyRunIdFactory = String Function(String prefix);
typedef ReplyRunClock = DateTime Function();
typedef ReplyRunStarted =
    Future<void> Function(
      AgentRun run,
      ProjectRunCancellationToken cancellationToken,
    );
typedef ProjectAgentScopedToolProvider =
    Future<List<ExecutableTool>> Function({
      required Project project,
      required Agent agent,
      required AgentRun run,
    });

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
    DeliverToProjectAgent? deliverToProjectAgent,
    ProjectAgentScopedToolProvider? scopedToolProvider,
    ModelUsageRepository? modelUsageRepository,
    ReplyRunIdFactory? idFactory,
    ReplyRunClock? clock,
  }) : _runRepository = runRepository,
       _gateway = gateway,
       _routeProjectMessage = routeProjectMessage,
       _deliverToProjectAgent = deliverToProjectAgent,
       _scopedToolProvider = scopedToolProvider,
       _modelUsageRepository = modelUsageRepository,
       _idFactory = idFactory ?? _defaultReplyRunIdFactory,
       _clock = clock ?? DateTime.now;

  final AgentRunRepository _runRepository;
  final ProjectAgentExecutionGateway _gateway;
  final RouteProjectMessage _routeProjectMessage;
  final DeliverToProjectAgent? _deliverToProjectAgent;
  final ProjectAgentScopedToolProvider? _scopedToolProvider;
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
      final projectTools =
          await _scopedToolProvider?.call(
            project: project,
            agent: agent,
            run: run,
          ) ??
          const <ExecutableTool>[];
      result = await _gateway.reply(
        ProjectAgentReplyRequest(
          runId: runId,
          projectId: project.id,
          agent: agent,
          sourceEvent: sourceEvent,
          contextThroughMessageSequence: sourceEvent.messageSequence!,
          visibleHistory: visibleHistory,
          cancellationToken: cancellationToken,
          deliveryExecutor:
              _deliverToProjectAgent == null
                  ? null
                  : (request) => _deliverToProjectAgent(
                    project: project,
                    sourceAgent: agent,
                    sourceRun: run,
                    sourceTurn: turn,
                    sourceEvent: sourceEvent,
                    request: request,
                    cancellationToken: cancellationToken,
                  ),
          projectTools: projectTools,
        ),
      );
      if (result.status == ProjectAgentReplyStatus.completed &&
          result.text.trim().isEmpty &&
          result.deliveryCount == 0 &&
          !result.toolInvocations.any(
            (invocation) =>
                invocation.status == ToolInvocationStatus.succeeded &&
                invocation.riskLevel != ToolRiskLevel.readOnly,
          )) {
        result = ProjectAgentReplyResult(
          status: ProjectAgentReplyStatus.failed,
          reasoning: result.reasoning,
          tokenUsage: result.tokenUsage,
          errorCode: 'empty_agent_reply',
          toolInvocations: result.toolInvocations,
        );
      }
      if (result.status == ProjectAgentReplyStatus.completed &&
          result.text.trim().isNotEmpty) {
        cancellationToken.throwIfCancelled();
        replyEvent =
            (await _routeProjectMessage.appendAgentReply(
              projectId: project.id,
              agent: agent,
              content: result.text,
              reasoning: result.reasoning,
              processInfoJson: _toolInvocationsJson(result.toolInvocations),
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

String _toolInvocationsJson(List<ToolInvocationRecord> invocations) {
  return jsonEncode(<String, Object?>{
    'reasoning_status': '',
    'duration_ms': null,
    'tool_calls': <Map<String, Object?>>[
      for (final invocation in invocations)
        <String, Object?>{
          'call_id': invocation.callId,
          'name': invocation.name,
          'title': invocation.title,
          'mcp_server_name': invocation.mcpServerName,
          'status': invocation.status.name,
          'detail': '',
          'source': invocation.source.name,
          'risk_level': invocation.riskLevel.name,
          'arguments_summary': _artifactToolArgumentsSummary(invocation),
          'result_summary': _artifactToolResultSummary(invocation),
          'approval_status': invocation.approvalDecision,
          'error_code': invocation.errorCode,
          'duration_ms': invocation.durationMs,
        },
    ],
    'command_executions': const <Object?>[],
    'file_edits': const <Object?>[],
    'skill_activations': const <Object?>[],
  });
}

String _artifactToolArgumentsSummary(ToolInvocationRecord invocation) {
  final arguments = Map<String, Object?>.from(invocation.arguments);
  if (const <String>{
    'project.artifacts.create',
    'project.artifacts.write_version',
  }.contains(invocation.name)) {
    final content = arguments['content'];
    arguments['content'] =
        content is String
            ? '<artifact content omitted: ${content.length} characters>'
            : '<artifact content omitted>';
  }
  return _boundedAuditText(jsonEncode(arguments));
}

String _artifactToolResultSummary(ToolInvocationRecord invocation) {
  if (invocation.name == 'project.artifacts.read') {
    return '<artifact content omitted>';
  }
  return _boundedAuditText(invocation.resultSummary);
}

String _boundedAuditText(String value) {
  const limit = 1024;
  return value.length <= limit ? value : '${value.substring(0, limit)}…';
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
