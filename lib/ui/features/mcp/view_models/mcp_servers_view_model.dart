import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/catalog_controller.dart';
import 'package:stars/domain/repositories/mcp_credential_store.dart';
import 'package:stars/domain/repositories/mcp_server_repository.dart';

final class McpServerDraft {
  const McpServerDraft({
    this.id,
    required this.name,
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
    required McpCatalogController catalogService,
    DateTime Function()? now,
  }) : _repository = repository,
       _credentialStore = credentialStore,
       _catalogService = catalogService,
       _now = now ?? DateTime.now {
    _repositoryChangesSubscription = _repository.changes.listen(
      _handleRepositoryChanges,
    );
  }

  final McpServerRepository _repository;
  final McpCredentialStore _credentialStore;
  final McpCatalogController _catalogService;
  final DateTime Function() _now;
  late final StreamSubscription<List<McpServer>> _repositoryChangesSubscription;

  List<McpServer> _servers = const [];
  Map<String, List<McpToolDescriptor>> _toolsByServer = const {};
  bool _isLoading = false;
  String? _busyServerId;
  AppFailure? _error;
  AppFailure? _warning;
  int _loadGeneration = 0;

  List<McpServer> get servers => _servers;
  bool get isLoading => _isLoading;
  String? get busyServerId => _busyServerId;
  AppFailure? get error => _error;
  AppFailure? get warning => _warning;

  List<McpToolDescriptor> toolsFor(String serverId) =>
      _toolsByServer[serverId] ?? const [];

  McpStdioProcessInfo? getStdioProcessInfo(String serverId) =>
      _catalogService.getStdioProcessInfo(serverId);

  void _handleRepositoryChanges(List<McpServer> _) {
    unawaited(_load(clearError: false));
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void clearWarning() {
    if (_warning == null) return;
    _warning = null;
    notifyListeners();
  }

  Future<void> load() => _load(clearError: true);

  Future<void> _load({required bool clearError}) async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    if (clearError) _error = null;
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
      if (generation == _loadGeneration) {
        _error = AppFailure.from(error, code: 'mcp_load_failed');
      }
    } finally {
      if (generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> saveAndConnect(McpServerDraft draft) async {
    _error = null;
    _warning = null;
    final timestamp = _now();
    McpServer? existing;
    try {
      existing =
          draft.id == null ? null : await _repository.getServer(draft.id!);
    } on Object catch (error) {
      _error = AppFailure.from(error, code: 'mcp_server_read_failed');
      notifyListeners();
      return false;
    }
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
          _error = const AppFailure.validation('mcp_invalid_endpoint');
          notifyListeners();
          return false;
        }
        transport = McpStreamableHttpServerTransport(
          endpoint: parsedEndpoint,
          authType: draft.authType,
        );
      case McpTransportType.stdio:
        if (draft.command.trim().isEmpty) {
          _error = const AppFailure.validation('mcp_invalid_stdio_command');
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
      _error = const AppFailure.validation('mcp_invalid_stdio_environment');
      notifyListeners();
      return false;
    }

    McpCredential? previousCredential;
    try {
      previousCredential = await _readCredentialForRollback(id);
    } on Object catch (error) {
      _error = AppFailure.from(error, code: 'mcp_credential_read_failed');
      notifyListeners();
      return false;
    }
    var credentialChanged = false;
    try {
      final server = McpServer(
        id: id,
        name: draft.name.trim(),
        transport: transport,
        remoteServerName: existing?.remoteServerName ?? '',
        remoteServerVersion: existing?.remoteServerVersion ?? '',
        capabilities: existing?.capabilities ?? const McpServerCapabilities(),
        status: McpConnectionStatus.disconnected,
        createdAt: existing?.createdAt ?? timestamp,
        updatedAt: timestamp,
      );
      credentialChanged = true;
      await _saveCredential(
        id: id,
        existing: existing,
        draft: draft,
        environment: environment,
      );
      await _repository.saveServer(server);
      _publishSavedServer(
        server,
        clearTools: existing != null && existing.transport != server.transport,
      );
    } on Object catch (error) {
      if (credentialChanged) {
        try {
          await _restoreCredential(id, previousCredential);
        } on Object catch (rollbackError) {
          _error = AppFailure.storage(
            'mcp_credential_rollback_failed',
            cause: (error, rollbackError),
          );
          await _reloadPreservingError();
          return false;
        }
      }
      _error = AppFailure.from(error, code: 'mcp_save_failed');
      await _reloadPreservingError();
      return false;
    }

    // Discovery is a follow-up operation. A remote outage must not turn a
    // fully committed local save into a reported save failure.
    await _runForServer(
      id,
      () => _catalogService.refreshServer(id),
      failureIsWarning: true,
    );
    return true;
  }

  void _publishSavedServer(McpServer server, {required bool clearTools}) {
    // An older page refresh must not replace this freshly persisted state.
    _loadGeneration += 1;
    _isLoading = false;
    final servers = [
      for (final current in _servers)
        if (current.id != server.id) current,
      server,
    ]..sort(
      (left, right) =>
          left.name.toLowerCase().compareTo(right.name.toLowerCase()),
    );
    final toolsByServer = <String, List<McpToolDescriptor>>{..._toolsByServer};
    if (clearTools || !toolsByServer.containsKey(server.id)) {
      toolsByServer[server.id] = const [];
    }
    _servers = List<McpServer>.unmodifiable(servers);
    _toolsByServer = Map<String, List<McpToolDescriptor>>.unmodifiable(
      toolsByServer,
    );
    notifyListeners();
  }

  Future<bool> refresh(String serverId) async {
    _error = null;
    _warning = null;
    await _runForServer(
      serverId,
      () => _catalogService.refreshServer(serverId),
    );
    return _error == null;
  }

  Future<void> deleteServer(McpServer server) async {
    _error = null;
    _warning = null;
    try {
      final previousCredential = await _readCredentialForRollback(server.id);
      try {
        await _catalogService.disconnect(server);
      } on Object catch (error) {
        _warning = AppFailure.from(error, code: 'mcp_disconnect_failed');
      }
      await _credentialStore.delete(server.id);
      try {
        await _repository.deleteServer(server.id);
      } on Object catch (error) {
        try {
          await _restoreCredential(server.id, previousCredential);
        } on Object catch (rollbackError) {
          throw AppFailure.storage(
            'mcp_credential_rollback_failed',
            cause: (error, rollbackError),
          );
        }
        rethrow;
      }
      try {
        await _catalogService.hydrateFromCache();
      } on Object catch (error) {
        _warning = AppFailure.from(error, code: 'mcp_cache_refresh_failed');
      }
    } on Object catch (error) {
      _error = AppFailure.from(error, code: 'mcp_delete_failed');
    }
    await _reloadPreservingError();
  }

  Future<void> _runForServer(
    String serverId,
    Future<Object?> Function() operation, {
    bool failureIsWarning = false,
  }) async {
    _busyServerId = serverId;
    notifyListeners();
    AppFailure? failure;
    try {
      await operation();
    } on Object catch (error) {
      failure = AppFailure.from(error, code: 'mcp_operation_failed');
    } finally {
      _busyServerId = null;
      await load();
      if (failureIsWarning) {
        _warning = failure;
      } else {
        _error = failure;
      }
      notifyListeners();
    }
  }

  Future<void> _reloadPreservingError() async {
    final preserved = _error;
    await load();
    _error = preserved;
    notifyListeners();
  }

  Future<McpCredential?> _readCredentialForRollback(String id) async {
    try {
      return await _credentialStore.read(id);
    } on Object catch (error) {
      throw AppFailure.storage('mcp_credential_read_failed', cause: error);
    }
  }

  Future<void> _restoreCredential(String id, McpCredential? credential) async {
    if (credential == null) {
      await _credentialStore.delete(id);
    } else {
      await _credentialStore.write(id, credential);
    }
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

  @override
  void dispose() {
    unawaited(_repositoryChangesSubscription.cancel());
    super.dispose();
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
