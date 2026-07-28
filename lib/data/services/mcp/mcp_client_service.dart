import 'package:stars/data/services/mcp/mcp_http_transport.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/mcp_client.dart';
import 'package:stars/domain/repositories/mcp_credential_store.dart';

final class McpClientService implements McpClient {
  McpClientService({
    required McpHttpTransport transport,
    required McpCredentialStore credentialStore,
  }) : _transport = transport,
       _credentialStore = credentialStore;

  static const String latestProtocolVersion = '2025-11-25';
  static const Set<String> supportedProtocolVersions = {
    '2025-11-25',
    '2025-06-18',
    '2025-03-26',
  };

  final McpHttpTransport _transport;
  final McpCredentialStore _credentialStore;
  final Map<String, _McpSession> _sessions = {};
  int _nextRequestId = 1;

  @override
  Future<McpInitializeResult> initialize(
    McpServer server, {
    AgentCancellationToken? cancellationToken,
  }) async {
    final cancellation = cancellationToken ?? AgentCancellationToken();
    final fingerprint =
        '${server.endpoint}|${server.authType.name}|${server.namespace}';
    final existing = _sessions[server.id];
    if (existing != null && existing.fingerprint == fingerprint) {
      return existing.initializeResult;
    }
    if (existing != null) await disconnect(server);

    final credential = await _credentialStore.read(server.id);
    final response = await _transport.post(
      server: server,
      credential: credential,
      cancellationToken: cancellation,
      payload: _request('initialize', {
        'protocolVersion': latestProtocolVersion,
        'capabilities': <String, Object?>{},
        'clientInfo': {
          'name': 'Stars',
          'title': 'Stars MCP Host',
          'version': '1.0.0',
        },
      }),
    );
    final result = _result(response.payload);
    final protocolVersion = result['protocolVersion']?.toString() ?? '';
    if (!supportedProtocolVersions.contains(protocolVersion)) {
      throw McpException(
        'mcp_unsupported_protocol',
        message: 'Unsupported MCP protocol version: $protocolVersion.',
      );
    }
    final serverInfo = _map(result['serverInfo']);
    final capabilities = _map(result['capabilities']);
    final toolCapabilities = _map(capabilities['tools']);
    final initialized = McpInitializeResult(
      protocolVersion: protocolVersion,
      serverName: serverInfo['name']?.toString() ?? server.name,
      serverVersion: serverInfo['version']?.toString() ?? '',
      capabilities: McpServerCapabilities(
        tools: capabilities.containsKey('tools'),
        toolListChanged: toolCapabilities['listChanged'] == true,
      ),
      instructions: result['instructions']?.toString() ?? '',
    );
    final session = _McpSession(
      fingerprint: fingerprint,
      sessionId: response.sessionId,
      initializeResult: initialized,
    );
    _sessions[server.id] = session;

    try {
      await _transport.post(
        server: server.copyWith(protocolVersion: protocolVersion),
        credential: credential,
        cancellationToken: cancellation,
        sessionId: session.sessionId,
        payload: const {
          'jsonrpc': '2.0',
          'method': 'notifications/initialized',
        },
      );
    } on Object {
      _sessions.remove(server.id);
      rethrow;
    }
    return initialized;
  }

  @override
  Future<List<McpToolDescriptor>> listTools(
    McpServer server, {
    AgentCancellationToken? cancellationToken,
  }) async {
    final cancellation = cancellationToken ?? AgentCancellationToken();
    final initialized = await initialize(
      server,
      cancellationToken: cancellation,
    );
    if (!initialized.capabilities.tools) {
      throw const McpException(
        'mcp_tools_not_supported',
        message: 'This MCP server does not advertise Tool support.',
      );
    }
    final session = _sessions[server.id]!;
    final credential = await _credentialStore.read(server.id);
    final tools = <McpToolDescriptor>[];
    String? cursor;
    for (var page = 0; page < 100; page += 1) {
      final response = await _transport.post(
        server: server.copyWith(protocolVersion: initialized.protocolVersion),
        credential: credential,
        cancellationToken: cancellation,
        sessionId: session.sessionId,
        payload: _request('tools/list', {
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        }),
      );
      final result = _result(response.payload);
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
        final tool = _parseTool(server, _map(rawTool));
        if (tools.any((item) => item.remoteName == tool.remoteName)) {
          throw McpException(
            'mcp_duplicate_tool_name',
            message: 'The MCP server returned duplicate Tool names.',
          );
        }
        tools.add(tool);
        if (tools.length > 10000) {
          throw const McpException(
            'mcp_tool_catalog_too_large',
            message: 'The MCP Tool catalog exceeds the safety limit.',
          );
        }
      }
      cursor = result['nextCursor']?.toString();
      if (cursor == null || cursor.isEmpty) break;
    }
    if (cursor != null && cursor.isNotEmpty) {
      throw const McpException(
        'mcp_tool_catalog_too_large',
        message: 'The MCP Tool catalog has too many pages.',
      );
    }
    return List<McpToolDescriptor>.unmodifiable(tools);
  }

  @override
  Future<McpToolCallResult> callTool({
    required McpServer server,
    required String remoteName,
    required Map<String, Object?> arguments,
    required AgentCancellationToken cancellationToken,
  }) async {
    final initialized = await initialize(
      server,
      cancellationToken: cancellationToken,
    );
    final session = _sessions[server.id]!;
    final credential = await _credentialStore.read(server.id);
    final response = await _transport.post(
      server: server.copyWith(protocolVersion: initialized.protocolVersion),
      credential: credential,
      cancellationToken: cancellationToken,
      sessionId: session.sessionId,
      payload: _request('tools/call', {
        'name': remoteName,
        'arguments': arguments,
      }),
    );
    final result = _result(response.payload);
    if (result['content'] is! List &&
        !result.containsKey('structuredContent')) {
      throw const McpException(
        'mcp_invalid_tool_result',
        message: 'The MCP Tool returned an invalid result.',
      );
    }
    return McpToolCallResult(
      content: _formatContent(result['content']),
      structuredContent: result['structuredContent'],
      isError: result['isError'] == true,
    );
  }

  @override
  Future<void> disconnect(McpServer server) async {
    final session = _sessions.remove(server.id);
    if (session?.sessionId == null) return;
    try {
      await _transport.deleteSession(
        server: server.copyWith(
          protocolVersion: session!.initializeResult.protocolVersion,
        ),
        credential: await _credentialStore.read(server.id),
        sessionId: session.sessionId!,
      );
    } on Object {
      // The local session is already gone; remote cleanup is best effort.
    }
  }

  Map<String, Object?> _request(String method, Map<String, Object?> params) {
    return {
      'jsonrpc': '2.0',
      'id': _nextRequestId++,
      'method': method,
      'params': params,
    };
  }

  Map<String, Object?> _result(Map<String, Object?>? payload) {
    if (payload == null) {
      throw const McpException(
        'mcp_invalid_response',
        message: 'The MCP server returned an empty response.',
      );
    }
    final error = _map(payload['error']);
    if (error.isNotEmpty) {
      throw McpException(
        'mcp_rpc_error',
        message: error['message']?.toString() ?? 'MCP JSON-RPC error.',
      );
    }
    final result = _map(payload['result']);
    if (result.isEmpty && payload['result'] is! Map) {
      throw const McpException(
        'mcp_invalid_response',
        message: 'The MCP JSON-RPC result is invalid.',
      );
    }
    return result;
  }

  McpToolDescriptor _parseTool(McpServer server, Map<String, Object?> source) {
    final remoteName = source['name']?.toString().trim() ?? '';
    final inputSchema = _map(source['inputSchema']);
    if (remoteName.isEmpty || inputSchema.isEmpty) {
      throw const McpException(
        'mcp_invalid_tool_catalog',
        message: 'An MCP Tool is missing its name or input schema.',
      );
    }
    final rawOutputSchema = source['outputSchema'];
    return McpToolDescriptor(
      serverId: server.id,
      namespace: server.namespace,
      remoteName: remoteName,
      title: source['title']?.toString() ?? remoteName,
      description: source['description']?.toString() ?? '',
      inputSchema: inputSchema,
      outputSchema: rawOutputSchema is Map ? _map(rawOutputSchema) : null,
      annotations: McpToolAnnotations.fromMap(_map(source['annotations'])),
      updatedAt: DateTime.now(),
    );
  }

  String _formatContent(Object? rawContent) {
    if (rawContent is! List) return '';
    final parts = <String>[];
    for (final rawPart in rawContent) {
      final part = _map(rawPart);
      switch (part['type']) {
        case 'text':
          final text = part['text']?.toString() ?? '';
          if (text.isNotEmpty) parts.add(text);
        case 'resource_link':
          final name = part['name']?.toString() ?? '';
          final uri = part['uri']?.toString() ?? '';
          parts.add('[Resource${name.isEmpty ? '' : ': $name'}] $uri');
        case 'resource':
          final resource = _map(part['resource']);
          final text = resource['text']?.toString() ?? '';
          final uri = resource['uri']?.toString() ?? '';
          parts.add(text.isEmpty ? '[Resource] $uri' : text);
        case 'image':
          parts.add('[Image content: ${part['mimeType'] ?? 'unknown'}]');
        case 'audio':
          parts.add('[Audio content: ${part['mimeType'] ?? 'unknown'}]');
      }
    }
    return parts.join('\n\n');
  }
}

final class _McpSession {
  const _McpSession({
    required this.fingerprint,
    required this.sessionId,
    required this.initializeResult,
  });

  final String fingerprint;
  final String? sessionId;
  final McpInitializeResult initializeResult;
}

Map<String, Object?> _map(Object? value) {
  if (value is! Map) return const {};
  return value.map(
    (key, mapValue) => MapEntry(key.toString(), mapValue as Object?),
  );
}
