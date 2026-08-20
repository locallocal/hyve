import 'dart:async';
import 'dart:convert';

import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/models/ai_models.dart';
import 'package:hyve/domain/repositories/ai_provider_repository.dart';
import 'package:hyve/domain/repositories/project_agent_execution_gateway.dart';

final class ProviderProjectAgentExecutionGateway
    implements ProjectAgentExecutionGateway {
  const ProviderProjectAgentExecutionGateway({
    required AiProviderRepository providers,
  }) : _providers = providers;

  final AiProviderRepository _providers;

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
    final generated = await _generate(
      agent: request.agent,
      messages: <ChatMessage>[
        ChatMessage(role: 'system', content: request.agent.systemPrompt),
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
