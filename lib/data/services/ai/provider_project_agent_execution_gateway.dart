import 'dart:async';
import 'dart:convert';

import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/models/ai_models.dart';
import 'package:hyve/domain/repositories/ai_provider_repository.dart';
import 'package:hyve/domain/repositories/project_agent_execution_gateway.dart';
import 'package:hyve/domain/use_cases/agent_run_coordinator.dart';
import 'package:hyve/data/services/tools/project_artifact_tools.dart';
import 'package:hyve/data/services/tools/agent_memory_tools.dart';
import 'package:hyve/data/services/tools/project_deliver_to_agent_tool.dart';

final class ProviderProjectAgentExecutionGateway
    implements ProjectAgentExecutionGateway {
  const ProviderProjectAgentExecutionGateway({
    required AiProviderRepository providers,
    AgentRunLimits agentRunLimits = const AgentRunLimits(),
    ToolApprovalHandler approvalHandler = const DenyToolApprovalHandler(),
  }) : _providers = providers,
       _agentRunLimits = agentRunLimits,
       _approvalHandler = approvalHandler;

  final AiProviderRepository _providers;
  final AgentRunLimits _agentRunLimits;
  final ToolApprovalHandler _approvalHandler;

  @override
  Future<BroadcastParticipationResult> decide(
    BroadcastParticipationRequest request,
  ) async {
    if (request.maxInputTokens > 4096 || request.maxOutputTokens > 128) {
      throw const FormatException('participation budget exceeds hard limits');
    }
    if (request.estimatedInputTokens > request.maxInputTokens) {
      throw const FormatException('participation input exceeds its budget');
    }
    request.cancellationToken.throwIfCancelled();
    final messages = <ChatMessage>[
      ChatMessage(role: 'system', content: request.decisionSystemPrompt),
      for (final event in request.visibleHistory)
        ChatMessage(
          role:
              event.actorType == ProjectEventActorType.user
                  ? 'user'
                  : 'assistant',
          content: event.content,
        ),
    ];
    final generated = await _generate(
      agent: request.agent,
      messages: messages,
      cancellationToken: request.cancellationToken,
    );
    final decoded = _strictJsonObject(generated.text);
    if (decoded.keys.toSet().difference(const <String>{
          'choice',
          'reasonCode',
          'intendedContribution',
        }).isNotEmpty ||
        decoded.length != 3) {
      throw const FormatException('invalid participation response shape');
    }
    final choiceName = decoded['choice'];
    final reasonCode = decoded['reasonCode'];
    final contribution = decoded['intendedContribution'];
    if (choiceName is! String ||
        reasonCode is! String ||
        reasonCode.trim().isEmpty ||
        contribution is! String) {
      throw const FormatException('invalid participation response fields');
    }
    final choice = switch (choiceName) {
      'reply' => ParticipationChoice.reply,
      'pass' => ParticipationChoice.pass,
      _ => throw const FormatException('invalid participation choice'),
    };
    return BroadcastParticipationResult(
      choice: choice,
      reasonCode: reasonCode,
      intendedContribution: contribution,
      tokenUsage: generated.usage,
    );
  }

  @override
  Future<ProjectAgentReplyResult> reply(
    ProjectAgentReplyRequest request,
  ) async {
    request.cancellationToken.throwIfCancelled();
    final provider = _providers.create(_botFromAgent(request.agent));
    final deliveryExecutor = request.deliveryExecutor;
    if ((deliveryExecutor != null || request.projectTools.isNotEmpty) &&
        provider.capabilities.supportsAgentLoop) {
      return _replyWithDeliveryTool(
        request: request,
        provider: provider,
        deliveryExecutor: deliveryExecutor,
      );
    }
    final generated = await _generate(
      agent: request.agent,
      messages: <ChatMessage>[
        ChatMessage(role: 'system', content: request.agent.systemPrompt),
        ...request.contextMessages,
        for (final event in request.visibleHistory)
          ChatMessage(
            role:
                event.actorType == ProjectEventActorType.user
                    ? 'user'
                    : event.actorId == request.agent.id
                    ? 'assistant'
                    : 'user',
            content: event.content,
            images:
                event.payload is ProjectMessagePayload
                    ? (event.payload as ProjectMessagePayload).images
                    : const <String>[],
            files:
                event.payload is ProjectMessagePayload
                    ? (event.payload as ProjectMessagePayload).files
                    : const <String>[],
          ),
      ],
      cancellationToken: request.cancellationToken,
    );
    return ProjectAgentReplyResult(
      status: ProjectAgentReplyStatus.completed,
      text: generated.text,
      reasoning: generated.reasoning,
      tokenUsage: generated.usage,
    );
  }

  Future<ProjectAgentReplyResult> _replyWithDeliveryTool({
    required ProjectAgentReplyRequest request,
    required AiProvider provider,
    required ProjectAgentDeliveryExecutor? deliveryExecutor,
  }) async {
    var deliveryCount = 0;
    final tools = <ExecutableTool>[
      ...request.projectTools,
      if (deliveryExecutor != null)
        ProjectDeliverToAgentTool(
          deliver: (deliveryRequest) async {
            final result = await deliveryExecutor(deliveryRequest);
            deliveryCount++;
            return result;
          },
        ),
    ];
    final cancellationToken = AgentCancellationToken();
    unawaited(
      request.cancellationToken.whenCancelled.then((_) {
        cancellationToken.cancel();
      }),
    );
    final coordinator = AgentRunCoordinator(
      toolRegistry: StaticToolRegistry(tools),
      toolPolicy: const _ProjectAgentToolPolicy(),
      approvalHandler: _approvalHandler,
      limits: _agentRunLimits,
    );
    final result = await coordinator.run(
      provider: provider,
      request: AgentRunRequest(
        runId: request.runId,
        chatId: request.projectId,
        botId: request.agent.id,
        messages: <ChatMessage>[
          ChatMessage(
            role: 'system',
            content:
                '${request.agent.systemPrompt}\n\n'
                'Project artifact tools are scoped to this project and your '
                'live membership permission. Read only the bounded content '
                'you need. Use ${ProjectDeliverToAgentTool.name} for every '
                'structured '
                'handoff to another project Agent. Do not simulate a handoff '
                'with a plain-text @mention.',
          ),
          ...request.contextMessages,
          for (final event in request.visibleHistory)
            ChatMessage(
              role:
                  event.actorType == ProjectEventActorType.user
                      ? 'user'
                      : event.actorId == request.agent.id
                      ? 'assistant'
                      : 'user',
              content: _projectEventContent(event),
              images:
                  event.payload is ProjectMessagePayload
                      ? (event.payload as ProjectMessagePayload).images
                      : const <String>[],
              files:
                  event.payload is ProjectMessagePayload
                      ? (event.payload as ProjectMessagePayload).files
                      : const <String>[],
            ),
        ],
        requestedToolNames: tools.map((tool) => tool.definition.name).toSet(),
        cancellationToken: cancellationToken,
      ),
    );
    return ProjectAgentReplyResult(
      status: switch (result.status) {
        RunResultStatus.completed => ProjectAgentReplyStatus.completed,
        RunResultStatus.cancelled => ProjectAgentReplyStatus.cancelled,
        RunResultStatus.failed => ProjectAgentReplyStatus.failed,
        RunResultStatus.timedOut => ProjectAgentReplyStatus.timedOut,
        RunResultStatus.limitExceeded => ProjectAgentReplyStatus.limitExceeded,
      },
      text: result.text,
      reasoning: result.reasoning,
      tokenUsage: result.tokenUsage,
      errorCode: result.error,
      deliveryCount: deliveryCount,
      toolInvocations: result.toolInvocations,
    );
  }

  Future<_GeneratedText> _generate({
    required Agent agent,
    required List<ChatMessage> messages,
    required ProjectRunCancellationToken cancellationToken,
  }) async {
    final provider = _providers.create(_botFromAgent(agent));
    provider.resetCancelState();
    var text = '';
    var reasoning = '';
    var usage = ModelTokenUsage.empty;
    String? error;
    provider.setCallbacks(
      onResponse: (delta) => text += delta,
      onReasoningResponse: (delta) => reasoning += delta,
      onTokenUsage: (value) => usage = value,
      onError: (value) => error = value,
    );
    unawaited(
      cancellationToken.whenCancelled.then((_) async {
        await provider.cancelRequest();
      }),
    );
    await provider.generateText(messages);
    if (cancellationToken.isCancelled || provider.isCancelled) {
      throw const ProjectRunCancelledException();
    }
    if (error != null) throw StateError(error!);
    return _GeneratedText(text: text, reasoning: reasoning, usage: usage);
  }
}

String _projectEventContent(ProjectEvent event) {
  final payload = event.payload;
  if (payload is AgentDeliveryPayload) {
    return '[Agent delivery: ${payload.kind.name}; '
        'visibility=${event.visibility.name}; '
        'targets=${event.targetAgentIds.join(',')}]\n'
        '${payload.summary}\n${payload.payload}';
  }
  return event.content;
}

final class _ProjectAgentToolPolicy implements ToolPolicy {
  const _ProjectAgentToolPolicy();

  @override
  ToolPolicyDecision evaluate(
    ToolDefinition definition,
    ToolCallRequest call,
    ToolPolicyContext context,
  ) {
    if (!context.requestedToolNames.contains(definition.name)) {
      return const ToolPolicyDecision.deny(reason: 'project_tool_not_exposed');
    }
    if (definition.name == ProjectDeliverToAgentTool.name) {
      return const ToolPolicyDecision.allow(
        reason: 'trusted_project_delivery_context',
      );
    }
    if (ProjectArtifactToolNames.readOnly.contains(definition.name)) {
      return const ToolPolicyDecision.allow(
        reason: 'scoped_project_artifact_read',
      );
    }
    if (AgentMemoryToolNames.readOnly.contains(definition.name)) {
      return const ToolPolicyDecision.allow(reason: 'scoped_agent_memory_read');
    }
    if (AgentMemoryToolNames.write.contains(definition.name)) {
      return const ToolPolicyDecision.allow(
        reason: 'scoped_agent_memory_proposal',
      );
    }
    if (AgentMemoryToolNames.destructive.contains(definition.name)) {
      return const ToolPolicyDecision.requireApproval(
        reason: 'agent_memory_forget_requires_approval',
      );
    }
    if (ProjectArtifactToolNames.write.contains(definition.name)) {
      return const ToolPolicyDecision.allow(
        reason: 'immutable_project_artifact_write',
      );
    }
    if (ProjectArtifactToolNames.destructive.contains(definition.name)) {
      return const ToolPolicyDecision.requireApproval(
        reason: 'project_artifact_destructive_approval',
      );
    }
    return const ToolPolicyDecision.deny(reason: 'project_tool_not_allowed');
  }
}

final class _GeneratedText {
  const _GeneratedText({
    required this.text,
    required this.reasoning,
    required this.usage,
  });

  final String text;
  final String reasoning;
  final ModelTokenUsage usage;
}

Bot _botFromAgent(Agent agent) => Bot(
  id: agent.id,
  name: agent.name,
  avatar: agent.avatar,
  provider: agent.provider,
  baseURL: agent.baseUrl,
  apiKey: agent.apiKey,
  apiType: agent.apiType,
  model: agent.model,
  systemPrompt: agent.systemPrompt,
  parameters: Map<String, dynamic>.from(agent.parameters),
  createTimestamp: agent.createdAt,
  modifyTimestamp: agent.updatedAt,
);

Map<String, Object?> _strictJsonObject(String source) {
  var normalized = source.trim();
  if (normalized.startsWith('```') && normalized.endsWith('```')) {
    normalized = normalized.substring(3, normalized.length - 3).trim();
    if (normalized.startsWith('json')) {
      normalized = normalized.substring(4).trim();
    }
  }
  final decoded = jsonDecode(normalized);
  if (decoded is! Map<String, Object?>) {
    throw const FormatException('participation response must be an object');
  }
  return decoded;
}
