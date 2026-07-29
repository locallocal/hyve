import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stars/data/services/mcp/mcp_endpoint_policy.dart';
import 'package:stars/domain/models/models.dart';

typedef McpHttpClientFactory = http.Client Function();

final class McpTransportResponse {
  const McpTransportResponse({
    required this.payload,
    this.sessionId,
    required this.statusCode,
  });

  final Map<String, Object?>? payload;
  final String? sessionId;
  final int statusCode;
}

final class McpHttpTransport {
  McpHttpTransport({
    required McpEndpointPolicy endpointPolicy,
    McpHttpClientFactory? clientFactory,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _endpointPolicy = endpointPolicy,
       _clientFactory = clientFactory ?? http.Client.new;

  final McpEndpointPolicy _endpointPolicy;
  final McpHttpClientFactory _clientFactory;
  final Duration requestTimeout;

  Future<McpTransportResponse> post({
    required McpServer server,
    required Map<String, Object?> payload,
    required McpCredential? credential,
    required AgentCancellationToken cancellationToken,
    String? sessionId,
  }) async {
    await _endpointPolicy.validate(server.endpoint);
    cancellationToken.throwIfCancelled();
    final client = _clientFactory();
    try {
      final request =
          http.Request('POST', server.endpoint)
            ..followRedirects = false
            ..headers.addAll(
              _headers(
                server: server,
                credential: credential,
                sessionId: sessionId,
              ),
            )
            ..body = jsonEncode(payload);
      final response = await _send(client, request, cancellationToken);
      return _parseResponse(response, expectedId: payload['id']);
    } finally {
      client.close();
    }
  }

  Future<void> deleteSession({
    required McpServer server,
    required McpCredential? credential,
    required String sessionId,
  }) async {
    await _endpointPolicy.validate(server.endpoint);
    final client = _clientFactory();
    try {
      final request =
          http.Request('DELETE', server.endpoint)
            ..followRedirects = false
            ..headers.addAll(
              _headers(
                server: server,
                credential: credential,
                sessionId: sessionId,
              ),
            );
      final response = await client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(requestTimeout);
      if (response.isRedirect) {
        throw const McpException(
          'mcp_redirect_blocked',
          message: 'MCP endpoint redirects are not allowed.',
        );
      }
      if (response.statusCode != 405 &&
          response.statusCode != 404 &&
          (response.statusCode < 200 || response.statusCode >= 300)) {
        throw McpException(
          'mcp_http_error',
          message: 'MCP session termination failed.',
          statusCode: response.statusCode,
        );
      }
    } finally {
      client.close();
    }
  }

  Map<String, String> _headers({
    required McpServer server,
    required McpCredential? credential,
    required String? sessionId,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json, text/event-stream',
      'Content-Type': 'application/json',
      if (sessionId != null && sessionId.isNotEmpty)
        'Mcp-Session-Id': sessionId,
      if (server.protocolVersion.isNotEmpty)
        'MCP-Protocol-Version': server.protocolVersion,
    };
    if (server.authType == McpAuthType.oauthAccessToken) {
      if (credential == null || credential.isExpired) {
        throw const McpException(
          'mcp_authorization_required',
          message: 'A valid MCP access token is required.',
        );
      }
      final token = credential.accessToken.trim();
      if (token.isEmpty) {
        throw const McpException(
          'mcp_authorization_required',
          message: 'A valid MCP access token is required.',
        );
      }
      if (token.contains('\r') || token.contains('\n')) {
        throw const McpException(
          'mcp_invalid_credential',
          message: 'The MCP credential is invalid.',
        );
      }
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> _send(
    http.Client client,
    http.Request request,
    AgentCancellationToken cancellationToken,
  ) {
    final completer = Completer<http.Response>();
    unawaited(
      client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(requestTimeout)
          .then((response) {
            if (!completer.isCompleted) completer.complete(response);
          })
          .catchError((Object error, StackTrace stackTrace) {
            if (completer.isCompleted) return;
            if (error is TimeoutException) {
              completer.completeError(
                const McpException(
                  'mcp_request_timeout',
                  message: 'The MCP request timed out.',
                ),
                stackTrace,
              );
            } else {
              completer.completeError(
                const McpException(
                  'mcp_network_error',
                  message: 'The MCP server could not be reached.',
                ),
                stackTrace,
              );
            }
          }),
    );
    unawaited(
      cancellationToken.whenCancelled.then((_) {
        if (completer.isCompleted) return;
        client.close();
        completer.completeError(const AgentRunCancelledException());
      }),
    );
    return completer.future;
  }

  McpTransportResponse _parseResponse(
    http.Response response, {
    Object? expectedId,
  }) {
    if (response.isRedirect) {
      throw const McpException(
        'mcp_redirect_blocked',
        message: 'MCP endpoint redirects are not allowed.',
      );
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw McpException(
        'mcp_authorization_required',
        message: 'The MCP server requires authorization.',
        statusCode: response.statusCode,
        authorizationMetadataUri: _authorizationMetadataUri(response.headers),
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw McpException(
        'mcp_http_error',
        message: 'The MCP server returned HTTP ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }
    final sessionId = _header(response.headers, 'mcp-session-id');
    if (response.bodyBytes.isEmpty || response.statusCode == 202) {
      return McpTransportResponse(
        payload: null,
        sessionId: sessionId,
        statusCode: response.statusCode,
      );
    }
    final contentType =
        _header(response.headers, 'content-type')?.toLowerCase() ?? '';
    final source = utf8.decode(response.bodyBytes);
    final Object? decoded;
    try {
      decoded =
          contentType.contains('text/event-stream')
              ? _decodeServerSentEvent(source, expectedId: expectedId)
              : jsonDecode(source);
    } on FormatException {
      throw const McpException(
        'mcp_invalid_response',
        message: 'The MCP server returned an invalid response.',
      );
    }
    if (decoded is! Map) {
      throw const McpException(
        'mcp_invalid_response',
        message: 'The MCP response must be a JSON-RPC object.',
      );
    }
    final payload = decoded.map(
      (key, value) => MapEntry(key.toString(), value as Object?),
    );
    if (expectedId != null && payload['id'] != expectedId) {
      throw const McpException(
        'mcp_response_id_mismatch',
        message: 'The MCP response id did not match the request.',
      );
    }
    return McpTransportResponse(
      payload: payload,
      sessionId: sessionId,
      statusCode: response.statusCode,
    );
  }

  Object? _decodeServerSentEvent(String source, {Object? expectedId}) {
    final dataLines = <String>[];
    Object? firstEvent;
    for (final line in const LineSplitter().convert(source)) {
      if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trimLeft());
      } else if (line.isEmpty && dataLines.isNotEmpty) {
        final data = dataLines.join('\n');
        dataLines.clear();
        if (data == '[DONE]') continue;
        final decoded = jsonDecode(data);
        firstEvent ??= decoded;
        if (expectedId == null ||
            (decoded is Map && decoded['id'] == expectedId)) {
          return decoded;
        }
      }
    }
    if (dataLines.isNotEmpty) {
      final decoded = jsonDecode(dataLines.join('\n'));
      firstEvent ??= decoded;
      if (expectedId == null ||
          (decoded is Map && decoded['id'] == expectedId)) {
        return decoded;
      }
    }
    if (firstEvent != null) return firstEvent;
    throw const FormatException('SSE response has no data event.');
  }

  Uri? _authorizationMetadataUri(Map<String, String> headers) {
    final authenticate = _header(headers, 'www-authenticate');
    if (authenticate == null) return null;
    final match = RegExp(
      r'resource_metadata\s*=\s*"([^"]+)"',
      caseSensitive: false,
    ).firstMatch(authenticate);
    return match == null ? null : Uri.tryParse(match.group(1)!);
  }

  String? _header(Map<String, String> headers, String name) {
    final normalized = name.toLowerCase();
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == normalized) return entry.value;
    }
    return null;
  }
}
