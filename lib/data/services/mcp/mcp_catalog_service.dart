import 'package:stars/data/services/mcp/mcp_tool_adapter.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/mcp_client.dart';
import 'package:stars/domain/repositories/mcp_server_repository.dart';

final class McpCatalogService {
  McpCatalogService({
    required McpServerRepository repository,
    required McpClient client,
    required DynamicToolRegistry toolRegistry,
    DateTime Function()? now,
  }) : _repository = repository,
       _client = client,
       _toolRegistry = toolRegistry,
       _now = now ?? DateTime.now;

  final McpServerRepository _repository;
  final McpClient _client;
  final DynamicToolRegistry _toolRegistry;
  final DateTime Function() _now;

  Future<void> hydrateFromCache() async {
    final servers = await _repository.getServers();
    final tools = <ExecutableTool>[];
    for (final server in servers) {
      if (server.status != McpConnectionStatus.connected) {
        continue;
      }
      for (final descriptor in await _repository.getTools(server.id)) {
        if (!descriptor.isSupportedByClient) continue;
        tools.add(
          McpToolAdapter(
            server: server,
            descriptor: descriptor,
            client: _client,
            availabilityCheck: () async {
              final current = await _repository.getServer(server.id);
              if (current?.status != McpConnectionStatus.connected) {
                return false;
              }
              final catalog = await _repository.getTools(server.id);
              return catalog.any(
                (candidate) => candidate.remoteName == descriptor.remoteName,
              );
            },
          ),
        );
      }
    }
    _toolRegistry.replaceDynamicSource('mcp', tools);
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
        updatedAt: _now(),
      ),
    );
    try {
      // A manual refresh also rotates credentials and negotiated sessions.
      await _client.disconnect(server);
      final catalog = await _client.discoverTools(
        server,
        cancellationToken: cancellationToken,
      );
      final connected = server.copyWith(
        remoteServerName: catalog.serverName,
        remoteServerVersion: catalog.serverVersion,
        capabilities: catalog.capabilities,
        status: McpConnectionStatus.connected,
        clearLastError: true,
        lastConnectedAt: _now(),
        updatedAt: _now(),
      );
      await _repository.replaceCatalog(connected, catalog.tools);
      await hydrateFromCache();
      return connected;
    } on McpException catch (error) {
      final requiresAuthorization = error.code == 'mcp_authorization_required';
      final failed = server.copyWith(
        status:
            requiresAuthorization
                ? McpConnectionStatus.authorizationRequired
                : McpConnectionStatus.error,
        lastErrorCode: error.code,
        updatedAt: _now(),
      );
      await _repository.saveServer(failed);
      await hydrateFromCache();
      rethrow;
    } on Object {
      await _repository.saveServer(
        server.copyWith(
          status: McpConnectionStatus.error,
          lastErrorCode: 'mcp_catalog_refresh_failed',
          updatedAt: _now(),
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
        updatedAt: _now(),
      ),
    );
    await hydrateFromCache();
  }
}
