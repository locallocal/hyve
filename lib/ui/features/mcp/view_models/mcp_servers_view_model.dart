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
    this.transportType = McpTransportType.streamableHttp,
    this.endpoint = '',
    this.command = '',
    this.arguments = '',
    this.environment = '',
    this.authType = McpAuthType.none,
    this.accessToken = '',
  });

  final String? id;
  final String name;
  final String namespace;
  final McpTransportType transportType;
  final String endpoint;
  final String command;
  final String arguments;
  final String environment;
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

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<void> load() async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final servers = await _repository.getServers();
      final catalogs = await Future.wait(
        servers.map(
          (server) async => (server.id, await _repository.getTools(server.id)),
        ),
      );
      if (generation != _loadGeneration) return;
      _servers = servers;
      _toolsByServer = Map.unmodifiable({
        for (final (serverId, tools) in catalogs) serverId: tools,
      });
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
    final McpServerTransport transport;
    switch (draft.transportType) {
      case McpTransportType.streamableHttp:
        final parsedEndpoint = Uri.tryParse(draft.endpoint.trim());
        if (parsedEndpoint == null ||
            !parsedEndpoint.hasScheme ||
            parsedEndpoint.host.isEmpty) {
          _error = const McpException('mcp_invalid_endpoint');
          notifyListeners();
          return false;
        }
        transport = McpStreamableHttpServerTransport(
          endpoint: parsedEndpoint,
          authType: draft.authType,
        );
      case McpTransportType.stdio:
        if (draft.command.trim().isEmpty) {
          _error = const McpException('mcp_invalid_stdio_command');
          notifyListeners();
          return false;
        }
        transport = McpStdioServerTransport(
          command: draft.command.trim(),
          arguments: draft.arguments
              .split(RegExp(r'\r?\n'))
              .map((argument) => argument.trim())
              .where((argument) => argument.isNotEmpty)
              .toList(growable: false),
        );
    }
    final environment = _parseEnvironment(draft.environment);
    if (environment == null) {
      _error = const McpException('mcp_invalid_stdio_environment');
      notifyListeners();
      return false;
    }

    try {
      final server = McpServer(
        id: id,
        name: draft.name.trim(),
        namespace: draft.namespace.trim().toLowerCase(),
        transport: transport,
        remoteServerName: existing?.remoteServerName ?? '',
        remoteServerVersion: existing?.remoteServerVersion ?? '',
        capabilities: existing?.capabilities ?? const McpServerCapabilities(),
        status: McpConnectionStatus.disconnected,
        createdAt: existing?.createdAt ?? timestamp,
        updatedAt: timestamp,
      );
      await _repository.saveServer(server);
      await _saveCredential(
        id: id,
        existing: existing,
        draft: draft,
        environment: environment,
      );
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

  Future<void> _saveCredential({
    required String id,
    required McpServer? existing,
    required McpServerDraft draft,
    required Map<String, String> environment,
  }) async {
    if (draft.transportType == McpTransportType.stdio) {
      if (environment.isNotEmpty) {
        await _credentialStore.write(
          id,
          McpCredential(environment: environment),
        );
      } else if (existing?.transport is! McpStdioServerTransport) {
        await _credentialStore.delete(id);
      }
      return;
    }

    if (draft.authType == McpAuthType.none) {
      await _credentialStore.delete(id);
      return;
    }
    final accessToken = draft.accessToken.trim();
    if (accessToken.isNotEmpty) {
      await _credentialStore.write(id, McpCredential(accessToken: accessToken));
    } else if (existing?.transport case McpStreamableHttpServerTransport(
      authType: McpAuthType.oauthAccessToken,
    )) {
      return;
    } else {
      await _credentialStore.delete(id);
    }
  }
}

Map<String, String>? _parseEnvironment(String source) {
  final environment = <String, String>{};
  for (final rawLine in source.split(RegExp(r'\r?\n'))) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final separator = line.indexOf('=');
    if (separator <= 0) return null;
    final key = line.substring(0, separator).trim();
    if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(key)) return null;
    environment[key] = line.substring(separator + 1);
  }
  return Map<String, String>.unmodifiable(environment);
}
