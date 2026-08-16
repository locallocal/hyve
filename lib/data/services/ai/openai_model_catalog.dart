part of 'openai.dart';

final class _OpenAiModelSpec {
  const _OpenAiModelSpec({
    required this.id,
    required this.taskType,
    required this.inputModalities,
    required this.outputModalities,
    required this.endpoints,
    this.lifecycle = AiModelLifecycle.previous,
    this.currentSnapshot,
    this.contextWindowTokens,
    this.maxInputTokens,
    this.maxOutputTokens,
    this.knowledgeCutoff,
    this.reasoningEfforts = const [],
    this.supportedFeatures = const {},
    this.nativeTools = const {},
    this.supportsWebSearch = false,
    this.supportsDeepThinking = false,
    this.supportsDeepResearch = false,
    this.isOfficialModel = true,
  });

  final String id;
  final AiModelTaskType taskType;
  final List<InputModality> inputModalities;
  final List<OutputModality> outputModalities;
  final List<AiModelEndpoint> endpoints;
  final AiModelLifecycle lifecycle;
  final String? currentSnapshot;
  final int? contextWindowTokens;
  final int? maxInputTokens;
  final int? maxOutputTokens;
  final DateTime? knowledgeCutoff;
  final List<String> reasoningEfforts;
  final Set<String> supportedFeatures;
  final Set<String> nativeTools;
  final bool supportsWebSearch;
  final bool supportsDeepThinking;
  final bool supportsDeepResearch;
  final bool isOfficialModel;

  AiModelEndpoint? get preferredEndpoint =>
      endpoints.isEmpty ? null : endpoints.first;

  bool get supportsConversationGeneration =>
      taskType == AiModelTaskType.chat &&
      (endpoints.contains(AiModelEndpoint.responses) ||
          endpoints.contains(AiModelEndpoint.chatCompletions));

  bool get supportsMcp =>
      supportsConversationGeneration &&
      supportedFeatures.contains('function_calling');

  bool get isSelectableConversationModel =>
      supportsConversationGeneration &&
      lifecycle != AiModelLifecycle.deprecated &&
      lifecycle != AiModelLifecycle.removed;

  AiModelInfo toModelInfo() => AiModelInfo(
    modelId: id,
    providerId: Bot.apiTypeOpenAI,
    inputModalities: inputModalities,
    outputModalities: outputModalities,
    supportsWebSearch: supportsWebSearch,
    supportsDeepThinking: supportsDeepThinking,
    supportsDeepResearch: supportsDeepResearch,
    supportsMcp: supportsMcp,
    supportsSkills: taskType == AiModelTaskType.chat,
    supportsAutomaticSkillActivation: supportsMcp,
    supportsHostedSkills: false,
    taskType: taskType,
    lifecycle: lifecycle,
    currentSnapshot: currentSnapshot,
    contextWindowTokens: contextWindowTokens,
    maxInputTokens: maxInputTokens,
    maxOutputTokens: maxOutputTokens,
    knowledgeCutoff: knowledgeCutoff,
    supportedEndpoints: endpoints,
    reasoningEfforts: reasoningEfforts,
    supportedFeatures: supportedFeatures,
    nativeTools: nativeTools,
  );

  AiModelInfo enrich(AiModelInfo live) {
    final documented = toModelInfo();
    return AiModelInfo(
      modelId: live.modelId,
      providerId: live.providerId,
      inputModalities:
          live.inputModalities.isEmpty
              ? documented.inputModalities
              : live.inputModalities,
      outputModalities:
          live.outputModalities.isEmpty
              ? documented.outputModalities
              : live.outputModalities,
      supportsWebSearch: live.supportsWebSearch ?? documented.supportsWebSearch,
      supportsDeepThinking:
          live.supportsDeepThinking ?? documented.supportsDeepThinking,
      supportsDeepResearch:
          live.supportsDeepResearch ?? documented.supportsDeepResearch,
      supportsMcp: live.supportsMcp ?? documented.supportsMcp,
      supportsSkills: live.supportsSkills ?? documented.supportsSkills,
      supportsAutomaticSkillActivation:
          live.supportsAutomaticSkillActivation ??
          documented.supportsAutomaticSkillActivation,
      supportsHostedSkills:
          live.supportsHostedSkills ?? documented.supportsHostedSkills,
      taskType: live.taskType ?? documented.taskType,
      lifecycle: live.lifecycle ?? documented.lifecycle,
      currentSnapshot: live.currentSnapshot ?? documented.currentSnapshot,
      contextWindowTokens:
          live.contextWindowTokens ?? documented.contextWindowTokens,
      maxInputTokens: live.maxInputTokens ?? documented.maxInputTokens,
      maxOutputTokens: live.maxOutputTokens ?? documented.maxOutputTokens,
      knowledgeCutoff: live.knowledgeCutoff ?? documented.knowledgeCutoff,
      releaseDate: live.releaseDate,
      supportedEndpoints:
          live.supportedEndpoints.isEmpty
              ? documented.supportedEndpoints
              : live.supportedEndpoints,
      reasoningEfforts:
          live.reasoningEfforts.isEmpty
              ? documented.reasoningEfforts
              : live.reasoningEfforts,
      supportedFeatures:
          live.supportedFeatures.isEmpty
              ? documented.supportedFeatures
              : live.supportedFeatures,
      nativeTools:
          live.nativeTools.isEmpty ? documented.nativeTools : live.nativeTools,
    );
  }
}

const _textInput = [InputModality.text];
const _textImageInput = [InputModality.text, InputModality.image];
const _textAudioInput = [InputModality.text, InputModality.audio];
const _realtimeInput = [
  InputModality.text,
  InputModality.audio,
  InputModality.image,
];
const _textOutput = [OutputModality.text];
const _imageOutput = [OutputModality.image];
const _textAudioOutput = [OutputModality.text, OutputModality.audio];
const _speechOutput = [OutputModality.speech];
const _videoAudioOutput = [OutputModality.video, OutputModality.audio];

const _responsesChatBatch = [
  AiModelEndpoint.responses,
  AiModelEndpoint.chatCompletions,
  AiModelEndpoint.batch,
];
const _responsesChat = [
  AiModelEndpoint.responses,
  AiModelEndpoint.chatCompletions,
];
const _responsesBatch = [AiModelEndpoint.responses, AiModelEndpoint.batch];
const _responsesOnly = [AiModelEndpoint.responses];
const _chatOnly = [AiModelEndpoint.chatCompletions];
const _chatAssistants = [
  AiModelEndpoint.chatCompletions,
  AiModelEndpoint.assistants,
];
const _responsesChatBatchAssistants = [
  AiModelEndpoint.responses,
  AiModelEndpoint.chatCompletions,
  AiModelEndpoint.batch,
  AiModelEndpoint.assistants,
];

const _functionFeatures = {
  'streaming',
  'structured_outputs',
  'function_calling',
  'prompt_caching',
};
const _frontierFeatures = {
  ..._functionFeatures,
  'web_search',
  'file_search',
  'image_input',
  'background',
};
const _frontierTools = {
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
const _reasoningEfforts = ['none', 'low', 'medium', 'high', 'xhigh'];
const _proReasoningEfforts = ['medium', 'high', 'xhigh'];

Iterable<_OpenAiModelSpec> _models(
  List<String> ids, {
  AiModelTaskType taskType = AiModelTaskType.chat,
  List<InputModality> input = _textInput,
  List<OutputModality> output = _textOutput,
  required List<AiModelEndpoint> endpoints,
  AiModelLifecycle lifecycle = AiModelLifecycle.previous,
  int? context,
  int? maxInput,
  int? maxOutput,
  DateTime? knowledgeCutoff,
  List<String> efforts = const [],
  Set<String> features = const {},
  Set<String> tools = const {},
  bool web = false,
  bool thinking = false,
  bool research = false,
  bool official = true,
}) sync* {
  for (final id in ids) {
    yield _OpenAiModelSpec(
      id: id,
      taskType: taskType,
      inputModalities: input,
      outputModalities: output,
      endpoints: endpoints,
      lifecycle: lifecycle,
      contextWindowTokens: context,
      maxInputTokens: maxInput,
      maxOutputTokens: maxOutput,
      knowledgeCutoff: knowledgeCutoff,
      reasoningEfforts: efforts,
      supportedFeatures: features,
      nativeTools: tools,
      supportsWebSearch: web,
      supportsDeepThinking: thinking,
      supportsDeepResearch: research,
      isOfficialModel: official,
    );
  }
}

final Map<String, _OpenAiModelSpec> _openAiModelSpecs = {
  for (final spec in [
    ..._buildOpenAiCoreModelSpecs(),
    ..._buildOpenAiSpecializedModelSpecs(),
    ..._models(
      ['dall-e-2', 'dall-e-3'],
      taskType: AiModelTaskType.imageGeneration,
      input: _textInput,
      output: _imageOutput,
      endpoints: const [AiModelEndpoint.images],
      lifecycle: AiModelLifecycle.removed,
      features: const {'image_generation'},
      official: false,
    ),
  ])
    spec.id: spec,
};

_OpenAiModelSpec? _findOpenAiModelSpec(String modelId) {
  final normalized = modelId.toLowerCase();
  final exact = _openAiModelSpecs[normalized];
  if (exact != null) return exact;
  final withoutDate = normalized.replaceFirst(
    RegExp(r'-(?:\d{4}-\d{2}-\d{2}|\d{8})$'),
    '',
  );
  return _openAiModelSpecs[withoutDate];
}

int _compareOpenAiModels(AiModelInfo left, AiModelInfo right) {
  const recommendedOrder = [
    'gpt-5.6-sol',
    'gpt-5.6',
    'gpt-5.6-terra',
    'gpt-5.6-luna',
  ];
  final leftRecommended = recommendedOrder.indexOf(left.modelId.toLowerCase());
  final rightRecommended = recommendedOrder.indexOf(
    right.modelId.toLowerCase(),
  );
  if (leftRecommended >= 0 || rightRecommended >= 0) {
    if (leftRecommended < 0) return 1;
    if (rightRecommended < 0) return -1;
    return leftRecommended.compareTo(rightRecommended);
  }
  const lifecycleOrder = {
    AiModelLifecycle.recommended: 0,
    AiModelLifecycle.current: 1,
    AiModelLifecycle.preview: 2,
    AiModelLifecycle.previous: 3,
    AiModelLifecycle.deprecated: 4,
    AiModelLifecycle.removed: 5,
  };
  final lifecycleComparison = (lifecycleOrder[left.lifecycle] ?? 3).compareTo(
    lifecycleOrder[right.lifecycle] ?? 3,
  );
  return lifecycleComparison != 0
      ? lifecycleComparison
      : left.modelId.compareTo(right.modelId);
}
