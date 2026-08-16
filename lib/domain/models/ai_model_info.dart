import 'package:hyve/domain/models/modalities.dart';

enum AiModelTaskType {
  chat('chat'),
  deepResearch('deep_research'),
  computerUse('computer_use'),
  imageGeneration('image_generation'),
  videoGeneration('video_generation'),
  audio('audio'),
  realtime('realtime'),
  transcription('transcription'),
  speech('speech'),
  embedding('embedding'),
  moderation('moderation'),
  legacyCompletion('legacy_completion');

  const AiModelTaskType(this.value);

  final String value;
}

enum AiModelLifecycle {
  recommended('recommended'),
  current('current'),
  previous('previous'),
  preview('preview'),
  deprecated('deprecated'),
  removed('removed');

  const AiModelLifecycle(this.value);

  final String value;
}

enum AiModelEndpoint {
  responses('responses'),
  chatCompletions('chat_completions'),
  batch('batch'),
  assistants('assistants'),
  images('images'),
  videos('videos'),
  realtime('realtime'),
  audioTranscriptions('audio_transcriptions'),
  audioTranslations('audio_translations'),
  speech('speech'),
  embeddings('embeddings'),
  moderation('moderation'),
  legacyCompletions('legacy_completions');

  const AiModelEndpoint(this.value);

  final String value;
}

/// A provider-independent snapshot of one AI model's capabilities.
///
/// Nullable limits and dates mean that the provider did not expose a reliable
/// value. Callers must not treat an unknown value as zero.
final class AiModelInfo {
  AiModelInfo({
    required this.modelId,
    required this.providerId,
    required List<InputModality> inputModalities,
    required List<OutputModality> outputModalities,
    this.supportsWebSearch,
    this.supportsDeepThinking,
    this.supportsDeepResearch,
    this.supportsMcp,
    this.supportsSkills,
    this.supportsAutomaticSkillActivation,
    this.supportsHostedSkills,
    this.taskType,
    this.lifecycle,
    this.currentSnapshot,
    this.contextWindowTokens,
    this.maxInputTokens,
    this.maxOutputTokens,
    this.knowledgeCutoff,
    this.releaseDate,
    List<AiModelEndpoint> supportedEndpoints = const [],
    List<String> reasoningEfforts = const [],
    Set<String> supportedFeatures = const {},
    Set<String> nativeTools = const {},
  }) : assert(modelId != ''),
       assert(providerId != ''),
       assert(contextWindowTokens == null || contextWindowTokens > 0),
       assert(maxInputTokens == null || maxInputTokens > 0),
       assert(maxOutputTokens == null || maxOutputTokens > 0),
       inputModalities = List<InputModality>.unmodifiable(inputModalities),
       outputModalities = List<OutputModality>.unmodifiable(outputModalities),
       supportedEndpoints = List<AiModelEndpoint>.unmodifiable(
         supportedEndpoints,
       ),
       reasoningEfforts = List<String>.unmodifiable(reasoningEfforts),
       supportedFeatures = Set<String>.unmodifiable(supportedFeatures),
       nativeTools = Set<String>.unmodifiable(nativeTools);

  final String modelId;
  final String providerId;
  final List<InputModality> inputModalities;
  final List<OutputModality> outputModalities;
  final bool? supportsWebSearch;
  final bool? supportsDeepThinking;
  final bool? supportsDeepResearch;

  /// Whether the model can run client-provided MCP tools in an Agent Loop.
  final bool? supportsMcp;

  /// Whether Hyve can apply prompt-based Skills to this model.
  final bool? supportsSkills;

  /// Whether the model can select Skills through structured tool calls.
  final bool? supportsAutomaticSkillActivation;

  /// Whether the provider can host immutable Skill bundles itself.
  final bool? supportsHostedSkills;

  /// The API task this model performs. Unknown external models keep this null.
  final AiModelTaskType? taskType;

  final AiModelLifecycle? lifecycle;

  /// The fixed model snapshot currently targeted by a floating alias.
  final String? currentSnapshot;

  /// Total shared input and output context window, in tokens.
  final int? contextWindowTokens;

  /// Maximum accepted input tokens, when lower than the shared context window.
  final int? maxInputTokens;

  /// Maximum number of output tokens, when known.
  final int? maxOutputTokens;

  final DateTime? knowledgeCutoff;

  final DateTime? releaseDate;

  final List<AiModelEndpoint> supportedEndpoints;

  /// Provider-specific reasoning effort names accepted by this model.
  final List<String> reasoningEfforts;

  /// Stable machine-readable feature names such as `structured_outputs`.
  final Set<String> supportedFeatures;

  /// Provider-hosted tool names. Client-side MCP and Skills stay separate.
  final Set<String> nativeTools;

  Map<String, Object?> toJson() => <String, Object?>{
    'model_id': modelId,
    'provider_id': providerId,
    'input_modalities': [for (final item in inputModalities) item.value],
    'output_modalities': [for (final item in outputModalities) item.value],
    'supports_web_search': supportsWebSearch,
    'supports_deep_thinking': supportsDeepThinking,
    'supports_deep_research': supportsDeepResearch,
    'supports_mcp': supportsMcp,
    'supports_skills': supportsSkills,
    'supports_automatic_skill_activation': supportsAutomaticSkillActivation,
    'supports_hosted_skills': supportsHostedSkills,
    'task_type': taskType?.value,
    'lifecycle': lifecycle?.value,
    'current_snapshot': currentSnapshot,
    'context_window_tokens': contextWindowTokens,
    'max_input_tokens': maxInputTokens,
    'max_output_tokens': maxOutputTokens,
    'knowledge_cutoff': knowledgeCutoff?.toUtc().toIso8601String(),
    'release_date': releaseDate?.toUtc().toIso8601String(),
    'supported_endpoints': [
      for (final endpoint in supportedEndpoints) endpoint.value,
    ],
    'reasoning_efforts': reasoningEfforts,
    'supported_features': supportedFeatures.toList(growable: false)..sort(),
    'native_tools': nativeTools.toList(growable: false)..sort(),
  };
}
