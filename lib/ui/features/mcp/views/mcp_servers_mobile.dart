part of 'mcp_servers_page.dart';

class _ServerCard extends StatefulWidget {
  const _ServerCard({
    required this.server,
    required this.tools,
    required this.busy,
    required this.onEdit,
    required this.onRefresh,
    required this.onDelete,
  });

  final McpServer server;
  final List<McpToolDescriptor> tools;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;

  @override
  State<_ServerCard> createState() => _ServerCardState();
}

class _ServerCardState extends State<_ServerCard> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _query = '';

  McpServer get server => widget.server;
  List<McpToolDescriptor> get tools => widget.tools;
  bool get busy => widget.busy;
  VoidCallback get onEdit => widget.onEdit;
  VoidCallback get onRefresh => widget.onRefresh;
  VoidCallback get onDelete => widget.onDelete;

  @override
  void didUpdateWidget(covariant _ServerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.server.id != widget.server.id) {
      _searchController.clear();
      _query = '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredTools = filterMcpTools(tools, _query);
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
        title: Text(
          server.name,
          key: ValueKey<String>('mobile-mcp-server-title-${server.id}'),
          style: StarsDesktopThemeSpec.pageTitleStyle(context),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mcpConnectionSummary(server),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${_mcpStatusLabel(context, server.status)} · '
              '${tools.length} ${S.of(context).mcpTools}',
              style: TextStyle(
                color:
                    server.status == McpConnectionStatus.error
                        ? colorScheme.error
                        : null,
              ),
            ),
          ],
        ),
        trailing: Icon(_mcpStatusIcon(server.status)),
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
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: StarsSearchField(
                key: ValueKey<String>('mobile-mcp-tool-search-${server.id}'),
                hintText: S.of(context).searchMcpTools,
                semanticLabel: S.of(context).searchMcpTools,
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _search,
                suffixIcon:
                    _query.isEmpty
                        ? null
                        : IconButton(
                          key: ValueKey<String>(
                            'clear-mobile-mcp-tool-search-${server.id}',
                          ),
                          tooltip: S.of(context).clearSearch,
                          onPressed: _clearSearch,
                          icon: const Icon(LucideIcons.x, size: 16),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
              ),
            ),
            if (filteredTools.isEmpty)
              StarsSearchEmptyState(
                key: ValueKey<String>(
                  'mobile-mcp-tool-search-empty-${server.id}',
                ),
                message: S.of(context).noMatchingMcpTools,
                clearLabel: S.of(context).clearSearch,
                onClear: _clearSearch,
              )
            else
              for (final tool in filteredTools)
                ListTile(
                  title: Text(
                    tool.title.isEmpty ? tool.remoteName : tool.title,
                  ),
                  subtitle: Text(
                    tool.isSupportedByClient
                        ? '${tool.canonicalName}\n${tool.description}'
                        : S.of(context).mcpToolSchemaUnsupported,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    tool.annotations.destructiveHint
                        ? Icons.warning_amber_rounded
                        : tool.annotations.readOnlyHint
                        ? Icons.visibility_outlined
                        : Icons.edit_outlined,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
