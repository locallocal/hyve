import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  test(
    'AiModelInfo exposes an immutable, serializable capability snapshot',
    () {
      final inputs = <InputModality>[InputModality.text, InputModality.image];
      final outputs = <OutputModality>[OutputModality.text];
      final releaseDate = DateTime.utc(2025, 4, 14);
      final knowledgeCutoff = DateTime.utc(2024, 6, 1);

      final info = AiModelInfo(
        modelId: 'model-1',
        providerId: 'provider-1',
        inputModalities: inputs,
        outputModalities: outputs,
        supportsWebSearch: true,
        supportsDeepThinking: true,
        supportsDeepResearch: false,
        supportsMcp: true,
        supportsSkills: true,
        supportsAutomaticSkillActivation: true,
        supportsHostedSkills: false,
        taskType: AiModelTaskType.chat,
        lifecycle: AiModelLifecycle.recommended,
        currentSnapshot: 'model-1-2025-04-14',
        contextWindowTokens: 128000,
        maxInputTokens: 120000,
        maxOutputTokens: 16384,
        knowledgeCutoff: knowledgeCutoff,
        releaseDate: releaseDate,
        supportedEndpoints: const [
          AiModelEndpoint.responses,
          AiModelEndpoint.chatCompletions,
        ],
        reasoningEfforts: const ['low', 'high'],
        supportedFeatures: const {'streaming', 'function_calling'},
        nativeTools: const {'web_search', 'mcp'},
      );

      inputs.clear();
      outputs.clear();

      expect(info.inputModalities, [InputModality.text, InputModality.image]);
      expect(info.outputModalities, [OutputModality.text]);
      expect(
        () => info.inputModalities.add(InputModality.audio),
        throwsUnsupportedError,
      );
      expect(info.toJson(), {
        'model_id': 'model-1',
        'provider_id': 'provider-1',
        'input_modalities': ['text', 'image'],
        'output_modalities': ['text'],
        'supports_web_search': true,
        'supports_deep_thinking': true,
        'supports_deep_research': false,
        'supports_mcp': true,
        'supports_skills': true,
        'supports_automatic_skill_activation': true,
        'supports_hosted_skills': false,
        'task_type': 'chat',
        'lifecycle': 'recommended',
        'current_snapshot': 'model-1-2025-04-14',
        'context_window_tokens': 128000,
        'max_input_tokens': 120000,
        'max_output_tokens': 16384,
        'knowledge_cutoff': '2024-06-01T00:00:00.000Z',
        'release_date': '2025-04-14T00:00:00.000Z',
        'supported_endpoints': ['responses', 'chat_completions'],
        'reasoning_efforts': ['low', 'high'],
        'supported_features': ['function_calling', 'streaming'],
        'native_tools': ['mcp', 'web_search'],
      });
    },
  );
}
