import 'package:flutter/material.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/utils/theme.dart';

/// Selects globally configured MCP servers that one bot may expose to its
/// model. Tool-level enablement remains controlled by the MCP catalog.
class BotMcpServerPicker extends StatelessWidget {
  const BotMcpServerPicker({
    super.key,
    required this.servers,
    required this.selectedServerIds,
    required this.onChanged,
    this.isLoading = false,
    this.embedded = false,
  });

  final List<McpServer> servers;
  final Set<String> selectedServerIds;
  final ValueChanged<Set<String>> onChanged;
  final bool isLoading;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    if (isLoading) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.mcpServersDescription,
          style:
              embedded
                  ? DesktopThemeTokens.metaStyle(context)
                  : Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        if (servers.isEmpty)
          Text(
            strings.noMcpServers,
            key: const ValueKey<String>('bot-mcp-empty'),
            style:
                embedded
                    ? DesktopThemeTokens.bodyStyle(
                      context,
                    )?.copyWith(color: DesktopThemeTokens.mutedText(context))
                    : Theme.of(context).textTheme.bodyMedium,
          )
        else
          for (final server in servers)
            Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                key: ValueKey<String>('bot-mcp-server-${server.id}'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                value: selectedServerIds.contains(server.id),
                enabled:
                    server.enabled || selectedServerIds.contains(server.id),
                onChanged: (selected) => _toggle(server.id, selected == true),
                title: Text(server.name),
                subtitle: Text(
                  _serverSummary(server),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
      ],
    );
  }

  void _toggle(String serverId, bool selected) {
    final next = Set<String>.of(selectedServerIds);
    if (selected) {
      next.add(serverId);
    } else {
      next.remove(serverId);
    }
    onChanged(Set<String>.unmodifiable(next));
  }

  String _serverSummary(McpServer server) {
    final location = switch (server.transportType) {
      McpTransportType.streamableHttp => server.endpoint.toString(),
      McpTransportType.stdio => ([
        server.command,
        ...server.arguments,
      ].where((item) => item.isNotEmpty)).join(' '),
    };
    return '${server.status.name} · $location';
  }
}
