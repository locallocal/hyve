import 'dart:convert';

import 'package:stars/data/services/mcp/mcp_transport.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/mcp_client.dart';
import 'package:stars/domain/repositories/mcp_credential_store.dart';

final class McpClientService implements McpClient {
  McpClientService({
    required Iterable<McpTransport> transports,
    required McpCredentialStore credentialStore,
    DateTime Function()? now,
  }) : _transports = _indexTransports(transports),
       _credentialStore = credentialStore,
       _now = now ?? DateTime.now;

  static const String protocolVersion = '2025-11-25';
  static const int _maxCatalogPages = 100;
  static const int _maxCatalogTools = 10000;

  final Map<McpTransportType, McpTransport> _transports;
  final McpCredentialStore _credentialStore;
  final DateTime Function() _now;
  final Map<String, _McpSession> _sessions = {};
  final Map<String, _PendingInitialization> _pendingInitializations = {};
  final Map<String, int> _connectionEpochs = {};
  int _nextRequestId = 1;

  @override
  Future<McpServerCatalog> discoverTools(
    McpServer server, {
    AgentCancellationToken? cancellationToken,
  }) async {
    final cancellation = cancellationToken ?? AgentCancellationToken();
    for (var attempt = 0; attempt < 2; attempt += 1) {
      final session = await _sessionFor(server, cancellation);
      try {
        final tools = await _listTools(server, session, cancellation);
        return McpServerCatalog(
          serverName: session.serverName,
          serverVersion: session.serverVersion,
          capabilities: session.capabilities,
          tools: tools,
          instructions: session.instructions,
        );
      } on McpException catch (error) {
        if (error.code != 'mcp_session_expired' || attempt != 0) rethrow;
        await _discardSession(server);
      }
    }
    throw StateError('Unreachable MCP discovery state.');
  }

  @override
  Future<McpToolCallResult> callTool({
    required McpServer server,
    required String remoteName,
    required Map<String, Object?> arguments,
    required AgentCancellationToken cancellationToken,
  }) async {
    for (var attempt = 0; attempt < 2; attempt += 1) {
      final session = await _sessionFor(server, cancellationToken);
      if (!session.capabilities.tools) {
        throw const McpException(
          'mcp_tools_not_supported',
          message: 'This MCP server does not advertise Tool support.',
        );
      }
      try {
        final request = _request('tools/call', {
          'name': remoteName,
          'arguments': arguments,
        });
        final response = await _send(
          server: server,
          session: session,
          cancellationToken: cancellationToken,
          payload: request,
        );
        final result = _result(response.payload, expectedId: request['id']);
        final rawContent = result['content'];
        if (rawContent is! List) {
          throw const McpException(
            'mcp_invalid_tool_result',
            message: 'The MCP Tool result content must be an array.',
          );
        }
        final rawStructuredContent = result['structuredContent'];
        if (rawStructuredContent != null && rawStructuredContent is! Map) {
          throw const McpException(
            'mcp_invalid_tool_result',
            message: 'The MCP Tool structured result must be an object.',
          );
        }
        final rawIsError = result['isError'];
        if (rawIsError != null && rawIsError is! bool) {
          throw const McpException(
            'mcp_invalid_tool_result',
            message: 'The MCP Tool isError field must be a boolean.',
          );
        }
        return McpToolCallResult(
          content: _formatContent(rawContent),
          structuredContent:
              rawStructuredContent == null
                  ? null
                  : _objectMap(
                    rawStructuredContent,
                    code: 'mcp_invalid_tool_result',
                  ),
          isError: rawIsError == true,
        );
      } on McpException catch (error) {
        if (error.code != 'mcp_session_expired' || attempt != 0) rethrow;
        await _discardSession(server);
      }
    }
    throw StateError('Unreachable MCP Tool call state.');
  }

  @override
  Future<void> disconnect(McpServer server) async {
    _connectionEpochs[server.id] = (_connectionEpochs[server.id] ?? 0) + 1;
    _pendingInitializations.remove(server.id);
    await _discardSession(server);
  }

  Future<_McpSession> _sessionFor(
    McpServer server,
    AgentCancellationToken cancellationToken,
  ) async {
    cancellationToken.throwIfCancelled();
    final fingerprint = _fingerprint(server);
    final existing = _sessions[server.id];
    if (existing != null && existing.fingerprint == fingerprint) {
      return existing;
    }

    final pending = _pendingInitializations[server.id];
    if (pending != null && pending.fingerprint == fingerprint) {
      return pending.future;
    }
    if (pending != null) {
      try {
        await pending.future;
      } on Object {
        // A replacement configuration starts independently after the old
        // initialization reaches a terminal state.
      }
      cancellationToken.throwIfCancelled();
    }

    await _discardSession(server);
    final future = _initialize(
      server,
      fingerprint,
      _connectionEpochs[server.id] ?? 0,
      cancellationToken,
    );
    final initialization = _PendingInitialization(fingerprint, future);
    _pendingInitializations[server.id] = initialization;
    try {
      return await future;
    } finally {
      if (identical(_pendingInitializations[server.id], initialization)) {
        _pendingInitializations.remove(server.id);
      }
    }
  }

  Future<_McpSession> _initialize(
    McpServer server,
    String fingerprint,
    int connectionEpoch,
    AgentCancellationToken cancellationToken,
  ) async {
    final credential = await _credentialStore.read(server.id);
    final request = _request('initialize', {
      'protocolVersion': protocolVersion,
      'capabilities': <String, Object?>{},
      'clientInfo': {
        'name': 'Stars',
        'title': 'Stars MCP Host',
        'version': '1.0.0',
      },
    });
    McpTransportResponse? response;
    String? negotiatedVersion;
    try {
      response = await _transportFor(server).send(
        server: server,
        credential: credential,
        cancellationToken: cancellationToken,
        payload: request,
        protocolVersion: null,
        sessionId: null,
      );
      final result = _result(response.payload, expectedId: request['id']);
      negotiatedVersion = _requiredString(
        result,
        'protocolVersion',
        code: 'mcp_invalid_response',
      );
      if (negotiatedVersion != protocolVersion) {
        throw McpException(
          'mcp_unsupported_protocol',
          message: 'Unsupported MCP protocol version: $negotiatedVersion.',
        );
      }
      final serverInfo = _requiredMap(
        result,
        'serverInfo',
        code: 'mcp_invalid_response',
      );
      final capabilities = _requiredMap(
        result,
        'capabilities',
        code: 'mcp_invalid_response',
      );
      final toolCapabilities = _optionalMap(
        capabilities,
        'tools',
        code: 'mcp_invalid_response',
      );
      final rawListChanged = toolCapabilities?['listChanged'];
      if (rawListChanged != null && rawListChanged is! bool) {
        throw const McpException(
          'mcp_invalid_response',
          message: 'MCP Tool listChanged must be a boolean.',
        );
      }
      final instructions = result['instructions'];
      if (instructions != null && instructions is! String) {
        throw const McpException(
          'mcp_invalid_response',
          message: 'MCP initialization instructions must be a string.',
        );
      }
      final session = _McpSession(
        fingerprint: fingerprint,
        sessionId: response.sessionId,
        protocolVersion: negotiatedVersion,
        serverName: _requiredString(
          serverInfo,
          'name',
          code: 'mcp_invalid_response',
        ),
        serverVersion: _requiredString(
          serverInfo,
          'version',
          code: 'mcp_invalid_response',
        ),
        capabilities: McpServerCapabilities(
          tools: capabilities.containsKey('tools'),
          toolListChanged: rawListChanged == true,
        ),
        instructions: instructions as String? ?? '',
      );
      await _transportFor(server).send(
        server: server,
        credential: credential,
        cancellationToken: cancellationToken,
        payload: const {
          'jsonrpc': '2.0',
          'method': 'notifications/initialized',
        },
        protocolVersion: negotiatedVersion,
        sessionId: session.sessionId,
      );
      if ((_connectionEpochs[server.id] ?? 0) != connectionEpoch) {
        throw const McpException(
          'mcp_connection_superseded',
          message: 'The MCP connection was superseded.',
        );
      }
      _sessions[server.id] = session;
      return session;
    } on Object {
      try {
        await _transportFor(server).disconnect(
          server: server,
          credential: credential,
          protocolVersion: negotiatedVersion,
          sessionId: response?.sessionId,
        );
      } on Object {
        // Initialization errors take precedence over cleanup failures.
      }
      rethrow;
    }
  }

  Future<List<McpToolDescriptor>> _listTools(
    McpServer server,
    _McpSession session,
    AgentCancellationToken cancellationToken,
  ) async {
    if (!session.capabilities.tools) {
      throw const McpException(
        'mcp_tools_not_supported',
        message: 'This MCP server does not advertise Tool support.',
      );
    }
    final tools = <McpToolDescriptor>[];
    final remoteNames = <String>{};
    String? cursor;
    for (var page = 0; page < _maxCatalogPages; page += 1) {
      final request = _request('tools/list', {
        if (cursor != null) 'cursor': cursor,
      });
      final response = await _send(
        server: server,
        session: session,
        cancellationToken: cancellationToken,
        payload: request,
      );
      final result = _result(response.payload, expectedId: request['id']);
      final rawTools = result['tools'];
      if (rawTools is! List) {
        throw const McpException(
          'mcp_invalid_tool_catalog',
          message: 'The MCP Tool catalog is invalid.',
        );
      }
      for (final rawTool in rawTools) {
        if (rawTool is! Map) {
          throw const McpException(
            'mcp_invalid_tool_catalog',
            message: 'The MCP Tool catalog contains an invalid entry.',
          );
        }
        final tool = _parseTool(
          server,
          _objectMap(rawTool, code: 'mcp_invalid_tool_catalog'),
        );
        if (!remoteNames.add(tool.remoteName)) {
          throw const McpException(
            'mcp_duplicate_tool_name',
            message: 'The MCP server returned duplicate Tool names.',
          );
        }
        tools.add(tool);
        if (tools.length > _maxCatalogTools) {
          throw const McpException(
            'mcp_tool_catalog_too_large',
            message: 'The MCP Tool catalog exceeds the safety limit.',
          );
        }
      }
      final nextCursor = result['nextCursor'];
      if (nextCursor == null) {
        return List<McpToolDescriptor>.unmodifiable(tools);
      }
      if (nextCursor is! String || nextCursor.isEmpty) {
        throw const McpException(
          'mcp_invalid_tool_catalog',
          message: 'The MCP Tool catalog returned an invalid cursor.',
        );
      }
      cursor = nextCursor;
    }
    throw const McpException(
      'mcp_tool_catalog_too_large',
      message: 'The MCP Tool catalog has too many pages.',
    );
  }

  Future<McpTransportResponse> _send({
    required McpServer server,
    required _McpSession session,
    required AgentCancellationToken cancellationToken,
    required Map<String, Object?> payload,
  }) async {
    return _transportFor(server).send(
      server: server,
      credential: await _credentialStore.read(server.id),
      cancellationToken: cancellationToken,
      payload: payload,
      protocolVersion: session.protocolVersion,
      sessionId: session.sessionId,
    );
  }

  Future<void> _discardSession(McpServer server) async {
    final session = _sessions.remove(server.id);
    if (session == null) return;
    try {
      await _transportFor(server).disconnect(
        server: server,
        credential: await _credentialStore.read(server.id),
        protocolVersion: session.protocolVersion,
        sessionId: session.sessionId,
      );
    } on Object {
      // The local session is gone; remote cleanup is best effort.
    }
  }

  McpTransport _transportFor(McpServer server) =>
      _transports[server.transport.type]!;

  Map<String, Object?> _request(String method, Map<String, Object?> params) {
    return {
      'jsonrpc': '2.0',
      'id': _nextRequestId++,
      'method': method,
      'params': params,
    };
  }

  Map<String, Object?> _result(
    Map<String, Object?>? payload, {
    required Object? expectedId,
  }) {
    if (payload == null ||
        payload['jsonrpc'] != '2.0' ||
        payload['id'] != expectedId) {
      throw const McpException(
        'mcp_invalid_response',
        message: 'The MCP server returned an invalid JSON-RPC response.',
      );
    }
    final hasResult = payload.containsKey('result');
    final hasError = payload.containsKey('error');
    if (hasResult == hasError) {
      throw const McpException(
        'mcp_invalid_response',
        message: 'The MCP response must contain either result or error.',
      );
    }
    if (hasError) {
      final error = _requiredMap(
        payload,
        'error',
        code: 'mcp_invalid_response',
      );
      if (error['code'] is! int || error['message'] is! String) {
        throw const McpException(
          'mcp_invalid_response',
          message: 'The MCP JSON-RPC error object is invalid.',
        );
      }
      throw McpException(
        'mcp_rpc_error',
        message: 'MCP JSON-RPC request failed with code ${error['code']}.',
      );
    }
    return _requiredMap(payload, 'result', code: 'mcp_invalid_response');
  }

  McpToolDescriptor _parseTool(McpServer server, Map<String, Object?> source) {
    final remoteName =
        _requiredString(
          source,
          'name',
          code: 'mcp_invalid_tool_catalog',
        ).trim();
    if (remoteName.isEmpty) {
      throw const McpException(
        'mcp_invalid_tool_catalog',
        message: 'An MCP Tool name cannot be empty.',
      );
    }
    final inputSchema = _requiredMap(
      source,
      'inputSchema',
      code: 'mcp_invalid_tool_catalog',
    );
    if (inputSchema['type'] != 'object') {
      throw const McpException(
        'mcp_invalid_tool_catalog',
        message: 'An MCP Tool input schema must describe an object.',
      );
    }
    final outputSchema = _optionalMap(
      source,
      'outputSchema',
      code: 'mcp_invalid_tool_catalog',
    );
    if (outputSchema != null && outputSchema['type'] != 'object') {
      throw const McpException(
        'mcp_invalid_tool_catalog',
        message: 'An MCP Tool output schema must describe an object.',
      );
    }
    final annotationValues =
        _optionalMap(source, 'annotations', code: 'mcp_invalid_tool_catalog') ??
        const <String, Object?>{};
    final execution = _optionalMap(
      source,
      'execution',
      code: 'mcp_invalid_tool_catalog',
    );
    final rawTaskSupport = execution?['taskSupport'];
    final taskSupport = switch (rawTaskSupport) {
      null || 'forbidden' => McpToolTaskSupport.forbidden,
      'optional' => McpToolTaskSupport.optional,
      'required' => McpToolTaskSupport.required,
      _ =>
        throw const McpException(
          'mcp_invalid_tool_catalog',
          message: 'An MCP Tool has invalid task execution metadata.',
        ),
    };
    final explicitTitle = source['title'];
    final annotationTitle = annotationValues['title'];
    if (explicitTitle != null && explicitTitle is! String ||
        annotationTitle != null && annotationTitle is! String) {
      throw const McpException(
        'mcp_invalid_tool_catalog',
        message: 'An MCP Tool title must be a string.',
      );
    }
    final description = source['description'];
    if (description != null && description is! String) {
      throw const McpException(
        'mcp_invalid_tool_catalog',
        message: 'An MCP Tool description must be a string.',
      );
    }
    final title = switch ((explicitTitle as String?)?.trim()) {
      final value? when value.isNotEmpty => value,
      _ => switch ((annotationTitle as String?)?.trim()) {
        final value? when value.isNotEmpty => value,
        _ => remoteName,
      },
    };
    final McpToolAnnotations annotations;
    try {
      annotations = McpToolAnnotations.fromMap(annotationValues);
    } on FormatException {
      throw const McpException(
        'mcp_invalid_tool_catalog',
        message: 'An MCP Tool annotation must be a boolean.',
      );
    }
    return McpToolDescriptor(
      serverId: server.id,
      namespace: server.namespace,
      remoteName: remoteName,
      title: title,
      description: description as String? ?? '',
      inputSchema: inputSchema,
      outputSchema: outputSchema,
      annotations: annotations,
      taskSupport: taskSupport,
      updatedAt: _now(),
    );
  }

  String _formatContent(List<Object?> rawContent) {
    final parts = <String>[];
    for (final rawPart in rawContent) {
      if (rawPart is! Map) {
        throw const McpException(
          'mcp_invalid_tool_result',
          message: 'The MCP Tool returned an invalid content block.',
        );
      }
      final part = _objectMap(rawPart, code: 'mcp_invalid_tool_result');
      switch (part['type']) {
        case 'text':
          final text = _requiredString(
            part,
            'text',
            code: 'mcp_invalid_tool_result',
          );
          if (text.isNotEmpty) parts.add(text);
        case 'resource_link':
          final resourceName = _requiredString(
            part,
            'name',
            code: 'mcp_invalid_tool_result',
          );
          final uri = _requiredString(
            part,
            'uri',
            code: 'mcp_invalid_tool_result',
          );
          parts.add(
            '[Resource${resourceName.isEmpty ? '' : ': $resourceName'}] $uri',
          );
        case 'resource':
          final resource = _requiredMap(
            part,
            'resource',
            code: 'mcp_invalid_tool_result',
          );
          final uri = _requiredString(
            resource,
            'uri',
            code: 'mcp_invalid_tool_result',
          );
          final resourceText = resource['text'];
          final resourceBlob = resource['blob'];
          if ((resourceText == null) == (resourceBlob == null) ||
              resourceText != null && resourceText is! String ||
              resourceBlob != null && resourceBlob is! String) {
            throw const McpException(
              'mcp_invalid_tool_result',
              message: 'An embedded MCP resource is invalid.',
            );
          }
          parts.add(
            resourceText is String && resourceText.isNotEmpty
                ? resourceText
                : '[Resource] $uri',
          );
        case 'image':
          _requiredString(part, 'data', code: 'mcp_invalid_tool_result');
          parts.add(
            '[Image content: ${_requiredString(part, 'mimeType', code: 'mcp_invalid_tool_result')}]',
          );
        case 'audio':
          _requiredString(part, 'data', code: 'mcp_invalid_tool_result');
          parts.add(
            '[Audio content: ${_requiredString(part, 'mimeType', code: 'mcp_invalid_tool_result')}]',
          );
        default:
          throw const McpException(
            'mcp_invalid_tool_result',
            message: 'The MCP Tool returned an unsupported content block.',
          );
      }
    }
    return parts.join('\n\n');
  }

  String _fingerprint(McpServer server) {
    return jsonEncode({
      'namespace': server.namespace,
      'transport': switch (server.transport) {
        McpStreamableHttpServerTransport(:final endpoint, :final authType) => {
          'type': McpTransportType.streamableHttp.name,
          'endpoint': endpoint.toString(),
          'authType': authType.name,
        },
        McpStdioServerTransport(:final command, :final arguments) => {
          'type': McpTransportType.stdio.name,
          'command': command.trim(),
          'arguments': arguments,
        },
      },
    });
  }
}

final class _McpSession {
  const _McpSession({
    required this.fingerprint,
    required this.sessionId,
    required this.protocolVersion,
    required this.serverName,
    required this.serverVersion,
    required this.capabilities,
    required this.instructions,
  });

  final String fingerprint;
  final String? sessionId;
  final String protocolVersion;
  final String serverName;
  final String serverVersion;
  final McpServerCapabilities capabilities;
  final String instructions;
}

final class _PendingInitialization {
  const _PendingInitialization(this.fingerprint, this.future);

  final String fingerprint;
  final Future<_McpSession> future;
}

Map<McpTransportType, McpTransport> _indexTransports(
  Iterable<McpTransport> transports,
) {
  final indexed = <McpTransportType, McpTransport>{};
  for (final transport in transports) {
    if (indexed.containsKey(transport.type)) {
      throw ArgumentError('MCP transport types must be unique.');
    }
    indexed[transport.type] = transport;
  }
  final missing = McpTransportType.values.where(
    (type) => !indexed.containsKey(type),
  );
  if (missing.isNotEmpty) {
    throw ArgumentError(
      'Missing MCP transports: ${missing.map((e) => e.name).join(', ')}.',
    );
  }
  return Map<McpTransportType, McpTransport>.unmodifiable(indexed);
}

Map<String, Object?> _objectMap(Object value, {required String code}) {
  if (value is! Map || value.keys.any((key) => key is! String)) {
    throw McpException(code, message: 'An MCP object contains invalid keys.');
  }
  return Map<String, Object?>.unmodifiable(value.cast<String, Object?>());
}

Map<String, Object?> _requiredMap(
  Map<String, Object?> source,
  String key, {
  required String code,
}) {
  final value = source[key];
  if (value is! Map) {
    throw McpException(code, message: 'MCP field "$key" must be an object.');
  }
  return _objectMap(value, code: code);
}

Map<String, Object?>? _optionalMap(
  Map<String, Object?> source,
  String key, {
  required String code,
}) {
  if (!source.containsKey(key)) return null;
  return _requiredMap(source, key, code: code);
}

String _requiredString(
  Map<String, Object?> source,
  String key, {
  required String code,
}) {
  final value = source[key];
  if (value is String) return value;
  throw McpException(code, message: 'MCP field "$key" must be a string.');
}
