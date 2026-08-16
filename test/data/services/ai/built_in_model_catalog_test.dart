import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/services/ai/built_in_model_catalog.dart';
import 'package:hyve/domain/models/models.dart';

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

    test(
      'contains the current documented Moonshot models and capabilities',
      () {
        final models = BuiltInModelCatalog.modelsFor(Bot.apiTypeMoonshot);
        final ids = models.map((model) => model.modelId).toList();

        expect(ids, [
          'kimi-k3',
          'kimi-k2.7-code',
          'kimi-k2.7-code-highspeed',
          'kimi-k2.6',
          'kimi-k2.5',
          'moonshot-v1-8k',
          'moonshot-v1-32k',
          'moonshot-v1-128k',
          'moonshot-v1-8k-vision-preview',
          'moonshot-v1-32k-vision-preview',
          'moonshot-v1-128k-vision-preview',
        ]);
        expect(ids, isNot(contains('kimi-latest')));
        expect(ids, isNot(contains('kimi-k2-thinking')));

        final k3 = models.first;
        expect(k3.inputModalities, [
          InputModality.text,
          InputModality.image,
          InputModality.video,
        ]);
        expect(k3.supportsWebSearch, isTrue);
        expect(k3.supportsDeepThinking, isTrue);
        expect(k3.supportsMcp, isTrue);
        expect(k3.contextWindowTokens, 1048576);
        expect(k3.maxOutputTokens, 1048576);
        expect(k3.lifecycle, AiModelLifecycle.recommended);
        expect(k3.supportedEndpoints, [AiModelEndpoint.chatCompletions]);
        expect(k3.reasoningEfforts, ['low', 'high', 'max']);
        expect(
          k3.supportedFeatures,
          containsAll([
            'always_thinking',
            'structured_outputs',
            'function_calling',
            'prompt_caching',
            'web_search',
          ]),
        );
        expect(k3.nativeTools, contains(r'$web_search'));

        for (final model in models.take(5)) {
          expect(
            model.supportsWebSearch,
            isTrue,
            reason: '${model.modelId} supports Kimi built-in web search',
          );
          expect(model.nativeTools, contains(r'$web_search'));
        }

        expect(models.every((model) => model.supportsMcp == true), isTrue);
        expect(models.every((model) => model.supportsSkills == true), isTrue);
        expect(
          models.every(
            (model) => model.supportsAutomaticSkillActivation == true,
          ),
          isTrue,
        );

        final highSpeed = models.singleWhere(
          (model) => model.modelId == 'kimi-k2.7-code-highspeed',
        );
        expect(highSpeed.contextWindowTokens, 262144);
        expect(highSpeed.inputModalities, contains(InputModality.video));
        expect(highSpeed.supportedFeatures, contains('high_speed_output'));

        final k25 = models.singleWhere((model) => model.modelId == 'kimi-k2.5');
        expect(k25.lifecycle, AiModelLifecycle.deprecated);
        expect(k25.supportedFeatures, contains('configurable_thinking'));

        final text128k = models.singleWhere(
          (model) => model.modelId == 'moonshot-v1-128k',
        );
        final vision128k = models.singleWhere(
          (model) => model.modelId == 'moonshot-v1-128k-vision-preview',
        );
        expect(text128k.contextWindowTokens, 131072);
        expect(text128k.inputModalities, [InputModality.text]);
        expect(text128k.supportsDeepThinking, isFalse);
        expect(text128k.supportsWebSearch, isFalse);
        expect(text128k.lifecycle, AiModelLifecycle.deprecated);
        expect(vision128k.contextWindowTokens, 131072);
        expect(vision128k.inputModalities, [
          InputModality.text,
          InputModality.image,
        ]);
      },
    );

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
