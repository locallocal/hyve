import 'package:stars/domain/models/models.dart';

enum ProviderLifecycle { active, migrated, retired }

final class ProviderLifecycleInfo {
  const ProviderLifecycleInfo({
    required this.lifecycle,
    required this.code,
    this.replacementApiType,
    this.replacementBaseUrl,
  });

  final ProviderLifecycle lifecycle;
  final String code;
  final String? replacementApiType;
  final String? replacementBaseUrl;
}

const providerLifecycleByApiType = <String, ProviderLifecycleInfo>{
  Bot.apiTypeNebius: ProviderLifecycleInfo(
    lifecycle: ProviderLifecycle.migrated,
    code: 'nebius_token_factory_migration',
    replacementBaseUrl: 'https://api.tokenfactory.nebius.com/v1/',
  ),
  Bot.apiTypeTencent: ProviderLifecycleInfo(
    lifecycle: ProviderLifecycle.migrated,
    code: 'tencent_tokenhub_migration',
    replacementBaseUrl: 'https://tokenhub.tencentmaas.com/v1/',
  ),
  Bot.apiTypeKluster: ProviderLifecycleInfo(
    lifecycle: ProviderLifecycle.retired,
    code: 'kluster_retired',
    replacementApiType: Bot.apiTypeOpenAI,
  ),
  Bot.apiTypeLambda: ProviderLifecycleInfo(
    lifecycle: ProviderLifecycle.retired,
    code: 'lambda_hosted_inference_retired',
    replacementApiType: Bot.apiTypeOpenAI,
  ),
  Bot.apiTypeSearch1Api: ProviderLifecycleInfo(
    lifecycle: ProviderLifecycle.retired,
    code: 'search1api_chat_retired',
    replacementApiType: Bot.apiTypeOpenAI,
  ),
};

ProviderLifecycleInfo? providerMigrationFor(Bot bot) {
  final info = providerLifecycleByApiType[bot.apiType];
  if (info == null) return null;
  if (info.lifecycle == ProviderLifecycle.retired) return info;
  final replacement = info.replacementBaseUrl;
  if (replacement != null &&
      bot.baseURL.isNotEmpty &&
      bot.baseURL != replacement) {
    return info;
  }
  return null;
}

final providersInfo = {
  'AiHubMix': {
    'api_type': Bot.apiTypeAiHubMix,
    'base_url': 'https://aihubmix.com/v1/',
  },
  'AiMass': {
    'api_type': Bot.apiTypeAiMass,
    'base_url': 'https://platform.wair.ac.cn/maas/v1/',
  },
  'AIStudio': {
    'api_type': Bot.apiTypeGemini,
    'base_url': 'https://generativelanguage.googleapis.com/v1beta/',
  },
  'AlibabaCloud': {
    'api_type': Bot.apiTypeAlibabaCloud,
    'base_url': 'https://dashscope.aliyuncs.com/compatible-mode/v1/',
  },
  'Anthropic': {
    'api_type': Bot.apiTypeAnthropic,
    'base_url': 'https://api.anthropic.com/v1/',
  },
  'BaiChuan': {
    'api_type': Bot.apiTypeBaiChuan,
    'base_url': 'https://api.baichuan-ai.com/v1/',
  },
  'Baidu': {
    'api_type': Bot.apiTypeBaidu,
    'base_url': 'https://qianfan.baidubce.com/v2/',
  },
  'Cerebras': {
    'api_type': Bot.apiTypeCerebras,
    'base_url': 'https://api.cerebras.ai/v1/',
  },
  'ChatGLM': {
    'api_type': Bot.apiTypeOpenAI,
    'base_url': 'http://localhost:8000',
  },
  'Cohere': {
    'api_type': Bot.apiTypeCohere,
    'base_url': 'https://api.cohere.com/v1/',
  },
  'DeepInfra': {
    'api_type': Bot.apiTypeDeepInfra,
    'base_url': 'https://api.deepinfra.com/v1/openai/',
  },
  'DeepSeek': {
    'api_type': Bot.apiTypeDeepseek,
    'base_url': 'https://api.deepseek.com/',
  },
  'Fireworks': {
    'api_type': Bot.apiTypeFireworks,
    'base_url': 'https://api.fireworks.ai/',
  },
  'Flux': {
    'api_type': Bot.apiTypeFlux,
    'base_url': 'https://api.us1.bfl.ai/v1/',
  },
  'Gemini': {
    'api_type': Bot.apiTypeGemini,
    'base_url': 'https://generativelanguage.googleapis.com/v1beta/',
  },
  'Grok': {'api_type': Bot.apiTypeGrok, 'base_url': 'https://api.x.ai/v1/'},
  'HuggingFace': {
    'api_type': Bot.apiTypeHuggingface,
    'sub_providers': {
      'Cerebras': {'base_url': 'https://router.huggingface.co/cerebras/v1/'},
      'Cohere': {
        'base_url': 'https://router.huggingface.co/cohere/compatibility/v1/',
      },
      'Fal-AI': {
        'base_url': 'https://router.huggingface.co/fal-ai/fal-ai/whisper',
      },
      'Fireworks-AI': {
        'base_url': 'https://router.huggingface.co/fireworks-ai/inference/v1/',
      },
      'Hyperbolic': {
        'base_url': 'https://router.huggingface.co/hyperbolic/v1/',
      },
      'HF-Inference': {
        'base_url': 'https://router.huggingface.co/hf-inference/',
      },
      'Nebius': {'base_url': 'https://router.huggingface.co/nebius/v1/'},
      'Novita': {'base_url': 'https://router.huggingface.co/novita/v3/openai/'},
      'Replicate': {'base_url': 'https://router.huggingface.co/replicate/v1/'},
      'Sambanova': {'base_url': 'https://router.huggingface.co/sambanova/v1/'},
      'Together': {'base_url': 'https://router.huggingface.co/together/v1/'},
    },
  },
  'InfiniGence': {
    'api_type': Bot.apiTypeInfiniGence,
    'base_url': 'https://cloud.infini-ai.com/maas/v1/',
  },
  'InternLM': {
    'api_type': Bot.apiTypeInternLM,
    'base_url': 'https://chat.intern-ai.org.cn/api/v1/',
  },
  'Jina': {
    'api_type': Bot.apiTypeJina,
    'base_url': 'https://deepsearch.jina.ai/v1/',
  },
  'MiniMax': {
    'api_type': Bot.apiTypeMiniMax,
    'base_url': 'https://api.minimax.chat/v1/',
  },
  'Mistral': {
    'api_type': Bot.apiTypeMistral,
    'base_url': 'https://api.mistral.ai/v1/',
  },
  'ModelScope': {
    'api_type': Bot.apiTypeModelScope,
    'base_url': 'https://api-inference.modelscope.cn/v1/',
  },
  'Monica': {
    'api_type': Bot.apiTypeMonica,
    'base_url': 'https://openapi.monica.im/v1/',
  },
  'Moonshot': {
    'api_type': Bot.apiTypeMoonshot,
    'base_url': 'https://api.moonshot.cn/v1/',
  },
  'Nebius': {
    'api_type': Bot.apiTypeNebius,
    'base_url': 'https://api.tokenfactory.nebius.com/v1/',
  },
  'Novita': {
    'api_type': Bot.apiTypeNovita,
    'base_url': 'https://api.novita.ai/v3/openai/v1/',
  },
  'Ollama': {
    'api_type': Bot.apiTypeOllama,
    'base_url': 'http://localhost:11434',
  },
  'OpenAI': {
    'api_type': Bot.apiTypeOpenAI,
    'base_url': 'https://api.openai.com/v1/',
    'models': <String>[],
  },
  'OpenRouter': {
    'api_type': Bot.apiTypeOpenRouter,
    'base_url': 'https://openrouter.ai/api/v1/',
  },
  'Perplexity': {
    'api_type': Bot.apiTypePerplexity,
    'base_url': 'https://api.perplexity.ai/',
  },
  'PPIO': {
    'api_type': Bot.apiTypePPIO,
    'base_url': 'https://api.ppinfra.com/v3/',
  },
  'SambaNova': {
    'api_type': Bot.apiTypeSambaNova,
    'base_url': 'https://api.sambanova.ai/v1/',
  },
  'SenseNova': {
    'api_type': Bot.apiTypeSenseNova,
    'base_url': 'https://api.sensenova.cn/v1/',
  },
  'SiliconFlow': {
    'api_type': Bot.apiTypeOpenAI,
    'base_url': 'https://api.siliconflow.cn',
  },
  'Spark': {
    'api_type': Bot.apiTypeSpark,
    'base_url': 'https://spark-api-open.xf-yun.com/v1/',
  },
  'StepFun': {
    'api_type': Bot.apiTypeStepFun,
    'base_url': 'https://api.stepfun.com/v1/',
  },
  'Stability': {
    'api_type': Bot.apiTypeStability,
    'base_url': 'https://api.stability.ai/v2beta/',
  },
  'Tencent': {
    'api_type': Bot.apiTypeTencent,
    'base_url': 'https://tokenhub.tencentmaas.com/v1/',
  },
  'TogetherAI': {
    'api_type': Bot.apiTypeTogetherAI,
    'base_url': 'https://api.together.xyz/v1/',
  },
  'VolcanoEngine': {
    'api_type': Bot.apiTypeVolcanoEngine,
    'base_url': 'https://ark.cn-beijing.volces.com/api/v3/',
  },
  'XingHe': {
    'api_type': Bot.apiTypeXingHe,
    'base_url': 'https://aistudio.baidu.com/llm/lmapi/v3/',
  },
  "ZeroOneAI": {
    'api_type': Bot.apiTypeZeroOneAI,
    'base_url': 'https://api.lingyiwanwu.com/v1/',
  },
  'ZhiPu': {
    'api_type': Bot.apiTypeZhipu,
    'base_url': 'https://open.bigmodel.cn/api/paas/v4/',
  },
};
