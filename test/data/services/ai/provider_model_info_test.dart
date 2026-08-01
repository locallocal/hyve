import 'package:flutter_test/flutter_test.dart';
import 'package:stars/data/services/ai/provider_service.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  group('provider model metadata', () {
    test('maps a rich external catalog response into one model interface', () {
      final provider = _MetadataProvider(_bot());

      final info = provider.parse({
        'id': 'vendor/model-1',
        'created': 1692901234,
        'context_length': 131072,
        'architecture': {
          'input_modalities': ['text', 'image', 'file'],
          'output_modalities': ['text'],
        },
        'supported_parameters': ['tools', 'reasoning', 'web_search_options'],
        'top_provider': {'max_completion_tokens': 8192},
      });

      expect(info.modelId, 'vendor/model-1');
      expect(info.providerId, Bot.apiTypeOpenRouter);
      expect(info.inputModalities, [
        InputModality.text,
        InputModality.image,
        InputModality.file,
      ]);
      expect(info.outputModalities, [OutputModality.text]);
      expect(info.supportsWebSearch, isTrue);
      expect(info.supportsDeepThinking, isTrue);
      expect(info.supportsDeepResearch, isNull);
      expect(info.supportsSkills, isTrue);
      expect(info.supportsAutomaticSkillActivation, isTrue);
      expect(info.supportsHostedSkills, isNull);
      expect(info.contextWindowTokens, 131072);
      expect(info.maxOutputTokens, 8192);
      expect(
        info.releaseDate,
        DateTime.fromMillisecondsSinceEpoch(1692901234000, isUtc: true),
      );
    });

    test('maps Gemini limits and thinking from its external response', () {
      final provider = _MetadataProvider(_bot(apiType: Bot.apiTypeGemini));

      final info = provider.parse({
        'name': 'models/gemini-test',
        'inputTokenLimit': 1048576,
        'outputTokenLimit': 8192,
        'thinking': true,
      });

      expect(info.modelId, 'models/gemini-test');
      expect(info.contextWindowTokens, 1048576);
      expect(info.maxOutputTokens, 8192);
      expect(info.supportsDeepThinking, isTrue);
      expect(info.inputModalities, isEmpty);
      expect(info.outputModalities, isEmpty);
      expect(info.supportsSkills, isNull);
    });

    test('never derives metadata from Bot parameters or its model name', () {
      final provider = _MetadataProvider(
        _bot(
          model: 'reasoning-model-2025-01-02',
          parameters: const {
            'context_window_tokens': 999999,
            'maxOutputTokens': 8888,
            'supports_web_search': true,
          },
        ),
      );

      final info = provider.parse({'id': 'external-model'});

      expect(info.inputModalities, isEmpty);
      expect(info.outputModalities, isEmpty);
      expect(info.supportsWebSearch, isNull);
      expect(info.supportsDeepThinking, isNull);
      expect(info.supportsSkills, isNull);
      expect(info.contextWindowTokens, isNull);
      expect(info.maxOutputTokens, isNull);
      expect(info.releaseDate, isNull);
    });
  });
}

final class _MetadataProvider extends Provider {
  _MetadataProvider(super.bot);

  AiModelInfo parse(Map<String, dynamic> model) => providerModelInfo(model);

  @override
  Future<void> generateText(List<ChatMessage> messages) async {}
}

Bot _bot({
  String apiType = Bot.apiTypeOpenRouter,
  String model = 'test-model',
  Map<String, dynamic>? parameters,
}) => Bot(
  id: 'bot-$apiType',
  name: apiType,
  avatar: '',
  provider: apiType,
  baseURL: 'https://example.invalid',
  apiKey: 'test-key',
  apiType: apiType,
  model: model,
  systemPrompt: '',
  parameters: parameters,
  createTimestamp: DateTime.fromMillisecondsSinceEpoch(1),
  modifyTimestamp: DateTime.fromMillisecondsSinceEpoch(1),
);
