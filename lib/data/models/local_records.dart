import 'dart:convert';

import 'package:hyve/data/models/project_agent_records.dart';
import 'package:hyve/domain/models/models.dart';

/// SQLite representation of a [Bot].
final class BotRecord {
  const BotRecord(this.values);

  factory BotRecord.fromDomain(Bot bot, {required String storedApiKey}) {
    return BotRecord(
      AgentRecord.fromDomain(
        Agent(
          id: bot.id,
          name: bot.name,
          avatar: bot.avatar,
          provider: bot.provider,
          baseUrl: bot.baseURL,
          apiKey: bot.apiKey,
          apiType: bot.apiType,
          model: bot.model,
          systemPrompt: bot.systemPrompt,
          parameters: bot.parameters ?? const <String, Object?>{},
          createdAt: bot.createTimestamp,
          updatedAt: bot.modifyTimestamp,
        ),
        storedApiKey: storedApiKey,
      ).values,
    );
  }

  final Map<String, Object?> values;

  String get id => _string(values['id']);

  String get storedApiKey => _string(values['api_key']);

  Bot toDomain({required String apiKey}) {
    final agent = AgentRecord(values).toDomain(apiKey: apiKey);
    return Bot(
      id: agent.id,
      name: agent.name,
      avatar: agent.avatar,
      provider: agent.provider,
      baseURL: agent.baseUrl,
      apiKey: apiKey,
      apiType: agent.apiType,
      model: agent.model,
      systemPrompt: agent.systemPrompt,
      parameters: Map<String, dynamic>.from(agent.parameters),
      createTimestamp: agent.createdAt,
      modifyTimestamp: agent.updatedAt,
    );
  }
}

/// SQLite representation of a [Chat].
final class ChatRecord {
  const ChatRecord(this.values);

  factory ChatRecord.fromDomain(Chat chat) {
    return ChatRecord({
      'id': chat.id,
      'last_message': chat.lastMessage,
      'last_message_timestamp':
          chat.lastMessageTimestamp.millisecondsSinceEpoch,
      'create_timestamp': chat.createTimestamp.millisecondsSinceEpoch,
      'modify_timestamp': chat.modifyTimestamp.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  Chat toDomain() {
    return Chat(
      id: _string(values['id']),
      name:
          values['project_name'] is String
              ? values['project_name']! as String
              : '',
      botIds: _projectBotIds(values['project_bot_ids']),
      lastMessage: _string(values['last_message']),
      lastMessageTimestamp: _timestamp(values['last_message_timestamp']),
      createTimestamp: _timestamp(values['create_timestamp']),
      modifyTimestamp: _timestamp(values['modify_timestamp']),
    );
  }
}

List<String> _projectBotIds(Object? raw) {
  if (raw is! String) {
    throw const FormatException('Project Bot ids must be stored as JSON text.');
  }
  final decoded = jsonDecode(raw);
  if (decoded is! List<Object?> || decoded.any((item) => item is! String)) {
    throw const FormatException('Project Bot ids must contain a string list.');
  }
  final ids = <String>{...decoded.cast<String>()}..remove('');
  return List<String>.unmodifiable(ids);
}

/// JSON-compatible representation of message execution metadata.
final class MessageProcessInfoRecord {
  const MessageProcessInfoRecord(this.values);

  factory MessageProcessInfoRecord.fromDomain(MessageProcessInfo info) {
    return MessageProcessInfoRecord({
      'reasoning_status': info.reasoningStatus,
      'duration_ms': info.durationMs,
      'tool_calls': info.toolCalls.map(_toolCallToMap).toList(),
      'command_executions':
          info.commandExecutions.map(_commandExecutionToMap).toList(),
      'file_edits': info.fileEdits.map(_fileEditToMap).toList(),
      'skill_activations':
          info.skillActivations.map(_skillActivationToMap).toList(),
    });
  }

  factory MessageProcessInfoRecord.fromRaw(Object? raw) {
    if (raw is! String) {
      throw const FormatException(
        'Message process info must be stored as JSON text.',
      );
    }
    final decoded = jsonDecode(raw);
    final values = _requiredStringMap(decoded, 'Message process info');
    const fields = <String>{
      'reasoning_status',
      'duration_ms',
      'tool_calls',
      'command_executions',
      'file_edits',
      'skill_activations',
    };
    if (values.keys.toSet().difference(fields).isNotEmpty ||
        fields.difference(values.keys.toSet()).isNotEmpty) {
      throw const FormatException(
        'Message process info does not match the current format.',
      );
    }
    return MessageProcessInfoRecord(values);
  }

  final Map<String, Object?> values;

  MessageProcessInfo toDomain() {
    return MessageProcessInfo(
      reasoningStatus: _string(values['reasoning_status']),
      durationMs: _nullableInt(values['duration_ms']),
      toolCalls: _records(values['tool_calls'], _toolCallFromMap),
      commandExecutions: _records(
        values['command_executions'],
        _commandExecutionFromMap,
      ),
      fileEdits: _records(values['file_edits'], _fileEditFromMap),
      skillActivations: _records(
        values['skill_activations'],
        _skillActivationFromMap,
      ),
    );
  }
}

/// SQLite representation of a [Message].
final class MessageRecord {
  const MessageRecord(this.values);

  factory MessageRecord.fromDomain(Message message) {
    return MessageRecord({
      'message_id': message.messageId,
      'turn_id': message.turnId,
      'run_id': message.runId,
      'chat_id': message.chatId,
      'bot_id': message.botId,
      'target_bot_ids': jsonEncode(message.targetBotIds),
      'sender_id': message.senderId,
      'content': message.content,
      'reasoning': message.reasoning,
      'process_info': jsonEncode(
        MessageProcessInfoRecord.fromDomain(message.processInfo).values,
      ),
      'images': jsonEncode(message.images),
      'files': jsonEncode(message.files),
      'audio': message.audio,
      'music': message.music,
      'video': message.video,
      'token_model': message.tokenUsage.model,
      'input_token_count': message.tokenUsage.inputTokens,
      'output_token_count': message.tokenUsage.outputTokens,
      'total_token_count': message.tokenUsage.effectiveTotalTokens,
      'terminal_state': message.terminalOutcome?.name ?? '',
      'has_partial_content': message.hasPartialContent ? 1 : 0,
      'timestamp': message.timestamp.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  Message toDomain() {
    return Message(
      messageId: _string(values['message_id']),
      turnId: _string(values['turn_id']),
      runId: _string(values['run_id']),
      chatId: _string(values['chat_id']),
      botId: _string(values['bot_id']),
      targetBotIds: _stringList(values['target_bot_ids']),
      senderId: _string(values['sender_id']),
      content: _string(values['content']),
      reasoning: _string(values['reasoning']),
      processInfo:
          MessageProcessInfoRecord.fromRaw(values['process_info']).toDomain(),
      images: _stringList(values['images']),
      files: _stringList(values['files']),
      audio: _string(values['audio']),
      music: _string(values['music']),
      video: _string(values['video']),
      tokenUsage: ModelTokenUsage(
        model: _string(values['token_model']),
        inputTokens: _storageInt(values['input_token_count']),
        outputTokens: _storageInt(values['output_token_count']),
        totalTokens: _storageInt(values['total_token_count']),
      ),
      terminalOutcome: _terminalOutcome(values['terminal_state']),
      hasPartialContent: _storageBool(values['has_partial_content']),
      timestamp: _timestamp(values['timestamp']),
    );
  }
}

/// SQLite representation of a [Profile].
final class ProfileRecord {
  const ProfileRecord(this.values);

  factory ProfileRecord.fromDomain(Profile profile) {
    return ProfileRecord({
      'name': profile.name,
      'avatar': profile.avatar,
      'font_size': profile.fontSize,
      'theme_mode': profile.themeMode,
      'language': profile.language,
      'show_execution_status': profile.showExecutionStatus ? 1 : 0,
      'create_timestamp': profile.createTimestamp.millisecondsSinceEpoch,
      'modify_timestamp': profile.modifyTimestamp.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  Profile toDomain() {
    return Profile(
      name: _string(values['name']),
      avatar: _string(values['avatar']),
      fontSize: _storageDouble(values['font_size']),
      themeMode: _storageInt(values['theme_mode']),
      language: _string(values['language']),
      showExecutionStatus: _storageBool(values['show_execution_status']),
      createTimestamp: _timestamp(values['create_timestamp']),
      modifyTimestamp: _timestamp(values['modify_timestamp']),
    );
  }
}

Map<String, Object?> _requiredStringMap(Object? raw, String field) {
  if (raw is! Map<Object?, Object?> || raw.keys.any((key) => key is! String)) {
    throw FormatException('$field must contain a JSON object.');
  }
  return <String, Object?>{
    for (final entry in raw.entries) entry.key! as String: entry.value,
  };
}

List<T> _records<T>(Object? raw, T Function(Map<String, Object?>) decode) {
  if (raw is! List<Object?>) {
    throw const FormatException('Message process records must be a list.');
  }
  return <T>[
    for (final item in raw)
      decode(_requiredStringMap(item, 'Message process record')),
  ];
}

Map<String, Object?> _toolCallToMap(MessageToolCall call) => {
  'call_id': call.callId,
  'name': call.name,
  'title': call.title,
  'mcp_server_name': call.mcpServerName,
  'status': call.status,
  'detail': call.detail,
  'source': call.source,
  'risk_level': call.riskLevel,
  'arguments_summary': call.argumentsSummary,
  'result_summary': call.resultSummary,
  'approval_status': call.approvalStatus,
  'error_code': call.errorCode,
  'duration_ms': call.durationMs,
};

MessageToolCall _toolCallFromMap(Map<String, Object?> values) {
  return MessageToolCall(
    callId: _string(values['call_id']),
    name: _string(values['name']),
    title: _string(values['title']),
    mcpServerName: _string(values['mcp_server_name']),
    status: _string(values['status']),
    detail: _string(values['detail']),
    source: _string(values['source']),
    riskLevel: _string(values['risk_level']),
    argumentsSummary: _string(values['arguments_summary']),
    resultSummary: _string(values['result_summary']),
    approvalStatus: _string(values['approval_status']),
    errorCode: _string(values['error_code']),
    durationMs: _nullableInt(values['duration_ms']),
  );
}

Map<String, Object?> _commandExecutionToMap(
  MessageCommandExecution execution,
) => {
  'call_id': execution.callId,
  'command': execution.command,
  'status': execution.status,
  'detail': execution.detail,
  'duration_ms': execution.durationMs,
};

MessageCommandExecution _commandExecutionFromMap(Map<String, Object?> values) {
  return MessageCommandExecution(
    callId: _string(values['call_id']),
    command: _string(values['command']),
    status: _string(values['status']),
    detail: _string(values['detail']),
    durationMs: _nullableInt(values['duration_ms']),
  );
}

Map<String, Object?> _fileEditToMap(MessageFileEdit edit) => {
  'path': edit.path,
  'type': edit.type,
  'status': edit.status,
  'detail': edit.detail,
};

MessageFileEdit _fileEditFromMap(Map<String, Object?> values) {
  return MessageFileEdit(
    path: _string(values['path']),
    type: _string(values['type']),
    status: _string(values['status']),
    detail: _string(values['detail']),
  );
}

Map<String, Object?> _skillActivationToMap(MessageSkillActivation activation) =>
    {
      'name': activation.name,
      'content_digest': activation.contentDigest,
      'trigger': activation.trigger,
      'status': activation.status,
    };

MessageSkillActivation _skillActivationFromMap(Map<String, Object?> values) {
  return MessageSkillActivation(
    name: _string(values['name']),
    contentDigest: _string(values['content_digest']),
    trigger: _string(values['trigger']),
    status: _string(values['status']),
  );
}

List<String> _stringList(Object? raw) {
  if (raw is! String) {
    throw const FormatException('Message assets must be stored as JSON text.');
  }
  final decoded = jsonDecode(raw);
  if (decoded is! List<Object?> || decoded.any((item) => item is! String)) {
    throw const FormatException('Message assets must contain a string list.');
  }
  return List<String>.unmodifiable(decoded.cast<String>());
}

MessageTerminalOutcome? _terminalOutcome(Object? raw) {
  final name = _string(raw);
  if (name.isEmpty) return null;
  for (final outcome in MessageTerminalOutcome.values) {
    if (outcome.name == name) return outcome;
  }
  throw const FormatException('Message terminal state is invalid.');
}

String _string(Object? value) {
  if (value is String) return value;
  throw const FormatException('Stored value must be a string.');
}

int _storageInt(Object? value) {
  if (value is int) return value;
  throw const FormatException('Stored value must be an integer.');
}

int? _nullableInt(Object? value) => value == null ? null : _storageInt(value);

double _storageDouble(Object? value) {
  if (value is num) return value.toDouble();
  throw const FormatException('Stored value must be numeric.');
}

bool _storageBool(Object? value) {
  return switch (value) {
    0 => false,
    1 => true,
    _ => throw const FormatException('Stored value must be 0 or 1.'),
  };
}

DateTime _timestamp(Object? value) =>
    DateTime.fromMillisecondsSinceEpoch(_storageInt(value));
