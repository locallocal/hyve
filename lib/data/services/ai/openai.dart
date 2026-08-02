import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:stars/data/services/ai/provider_service.dart';
import 'package:stars/data/services/ai/skill_tool_sessions.dart';
import 'package:stars/domain/models/models.dart';

class OpenAI extends Provider {
  static const String defaultApiModelsUrl = 'https://api.openai.com/v1/models';
  static const String defaultApiChatUrl =
      'https://api.openai.com/v1/chat/completions';
  static const String defaultApiResponsesUrl =
      'https://api.openai.com/v1/responses';
  static const String defaultApiImageUrl =
      'https://api.openai.com/v1/images/generations';
  static const String defaultApiImageEditUrl =
      'https://api.openai.com/v1/images/edits';
  static const String defaultApiSpeechUrl =
      'https://api.openai.com/v1/audio/speech';
  static const String defaultApiVideosUrl = 'https://api.openai.com/v1/videos';

  OpenAI(super.bot, {http.Client? skillToolClient})
    : _skillToolClient = skillToolClient;

  final http.Client? _skillToolClient;

  static Set<String> get officialModelIds => Set<String>.unmodifiable(
    _openAiModelSpecs.values
        .where((spec) => spec.isOfficialModel)
        .map((spec) => spec.id),
  );

  static List<AiModelInfo> get documentedModels =>
      List<AiModelInfo>.unmodifiable(
        _openAiModelSpecs.values.map((spec) => spec.toModelInfo()),
      );

  @override
  AiProviderCapabilities get capabilities => const AiProviderCapabilities(
    supportsStructuredToolCalls: true,
    supportsToolResults: true,
    supportsParallelToolCalls: true,
  );

  @override
  AgentModelSession openModelSession(ModelRequest request) {
    final client = _skillToolClient ?? http.Client();
    if (_usesResponsesApi) {
      return OpenAiResponsesAgentModelSession(
        bot: bot,
        request: request,
        formattedInput: _processMessagesForResponses(request.messages),
        uri: Uri.parse(_endpoint('responses', defaultApiResponsesUrl)),
        headers: _headers,
        client: client,
        closeClient: _skillToolClient == null,
        decodeResponse: decodeProviderResponse,
        reasoningEffort: _selectedReasoningEffort,
      );
    }
    return OpenAiAgentModelSession(
      bot: bot,
      request: request,
      formattedMessages: processMessagesWithImages(request.messages),
      uri: Uri.parse(_endpoint('chat/completions', defaultApiChatUrl)),
      headers: _headers,
      client: client,
      closeClient: _skillToolClient == null,
      decodeResponse: decodeProviderResponse,
      reasoningEffort: _selectedReasoningEffort,
    );
  }

  @override
  SkillToolSession openSkillToolSession(SkillToolSessionRequest request) {
    final client = _skillToolClient ?? http.Client();
    if (_usesResponsesApi) {
      return OpenAiResponsesSkillToolSession(
        bot: bot,
        request: request,
        formattedInput: _processMessagesForResponses(request.messages),
        uri: Uri.parse(_endpoint('responses', defaultApiResponsesUrl)),
        headers: _headers,
        client: client,
        closeClient: _skillToolClient == null,
        decodeResponse: decodeProviderResponse,
      );
    }
    return OpenAiSkillToolSession(
      bot: bot,
      request: request,
      formattedMessages: processMessagesWithImages(request.messages),
      uri: Uri.parse(_endpoint('chat/completions', defaultApiChatUrl)),
      headers: _headers,
      client: client,
      closeClient: _skillToolClient == null,
      decodeResponse: decodeProviderResponse,
    );
  }

  @override
  bool supportWebSearch() {
    final documented = _selectedModelSpec?.supportsWebSearch;
    if (documented != null) return documented;
    return builtInModelInfo()?.supportsWebSearch ?? false;
  }

  @override
  bool supportDeepThinking() {
    final documented = _selectedModelSpec?.supportsDeepThinking;
    if (documented != null) return documented;
    return builtInModelInfo()?.supportsDeepThinking ?? false;
  }

  @override
  bool supportDeepResearch() =>
      _selectedModelSpec?.supportsDeepResearch ?? false;

  @override
  bool supportMcp() {
    final configured = bot.configuredSupportsMcp;
    final modelSupportsMcp =
        configured ??
        _selectedModelSpec?.supportsMcp ??
        builtInModelInfo()?.supportsMcp ??
        false;
    return modelSupportsMcp && capabilities.supportsAgentLoop;
  }

  @override
  List<InputModality> getInputModalites() {
    final documented = _selectedModelSpec?.inputModalities;
    if (documented != null) return documented;
    return builtInModelInfo()?.inputModalities ?? const [InputModality.text];
  }

  @override
  List<OutputModality> getOutputModalites() {
    return _selectedModelSpec?.outputModalities ??
        builtInModelInfo()?.outputModalities ??
        const [OutputModality.text];
  }

  @override
  Future<List<AiModelInfo>> fetchModels() async {
    final client = _skillToolClient ?? http.Client();
    try {
      final response = await client
          .get(
            Uri.parse(_endpoint('models', defaultApiModelsUrl)),
            headers: _authorizationHeaders,
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'List models failed: ${response.statusCode}- ${response.body}',
        );
      }
      final data = decodeProviderResponse(utf8.decode(response.bodyBytes));
      final rawModels = data['data'];
      if (rawModels is! List) {
        throw const FormatException('OpenAI model catalog is not a list');
      }
      final liveModels = rawModels.whereType<Map>().map((raw) {
        final model = Map<String, dynamic>.from(raw);
        final live = providerModelInfo(model);
        final spec =
            _isFirstPartyOpenAi ? _findOpenAiModelSpec(live.modelId) : null;
        return spec == null ? live : spec.enrich(live);
      });

      final merged = <String, AiModelInfo>{
        for (final model in liveModels) model.modelId.toLowerCase(): model,
      };
      if (_isFirstPartyOpenAi) {
        for (final id in const [
          'gpt-5.6-sol',
          'gpt-5.6',
          'gpt-5.6-terra',
          'gpt-5.6-luna',
        ]) {
          merged.putIfAbsent(id, () => _openAiModelSpecs[id]!.toModelInfo());
        }
      }

      final selectable = merged.values
          .where((model) {
            if (!_isFirstPartyOpenAi) return true;
            final spec = _findOpenAiModelSpec(model.modelId);
            return spec == null || spec.isSelectableConversationModel;
          })
          .toList(growable: false);
      selectable.sort(_compareOpenAiModels);
      return selectable;
    } on TimeoutException {
      throw Exception('List models Timeout, retry later.');
    } catch (e) {
      throw Exception('List models failed: $e');
    } finally {
      if (_skillToolClient == null) client.close();
    }
  }

  @override
  Future<void> generateText(List<ChatMessage> messages) async {
    final client = _skillToolClient ?? http.Client();
    try {
      resetCancelState();
      final spec = _selectedModelSpec;
      if (spec != null && !spec.supportsConversationGeneration) {
        throw UnsupportedError(
          'Model ${bot.model} uses ${spec.taskType.value} and cannot generate '
          'chat text.',
        );
      }

      if (_usesResponsesApi) {
        await generateResponsesText(
          url: _endpoint('responses', defaultApiResponsesUrl),
          headers: _headers,
          messages: messages,
          formattedInput: _processMessagesForResponses(messages),
          includeWebSearch: webSearch,
          reasoning:
              deepThinking && _selectedReasoningEffort != null
                  ? {'effort': _selectedReasoningEffort!, 'summary': 'auto'}
                  : null,
          client: client,
        );
        if (!isCancelled && onComplete != null) onComplete!();
        return;
      }

      final request =
          http.Request(
              'POST',
              Uri.parse(_endpoint('chat/completions', defaultApiChatUrl)),
            )
            ..headers.addAll(_headers)
            ..body = jsonEncode({
              'model': bot.model,
              'messages': processMessagesWithImages(messages),
              'response_format': {'type': 'text'},
              'stream': true,
              'stream_options': {'include_usage': true},
              if (webSearch && _isSearchPreviewModel)
                'web_search_options': <String, Object?>{},
              if (deepThinking && _selectedReasoningEffort != null)
                'reasoning_effort': _selectedReasoningEffort,
            });

      cancelController?.stream.listen((_) => client.close());
      final streamedResponse = await client.send(request);
      if (streamedResponse.statusCode < 200 ||
          streamedResponse.statusCode >= 300) {
        final body = await streamedResponse.stream.bytesToString();
        throw Exception('${streamedResponse.statusCode}, $body');
      }
      final stream = streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (isCancelled) break;
        if (!line.startsWith('data: ')) continue;
        final jsonSource = line.substring(6).trim();
        if (jsonSource == '[DONE]') {
          if (!isCancelled && onComplete != null) onComplete!();
          return;
        }
        if (jsonSource.isEmpty) continue;
        final data = decodeProviderResponse(jsonSource);
        final choices = data['choices'];
        if (choices is! List || choices.isEmpty || choices.first is! Map) {
          continue;
        }
        final choice = Map<String, dynamic>.from(choices.first as Map);
        final delta =
            choice['delta'] is Map
                ? Map<String, dynamic>.from(choice['delta'] as Map)
                : const <String, dynamic>{};
        final reasoning =
            delta['reasoning_content']?.toString() ??
            delta['reasoning']?.toString() ??
            '';
        if (deepThinking &&
            reasoning.isNotEmpty &&
            onReasoningResponse != null) {
          onReasoningResponse!(reasoning);
        }
        final content = delta['content']?.toString() ?? '';
        if (content.isNotEmpty) onResponse(content);
      }

      if (!isCancelled && onComplete != null) {
        onComplete!();
      } else if (isCancelled && onError != null) {
        onError!('Request cancelled');
      }
    } catch (e) {
      if (!isCancelled && onError != null) {
        onError!(e.toString());
      }
    } finally {
      if (cancelController?.isClosed == false) cancelController?.close();
      cancelController = null;
      if (_skillToolClient == null) client.close();
    }
  }

  @override
  List<String> getSupportedImageSizes() {
    final model = bot.model.toLowerCase();
    if (model == 'dall-e-3') {
      return ['1024x1024', '1792x1024', '1024x1792'];
    }
    if (model == 'dall-e-2') {
      return ['256x256', '512x512', '1024x1024'];
    }
    if (_selectedModelSpec?.taskType == AiModelTaskType.imageGeneration) {
      return ['1024x1024', '1536x1024', '1024x1536', 'auto'];
    }
    return const [];
  }

  @override
  Future<List<String>> generateImage(
    String prompt,
    String size,
    String imageDirPath, {
    List<String> referenceImages = const [],
    String style = '',
  }) async {
    final spec = _selectedModelSpec;
    final isLegacyDallE = bot.model.toLowerCase().startsWith('dall-e-');
    if (spec?.taskType != AiModelTaskType.imageGeneration && !isLegacyDallE) {
      throw UnsupportedError(
        'Model ${bot.model} does not support the OpenAI Images API.',
      );
    }
    final client = _skillToolClient ?? http.Client();
    try {
      late http.Response response;
      if (referenceImages.isEmpty) {
        final requestBody = <String, Object?>{
          'model': bot.model,
          'prompt': prompt,
          'n': 1,
          if (size.isNotEmpty) 'size': size,
          if (isLegacyDallE) 'response_format': 'url',
          if (isLegacyDallE && style.isNotEmpty) 'style': style,
        };
        response = await client.post(
          Uri.parse(_endpoint('images/generations', defaultApiImageUrl)),
          headers: _headers,
          body: jsonEncode(requestBody),
        );
      } else {
        if (isLegacyDallE) {
          throw UnsupportedError(
            'Reference-image editing requires a GPT Image model.',
          );
        }
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(_endpoint('images/edits', defaultApiImageEditUrl)),
        )..headers.addAll(_authorizationHeaders);
        request.fields.addAll({
          'model': bot.model,
          'prompt': prompt,
          if (size.isNotEmpty) 'size': size,
        });
        for (final imagePath in referenceImages) {
          if (!File(imagePath).existsSync()) continue;
          request.files.add(
            await http.MultipartFile.fromPath('image[]', imagePath),
          );
        }
        if (request.files.isEmpty) {
          throw const FileSystemException('No readable reference images.');
        }
        response = await http.Response.fromStream(await client.send(request));
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Generate image failed: ${response.statusCode} - ${response.body}',
        );
      }
      final data = decodeProviderResponse(utf8.decode(response.bodyBytes));
      return _persistImages(data, imageDirPath, client);
    } catch (e) {
      throw Exception('Generate image failed: $e');
    } finally {
      if (_skillToolClient == null) client.close();
    }
  }

  @override
  List<String> getSupportVoicTypes() {
    if (_selectedModelSpec?.taskType != AiModelTaskType.speech) return const [];
    if (bot.model == 'tts-1' || bot.model == 'tts-1-hd') {
      return const [
        'alloy',
        'ash',
        'coral',
        'echo',
        'fable',
        'onyx',
        'nova',
        'sage',
        'shimmer',
      ];
    }
    return const [
      'alloy',
      'ash',
      'ballad',
      'coral',
      'echo',
      'fable',
      'nova',
      'onyx',
      'sage',
      'shimmer',
      'verse',
      'marin',
      'cedar',
    ];
  }

  @override
  Future<String> generateSpeech(
    String prompt,
    String voiceType,
    String outputDirPath,
  ) async {
    if (_selectedModelSpec?.taskType != AiModelTaskType.speech) {
      throw UnsupportedError(
        'Model ${bot.model} does not support the OpenAI Speech API.',
      );
    }
    final client = _skillToolClient ?? http.Client();
    try {
      final response = await client.post(
        Uri.parse(_endpoint('audio/speech', defaultApiSpeechUrl)),
        headers: _headers,
        body: jsonEncode({
          'model': bot.model,
          'input': prompt,
          'voice': voiceType,
          'response_format': 'mp3',
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Generate speech failed: ${response.statusCode} - ${response.body}',
        );
      }
      await Directory(outputDirPath).create(recursive: true);
      final path =
          '$outputDirPath/openai_speech_${DateTime.now().millisecondsSinceEpoch}.mp3';
      await File(path).writeAsBytes(response.bodyBytes);
      return path;
    } finally {
      if (_skillToolClient == null) client.close();
    }
  }

  @override
  List<String> getSupportVideoResolutions() {
    if (_selectedModelSpec?.taskType != AiModelTaskType.videoGeneration) {
      return const [];
    }
    return bot.model.toLowerCase() == 'sora-2-pro'
        ? const ['1920x1080', '1080x1920']
        : const ['1280x720', '720x1280'];
  }

  @override
  List<String> getSupportVideoRatios() {
    if (_selectedModelSpec?.taskType != AiModelTaskType.videoGeneration) {
      return const [];
    }
    return const ['16:9', '9:16'];
  }

  @override
  Future<String> generateVideo(
    String prompt,
    String ratio,
    String outputDirPath,
    List<String> referImages,
  ) async {
    if (_selectedModelSpec?.taskType != AiModelTaskType.videoGeneration) {
      throw UnsupportedError(
        'Model ${bot.model} does not support the OpenAI Videos API.',
      );
    }
    final size = _videoSize(ratio);
    final client = _skillToolClient ?? http.Client();
    try {
      late http.Response createResponse;
      String? reference;
      for (final imagePath in referImages) {
        if (File(imagePath).existsSync()) {
          reference = imagePath;
          break;
        }
      }
      if (reference == null) {
        createResponse = await client.post(
          Uri.parse(_endpoint('videos', defaultApiVideosUrl)),
          headers: _headers,
          body: jsonEncode({
            'model': bot.model,
            'prompt': prompt,
            'size': size,
          }),
        );
      } else {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(_endpoint('videos', defaultApiVideosUrl)),
        )..headers.addAll(_authorizationHeaders);
        request.fields.addAll({
          'model': bot.model,
          'prompt': prompt,
          'size': size,
        });
        request.files.add(
          await http.MultipartFile.fromPath('input_reference', reference),
        );
        createResponse = await http.Response.fromStream(
          await client.send(request),
        );
      }
      _ensureSuccess(createResponse, 'Generate video');
      var video = Map<String, dynamic>.from(
        decodeProviderResponse(utf8.decode(createResponse.bodyBytes)) as Map,
      );
      final videoId = video['id']?.toString() ?? '';
      if (videoId.isEmpty) {
        throw const FormatException('Video response is missing an id.');
      }

      for (var attempt = 0; attempt < 300; attempt++) {
        final status = video['status']?.toString();
        if (status == 'completed') break;
        if (status == 'failed' || status == 'expired') {
          throw Exception(video['error'] ?? 'Video generation $status.');
        }
        await Future<void>.delayed(const Duration(seconds: 2));
        final pollResponse = await client.get(
          Uri.parse(
            _endpoint('videos/$videoId', '$defaultApiVideosUrl/$videoId'),
          ),
          headers: _authorizationHeaders,
        );
        _ensureSuccess(pollResponse, 'Poll video');
        video = Map<String, dynamic>.from(
          decodeProviderResponse(utf8.decode(pollResponse.bodyBytes)) as Map,
        );
      }
      if (video['status'] != 'completed') {
        throw TimeoutException('Video generation timed out.');
      }

      final contentResponse = await client.get(
        Uri.parse(
          _endpoint(
            'videos/$videoId/content',
            '$defaultApiVideosUrl/$videoId/content',
          ),
        ),
        headers: _authorizationHeaders,
      );
      _ensureSuccess(contentResponse, 'Download video');
      await Directory(outputDirPath).create(recursive: true);
      final path = '$outputDirPath/openai_video_$videoId.mp4';
      await File(path).writeAsBytes(contentResponse.bodyBytes);
      return path;
    } finally {
      if (_skillToolClient == null) client.close();
    }
  }

  @override
  List<Map<String, dynamic>> processMessagesWithImages(
    List<ChatMessage> messages,
  ) {
    return messages
        .map((message) {
          final role = _normalizedMessageRole(message.role);
          if (message.images.isEmpty) {
            return {'role': role, 'content': message.content};
          }
          final content = <Map<String, dynamic>>[];
          if (message.content.isNotEmpty) {
            content.add({'type': 'text', 'text': message.content});
          }

          for (final imagePath in message.images) {
            try {
              final file = File(imagePath);
              if (file.existsSync()) {
                final bytes = file.readAsBytesSync();
                content.add({
                  'type': 'image_url',
                  'image_url': {
                    'url':
                        'data:${getImageMediaType(bytes)};base64,${base64Encode(bytes)}',
                  },
                });
              }
            } catch (_) {
              // Skip an unreadable optional image and continue the request.
            }
          }
          return {'role': role, 'content': content};
        })
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _processMessagesForResponses(
    List<ChatMessage> messages,
  ) {
    return messages
        .map((message) {
          final content = <Map<String, dynamic>>[];
          if (message.content.isNotEmpty) {
            content.add({'type': 'input_text', 'text': message.content});
          }
          for (final imagePath in message.images) {
            try {
              final bytes = File(imagePath).readAsBytesSync();
              content.add({
                'type': 'input_image',
                'image_url':
                    'data:${getImageMediaType(bytes)};base64,${base64Encode(bytes)}',
              });
            } on FileSystemException {
              // Ignore an optional image that was removed before sending.
            }
          }
          return {
            'role': _normalizedMessageRole(message.role),
            'content': content,
          };
        })
        .toList(growable: false);
  }

  Future<List<String>> _persistImages(
    Object? decoded,
    String imageDirPath,
    http.Client client,
  ) async {
    if (decoded is! Map || decoded['data'] is! List) {
      throw const FormatException('Image response has no data array.');
    }
    await Directory(imageDirPath).create(recursive: true);
    final paths = <String>[];
    var index = 0;
    for (final rawImage in decoded['data'] as List) {
      if (rawImage is! Map) continue;
      final image = Map<String, dynamic>.from(rawImage);
      List<int>? bytes;
      final encoded = image['b64_json']?.toString();
      if (encoded != null && encoded.isNotEmpty) {
        bytes = base64Decode(encoded);
      } else {
        final url = image['url']?.toString();
        if (url != null && url.isNotEmpty) {
          final response = await client.get(Uri.parse(url));
          _ensureSuccess(response, 'Download image');
          bytes = response.bodyBytes;
        }
      }
      if (bytes == null) continue;
      final path =
          '$imageDirPath/openai_image_${DateTime.now().microsecondsSinceEpoch}_$index.png';
      await File(path).writeAsBytes(bytes);
      paths.add(path);
      index += 1;
    }
    if (paths.isEmpty) {
      throw const FormatException('Image response contained no image output.');
    }
    return paths;
  }

  void _ensureSuccess(http.Response response, String operation) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        '$operation failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  String _videoSize(String ratio) {
    final resolutions = getSupportVideoResolutions();
    if (resolutions.isEmpty) return '';
    return ratio == '9:16' ? resolutions.last : resolutions.first;
  }

  String _normalizedMessageRole(String role) {
    if (role == 'system' && supportDeepThinking()) return 'developer';
    return role;
  }

  String _endpoint(String path, String defaultUrl) {
    if (bot.baseURL.isEmpty) return defaultUrl;
    final base = bot.baseURL.endsWith('/') ? bot.baseURL : '${bot.baseURL}/';
    final relative = path.startsWith('/') ? path.substring(1) : path;
    return '$base$relative';
  }

  Map<String, String> get _authorizationHeaders => {
    'Authorization': 'Bearer ${bot.apiKey}',
  };

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    ..._authorizationHeaders,
  };

  bool get _isFirstPartyOpenAi =>
      bot.apiType == Bot.apiTypeOpenAI &&
      bot.provider.toLowerCase() == Bot.apiTypeOpenAI;

  _OpenAiModelSpec? get _selectedModelSpec =>
      _isFirstPartyOpenAi ? _findOpenAiModelSpec(bot.model) : null;

  bool get _usesResponsesApi =>
      _isFirstPartyOpenAi &&
      _selectedModelSpec?.preferredEndpoint == AiModelEndpoint.responses;

  bool get _isSearchPreviewModel =>
      _selectedModelSpec?.supportedFeatures.contains('built_in_web_search') ==
      true;

  String? get _selectedReasoningEffort {
    final spec = _selectedModelSpec;
    if (spec == null) return 'high';
    if (!spec.supportsDeepThinking) return null;
    for (final effort in const ['high', 'medium', 'low', 'xhigh', 'none']) {
      if (spec.reasoningEfforts.contains(effort)) return effort;
    }
    return null;
  }
}

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
