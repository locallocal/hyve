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

List<_OpenAiModelSpec> _buildOpenAiCoreModelSpecs() => [
  ..._models(
    ['gpt-5.6-sol', 'gpt-5.6-terra', 'gpt-5.6-luna'],
    input: _textImageInput,
    endpoints: _responsesChatBatch,
    lifecycle: AiModelLifecycle.recommended,
    context: 1050000,
    maxInput: 922000,
    maxOutput: 128000,
    knowledgeCutoff: DateTime.utc(2026, 2, 16),
    efforts: _reasoningEfforts,
    features: _frontierFeatures,
    tools: _frontierTools,
    web: true,
    thinking: true,
  ),
  _OpenAiModelSpec(
    id: 'gpt-5.6',
    taskType: AiModelTaskType.chat,
    inputModalities: _textImageInput,
    outputModalities: _textOutput,
    endpoints: _responsesChatBatch,
    lifecycle: AiModelLifecycle.recommended,
    currentSnapshot: 'gpt-5.6-sol',
    contextWindowTokens: 1050000,
    maxInputTokens: 922000,
    maxOutputTokens: 128000,
    knowledgeCutoff: DateTime.utc(2026, 2, 16),
    reasoningEfforts: _reasoningEfforts,
    supportedFeatures: _frontierFeatures,
    nativeTools: _frontierTools,
    supportsWebSearch: true,
    supportsDeepThinking: true,
    isOfficialModel: false,
  ),
  ..._models(
    ['gpt-5.5'],
    input: _textImageInput,
    endpoints: _responsesChatBatch,
    context: 1050000,
    maxOutput: 128000,
    efforts: _reasoningEfforts,
    features: _frontierFeatures,
    tools: _frontierTools,
    web: true,
    thinking: true,
  ),
  ..._models(
    ['gpt-5.5-pro'],
    input: _textImageInput,
    endpoints: _responsesBatch,
    context: 1050000,
    maxOutput: 128000,
    efforts: _proReasoningEfforts,
    features: _frontierFeatures,
    tools: _frontierTools,
    web: true,
    thinking: true,
  ),
  ..._models(
    ['gpt-5.4'],
    input: _textImageInput,
    endpoints: _responsesChatBatch,
    context: 1050000,
    maxOutput: 128000,
    efforts: _reasoningEfforts,
    features: _frontierFeatures,
    tools: _frontierTools,
    web: true,
    thinking: true,
  ),
  ..._models(
    ['gpt-5.4-mini', 'gpt-5.4-nano'],
    input: _textImageInput,
    endpoints: _responsesChatBatch,
    context: 400000,
    maxOutput: 128000,
    efforts: _reasoningEfforts,
    features: _frontierFeatures,
    tools: _frontierTools,
    web: true,
    thinking: true,
  ),
  ..._models(
    ['gpt-5.4-pro'],
    input: _textImageInput,
    endpoints: _responsesOnly,
    context: 1050000,
    maxOutput: 128000,
    efforts: _proReasoningEfforts,
    features: _frontierFeatures,
    tools: _frontierTools,
    web: true,
    thinking: true,
  ),
  ..._models(
    ['gpt-5.3-codex'],
    input: _textImageInput,
    endpoints: _responsesOnly,
    context: 400000,
    maxOutput: 128000,
    efforts: _reasoningEfforts,
    features: _frontierFeatures,
    tools: const {'web_search', 'hosted_shell', 'skills'},
    web: true,
    thinking: true,
  ),
  ..._models(
    ['gpt-5.2', 'gpt-5.1', 'gpt-5'],
    input: _textImageInput,
    endpoints: _responsesChatBatch,
    context: 400000,
    maxOutput: 128000,
    efforts: _reasoningEfforts,
    features: _frontierFeatures,
    tools: _frontierTools,
    web: true,
    thinking: true,
  ),
  ..._models(
    ['gpt-5.2-pro'],
    input: _textImageInput,
    endpoints: _responsesBatch,
    context: 400000,
    maxOutput: 128000,
    efforts: _proReasoningEfforts,
    features: _frontierFeatures,
    tools: _frontierTools,
    web: true,
    thinking: true,
  ),
  ..._models(
    ['gpt-5-pro'],
    input: _textImageInput,
    endpoints: _responsesOnly,
    context: 400000,
    maxOutput: 272000,
    efforts: _proReasoningEfforts,
    features: _frontierFeatures,
    tools: _frontierTools,
    web: true,
    thinking: true,
  ),
  ..._models(
    ['gpt-5-mini', 'gpt-5-nano'],
    input: _textImageInput,
    endpoints: _responsesChatBatch,
    context: 400000,
    maxOutput: 128000,
    efforts: _reasoningEfforts,
    features: _frontierFeatures,
    tools: _frontierTools,
    web: true,
    thinking: true,
  ),
  ..._models(
    [
      'gpt-5.2-codex',
      'gpt-5.1-codex',
      'gpt-5.1-codex-mini',
      'gpt-5.1-codex-max',
      'gpt-5-codex',
    ],
    input: _textImageInput,
    endpoints: _responsesOnly,
    context: 400000,
    maxOutput: 128000,
    efforts: _reasoningEfforts,
    features: _frontierFeatures,
    tools: const {'web_search', 'hosted_shell', 'skills'},
    web: true,
    thinking: true,
  ),
  ..._models(
    ['codex-mini-latest'],
    input: _textImageInput,
    endpoints: _responsesOnly,
    context: 200000,
    maxOutput: 100000,
    efforts: const ['low', 'medium', 'high'],
    features: _functionFeatures,
    tools: const {'hosted_shell'},
    thinking: true,
  ),
  ..._models(
    ['gpt-4.1', 'gpt-4.1-mini'],
    input: _textImageInput,
    endpoints: _responsesChatBatchAssistants,
    context: 1047576,
    maxOutput: 32768,
    features: const {
      ..._functionFeatures,
      'image_input',
      'web_search',
      'file_search',
      'predicted_outputs',
      'fine_tuning',
    },
    tools: const {'web_search', 'file_search'},
    web: true,
  ),
  ..._models(
    ['gpt-4.1-nano'],
    input: _textImageInput,
    endpoints: _responsesChatBatchAssistants,
    context: 1047576,
    maxOutput: 32768,
    features: const {
      ..._functionFeatures,
      'image_input',
      'file_search',
      'predicted_outputs',
      'fine_tuning',
    },
    tools: const {'file_search'},
  ),
  ..._models(
    ['gpt-4o', 'gpt-4o-mini'],
    input: _textImageInput,
    endpoints: _responsesChatBatchAssistants,
    context: 128000,
    maxOutput: 16384,
    features: const {
      ..._functionFeatures,
      'image_input',
      'web_search',
      'file_search',
      'predicted_outputs',
      'fine_tuning',
    },
    tools: const {'web_search', 'file_search'},
    web: true,
  ),
  ..._models(
    ['o1'],
    input: _textImageInput,
    endpoints: _responsesChatBatch,
    context: 200000,
    maxOutput: 100000,
    efforts: const ['low', 'medium', 'high'],
    features: _functionFeatures,
    tools: const {'file_search', 'mcp'},
    thinking: true,
  ),
  ..._models(
    ['o1-pro'],
    input: _textImageInput,
    endpoints: _responsesBatch,
    context: 200000,
    maxOutput: 100000,
    efforts: _proReasoningEfforts,
    features: _functionFeatures,
    tools: const {'file_search', 'mcp'},
    thinking: true,
  ),
  ..._models(
    ['o1-mini'],
    endpoints: _chatAssistants,
    context: 128000,
    maxOutput: 65536,
    efforts: const ['medium'],
    features: const {'streaming'},
    thinking: true,
  ),
  ..._models(
    ['o1-preview'],
    endpoints: _chatAssistants,
    lifecycle: AiModelLifecycle.preview,
    context: 128000,
    maxOutput: 32768,
    efforts: const ['medium'],
    features: const {'streaming'},
    thinking: true,
  ),
  ..._models(
    ['o3', 'o4-mini'],
    input: _textImageInput,
    endpoints: _responsesChatBatch,
    context: 200000,
    maxOutput: 100000,
    efforts: const ['low', 'medium', 'high'],
    features: _frontierFeatures,
    tools: const {'web_search', 'file_search', 'code_interpreter', 'mcp'},
    web: true,
    thinking: true,
  ),
  ..._models(
    ['o3-pro'],
    input: _textImageInput,
    endpoints: _responsesBatch,
    context: 200000,
    maxOutput: 100000,
    efforts: _proReasoningEfforts,
    features: _frontierFeatures,
    tools: const {'web_search', 'file_search', 'code_interpreter', 'mcp'},
    web: true,
    thinking: true,
  ),
  ..._models(
    ['o3-mini'],
    endpoints: _responsesChatBatchAssistants,
    context: 200000,
    maxOutput: 100000,
    efforts: const ['low', 'medium', 'high'],
    features: _functionFeatures,
    tools: const {'file_search', 'code_interpreter', 'mcp'},
    thinking: true,
  ),
  ..._models(
    ['computer-use-preview'],
    taskType: AiModelTaskType.computerUse,
    input: _textImageInput,
    endpoints: _responsesBatch,
    lifecycle: AiModelLifecycle.preview,
    context: 8192,
    maxOutput: 1024,
    features: const {'function_calling', 'computer_use'},
    tools: const {'computer_use'},
  ),
  ..._models(
    ['gpt-3.5-turbo'],
    endpoints: _chatOnly,
    context: 16385,
    maxOutput: 4096,
    features: _functionFeatures,
  ),
  ..._models(
    ['gpt-4'],
    endpoints: _chatOnly,
    context: 8192,
    maxOutput: 8192,
    features: _functionFeatures,
  ),
  ..._models(
    ['gpt-4-turbo'],
    input: _textImageInput,
    endpoints: _chatOnly,
    context: 128000,
    maxOutput: 4096,
    features: const {..._functionFeatures, 'image_input'},
  ),
  ..._models(
    ['gpt-4-turbo-preview'],
    endpoints: _chatOnly,
    lifecycle: AiModelLifecycle.preview,
    context: 128000,
    maxOutput: 4096,
    features: _functionFeatures,
  ),
  ..._models(
    ['gpt-4.5-preview'],
    input: _textImageInput,
    endpoints: _responsesChatBatch,
    lifecycle: AiModelLifecycle.deprecated,
    context: 128000,
    maxOutput: 16384,
    features: const {..._functionFeatures, 'image_input'},
  ),
  ..._models(
    ['babbage-002', 'davinci-002'],
    taskType: AiModelTaskType.legacyCompletion,
    endpoints: const [AiModelEndpoint.legacyCompletions],
    context: 16384,
    maxOutput: 4096,
    features: const {'fine_tuning'},
  ),
  ..._models(
    ['chat-latest', 'gpt-5-chat-latest', 'gpt-5.1-chat-latest'],
    input: _textImageInput,
    endpoints: _responsesChat,
    context: 128000,
    maxOutput: 16384,
    features: const {..._functionFeatures, 'image_input'},
    thinking: true,
  ),
  ..._models(
    ['gpt-5.2-chat-latest', 'gpt-5.3-chat-latest'],
    input: _textImageInput,
    endpoints: _responsesChat,
    lifecycle: AiModelLifecycle.deprecated,
    context: 128000,
    maxOutput: 16384,
    features: const {..._functionFeatures, 'image_input'},
    thinking: true,
  ),
  ..._models(
    ['chatgpt-4o-latest'],
    input: _textImageInput,
    endpoints: _chatOnly,
    lifecycle: AiModelLifecycle.removed,
    context: 128000,
    maxOutput: 16384,
    features: const {..._functionFeatures, 'image_input'},
  ),
];

List<_OpenAiModelSpec> _buildOpenAiSpecializedModelSpecs() => [
  ..._models(
    ['gpt-4o-search-preview', 'gpt-4o-mini-search-preview'],
    endpoints: _chatOnly,
    lifecycle: AiModelLifecycle.preview,
    context: 128000,
    maxOutput: 16384,
    features: const {'streaming', 'structured_outputs', 'built_in_web_search'},
    tools: const {'web_search'},
    web: true,
  ),
  ..._models(
    ['o3-deep-research', 'o4-mini-deep-research'],
    taskType: AiModelTaskType.deepResearch,
    input: _textImageInput,
    endpoints: _responsesBatch,
    context: 200000,
    maxOutput: 100000,
    efforts: const ['low', 'medium', 'high'],
    features: const {
      ..._functionFeatures,
      'web_search',
      'deep_research',
      'image_input',
      'background',
    },
    tools: const {'web_search', 'code_interpreter', 'mcp'},
    web: true,
    thinking: true,
    research: true,
  ),
  ..._models(
    ['gpt-image-2'],
    taskType: AiModelTaskType.imageGeneration,
    input: _textImageInput,
    output: _imageOutput,
    endpoints: const [AiModelEndpoint.images, AiModelEndpoint.batch],
    lifecycle: AiModelLifecycle.current,
    features: const {
      'image_generation',
      'image_edit',
      'inpainting',
      'streaming',
    },
  ),
  ..._models(
    ['gpt-image-1.5'],
    taskType: AiModelTaskType.imageGeneration,
    input: _textImageInput,
    output: const [OutputModality.image, OutputModality.text],
    endpoints: const [AiModelEndpoint.images, AiModelEndpoint.batch],
    features: const {
      'image_generation',
      'image_edit',
      'inpainting',
      'streaming',
    },
  ),
  ..._models(
    ['gpt-image-1'],
    taskType: AiModelTaskType.imageGeneration,
    input: _textImageInput,
    output: _imageOutput,
    endpoints: const [
      AiModelEndpoint.images,
      AiModelEndpoint.responses,
      AiModelEndpoint.batch,
    ],
    features: const {
      'image_generation',
      'image_edit',
      'inpainting',
      'streaming',
    },
  ),
  ..._models(
    ['gpt-image-1-mini', 'chatgpt-image-latest'],
    taskType: AiModelTaskType.imageGeneration,
    input: _textImageInput,
    output: _imageOutput,
    endpoints: const [AiModelEndpoint.images, AiModelEndpoint.batch],
    features: const {'image_generation', 'image_edit', 'inpainting'},
  ),
  ..._models(
    ['sora-2', 'sora-2-pro'],
    taskType: AiModelTaskType.videoGeneration,
    input: _textImageInput,
    output: _videoAudioOutput,
    endpoints: const [AiModelEndpoint.videos],
    lifecycle: AiModelLifecycle.current,
    features: const {
      'video_generation',
      'synchronized_audio',
      'image_reference',
      'async_polling',
    },
  ),
  ..._models(
    [
      'gpt-audio-1.5',
      'gpt-audio',
      'gpt-audio-mini',
      'gpt-4o-audio-preview',
      'gpt-4o-mini-audio-preview',
    ],
    taskType: AiModelTaskType.audio,
    input: _textAudioInput,
    output: _textAudioOutput,
    endpoints: _chatOnly,
    context: 128000,
    maxOutput: 16384,
    features: const {'streaming', 'function_calling', 'audio_input_output'},
  ),
  ..._models(
    ['gpt-realtime-2.1', 'gpt-realtime-2.1-mini', 'gpt-realtime-2'],
    taskType: AiModelTaskType.realtime,
    input: _realtimeInput,
    output: _textAudioOutput,
    endpoints: const [AiModelEndpoint.realtime],
    context: 128000,
    maxOutput: 32000,
    efforts: _reasoningEfforts,
    features: const {
      'streaming',
      'function_calling',
      'prompt_caching',
      'webrtc',
      'websocket',
      'sip',
    },
    thinking: true,
  ),
  ..._models(
    [
      'gpt-realtime-1.5',
      'gpt-realtime',
      'gpt-realtime-mini',
      'gpt-4o-realtime-preview',
      'gpt-4o-mini-realtime-preview',
    ],
    taskType: AiModelTaskType.realtime,
    input: _realtimeInput,
    output: _textAudioOutput,
    endpoints: const [AiModelEndpoint.realtime],
    lifecycle: AiModelLifecycle.preview,
    context: 32000,
    maxOutput: 4096,
    features: const {
      'streaming',
      'function_calling',
      'prompt_caching',
      'webrtc',
      'websocket',
      'sip',
    },
  ),
  ..._models(
    ['gpt-realtime-translate'],
    taskType: AiModelTaskType.realtime,
    input: const [InputModality.audio],
    output: _textAudioOutput,
    endpoints: const [AiModelEndpoint.realtime],
    context: 16000,
    maxOutput: 2000,
    features: const {'streaming', 'translation'},
  ),
  ..._models(
    ['gpt-realtime-whisper'],
    taskType: AiModelTaskType.realtime,
    input: _textAudioInput,
    output: _textOutput,
    endpoints: const [AiModelEndpoint.realtime],
    context: 16000,
    maxOutput: 2000,
    features: const {'streaming', 'transcription'},
  ),
  ..._models(
    ['gpt-transcribe'],
    taskType: AiModelTaskType.transcription,
    input: _textAudioInput,
    output: _textOutput,
    endpoints: const [AiModelEndpoint.audioTranscriptions],
    features: const {'transcription'},
  ),
  ..._models(
    ['gpt-live-transcribe'],
    taskType: AiModelTaskType.transcription,
    input: _textAudioInput,
    output: _textOutput,
    endpoints: const [
      AiModelEndpoint.audioTranscriptions,
      AiModelEndpoint.realtime,
    ],
    features: const {'streaming', 'transcription'},
  ),
  ..._models(
    ['gpt-4o-transcribe', 'gpt-4o-mini-transcribe'],
    taskType: AiModelTaskType.transcription,
    input: _textAudioInput,
    output: _textOutput,
    endpoints: const [AiModelEndpoint.audioTranscriptions],
    context: 16000,
    maxOutput: 2000,
    features: const {'transcription'},
  ),
  ..._models(
    ['gpt-4o-transcribe-diarize'],
    taskType: AiModelTaskType.transcription,
    input: _textAudioInput,
    output: _textOutput,
    endpoints: const [AiModelEndpoint.audioTranscriptions],
    context: 16000,
    maxOutput: 2000,
    features: const {'transcription', 'diarization'},
  ),
  ..._models(
    ['whisper-1'],
    taskType: AiModelTaskType.transcription,
    input: const [InputModality.audio],
    output: _textOutput,
    endpoints: const [
      AiModelEndpoint.audioTranscriptions,
      AiModelEndpoint.audioTranslations,
    ],
    features: const {'transcription', 'translation'},
  ),
  ..._models(
    ['gpt-4o-mini-tts', 'tts-1', 'tts-1-hd'],
    taskType: AiModelTaskType.speech,
    input: _textInput,
    output: _speechOutput,
    endpoints: const [AiModelEndpoint.speech],
    features: const {'text_to_speech', 'streaming'},
  ),
  ..._models(
    [
      'text-embedding-3-large',
      'text-embedding-3-small',
      'text-embedding-ada-002',
    ],
    taskType: AiModelTaskType.embedding,
    input: _textInput,
    output: const [],
    endpoints: const [AiModelEndpoint.embeddings, AiModelEndpoint.batch],
    features: const {'embeddings'},
  ),
  ..._models(
    ['omni-moderation-latest'],
    taskType: AiModelTaskType.moderation,
    input: _textImageInput,
    output: const [],
    endpoints: const [AiModelEndpoint.moderation, AiModelEndpoint.batch],
    lifecycle: AiModelLifecycle.current,
    features: const {'moderation', 'image_input'},
  ),
  ..._models(
    ['text-moderation-latest', 'text-moderation-stable'],
    taskType: AiModelTaskType.moderation,
    input: _textInput,
    output: const [],
    endpoints: const [AiModelEndpoint.moderation, AiModelEndpoint.batch],
    features: const {'moderation'},
  ),
  ..._models(
    ['gpt-oss-120b', 'gpt-oss-20b'],
    input: _textInput,
    endpoints: _responsesBatch,
    lifecycle: AiModelLifecycle.current,
    context: 131072,
    maxOutput: 131072,
    efforts: const ['low', 'medium', 'high'],
    features: const {
      ..._functionFeatures,
      'open_weights',
      'fine_tuning',
      'web_search',
      'code_interpreter',
    },
    tools: const {'web_search', 'code_interpreter', 'mcp'},
    web: true,
    thinking: true,
  ),
];

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
