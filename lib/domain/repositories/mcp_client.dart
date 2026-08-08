import 'package:stars/domain/models/models.dart';

abstract interface class McpClient {
  Future<McpServerCatalog> discoverTools(
    McpServer server, {
    AgentCancellationToken? cancellationToken,
  });

  Future<McpToolCallResult> callTool({
    required McpServer server,
    required String remoteName,
    required Map<String, Object?> arguments,
    required AgentCancellationToken cancellationToken,
  });

  Future<void> disconnect(McpServer server);
}

abstract interface class McpStdioProcessInfoSource {
  McpStdioProcessInfo? getStdioProcessInfo(String serverId);
}
