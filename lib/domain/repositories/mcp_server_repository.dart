import 'package:stars/domain/models/models.dart';

abstract interface class McpServerRepository {
  Stream<List<McpServer>> get changes;

  Future<List<McpServer>> getServers({bool forceRefresh = false});

  Future<McpServer?> getServer(String id);

  Future<void> saveServer(McpServer server);

  Future<void> deleteServer(String id);

  Future<List<McpToolDescriptor>> getTools(
    String serverId, {
    bool enabledOnly = false,
  });

  Future<void> replaceTools(String serverId, List<McpToolDescriptor> tools);

  Future<void> setToolEnabled(
    String serverId,
    String remoteName, {
    required bool enabled,
  });
}
