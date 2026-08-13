part of 'bot_mcp_tool_picker.dart';

class _BotMcpToolListViewport extends StatefulWidget {
  const _BotMcpToolListViewport({
    required this.serverId,
    required this.tools,
    required this.embedded,
    required this.readOnly,
    required this.buildBatchActions,
    required this.buildToolRow,
  });

  final String serverId;
  final List<McpToolDescriptor> tools;
  final bool embedded;
  final bool readOnly;
  final _BotMcpToolBatchActionsBuilder buildBatchActions;
  final _BotMcpToolRowBuilder buildToolRow;

  @override
  State<_BotMcpToolListViewport> createState() =>
      _BotMcpToolListViewportState();
}

class _BotMcpToolListViewportState extends State<_BotMcpToolListViewport> {
  static const _toolListMaxHeight = 360.0;

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _query = '';

  @override
  void didUpdateWidget(covariant _BotMcpToolListViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serverId != widget.serverId) {
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
    final strings = S.of(context);
    final tools = widget.tools;
    if (tools.isEmpty) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _toolListMaxHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            strings.noMcpToolsDiscovered,
            textAlign: TextAlign.center,
            style:
                widget.embedded
                    ? StarsDesktopThemeSpec.metaStyle(context)
                    : Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    final filteredTools = filterMcpTools(tools, _query);
    return SizedBox(
      height: _toolListMaxHeight,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StarsSearchField(
                key: ValueKey<String>('bot-mcp-tool-search-${widget.serverId}'),
                hintText: strings.searchMcpTools,
                semanticLabel: strings.searchMcpTools,
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _search,
                insetFocusRing: widget.embedded,
                suffixIcon:
                    _query.isEmpty
                        ? null
                        : StarsDesktopIconAction(
                          key: ValueKey<String>(
                            'clear-bot-mcp-tool-search-${widget.serverId}',
                          ),
                          icon: LucideIcons.x,
                          label: strings.clearSearch,
                          onPressed: _clearSearch,
                          iconSize: 16,
                        ),
              ),
              const SizedBox(height: 12),
              if (filteredTools.isEmpty)
                StarsSearchEmptyState(
                  key: ValueKey<String>(
                    'bot-mcp-tool-search-empty-${widget.serverId}',
                  ),
                  message: strings.noMatchingMcpTools,
                  clearLabel: strings.clearSearch,
                  onClear: _clearSearch,
                )
              else ...[
                if (!widget.readOnly) ...[
                  widget.buildBatchActions(tools, refresh: setState),
                  const SizedBox(height: 8),
                  widget.embedded
                      ? const ShadSeparator.horizontal()
                      : const Divider(height: 1),
                ],
                for (var index = 0; index < filteredTools.length; index++) ...[
                  widget.buildToolRow(filteredTools[index], refresh: setState),
                  if (index != filteredTools.length - 1)
                    widget.embedded
                        ? const ShadSeparator.horizontal()
                        : const Divider(height: 1),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
