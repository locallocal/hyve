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

const Set<String> _participationResponseKeys = <String>{
  'choice',
  'reasonCode',
  'reason_code',
  'reason',
  'intendedContribution',
  'intended_contribution',
};
const List<String> _participationReasonKeys = <String>[
  'reasonCode',
  'reason_code',
  'reason',
];
const List<String> _participationContributionKeys = <String>[
  'intendedContribution',
  'intended_contribution',
];

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
    final decoded = _jsonObjectFromModelOutput(generated.text);
    if (decoded.keys
        .toSet()
        .difference(_participationResponseKeys)
        .isNotEmpty) {
      throw const FormatException('invalid participation response shape');
    }
    final choiceName = _aliasedField(decoded, const <String>['choice']);
    final reasonCode = _aliasedField(decoded, _participationReasonKeys);
    final contribution = _aliasedField(
      decoded,
      _participationContributionKeys,
      required: false,
    );
    if (choiceName is! String ||
        reasonCode is! String ||
        reasonCode.trim().isEmpty ||
        contribution != null && contribution is! String) {
      throw const FormatException('invalid participation response fields');
    }
    final choice = switch (choiceName.trim().toLowerCase()) {
      'reply' => ParticipationChoice.reply,
      'pass' => ParticipationChoice.pass,
      _ => throw const FormatException('invalid participation choice'),
    };
    return BroadcastParticipationResult(
      choice: choice,
      reasonCode: reasonCode.trim(),
      intendedContribution: (contribution as String?)?.trim() ?? '',
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

Object? _aliasedField(
  Map<String, Object?> values,
  List<String> names, {
  bool required = true,
}) {
  final present = names.where(values.containsKey).toList(growable: false);
  if (present.length > 1 || required && present.isEmpty) {
    throw const FormatException('ambiguous or missing participation field');
  }
  return present.isEmpty ? null : values[present.single];
}

Map<String, Object?> _jsonObjectFromModelOutput(String source) {
  final normalized = source.trim();
  final direct = _tryJsonObject(normalized);
  if (direct != null) return direct;

  Map<String, Object?>? firstObject;
  for (
    var start = normalized.indexOf('{');
    start >= 0;
    start = normalized.indexOf('{', start + 1)
  ) {
    final end = _jsonObjectEnd(normalized, start);
    if (end == null) continue;
    final decoded = _tryJsonObject(normalized.substring(start, end + 1));
    if (decoded == null) continue;
    firstObject ??= decoded;
    if (_looksLikeParticipationObject(decoded)) return decoded;
  }
  if (firstObject != null) return firstObject;
  throw const FormatException('participation response must contain an object');
}

bool _looksLikeParticipationObject(Map<String, Object?> values) =>
    values.containsKey('choice') &&
    _participationReasonKeys.any(values.containsKey) &&
    values.keys.toSet().difference(_participationResponseKeys).isEmpty;

Map<String, Object?>? _tryJsonObject(String source) {
  if (source.isEmpty) return null;
  try {
    final decoded = jsonDecode(source);
    if (decoded is! Map<Object?, Object?> ||
        decoded.keys.any((key) => key is! String)) {
      return null;
    }
    return <String, Object?>{
      for (final entry in decoded.entries) entry.key! as String: entry.value,
    };
  } on FormatException {
    return null;
  }
}

int? _jsonObjectEnd(String source, int start) {
  var depth = 0;
  var inString = false;
  var escaped = false;
  for (var index = start; index < source.length; index++) {
    final codeUnit = source.codeUnitAt(index);
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (codeUnit == 0x5c) {
        escaped = true;
      } else if (codeUnit == 0x22) {
        inString = false;
      }
      continue;
    }
    if (codeUnit == 0x22) {
      inString = true;
    } else if (codeUnit == 0x7b) {
      depth++;
    } else if (codeUnit == 0x7d && --depth == 0) {
      return index;
    }
  }
  return null;
}
