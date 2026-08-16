import 'package:hyve/domain/models/mcp.dart';
import 'package:hyve/domain/models/modalities.dart';

class Bot {
  static const parameterSupportsMcp = 'supports_mcp';
  static const parameterMcpServers = 'mcp_servers';
  static const parameterMcpTools = 'mcp_tools';
  static const parameterSupportsAutomaticSkillActivation =
      'supports_automatic_skill_activation';
  static const parameterSupportsSkills = 'supports_skills';
  static const parameterContextWindowTokens = 'context_window_tokens';
  static const parameterInputModalities = 'input_modalities';
  static const parameterOutputModalities = 'output_modalities';

  static const apiTypeOpenAI = 'openai';
  static const apiTypeAzure = 'azure';
  static const apiTypeOllama = 'ollama';
  static const apiTypeGemini = 'gemini';
  static const apiTypeDeepseek = 'deepseek';
  static const apiTypeGrok = 'grok';
  static const apiTypeHuggingface = 'huggingface';
  static const apiTypeOpenRouter = 'openrouter';
  static const apiTypeAnthropic = 'anthropic';
  static const apiTypeVolcanoEngine = 'volcanoengine';
  static const apiTypeTencent = 'tencent';
  static const apiTypeBaidu = 'baidu';
  static const apiTypeXingHe = 'xinghe';
  static const apiTypeZhipu = 'zhipu';
  static const apiTypeAlibabaCloud = 'alibabacloud';
  static const apiTypeZeroOneAI = 'zerooneai';
  static const apiTypeInfiniGence = 'infinigence';
  static const apiTypePPIO = 'ppio';
  static const apiTypeStepFun = 'stepfun';
  static const apiTypeBaiChuan = 'baichuan';
  static const apiTypeSpark = 'spark';
  static const apiTypeSenseNova = 'sensenova';
  static const apiTypeMistral = 'mistral';
  static const apiTypeStability = 'stability';
  static const apiTypeFireworks = 'fireworks';
  static const apiTypeFlux = 'flux';
  static const apiTypeKluster = 'kluster';
  static const apiTypeInternLM = 'internlm';
  static const apiTypeJina = 'jina';
  static const apiTypeLambda = 'lambda';
  static const apiTypeAiHubMix = 'aihubmix';
  static const apiTypeAiMass = 'aimass';
  static const apiTypeDeepInfra = 'deepinfra';
  static const apiTypeCerebras = 'cerebras';
  static const apiTypeCohere = 'cohere';
  static const apiTypeMiniMax = 'minimax';
  static const apiTypeModelScope = 'modelscope';
  static const apiTypeMonica = 'monica';
  static const apiTypeNebius = 'nebius';
  static const apiTypeNovita = 'novita';
  static const apiTypeSearch1Api = 'search1api';
  static const apiTypeSambaNova = 'sambanova';
  static const apiTypePerplexity = 'perplexity';
  static const apiTypeTogetherAI = 'togetherai';
  static const apiTypeMoonshot = 'moonshot';

  const Bot({
    required this.id,
    required this.name,
    required this.avatar,
    required this.provider,
    required this.baseURL,
    required this.apiKey,
    required this.apiType,
    required this.model,
    required this.systemPrompt,
    this.parameters,
    required this.createTimestamp,
    required this.modifyTimestamp,
  });

  final String id;
  final String name;
  final String avatar;
  final String provider;
  final String baseURL;
  final String apiKey;
  final String apiType;
  final String model;
  final String systemPrompt;
  final Map<String, dynamic>? parameters;
  final DateTime createTimestamp;
  final DateTime modifyTimestamp;

  bool? get configuredSupportsMcp {
    final value = parameters?[parameterSupportsMcp];
    return value is bool ? value : null;
  }

  Set<McpToolConfiguration> get mcpTools {
    final value = parameters?[parameterMcpTools];
    if (value == null) return const {};
    if (value is! List) {
      throw const FormatException('Bot MCP Tools must be a list.');
    }
    return Set<McpToolConfiguration>.unmodifiable(
      value.map((item) {
        if (item is! Map) {
          throw const FormatException('Bot MCP Tool must be an object.');
        }
        return McpToolConfiguration.fromMap(
          item.map(
            (key, mapValue) => MapEntry(key.toString(), mapValue as Object?),
          ),
        );
      }),
    );
  }

  Set<String> get mcpServerIds {
    final value = parameters?[parameterMcpServers];
    if (value == null) {
      return Set<String>.unmodifiable(
        mcpTools.map((configuration) => configuration.serverId),
      );
    }
    if (value is! List) {
      throw const FormatException('Bot MCP Servers must be a list.');
    }
    final configuredServerIds = value.map((item) {
      if (item is! String || item.trim().isEmpty) {
        throw const FormatException('Bot MCP Server id must be a string.');
      }
      return item;
    });
    return Set<String>.unmodifiable(
      configuredServerIds.followedBy(
        mcpTools.map((configuration) => configuration.serverId),
      ),
    );
  }

  bool? get configuredSupportsAutomaticSkillActivation {
    final value = parameters?[parameterSupportsAutomaticSkillActivation];
    return value is bool ? value : null;
  }

  bool? get configuredSupportsSkills {
    final value = parameters?[parameterSupportsSkills];
    return value is bool ? value : null;
  }

  int? get configuredContextWindowTokens {
    final value = parameters?[parameterContextWindowTokens];
    return value is int && value > 0 ? value : null;
  }

  List<InputModality>? get configuredInputModalities {
    final value = parameters?[parameterInputModalities];
    if (value is! List) return null;
    final names = value.whereType<String>().toSet();
    return List<InputModality>.unmodifiable([
      for (final modality in InputModality.values)
        if (names.contains(modality.value)) modality,
    ]);
  }

  List<OutputModality>? get configuredOutputModalities {
    final value = parameters?[parameterOutputModalities];
    if (value is! List) return null;
    final names = value.whereType<String>().toSet();
    return List<OutputModality>.unmodifiable([
      for (final modality in OutputModality.values)
        if (names.contains(modality.value)) modality,
    ]);
  }

  static List<String> getAllApiTypes() {
    return [
      apiTypeOpenAI,
      apiTypeAnthropic,
      apiTypeGemini,
      apiTypeDeepseek,
      apiTypeOllama,
      apiTypeHuggingface,
      apiTypeGrok,
      apiTypeVolcanoEngine,
      apiTypeTencent,
      apiTypeBaidu,
      apiTypeXingHe,
      apiTypeOpenRouter,
      apiTypeZhipu,
      apiTypeAlibabaCloud,
      apiTypeZeroOneAI,
      apiTypeInfiniGence,
      apiTypePPIO,
      apiTypeStepFun,
      apiTypeBaiChuan,
      apiTypeSpark,
      apiTypeSenseNova,
      apiTypeMistral,
      apiTypeStability,
      apiTypeFireworks,
      apiTypeFlux,
      apiTypeKluster,
      apiTypeInternLM,
      apiTypeJina,
      apiTypeLambda,
      apiTypeAiHubMix,
      apiTypeAiMass,
      apiTypeDeepInfra,
      apiTypeCerebras,
      apiTypeCohere,
      apiTypeMiniMax,
      apiTypeModelScope,
      apiTypeMonica,
      apiTypeNebius,
      apiTypeNovita,
      apiTypeSearch1Api,
      apiTypeSambaNova,
      apiTypePerplexity,
      apiTypeTogetherAI,
      apiTypeMoonshot,
    ];
  }
}
