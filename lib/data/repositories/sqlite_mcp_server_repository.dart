import 'dart:async';

import 'package:stars/data/models/mcp_records.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/mcp_server_repository.dart';

final class SqliteMcpServerRepository implements McpServerRepository {
  SqliteMcpServerRepository({required LocalDatabaseService localDatabase})
    : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;
  final StreamController<List<McpServer>> _changes =
      StreamController<List<McpServer>>.broadcast();
  List<McpServer>? _cache;

  @override
  Stream<List<McpServer>> get changes => _changes.stream;

  @override
  Future<List<McpServer>> getServers({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _snapshot;
    final records = await _localDatabase.loadMcpServers();
    _cache =
        records.map((record) => McpServerRecord(record).toDomain()).toList()
          ..sort((left, right) => left.name.compareTo(right.name));
    return _snapshot;
  }

  @override
  Future<McpServer?> getServer(String id) async {
    final cached = _cache?.where((server) => server.id == id).firstOrNull;
    if (cached != null) return cached;
    final records = await _localDatabase.loadMcpServer(id);
    return records.isEmpty ? null : McpServerRecord(records.single).toDomain();
  }

  @override
  Future<void> saveServer(McpServer server) async {
    final existing = await getServer(server.id);
    await _localDatabase.upsertMcpServer(
      McpServerRecord.fromDomain(server).values,
    );
    if (existing != null && existing.namespace != server.namespace) {
      await _localDatabase.clearMcpTools(server.id);
    }
    await _refreshAndEmit();
  }

  @override
  Future<void> deleteServer(String id) async {
    await _localDatabase.deleteMcpServer(id);
    await _refreshAndEmit();
  }

  @override
  Future<List<McpToolDescriptor>> getTools(
    String serverId, {
    bool enabledOnly = false,
  }) async {
    final records = await _localDatabase.loadMcpTools(
      serverId,
      enabledOnly: enabledOnly,
    );
    return List<McpToolDescriptor>.unmodifiable(
      records.map((record) => McpToolRecord(record).toDomain()),
    );
  }

  @override
  Future<void> replaceTools(
    String serverId,
    List<McpToolDescriptor> tools,
  ) async {
    final previous = {
      for (final tool in await getTools(serverId))
        tool.remoteName: tool.enabled,
    };
    final records = [
      for (final tool in tools)
        McpToolRecord.fromDomain(
          tool.copyWith(enabled: previous[tool.remoteName] ?? false),
        ).values,
    ];
    await _localDatabase.replaceMcpTools(serverId, records);
  }

  @override
  Future<void> setToolEnabled(
    String serverId,
    String remoteName, {
    required bool enabled,
  }) {
    return _localDatabase.setMcpToolEnabled(
      serverId,
      remoteName,
      enabled: enabled,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _refreshAndEmit() async {
    await getServers(forceRefresh: true);
    if (!_changes.isClosed) _changes.add(_snapshot);
  }

  List<McpServer> get _snapshot =>
      List<McpServer>.unmodifiable(_cache ?? const []);

  Future<void> dispose() => _changes.close();
}
