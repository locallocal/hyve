import 'package:hyve/domain/models/models.dart';

abstract interface class McpCredentialStore {
  Future<McpCredential?> read(String serverId);

  Future<void> write(String serverId, McpCredential credential);

  Future<void> delete(String serverId);
}
