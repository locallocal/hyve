import 'package:flutter_test/flutter_test.dart';
import 'package:stars/data/services/ai/built_in_model_catalog.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  group('BuiltInModelCatalog', () {
    test('contains the latest documented OpenAI frontier models', () {
      final models = BuiltInModelCatalog.modelsFor(Bot.apiTypeOpenAI);

      final sol = models.singleWhere((model) => model.modelId == 'gpt-5.6-sol');
      expect(
        models.map((model) => model.modelId),
        containsAll(['gpt-5.6', 'gpt-5.6-terra', 'gpt-5.6-luna']),
      );
      expect(sol.inputModalities, [InputModality.text, InputModality.image]);
      expect(sol.outputModalities, [OutputModality.text]);
      expect(sol.supportsWebSearch, isTrue);
      expect(sol.supportsDeepThinking, isTrue);
      expect(sol.supportsMcp, isTrue);
      expect(sol.contextWindowTokens, 1050000);
      expect(sol.maxOutputTokens, 128000);
    });

    test('contains DeepSeek V4 IDs and omits retired aliases', () {
      final models = BuiltInModelCatalog.modelsFor(Bot.apiTypeDeepseek);
      final ids = models.map((model) => model.modelId).toList();

      expect(ids, ['deepseek-v4-flash', 'deepseek-v4-pro']);
      expect(ids, isNot(contains('deepseek-chat')));
      expect(ids, isNot(contains('deepseek-reasoner')));
      expect(models.first.supportsWebSearch, isFalse);
      expect(models.first.supportsDeepThinking, isTrue);
      expect(models.first.releaseDate, DateTime.utc(2026, 7, 31));
    });

    test('matches Gemini IDs with or without the resource-name prefix', () {
      final model = BuiltInModelCatalog.find(
        Bot.apiTypeGemini,
        'gemini-3.6-flash',
      );

      expect(model?.modelId, 'models/gemini-3.6-flash');
      expect(model?.inputModalities, contains(InputModality.file));
      expect(model?.supportsWebSearch, isTrue);
      expect(model?.supportsDeepThinking, isTrue);
      expect(model?.supportsMcp, isFalse);
    });

    test('contains the current Mistral adjustable-reasoning models', () {
      final models = BuiltInModelCatalog.modelsFor(Bot.apiTypeMistral);

      expect(
        models.map((model) => model.modelId),
        containsAll(['mistral-medium-3-5', 'mistral-small-2603']),
      );
      expect(models.every((model) => model.supportsWebSearch == false), isTrue);
      expect(
        models.every((model) => model.supportsDeepThinking == true),
        isTrue,
      );
      expect(models.first.contextWindowTokens, 256000);
    });

    test('live explicit values win while missing metadata is filled', () {
      final live = AiModelInfo(
        modelId: 'gpt-5.6-sol',
        providerId: Bot.apiTypeOpenAI,
        inputModalities: const [],
        outputModalities: const [],
        supportsWebSearch: false,
        contextWindowTokens: 999999,
      );

      final merged = BuiltInModelCatalog.merge(Bot.apiTypeOpenAI, [live]);
      final sol = merged.singleWhere((model) => model.modelId == 'gpt-5.6-sol');

      expect(sol.supportsWebSearch, isFalse);
      expect(sol.supportsDeepThinking, isTrue);
      expect(sol.supportsMcp, isTrue);
      expect(sol.inputModalities, [InputModality.text, InputModality.image]);
      expect(sol.outputModalities, [OutputModality.text]);
      expect(sol.contextWindowTokens, 999999);
      expect(sol.maxOutputTokens, 128000);
      expect(merged.map((model) => model.modelId), contains('gpt-5.6-luna'));
    });
  });
}
