import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:hyve/data/services/mcp/mcp_endpoint_policy.dart';
import 'package:hyve/data/services/mcp/mcp_transport.dart';
import 'package:hyve/domain/models/models.dart';

typedef McpHttpClientFactory = http.Client Function();

final class McpHttpTransport implements McpTransport {
  McpHttpTransport({
    required McpEndpointPolicy endpointPolicy,
    McpHttpClientFactory? clientFactory,
    this.requestTimeout = const Duration(seconds: 30),
    this.maxResponseBytes = 8 * 1024 * 1024,
  }) : _endpointPolicy = endpointPolicy,
       _clientFactory = clientFactory,
       assert(maxResponseBytes > 0);

  final McpEndpointPolicy _endpointPolicy;
  final McpHttpClientFactory? _clientFactory;
  final Duration requestTimeout;
  final int maxResponseBytes;

  @override
  McpTransportType get type => McpTransportType.streamableHttp;

  @override
  Future<McpTransportResponse> send({
    required McpServer server,
    required Map<String, Object?> payload,
    required McpCredential? credential,
    required AgentCancellationToken cancellationToken,
    required String? protocolVersion,
    String? sessionId,
  }) async {
    final transport = _configuration(server);
    final addresses = await _endpointPolicy.validate(transport.endpoint);
    cancellationToken.throwIfCancelled();
    final client =
        _clientFactory?.call() ?? _pinnedClient(transport.endpoint, addresses);
    try {
      final request =
          http.Request('POST', transport.endpoint)
            ..followRedirects = false
            ..headers.addAll(
              _headers(
                transport: transport,
                credential: credential,
                protocolVersion: protocolVersion,
                sessionId: sessionId,
              ),
            )
            ..body = jsonEncode(payload);
      final response = await _send(client, request, cancellationToken);
      return _parseResponse(
        response,
        expectedId: payload['id'],
        sentSessionId: sessionId,
      );
    } finally {
      client.close();
    }
  }

  @override
  Future<void> disconnect({
    required McpServer server,
    required McpCredential? credential,
    required String? protocolVersion,
    required String? sessionId,
  }) async {
    if (sessionId == null) return;
    final transport = _configuration(server);
    final addresses = await _endpointPolicy.validate(transport.endpoint);
    final client =
        _clientFactory?.call() ?? _pinnedClient(transport.endpoint, addresses);
    try {
      final request =
          http.Request('DELETE', transport.endpoint)
            ..followRedirects = false
            ..headers.addAll(
              _headers(
                transport: transport,
                credential: credential,
                protocolVersion: protocolVersion,
                sessionId: sessionId,
              ),
            );
      final response = await client
          .send(request)
          .then(_readResponse)
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
    required McpStreamableHttpServerTransport transport,
    required McpCredential? credential,
    required String? protocolVersion,
    required String? sessionId,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json, text/event-stream',
      'Content-Type': 'application/json',
      if (sessionId != null && sessionId.isNotEmpty)
        'Mcp-Session-Id': sessionId,
      if (protocolVersion != null) 'MCP-Protocol-Version': protocolVersion,
    };
    if (transport.authType == McpAuthType.oauthAccessToken) {
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
          .then(_readResponse)
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
            } else if (error is McpException) {
              completer.completeError(error, stackTrace);
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
    required String? sentSessionId,
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
    if (response.statusCode == 404 && sentSessionId != null) {
      throw const McpException(
        'mcp_session_expired',
        message: 'The MCP session expired.',
        statusCode: 404,
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
    if (sessionId != null && !_isValidSessionId(sessionId)) {
      throw const McpException(
        'mcp_invalid_response',
        message: 'The MCP server returned an invalid session id.',
      );
    }
    if (response.statusCode == 202) {
      if (expectedId != null || response.bodyBytes.isNotEmpty) {
        throw const McpException(
          'mcp_invalid_response',
          message: 'The MCP server returned an invalid accepted response.',
        );
      }
      return McpTransportResponse(payload: null, sessionId: sessionId);
    }
    if (response.bodyBytes.isEmpty) {
      return McpTransportResponse(payload: null, sessionId: sessionId);
    }
    final contentType =
        _header(response.headers, 'content-type')?.toLowerCase() ?? '';
    final Object? decoded;
    try {
      final source = utf8.decode(response.bodyBytes);
      if (contentType.contains('text/event-stream')) {
        decoded = _decodeServerSentEvent(source, expectedId: expectedId);
      } else if (contentType.contains('application/json')) {
        decoded = jsonDecode(source);
      } else {
        throw const FormatException('Unsupported MCP response media type.');
      }
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
    if (decoded.keys.any((key) => key is! String)) {
      throw const McpException(
        'mcp_invalid_response',
        message: 'The MCP response contains an invalid object key.',
      );
    }
    final payload = decoded.cast<String, Object?>();
    if (expectedId != null && payload['id'] != expectedId) {
      throw const McpException(
        'mcp_response_id_mismatch',
        message: 'The MCP response id did not match the request.',
      );
    }
    return McpTransportResponse(payload: payload, sessionId: sessionId);
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
        if (data.isEmpty) continue;
        final decoded = jsonDecode(data);
        if (expectedId == null ||
            (decoded is Map && decoded['id'] == expectedId)) {
          return decoded;
        }
        firstEvent ??= decoded;
      }
    }
    if (dataLines.isNotEmpty) {
      final data = dataLines.join('\n');
      if (data.isNotEmpty) {
        final decoded = jsonDecode(data);
        if (expectedId == null ||
            (decoded is Map && decoded['id'] == expectedId)) {
          return decoded;
        }
        firstEvent ??= decoded;
      }
    }
    if (expectedId == null && firstEvent != null) return firstEvent;
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

  McpStreamableHttpServerTransport _configuration(McpServer server) {
    final transport = server.transport;
    if (transport is McpStreamableHttpServerTransport) return transport;
    throw ArgumentError.value(
      transport,
      'server',
      'An HTTP MCP transport requires Streamable HTTP configuration.',
    );
  }

  bool _isValidSessionId(String value) =>
      value.isNotEmpty &&
      value.codeUnits.every((unit) => unit >= 0x21 && unit <= 0x7e);

  Future<http.Response> _readResponse(http.StreamedResponse streamed) async {
    final bytes = BytesBuilder(copy: false);
    var length = 0;
    await for (final chunk in streamed.stream) {
      length += chunk.length;
      if (length > maxResponseBytes) {
        throw const McpException(
          'mcp_response_too_large',
          message: 'The MCP response exceeds the safety limit.',
        );
      }
      bytes.add(chunk);
    }
    return http.Response.bytes(
      bytes.takeBytes(),
      streamed.statusCode,
      request: streamed.request,
      headers: streamed.headers,
      isRedirect: streamed.isRedirect,
      persistentConnection: streamed.persistentConnection,
      reasonPhrase: streamed.reasonPhrase,
    );
  }

  http.Client _pinnedClient(Uri endpoint, List<InternetAddress> addresses) {
    final address = addresses.first;
    final ioClient = HttpClient();
    ioClient.connectionTimeout = requestTimeout;
    ioClient.findProxy = (_) => 'DIRECT';
    ioClient.connectionFactory = (
      Uri uri,
      String? proxyHost,
      int? proxyPort,
    ) async {
      if (proxyHost != null ||
          proxyPort != null ||
          uri.host.toLowerCase() != endpoint.host.toLowerCase()) {
        throw const McpException(
          'mcp_endpoint_changed',
          message: 'The MCP connection target changed unexpectedly.',
        );
      }
      final connection = await Socket.startConnect(address, uri.port);
      final secureSocket = connection.socket.then(
        (socket) => SecureSocket.secure(
          socket,
          host: uri.host,
          supportedProtocols: const ['http/1.1'],
        ),
      );
      return ConnectionTask.fromSocket(secureSocket, connection.cancel);
    };
    return IOClient(ioClient);
  }
}
