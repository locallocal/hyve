import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/utils/theme.dart';

/// Manages the MCP servers added to a bot and their per-bot enabled state.
class BotMcpServerPicker extends StatefulWidget {
  const BotMcpServerPicker({
    super.key,
    required this.servers,
    required this.selectedServerIds,
    required this.disabledServerIds,
    required this.onChanged,
    this.isLoading = false,
    this.embedded = false,
  });

  final List<McpServer> servers;
  final Set<String> selectedServerIds;
  final Set<String> disabledServerIds;
  final void Function(
    Set<String> selectedServerIds,
    Set<String> disabledServerIds,
  )
  onChanged;
  final bool isLoading;
  final bool embedded;

  @override
  State<BotMcpServerPicker> createState() => _BotMcpServerPickerState();
}

class _BotMcpServerPickerState extends State<BotMcpServerPicker> {
  final _searchController = TextEditingController();

  List<McpServer> get _addedServers => widget.servers
      .where((server) => widget.selectedServerIds.contains(server.id))
      .toList(growable: false);

  List<McpServer> get _availableServers => widget.servers
      .where(
        (server) =>
            _isHealthy(server) && !widget.selectedServerIds.contains(server.id),
      )
      .toList(growable: false);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    if (widget.isLoading) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (widget.servers.isEmpty) {
      return Text(
        strings.noMcpServers,
        key: const ValueKey<String>('bot-mcp-empty'),
        style:
            widget.embedded
                ? DesktopThemeTokens.bodyStyle(
                  context,
                )?.copyWith(color: DesktopThemeTokens.mutedText(context))
                : Theme.of(context).textTheme.bodyMedium,
      );
    }

    final addedServers = _addedServers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.mcpServersDescription,
                style:
                    widget.embedded
                        ? DesktopThemeTokens.metaStyle(context)
                        : Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(width: 12),
            _buildAddButton(context),
          ],
        ),
        const SizedBox(height: 10),
        if (addedServers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.noBotMcpServersAdded,
                  key: const ValueKey<String>('bot-mcp-none-added'),
                  style:
                      widget.embedded
                          ? ShadTheme.of(context).textTheme.small
                          : Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  strings.noBotMcpServersAddedDescription,
                  style:
                      widget.embedded
                          ? DesktopThemeTokens.metaStyle(context)
                          : Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          )
        else
          for (var index = 0; index < addedServers.length; index++) ...[
            _buildServerRow(context, addedServers[index]),
            if (index != addedServers.length - 1)
              if (widget.embedded)
                const ShadSeparator.horizontal()
              else
                const Divider(height: 1),
          ],
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final strings = S.of(context);
    final canAdd = _availableServers.isNotEmpty;
    if (widget.embedded) {
      final button = ShadButton.outline(
        key: const ValueKey<String>('add-bot-mcp-server'),
        size: ShadButtonSize.sm,
        width: 0,
        enabled: canAdd,
        onPressed: _showAddServerDialog,
        leading: const Icon(LucideIcons.plus, size: 15),
        child: Text(strings.addMcpServer),
      );
      if (canAdd) return button;
      return ShadTooltip(
        builder: (context) => Text(strings.noAvailableMcpServers),
        child: button,
      );
    }
    return Tooltip(
      message: canAdd ? strings.addMcpServer : strings.noAvailableMcpServers,
      child: OutlinedButton.icon(
        key: const ValueKey<String>('add-bot-mcp-server'),
        onPressed: canAdd ? _showAddServerDialog : null,
        icon: const Icon(Icons.add_rounded, size: 17),
        label: Text(strings.addMcpServer),
      ),
    );
  }

  Widget _buildServerRow(BuildContext context, McpServer server) {
    final strings = S.of(context);
    final enabled = !widget.disabledServerIds.contains(server.id);
    final canChange = _isHealthy(server) || enabled;
    final switchWidget =
        widget.embedded
            ? ShadSwitch(
              key: ValueKey<String>('bot-mcp-server-toggle-${server.id}'),
              value: enabled,
              enabled: canChange,
              onChanged: (value) => _setEnabled(server.id, value),
              label: Text(
                enabled ? strings.skillEnabled : strings.skillDisabled,
              ),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(enabled ? strings.skillEnabled : strings.skillDisabled),
                Switch(
                  key: ValueKey<String>('bot-mcp-server-toggle-${server.id}'),
                  value: enabled,
                  onChanged:
                      canChange
                          ? (value) => _setEnabled(server.id, value)
                          : null,
                ),
              ],
            );
    final removeButton =
        widget.embedded
            ? ShadTooltip(
              builder: (context) => Text(strings.removeMcpServer),
              child: ShadIconButton.ghost(
                key: ValueKey<String>('remove-bot-mcp-server-${server.id}'),
                width: 30,
                height: 30,
                padding: EdgeInsets.zero,
                iconSize: 16,
                onPressed: () => _remove(server.id),
                icon: const Icon(LucideIcons.trash2),
              ),
            )
            : IconButton(
              key: ValueKey<String>('remove-bot-mcp-server-${server.id}'),
              tooltip: strings.removeMcpServer,
              visualDensity: VisualDensity.compact,
              onPressed: () => _remove(server.id),
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
            );

    return Padding(
      key: ValueKey<String>('bot-mcp-server-${server.id}'),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  server.name,
                  style:
                      widget.embedded
                          ? ShadTheme.of(context).textTheme.small
                          : Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  _serverSummary(context, server),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      widget.embedded
                          ? DesktopThemeTokens.metaStyle(context)
                          : Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          switchWidget,
          const SizedBox(width: 8),
          removeButton,
        ],
      ),
    );
  }

  Future<void> _showAddServerDialog() async {
    if (_availableServers.isEmpty) return;
    _searchController.clear();
    if (widget.embedded) {
      await showShadDialog<void>(
        context: context,
        builder:
            (dialogContext) => StatefulBuilder(
              builder:
                  (dialogContext, refresh) => ShadDialog(
                    title: Text(S.of(context).addMcpServer),
                    description: Text(S.of(context).mcpServersDescription),
                    constraints: const BoxConstraints(maxWidth: 620),
                    actions: [
                      ShadButton.outline(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(S.of(context).cancel),
                      ),
                    ],
                    child: _buildAvailableServers(
                      dialogContext,
                      embedded: true,
                      refresh: refresh,
                    ),
                  ),
            ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (dialogContext, refresh) => AlertDialog(
                  title: Text(S.of(context).addMcpServer),
                  content: SizedBox(
                    width: 520,
                    child: _buildAvailableServers(
                      dialogContext,
                      embedded: false,
                      refresh: refresh,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(S.of(context).cancel),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildAvailableServers(
    BuildContext dialogContext, {
    required bool embedded,
    required StateSetter refresh,
  }) {
    final strings = S.of(context);
    final query = _searchController.text.trim().toLowerCase();
    final servers = _availableServers
        .where(
          (server) =>
              query.isEmpty ||
              server.name.toLowerCase().contains(query) ||
              server.namespace.toLowerCase().contains(query),
        )
        .toList(growable: false);
    final searchField =
        embedded
            ? StarsSearchField(
              key: const ValueKey<String>('bot-mcp-server-search-field'),
              hintText: strings.searchMcpServers,
              semanticLabel: strings.searchMcpServers,
              controller: _searchController,
              autofocus: true,
              onChanged: (_) => refresh(() {}),
            )
            : TextField(
              key: const ValueKey<String>('bot-mcp-server-search-field'),
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: strings.searchMcpServers,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: (_) => refresh(() {}),
            );

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (servers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        strings.noMatchingMcpServers,
                        textAlign: TextAlign.center,
                        style:
                            embedded
                                ? DesktopThemeTokens.metaStyle(context)
                                : Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  for (var index = 0; index < servers.length; index++) ...[
                    _buildAvailableServerRow(
                      dialogContext,
                      servers[index],
                      embedded: embedded,
                    ),
                    if (index != servers.length - 1)
                      if (embedded)
                        const ShadSeparator.horizontal()
                      else
                        const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableServerRow(
    BuildContext dialogContext,
    McpServer server, {
    required bool embedded,
  }) {
    final strings = S.of(context);
    final addButton =
        embedded
            ? ShadButton(
              key: ValueKey<String>('select-bot-mcp-server-${server.id}'),
              size: ShadButtonSize.sm,
              width: 0,
              onPressed: () => _add(dialogContext, server.id),
              leading: const Icon(LucideIcons.plus, size: 14),
              child: Text(strings.addMcpServer),
            )
            : FilledButton.tonalIcon(
              key: ValueKey<String>('select-bot-mcp-server-${server.id}'),
              onPressed: () => _add(dialogContext, server.id),
              icon: const Icon(Icons.add_rounded, size: 17),
              label: Text(strings.addMcpServer),
            );
    return Padding(
      key: ValueKey<String>('available-bot-mcp-server-${server.id}'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  server.name,
                  style:
                      embedded
                          ? ShadTheme.of(context).textTheme.small
                          : Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  _serverSummary(context, server),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      embedded
                          ? DesktopThemeTokens.metaStyle(context)
                          : Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          addButton,
        ],
      ),
    );
  }

  void _add(BuildContext dialogContext, String serverId) {
    final selected = Set<String>.of(widget.selectedServerIds)..add(serverId);
    final disabled = Set<String>.of(widget.disabledServerIds)..remove(serverId);
    _notify(selected, disabled);
    Navigator.of(dialogContext).pop();
  }

  void _remove(String serverId) {
    final selected = Set<String>.of(widget.selectedServerIds)..remove(serverId);
    final disabled = Set<String>.of(widget.disabledServerIds)..remove(serverId);
    _notify(selected, disabled);
  }

  void _setEnabled(String serverId, bool enabled) {
    final disabled = Set<String>.of(widget.disabledServerIds);
    if (enabled) {
      disabled.remove(serverId);
    } else {
      disabled.add(serverId);
    }
    _notify(Set<String>.of(widget.selectedServerIds), disabled);
  }

  void _notify(Set<String> selected, Set<String> disabled) {
    widget.onChanged(
      Set<String>.unmodifiable(selected),
      Set<String>.unmodifiable(disabled),
    );
  }

  bool _isHealthy(McpServer server) =>
      server.enabled && server.status == McpConnectionStatus.connected;

  String _serverSummary(BuildContext context, McpServer server) {
    final strings = S.of(context);
    final status = switch (server.status) {
      McpConnectionStatus.connected => strings.mcpConnected,
      McpConnectionStatus.connecting => strings.mcpConnecting,
      McpConnectionStatus.authorizationRequired =>
        strings.mcpAuthorizationRequired,
      McpConnectionStatus.error => strings.mcpConnectionError,
      McpConnectionStatus.disconnected => strings.mcpDisconnected,
    };
    final location = switch (server.transportType) {
      McpTransportType.streamableHttp => server.endpoint.toString(),
      McpTransportType.stdio => ([
        server.command,
        ...server.arguments,
      ].where((item) => item.isNotEmpty)).join(' '),
    };
    return '$status · $location';
  }
}
