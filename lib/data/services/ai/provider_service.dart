import 'dart:convert';
import 'dart:io';

import 'package:stars/domain/models/ai_models.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';

export 'package:stars/domain/models/ai_models.dart';
export 'package:stars/domain/models/ai_model_info.dart';

extension ChatMessageJson on ChatMessage {
  Map<String, Object> toJson() => {'role': role, 'content': content};
}

/// Shared implementation helpers for vendor-specific AI service adapters.
abstract class Provider extends AiProvider {
  Provider(super.bot);

  ModelTokenUsage _capturedTokenUsage = ModelTokenUsage.empty;

  /// Decodes a provider response and extracts token usage when the response
  /// exposes one of the common OpenAI, Anthropic, Gemini, or Ollama shapes.
  dynamic decodeProviderResponse(String source) {
    final decoded = jsonDecode(source);
    _captureTokenUsage(decoded);
    return decoded;
  }

  /// Maps model metadata returned by a provider catalog endpoint.
  ///
  /// Missing fields remain unknown; this method never reads [Bot.parameters]
  /// and never infers capabilities from a model identifier.
  AiModelInfo providerModelInfo(Map<String, dynamic> model, {String? modelId}) {
    final architecture = _stringMap(model['architecture']);
    final topProvider = _stringMap(model['top_provider']);
    final supportedParameters = _stringSet(model['supported_parameters']);
    final capabilities = _stringSet(model['capabilities']);

    return AiModelInfo(
      modelId:
          modelId ??
          _firstString(model, const ['id', 'name', 'baseModelId']) ??
          (throw const FormatException('Provider model is missing an id')),
      providerId: bot.apiType,
      inputModalities: _inputModalities(
        architecture?['input_modalities'] ??
            model['input_modalities'] ??
            model['supportedInputTypes'],
      ),
      outputModalities: _outputModalities(
        architecture?['output_modalities'] ??
            model['output_modalities'] ??
            model['supportedOutputTypes'],
      ),
      supportsWebSearch:
          _firstBool(model, const [
            'supports_web_search',
            'supportsWebSearch',
          ]) ??
          _setCapability(supportedParameters, const {
            'web_search',
            'web_search_options',
          }),
      supportsDeepThinking:
          _firstBool(model, const [
            'thinking',
            'supports_deep_thinking',
            'supportsDeepThinking',
          ]) ??
          _setCapability(supportedParameters, const {
            'reasoning',
            'include_reasoning',
          }),
      supportsDeepResearch: _firstBool(model, const [
        'supports_deep_research',
        'supportsDeepResearch',
      ]),
      supportsSkills:
          _firstBool(model, const ['supports_skills', 'supportsSkills']) ??
          _setCapability(supportedParameters, const {'tools', 'tool_choice'}) ??
          _setCapability(capabilities, const {'tools', 'tool_calling'}),
      supportsAutomaticSkillActivation:
          _firstBool(model, const [
            'supports_automatic_skill_activation',
            'supportsAutomaticSkillActivation',
          ]) ??
          _setCapability(supportedParameters, const {'tools', 'tool_choice'}) ??
          _setCapability(capabilities, const {'tools', 'tool_calling'}),
      supportsHostedSkills: _firstBool(model, const [
        'supports_hosted_skills',
        'supportsHostedSkills',
      ]),
      contextWindowTokens:
          _firstPositiveInt(model, const [
            'context_length',
            'contextWindowTokens',
            'inputTokenLimit',
          ]) ??
          _firstPositiveInt(topProvider, const ['context_length']),
      maxOutputTokens:
          _firstPositiveInt(model, const [
            'max_output_length',
            'maxOutputTokens',
            'outputTokenLimit',
          ]) ??
          _firstPositiveInt(topProvider, const ['max_completion_tokens']),
      releaseDate: _providerDate(
        model['created'] ?? model['created_at'] ?? model['release_date'],
      ),
    );
  }

  List<AiModelInfo> providerModelInfos(
    Object? source, {
    String? Function(Map<String, dynamic> model)? modelId,
  }) {
    if (source is! List) {
      throw const FormatException('Provider model catalog is not a list');
    }
    return source
        .whereType<Map>()
        .map((raw) {
          final model = Map<String, dynamic>.from(raw);
          return providerModelInfo(model, modelId: modelId?.call(model));
        })
        .toList(growable: false);
  }

  @override
  void resetCancelState() {
    _capturedTokenUsage = ModelTokenUsage.empty;
    super.resetCancelState();
  }

  void _captureTokenUsage(Object? payload) {
    final usage = _findTokenUsage(payload);
    if (usage == null || !usage.hasData) return;
    _capturedTokenUsage = _capturedTokenUsage.merge(usage);
    onTokenUsage?.call(_capturedTokenUsage);
  }

  ModelTokenUsage? _findTokenUsage(Object? value) {
    if (value is List) {
      for (final item in value) {
        final usage = _findTokenUsage(item);
        if (usage != null) return usage;
      }
      return null;
    }
    if (value is! Map) return null;

    final map = value.cast<Object?, Object?>();
    final direct = _tokenUsageFromMap(map);
    if (direct != null) return direct;

    const preferredKeys = <String>[
      'usage',
      'usageMetadata',
      'usage_metadata',
      'token_usage',
      'message',
    ];
    for (final key in preferredKeys) {
      final usage = _findTokenUsage(map[key]);
      if (usage != null) return usage;
    }
    for (final nested in map.values) {
      final usage = _findTokenUsage(nested);
      if (usage != null) return usage;
    }
    return null;
  }

  ModelTokenUsage? _tokenUsageFromMap(Map<Object?, Object?> map) {
    final input = _firstCount(map, const <String>[
      'input_tokens',
      'inputTokens',
      'inputTokenCount',
      'prompt_tokens',
      'promptTokens',
      'promptTokenCount',
      'prompt_eval_count',
    ]);
    final output = _firstCount(map, const <String>[
      'output_tokens',
      'outputTokens',
      'outputTokenCount',
      'completion_tokens',
      'completionTokens',
      'completionTokenCount',
      'candidatesTokenCount',
      'eval_count',
    ]);
    final total = _firstCount(map, const <String>[
      'total_tokens',
      'totalTokens',
      'totalTokenCount',
    ]);
    if (input == null && output == null && total == null) return null;

    return ModelTokenUsage(
      model: bot.model,
      inputTokens: input ?? 0,
      outputTokens: output ?? 0,
      totalTokens: total ?? 0,
    );
  }

  int? _firstCount(Map<Object?, Object?> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      final count = switch (value) {
        final int count => count,
        final num count => count.toInt(),
        _ => int.tryParse(value?.toString() ?? ''),
      };
      if (count != null && count >= 0) return count;
    }
    return null;
  }

  List<Map<String, dynamic>> processMessagesWithImages(
    List<ChatMessage> messages,
  ) {
    return messages.map((message) {
      if (message.images.isEmpty) return message.toJson();

      final content = <Map<String, dynamic>>[];
      if (message.content.isNotEmpty) {
        content.add({'type': 'text', 'text': message.content});
      }

      for (final imagePath in message.images) {
        try {
          final file = File(imagePath);
          if (file.existsSync()) {
            final base64Image = base64Encode(file.readAsBytesSync());
            content.add({
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
            });
          }
        } catch (error) {
          throw Exception('Process image $imagePath failed: $error');
        }
      }
      return {'role': message.role, 'content': content};
    }).toList();
  }

  String getImageMediaType(List<int> bytes) {
    if (bytes.length >= 3) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return 'image/jpeg';
      }
      if (bytes.length >= 4 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return 'image/png';
      }
      if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
        return 'image/gif';
      }
      if (bytes[0] == 0x42 && bytes[1] == 0x4D) return 'image/bmp';
      if (bytes.length >= 4 &&
          bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46) {
        return 'image/webp';
      }
    }
    return 'application/octet-stream';
  }

  String transformRatio(int width, int height) {
    final divisor = _calculateGreatestCommonDivisor(width, height);
    return '${width ~/ divisor}:${height ~/ divisor}';
  }

  int _calculateGreatestCommonDivisor(int left, int right) {
    while (right != 0) {
      final remainder = left % right;
      left = right;
      right = remainder;
    }
    return left;
  }
}

Map<String, dynamic>? _stringMap(Object? value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}

String? _firstString(Map<String, dynamic> values, List<String> keys) {
  for (final key in keys) {
    final value = values[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

bool? _firstBool(Map<String, dynamic>? values, List<String> keys) {
  if (values == null) return null;
  for (final key in keys) {
    final value = values[key];
    if (value is bool) return value;
  }
  return null;
}

int? _firstPositiveInt(Map<String, dynamic>? values, List<String> keys) {
  if (values == null) return null;
  for (final key in keys) {
    final value = values[key];
    final parsed = switch (value) {
      int() => value,
      num() when value.isFinite && value == value.roundToDouble() =>
        value.toInt(),
      String() => int.tryParse(value),
      _ => null,
    };
    if (parsed != null && parsed > 0) return parsed;
  }
  return null;
}

Set<String>? _stringSet(Object? value) {
  if (value is! List) return null;
  return value.whereType<String>().map((item) => item.toLowerCase()).toSet();
}

bool? _setCapability(Set<String>? values, Set<String> supportedValues) {
  if (values == null) return null;
  return values.any(supportedValues.contains);
}

List<InputModality> _inputModalities(Object? value) {
  final names = _stringSet(value) ?? const <String>{};
  return [
    for (final modality in InputModality.values)
      if (names.contains(modality.value)) modality,
  ];
}

List<OutputModality> _outputModalities(Object? value) {
  final names = _stringSet(value) ?? const <String>{};
  return [
    for (final modality in OutputModality.values)
      if (names.contains(modality.value)) modality,
  ];
}

DateTime? _providerDate(Object? value) {
  if (value is num) {
    final raw = value.toInt();
    final milliseconds = raw.abs() < 100000000000 ? raw * 1000 : raw;
    try {
      return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
    } on ArgumentError {
      return null;
    }
  }
  if (value is String) return DateTime.tryParse(value)?.toUtc();
  return null;
}
