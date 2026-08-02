import 'package:stars/domain/models/models.dart';

/// Provider metadata that is not consistently returned by `/models` APIs.
///
/// Keep this list limited to first-party, currently documented model IDs. The
/// live provider response still wins whenever it includes an explicit value.
/// Last verified against the providers' official documentation: 2026-08-02.
final class BuiltInModelCatalog {
  BuiltInModelCatalog._();

  static final Map<String, List<AiModelInfo>> _models = {
    Bot.apiTypeOpenAI: [
      _model(
        providerId: Bot.apiTypeOpenAI,
        modelId: 'gpt-5.6-sol',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 1050000,
        output: 128000,
      ),
      _model(
        providerId: Bot.apiTypeOpenAI,
        modelId: 'gpt-5.6',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 1050000,
        output: 128000,
      ),
      _model(
        providerId: Bot.apiTypeOpenAI,
        modelId: 'gpt-5.6-terra',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 1050000,
        output: 128000,
      ),
      _model(
        providerId: Bot.apiTypeOpenAI,
        modelId: 'gpt-5.6-luna',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 1050000,
        output: 128000,
      ),
    ],
    Bot.apiTypeAnthropic: [
      _model(
        providerId: Bot.apiTypeAnthropic,
        modelId: 'claude-fable-5',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 1000000,
        output: 128000,
        releaseDate: DateTime.utc(2026, 6, 9),
      ),
      _model(
        providerId: Bot.apiTypeAnthropic,
        modelId: 'claude-opus-5',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 1000000,
        output: 128000,
      ),
      _model(
        providerId: Bot.apiTypeAnthropic,
        modelId: 'claude-sonnet-5',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 1000000,
        output: 128000,
      ),
      _model(
        providerId: Bot.apiTypeAnthropic,
        modelId: 'claude-haiku-4-5-20251001',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 200000,
        output: 64000,
        releaseDate: DateTime.utc(2025, 10, 1),
      ),
      _model(
        providerId: Bot.apiTypeAnthropic,
        modelId: 'claude-haiku-4-5',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 200000,
        output: 64000,
      ),
    ],
    Bot.apiTypeGemini: [
      _model(
        providerId: Bot.apiTypeGemini,
        modelId: 'models/gemini-3.6-flash',
        input: _geminiInput,
        web: true,
        thinking: true,
        context: 1048576,
        output: 65536,
      ),
      _model(
        providerId: Bot.apiTypeGemini,
        modelId: 'models/gemini-3.5-flash',
        input: _geminiInput,
        web: true,
        thinking: true,
        context: 1048576,
        output: 65536,
      ),
      _model(
        providerId: Bot.apiTypeGemini,
        modelId: 'models/gemini-3.5-flash-lite',
        input: _geminiInput,
        web: true,
        thinking: true,
        context: 1048576,
        output: 65536,
      ),
      _model(
        providerId: Bot.apiTypeGemini,
        modelId: 'models/gemini-3.1-pro-preview',
        input: _geminiInput,
        web: true,
        thinking: true,
        context: 1048576,
        output: 65536,
      ),
    ],
    Bot.apiTypeGrok: [
      _model(
        providerId: Bot.apiTypeGrok,
        modelId: 'grok-4.5',
        input: _textImage,
        web: true,
        thinking: true,
        context: 500000,
      ),
    ],
    Bot.apiTypeDeepseek: [
      _model(
        providerId: Bot.apiTypeDeepseek,
        modelId: 'deepseek-v4-flash',
        web: false,
        thinking: true,
        context: 1000000,
        output: 384000,
        releaseDate: DateTime.utc(2026, 7, 31),
      ),
      _model(
        providerId: Bot.apiTypeDeepseek,
        modelId: 'deepseek-v4-pro',
        web: false,
        thinking: true,
        context: 1000000,
        output: 384000,
        releaseDate: DateTime.utc(2026, 4, 24),
      ),
    ],
    Bot.apiTypeMistral: [
      _model(
        providerId: Bot.apiTypeMistral,
        modelId: 'mistral-medium-3-5',
        input: _textImage,
        web: false,
        thinking: true,
        context: 256000,
        releaseDate: DateTime.utc(2026, 4, 28),
      ),
      _model(
        providerId: Bot.apiTypeMistral,
        modelId: 'mistral-small-2603',
        input: _textImage,
        web: false,
        thinking: true,
        context: 256000,
        releaseDate: DateTime.utc(2026, 3, 16),
      ),
      _model(
        providerId: Bot.apiTypeMistral,
        modelId: 'mistral-small-latest',
        input: _textImage,
        web: false,
        thinking: true,
        context: 256000,
      ),
    ],
    Bot.apiTypePerplexity: [
      _model(
        providerId: Bot.apiTypePerplexity,
        modelId: 'sonar',
        web: true,
        thinking: false,
        context: 128000,
      ),
      _model(
        providerId: Bot.apiTypePerplexity,
        modelId: 'sonar-pro',
        web: true,
        thinking: false,
        context: 200000,
      ),
      _model(
        providerId: Bot.apiTypePerplexity,
        modelId: 'sonar-reasoning-pro',
        web: true,
        thinking: true,
        context: 128000,
      ),
      _model(
        providerId: Bot.apiTypePerplexity,
        modelId: 'sonar-deep-research',
        web: true,
        thinking: true,
        research: true,
        context: 128000,
      ),
    ],
  };

  static List<AiModelInfo> modelsFor(String providerId) =>
      List<AiModelInfo>.unmodifiable(_models[providerId] ?? const []);

  static AiModelInfo? find(String providerId, String modelId) {
    final canonicalId = _canonicalModelId(modelId);
    for (final model in _models[providerId] ?? const <AiModelInfo>[]) {
      if (_canonicalModelId(model.modelId) == canonicalId) return model;
    }
    return null;
  }

  static AiModelInfo enrich(AiModelInfo model) {
    final builtIn = find(model.providerId, model.modelId);
    return builtIn == null ? model : _mergeModel(model, builtIn);
  }

  /// Enriches live results and appends newly documented models that a provider
  /// catalog has not exposed yet (for example, during a staged rollout).
  static List<AiModelInfo> merge(
    String providerId,
    Iterable<AiModelInfo> liveModels,
  ) {
    final liveById = <String, AiModelInfo>{
      for (final model in liveModels) _canonicalModelId(model.modelId): model,
    };
    final result = <AiModelInfo>[];

    for (final builtIn in _models[providerId] ?? const <AiModelInfo>[]) {
      final live = liveById.remove(_canonicalModelId(builtIn.modelId));
      result.add(live == null ? builtIn : _mergeModel(live, builtIn));
    }

    final remaining =
        liveById.values.toList()
          ..sort((left, right) => left.modelId.compareTo(right.modelId));
    result.addAll(remaining);
    return result;
  }

  static AiModelInfo _mergeModel(AiModelInfo live, AiModelInfo builtIn) {
    return AiModelInfo(
      modelId: live.modelId,
      providerId: live.providerId,
      inputModalities:
          live.inputModalities.isEmpty
              ? builtIn.inputModalities
              : live.inputModalities,
      outputModalities:
          live.outputModalities.isEmpty
              ? builtIn.outputModalities
              : live.outputModalities,
      supportsWebSearch: live.supportsWebSearch ?? builtIn.supportsWebSearch,
      supportsDeepThinking:
          live.supportsDeepThinking ?? builtIn.supportsDeepThinking,
      supportsDeepResearch:
          live.supportsDeepResearch ?? builtIn.supportsDeepResearch,
      supportsMcp: live.supportsMcp ?? builtIn.supportsMcp,
      supportsSkills: live.supportsSkills ?? builtIn.supportsSkills,
      supportsAutomaticSkillActivation:
          live.supportsAutomaticSkillActivation ??
          builtIn.supportsAutomaticSkillActivation,
      supportsHostedSkills:
          live.supportsHostedSkills ?? builtIn.supportsHostedSkills,
      contextWindowTokens:
          live.contextWindowTokens ?? builtIn.contextWindowTokens,
      maxOutputTokens: live.maxOutputTokens ?? builtIn.maxOutputTokens,
      releaseDate: live.releaseDate ?? builtIn.releaseDate,
    );
  }

  static String _canonicalModelId(String modelId) {
    final normalized = modelId.toLowerCase();
    return normalized.startsWith('models/')
        ? normalized.substring('models/'.length)
        : normalized;
  }

  static AiModelInfo _model({
    required String providerId,
    required String modelId,
    List<InputModality> input = const [InputModality.text],
    bool? web,
    bool? thinking,
    bool? research,
    bool? mcp = false,
    int? context,
    int? output,
    DateTime? releaseDate,
  }) => AiModelInfo(
    modelId: modelId,
    providerId: providerId,
    inputModalities: input,
    outputModalities: const [OutputModality.text],
    supportsWebSearch: web,
    supportsDeepThinking: thinking,
    supportsDeepResearch: research,
    supportsMcp: mcp,
    supportsSkills: true,
    supportsAutomaticSkillActivation: true,
    contextWindowTokens: context,
    maxOutputTokens: output,
    releaseDate: releaseDate,
  );

  static const _textImage = [InputModality.text, InputModality.image];
  static const _geminiInput = [
    InputModality.text,
    InputModality.image,
    InputModality.video,
    InputModality.audio,
    InputModality.file,
  ];
}
