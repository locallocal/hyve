import 'package:stars/domain/models/modalities.dart';

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
    this.supportsSkills,
    this.supportsAutomaticSkillActivation,
    this.supportsHostedSkills,
    this.contextWindowTokens,
    this.maxOutputTokens,
    this.releaseDate,
  }) : assert(modelId != ''),
       assert(providerId != ''),
       assert(contextWindowTokens == null || contextWindowTokens > 0),
       assert(maxOutputTokens == null || maxOutputTokens > 0),
       inputModalities = List<InputModality>.unmodifiable(inputModalities),
       outputModalities = List<OutputModality>.unmodifiable(outputModalities);

  final String modelId;
  final String providerId;
  final List<InputModality> inputModalities;
  final List<OutputModality> outputModalities;
  final bool? supportsWebSearch;
  final bool? supportsDeepThinking;
  final bool? supportsDeepResearch;

  /// Whether Stars can apply prompt-based Skills to this model.
  final bool? supportsSkills;

  /// Whether the model can select Skills through structured tool calls.
  final bool? supportsAutomaticSkillActivation;

  /// Whether the provider can host immutable Skill bundles itself.
  final bool? supportsHostedSkills;

  /// Total shared input and output context window, in tokens.
  final int? contextWindowTokens;

  /// Maximum number of output tokens, when known.
  final int? maxOutputTokens;

  final DateTime? releaseDate;

  Map<String, Object?> toJson() => <String, Object?>{
    'model_id': modelId,
    'provider_id': providerId,
    'input_modalities': [for (final item in inputModalities) item.value],
    'output_modalities': [for (final item in outputModalities) item.value],
    'supports_web_search': supportsWebSearch,
    'supports_deep_thinking': supportsDeepThinking,
    'supports_deep_research': supportsDeepResearch,
    'supports_skills': supportsSkills,
    'supports_automatic_skill_activation': supportsAutomaticSkillActivation,
    'supports_hosted_skills': supportsHostedSkills,
    'context_window_tokens': contextWindowTokens,
    'max_output_tokens': maxOutputTokens,
    'release_date': releaseDate?.toUtc().toIso8601String(),
  };
}
