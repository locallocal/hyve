import 'package:stars/domain/models/models.dart';

abstract interface class McpServerRepository {
  Stream<List<McpServer>> get changes;

  Future<List<McpServer>> getServers();

  Future<McpServer?> getServer(String id);

  Future<void> saveServer(McpServer server);

  Future<void> deleteServer(String id);

  Future<List<McpToolDescriptor>> getTools(String serverId);

  Future<void> replaceCatalog(McpServer server, List<McpToolDescriptor> tools);
}
