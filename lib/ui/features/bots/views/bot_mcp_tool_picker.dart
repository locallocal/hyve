import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/utils/theme.dart';

/// Configures which discovered MCP Tools one existing agent may use.
class BotMcpToolPicker extends StatelessWidget {
  const BotMcpToolPicker({
    super.key,
    required this.servers,
    required this.toolsByServer,
    required this.configurations,
    required this.onChanged,
    this.isLoading = false,
    this.embedded = false,
    this.readOnly = false,
  });

  final List<McpServer> servers;
  final Map<String, List<McpToolDescriptor>> toolsByServer;
  final Set<McpToolConfiguration> configurations;
  final ValueChanged<Set<McpToolConfiguration>> onChanged;
  final bool isLoading;
  final bool embedded;
  final bool readOnly;

  Map<String, McpToolConfiguration> get _configuredByKey => {
    for (final configuration in configurations)
      configuration.key: configuration,
  };

  List<(McpServer, List<McpToolDescriptor>)> get _catalogs => [
    for (final server in servers)
      if (server.status == McpConnectionStatus.connected)
        (
          server,
          (toolsByServer[server.id] ?? const <McpToolDescriptor>[])
              .where((tool) => tool.isSupportedByClient)
              .toList(growable: false),
        ),
  ].where((entry) => entry.$2.isNotEmpty).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    final catalogs = _catalogs;
    if (catalogs.isEmpty) {
      return Text(
        S.of(context).noBotMcpToolsAvailable,
        key: const ValueKey<String>('bot-mcp-tools-empty'),
        style:
            embedded
                ? DesktopThemeTokens.metaStyle(context)
                : Theme.of(context).textTheme.bodyMedium,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.of(context).botMcpToolsDescription,
          style:
              embedded
                  ? DesktopThemeTokens.metaStyle(context)
                  : Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        for (
          var serverIndex = 0;
          serverIndex < catalogs.length;
          serverIndex++
        ) ...[
          _buildServerCatalog(
            context,
            catalogs[serverIndex].$1,
            catalogs[serverIndex].$2,
          ),
          if (serverIndex != catalogs.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildServerCatalog(
    BuildContext context,
    McpServer server,
    List<McpToolDescriptor> tools,
  ) {
    return Column(
      key: ValueKey<String>('bot-mcp-server-${server.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          server.name,
          style:
              embedded
                  ? ShadTheme.of(
                    context,
                  ).textTheme.small.copyWith(fontWeight: FontWeight.w600)
                  : Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        for (var index = 0; index < tools.length; index++) ...[
          _buildToolRow(context, tools[index]),
          if (index != tools.length - 1)
            embedded
                ? const ShadSeparator.horizontal()
                : const Divider(height: 1),
        ],
      ],
    );
  }

  Widget _buildToolRow(BuildContext context, McpToolDescriptor tool) {
    final key = McpToolConfiguration.keyFor(tool.serverId, tool.remoteName);
    final configuration = _configuredByKey[key];
    final enabled = configuration != null;
    final title = tool.title.isEmpty ? tool.remoteName : tool.title;
    final enableSwitch =
        embedded
            ? ShadSwitch(
              key: ValueKey<String>(
                'bot-mcp-tool-toggle-${tool.serverId}-${tool.remoteName}',
              ),
              value: enabled,
              enabled: !readOnly,
              onChanged: readOnly ? null : (value) => _setEnabled(tool, value),
            )
            : Switch(
              key: ValueKey<String>(
                'bot-mcp-tool-toggle-${tool.serverId}-${tool.remoteName}',
              ),
              value: enabled,
              onChanged: readOnly ? null : (value) => _setEnabled(tool, value),
            );
    final approvalSwitch =
        embedded
            ? ShadSwitch(
              key: ValueKey<String>(
                'bot-mcp-tool-no-approval-${tool.serverId}-${tool.remoteName}',
              ),
              value: configuration?.requiresApproval == false,
              enabled: enabled && !readOnly,
              onChanged:
                  readOnly ? null : (value) => _setApprovalExempt(tool, value),
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
                      enabled && !readOnly
                          ? (value) => _setApprovalExempt(tool, value)
                          : null,
                ),
              ],
            );
    return Padding(
      key: ValueKey<String>('bot-mcp-tool-${tool.serverId}-${tool.remoteName}'),
      padding: const EdgeInsets.symmetric(vertical: 9),
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
                      embedded
                          ? DesktopThemeTokens.metaStyle(context)
                          : Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
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

  void _setEnabled(McpToolDescriptor tool, bool enabled) {
    if (readOnly) return;
    final next = {
      for (final configuration in configurations)
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
    onChanged(Set<McpToolConfiguration>.unmodifiable(next.values));
  }

  void _setApprovalExempt(McpToolDescriptor tool, bool exempt) {
    if (readOnly) return;
    final next = {
      for (final configuration in configurations)
        configuration.key: configuration,
    };
    final key = McpToolConfiguration.keyFor(tool.serverId, tool.remoteName);
    final current = next[key];
    if (current == null) return;
    next[key] = current.copyWith(requiresApproval: !exempt);
    onChanged(Set<McpToolConfiguration>.unmodifiable(next.values));
  }
}
