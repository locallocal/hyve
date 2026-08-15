import 'dart:async';

import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/catalog_controller.dart';
import 'package:stars/domain/repositories/mcp_server_repository.dart';
import 'package:stars/domain/use_cases/mcp_server_mutations.dart';
import 'package:stars/ui/core/view_models/disposable_change_notifier.dart';

final class McpServersViewModel extends DisposableChangeNotifier {
  McpServersViewModel({
    required McpServerRepository repository,
    required McpCatalogController catalogService,
    required SaveAndConnectMcpServer saveAndConnect,
    required DeleteMcpServer deleteServer,
  }) : _repository = repository,
       _catalogService = catalogService,
       _saveAndConnect = saveAndConnect,
       _deleteServer = deleteServer {
    _repositoryChangesSubscription = _repository.changes.listen(
      _handleRepositoryChanges,
    );
  }

  final McpServerRepository _repository;
  final McpCatalogController _catalogService;
  final SaveAndConnectMcpServer _saveAndConnect;
  final DeleteMcpServer _deleteServer;
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
    if (isDisposed) return;
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
    if (isDisposed) return;
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
      if (isDisposed || generation != _loadGeneration) return;
      _servers = servers;
      _toolsByServer = Map.unmodifiable({
        for (final (serverId, tools) in catalogs) serverId: tools,
      });
    } catch (error) {
      if (!isDisposed && generation == _loadGeneration) {
        _error = AppFailure.from(error, code: 'mcp_load_failed');
      }
    } finally {
      if (!isDisposed && generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> saveAndConnect(McpServerDraft draft) async {
    if (isDisposed) return false;
    _error = null;
    _warning = null;
    final result = await _saveAndConnect(
      draft,
      onCommitted: (commit) {
        if (isDisposed) return;
        _busyServerId = commit.server.id;
        _publishSavedServer(commit.server, clearTools: commit.clearTools);
      },
    );
    if (isDisposed) return result.isCommitted;
    _busyServerId = null;
    await _reloadPreservingFeedback(
      error: result.failure,
      warning: result.warning,
    );
    return result.isCommitted;
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
    if (isDisposed) return false;
    _error = null;
    _warning = null;
    await _runForServer(
      serverId,
      () => _catalogService.refreshServer(serverId),
    );
    if (isDisposed) return false;
    return _error == null;
  }

  Future<void> deleteServer(McpServer server) async {
    if (isDisposed) return;
    _error = null;
    _warning = null;
    _busyServerId = server.id;
    notifyListeners();
    final result = await _deleteServer(server);
    if (isDisposed) return;
    _busyServerId = null;
    await _reloadPreservingFeedback(
      error: result.failure,
      warning: result.warning,
    );
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
    }
    if (isDisposed) return;
    _busyServerId = null;
    await load();
    if (isDisposed) return;
    if (failureIsWarning) {
      _warning = failure;
    } else {
      _error = failure;
    }
    notifyListeners();
  }

  Future<void> _reloadPreservingFeedback({
    AppFailure? error,
    AppFailure? warning,
  }) async {
    if (isDisposed) return;
    await load();
    if (isDisposed) return;
    _error = error ?? _error;
    _warning = warning;
    notifyListeners();
  }

  @override
  void disposeResources() {
    unawaited(_repositoryChangesSubscription.cancel());
  }
}
