import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/ui/features/bots/views/edit_bot.dart';
import 'package:hyve/ui/features/chat/views/chat.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/views/project_workspace_page.dart';
import 'package:hyve/utils/theme.dart';
import 'package:hyve/utils/utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

part 'desktop_layout_workspace.dart';
part 'desktop_layout_toolbar.dart';
part 'desktop_layout_components.dart';
part 'desktop_layout_shortcuts.dart';
part 'desktop_layout_overlays.dart';
part 'desktop_layout_resizing.dart';

enum _ChatOverlay { sidebar }

/// Adaptive desktop shell for macOS, Windows and Linux.
///
/// Native window controls remain owned by the host platform. This widget only
/// renders the application toolbar and the resizable content columns below it.
class DesktopLayout extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final List<Widget> pages;
  final String? selectedChatId;
  final Bot? selectedChatBot;
  final List<Bot> selectedChatBots;
  final bool selectedProjectUsesAgentRuntime;
  final String selectedProjectName;
  final Bot? selectedBot;
  final bool isEditingBot;
  final bool showExecutionStatus;
  final int selectedProfileSection;
  final ValueChanged<int>? onProfileSectionChanged;
  final VoidCallback? onCreateChat;
  final VoidCallback? onAddBot;
  final VoidCallback? onSearchRequested;
  final Future<void> Function(Bot) onBotUpdated;
  final Future<void> Function() onBotDeleted;
  final Future<String?> Function()? avatarPicker;

  const DesktopLayout({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
    required this.pages,
    this.selectedChatId,
    this.selectedChatBot,
    this.selectedChatBots = const <Bot>[],
    this.selectedProjectUsesAgentRuntime = false,
    this.selectedProjectName = '',
    this.selectedBot,
    this.isEditingBot = false,
    this.showExecutionStatus = true,
    this.selectedProfileSection = 0,
    this.onProfileSectionChanged,
    this.onCreateChat,
    this.onAddBot,
    this.onSearchRequested,
    required this.onBotUpdated,
    required this.onBotDeleted,
    this.avatarPicker,
  });

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  void _updateState(VoidCallback callback) => setState(callback);

  double _sidebarWidth = HyveDesktopThemeSpec.sidebarWidth;
  bool _sidebarVisible = true;
  bool _compactSidebarOpen = false;
  _ChatOverlay? _activeChatOverlay;
  NavigatorState? _chatOverlayNavigator;
  ModalRoute<dynamic>? _chatOverlayRoute;
  Completer<ModalRoute<dynamic>?>? _chatOverlayRouteReady;
  Future<void>? _chatOverlayClosed;
  Future<void> _chatOverlayTransition = Future<void>.value();
  int _chatOverlaySession = 0;
  bool _preserveChatOverlayIntent = false;
  bool _chatOverlayDismissScheduled = false;

  GlobalKey<ChatPageState>? _chatPageKey;
  final ProjectWorkspaceController _projectWorkspaceController =
      ProjectWorkspaceController();

  Bot? get _activeBot => switch (widget.currentIndex) {
    0 => widget.selectedChatBot,
    1 => widget.selectedBot,
    _ => null,
  };

  @override
  void didUpdateWidget(covariant DesktopLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    final chatChanged = oldWidget.selectedChatId != widget.selectedChatId;
    if (chatChanged) _chatPageKey = null;
    if (oldWidget.currentIndex == 0 && widget.currentIndex != 0) {
      _preserveChatOverlayIntent = false;
      unawaited(_dismissActiveChatOverlay());
    }
  }

  @override
  void dispose() {
    final navigator = _chatOverlayNavigator;
    final route = _chatOverlayRoute;
    final routeReady = _chatOverlayRouteReady;
    _chatOverlaySession += 1;
    if (route != null && route.isActive) {
      navigator?.removeRoute(route);
    } else if (routeReady != null && !routeReady.isCompleted) {
      unawaited(
        routeReady.future.then((pendingRoute) {
          if (pendingRoute != null && pendingRoute.isActive) {
            navigator?.removeRoute(pendingRoute);
          }
        }),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shell = LayoutBuilder(
      builder:
          (context, constraints) => _buildShell(
            context,
            constraints,
            isChat: widget.currentIndex == 0,
          ),
    );
    final baseTheme = ShadTheme.of(context);
    return HyveChatThemeScope(
      child: Builder(
        builder:
            (chatThemeContext) => ShadTheme(
              data:
                  widget.currentIndex == 0
                      ? ShadTheme.of(chatThemeContext)
                      : baseTheme,
              child: shell,
            ),
      ),
    );
  }

  Widget _buildShell(
    BuildContext context,
    BoxConstraints constraints, {
    required bool isChat,
  }) {
    final width = constraints.maxWidth;
    final overlaySidebar = width < 960;
    final sidebarDocked = !overlaySidebar;
    final showSidebar =
        sidebarDocked &&
        _sidebarVisible &&
        _activeChatOverlay != _ChatOverlay.sidebar;
    final sidebarWidth =
        width < 1200
            ? _sidebarWidth.clamp(260.0, 280.0)
            : _sidebarWidth.clamp(
              HyveDesktopThemeSpec.sidebarMinWidth,
              HyveDesktopThemeSpec.sidebarMaxWidth,
            );
    final projectWorkspaceSelected =
        widget.currentIndex == 0 &&
        widget.selectedChatId != null &&
        widget.selectedProjectUsesAgentRuntime;
    if (isChat) {
      _closeChatOverlayForBreakpoint(
        width: width,
        sidebarDocked: sidebarDocked,
      );
    }

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: CallbackShortcuts(
        bindings: _shortcutBindings(
          context: context,
          isChat: isChat,
          overlaySidebar: overlaySidebar,
        ),
        child: Focus(
          autofocus: true,
          child: ColoredBox(
            color: HyveDesktopThemeSpec.shellBackground(context),
            child: SafeArea(
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showSidebar) ...[
                        SizedBox(
                          width: sidebarWidth,
                          child: _buildSidebar(
                            context,
                            onToggleSidebar:
                                () => _toggleSidebar(
                                  context,
                                  overlay: overlaySidebar,
                                  useChatSheet: isChat,
                                ),
                          ),
                        ),
                        _DesktopResizeHandle(
                          key: const ValueKey<String>(
                            'desktop-sidebar-resize-handle',
                          ),
                          label: S.of(context).showSidebar,
                          value: sidebarWidth,
                          onResize:
                              (delta) =>
                                  _resizeSidebar(delta, availableWidth: width),
                          onReset: () => _resetSidebarWidth(width),
                        ),
                      ],
                      Expanded(
                        child: Column(
                          children: [
                            _UnifiedDesktopToolbar(
                              currentIndex: widget.currentIndex,
                              bot: _activeBot,
                              projectName: widget.selectedProjectName,
                              sidebarVisible:
                                  overlaySidebar
                                      ? isChat
                                          ? _activeChatOverlay ==
                                              _ChatOverlay.sidebar
                                          : _compactSidebarOpen
                                      : _sidebarVisible,
                              compact: isChat && overlaySidebar,
                              isChat: isChat,
                              onToggleSidebar:
                                  () => _toggleSidebar(
                                    context,
                                    overlay: overlaySidebar,
                                    useChatSheet: isChat,
                                  ),
                              onCreateChat: widget.onCreateChat,
                              onSearchRequested:
                                  widget.currentIndex >= 2
                                      ? null
                                      : () => _requestSearch(
                                        context,
                                        isChat: isChat,
                                        overlaySidebar: overlaySidebar,
                                      ),
                              onShowProjectMembers:
                                  projectWorkspaceSelected
                                      ? () => unawaited(
                                        _projectWorkspaceController
                                            .showMembers(),
                                      )
                                      : null,
                              onShowProjectArtifacts:
                                  projectWorkspaceSelected
                                      ? _projectWorkspaceController
                                          .showArtifacts
                                      : null,
                              onShowProjectExecution:
                                  projectWorkspaceSelected
                                      ? _projectWorkspaceController
                                          .showExecution
                                      : null,
                            ),
                            Expanded(child: _buildWorkspace(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isChat && overlaySidebar && _compactSidebarOpen)
                    _buildSidebarOverlay(context, width),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
