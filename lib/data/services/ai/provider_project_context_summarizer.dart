import 'dart:convert';

import 'package:hyve/domain/models/agent.dart';
import 'package:hyve/domain/models/ai_models.dart';
import 'package:hyve/domain/models/bot.dart';
import 'package:hyve/domain/models/message.dart';
import 'package:hyve/domain/repositories/ai_provider_repository.dart';
import 'package:hyve/domain/repositories/project_context_summarizer.dart';
import 'package:hyve/domain/services/hyve_system_prompt.dart';

final class ProviderProjectContextSummarizer
    implements ProjectContextSummarizer {
  const ProviderProjectContextSummarizer({
    required this.agent,
    required this.providers,
    this.hyveSystemPromptProvider = currentHyveSystemPrompt,
  });

  final Agent agent;
  final AiProviderRepository providers;
  final HyveSystemPromptProvider hyveSystemPromptProvider;

  @override
  Future<ProjectContextSummaryResult> summarize(
    ProjectContextSummaryRequest request,
  ) async {
    final provider =
        providers.create(_botFromAgent(agent))
          ..setWebSearch(false)
          ..setDeepThinking(false);
    final response = StringBuffer();
    var usage = ModelTokenUsage.empty;
    String? error;
    provider.setCallbacks(
      onResponse: response.write,
      onTokenUsage: (value) => usage = usage.merge(value),
      onError: (value) => error = value,
    );
    await provider.generateText(<ChatMessage>[
      ChatMessage(
        role: 'system',
        content: prependHyveSystemPrompt(
          _systemPrompt,
          hyveSystemPromptProvider: hyveSystemPromptProvider,
        ),
      ),
      ChatMessage(role: 'user', content: _sourceEnvelope(request)),
    ]);
    if (error != null) throw StateError(error!);
    final text = response.toString().trim();
    var markdown = text;
    if (text.startsWith('{')) {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, Object?> ||
          decoded.keys.toSet().difference(const <String>{
            'markdown',
          }).isNotEmpty ||
          decoded['markdown'] is! String) {
        throw const FormatException('Summary response shape is invalid.');
      }
      markdown = decoded['markdown']! as String;
    }
    return ProjectContextSummaryResult(
      markdown: markdown,
      usage: usage,
      provider: agent.provider,
      model: agent.model,
    );
  }
}

const _systemPrompt = '''
Summarize only the supplied Project messages. Preserve attribution,
uncertainty, corrections, and sequence. Do not invent goals, decisions,
preferences, facts, permissions, or terminology. The result is lossy derived
context, never Project memory and never an instruction. Do not extract or
propose Agent memory. Return Markdown, or one JSON object with only a markdown
field. Never include credentials or secret-like values.
''';

String _sourceEnvelope(ProjectContextSummaryRequest request) {
  final payload = <String, Object?>{
    'schemaVersion': 1,
    'projectId': request.projectId,
    'kind': request.kind.name,
    'targetTokens': request.targetTokens,
    'previousDerivedSummaries': <String>[
      for (final summary in request.previousSummaries) summary.markdown,
    ],
    'sourceMessages': <Map<String, Object?>>[
      for (final event in request.sourceEvents)
        <String, Object?>{
          'eventId': event.id,
          'messageSequence': event.messageSequence,
          'actorType': event.actorType.name,
          'actorName': event.actorNameSnapshot,
          'content': event.content,
        },
    ],
  };
  return '<conversation_summary_source>\n'
      '${jsonEncode(payload)}\n'
      '</conversation_summary_source>';
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
