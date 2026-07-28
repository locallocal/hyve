import 'package:stars/data/services/mcp/mcp_tool_adapter.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/mcp_client.dart';
import 'package:stars/domain/repositories/mcp_server_repository.dart';

final class McpCatalogService {
  McpCatalogService({
    required McpServerRepository repository,
    required McpClient client,
    required DynamicToolRegistry toolRegistry,
  }) : _repository = repository,
       _client = client,
       _toolRegistry = toolRegistry;

  final McpServerRepository _repository;
  final McpClient _client;
  final DynamicToolRegistry _toolRegistry;

  Future<void> hydrateFromCache() async {
    final servers = await _repository.getServers(forceRefresh: true);
    final tools = <ExecutableTool>[];
    for (final server in servers) {
      if (!server.enabled) continue;
      for (final descriptor in await _repository.getTools(
        server.id,
        enabledOnly: true,
      )) {
        if (!descriptor.hasCompatibleSchema) continue;
        tools.add(
          McpToolAdapter(
            server: server,
            descriptor: descriptor,
            client: _client,
            availabilityCheck:
                () => _isToolStillEnabled(server.id, descriptor.remoteName),
          ),
        );
      }
    }
    _toolRegistry.replaceDynamic(tools);
  }

  Future<McpServer> refreshServer(
    String serverId, {
    AgentCancellationToken? cancellationToken,
  }) async {
    final server = await _repository.getServer(serverId);
    if (server == null) {
      throw const McpException(
        'mcp_server_not_found',
        message: 'The MCP server no longer exists.',
      );
    }
    await _repository.saveServer(
      server.copyWith(
        status: McpConnectionStatus.connecting,
        clearLastError: true,
        updatedAt: DateTime.now(),
      ),
    );
    try {
      // A manual refresh also rotates credentials and negotiated sessions.
      await _client.disconnect(server);
      final initialized = await _client.initialize(
        server,
        cancellationToken: cancellationToken,
      );
      final tools = await _client.listTools(
        server,
        cancellationToken: cancellationToken,
      );
      await _repository.replaceTools(server.id, tools);
      final connected = server.copyWith(
        protocolVersion: initialized.protocolVersion,
        remoteServerName: initialized.serverName,
        remoteServerVersion: initialized.serverVersion,
        capabilities: initialized.capabilities,
        status: McpConnectionStatus.connected,
        clearLastError: true,
        lastConnectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.saveServer(connected);
      await hydrateFromCache();
      return connected;
    } on McpException catch (error) {
      final failed = server.copyWith(
        status:
            error.code == 'mcp_authorization_required'
                ? McpConnectionStatus.authorizationRequired
                : McpConnectionStatus.error,
        lastErrorCode: error.code,
        updatedAt: DateTime.now(),
      );
      await _repository.saveServer(failed);
      await hydrateFromCache();
      rethrow;
    } on Object {
      await _repository.saveServer(
        server.copyWith(
          status: McpConnectionStatus.error,
          lastErrorCode: 'mcp_catalog_refresh_failed',
          updatedAt: DateTime.now(),
        ),
      );
      await hydrateFromCache();
      rethrow;
    }
  }

  Future<void> disconnect(McpServer server) async {
    await _client.disconnect(server);
    await _repository.saveServer(
      server.copyWith(
        status: McpConnectionStatus.disconnected,
        clearLastError: true,
        updatedAt: DateTime.now(),
      ),
    );
    await hydrateFromCache();
  }

  Future<bool> _isToolStillEnabled(String serverId, String remoteName) async {
    final server = await _repository.getServer(serverId);
    if (server == null || !server.enabled) return false;
    final tools = await _repository.getTools(serverId, enabledOnly: true);
    return tools.any((tool) => tool.remoteName == remoteName);
  }
}
