import 'dart:convert';
import 'dart:io';

import 'package:stars/domain/models/ai_models.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';

export 'package:stars/domain/models/ai_models.dart';

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
