import 'package:flutter/material.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/core/dependency_injection/app_scope.dart';
import 'package:stars/ui/features/mcp/view_models/mcp_servers_view_model.dart';

class McpServersPage extends StatefulWidget {
  const McpServersPage({super.key, this.viewModel});

  final McpServersViewModel? viewModel;

  @override
  State<McpServersPage> createState() => _McpServersPageState();
}

class _McpServersPageState extends State<McpServersPage> {
  McpServersViewModel? _resolvedViewModel;
  bool _initialized = false;

  McpServersViewModel get _viewModel => widget.viewModel ?? _resolvedViewModel!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _resolvedViewModel =
        widget.viewModel ?? AppScope.of(context).createMcpServersViewModel();
    _viewModel.load();
  }

  @override
  void dispose() {
    if (widget.viewModel == null) _resolvedViewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).mcpServers),
        actions: [
          IconButton(
            tooltip: S.of(context).addMcpServer,
            onPressed: () => _showEditor(),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(),
        icon: const Icon(Icons.add_rounded),
        label: Text(S.of(context).addMcpServer),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_viewModel.isLoading && _viewModel.servers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _viewModel.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _SecurityNotice(
            title: S.of(context).remoteMcpOnly,
            description: S.of(context).localMcpDisabledDescription,
          ),
          const SizedBox(height: 12),
          Text(
            S.of(context).mcpProgressiveDiscoveryDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (_viewModel.error != null) ...[
            const SizedBox(height: 12),
            _ErrorNotice(message: _errorMessage(_viewModel.error!)),
          ],
          const SizedBox(height: 16),
          if (_viewModel.servers.isEmpty)
            _EmptyState(onAdd: () => _showEditor())
          else
            for (final server in _viewModel.servers) ...[
              _ServerCard(
                server: server,
                tools: _viewModel.toolsFor(server.id),
                busy: _viewModel.busyServerId == server.id,
                onEdit: () => _showEditor(server),
                onRefresh: () => _viewModel.refresh(server.id),
                onDelete: () => _confirmDelete(server),
                onEnabledChanged:
                    (enabled) => _viewModel.setServerEnabled(server, enabled),
                onToolEnabledChanged: _viewModel.setToolEnabled,
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  String _errorMessage(Object error) {
    if (error case McpException(:final code)) {
      return switch (code) {
        'mcp_https_required' => S.of(context).mcpHttpsRequired,
        'mcp_private_endpoint_blocked' =>
          S.of(context).mcpPrivateEndpointBlocked,
        'mcp_authorization_required' => S.of(context).mcpAuthorizationRequired,
        'mcp_request_timeout' => S.of(context).mcpRequestTimedOut,
        'mcp_unsupported_protocol' => S.of(context).mcpUnsupportedProtocol,
        _ => S.of(context).mcpConnectionFailed(code),
      };
    }
    return S.of(context).mcpConnectionFailed('mcp_unknown_error');
  }

  Future<void> _showEditor([McpServer? server]) async {
    final draft = await showDialog<McpServerDraft>(
      context: context,
      builder: (context) => _McpServerEditorDialog(server: server),
    );
    if (draft == null) return;
    await _viewModel.saveAndConnect(draft);
  }

  Future<void> _confirmDelete(McpServer server) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(S.of(context).deleteMcpServer),
            content: Text(S.of(context).confirmDeleteMcpServer(server.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(S.of(context).cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(S.of(context).delete),
              ),
            ],
          ),
    );
    if (confirmed == true) await _viewModel.deleteServer(server);
  }
}

class _ServerCard extends StatelessWidget {
  const _ServerCard({
    required this.server,
    required this.tools,
    required this.busy,
    required this.onEdit,
    required this.onRefresh,
    required this.onDelete,
    required this.onEnabledChanged,
    required this.onToolEnabledChanged,
  });

  final McpServer server;
  final List<McpToolDescriptor> tools;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;
  final ValueChanged<bool> onEnabledChanged;
  final Future<void> Function(McpToolDescriptor, bool) onToolEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading:
            busy
                ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Icon(_statusIcon(server.status)),
        title: Text(server.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(server.endpoint.toString()),
            const SizedBox(height: 2),
            Text(
              '${_statusLabel(context, server.status)} · '
              '${server.namespace} · ${tools.length} ${S.of(context).mcpTools}',
              style: TextStyle(
                color:
                    server.status == McpConnectionStatus.error
                        ? colorScheme.error
                        : null,
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: server.enabled,
          onChanged: busy ? null : onEnabledChanged,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: busy ? null : onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(S.of(context).refreshMcpTools),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: S.of(context).editMcpServer,
                  onPressed: busy ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: S.of(context).deleteMcpServer,
                  onPressed: busy ? null : onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
          if (tools.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(S.of(context).noMcpToolsDiscovered),
              ),
            )
          else
            for (final tool in tools)
              SwitchListTile(
                value: tool.enabled,
                onChanged:
                    !server.enabled || !tool.hasCompatibleSchema
                        ? null
                        : (enabled) => onToolEnabledChanged(tool, enabled),
                title: Text(tool.title.isEmpty ? tool.remoteName : tool.title),
                subtitle: Text(
                  tool.hasCompatibleSchema
                      ? '${tool.canonicalName}\n${tool.description}'
                      : S.of(context).mcpToolSchemaUnsupported,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                secondary: Icon(
                  tool.annotations.destructiveHint
                      ? Icons.warning_amber_rounded
                      : tool.annotations.readOnlyHint
                      ? Icons.visibility_outlined
                      : Icons.edit_outlined,
                ),
              ),
        ],
      ),
    );
  }

  IconData _statusIcon(McpConnectionStatus status) => switch (status) {
    McpConnectionStatus.connected => Icons.cloud_done_outlined,
    McpConnectionStatus.connecting => Icons.cloud_sync_outlined,
    McpConnectionStatus.authorizationRequired => Icons.key_outlined,
    McpConnectionStatus.error => Icons.cloud_off_outlined,
    McpConnectionStatus.disconnected => Icons.cloud_outlined,
  };

  String _statusLabel(BuildContext context, McpConnectionStatus status) =>
      switch (status) {
        McpConnectionStatus.connected => S.of(context).mcpConnected,
        McpConnectionStatus.connecting => S.of(context).mcpConnecting,
        McpConnectionStatus.authorizationRequired =>
          S.of(context).mcpAuthorizationRequired,
        McpConnectionStatus.error => S.of(context).mcpConnectionError,
        McpConnectionStatus.disconnected => S.of(context).mcpDisconnected,
      };
}

class _McpServerEditorDialog extends StatefulWidget {
  const _McpServerEditorDialog({this.server});

  final McpServer? server;

  @override
  State<_McpServerEditorDialog> createState() => _McpServerEditorDialogState();
}

class _McpServerEditorDialogState extends State<_McpServerEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _namespaceController;
  late final TextEditingController _endpointController;
  late final TextEditingController _tokenController;
  late McpAuthType _authType;

  @override
  void initState() {
    super.initState();
    final server = widget.server;
    _nameController = TextEditingController(text: server?.name ?? '');
    _namespaceController = TextEditingController(text: server?.namespace ?? '');
    _endpointController = TextEditingController(
      text: server?.endpoint.toString() ?? '',
    );
    _tokenController = TextEditingController();
    _authType = server?.authType ?? McpAuthType.none;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _namespaceController.dispose();
    _endpointController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.server == null
            ? S.of(context).addMcpServer
            : S.of(context).editMcpServer,
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: S.of(context).mcpServerName,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _namespaceController,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: S.of(context).mcpNamespace,
                  helperText: S.of(context).mcpNamespaceDescription,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _endpointController,
                autocorrect: false,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: S.of(context).mcpEndpoint,
                  hintText: 'https://example.com/mcp',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<McpAuthType>(
                initialValue: _authType,
                decoration: InputDecoration(
                  labelText: S.of(context).mcpAuthentication,
                ),
                items: [
                  DropdownMenuItem(
                    value: McpAuthType.none,
                    child: Text(S.of(context).mcpNoAuthentication),
                  ),
                  DropdownMenuItem(
                    value: McpAuthType.oauthAccessToken,
                    child: Text(S.of(context).mcpAccessToken),
                  ),
                ],
                onChanged:
                    (value) =>
                        setState(() => _authType = value ?? McpAuthType.none),
              ),
              if (_authType == McpAuthType.oauthAccessToken) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _tokenController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: S.of(context).mcpAccessToken,
                    helperText:
                        widget.server == null
                            ? S.of(context).mcpTokenStoredSecurely
                            : S.of(context).mcpTokenLeaveBlank,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(S.of(context).saveAndConnect),
        ),
      ],
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    final namespace = _namespaceController.text.trim().toLowerCase();
    final endpoint = _endpointController.text.trim();
    if (name.isEmpty ||
        !RegExp(r'^[a-z][a-z0-9_-]{0,31}$').hasMatch(namespace) ||
        endpoint.isEmpty) {
      return;
    }
    Navigator.of(context).pop(
      McpServerDraft(
        id: widget.server?.id,
        name: name,
        namespace: namespace,
        endpoint: endpoint,
        authType: _authType,
        accessToken: _tokenController.text,
      ),
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: ListTile(
        leading: const Icon(Icons.security_outlined),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: const Icon(Icons.error_outline_rounded),
        title: Text(message),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Column(
        children: [
          const Icon(Icons.hub_outlined, size: 56),
          const SizedBox(height: 16),
          Text(
            S.of(context).noMcpServers,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).noMcpServersDescription,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: Text(S.of(context).addMcpServer),
          ),
        ],
      ),
    );
  }
}
