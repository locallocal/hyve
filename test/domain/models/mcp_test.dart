import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  test('MCP Tool canonical names are stable and namespace scoped', () {
    expect(
      McpToolDescriptor.canonicalNameFor('github', 'create_issue'),
      'mcp.github.create_issue',
    );
    final first = McpToolDescriptor.canonicalNameFor(
      'docs',
      'search documents/v2',
    );
    final second = McpToolDescriptor.canonicalNameFor(
      'docs',
      'search documents/v2',
    );

    expect(first, second);
    expect(first, startsWith('mcp.docs.search_documents_v2_'));
    expect(first, isNot(contains(' ')));
  });

  test('MCP server rejects invalid capability namespaces', () {
    expect(
      () => McpServer(
        id: 'server-1',
        name: 'Example',
        namespace: 'Not Valid',
        endpoint: Uri.parse('https://example.com/mcp'),
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      throwsArgumentError,
    );
  });

  test('stdio MCP servers require a command and copy their arguments', () {
    final timestamp = DateTime(2026);
    expect(
      () => McpServer(
        id: 'stdio-1',
        name: 'Local',
        namespace: 'local',
        transportType: McpTransportType.stdio,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
      throwsArgumentError,
    );

    final arguments = <String>['-y', 'example-server'];
    final server = McpServer(
      id: 'stdio-1',
      name: 'Local',
      namespace: 'local',
      transportType: McpTransportType.stdio,
      command: 'npx',
      arguments: arguments,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    arguments.add('--mutated');

    expect(server.endpoint, Uri());
    expect(server.arguments, ['-y', 'example-server']);
    expect(() => server.arguments.add('blocked'), throwsUnsupportedError);
  });

  test('MCP Tool compatibility fails closed for unsupported schemas', () {
    final descriptor = McpToolDescriptor(
      serverId: 'server-1',
      namespace: 'example',
      remoteName: 'search',
      title: 'Search',
      description: 'Search.',
      inputSchema: const {
        'type': 'object',
        'properties': {
          'query': {r'$ref': r'#/$defs/query'},
        },
        r'$defs': {
          'query': {'type': 'string'},
        },
      },
      updatedAt: DateTime(2026),
    );

    expect(descriptor.hasCompatibleSchema, isFalse);
  });

  test('Dynamic Tool registry atomically replaces remote Tools', () {
    final fixed = _FakeTool('calculate');
    final registry = DynamicToolRegistry([fixed]);
    registry.replaceDynamic([_FakeTool('mcp.docs.search')]);

    expect(registry.list().map((definition) => definition.name), [
      'calculate',
      'mcp.docs.search',
    ]);
    expect(registry.find('mcp.docs.search'), isNotNull);

    registry.replaceDynamic([_FakeTool('mcp.github.issue')]);
    expect(registry.find('mcp.docs.search'), isNull);
    expect(registry.find('mcp.github.issue'), isNotNull);
    expect(
      () => registry.replaceDynamic([_FakeTool('calculate')]),
      throwsArgumentError,
    );
  });
}

final class _FakeTool implements ExecutableTool {
  _FakeTool(String name)
    : definition = ToolDefinition(
        name: name,
        description: name,
        inputSchema: const {'type': 'object'},
        source: ToolSource.builtIn,
        riskLevel: ToolRiskLevel.readOnly,
        capabilities: const {ToolCapability.compute},
      );

  @override
  final ToolDefinition definition;

  @override
  Future<ToolResult> execute(
    ToolCallRequest call,
    AgentCancellationToken cancellationToken,
  ) async {
    return ToolResult(callId: call.callId, name: call.name, content: 'ok');
  }
}
