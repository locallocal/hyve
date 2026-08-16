import 'dart:async';

import 'package:hyve/data/models/mcp_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/mcp_server_repository.dart';

final class SqliteMcpServerRepository implements McpServerRepository {
  SqliteMcpServerRepository({required LocalDatabaseService localDatabase})
    : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;
  final StreamController<List<McpServer>> _changes =
      StreamController<List<McpServer>>.broadcast();

  @override
  Stream<List<McpServer>> get changes => _changes.stream;

  @override
  Future<List<McpServer>> getServers() async {
    final records = await _localDatabase.loadMcpServers();
    return List<McpServer>.unmodifiable(
      records.map((record) => McpServerRecord(record).toDomain()),
    );
  }

  @override
  Future<McpServer?> getServer(String id) async {
    final records = await _localDatabase.loadMcpServer(id);
    return records.isEmpty ? null : McpServerRecord(records.single).toDomain();
  }

  @override
  Future<void> saveServer(McpServer server) async {
    final existing = await getServer(server.id);
    await _localDatabase.upsertMcpServer(
      McpServerRecord.fromDomain(server).values,
      clearTools: existing != null && existing.transport != server.transport,
    );
    await _emitServers();
  }

  @override
  Future<void> deleteServer(String id) async {
    await _localDatabase.deleteMcpServer(id);
    await _emitServers();
  }

  @override
  Future<List<McpToolDescriptor>> getTools(String serverId) async {
    final records = await _localDatabase.loadMcpTools(serverId);
    return List<McpToolDescriptor>.unmodifiable(
      records.map((record) => McpToolRecord(record).toDomain()),
    );
  }

  @override
  Future<void> replaceCatalog(
    McpServer server,
    List<McpToolDescriptor> tools,
  ) async {
    final records = await _catalogRecords(server, tools);
    await _localDatabase.replaceMcpCatalog(
      McpServerRecord.fromDomain(server).values,
      records,
    );
    await _emitServers();
  }

  Future<List<Map<String, Object?>>> _catalogRecords(
    McpServer server,
    List<McpToolDescriptor> tools,
  ) async {
    return [
      for (final tool in tools)
        if (tool.serverId != server.id)
          throw ArgumentError.value(
            tool.remoteName,
            'tools',
            'MCP Tool ownership does not match its server.',
          )
        else
          McpToolRecord.fromDomain(tool).values,
    ];
  }

  Future<void> _emitServers() async {
    if (!_changes.isClosed) _changes.add(await getServers());
  }

  Future<void> dispose() => _changes.close();
}
