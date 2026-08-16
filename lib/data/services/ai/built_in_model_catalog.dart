import 'package:hyve/domain/models/models.dart';

/// Provider metadata that is not consistently returned by `/models` APIs.
///
/// Keep this list limited to first-party, currently documented model IDs. The
/// live provider response still wins whenever it includes an explicit value.
/// Last verified against the providers' official documentation: 2026-08-04.
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
        maxInput: 922000,
        output: 128000,
        lifecycle: AiModelLifecycle.recommended,
        currentSnapshot: 'gpt-5.6-sol',
        knowledgeCutoff: DateTime.utc(2026, 2, 16),
        endpoints: _openAiTextEndpoints,
        reasoningEfforts: _gpt56ReasoningEfforts,
        features: _openAiFrontierFeatures,
        nativeTools: _openAiFrontierTools,
      ),
      _model(
        providerId: Bot.apiTypeOpenAI,
        modelId: 'gpt-5.6',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 1050000,
        maxInput: 922000,
        output: 128000,
        lifecycle: AiModelLifecycle.recommended,
        currentSnapshot: 'gpt-5.6-sol',
        knowledgeCutoff: DateTime.utc(2026, 2, 16),
        endpoints: _openAiTextEndpoints,
        reasoningEfforts: _gpt56ReasoningEfforts,
        features: _openAiFrontierFeatures,
        nativeTools: _openAiFrontierTools,
      ),
      _model(
        providerId: Bot.apiTypeOpenAI,
        modelId: 'gpt-5.6-terra',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 1050000,
        maxInput: 922000,
        output: 128000,
        lifecycle: AiModelLifecycle.recommended,
        knowledgeCutoff: DateTime.utc(2026, 2, 16),
        endpoints: _openAiTextEndpoints,
        reasoningEfforts: _gpt56ReasoningEfforts,
        features: _openAiFrontierFeatures,
        nativeTools: _openAiFrontierTools,
      ),
      _model(
        providerId: Bot.apiTypeOpenAI,
        modelId: 'gpt-5.6-luna',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 1050000,
        maxInput: 922000,
        output: 128000,
        lifecycle: AiModelLifecycle.recommended,
        knowledgeCutoff: DateTime.utc(2026, 2, 16),
        endpoints: _openAiTextEndpoints,
        reasoningEfforts: _gpt56ReasoningEfforts,
        features: _openAiFrontierFeatures,
        nativeTools: _openAiFrontierTools,
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
    Bot.apiTypeMoonshot: [
      _model(
        providerId: Bot.apiTypeMoonshot,
        modelId: 'kimi-k3',
        input: _kimiMultimodalInput,
        web: true,
        thinking: true,
        mcp: true,
        context: 1048576,
        output: 1048576,
        lifecycle: AiModelLifecycle.recommended,
        endpoints: _chatCompletionsEndpoint,
        reasoningEfforts: const ['low', 'high', 'max'],
        nativeTools: _kimiWebSearchTools,
        features: const {
          ..._kimiAgentFeatures,
          'always_thinking',
          'structured_outputs',
          'partial_mode',
          'dynamic_tools',
          'prompt_caching',
        },
      ),
      _model(
        providerId: Bot.apiTypeMoonshot,
        modelId: 'kimi-k2.7-code',
        input: _kimiMultimodalInput,
        web: true,
        thinking: true,
        mcp: true,
        context: 262144,
        lifecycle: AiModelLifecycle.current,
        endpoints: _chatCompletionsEndpoint,
        nativeTools: _kimiWebSearchTools,
        features: const {
          ..._kimiAgentFeatures,
          'always_thinking',
          'preserved_thinking',
        },
      ),
      _model(
        providerId: Bot.apiTypeMoonshot,
        modelId: 'kimi-k2.7-code-highspeed',
        input: _kimiMultimodalInput,
        web: true,
        thinking: true,
        mcp: true,
        context: 262144,
        lifecycle: AiModelLifecycle.current,
        endpoints: _chatCompletionsEndpoint,
        nativeTools: _kimiWebSearchTools,
        features: const {
          ..._kimiAgentFeatures,
          'always_thinking',
          'preserved_thinking',
          'high_speed_output',
        },
      ),
      _model(
        providerId: Bot.apiTypeMoonshot,
        modelId: 'kimi-k2.6',
        input: _kimiMultimodalInput,
        web: true,
        thinking: true,
        mcp: true,
        context: 262144,
        lifecycle: AiModelLifecycle.current,
        endpoints: _chatCompletionsEndpoint,
        nativeTools: _kimiWebSearchTools,
        features: const {
          ..._kimiAgentFeatures,
          'configurable_thinking',
          'preserved_thinking',
        },
      ),
      _model(
        providerId: Bot.apiTypeMoonshot,
        modelId: 'kimi-k2.5',
        input: _textImage,
        web: true,
        thinking: true,
        mcp: true,
        context: 262144,
        lifecycle: AiModelLifecycle.deprecated,
        endpoints: _chatCompletionsEndpoint,
        nativeTools: _kimiWebSearchTools,
        features: const {
          'streaming',
          'function_calling',
          'image_input',
          'reasoning',
          'configurable_thinking',
          'web_search',
        },
      ),
      _model(
        providerId: Bot.apiTypeMoonshot,
        modelId: 'moonshot-v1-8k',
        web: false,
        thinking: false,
        mcp: true,
        context: 8192,
        lifecycle: AiModelLifecycle.deprecated,
        endpoints: _chatCompletionsEndpoint,
        features: const {'streaming'},
      ),
      _model(
        providerId: Bot.apiTypeMoonshot,
        modelId: 'moonshot-v1-32k',
        web: false,
        thinking: false,
        mcp: true,
        context: 32768,
        lifecycle: AiModelLifecycle.deprecated,
        endpoints: _chatCompletionsEndpoint,
        features: const {'streaming'},
      ),
      _model(
        providerId: Bot.apiTypeMoonshot,
        modelId: 'moonshot-v1-128k',
        web: false,
        thinking: false,
        mcp: true,
        context: 131072,
        lifecycle: AiModelLifecycle.deprecated,
        endpoints: _chatCompletionsEndpoint,
        features: const {'streaming'},
      ),
      _model(
        providerId: Bot.apiTypeMoonshot,
        modelId: 'moonshot-v1-8k-vision-preview',
        input: _textImage,
        web: false,
        thinking: false,
        mcp: true,
        context: 8192,
        lifecycle: AiModelLifecycle.deprecated,
        endpoints: _chatCompletionsEndpoint,
        features: const {'streaming', 'image_input'},
      ),
      _model(
        providerId: Bot.apiTypeMoonshot,
        modelId: 'moonshot-v1-32k-vision-preview',
        input: _textImage,
        web: false,
        thinking: false,
        mcp: true,
        context: 32768,
        lifecycle: AiModelLifecycle.deprecated,
        endpoints: _chatCompletionsEndpoint,
        features: const {'streaming', 'image_input'},
      ),
      _model(
        providerId: Bot.apiTypeMoonshot,
        modelId: 'moonshot-v1-128k-vision-preview',
        input: _textImage,
        web: false,
        thinking: false,
        mcp: true,
        context: 131072,
        lifecycle: AiModelLifecycle.deprecated,
        endpoints: _chatCompletionsEndpoint,
        features: const {'streaming', 'image_input'},
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
      taskType: live.taskType ?? builtIn.taskType,
      lifecycle: live.lifecycle ?? builtIn.lifecycle,
      currentSnapshot: live.currentSnapshot ?? builtIn.currentSnapshot,
      contextWindowTokens:
          live.contextWindowTokens ?? builtIn.contextWindowTokens,
      maxInputTokens: live.maxInputTokens ?? builtIn.maxInputTokens,
      maxOutputTokens: live.maxOutputTokens ?? builtIn.maxOutputTokens,
      knowledgeCutoff: live.knowledgeCutoff ?? builtIn.knowledgeCutoff,
      releaseDate: live.releaseDate ?? builtIn.releaseDate,
      supportedEndpoints:
          live.supportedEndpoints.isEmpty
              ? builtIn.supportedEndpoints
              : live.supportedEndpoints,
      reasoningEfforts:
          live.reasoningEfforts.isEmpty
              ? builtIn.reasoningEfforts
              : live.reasoningEfforts,
      supportedFeatures:
          live.supportedFeatures.isEmpty
              ? builtIn.supportedFeatures
              : live.supportedFeatures,
      nativeTools:
          live.nativeTools.isEmpty ? builtIn.nativeTools : live.nativeTools,
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
    int? maxInput,
    int? output,
    DateTime? releaseDate,
    AiModelLifecycle? lifecycle,
    String? currentSnapshot,
    DateTime? knowledgeCutoff,
    List<AiModelEndpoint> endpoints = const [],
    List<String> reasoningEfforts = const [],
    Set<String> features = const {},
    Set<String> nativeTools = const {},
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
    taskType: AiModelTaskType.chat,
    lifecycle: lifecycle,
    currentSnapshot: currentSnapshot,
    contextWindowTokens: context,
    maxInputTokens: maxInput,
    maxOutputTokens: output,
    knowledgeCutoff: knowledgeCutoff,
    releaseDate: releaseDate,
    supportedEndpoints: endpoints,
    reasoningEfforts: reasoningEfforts,
    supportedFeatures: features,
    nativeTools: nativeTools,
  );

  static const _textImage = [InputModality.text, InputModality.image];
  static const _kimiMultimodalInput = [
    InputModality.text,
    InputModality.image,
    InputModality.video,
  ];
  static const _geminiInput = [
    InputModality.text,
    InputModality.image,
    InputModality.video,
    InputModality.audio,
    InputModality.file,
  ];
  static const _openAiTextEndpoints = [
    AiModelEndpoint.responses,
    AiModelEndpoint.chatCompletions,
    AiModelEndpoint.batch,
  ];
  static const _chatCompletionsEndpoint = [AiModelEndpoint.chatCompletions];
  static const _gpt56ReasoningEfforts = [
    'none',
    'low',
    'medium',
    'high',
    'xhigh',
  ];
  static const _openAiFrontierFeatures = {
    'streaming',
    'structured_outputs',
    'function_calling',
    'file_search',
    'image_input',
    'web_search',
    'prompt_caching',
  };
  static const _openAiFrontierTools = {
    'web_search',
    'file_search',
    'image_generation',
    'code_interpreter',
    'hosted_shell',
    'apply_patch',
    'skills',
    'computer_use',
    'mcp',
    'tool_search',
  };
  static const _kimiAgentFeatures = {
    'streaming',
    'function_calling',
    'image_input',
    'video_input',
    'reasoning',
    'web_search',
  };
  static const _kimiWebSearchTools = {r'$web_search'};
}
