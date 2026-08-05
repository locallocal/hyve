import 'package:stars/domain/models/models.dart';

abstract interface class McpServerRepository {
  Stream<List<McpServer>> get changes;

  Future<List<McpServer>> getServers();

  Future<McpServer?> getServer(String id);

  Future<void> saveServer(McpServer server);

  Future<void> deleteServer(String id);

  Future<List<McpToolDescriptor>> getTools(
    String serverId, {
    bool enabledOnly = false,
  });

  Future<void> replaceCatalog(McpServer server, List<McpToolDescriptor> tools);

  Future<bool> isToolEnabled(String serverId, String remoteName);

  Future<void> setToolEnabled(
    String serverId,
    String remoteName, {
    required bool enabled,
  });
}
