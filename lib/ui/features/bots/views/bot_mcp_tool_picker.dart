import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/utils/theme.dart';

typedef BotMcpCatalog =
    ({
      List<McpServer> servers,
      Map<String, List<McpToolDescriptor>> toolsByServer,
    });

/// Selects MCP Servers for a Bot and configures their individual Tools.
class BotMcpToolPicker extends StatefulWidget {
  const BotMcpToolPicker({
    super.key,
    required this.servers,
    required this.toolsByServer,
    required this.selectedServerIds,
    required this.configurations,
    required this.onSelectedServerIdsChanged,
    required this.onChanged,
    this.isLoading = false,
    this.embedded = false,
    this.readOnly = false,
  });

  final List<McpServer> servers;
  final Map<String, List<McpToolDescriptor>> toolsByServer;
  final Set<String> selectedServerIds;
  final Set<McpToolConfiguration> configurations;
  final ValueChanged<Set<String>> onSelectedServerIdsChanged;
  final ValueChanged<Set<McpToolConfiguration>> onChanged;
  final bool isLoading;
  final bool embedded;
  final bool readOnly;

  @override
  State<BotMcpToolPicker> createState() => _BotMcpToolPickerState();
}

class _BotMcpToolPickerState extends State<BotMcpToolPicker> {
  static const _toolListMaxHeight = 360.0;

  late Set<McpToolConfiguration> _configurations;

  @override
  void initState() {
    super.initState();
    _configurations = widget.configurations;
  }

  @override
  void didUpdateWidget(covariant BotMcpToolPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _configurations = widget.configurations;
  }

  Map<String, McpServer> get _serversById => {
    for (final server in widget.servers) server.id: server,
  };

  Map<String, McpToolConfiguration> get _configuredByKey => {
    for (final configuration in _configurations)
      configuration.key: configuration,
  };

  List<McpServer> get _availableServers {
    final available =
        widget.servers
            .where(
              (server) =>
                  server.status == McpConnectionStatus.connected &&
                  !widget.selectedServerIds.contains(server.id),
            )
            .toList();
    available.sort(
      (left, right) =>
          left.name.toLowerCase().compareTo(right.name.toLowerCase()),
    );
    return available;
  }

  List<String> get _selectedServerIds {
    final ids = widget.selectedServerIds.toList();
    ids.sort((left, right) {
      final leftName = _serversById[left]?.name ?? left;
      final rightName = _serversById[right]?.name ?? right;
      return leftName.toLowerCase().compareTo(rightName.toLowerCase());
    });
    return ids;
  }

  List<McpToolDescriptor> _toolsFor(String serverId) =>
      (widget.toolsByServer[serverId] ?? const <McpToolDescriptor>[])
          .where((tool) => tool.isSupportedByClient)
          .toList(growable: false);

  int _enabledToolCount(String serverId) =>
      _configurations
          .where((configuration) => configuration.serverId == serverId)
          .length;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final strings = S.of(context);
    final availableServers = _availableServers;
    final addButton =
        widget.embedded
            ? ShadButton.outline(
              key: const ValueKey<String>('add-bot-mcp-server'),
              size: ShadButtonSize.sm,
              width: 0,
              enabled: !widget.readOnly && availableServers.isNotEmpty,
              onPressed:
                  widget.readOnly || availableServers.isEmpty
                      ? null
                      : _showAddServerDialog,
              leading: const Icon(LucideIcons.plus, size: 15),
              child: Text(strings.addMcpServer),
            )
            : OutlinedButton.icon(
              key: const ValueKey<String>('add-bot-mcp-server'),
              onPressed:
                  widget.readOnly || availableServers.isEmpty
                      ? null
                      : _showAddServerDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(strings.addMcpServer),
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.botMcpToolsDescription,
                style:
                    widget.embedded
                        ? DesktopThemeTokens.metaStyle(context)
                        : Theme.of(context).textTheme.bodySmall,
              ),
            ),
            if (!widget.readOnly) ...[const SizedBox(width: 12), addButton],
          ],
        ),
        const SizedBox(height: 10),
        if (_selectedServerIds.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.noMcpServers,
                  style:
                      widget.embedded
                          ? ShadTheme.of(context).textTheme.small
                          : Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  strings.noMcpServersDescription,
                  style:
                      widget.embedded
                          ? DesktopThemeTokens.metaStyle(context)
                          : Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          )
        else
          for (var index = 0; index < _selectedServerIds.length; index++) ...[
            _buildSelectedServerRow(_selectedServerIds[index]),
            if (index != _selectedServerIds.length - 1)
              widget.embedded
                  ? const ShadSeparator.horizontal()
                  : const Divider(height: 1),
          ],
      ],
    );
  }

  Widget _buildSelectedServerRow(String serverId) {
    final server = _serversById[serverId];
    final tools = _toolsFor(serverId);
    final enabledCount = _enabledToolCount(serverId);
    final strings = S.of(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  server?.name ?? serverId,
                  style:
                      widget.embedded
                          ? ShadTheme.of(context).textTheme.small
                          : Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  '${server?.namespace ?? serverId} · '
                  '$enabledCount/${tools.length} ${strings.mcpTools}',
                  style:
                      widget.embedded
                          ? DesktopThemeTokens.metaStyle(context)
                          : Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(LucideIcons.chevronRight, size: 16),
          const SizedBox(width: 8),
          if (!widget.readOnly)
            widget.embedded
                ? ShadTooltip(
                  builder: (context) => Text(strings.removeMcpServer),
                  child: ShadIconButton.ghost(
                    key: ValueKey<String>('remove-bot-mcp-server-$serverId'),
                    width: 30,
                    height: 30,
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    onPressed: () => _removeServer(serverId),
                    icon: const Icon(LucideIcons.trash2),
                  ),
                )
                : IconButton(
                  key: ValueKey<String>('remove-bot-mcp-server-$serverId'),
                  tooltip: strings.removeMcpServer,
                  onPressed: () => _removeServer(serverId),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
        ],
      ),
    );

    return Semantics(
      button: true,
      label: server?.name ?? serverId,
      child: InkWell(
        key: ValueKey<String>('bot-mcp-server-$serverId'),
        onTap: () => _showToolDialog(serverId),
        borderRadius: BorderRadius.circular(8),
        child: content,
      ),
    );
  }

  Future<void> _showAddServerDialog() async {
    if (widget.readOnly || _availableServers.isEmpty) return;
    if (widget.embedded) {
      await showShadDialog<void>(
        context: context,
        builder:
            (dialogContext) => ShadDialog(
              title: Text(S.of(context).addMcpServer),
              description: Text(S.of(context).botMcpToolsDescription),
              constraints: const BoxConstraints(maxWidth: 620),
              actions: [
                ShadButton.outline(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(S.of(context).cancel),
                ),
              ],
              child: _buildAvailableServerList(dialogContext),
            ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(S.of(context).addMcpServer),
            content: SizedBox(
              width: 520,
              child: _buildAvailableServerList(dialogContext),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(S.of(context).cancel),
              ),
            ],
          ),
    );
  }

  Widget _buildAvailableServerList(BuildContext dialogContext) {
    final strings = S.of(context);
    final availableServers = _availableServers;
    if (availableServers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          strings.noMatchingMcpServers,
          textAlign: TextAlign.center,
          style:
              widget.embedded
                  ? DesktopThemeTokens.metaStyle(context)
                  : Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < availableServers.length; index++) ...[
            Padding(
              key: ValueKey<String>(
                'available-bot-mcp-server-${availableServers[index].id}',
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          availableServers[index].name,
                          style:
                              widget.embedded
                                  ? ShadTheme.of(context).textTheme.small
                                  : Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${availableServers[index].namespace} · '
                          '${_toolsFor(availableServers[index].id).length} '
                          '${strings.mcpTools}',
                          style:
                              widget.embedded
                                  ? DesktopThemeTokens.metaStyle(context)
                                  : Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (widget.embedded)
                    ShadButton(
                      key: ValueKey<String>(
                        'select-bot-mcp-server-${availableServers[index].id}',
                      ),
                      size: ShadButtonSize.sm,
                      width: 0,
                      onPressed:
                          () => _addServer(
                            dialogContext,
                            availableServers[index].id,
                          ),
                      leading: const Icon(LucideIcons.plus, size: 14),
                      child: Text(strings.addMcpServer),
                    )
                  else
                    FilledButton.tonalIcon(
                      key: ValueKey<String>(
                        'select-bot-mcp-server-${availableServers[index].id}',
                      ),
                      onPressed:
                          () => _addServer(
                            dialogContext,
                            availableServers[index].id,
                          ),
                      icon: const Icon(Icons.add_rounded, size: 17),
                      label: Text(strings.addMcpServer),
                    ),
                ],
              ),
            ),
            if (index != availableServers.length - 1)
              widget.embedded
                  ? const ShadSeparator.horizontal()
                  : const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Future<void> _showToolDialog(String serverId) async {
    final server = _serversById[serverId];
    final tools = _toolsFor(serverId);
    final title = server?.name ?? serverId;
    final description =
        '${server?.namespace ?? serverId} · ${tools.length} ${S.of(context).mcpTools}';
    if (widget.embedded) {
      await showShadDialog<void>(
        context: context,
        builder:
            (dialogContext) => StatefulBuilder(
              builder:
                  (dialogContext, refresh) => ShadDialog(
                    key: ValueKey<String>('bot-mcp-tools-dialog-$serverId'),
                    title: Text(title),
                    description: Text(description),
                    constraints: const BoxConstraints(maxWidth: 680),
                    actions: [
                      ShadButton.outline(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          MaterialLocalizations.of(context).closeButtonLabel,
                        ),
                      ),
                    ],
                    child: _buildToolListViewport(tools, refresh: refresh),
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
                  key: ValueKey<String>('bot-mcp-tools-dialog-$serverId'),
                  title: Text(title),
                  content: SizedBox(
                    width: 560,
                    child: _buildToolListViewport(tools, refresh: refresh),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        MaterialLocalizations.of(context).closeButtonLabel,
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildToolListViewport(
    List<McpToolDescriptor> tools, {
    required StateSetter refresh,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: _toolListMaxHeight),
      child: SingleChildScrollView(
        child: _buildToolList(tools, refresh: refresh),
      ),
    );
  }

  Widget _buildToolList(
    List<McpToolDescriptor> tools, {
    required StateSetter refresh,
  }) {
    if (tools.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          S.of(context).noMcpToolsDiscovered,
          textAlign: TextAlign.center,
          style:
              widget.embedded
                  ? DesktopThemeTokens.metaStyle(context)
                  : Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < tools.length; index++) ...[
            _buildToolRow(tools[index], refresh: refresh),
            if (index != tools.length - 1)
              widget.embedded
                  ? const ShadSeparator.horizontal()
                  : const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Widget _buildToolRow(McpToolDescriptor tool, {required StateSetter refresh}) {
    final key = McpToolConfiguration.keyFor(tool.serverId, tool.remoteName);
    final configuration = _configuredByKey[key];
    final enabled = configuration != null;
    final title = tool.title.isEmpty ? tool.remoteName : tool.title;
    final enableSwitch =
        widget.embedded
            ? ShadSwitch(
              key: ValueKey<String>(
                'bot-mcp-tool-toggle-${tool.serverId}-${tool.remoteName}',
              ),
              value: enabled,
              enabled: !widget.readOnly,
              onChanged:
                  widget.readOnly
                      ? null
                      : (value) {
                        _setEnabled(tool, value);
                        refresh(() {});
                      },
            )
            : Switch(
              key: ValueKey<String>(
                'bot-mcp-tool-toggle-${tool.serverId}-${tool.remoteName}',
              ),
              value: enabled,
              onChanged:
                  widget.readOnly
                      ? null
                      : (value) {
                        _setEnabled(tool, value);
                        refresh(() {});
                      },
            );
    final approvalSwitch =
        widget.embedded
            ? ShadSwitch(
              key: ValueKey<String>(
                'bot-mcp-tool-no-approval-${tool.serverId}-${tool.remoteName}',
              ),
              value: configuration?.requiresApproval == false,
              enabled: enabled && !widget.readOnly,
              onChanged:
                  enabled && !widget.readOnly
                      ? (value) {
                        _setApprovalExempt(tool, value);
                        refresh(() {});
                      }
                      : null,
              label: Text(S.of(context).mcpNoApprovalRequired),
            )
            : Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(S.of(context).mcpNoApprovalRequired),
                Switch(
                  key: ValueKey<String>(
                    'bot-mcp-tool-no-approval-${tool.serverId}-${tool.remoteName}',
                  ),
                  value: configuration?.requiresApproval == false,
                  onChanged:
                      enabled && !widget.readOnly
                          ? (value) {
                            _setApprovalExempt(tool, value);
                            refresh(() {});
                          }
                          : null,
                ),
              ],
            );
    return Padding(
      key: ValueKey<String>('bot-mcp-tool-${tool.serverId}-${tool.remoteName}'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            tool.annotations.destructiveHint
                ? Icons.warning_amber_rounded
                : tool.annotations.readOnlyHint
                ? Icons.visibility_outlined
                : Icons.edit_outlined,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 2),
                Text(
                  tool.description.isEmpty
                      ? tool.canonicalName
                      : tool.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      widget.embedded
                          ? DesktopThemeTokens.metaStyle(context)
                          : Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: approvalSwitch,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          enableSwitch,
        ],
      ),
    );
  }

  void _addServer(BuildContext dialogContext, String serverId) {
    if (widget.readOnly) return;
    widget.onSelectedServerIdsChanged(
      Set<String>.unmodifiable({...widget.selectedServerIds, serverId}),
    );
    Navigator.of(dialogContext).pop();
  }

  void _removeServer(String serverId) {
    if (widget.readOnly) return;
    widget.onSelectedServerIdsChanged(
      Set<String>.unmodifiable(
        widget.selectedServerIds.where((id) => id != serverId),
      ),
    );
    _configurations = Set<McpToolConfiguration>.unmodifiable(
      _configurations.where(
        (configuration) => configuration.serverId != serverId,
      ),
    );
    widget.onChanged(_configurations);
  }

  void _setEnabled(McpToolDescriptor tool, bool enabled) {
    if (widget.readOnly) return;
    final next = {
      for (final configuration in _configurations)
        configuration.key: configuration,
    };
    final key = McpToolConfiguration.keyFor(tool.serverId, tool.remoteName);
    if (enabled) {
      next[key] = McpToolConfiguration(
        serverId: tool.serverId,
        remoteName: tool.remoteName,
      );
    } else {
      next.remove(key);
    }
    _configurations = Set<McpToolConfiguration>.unmodifiable(next.values);
    widget.onChanged(_configurations);
  }

  void _setApprovalExempt(McpToolDescriptor tool, bool exempt) {
    if (widget.readOnly) return;
    final next = {
      for (final configuration in _configurations)
        configuration.key: configuration,
    };
    final key = McpToolConfiguration.keyFor(tool.serverId, tool.remoteName);
    final current = next[key];
    if (current == null) return;
    next[key] = current.copyWith(requiresApproval: !exempt);
    _configurations = Set<McpToolConfiguration>.unmodifiable(next.values);
    widget.onChanged(_configurations);
  }
}
