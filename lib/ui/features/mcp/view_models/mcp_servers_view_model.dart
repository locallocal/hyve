import 'package:flutter/foundation.dart';
import 'package:stars/data/services/mcp/mcp_catalog_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/mcp_credential_store.dart';
import 'package:stars/domain/repositories/mcp_server_repository.dart';

final class McpServerDraft {
  const McpServerDraft({
    this.id,
    required this.name,
    required this.namespace,
    required this.endpoint,
    required this.authType,
    this.accessToken = '',
  });

  final String? id;
  final String name;
  final String namespace;
  final String endpoint;
  final McpAuthType authType;
  final String accessToken;
}

final class McpServersViewModel extends ChangeNotifier {
  McpServersViewModel({
    required McpServerRepository repository,
    required McpCredentialStore credentialStore,
    required McpCatalogService catalogService,
    DateTime Function()? now,
  }) : _repository = repository,
       _credentialStore = credentialStore,
       _catalogService = catalogService,
       _now = now ?? DateTime.now;

  final McpServerRepository _repository;
  final McpCredentialStore _credentialStore;
  final McpCatalogService _catalogService;
  final DateTime Function() _now;

  List<McpServer> _servers = const [];
  Map<String, List<McpToolDescriptor>> _toolsByServer = const {};
  bool _isLoading = false;
  String? _busyServerId;
  Object? _error;
  int _loadGeneration = 0;

  List<McpServer> get servers => _servers;
  bool get isLoading => _isLoading;
  String? get busyServerId => _busyServerId;
  Object? get error => _error;

  List<McpToolDescriptor> toolsFor(String serverId) =>
      _toolsByServer[serverId] ?? const [];

  Future<void> load() async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final servers = await _repository.getServers(forceRefresh: true);
      final tools = <String, List<McpToolDescriptor>>{};
      for (final server in servers) {
        tools[server.id] = await _repository.getTools(server.id);
      }
      if (generation != _loadGeneration) return;
      _servers = servers;
      _toolsByServer = Map.unmodifiable(tools);
    } catch (error) {
      if (generation == _loadGeneration) _error = error;
    } finally {
      if (generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> saveAndConnect(McpServerDraft draft) async {
    _error = null;
    final timestamp = _now();
    final existing =
        draft.id == null ? null : await _repository.getServer(draft.id!);
    final id =
        existing?.id ??
        'mcp-${timestamp.microsecondsSinceEpoch.toRadixString(36)}';
    final endpoint = Uri.tryParse(draft.endpoint.trim());
    if (endpoint == null || !endpoint.hasScheme || endpoint.host.isEmpty) {
      _error = const McpException('mcp_invalid_endpoint');
      notifyListeners();
      return false;
    }

    try {
      final server = McpServer(
        id: id,
        name: draft.name.trim(),
        namespace: draft.namespace.trim().toLowerCase(),
        endpoint: endpoint,
        authType: draft.authType,
        enabled: existing?.enabled ?? true,
        protocolVersion: existing?.protocolVersion ?? '',
        remoteServerName: existing?.remoteServerName ?? '',
        remoteServerVersion: existing?.remoteServerVersion ?? '',
        capabilities: existing?.capabilities ?? const McpServerCapabilities(),
        status: McpConnectionStatus.disconnected,
        createdAt: existing?.createdAt ?? timestamp,
        updatedAt: timestamp,
      );
      await _repository.saveServer(server);
      final accessToken = draft.accessToken.trim();
      if (draft.authType == McpAuthType.none) {
        await _credentialStore.delete(id);
      } else if (accessToken.isNotEmpty) {
        await _credentialStore.write(
          id,
          McpCredential(accessToken: accessToken),
        );
      }
      await _runForServer(id, () => _catalogService.refreshServer(id));
      return _error == null;
    } on Object catch (error) {
      _error = error;
      await _reloadPreservingError();
      return false;
    }
  }

  Future<bool> refresh(String serverId) async {
    _error = null;
    await _runForServer(
      serverId,
      () => _catalogService.refreshServer(serverId),
    );
    return _error == null;
  }

  Future<void> setServerEnabled(McpServer server, bool enabled) async {
    _error = null;
    try {
      final updated = server.copyWith(
        enabled: enabled,
        updatedAt: _now(),
        status: McpConnectionStatus.disconnected,
      );
      await _repository.saveServer(updated);
      if (enabled) {
        await _runForServer(
          server.id,
          () => _catalogService.refreshServer(server.id),
        );
      } else {
        await _catalogService.disconnect(updated);
        await load();
      }
    } on Object catch (error) {
      _error = error;
      await _reloadPreservingError();
    }
  }

  Future<void> setToolEnabled(McpToolDescriptor tool, bool enabled) async {
    _error = null;
    try {
      await _repository.setToolEnabled(
        tool.serverId,
        tool.remoteName,
        enabled: enabled,
      );
      await _catalogService.hydrateFromCache();
    } on Object catch (error) {
      _error = error;
    }
    await _reloadPreservingError();
  }

  Future<void> deleteServer(McpServer server) async {
    _error = null;
    try {
      await _catalogService.disconnect(server);
      await _repository.deleteServer(server.id);
      await _credentialStore.delete(server.id);
      await _catalogService.hydrateFromCache();
    } on Object catch (error) {
      _error = error;
    }
    await _reloadPreservingError();
  }

  Future<void> _runForServer(
    String serverId,
    Future<Object?> Function() operation,
  ) async {
    _busyServerId = serverId;
    notifyListeners();
    Object? failure;
    try {
      await operation();
    } on Object catch (error) {
      failure = error;
    } finally {
      _busyServerId = null;
      await load();
      _error = failure;
      notifyListeners();
    }
  }

  Future<void> _reloadPreservingError() async {
    final preserved = _error;
    await load();
    _error = preserved;
    notifyListeners();
  }
}
