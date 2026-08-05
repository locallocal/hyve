import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/core/dependency_injection/app_scope.dart';
import 'package:stars/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:stars/ui/features/mcp/view_models/mcp_servers_view_model.dart';
import 'package:stars/utils/theme.dart';
import 'package:stars/utils/utils.dart';

class McpServersPage extends StatefulWidget {
  const McpServersPage({super.key, this.viewModel});

  final McpServersViewModel? viewModel;

  @override
  State<McpServersPage> createState() => _McpServersPageState();
}

class _McpServersPageState extends State<McpServersPage> {
  McpServersViewModel? _resolvedViewModel;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _query = '';
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
    _searchController.dispose();
    _searchFocusNode.dispose();
    if (widget.viewModel == null) _resolvedViewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder:
          (context, _) =>
              isDesktopOrTabletPlatform(context)
                  ? _buildDesktop(context)
                  : _buildMobile(context),
    );
  }

  Widget _buildMobile(BuildContext context) {
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
      body: _buildMobileBody(context),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final strings = S.of(context);
    final filteredServers = _filteredServers;
    return ColoredBox(
      color: DesktopThemeTokens.workspaceSurface(context),
      child: RefreshIndicator(
        onRefresh: _viewModel.load,
        child: SingleChildScrollView(
          key: const ValueKey<String>('mcp-servers-desktop-page'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: DesktopThemeTokens.formPagePadding,
          child: Center(
            child: ConstrainedBox(
              key: const ValueKey<String>('mcp-servers-desktop-content'),
              constraints: const BoxConstraints(
                maxWidth: DesktopThemeTokens.formContentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.mcpServers,
                              style: DesktopThemeTokens.pageTitleStyle(context),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              strings.mcpServersDescription,
                              style: DesktopThemeTokens.bodyStyle(
                                context,
                              )?.copyWith(
                                color: DesktopThemeTokens.mutedText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ShadButton(
                        key: const ValueKey<String>('add-mcp-server-desktop'),
                        onPressed: () => _showEditor(),
                        leading: const Icon(LucideIcons.plus, size: 16),
                        child: Text(strings.addMcpServer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ShadAlert(
                    icon: const Icon(LucideIcons.shieldCheck),
                    title: Text(strings.mcpLocalProcessSecurityTitle),
                    description: Text(
                      strings.mcpLocalProcessSecurityDescription,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDesktopSearchField(context),
                  const SizedBox(height: 16),
                  Text(
                    strings.mcpProgressiveDiscoveryDescription,
                    style: DesktopThemeTokens.bodyStyle(
                      context,
                    )?.copyWith(color: DesktopThemeTokens.mutedText(context)),
                  ),
                  if (_viewModel.error != null) ...[
                    const SizedBox(height: 16),
                    ShadAlert.destructive(
                      key: const ValueKey<String>('mcp-error-alert'),
                      crossAxisAlignment: CrossAxisAlignment.center,
                      icon: const Icon(LucideIcons.circleAlert),
                      title: Text(_errorMessage(_viewModel.error!)),
                      trailing: ShadTooltip(
                        builder:
                            (context) => Text(
                              MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip,
                            ),
                        child: ShadIconButton.ghost(
                          key: const ValueKey<String>('close-mcp-error'),
                          onPressed: _viewModel.clearError,
                          width: 28,
                          height: 28,
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: const Icon(LucideIcons.x),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_viewModel.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: ShadProgress(),
                      ),
                    )
                  else if (_viewModel.servers.isEmpty)
                    DesktopEmptyStateCard(
                      icon: LucideIcons.server,
                      title: strings.noMcpServers,
                      description: strings.noMcpServersDescription,
                      action: ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () => _showEditor(),
                        leading: const Icon(LucideIcons.plus, size: 16),
                        child: Text(strings.addMcpServer),
                      ),
                    )
                  else if (filteredServers.isEmpty)
                    _buildDesktopSearchEmpty(context)
                  else
                    _buildDesktopServers(filteredServers),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSearchField(BuildContext context) {
    final strings = S.of(context);
    return StarsSearchField(
      key: const ValueKey<String>('mcp-search-field'),
      hintText: strings.searchMcpServers,
      semanticLabel: strings.searchMcpServers,
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: _search,
      suffixIcon:
          _query.isNotEmpty
              ? IconButton(
                key: const ValueKey<String>('clear-mcp-search'),
                tooltip: strings.clearSearch,
                onPressed: _clearSearch,
                icon: const Icon(LucideIcons.x, size: 16),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              )
              : null,
    );
  }

  Widget _buildDesktopSearchEmpty(BuildContext context) {
    final strings = S.of(context);
    return DesktopEmptyStateCard(
      icon: LucideIcons.search,
      title: strings.noMatchingMcpServers,
      description: strings.tryDifferentSearch,
      action: ShadButton(
        size: ShadButtonSize.sm,
        onPressed: _clearSearch,
        leading: const Icon(LucideIcons.x, size: 16),
        child: Text(strings.clearSearch),
      ),
    );
  }

  Widget _buildDesktopServers(List<McpServer> servers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 800 ? 2 : 1;
        const gap = 14.0;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final server in servers)
              SizedBox(
                width: itemWidth,
                child: _DesktopServerCard(
                  key: ValueKey<String>('desktop-mcp-server-${server.id}'),
                  server: server,
                  tools: _viewModel.toolsFor(server.id),
                  busy: _viewModel.busyServerId == server.id,
                  onOpenDetails: () => _showDetails(server),
                  onEdit: () => _showEditor(server),
                  onRefresh: () => _viewModel.refresh(server.id),
                  onDelete: () => _confirmDelete(server),
                  onEnabledChanged:
                      (enabled) => _viewModel.setServerEnabled(server, enabled),
                ),
              ),
          ],
        );
      },
    );
  }

  List<McpServer> get _filteredServers {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return _viewModel.servers;
    return _viewModel.servers
        .where((server) {
          final tools = _viewModel.toolsFor(server.id);
          final searchableText =
              [
                server.name,
                server.namespace,
                _mcpConnectionSummary(server),
                server.transport.type.name,
                server.status.name,
                server.remoteServerName,
                server.remoteServerVersion,
                for (final tool in tools) ...[
                  tool.remoteName,
                  tool.title,
                  tool.description,
                  tool.canonicalName,
                ],
              ].join('\n').toLowerCase();
          return searchableText.contains(normalized);
        })
        .toList(growable: false);
  }

  void _search(String query) {
    if (_query == query) return;
    setState(() => _query = query);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
    if (_query.isNotEmpty) setState(() => _query = '');
  }

  Widget _buildMobileBody(BuildContext context) {
    if (_viewModel.isLoading && _viewModel.servers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _viewModel.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _SecurityNotice(
            title:
                isDesktopPlatform(context)
                    ? S.of(context).mcpLocalProcessSecurityTitle
                    : S.of(context).remoteMcpOnly,
            description:
                isDesktopPlatform(context)
                    ? S.of(context).mcpLocalProcessSecurityDescription
                    : S.of(context).localMcpDisabledDescription,
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
        'mcp_stdio_start_failed' => S.of(context).mcpStdioStartFailed,
        'mcp_invalid_stdio_environment' =>
          S.of(context).mcpInvalidStdioEnvironment,
        _ => S.of(context).mcpConnectionFailed(code),
      };
    }
    return S.of(context).mcpConnectionFailed('mcp_unknown_error');
  }

  Future<void> _showDetails(McpServer server) async {
    await showShadDialog<void>(
      context: context,
      builder:
          (dialogContext) => ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              var currentServer = server;
              for (final candidate in _viewModel.servers) {
                if (candidate.id == server.id) {
                  currentServer = candidate;
                  break;
                }
              }
              return _McpServerDetailsDialog(
                server: currentServer,
                tools: _viewModel.toolsFor(server.id),
                busy: _viewModel.busyServerId == server.id,
                onToolEnabledChanged: _viewModel.setToolEnabled,
              );
            },
          ),
    );
  }

  Future<void> _showEditor([McpServer? server]) async {
    final desktop = isDesktopOrTabletPlatform(context);
    final draft =
        desktop
            ? await showShadDialog<McpServerDraft>(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) =>
                      _McpServerEditorDialog(server: server, desktop: true),
            )
            : await showDialog<McpServerDraft>(
              context: context,
              builder:
                  (context) =>
                      _McpServerEditorDialog(server: server, desktop: false),
            );
    if (draft == null) return;
    await _viewModel.saveAndConnect(draft);
  }

  Future<void> _confirmDelete(McpServer server) async {
    final desktop = isDesktopOrTabletPlatform(context);
    final confirmed =
        desktop
            ? await showChatShadDialog<bool>(
              context: context,
              variant: ShadDialogVariant.alert,
              builder:
                  (dialogContext) => ShadDialog.alert(
                    title: Text(S.of(dialogContext).deleteMcpServer),
                    description: Text(
                      S.of(dialogContext).confirmDeleteMcpServer(server.name),
                    ),
                    actions: [
                      ShadButton.outline(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(S.of(dialogContext).cancel),
                      ),
                      ShadButton.destructive(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(S.of(dialogContext).delete),
                      ),
                    ],
                  ),
            )
            : await showDialog<bool>(
              context: context,
              builder:
                  (dialogContext) => AlertDialog(
                    title: Center(
                      child: Text(
                        S.of(dialogContext).deleteMcpServer,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              Theme.of(
                                dialogContext,
                              ).textTheme.bodyLarge?.fontSize,
                        ),
                      ),
                    ),
                    content: Text(
                      S.of(dialogContext).confirmDeleteMcpServer(server.name),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(S.of(dialogContext).cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(
                          S.of(dialogContext).delete,
                          style: TextStyle(
                            color: DesktopThemeTokens.error(dialogContext),
                          ),
                        ),
                      ),
                    ],
                  ),
            );
    if (confirmed == true) await _viewModel.deleteServer(server);
  }
}

String _mcpConnectionSummary(McpServer server) {
  return switch (server.transport) {
    McpStreamableHttpServerTransport(:final endpoint) => endpoint.toString(),
    McpStdioServerTransport(:final command, :final arguments) => [
      command,
      ...arguments,
    ].where((part) => part.isNotEmpty).join(' '),
  };
}

IconData _mcpStatusIcon(McpConnectionStatus status) => switch (status) {
  McpConnectionStatus.connected => Icons.cloud_done_outlined,
  McpConnectionStatus.connecting => Icons.cloud_sync_outlined,
  McpConnectionStatus.authorizationRequired => Icons.key_outlined,
  McpConnectionStatus.error => Icons.cloud_off_outlined,
  McpConnectionStatus.disconnected => Icons.cloud_outlined,
};

String _mcpStatusLabel(BuildContext context, McpConnectionStatus status) =>
    switch (status) {
      McpConnectionStatus.connected => S.of(context).mcpConnected,
      McpConnectionStatus.connecting => S.of(context).mcpConnecting,
      McpConnectionStatus.authorizationRequired =>
        S.of(context).mcpAuthorizationRequired,
      McpConnectionStatus.error => S.of(context).mcpConnectionError,
      McpConnectionStatus.disconnected => S.of(context).mcpDisconnected,
    };

class _DesktopServerCard extends StatefulWidget {
  const _DesktopServerCard({
    super.key,
    required this.server,
    required this.tools,
    required this.busy,
    required this.onOpenDetails,
    required this.onEdit,
    required this.onRefresh,
    required this.onDelete,
    required this.onEnabledChanged,
  });

  final McpServer server;
  final List<McpToolDescriptor> tools;
  final bool busy;
  final VoidCallback onOpenDetails;
  final VoidCallback onEdit;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;
  final ValueChanged<bool> onEnabledChanged;

  @override
  State<_DesktopServerCard> createState() => _DesktopServerCardState();
}

class _DesktopServerCardState extends State<_DesktopServerCard> {
  static const double _menuContentWidth = 184;
  static const EdgeInsets _menuPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );

  final ShadPopoverController _menuController = ShadPopoverController();
  final FocusNode _menuFocusNode = FocusNode(
    debugLabel: 'desktop-mcp-server-card-actions',
  );
  bool _menuActionInvokedByPointer = false;

  @override
  void didUpdateWidget(covariant _DesktopServerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.busy && widget.busy) _menuController.hide();
  }

  @override
  void dispose() {
    _menuController.dispose();
    _menuFocusNode.dispose();
    super.dispose();
  }

  void _invokeMenuAction(VoidCallback action) {
    final invokedByPointer = _menuActionInvokedByPointer;
    _menuActionInvokedByPointer = false;
    if (invokedByPointer) {
      FocusManager.instance.primaryFocus?.unfocus();
      _menuFocusNode.unfocus();
    }
    _menuController.hide();
    action();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!invokedByPointer &&
          FocusManager.instance.highlightMode ==
              FocusHighlightMode.traditional) {
        _menuFocusNode.requestFocus();
      } else {
        _menuFocusNode.unfocus();
      }
    });
  }

  Widget _buildActionMenu(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return ShadPopover(
      controller: _menuController,
      anchor: const ShadAnchorAuto(
        offset: Offset(0, 4),
        followerAnchor: AlignmentDirectional.topStart,
        targetAnchor: AlignmentDirectional.bottomEnd,
        fallback: ShadAnchorAuto(
          offset: Offset(0, -4),
          followerAnchor: AlignmentDirectional.bottomStart,
          targetAnchor: AlignmentDirectional.topEnd,
        ),
      ),
      padding: EdgeInsets.zero,
      popover:
          (context) => Listener(
            onPointerDown: (_) => _menuActionInvokedByPointer = true,
            onPointerUp:
                (_) => WidgetsBinding.instance.addPostFrameCallback((_) {
                  _menuActionInvokedByPointer = false;
                }),
            onPointerCancel: (_) => _menuActionInvokedByPointer = false,
            child: SizedBox(
              key: ValueKey<String>(
                'desktop-mcp-server-action-menu-${widget.server.id}',
              ),
              width: _menuContentWidth + _menuPadding.horizontal,
              child: Padding(
                padding: _menuPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShadButton.ghost(
                      key: ValueKey<String>(
                        'desktop-mcp-server-details-${widget.server.id}',
                      ),
                      size: ShadButtonSize.sm,
                      onPressed: () => _invokeMenuAction(widget.onOpenDetails),
                      mainAxisAlignment: MainAxisAlignment.start,
                      leading: const Icon(LucideIcons.info, size: 16),
                      child: Text(S.of(context).details),
                    ),
                    ShadButton.ghost(
                      key: ValueKey<String>(
                        'desktop-mcp-server-refresh-${widget.server.id}',
                      ),
                      size: ShadButtonSize.sm,
                      onPressed:
                          widget.busy
                              ? null
                              : () => _invokeMenuAction(widget.onRefresh),
                      mainAxisAlignment: MainAxisAlignment.start,
                      leading: const Icon(LucideIcons.refreshCw, size: 16),
                      child: Text(S.of(context).refresh),
                    ),
                    ShadButton.ghost(
                      key: ValueKey<String>(
                        'desktop-mcp-server-edit-${widget.server.id}',
                      ),
                      size: ShadButtonSize.sm,
                      onPressed:
                          widget.busy
                              ? null
                              : () => _invokeMenuAction(widget.onEdit),
                      mainAxisAlignment: MainAxisAlignment.start,
                      leading: const Icon(Icons.edit_outlined, size: 16),
                      child: Text(S.of(context).edit),
                    ),
                    ShadButton.raw(
                      key: ValueKey<String>(
                        'desktop-mcp-server-delete-${widget.server.id}',
                      ),
                      variant: ShadButtonVariant.ghost,
                      size: ShadButtonSize.sm,
                      foregroundColor: colors.destructive,
                      onPressed:
                          widget.busy
                              ? null
                              : () => _invokeMenuAction(widget.onDelete),
                      mainAxisAlignment: MainAxisAlignment.start,
                      leading: const Icon(LucideIcons.trash2, size: 16),
                      child: Text(S.of(context).delete),
                    ),
                  ],
                ),
              ),
            ),
          ),
      child: StarsDesktopIconAction(
        key: ValueKey<String>('desktop-mcp-server-actions-${widget.server.id}'),
        icon: LucideIcons.ellipsis,
        label: MaterialLocalizations.of(context).showMenuTooltip,
        focusNode: _menuFocusNode,
        onPressed: _menuController.toggle,
        hoverBackgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final tokens = StarsDesktopTokens.of(context);
    final statusColor = _statusColor(tokens, widget.server.status);

    return ShadCard(
      width: double.infinity,
      title: Row(
        children: [
          if (widget.busy)
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              _mcpStatusIcon(widget.server.status),
              size: 18,
              color: statusColor,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.server.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          ShadSwitch(
            key: ValueKey<String>(
              'desktop-mcp-server-toggle-${widget.server.id}',
            ),
            value: widget.server.enabled,
            enabled: !widget.busy,
            onChanged: widget.onEnabledChanged,
          ),
        ],
      ),
      description: Text(
        _mcpConnectionSummary(widget.server),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      footer: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: _buildActionMenu(context),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 10),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ShadBadge.outline(
              child: Text(
                _mcpStatusLabel(context, widget.server.status),
                style: TextStyle(color: statusColor),
              ),
            ),
            ShadBadge.secondary(child: Text(widget.server.namespace)),
            ShadBadge.secondary(
              child: Text(
                widget.server.transport.type == McpTransportType.stdio
                    ? strings.mcpTransportStdio
                    : strings.mcpTransportStreamableHttp,
              ),
            ),
            ShadBadge.outline(
              child: Text('${widget.tools.length} ${strings.mcpTools}'),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(StarsDesktopTokens tokens, McpConnectionStatus status) =>
      switch (status) {
        McpConnectionStatus.connected => tokens.success,
        McpConnectionStatus.connecting => tokens.warning,
        McpConnectionStatus.authorizationRequired => tokens.warning,
        McpConnectionStatus.error => tokens.danger,
        McpConnectionStatus.disconnected => tokens.secondaryText,
      };
}

class _McpServerDetailsDialog extends StatelessWidget {
  const _McpServerDetailsDialog({
    required this.server,
    required this.tools,
    required this.busy,
    required this.onToolEnabledChanged,
  });

  final McpServer server;
  final List<McpToolDescriptor> tools;
  final bool busy;
  final Future<void> Function(McpToolDescriptor, bool) onToolEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final tokens = StarsDesktopTokens.of(context);
    final statusColor = switch (server.status) {
      McpConnectionStatus.connected => tokens.success,
      McpConnectionStatus.connecting => tokens.warning,
      McpConnectionStatus.authorizationRequired => tokens.warning,
      McpConnectionStatus.error => tokens.danger,
      McpConnectionStatus.disconnected => tokens.secondaryText,
    };

    return ShadDialog(
      key: ValueKey<String>('desktop-mcp-server-details-dialog-${server.id}'),
      title: Text(server.name),
      description: Text(
        _mcpConnectionSummary(server),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      constraints: const BoxConstraints(maxWidth: 720),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
      child: SizedBox(
        height: 520,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ShadBadge.outline(
                    child: Text(
                      _mcpStatusLabel(context, server.status),
                      style: TextStyle(color: statusColor),
                    ),
                  ),
                  ShadBadge.secondary(child: Text(server.namespace)),
                  ShadBadge.secondary(
                    child: Text(
                      server.transport.type == McpTransportType.stdio
                          ? strings.mcpTransportStdio
                          : strings.mcpTransportStreamableHttp,
                    ),
                  ),
                  ShadBadge.outline(
                    child: Text('${tools.length} ${strings.mcpTools}'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const ShadSeparator.horizontal(),
              const SizedBox(height: 18),
              Text(strings.mcpTools, style: ShadTheme.of(context).textTheme.h4),
              const SizedBox(height: 10),
              if (tools.isEmpty)
                Text(
                  strings.noMcpToolsDiscovered,
                  style: DesktopThemeTokens.metaStyle(context),
                )
              else
                for (var index = 0; index < tools.length; index++) ...[
                  _DesktopMcpToolCard(
                    key: ValueKey<String>(
                      'desktop-mcp-tool-${server.id}-${tools[index].remoteName}',
                    ),
                    serverEnabled: server.enabled && !busy,
                    tool: tools[index],
                    onEnabledChanged: onToolEnabledChanged,
                  ),
                  if (index != tools.length - 1) const SizedBox(height: 8),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopMcpToolCard extends StatelessWidget {
  const _DesktopMcpToolCard({
    super.key,
    required this.serverEnabled,
    required this.tool,
    required this.onEnabledChanged,
  });

  final bool serverEnabled;
  final McpToolDescriptor tool;
  final Future<void> Function(McpToolDescriptor, bool) onEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = StarsDesktopTokens.of(context);
    final supported = tool.isSupportedByClient;
    final title = tool.title.isEmpty ? tool.remoteName : tool.title;

    return ShadCard(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      backgroundColor: tokens.controlFill,
      border: ShadBorder.all(color: tokens.separator, width: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              tool.annotations.destructiveHint
                  ? LucideIcons.triangleAlert
                  : tool.annotations.readOnlyHint
                  ? LucideIcons.eye
                  : LucideIcons.pencil,
              size: 16,
              color:
                  tool.annotations.destructiveHint
                      ? tokens.warning
                      : tokens.secondaryText,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ShadTheme.of(
                    context,
                  ).textTheme.small.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  tool.canonicalName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DesktopThemeTokens.metaStyle(context),
                ),
                if (tool.description.isNotEmpty || !supported) ...[
                  const SizedBox(height: 4),
                  Text(
                    supported
                        ? tool.description
                        : S.of(context).mcpToolSchemaUnsupported,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: DesktopThemeTokens.metaStyle(context)?.copyWith(
                      color: supported ? tokens.secondaryText : tokens.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          ShadSwitch(
            key: ValueKey<String>(
              'desktop-mcp-tool-toggle-${tool.serverId}-${tool.remoteName}',
            ),
            value: tool.enabled,
            enabled: serverEnabled && supported,
            onChanged: (enabled) => onEnabledChanged(tool, enabled),
          ),
        ],
      ),
    );
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
                : Icon(_mcpStatusIcon(server.status)),
        title: Text(server.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _mcpConnectionSummary(server),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${_mcpStatusLabel(context, server.status)} · '
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
                    !server.enabled || !tool.isSupportedByClient
                        ? null
                        : (enabled) => onToolEnabledChanged(tool, enabled),
                title: Text(tool.title.isEmpty ? tool.remoteName : tool.title),
                subtitle: Text(
                  tool.isSupportedByClient
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
}

class _McpServerEditorDialog extends StatefulWidget {
  const _McpServerEditorDialog({required this.desktop, this.server});

  final bool desktop;
  final McpServer? server;

  @override
  State<_McpServerEditorDialog> createState() => _McpServerEditorDialogState();
}

class _McpServerEditorDialogState extends State<_McpServerEditorDialog> {
  static const double _desktopFieldWidth =
      DesktopThemeTokens.addBotFormFieldWidth;
  static const double _desktopSectionPadding =
      DesktopThemeTokens.botFormSectionPadding;
  static const double _desktopSectionBorderWidth =
      DesktopThemeTokens.botFormSectionBorderWidth;
  static const double _desktopDropdownButtonSize = 30;
  static const double _desktopTransportMenuWidth = 256;
  static const double _desktopFormWidth =
      _desktopFieldWidth +
      _desktopSectionPadding * 2 +
      _desktopSectionBorderWidth * 2;
  static const BoxConstraints _desktopInputConstraints = BoxConstraints(
    minHeight: DesktopThemeTokens.botFormFieldHeight,
  );

  final _desktopFormKey = GlobalKey<ShadFormState>();
  final _desktopScrollController = ScrollController();
  late final TextEditingController _nameController;
  late final TextEditingController _namespaceController;
  late final TextEditingController _transportController;
  late final TextEditingController _endpointController;
  late final TextEditingController _commandController;
  late final TextEditingController _argumentsController;
  late final TextEditingController _environmentController;
  late final TextEditingController _tokenController;
  late final TextEditingController _authController;
  late McpTransportType _transportType;
  late McpAuthType _authType;

  @override
  void initState() {
    super.initState();
    final server = widget.server;
    final httpTransport = switch (server?.transport) {
      final McpStreamableHttpServerTransport transport => transport,
      _ => null,
    };
    final stdioTransport = switch (server?.transport) {
      final McpStdioServerTransport transport => transport,
      _ => null,
    };
    _nameController = TextEditingController(text: server?.name ?? '');
    _namespaceController = TextEditingController(text: server?.namespace ?? '');
    _transportController = TextEditingController();
    _endpointController = TextEditingController(
      text: httpTransport?.endpoint.toString() ?? '',
    );
    _commandController = TextEditingController(
      text: stdioTransport?.command ?? '',
    );
    _argumentsController = TextEditingController(
      text: stdioTransport?.arguments.join('\n') ?? '',
    );
    _environmentController = TextEditingController();
    _tokenController = TextEditingController();
    _authController = TextEditingController();
    _transportType = server?.transport.type ?? McpTransportType.streamableHttp;
    _authType = httpTransport?.authType ?? McpAuthType.none;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTransportController();
    _syncAuthController();
  }

  @override
  void dispose() {
    _desktopScrollController.dispose();
    _nameController.dispose();
    _namespaceController.dispose();
    _transportController.dispose();
    _endpointController.dispose();
    _commandController.dispose();
    _argumentsController.dispose();
    _environmentController.dispose();
    _tokenController.dispose();
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.desktop
        ? _buildDesktopDialog(context)
        : _buildMobileDialog(context);
  }

  Widget _buildDesktopDialog(BuildContext context) {
    final windowSize = MediaQuery.sizeOf(context);
    final inset =
        windowSize.width < 900 || windowSize.height < 760 ? 16.0 : 24.0;
    final dialogWidth =
        (windowSize.width - inset * 2).clamp(0.0, 840.0).toDouble();
    final dialogHeight =
        (windowSize.height - inset * 2).clamp(0.0, 720.0).toDouble();

    return ShadDialog(
      constraints: BoxConstraints.tightFor(
        width: dialogWidth,
        height: dialogHeight,
      ),
      padding: EdgeInsets.zero,
      gap: 0,
      scrollable: false,
      useSafeArea: false,
      removeBorderRadiusWhenTiny: false,
      closeIcon: const SizedBox.shrink(),
      child: SizedBox(
        key: const ValueKey<String>('mcp-server-dialog-content'),
        width: dialogWidth,
        height: dialogHeight,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              _buildDesktopHeader(context),
              const ShadSeparator.horizontal(),
              Expanded(
                child: Scrollbar(
                  controller: _desktopScrollController,
                  child: SingleChildScrollView(
                    controller: _desktopScrollController,
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _desktopFormWidth,
                        ),
                        child: ShadForm(
                          key: _desktopFormKey,
                          autovalidateMode:
                              ShadAutovalidateMode.alwaysAfterFirstValidation,
                          child: FocusTraversalGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildDesktopSection(
                                  context,
                                  S.of(context).basicInformation,
                                  [
                                    _buildDesktopNameInput(context),
                                    _buildDesktopNamespaceInput(context),
                                  ],
                                  sectionKey: const ValueKey<String>(
                                    'mcp-server-basic-section',
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildDesktopSection(
                                  context,
                                  S.of(context).mcpConnectionSettings,
                                  [
                                    _buildDesktopTransportInput(context),
                                    if (_transportType ==
                                        McpTransportType.streamableHttp) ...[
                                      _buildDesktopEndpointInput(context),
                                      _buildDesktopAuthInput(context),
                                      if (_authType ==
                                          McpAuthType.oauthAccessToken)
                                        _buildDesktopTokenInput(context),
                                    ] else ...[
                                      _buildDesktopCommandInput(context),
                                      _buildDesktopArgumentsInput(context),
                                      _buildDesktopEnvironmentInput(context),
                                    ],
                                  ],
                                  sectionKey: const ValueKey<String>(
                                    'mcp-server-connection-section',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildDesktopFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDialog(BuildContext context) {
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
              if (_transportType == McpTransportType.streamableHttp) ...[
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
                  onChanged: (value) => _setAuthType(value ?? McpAuthType.none),
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
              ] else ...[
                TextField(
                  controller: _commandController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: S.of(context).mcpCommand,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _argumentsController,
                  autocorrect: false,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: S.of(context).mcpArguments,
                    helperText: S.of(context).mcpArgumentsDescription,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _environmentController,
                  autocorrect: false,
                  obscureText: true,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: S.of(context).mcpEnvironment,
                    helperText: S.of(context).mcpEnvironmentDescription,
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

  Widget _buildDesktopHeader(BuildContext context) {
    final strings = S.of(context);
    final tokens = StarsDesktopTokens.of(context);
    final editing = widget.server != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.controlFill,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.server,
              size: 23,
              color: tokens.secondaryText,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editing ? strings.editMcpServer : strings.addMcpServer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DesktopThemeTokens.pageTitleStyle(context),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.mcpServersDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DesktopThemeTokens.metaStyle(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ShadTooltip(
            builder:
                (context) =>
                    Text(MaterialLocalizations.of(context).closeButtonTooltip),
            child: ShadIconButton.ghost(
              onPressed: () => Navigator.of(context).pop(),
              width: 36,
              height: 36,
              iconSize: 17,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSection(
    BuildContext context,
    String title,
    List<Widget> children, {
    required Key sectionKey,
  }) {
    final tokens = StarsDesktopTokens.of(context);
    return ShadCard(
      key: sectionKey,
      width: double.infinity,
      padding: const EdgeInsets.all(_desktopSectionPadding),
      backgroundColor: tokens.raisedSurface,
      border: ShadBorder.all(
        color: tokens.separator,
        width: _desktopSectionBorderWidth,
      ),
      columnCrossAxisAlignment: CrossAxisAlignment.stretch,
      title: Text(
        title,
        style: DesktopThemeTokens.sectionTitleStyle(
          context,
        )?.copyWith(fontSize: DesktopThemeTokens.botFormSectionTitleFontSize),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ShadSeparator.horizontal(),
        ColoredBox(
          color: ShadTheme.of(context).colorScheme.background,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _desktopFormWidth,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.outline(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(S.of(context).cancel),
                      ),
                      const SizedBox(width: 8),
                      ShadButton(
                        onPressed: _save,
                        leading: const Icon(Icons.link_rounded, size: 17),
                        child: Text(S.of(context).saveAndConnect),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopNameInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-name'),
      id: 'name',
      controller: _nameController,
      textInputAction: TextInputAction.next,
      label: Text(S.of(context).mcpServerName),
      leading: _desktopInputLeading(LucideIcons.server),
      constraints: _desktopInputConstraints,
      validator:
          (value) =>
              value.trim().isEmpty ? S.of(context).fillRequiredFields : null,
    );
  }

  Widget _buildDesktopNamespaceInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-namespace'),
      id: 'namespace',
      controller: _namespaceController,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      label: Text(S.of(context).mcpNamespace),
      description: Text(S.of(context).mcpNamespaceDescription),
      leading: _desktopInputLeading(LucideIcons.braces),
      constraints: _desktopInputConstraints,
      validator:
          (value) =>
              RegExp(r'^[a-z][a-z0-9_-]{0,31}$').hasMatch(value.trim())
                  ? null
                  : S.of(context).mcpNamespaceDescription,
    );
  }

  Widget _buildDesktopTransportInput(BuildContext context) {
    final tokens = StarsDesktopTokens.of(context);
    final shadTheme = ShadTheme.of(context);
    final inputTextStyle = shadTheme.textTheme.muted
        .copyWith(color: shadTheme.colorScheme.foreground)
        .merge(shadTheme.inputTheme.style);
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-transport'),
      id: 'transport',
      controller: _transportController,
      readOnly: true,
      label: Text(S.of(context).mcpTransport),
      leading: _desktopInputLeading(Icons.swap_horiz_rounded),
      constraints: _desktopInputConstraints,
      trailing: MenuAnchor(
        crossAxisUnconstrained: false,
        alignmentOffset: const Offset(
          _desktopDropdownButtonSize - _desktopTransportMenuWidth,
          4,
        ),
        style: _desktopMenuStyle(tokens, width: _desktopTransportMenuWidth),
        menuChildren: [
          for (final transportType in McpTransportType.values)
            MenuItemButton(
              trailingIcon:
                  transportType == _transportType
                      ? Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: tokens.accent,
                      )
                      : const SizedBox.square(dimension: 16),
              onPressed: () => _setTransportType(transportType),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 180),
                child: Text(
                  _transportLabel(transportType),
                  style: inputTextStyle,
                ),
              ),
            ),
        ],
        builder:
            (context, controller, child) => ShadIconButton.ghost(
              key: const ValueKey<String>('mcp-server-transport-menu'),
              onPressed: () => _toggleMenu(controller),
              icon: const Icon(Icons.expand_more_rounded),
              iconSize: 16,
              width: _desktopDropdownButtonSize,
              height: _desktopDropdownButtonSize,
              padding: EdgeInsets.zero,
            ),
      ),
    );
  }

  Widget _buildDesktopEndpointInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-endpoint'),
      id: 'endpoint',
      controller: _endpointController,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      keyboardType: TextInputType.url,
      label: Text(S.of(context).mcpEndpoint),
      placeholder: const Text('https://example.com/mcp'),
      leading: _desktopInputLeading(LucideIcons.link),
      constraints: _desktopInputConstraints,
      validator:
          (value) =>
              value.trim().isEmpty ? S.of(context).fillRequiredFields : null,
    );
  }

  Widget _buildDesktopCommandInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-command'),
      id: 'command',
      controller: _commandController,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      label: Text(S.of(context).mcpCommand),
      description: Text(S.of(context).mcpCommandDescription),
      placeholder: const Text('npx'),
      leading: _desktopInputLeading(Icons.terminal_rounded),
      constraints: _desktopInputConstraints,
      validator:
          (value) =>
              value.trim().isEmpty ? S.of(context).fillRequiredFields : null,
    );
  }

  Widget _buildDesktopArgumentsInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-arguments'),
      id: 'arguments',
      controller: _argumentsController,
      autocorrect: false,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: 4,
      label: Text(S.of(context).mcpArguments),
      description: Text(S.of(context).mcpArgumentsDescription),
      placeholder: const Text('-y\n@modelcontextprotocol/server-filesystem'),
      leading: _desktopInputLeading(Icons.format_list_bulleted_rounded),
      constraints: const BoxConstraints(minHeight: 104),
    );
  }

  Widget _buildDesktopEnvironmentInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-environment'),
      id: 'environment',
      controller: _environmentController,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: 4,
      label: Text(S.of(context).mcpEnvironment),
      description: Text(S.of(context).mcpEnvironmentDescription),
      placeholder: const Text('API_KEY=secret'),
      leading: _desktopInputLeading(Icons.password_rounded),
      constraints: const BoxConstraints(minHeight: 104),
    );
  }

  Widget _buildDesktopAuthInput(BuildContext context) {
    final tokens = StarsDesktopTokens.of(context);
    final shadTheme = ShadTheme.of(context);
    final inputTextStyle = shadTheme.textTheme.muted
        .copyWith(color: shadTheme.colorScheme.foreground)
        .merge(shadTheme.inputTheme.style);
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      style: _desktopMenuStyle(tokens),
      menuChildren: [
        for (final authType in McpAuthType.values)
          MenuItemButton(
            trailingIcon:
                authType == _authType
                    ? Icon(Icons.check_rounded, size: 16, color: tokens.accent)
                    : const SizedBox.square(dimension: 16),
            onPressed: () => _setAuthType(authType),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180),
              child: Text(_authLabel(authType), style: inputTextStyle),
            ),
          ),
      ],
      builder:
          (context, controller, child) => ShadInputFormField(
            key: const ValueKey<String>('mcp-server-authentication'),
            id: 'authentication',
            controller: _authController,
            readOnly: true,
            label: Text(S.of(context).mcpAuthentication),
            leading: _desktopInputLeading(LucideIcons.keyRound),
            constraints: _desktopInputConstraints,
            onPressed: () => _toggleMenu(controller),
            trailing: ShadIconButton.ghost(
              key: const ValueKey<String>('mcp-server-authentication-menu'),
              onPressed: () => _toggleMenu(controller),
              icon: const Icon(Icons.expand_more_rounded),
              iconSize: 16,
              width: _desktopDropdownButtonSize,
              height: _desktopDropdownButtonSize,
              padding: EdgeInsets.zero,
            ),
          ),
    );
  }

  MenuStyle _desktopMenuStyle(StarsDesktopTokens tokens, {double? width}) {
    return MenuStyle(
      backgroundColor: WidgetStatePropertyAll(tokens.raisedSurface),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      shadowColor: WidgetStatePropertyAll(
        Colors.black.withValues(alpha: tokens.highContrast ? 0 : 0.18),
      ),
      elevation: WidgetStatePropertyAll(tokens.highContrast ? 0 : 6),
      visualDensity: width == null ? null : VisualDensity.standard,
      minimumSize:
          width == null ? null : WidgetStatePropertyAll(Size(width, 0)),
      maximumSize: WidgetStatePropertyAll(Size(width ?? 420, 240)),
      side: WidgetStatePropertyAll(
        BorderSide(color: tokens.separator, width: 0),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: DesktopThemeTokens.containerRadius,
        ),
      ),
    );
  }

  Widget _buildDesktopTokenInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-access-token'),
      id: 'accessToken',
      controller: _tokenController,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      label: Text(S.of(context).mcpAccessToken),
      description: Text(
        widget.server == null
            ? S.of(context).mcpTokenStoredSecurely
            : S.of(context).mcpTokenLeaveBlank,
      ),
      leading: _desktopInputLeading(LucideIcons.lockKeyhole),
      constraints: _desktopInputConstraints,
    );
  }

  Widget _desktopInputLeading(IconData icon) {
    return SizedBox(
      width: 17,
      height: 30,
      child: Center(child: Icon(icon, size: 17)),
    );
  }

  void _toggleMenu(MenuController controller) {
    controller.isOpen ? controller.close() : controller.open();
  }

  void _setAuthType(McpAuthType value) {
    setState(() {
      _authType = value;
      _syncAuthController();
    });
  }

  void _setTransportType(McpTransportType value) {
    setState(() {
      _transportType = value;
      if (value == McpTransportType.stdio) {
        _authType = McpAuthType.none;
      }
      _syncTransportController();
      _syncAuthController();
    });
  }

  void _syncTransportController() {
    final label = _transportLabel(_transportType);
    if (_transportController.text != label) {
      _transportController.text = label;
    }
  }

  void _syncAuthController() {
    final label = _authLabel(_authType);
    if (_authController.text != label) {
      _authController.text = label;
    }
  }

  String _authLabel(McpAuthType value) => switch (value) {
    McpAuthType.none => S.of(context).mcpNoAuthentication,
    McpAuthType.oauthAccessToken => S.of(context).mcpAccessToken,
  };

  String _transportLabel(McpTransportType value) => switch (value) {
    McpTransportType.streamableHttp => S.of(context).mcpTransportStreamableHttp,
    McpTransportType.stdio => S.of(context).mcpTransportStdio,
  };

  void _save() {
    if (widget.desktop &&
        !(_desktopFormKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }
    final name = _nameController.text.trim();
    final namespace = _namespaceController.text.trim().toLowerCase();
    final endpoint = _endpointController.text.trim();
    final command = _commandController.text.trim();
    if (name.isEmpty ||
        !RegExp(r'^[a-z][a-z0-9_-]{0,31}$').hasMatch(namespace) ||
        (_transportType == McpTransportType.streamableHttp &&
            endpoint.isEmpty) ||
        (_transportType == McpTransportType.stdio && command.isEmpty)) {
      return;
    }
    Navigator.of(context).pop(
      McpServerDraft(
        id: widget.server?.id,
        name: name,
        namespace: namespace,
        transportType: _transportType,
        endpoint: endpoint,
        command: command,
        arguments: _argumentsController.text,
        environment: _environmentController.text,
        authType:
            _transportType == McpTransportType.stdio
                ? McpAuthType.none
                : _authType,
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
