part of 'desktop_layout.dart';

/// Project-specific actions hosted by the unified desktop toolbar.
class ProjectWorkspaceToolbarActions extends StatelessWidget {
  const ProjectWorkspaceToolbarActions({
    super.key,
    required this.onShowMembers,
    required this.onShowArtifacts,
    required this.onShowExecution,
  });

  final VoidCallback onShowMembers;
  final VoidCallback onShowArtifacts;
  final VoidCallback onShowExecution;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        HyveDesktopIconAction(
          key: const ValueKey<String>('project-members-button'),
          label: copy.members,
          onPressed: onShowMembers,
          icon: LucideIcons.bot,
        ),
        HyveDesktopIconAction(
          key: const ValueKey<String>('project-artifacts-button'),
          label: copy.artifacts,
          onPressed: onShowArtifacts,
          icon: LucideIcons.folderKanban,
        ),
        HyveDesktopIconAction(
          key: const ValueKey<String>('project-execution-button'),
          label: copy.execution,
          onPressed: onShowExecution,
          icon: LucideIcons.activity,
        ),
      ],
    );
  }
}

class _UnifiedDesktopToolbar extends StatelessWidget {
  final int currentIndex;
  final Bot? bot;
  final String projectName;
  final bool isChat;
  final bool compact;
  final bool sidebarVisible;
  final bool inspectorVisible;
  final bool inspectorAvailable;
  final VoidCallback onToggleSidebar;
  final VoidCallback? onToggleInspector;
  final VoidCallback? onCreateChat;
  final VoidCallback? onSearchRequested;
  final VoidCallback? onShowProjectMembers;
  final VoidCallback? onShowProjectArtifacts;
  final VoidCallback? onShowProjectExecution;

  const _UnifiedDesktopToolbar({
    required this.currentIndex,
    required this.bot,
    required this.projectName,
    required this.isChat,
    required this.compact,
    required this.sidebarVisible,
    required this.inspectorVisible,
    required this.inspectorAvailable,
    required this.onToggleSidebar,
    required this.onToggleInspector,
    required this.onCreateChat,
    required this.onSearchRequested,
    required this.onShowProjectMembers,
    required this.onShowProjectArtifacts,
    required this.onShowProjectExecution,
  });

  @override
  Widget build(BuildContext context) {
    final activeBot = bot;
    final title = switch (currentIndex) {
      0 =>
        projectName.trim().isNotEmpty
            ? projectName.trim()
            : activeBot?.name ??
                desktopProjectText(context, S.of(context).chats),
      1 => activeBot?.name ?? S.of(context).Bots,
      2 => S.of(context).skillLibrary,
      3 => S.of(context).mcpServers,
      _ => S.of(context).profile,
    };
    final summary =
        activeBot == null
            ? null
            : [
              activeBot.provider.trim(),
              activeBot.model.trim(),
            ].where((value) => value.isNotEmpty).join(' · ');

    return Container(
      key: const ValueKey<String>('desktop-unified-toolbar'),
      height: HyveDesktopThemeSpec.toolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: HyveDesktopThemeSpec.toolbarSurface(context),
        border: Border(
          bottom: BorderSide(
            width: 0,
            color: HyveDesktopThemeSpec.divider(context),
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child:
                !sidebarVisible
                    ? isChat
                        ? HyveDesktopIconAction(
                          key: const ValueKey<String>(
                            'desktop-toolbar-sidebar',
                          ),
                          label: S.of(context).showSidebar,
                          onPressed: onToggleSidebar,
                          icon: LucideIcons.panelLeftOpen,
                        )
                        : _DesktopToolbarIconAction(
                          key: const ValueKey<String>(
                            'desktop-toolbar-sidebar',
                          ),
                          tooltip: S.of(context).showSidebar,
                          onPressed: onToggleSidebar,
                          icon: const Icon(LucideIcons.panelLeft, size: 17),
                        )
                    : const SizedBox.shrink(),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HyveDesktopThemeSpec.toolbarTitleStyle(context),
                  ),
                ),
                if (!isChat && summary != null && summary.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: HyveDesktopThemeSpec.metaStyle(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child:
                isChat
                    ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (compact && onCreateChat != null)
                          HyveDesktopIconAction(
                            key: const ValueKey<String>(
                              'desktop-toolbar-new-chat',
                            ),
                            label: desktopProjectText(
                              context,
                              S.of(context).newChat,
                            ),
                            onPressed: onCreateChat,
                            icon: desktopProjectIcon,
                          ),
                        if (onShowProjectMembers != null &&
                            onShowProjectArtifacts != null &&
                            onShowProjectExecution != null)
                          ProjectWorkspaceToolbarActions(
                            onShowMembers: onShowProjectMembers!,
                            onShowArtifacts: onShowProjectArtifacts!,
                            onShowExecution: onShowProjectExecution!,
                          ),
                        if (inspectorAvailable)
                          HyveDesktopIconAction(
                            key: const ValueKey<String>(
                              'desktop-toolbar-inspector',
                            ),
                            label:
                                inspectorVisible
                                    ? S.of(context).hideInspector
                                    : S.of(context).showInspector,
                            onPressed: onToggleInspector,
                            selected: inspectorVisible,
                            variant:
                                inspectorVisible
                                    ? ShadButtonVariant.secondary
                                    : ShadButtonVariant.ghost,
                            icon:
                                inspectorVisible
                                    ? LucideIcons.panelRightClose
                                    : LucideIcons.panelRightOpen,
                          ),
                      ],
                    )
                    : DecoratedBox(
                      decoration: BoxDecoration(
                        color: HyveDesktopThemeSpec.controlFill(context),
                        borderRadius: HyveDesktopThemeSpec.controlRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (inspectorAvailable)
                            _DesktopToolbarIconAction(
                              key: const ValueKey<String>(
                                'desktop-toolbar-inspector',
                              ),
                              tooltip:
                                  inspectorVisible
                                      ? S.of(context).hideInspector
                                      : S.of(context).showInspector,
                              onPressed: onToggleInspector,
                              selected: inspectorVisible,
                              icon: Icon(
                                inspectorVisible
                                    ? LucideIcons.panelRightClose
                                    : LucideIcons.panelRightOpen,
                                size: 17,
                              ),
                            ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _DesktopToolbarIconAction extends StatefulWidget {
  final String tooltip;
  final VoidCallback? onPressed;
  final Widget icon;
  final bool selected;

  const _DesktopToolbarIconAction({
    super.key,
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.selected = false,
  });

  @override
  State<_DesktopToolbarIconAction> createState() =>
      _DesktopToolbarIconActionState();
}

class _DesktopToolbarIconActionState extends State<_DesktopToolbarIconAction> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      selected: widget.selected,
      label: widget.tooltip,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: ShadTooltip(
            focusNode: _focusNode,
            builder: (context) => Text(widget.tooltip),
            child: ShadIconButton.raw(
              variant:
                  widget.selected
                      ? ShadButtonVariant.secondary
                      : ShadButtonVariant.ghost,
              focusNode: _focusNode,
              width: 32,
              height: 32,
              iconSize: 18,
              enabled: widget.onPressed != null,
              onPressed: widget.onPressed,
              icon: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}
