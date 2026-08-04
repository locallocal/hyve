import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stars/domain/models/ai_models.dart';
import 'package:stars/domain/models/models.dart';

typedef ProviderResponseDecoder = Object? Function(String source);

final class OpenAiSkillToolSession implements SkillToolSession {
  OpenAiSkillToolSession({
    required Bot bot,
    required SkillToolSessionRequest request,
    required List<Map<String, dynamic>> formattedMessages,
    required Uri uri,
    required Map<String, String> headers,
    required http.Client client,
    required bool closeClient,
    required ProviderResponseDecoder decodeResponse,
  }) : _bot = bot,
       _request = request,
       _messages =
           formattedMessages
               .map((message) => Map<String, Object?>.from(message))
               .toList(),
       _uri = uri,
       _headers = headers,
       _client = client,
       _closeClient = closeClient,
       _decodeResponse = decodeResponse;

  final Bot _bot;
  final SkillToolSessionRequest _request;
  final List<Map<String, Object?>> _messages;
  final Uri _uri;
  final Map<String, String> _headers;
  final http.Client _client;
  final bool _closeClient;
  final ProviderResponseDecoder _decodeResponse;
  bool _started = false;

  @override
  Future<SkillToolTurn> start() {
    if (_started) throw StateError('Skill tool session already started.');
    _started = true;
    return _send();
  }

  @override
  Future<SkillToolTurn> continueWith(List<SkillToolResult> results) async {
    if (!_started) throw StateError('Skill tool session has not started.');
    for (final result in results) {
      _messages.add({
        'role': 'tool',
        'tool_call_id': result.callId,
        'content': result.content,
      });
    }
    return _send();
  }

  Future<SkillToolTurn> _send() async {
    final response = await _client
        .post(
          _uri,
          headers: _headers,
          body: jsonEncode({
            'model': _bot.model,
            'messages': _messages,
            'tools': _openAiSkillTools(_request.catalog),
            'tool_choice': 'auto',
            'parallel_tool_calls': false,
            'stream': false,
          }),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Skill activation request failed: '
        '${response.statusCode} ${response.body}',
      );
    }
    final decoded = _decodeResponse(utf8.decode(response.bodyBytes));
    final root = _objectMap(decoded);
    final choices = _objectList(root['choices']);
    if (choices.isEmpty) {
      throw const FormatException('Skill activation response has no choices.');
    }
    final message = _objectMap(_objectMap(choices.first)['message']);
    final rawCalls = _objectList(message['tool_calls']);
    _messages.add({
      'role': 'assistant',
      'content': message['content']?.toString() ?? '',
      if (rawCalls.isNotEmpty) 'tool_calls': rawCalls,
    });
    final calls = <SkillToolCall>[];
    for (final rawCall in rawCalls) {
      final call = _objectMap(rawCall);
      final function = _objectMap(call['function']);
      calls.add(
        SkillToolCall(
          callId: call['id']?.toString() ?? '',
          name: function['name']?.toString() ?? '',
          arguments: _decodeArguments(function['arguments']),
        ),
      );
    }
    return SkillToolTurn(
      calls: calls,
      isComplete: calls.isEmpty,
      tokenUsage: _openAiUsage(root, _bot.model),
    );
  }

  @override
  void close() {
    if (_closeClient) _client.close();
  }
}

/// Non-streaming Skill activation over the Responses API.
///
/// Responses tool calls and tool outputs are separate input items correlated
/// by `call_id`; the complete model output is retained between turns so
/// reasoning items remain available to reasoning models.
final class OpenAiResponsesSkillToolSession implements SkillToolSession {
  OpenAiResponsesSkillToolSession({
    required Bot bot,
    required SkillToolSessionRequest request,
    required List<Map<String, dynamic>> formattedInput,
    required Uri uri,
    required Map<String, String> headers,
    required http.Client client,
    required bool closeClient,
    required ProviderResponseDecoder decodeResponse,
  }) : _bot = bot,
       _request = request,
       _input =
           formattedInput
               .map((item) => Map<String, Object?>.from(item))
               .toList(),
       _uri = uri,
       _headers = headers,
       _client = client,
       _closeClient = closeClient,
       _decodeResponse = decodeResponse;

  final Bot _bot;
  final SkillToolSessionRequest _request;
  final List<Map<String, Object?>> _input;
  final Uri _uri;
  final Map<String, String> _headers;
  final http.Client _client;
  final bool _closeClient;
  final ProviderResponseDecoder _decodeResponse;
  bool _started = false;

  @override
  Future<SkillToolTurn> start() {
    if (_started) throw StateError('Skill tool session already started.');
    _started = true;
    return _send();
  }

  @override
  Future<SkillToolTurn> continueWith(List<SkillToolResult> results) async {
    if (!_started) throw StateError('Skill tool session has not started.');
    for (final result in results) {
      _input.add({
        'type': 'function_call_output',
        'call_id': result.callId,
        'output': result.content,
      });
    }
    return _send();
  }

  Future<SkillToolTurn> _send() async {
    final response = await _client
        .post(
          _uri,
          headers: _headers,
          body: jsonEncode({
            'model': _bot.model,
            'input': _input,
            'tools': _openAiResponsesSkillTools(_request.catalog),
            'tool_choice': 'auto',
            'parallel_tool_calls': false,
          }),
        )
        .timeout(const Duration(seconds: 60));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Skill activation request failed: '
        '${response.statusCode} ${response.body}',
      );
    }
    final root = _objectMap(_decodeResponse(utf8.decode(response.bodyBytes)));
    final output = _objectList(root['output']);
    _input.addAll(output.map(_objectMap));

    final calls = <SkillToolCall>[];
    for (final rawItem in output) {
      final item = _objectMap(rawItem);
      if (item['type'] != 'function_call') continue;
      calls.add(
        SkillToolCall(
          callId: item['call_id']?.toString() ?? '',
          name: item['name']?.toString() ?? '',
          arguments: _decodeArguments(item['arguments']),
        ),
      );
    }
    return SkillToolTurn(
      calls: calls,
      isComplete: calls.isEmpty,
      tokenUsage: _openAiResponsesUsage(root, _bot.model),
    );
  }

  @override
  void close() {
    if (_closeClient) _client.close();
  }
}

final class AnthropicSkillToolSession implements SkillToolSession {
  AnthropicSkillToolSession({
    required Bot bot,
    required SkillToolSessionRequest request,
    required String system,
    required List<Map<String, dynamic>> formattedMessages,
    required Uri uri,
    required Map<String, String> headers,
    required int maxTokens,
    required http.Client client,
    required bool closeClient,
    required ProviderResponseDecoder decodeResponse,
  }) : _bot = bot,
       _request = request,
       _system = system,
       _messages =
           formattedMessages
               .map((message) => Map<String, Object?>.from(message))
               .toList(),
       _uri = uri,
       _headers = headers,
       _maxTokens = maxTokens,
       _client = client,
       _closeClient = closeClient,
       _decodeResponse = decodeResponse;

  final Bot _bot;
  final SkillToolSessionRequest _request;
  final String _system;
  final List<Map<String, Object?>> _messages;
  final Uri _uri;
  final Map<String, String> _headers;
  final int _maxTokens;
  final http.Client _client;
  final bool _closeClient;
  final ProviderResponseDecoder _decodeResponse;
  bool _started = false;

  @override
  Future<SkillToolTurn> start() {
    if (_started) throw StateError('Skill tool session already started.');
    _started = true;
    return _send();
  }

  @override
  Future<SkillToolTurn> continueWith(List<SkillToolResult> results) async {
    if (!_started) throw StateError('Skill tool session has not started.');
    _messages.add({
      'role': 'user',
      'content': [
        for (final result in results)
          {
            'type': 'tool_result',
            'tool_use_id': result.callId,
            'content': result.content,
            'is_error': result.isError,
          },
      ],
    });
    return _send();
  }

  Future<SkillToolTurn> _send() async {
    final response = await _client
        .post(
          _uri,
          headers: _headers,
          body: jsonEncode({
            'model': _bot.model,
            'messages': _messages,
            'system': _system,
            'tools': _anthropicSkillTools(_request.catalog),
            'tool_choice': {'type': 'auto'},
            'max_tokens': _maxTokens < 1024 ? _maxTokens : 1024,
            'stream': false,
          }),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Skill activation request failed: '
        '${response.statusCode} ${response.body}',
      );
    }
    final decoded = _decodeResponse(utf8.decode(response.bodyBytes));
    final root = _objectMap(decoded);
    final content = _objectList(root['content']);
    _messages.add({'role': 'assistant', 'content': content});
    final calls = <SkillToolCall>[];
    for (final rawBlock in content) {
      final block = _objectMap(rawBlock);
      if (block['type'] != 'tool_use') continue;
      calls.add(
        SkillToolCall(
          callId: block['id']?.toString() ?? '',
          name: block['name']?.toString() ?? '',
          arguments: _objectMap(block['input']),
        ),
      );
    }
    return SkillToolTurn(
      calls: calls,
      isComplete: calls.isEmpty,
      tokenUsage: _anthropicUsage(root, _bot.model),
    );
  }

  @override
  void close() {
    if (_closeClient) _client.close();
  }
}

final class OpenAiAgentModelSession implements AgentModelSession {
  OpenAiAgentModelSession({
    required Bot bot,
    required ModelRequest request,
    required List<Map<String, dynamic>> formattedMessages,
    required Uri uri,
    required Map<String, String> headers,
    required http.Client client,
    required bool closeClient,
    required ProviderResponseDecoder decodeResponse,
    String? reasoningEffort,
    bool streamResponses = false,
    Map<String, Object?> additionalBody = const {},
  }) : _bot = bot,
       _request = request,
       _toolNames = _ProviderToolNameCodec(request.tools),
       _messages =
           formattedMessages
               .map((message) => Map<String, Object?>.from(message))
               .toList(),
       _uri = uri,
       _headers = headers,
       _client = client,
       _closeClient = closeClient,
       _decodeResponse = decodeResponse,
       _reasoningEffort = reasoningEffort,
       _streamResponses = streamResponses,
       _additionalBody = Map<String, Object?>.unmodifiable(additionalBody);

  final Bot _bot;
  final ModelRequest _request;
  final _ProviderToolNameCodec _toolNames;
  final List<Map<String, Object?>> _messages;
  final Uri _uri;
  final Map<String, String> _headers;
  final http.Client _client;
  final bool _closeClient;
  final ProviderResponseDecoder _decodeResponse;
  final String? _reasoningEffort;
  final bool _streamResponses;
  final Map<String, Object?> _additionalBody;
  bool _started = false;
  bool _closed = false;

  @override
  Stream<ModelEvent> start() {
    if (_started) {
      throw StateError('Agent model session already started.');
    }
    _started = true;
    return _send();
  }

  @override
  Stream<ModelEvent> continueWith(List<ToolResult> results) {
    if (!_started) {
      throw StateError('Agent model session has not started.');
    }
    for (final result in results) {
      _messages.add({
        'role': 'tool',
        'tool_call_id': result.callId,
        'content': result.content,
      });
    }
    return _send();
  }

  Stream<ModelEvent> _send() async* {
    if (_streamResponses && _request.options.stream) {
      yield* _sendStreaming();
      return;
    }

    final response = await _client
        .post(
          _uri,
          headers: _headers,
          body: jsonEncode(_requestBody(stream: false)),
        )
        .timeout(const Duration(seconds: 60));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      yield ModelTurnFailed(
        error: 'Model request failed: ${response.statusCode} ${response.body}',
        code: 'provider_http_error',
      );
      return;
    }
    final root = _objectMap(_decodeResponse(utf8.decode(response.bodyBytes)));
    final choices = _objectList(root['choices']);
    if (choices.isEmpty) {
      yield const ModelTurnFailed(
        error: 'Model response has no choices.',
        code: 'invalid_provider_response',
      );
      return;
    }
    final choice = _objectMap(choices.first);
    final message = _objectMap(choice['message']);
    final rawCalls = _objectList(message['tool_calls']);
    _messages.add({
      'role': 'assistant',
      'content': message['content']?.toString() ?? '',
      if (rawCalls.isNotEmpty) 'tool_calls': rawCalls,
    });

    final reasoning =
        message['reasoning_content']?.toString() ??
        message['reasoning']?.toString() ??
        '';
    if (reasoning.isNotEmpty) yield ReasoningDelta(reasoning);
    final content = message['content']?.toString() ?? '';
    if (content.isNotEmpty) yield TextDelta(content);
    for (final rawCall in rawCalls) {
      final call = _objectMap(rawCall);
      final function = _objectMap(call['function']);
      final callId = call['id']?.toString() ?? '';
      final name = _toolNames.canonical(function['name']?.toString() ?? '');
      final rawArguments = function['arguments'];
      yield ToolCallStarted(callId: callId, name: name);
      if (rawArguments is String && rawArguments.isNotEmpty) {
        yield ToolCallArgumentsDelta(
          callId: callId,
          argumentsDelta: rawArguments,
        );
      }
      yield ToolCallRequested(
        callId: callId,
        name: name,
        arguments: _decodeArguments(rawArguments),
      );
    }
    final usage = _openAiUsage(root, _bot.model);
    if (usage.hasData) yield UsageReported(usage);
    yield ModelTurnCompleted(
      stopReason: choice['finish_reason']?.toString() ?? '',
    );
  }

  Stream<ModelEvent> _sendStreaming() async* {
    final request =
        http.Request('POST', _uri)
          ..headers.addAll(_headers)
          ..body = jsonEncode(_requestBody(stream: true));
    final response = await _client
        .send(request)
        .timeout(const Duration(seconds: 60));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      yield ModelTurnFailed(
        error: 'Model request failed: ${response.statusCode} $body',
        code: 'provider_http_error',
      );
      return;
    }

    final content = StringBuffer();
    final reasoning = StringBuffer();
    final toolCalls = <int, _OpenAiStreamedToolCallBuilder>{};
    var usage = ModelTokenUsage.empty;
    var finishReason = '';
    var receivedDone = false;

    await for (final source in _sseData(response.stream)) {
      if (source == '[DONE]') {
        receivedDone = true;
        break;
      }

      final root = _objectMap(_decodeResponse(source));
      if (root['error'] != null) {
        yield ModelTurnFailed(
          error: 'Model request failed: ${root['error']}',
          code: 'provider_stream_error',
        );
        return;
      }
      usage = usage.merge(_openAiUsage(root, _bot.model));

      final choices = _objectList(root['choices']);
      if (choices.isEmpty) continue;
      final choice = _objectMap(choices.first);
      usage = usage.merge(_openAiUsage(choice, _bot.model));
      final nextFinishReason = choice['finish_reason']?.toString() ?? '';
      if (nextFinishReason.isNotEmpty) finishReason = nextFinishReason;

      final delta = _objectMap(choice['delta']);
      final reasoningDelta = _streamedText(
        delta['reasoning_content'] ?? delta['reasoning'],
      );
      if (reasoningDelta.isNotEmpty) {
        reasoning.write(reasoningDelta);
        yield ReasoningDelta(reasoningDelta);
      }
      final contentDelta = _streamedText(delta['content']);
      if (contentDelta.isNotEmpty) {
        content.write(contentDelta);
        yield TextDelta(contentDelta);
      }

      final rawCalls = _objectList(delta['tool_calls']);
      for (var position = 0; position < rawCalls.length; position++) {
        final rawCall = _objectMap(rawCalls[position]);
        final index = _integer(rawCall['index'], fallback: position);
        toolCalls
            .putIfAbsent(index, _OpenAiStreamedToolCallBuilder.new)
            .append(rawCall);
      }
    }

    if (!receivedDone) {
      yield const ModelTurnFailed(
        error: 'Model response stream ended before data: [DONE].',
        code: 'incomplete_provider_stream',
      );
      return;
    }

    final orderedCalls =
        toolCalls.entries.toList()
          ..sort((left, right) => left.key.compareTo(right.key));
    final rawCalls = [for (final entry in orderedCalls) entry.value.toJson()];
    _messages.add({
      'role': 'assistant',
      'content': content.toString(),
      if (reasoning.isNotEmpty) 'reasoning_content': reasoning.toString(),
      if (rawCalls.isNotEmpty) 'tool_calls': rawCalls,
    });

    for (final entry in orderedCalls) {
      final call = entry.value;
      final name = _toolNames.canonical(call.name.toString());
      yield ToolCallStarted(callId: call.id, name: name);
      final arguments = call.arguments.toString();
      if (arguments.isNotEmpty) {
        yield ToolCallArgumentsDelta(
          callId: call.id,
          argumentsDelta: arguments,
        );
      }
      yield ToolCallRequested(
        callId: call.id,
        name: name,
        arguments: _decodeArguments(arguments),
      );
    }
    if (usage.hasData) yield UsageReported(usage);
    yield ModelTurnCompleted(stopReason: finishReason);
  }

  Map<String, Object?> _requestBody({required bool stream}) => {
    'model': _bot.model,
    'messages': _messages,
    if (_request.tools.isNotEmpty) ...{
      'tools': _openAiTools(_request.tools, _toolNames),
      'tool_choice': 'auto',
      'parallel_tool_calls': _request.options.allowParallelToolCalls,
    },
    if (_request.options.deepThinking && _reasoningEffort != null)
      'reasoning_effort': _reasoningEffort,
    ..._additionalBody,
    'stream': stream,
    if (stream) 'stream_options': const {'include_usage': true},
  };

  @override
  Future<void> cancel() async {
    if (_closed) return;
    _closed = true;
    _client.close();
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    if (_closeClient) _client.close();
  }
}

final class _OpenAiStreamedToolCallBuilder {
  String id = '';
  String type = '';
  final StringBuffer name = StringBuffer();
  final StringBuffer arguments = StringBuffer();

  void append(Map<String, Object?> rawCall) {
    final idDelta = rawCall['id']?.toString() ?? '';
    if (idDelta.isNotEmpty) id = idDelta;
    final typeDelta = rawCall['type']?.toString() ?? '';
    if (typeDelta.isNotEmpty) type = typeDelta;

    final function = _objectMap(rawCall['function']);
    name.write(function['name']?.toString() ?? '');
    arguments.write(function['arguments']?.toString() ?? '');
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'type': type.isEmpty ? 'function' : type,
    'function': {
      'name': name.toString(),
      'arguments': arguments.isEmpty ? '{}' : arguments.toString(),
    },
  };
}

final class OpenAiResponsesAgentModelSession implements AgentModelSession {
  OpenAiResponsesAgentModelSession({
    required Bot bot,
    required ModelRequest request,
    required List<Map<String, dynamic>> formattedInput,
    required Uri uri,
    required Map<String, String> headers,
    required http.Client client,
    required bool closeClient,
    required ProviderResponseDecoder decodeResponse,
    String? reasoningEffort,
  }) : _bot = bot,
       _request = request,
       _toolNames = _ProviderToolNameCodec(request.tools),
       _input =
           formattedInput
               .map((item) => Map<String, Object?>.from(item))
               .toList(),
       _uri = uri,
       _headers = headers,
       _client = client,
       _closeClient = closeClient,
       _decodeResponse = decodeResponse,
       _reasoningEffort = reasoningEffort;

  final Bot _bot;
  final ModelRequest _request;
  final _ProviderToolNameCodec _toolNames;
  final List<Map<String, Object?>> _input;
  final Uri _uri;
  final Map<String, String> _headers;
  final http.Client _client;
  final bool _closeClient;
  final ProviderResponseDecoder _decodeResponse;
  final String? _reasoningEffort;
  bool _started = false;
  bool _closed = false;

  @override
  Stream<ModelEvent> start() {
    if (_started) throw StateError('Agent model session already started.');
    _started = true;
    return _send();
  }

  @override
  Stream<ModelEvent> continueWith(List<ToolResult> results) {
    if (!_started) {
      throw StateError('Agent model session has not started.');
    }
    for (final result in results) {
      _input.add({
        'type': 'function_call_output',
        'call_id': result.callId,
        'output': result.content,
      });
    }
    return _send();
  }

  Stream<ModelEvent> _send() async* {
    final tools = _openAiResponsesTools(_request.tools, _toolNames);
    if (_request.options.webSearch) tools.add({'type': 'web_search'});
    final response = await _client
        .post(
          _uri,
          headers: _headers,
          body: jsonEncode({
            'model': _bot.model,
            'input': _input,
            if (tools.isNotEmpty) ...{
              'tools': tools,
              'tool_choice': 'auto',
              'parallel_tool_calls': _request.options.allowParallelToolCalls,
            },
            if (_request.options.deepThinking && _reasoningEffort != null)
              'reasoning': {'effort': _reasoningEffort, 'summary': 'auto'},
          }),
        )
        .timeout(const Duration(seconds: 60));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      yield ModelTurnFailed(
        error: 'Model request failed: ${response.statusCode} ${response.body}',
        code: 'provider_http_error',
      );
      return;
    }

    final root = _objectMap(_decodeResponse(utf8.decode(response.bodyBytes)));
    final output = _objectList(root['output']);
    if (output.isEmpty) {
      yield const ModelTurnFailed(
        error: 'Model response has no output items.',
        code: 'invalid_provider_response',
      );
      return;
    }
    _input.addAll(output.map(_objectMap));

    var hasToolCalls = false;
    for (final rawItem in output) {
      final item = _objectMap(rawItem);
      switch (item['type']) {
        case 'reasoning':
          for (final rawSummary in _objectList(item['summary'])) {
            final summary = _objectMap(rawSummary);
            final text = summary['text']?.toString() ?? '';
            if (text.isNotEmpty) yield ReasoningDelta(text);
          }
        case 'message':
          for (final rawContent in _objectList(item['content'])) {
            final content = _objectMap(rawContent);
            if (content['type'] != 'output_text') continue;
            final text = content['text']?.toString() ?? '';
            if (text.isNotEmpty) yield TextDelta(text);
          }
        case 'function_call':
          hasToolCalls = true;
          final callId = item['call_id']?.toString() ?? '';
          final name = _toolNames.canonical(item['name']?.toString() ?? '');
          final rawArguments = item['arguments'];
          yield ToolCallStarted(callId: callId, name: name);
          if (rawArguments is String && rawArguments.isNotEmpty) {
            yield ToolCallArgumentsDelta(
              callId: callId,
              argumentsDelta: rawArguments,
            );
          }
          yield ToolCallRequested(
            callId: callId,
            name: name,
            arguments: _decodeArguments(rawArguments),
          );
      }
    }

    final usage = _openAiResponsesUsage(root, _bot.model);
    if (usage.hasData) yield UsageReported(usage);
    yield ModelTurnCompleted(
      stopReason:
          hasToolCalls ? 'tool_calls' : root['status']?.toString() ?? '',
    );
  }

  @override
  Future<void> cancel() async {
    if (_closed) return;
    _closed = true;
    _client.close();
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    if (_closeClient) _client.close();
  }
}

final class AnthropicAgentModelSession implements AgentModelSession {
  AnthropicAgentModelSession({
    required Bot bot,
    required ModelRequest request,
    required String system,
    required List<Map<String, dynamic>> formattedMessages,
    required Uri uri,
    required Map<String, String> headers,
    required int maxTokens,
    required http.Client client,
    required bool closeClient,
    required ProviderResponseDecoder decodeResponse,
  }) : _bot = bot,
       _request = request,
       _toolNames = _ProviderToolNameCodec(request.tools),
       _system = system,
       _messages =
           formattedMessages
               .map((message) => Map<String, Object?>.from(message))
               .toList(),
       _uri = uri,
       _headers = headers,
       _maxTokens = maxTokens,
       _client = client,
       _closeClient = closeClient,
       _decodeResponse = decodeResponse;

  final Bot _bot;
  final ModelRequest _request;
  final _ProviderToolNameCodec _toolNames;
  final String _system;
  final List<Map<String, Object?>> _messages;
  final Uri _uri;
  final Map<String, String> _headers;
  final int _maxTokens;
  final http.Client _client;
  final bool _closeClient;
  final ProviderResponseDecoder _decodeResponse;
  bool _started = false;
  bool _closed = false;

  @override
  Stream<ModelEvent> start() {
    if (_started) {
      throw StateError('Agent model session already started.');
    }
    _started = true;
    return _send();
  }

  @override
  Stream<ModelEvent> continueWith(List<ToolResult> results) {
    if (!_started) {
      throw StateError('Agent model session has not started.');
    }
    _messages.add({
      'role': 'user',
      'content': [
        for (final result in results)
          {
            'type': 'tool_result',
            'tool_use_id': result.callId,
            'content': result.content,
            'is_error': result.isError,
          },
      ],
    });
    return _send();
  }

  Stream<ModelEvent> _send() async* {
    final response = await _client
        .post(
          _uri,
          headers: _headers,
          body: jsonEncode({
            'model': _bot.model,
            'messages': _messages,
            'system': _system,
            if (_request.tools.isNotEmpty) ...{
              'tools': _anthropicTools(_request.tools, _toolNames),
              'tool_choice': {'type': 'auto'},
            },
            'max_tokens': _maxTokens,
            if (_request.options.deepThinking)
              'thinking': {'type': 'enabled', 'budget_tokens': 16000},
            'stream': false,
          }),
        )
        .timeout(const Duration(seconds: 60));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      yield ModelTurnFailed(
        error: 'Model request failed: ${response.statusCode} ${response.body}',
        code: 'provider_http_error',
      );
      return;
    }
    final root = _objectMap(_decodeResponse(utf8.decode(response.bodyBytes)));
    final content = _objectList(root['content']);
    _messages.add({'role': 'assistant', 'content': content});
    for (final rawBlock in content) {
      final block = _objectMap(rawBlock);
      switch (block['type']) {
        case 'text':
          final text = block['text']?.toString() ?? '';
          if (text.isNotEmpty) yield TextDelta(text);
        case 'thinking':
          final thinking = block['thinking']?.toString() ?? '';
          if (thinking.isNotEmpty) yield ReasoningDelta(thinking);
        case 'tool_use':
          final callId = block['id']?.toString() ?? '';
          final name = _toolNames.canonical(block['name']?.toString() ?? '');
          yield ToolCallStarted(callId: callId, name: name);
          yield ToolCallRequested(
            callId: callId,
            name: name,
            arguments: _objectMap(block['input']),
          );
      }
    }
    final usage = _anthropicUsage(root, _bot.model);
    if (usage.hasData) yield UsageReported(usage);
    yield ModelTurnCompleted(stopReason: root['stop_reason']?.toString() ?? '');
  }

  @override
  Future<void> cancel() async {
    if (_closed) return;
    _closed = true;
    _client.close();
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    if (_closeClient) _client.close();
  }
}

List<Map<String, Object?>> _openAiSkillTools(List<SkillCatalogEntry> catalog) {
  final names = catalog.map((entry) => entry.name).toList(growable: false);
  return [
    {
      'type': 'function',
      'function': {
        'name': 'activate_skill',
        'description':
            'Load one available Skill when it is relevant to the user request.',
        'strict': true,
        'parameters': {
          'type': 'object',
          'properties': {
            'name': {'type': 'string', 'enum': names},
          },
          'required': ['name'],
          'additionalProperties': false,
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'read_skill_resource',
        'description':
            'Read a UTF-8 text file under references/ for an activated Skill.',
        'strict': true,
        'parameters': {
          'type': 'object',
          'properties': {
            'name': {'type': 'string', 'enum': names},
            'path': {
              'type': 'string',
              'description': 'A relative path beginning with references/.',
            },
          },
          'required': ['name', 'path'],
          'additionalProperties': false,
        },
      },
    },
  ];
}

List<Map<String, Object?>> _openAiResponsesSkillTools(
  List<SkillCatalogEntry> catalog,
) {
  return [
    for (final tool in _openAiSkillTools(catalog))
      {'type': 'function', ..._objectMap(tool['function'])},
  ];
}

List<Map<String, Object?>> _openAiTools(
  List<ToolDefinition> definitions,
  _ProviderToolNameCodec names,
) {
  return [
    for (final definition in definitions)
      {
        'type': 'function',
        'function': {
          'name': names.wire(definition.name),
          'description': definition.description,
          'parameters': definition.inputSchema,
        },
      },
  ];
}

List<Map<String, Object?>> _openAiResponsesTools(
  List<ToolDefinition> definitions,
  _ProviderToolNameCodec names,
) {
  return [
    for (final definition in definitions)
      {
        'type': 'function',
        'name': names.wire(definition.name),
        'description': definition.description,
        'parameters': definition.inputSchema,
      },
  ];
}

List<Map<String, Object?>> _anthropicTools(
  List<ToolDefinition> definitions,
  _ProviderToolNameCodec names,
) {
  return [
    for (final definition in definitions)
      {
        'name': names.wire(definition.name),
        'description': definition.description,
        'input_schema': definition.inputSchema,
      },
  ];
}

final class _ProviderToolNameCodec {
  _ProviderToolNameCodec(List<ToolDefinition> definitions) {
    for (final definition in definitions) {
      final canonical = definition.name;
      final alias = _createAlias(canonical);
      if (_canonicalByWire.containsKey(alias)) {
        throw ArgumentError.value(
          canonical,
          'definitions',
          'Provider Tool aliases must be unique.',
        );
      }
      _wireByCanonical[canonical] = alias;
      _canonicalByWire[alias] = canonical;
    }
  }

  final Map<String, String> _wireByCanonical = {};
  final Map<String, String> _canonicalByWire = {};

  String wire(String canonical) => _wireByCanonical[canonical] ?? canonical;

  String canonical(String wireName) => _canonicalByWire[wireName] ?? wireName;

  String _createAlias(String canonical) {
    if (canonical.length <= 64 &&
        RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(canonical)) {
      return canonical;
    }
    var base = canonical.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
    if (base.isEmpty) base = 'tool';
    final hash = _stableToolNameHash(canonical);
    final maximumBaseLength = 64 - hash.length - 1;
    if (base.length > maximumBaseLength) {
      base = base.substring(0, maximumBaseLength);
    }
    return '${base}_$hash';
  }
}

String _stableToolNameHash(String value) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(value)) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

List<Map<String, Object?>> _anthropicSkillTools(
  List<SkillCatalogEntry> catalog,
) {
  return [
    for (final tool in _openAiSkillTools(catalog))
      {
        'name': _objectMap(tool['function'])['name'],
        'description': _objectMap(tool['function'])['description'],
        'input_schema': _objectMap(tool['function'])['parameters'],
      },
  ];
}

Map<String, Object?> _decodeArguments(Object? value) {
  if (value is Map) return _objectMap(value);
  if (value is! String || value.isEmpty) return const {};
  try {
    return _objectMap(jsonDecode(value));
  } on FormatException {
    return const {};
  }
}

Map<String, Object?> _objectMap(Object? value) {
  if (value is! Map) return const {};
  return value.map(
    (key, mapValue) => MapEntry(key.toString(), mapValue as Object?),
  );
}

List<Object?> _objectList(Object? value) {
  if (value is! List) return const [];
  return List<Object?>.from(value);
}

ModelTokenUsage _openAiUsage(Map<String, Object?> root, String model) {
  final usage = _objectMap(root['usage']);
  return ModelTokenUsage(
    model: model,
    inputTokens: _integer(usage['prompt_tokens']),
    outputTokens: _integer(usage['completion_tokens']),
    totalTokens: _integer(usage['total_tokens']),
  );
}

ModelTokenUsage _openAiResponsesUsage(Map<String, Object?> root, String model) {
  final usage = _objectMap(root['usage']);
  return ModelTokenUsage(
    model: model,
    inputTokens: _integer(usage['input_tokens']),
    outputTokens: _integer(usage['output_tokens']),
    totalTokens: _integer(usage['total_tokens']),
  );
}

ModelTokenUsage _anthropicUsage(Map<String, Object?> root, String model) {
  final usage = _objectMap(root['usage']);
  final input = _integer(usage['input_tokens']);
  final output = _integer(usage['output_tokens']);
  return ModelTokenUsage(
    model: model,
    inputTokens: input,
    outputTokens: output,
    totalTokens: input + output,
  );
}

int _integer(Object? value, {int fallback = 0}) {
  return switch (value) {
    final int number => number,
    final num number => number.toInt(),
    _ => int.tryParse(value?.toString() ?? '') ?? fallback,
  };
}

String _streamedText(Object? value) {
  if (value is String) return value;
  if (value is! List) return '';
  final text = StringBuffer();
  for (final item in value) {
    final part = _objectMap(item);
    final value = part['text'] ?? part['content'];
    if (value != null) text.write(value);
  }
  return text.toString();
}

Stream<String> _sseData(Stream<List<int>> bytes) async* {
  var data = StringBuffer();
  var hasData = false;
  final lines = bytes.transform(utf8.decoder).transform(const LineSplitter());
  await for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      if (hasData) yield data.toString();
      data = StringBuffer();
      hasData = false;
      continue;
    }
    if (line.startsWith(':')) continue;
    if (line.startsWith('data:')) {
      if (hasData) data.write('\n');
      data.write(line.substring(5).trimLeft());
      hasData = true;
      continue;
    }
    if (hasData) {
      data
        ..write('\n')
        ..write(line);
    }
  }
  if (hasData) yield data.toString();
}
