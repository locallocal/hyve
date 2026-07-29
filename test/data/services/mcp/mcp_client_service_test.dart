import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stars/data/services/mcp/mcp_client_service.dart';
import 'package:stars/data/services/mcp/mcp_endpoint_policy.dart';
import 'package:stars/data/services/mcp/mcp_http_transport.dart';
import 'package:stars/data/services/mcp/mcp_stdio_transport.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/mcp_credential_store.dart';

void main() {
  test(
    'negotiates a session, paginates Tool discovery, and calls a Tool',
    () async {
      final requests = <http.Request>[];
      Future<http.Response> handler(http.Request request) async {
        requests.add(request);
        final payload =
            request.body.isEmpty
                ? const <String, Object?>{}
                : (jsonDecode(request.body) as Map<String, dynamic>);
        switch (payload['method']) {
          case 'initialize':
            return http.Response(
              jsonEncode({
                'jsonrpc': '2.0',
                'id': payload['id'],
                'result': {
                  'protocolVersion': '2025-11-25',
                  'capabilities': {
                    'tools': {'listChanged': true},
                  },
                  'serverInfo': {'name': 'Example MCP', 'version': '2.1.0'},
                },
              }),
              200,
              headers: {
                'content-type': 'application/json',
                'mcp-session-id': 'session-123',
              },
            );
          case 'notifications/initialized':
            return http.Response('', 202);
          case 'tools/list':
            final params = payload['params'] as Map<String, dynamic>;
            final secondPage = params['cursor'] == 'page-2';
            return http.Response(
              jsonEncode({
                'jsonrpc': '2.0',
                'id': payload['id'],
                'result': {
                  'tools': [
                    {
                      'name': secondPage ? 'create_note' : 'search_notes',
                      'title': secondPage ? 'Create note' : 'Search notes',
                      'description': 'Example Tool',
                      'inputSchema': {
                        'type': 'object',
                        'properties': {
                          'query': {'type': 'string'},
                        },
                      },
                      'annotations': {
                        'readOnlyHint': !secondPage,
                        'destructiveHint': secondPage,
                      },
                    },
                  ],
                  if (!secondPage) 'nextCursor': 'page-2',
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          case 'tools/call':
            return http.Response(
              'event: message\n'
              'data: ${jsonEncode({
                'jsonrpc': '2.0',
                'method': 'notifications/progress',
                'params': {'progress': 0.5},
              })}\n\n'
              'event: message\n'
              'data: ${jsonEncode({
                'jsonrpc': '2.0',
                'id': payload['id'],
                'result': {
                  'content': [
                    {'type': 'text', 'text': 'Found 2 notes'},
                    {'type': 'image', 'mimeType': 'image/png', 'data': 'not-forwarded'},
                  ],
                  'structuredContent': {'count': 2},
                },
              })}\n\n',
              200,
              headers: {'content-type': 'text/event-stream'},
            );
        }
        return http.Response('not found', 404);
      }

      final credentials =
          _MemoryCredentialStore()
            ..value = const McpCredential(accessToken: 'secret-token');
      final client = McpClientService(
        transport: McpHttpTransport(
          endpointPolicy: McpEndpointPolicy(
            resolver: (_) async => [InternetAddress('8.8.8.8')],
          ),
          clientFactory: () => MockClient(handler),
        ),
        credentialStore: credentials,
      );
      final server = _server();

      final tools = await client.listTools(server);

      expect(tools.map((tool) => tool.remoteName), [
        'search_notes',
        'create_note',
      ]);
      expect(tools.first.annotations.readOnlyHint, isTrue);
      expect(tools.last.annotations.destructiveHint, isTrue);
      expect(
        requests
            .skip(1)
            .every(
              (request) => request.headers['Mcp-Session-Id'] == 'session-123',
            ),
        isTrue,
      );
      expect(
        requests.every(
          (request) =>
              request.headers['Authorization'] == 'Bearer secret-token',
        ),
        isTrue,
      );

      final result = await client.callTool(
        server: server,
        remoteName: 'search_notes',
        arguments: const {'query': 'release'},
        cancellationToken: AgentCancellationToken(),
      );

      expect(result.content, contains('Found 2 notes'));
      expect(result.content, contains('[Image content: image/png]'));
      expect(result.content, isNot(contains('not-forwarded')));
      expect(result.structuredContent, {'count': 2});
      expect(requests.last.headers['MCP-Protocol-Version'], '2025-11-25');
    },
  );

  test('surfaces OAuth metadata without including credential values', () async {
    final credentials =
        _MemoryCredentialStore()
          ..value = const McpCredential(accessToken: 'do-not-leak');
    final client = McpClientService(
      transport: McpHttpTransport(
        endpointPolicy: McpEndpointPolicy(
          resolver: (_) async => [InternetAddress('8.8.8.8')],
        ),
        clientFactory:
            () => MockClient(
              (_) async => http.Response(
                '',
                401,
                headers: {
                  'www-authenticate':
                      'Bearer resource_metadata="https://auth.example.com/.well-known/oauth-protected-resource"',
                },
              ),
            ),
      ),
      credentialStore: credentials,
    );

    Object? caught;
    try {
      await client.initialize(_server());
    } on Object catch (error) {
      caught = error;
    }

    expect(caught, isA<McpException>());
    final error = caught! as McpException;
    expect(error.code, 'mcp_authorization_required');
    expect(
      error.authorizationMetadataUri,
      Uri.parse(
        'https://auth.example.com/.well-known/oauth-protected-resource',
      ),
    );
    expect(error.toString(), isNot(contains('do-not-leak')));
  });

  test(
    'initializes, calls, and disconnects a local stdio MCP process',
    () async {
      final credentials =
          _MemoryCredentialStore()
            ..value = const McpCredential(
              environment: {'STARS_MCP_TEST_VALUE': 'secure-environment'},
            );
      final client = McpClientService(
        transport: McpHttpTransport(
          endpointPolicy: McpEndpointPolicy(
            resolver: (_) async => [InternetAddress('8.8.8.8')],
          ),
        ),
        stdioTransport: McpStdioTransport(
          requestTimeout: const Duration(seconds: 10),
        ),
        credentialStore: credentials,
      );
      final timestamp = DateTime(2026, 7, 30);
      final server = McpServer(
        id: 'stdio-server',
        name: 'Fixture',
        namespace: 'fixture',
        transportType: McpTransportType.stdio,
        command: 'dart',
        arguments: const [
          'test/fixtures/mcp_stdio_server.dart',
          'fixture-argument',
        ],
        createdAt: timestamp,
        updatedAt: timestamp,
      );
      addTearDown(() => client.disconnect(server));

      final tools = await client.listTools(server);
      final result = await client.callTool(
        server: server,
        remoteName: 'echo',
        arguments: const {'message': 'hello'},
        cancellationToken: AgentCancellationToken(),
      );

      expect(tools.single.remoteName, 'echo');
      expect(result.content, 'hello|secure-environment|fixture-argument');
      await client.disconnect(server);
    },
  );
}

McpServer _server() {
  final timestamp = DateTime(2026, 7, 29);
  return McpServer(
    id: 'server-1',
    name: 'Example',
    namespace: 'example',
    endpoint: Uri.parse('https://mcp.example.com/mcp'),
    authType: McpAuthType.oauthAccessToken,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

final class _MemoryCredentialStore implements McpCredentialStore {
  McpCredential? value;

  @override
  Future<void> delete(String serverId) async => value = null;

  @override
  Future<McpCredential?> read(String serverId) async => value;

  @override
  Future<void> write(String serverId, McpCredential credential) async {
    value = credential;
  }
}
