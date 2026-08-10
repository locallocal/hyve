import 'package:stars/domain/models/models.dart';

String mcpConnectionSummary(McpServer server) {
  return switch (server.transport) {
    McpStreamableHttpServerTransport(:final endpoint) => endpoint.toString(),
    McpStdioServerTransport(:final command, :final arguments) => [
      command,
      ...arguments,
    ].where((part) => part.isNotEmpty).join(' '),
  };
}

List<McpServer> filterMcpServers(
  List<McpServer> servers,
  String query, {
  required List<McpToolDescriptor> Function(String serverId) toolsForServer,
}) {
  final terms = _searchTerms(query);
  if (terms.isEmpty) return servers;

  return servers
      .where((server) {
        final searchableText =
            [
              server.id,
              server.name,
              mcpConnectionSummary(server),
              server.transport.type.name,
              server.status.name,
              server.remoteServerName,
              server.remoteServerVersion,
              for (final tool in toolsForServer(server.id)) ...[
                tool.remoteName,
                tool.title,
                tool.description,
                tool.canonicalName,
              ],
            ].join('\n').toLowerCase();
        return terms.every(searchableText.contains);
      })
      .toList(growable: false);
}

/// Filters MCP Tools with the same multi-term matching used across details.
List<McpToolDescriptor> filterMcpTools(
  List<McpToolDescriptor> tools,
  String query,
) {
  final terms = _searchTerms(query);
  if (terms.isEmpty) return tools;

  return tools
      .where((tool) {
        final searchableText =
            [
              tool.title,
              tool.remoteName,
              tool.canonicalName,
              tool.description,
            ].join('\n').toLowerCase();
        return terms.every(searchableText.contains);
      })
      .toList(growable: false);
}

List<String> _searchTerms(String query) => query
    .trim()
    .toLowerCase()
    .split(RegExp(r'\s+'))
    .where((term) => term.isNotEmpty)
    .toList(growable: false);
