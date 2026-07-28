import 'dart:convert';
import 'package:flutter/foundation.dart';

enum InputModality {
  text('text'),
  image('image'),
  file('file'),
  audio('audio'),
  video('video'),
  realtime('realtime');

  final String value;
  const InputModality(this.value);
}

enum OutputModality {
  text('text'),
  image('image'),
  speech('speech'),
  audio('audio'),
  realtime('realtime'),
  music('music'),
  video('video'),
  multi('multi');

  final String value;
  const OutputModality(this.value);
}

// 机器人信息
class Bot {
  static const apiTypeOpenAI = "openai";
  static const apiTypeAzure = "azure";
  static const apiTypeOllama = "ollama";
  static const apiTypeGemini = "gemini";
  static const apiTypeDeepseek = "deepseek";
  static const apiTypeGrok = "grok";
  static const apiTypeHuggingface = "huggingface";
  static const apiTypeOpenRouter = 'openrouter';
  static const apiTypeAnthropic = "anthropic";
  static const apiTypeVolcanoEngine = "volcanoengine";
  static const apiTypeTencent = "tencent";
  static const apiTypeBaidu = "baidu";
  static const apiTypeXingHe = "xinghe";
  static const apiTypeZhipu = 'zhipu';
  static const apiTypeAlibabaCloud = 'alibabacloud';
  static const apiTypeZeroOneAI = 'zerooneai';
  static const apiTypeInfiniGence = 'infinigence';
  static const apiTypePPIO = 'ppio';
  static const apiTypeStepFun = "stepfun";
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

  factory Bot.fromMap(Map<String, dynamic> map) {
    // 从JSON字符串解析parameters
    Map<String, dynamic>? params;
    if (map['parameters'] != null) {
      // 如果是字符串，尝试解析JSON
      try {
        params =
            jsonDecode(map['parameters'] as String) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('解析parameters失败: $e');
        params = {};
      }
    } else if (map['parameters'] is Map) {
      // 如果已经是Map，直接使用
      params = Map<String, dynamic>.from(map['parameters'] as Map);
    }

    return Bot(
      id: map['id'] as String,
      name: map['name'] as String,
      avatar: map['avatar'] as String,
      provider: map['provider'] as String,
      baseURL: map['base_url'] as String,
      apiKey: map['api_key'] as String,
      apiType: map['api_type'] as String,
      model: map['model'] as String,
      systemPrompt: map['system_prompt'] as String,
      parameters: params,
      createTimestamp: DateTime.fromMillisecondsSinceEpoch(
        map['create_timestamp'] as int,
      ),
      modifyTimestamp: DateTime.fromMillisecondsSinceEpoch(
        map['modify_timestamp'] as int,
      ),
    );
  }

  Map<String, Object> toMap() {
    // 将parameters转换为JSON字符串
    String paramsJson = '{}';
    if (parameters != null && parameters!.isNotEmpty) {
      try {
        paramsJson = jsonEncode(parameters);
      } catch (e) {
        debugPrint('序列化parameters失败: $e');
      }
    }

    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'provider': provider,
      'base_url': baseURL,
      'api_key': apiKey,
      'api_type': apiType,
      'model': model,
      'system_prompt': systemPrompt,
      'parameters': paramsJson,
      'create_timestamp': createTimestamp.millisecondsSinceEpoch,
      'modify_timestamp': modifyTimestamp.millisecondsSinceEpoch,
    };
  }

  // 获取所有API类型
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

// 消息
class MessageToolCall {
  final String callId;
  final String name;
  final String status;
  final String detail;
  final String source;
  final String riskLevel;
  final String argumentsSummary;
  final String resultSummary;
  final String approvalStatus;
  final String errorCode;
  final int? durationMs;

  const MessageToolCall({
    this.callId = '',
    required this.name,
    this.status = '',
    this.detail = '',
    this.source = '',
    this.riskLevel = '',
    this.argumentsSummary = '',
    this.resultSummary = '',
    this.approvalStatus = '',
    this.errorCode = '',
    this.durationMs,
  });

  factory MessageToolCall.fromMap(Map<String, dynamic> map) {
    return MessageToolCall(
      callId: (map['call_id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      status: (map['status'] ?? '') as String,
      detail: (map['detail'] ?? '') as String,
      source: (map['source'] ?? '') as String,
      riskLevel: (map['risk_level'] ?? '') as String,
      argumentsSummary: (map['arguments_summary'] ?? '') as String,
      resultSummary: (map['result_summary'] ?? '') as String,
      approvalStatus: (map['approval_status'] ?? '') as String,
      errorCode: (map['error_code'] ?? '') as String,
      durationMs: map['duration_ms'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'call_id': callId,
      'name': name,
      'status': status,
      'detail': detail,
      'source': source,
      'risk_level': riskLevel,
      'arguments_summary': argumentsSummary,
      'result_summary': resultSummary,
      'approval_status': approvalStatus,
      'error_code': errorCode,
      'duration_ms': durationMs,
    };
  }

  MessageToolCall copyWith({
    String? status,
    String? detail,
    String? resultSummary,
    String? approvalStatus,
    String? errorCode,
    int? durationMs,
  }) {
    return MessageToolCall(
      callId: callId,
      name: name,
      status: status ?? this.status,
      detail: detail ?? this.detail,
      source: source,
      riskLevel: riskLevel,
      argumentsSummary: argumentsSummary,
      resultSummary: resultSummary ?? this.resultSummary,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      errorCode: errorCode ?? this.errorCode,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}

class MessageCommandExecution {
  final String command;
  final String status;
  final String detail;
  final int? durationMs;

  const MessageCommandExecution({
    required this.command,
    this.status = '',
    this.detail = '',
    this.durationMs,
  });

  factory MessageCommandExecution.fromMap(Map<String, dynamic> map) {
    return MessageCommandExecution(
      command: (map['command'] ?? '') as String,
      status: (map['status'] ?? '') as String,
      detail: (map['detail'] ?? '') as String,
      durationMs: map['duration_ms'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'command': command,
      'status': status,
      'detail': detail,
      'duration_ms': durationMs,
    };
  }
}

class MessageFileEdit {
  final String path;
  final String type;
  final String status;
  final String detail;

  const MessageFileEdit({
    required this.path,
    this.type = '',
    this.status = '',
    this.detail = '',
  });

  factory MessageFileEdit.fromMap(Map<String, dynamic> map) {
    return MessageFileEdit(
      path: (map['path'] ?? '') as String,
      type: (map['type'] ?? '') as String,
      status: (map['status'] ?? '') as String,
      detail: (map['detail'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'path': path, 'type': type, 'status': status, 'detail': detail};
  }
}

class MessageSkillActivation {
  final String name;
  final String contentDigest;
  final String trigger;
  final String status;

  const MessageSkillActivation({
    required this.name,
    required this.contentDigest,
    required this.trigger,
    this.status = 'recorded',
  });

  factory MessageSkillActivation.fromMap(Map<String, dynamic> map) {
    return MessageSkillActivation(
      name: (map['name'] ?? '') as String,
      contentDigest: (map['content_digest'] ?? '') as String,
      trigger: (map['trigger'] ?? '') as String,
      status: (map['status'] ?? 'recorded') as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'content_digest': contentDigest,
    'trigger': trigger,
    'status': status,
  };
}

class MessageProcessInfo {
  final String reasoningStatus;
  final int? durationMs;
  final List<MessageToolCall> toolCalls;
  final List<MessageCommandExecution> commandExecutions;
  final List<MessageFileEdit> fileEdits;
  final List<MessageSkillActivation> skillActivations;

  const MessageProcessInfo({
    this.reasoningStatus = '',
    this.durationMs,
    this.toolCalls = const [],
    this.commandExecutions = const [],
    this.fileEdits = const [],
    this.skillActivations = const [],
  });

  bool get hasData =>
      reasoningStatus.isNotEmpty ||
      durationMs != null ||
      toolCalls.isNotEmpty ||
      commandExecutions.isNotEmpty ||
      fileEdits.isNotEmpty ||
      skillActivations.isNotEmpty;

  factory MessageProcessInfo.fromRaw(dynamic raw) {
    if (raw == null) {
      return const MessageProcessInfo();
    }

    if (raw is String) {
      if (raw.isEmpty) {
        return const MessageProcessInfo();
      }
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return MessageProcessInfo.fromMap(decoded);
        }
        if (decoded is Map) {
          return MessageProcessInfo.fromMap(decoded.cast<String, dynamic>());
        }
      } catch (e) {
        debugPrint('Parse process info failed: $e');
      }
      return const MessageProcessInfo();
    }

    if (raw is Map<String, dynamic>) {
      return MessageProcessInfo.fromMap(raw);
    }

    if (raw is Map) {
      return MessageProcessInfo.fromMap(raw.cast<String, dynamic>());
    }

    return const MessageProcessInfo();
  }

  factory MessageProcessInfo.fromMap(Map<String, dynamic> map) {
    List<MessageToolCall> toolCalls = [];
    final rawToolCalls = map['tool_calls'];
    if (rawToolCalls is List) {
      toolCalls =
          rawToolCalls
              .whereType<Map>()
              .map((e) => MessageToolCall.fromMap(e.cast<String, dynamic>()))
              .toList();
    }

    List<MessageCommandExecution> commandExecutions = [];
    final rawCommandExecutions = map['command_executions'];
    if (rawCommandExecutions is List) {
      commandExecutions =
          rawCommandExecutions
              .whereType<Map>()
              .map(
                (e) =>
                    MessageCommandExecution.fromMap(e.cast<String, dynamic>()),
              )
              .toList();
    }

    List<MessageFileEdit> fileEdits = [];
    final rawFileEdits = map['file_edits'];
    if (rawFileEdits is List) {
      fileEdits =
          rawFileEdits
              .whereType<Map>()
              .map((e) => MessageFileEdit.fromMap(e.cast<String, dynamic>()))
              .toList();
    }

    List<MessageSkillActivation> skillActivations = [];
    final rawSkillActivations = map['skill_activations'];
    if (rawSkillActivations is List) {
      skillActivations =
          rawSkillActivations
              .whereType<Map>()
              .map(
                (e) =>
                    MessageSkillActivation.fromMap(e.cast<String, dynamic>()),
              )
              .toList();
    }

    return MessageProcessInfo(
      reasoningStatus: (map['reasoning_status'] ?? '') as String,
      durationMs: map['duration_ms'] as int?,
      toolCalls: toolCalls,
      commandExecutions: commandExecutions,
      fileEdits: fileEdits,
      skillActivations: skillActivations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reasoning_status': reasoningStatus,
      'duration_ms': durationMs,
      'tool_calls': toolCalls.map((e) => e.toMap()).toList(),
      'command_executions': commandExecutions.map((e) => e.toMap()).toList(),
      'file_edits': fileEdits.map((e) => e.toMap()).toList(),
      'skill_activations': skillActivations.map((e) => e.toMap()).toList(),
    };
  }
}

enum MessageTerminalOutcome {
  completed,
  cancelled,
  failed,
  emptyResponse;

  static MessageTerminalOutcome? fromStorage(Object? value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    for (final outcome in values) {
      if (outcome.name == raw) return outcome;
    }
    return null;
  }
}

/// Immutable token accounting for one model response or an aggregate.
///
/// Providers do not all return a total, so [effectiveTotalTokens] falls back
/// to the input/output sum. [model] is populated for per-response records and
/// intentionally left empty for aggregates that may span multiple models.
class ModelTokenUsage {
  const ModelTokenUsage({
    this.model = '',
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.totalTokens = 0,
  });

  static const empty = ModelTokenUsage();

  final String model;
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;

  int get effectiveTotalTokens =>
      totalTokens > 0 ? totalTokens : inputTokens + outputTokens;

  bool get hasData => inputTokens > 0 || outputTokens > 0 || totalTokens > 0;

  ModelTokenUsage merge(ModelTokenUsage newer) {
    return ModelTokenUsage(
      model: newer.model.isNotEmpty ? newer.model : model,
      inputTokens: newer.inputTokens > 0 ? newer.inputTokens : inputTokens,
      outputTokens: newer.outputTokens > 0 ? newer.outputTokens : outputTokens,
      totalTokens: newer.totalTokens > 0 ? newer.totalTokens : totalTokens,
    );
  }

  ModelTokenUsage operator +(ModelTokenUsage other) {
    return ModelTokenUsage(
      inputTokens: inputTokens + other.inputTokens,
      outputTokens: outputTokens + other.outputTokens,
      totalTokens: effectiveTotalTokens + other.effectiveTotalTokens,
    );
  }

  static ModelTokenUsage sum(Iterable<ModelTokenUsage> usages) {
    return usages.fold(empty, (total, usage) => total + usage);
  }
}

/// Immutable accounting record for one model response.
///
/// The record is stored independently from message content so clearing a
/// conversation does not erase historical usage.
class ModelTokenUsageRecord {
  const ModelTokenUsageRecord({
    required this.messageId,
    required this.chatId,
    required this.botId,
    required this.timestamp,
    required this.usage,
  });

  final String messageId;
  final String chatId;
  final String botId;
  final DateTime timestamp;
  final ModelTokenUsage usage;
}

class Message {
  final String messageId;
  final String turnId;
  final String runId;
  final String chatId;
  final String botId;
  final String senderId;
  final String content;
  final String reasoning;
  final MessageProcessInfo processInfo;
  final List<String> images; // 图片路径列表
  final List<String> files; // 文件路径列表
  final String audio;
  final String music;
  final String video;
  final ModelTokenUsage tokenUsage;
  final MessageTerminalOutcome? terminalOutcome;
  final bool hasPartialContent;
  final DateTime timestamp;

  const Message({
    this.messageId = '',
    this.turnId = '',
    this.runId = '',
    required this.chatId,
    required this.botId,
    required this.senderId,
    required this.content,
    this.reasoning = '',
    this.processInfo = const MessageProcessInfo(),
    this.images = const [],
    this.files = const [],
    this.audio = '',
    this.music = '',
    this.video = '',
    this.tokenUsage = ModelTokenUsage.empty,
    this.terminalOutcome,
    this.hasPartialContent = false,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    // 处理图片列表
    List<String> imagesList = [];
    if (map['images'] != null) {
      if (map['images'] is String) {
        try {
          final List<dynamic> decoded = jsonDecode(map['images'] as String);
          imagesList = decoded.map((e) => e.toString()).toList();
        } catch (e) {
          debugPrint('Parse images failed: $e');
        }
      } else if (map['images'] is List) {
        imagesList = (map['images'] as List).map((e) => e.toString()).toList();
      }
    }

    // 处理文件列表
    List<String> filesList = [];
    if (map['files'] != null) {
      if (map['files'] is String) {
        try {
          final List<dynamic> decoded = jsonDecode(map['files'] as String);
          filesList = decoded.map((e) => e.toString()).toList();
        } catch (e) {
          debugPrint('Parse files failed: $e');
        }
      } else if (map['files'] is List) {
        filesList = (map['files'] as List).map((e) => e.toString()).toList();
      }
    }

    return Message(
      messageId: (map['message_id'] ?? '').toString(),
      turnId: (map['turn_id'] ?? '').toString(),
      runId: (map['run_id'] ?? '').toString(),
      chatId: map['chat_id'] as String,
      botId: map['bot_id'] as String,
      senderId: map['sender_id'] as String,
      content: (map['content'] ?? '') as String,
      reasoning: (map['reasoning'] ?? '') as String,
      processInfo: MessageProcessInfo.fromRaw(map['process_info']),
      images: imagesList,
      files: filesList,
      audio: (map['audio'] ?? '') as String,
      music: (map['music'] ?? '') as String,
      video: (map['video'] ?? '') as String,
      tokenUsage: ModelTokenUsage(
        model: (map['token_model'] ?? '').toString(),
        inputTokens: _storageInt(map['input_token_count']),
        outputTokens: _storageInt(map['output_token_count']),
        totalTokens: _storageInt(map['total_token_count']),
      ),
      terminalOutcome: MessageTerminalOutcome.fromStorage(
        map['terminal_state'],
      ),
      hasPartialContent: switch (map['has_partial_content']) {
        final int value => value != 0,
        final bool value => value,
        _ => false,
      },
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Message copyWith({
    String? messageId,
    String? turnId,
    String? runId,
    String? chatId,
    String? botId,
    String? senderId,
    String? content,
    String? reasoning,
    MessageProcessInfo? processInfo,
    List<String>? images,
    List<String>? files,
    String? audio,
    String? music,
    String? video,
    ModelTokenUsage? tokenUsage,
    MessageTerminalOutcome? terminalOutcome,
    bool clearTerminalOutcome = false,
    bool? hasPartialContent,
    DateTime? timestamp,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      turnId: turnId ?? this.turnId,
      runId: runId ?? this.runId,
      chatId: chatId ?? this.chatId,
      botId: botId ?? this.botId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      reasoning: reasoning ?? this.reasoning,
      processInfo: processInfo ?? this.processInfo,
      images: images ?? this.images,
      files: files ?? this.files,
      audio: audio ?? this.audio,
      music: music ?? this.music,
      video: video ?? this.video,
      tokenUsage: tokenUsage ?? this.tokenUsage,
      terminalOutcome:
          clearTerminalOutcome ? null : terminalOutcome ?? this.terminalOutcome,
      hasPartialContent: hasPartialContent ?? this.hasPartialContent,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, Object> toMap() {
    return {
      'message_id': messageId,
      'turn_id': turnId,
      'run_id': runId,
      'chat_id': chatId,
      'bot_id': botId,
      'sender_id': senderId,
      'content': content,
      'reasoning': reasoning,
      'process_info': jsonEncode(processInfo.toMap()),
      'images': jsonEncode(images),
      'files': jsonEncode(files),
      'audio': audio,
      'music': music,
      'video': video,
      'token_model': tokenUsage.model,
      'input_token_count': tokenUsage.inputTokens,
      'output_token_count': tokenUsage.outputTokens,
      'total_token_count': tokenUsage.effectiveTotalTokens,
      'terminal_state': terminalOutcome?.name ?? '',
      'has_partial_content': hasPartialContent ? 1 : 0,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

int _storageInt(Object? value) {
  return switch (value) {
    final int number => number,
    final num number => number.toInt(),
    _ => int.tryParse(value?.toString() ?? '') ?? 0,
  };
}

// 聊天信息
class Chat {
  final String id;
  final String botId;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final DateTime createTimestamp;
  final DateTime modifyTimestamp;

  const Chat({
    required this.id,
    required this.botId,
    this.lastMessage = '',
    required this.lastMessageTimestamp,
    required this.createTimestamp,
    required this.modifyTimestamp,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      botId: map['bot_id'] as String,
      lastMessage: map['last_message'] as String,
      lastMessageTimestamp: DateTime.fromMillisecondsSinceEpoch(
        map['last_message_timestamp'] as int,
      ),
      createTimestamp: DateTime.fromMillisecondsSinceEpoch(
        map['create_timestamp'] as int,
      ),
      modifyTimestamp: DateTime.fromMillisecondsSinceEpoch(
        map['modify_timestamp'] as int,
      ),
    );
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'bot_id': botId,
      'last_message': lastMessage,
      'last_message_timestamp': lastMessageTimestamp.millisecondsSinceEpoch,
      'create_timestamp': createTimestamp.millisecondsSinceEpoch,
      'modify_timestamp': modifyTimestamp.millisecondsSinceEpoch,
    };
  }
}

class Profile {
  final String name;
  final String avatar;
  final double fontSize;
  final int themeMode;
  final String language;
  final bool showExecutionStatus;
  final DateTime createTimestamp;
  final DateTime modifyTimestamp;

  const Profile({
    required this.name,
    required this.avatar,
    required this.fontSize,
    required this.themeMode,
    required this.language,
    this.showExecutionStatus = true,
    required this.createTimestamp,
    required this.modifyTimestamp,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    final fontSizeValue = map['font_size'];
    final themeModeValue = map['theme_mode'];
    final showExecutionStatusValue = map['show_execution_status'];
    final createTimestampValue = map['create_timestamp'];
    final modifyTimestampValue = map['modify_timestamp'];

    return Profile(
      name: map['name']?.toString() ?? '用户名',
      avatar: map['avatar']?.toString() ?? '',
      fontSize:
          fontSizeValue is num
              ? fontSizeValue.toDouble()
              : double.tryParse(fontSizeValue?.toString() ?? '') ?? 16.0,
      themeMode:
          themeModeValue is num
              ? themeModeValue.toInt()
              : int.tryParse(themeModeValue?.toString() ?? '') ?? 0,
      language: map['language']?.toString() ?? 'zh_CN',
      showExecutionStatus: switch (showExecutionStatusValue) {
        bool value => value,
        num value => value != 0,
        String value => value != '0' && value.toLowerCase() != 'false',
        _ => true,
      },
      createTimestamp: DateTime.fromMillisecondsSinceEpoch(
        createTimestampValue is num
            ? createTimestampValue.toInt()
            : int.tryParse(createTimestampValue?.toString() ?? '') ?? 0,
      ),
      modifyTimestamp: DateTime.fromMillisecondsSinceEpoch(
        modifyTimestampValue is num
            ? modifyTimestampValue.toInt()
            : int.tryParse(modifyTimestampValue?.toString() ?? '') ?? 0,
      ),
    );
  }

  Map<String, Object> toMap() {
    return {
      'name': name,
      'avatar': avatar,
      'font_size': fontSize,
      'theme_mode': themeMode,
      'language': language,
      'show_execution_status': showExecutionStatus ? 1 : 0,
      'create_timestamp': createTimestamp.millisecondsSinceEpoch,
      'modify_timestamp': modifyTimestamp.millisecondsSinceEpoch,
    };
  }
}
