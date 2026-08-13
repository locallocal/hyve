import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/core/dependency_injection/app_dependencies.dart';
import 'package:stars/ui/core/dependency_injection/app_scope.dart';
import 'package:stars/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:stars/ui/core/widgets/logo.dart';
import 'package:stars/ui/core/widgets/model_modalities.dart';
import 'package:stars/ui/features/bots/views/edit_bot.dart';
import 'package:stars/ui/features/chat/view_models/chat_token_usage_view_model.dart';
import 'package:stars/ui/features/chat/view_models/conversation_memory_view_model.dart';
import 'package:stars/ui/features/chat/views/chat.dart';
import 'package:stars/ui/features/chat/views/conversation_memory_panel.dart';
import 'package:stars/ui/features/chat/views/conversation_model_controls.dart';
import 'package:stars/ui/features/chat/views/token_usage_chart.dart';
import 'package:stars/utils/theme.dart';
import 'package:stars/utils/utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

part 'desktop_layout_workspace.dart';
part 'desktop_layout_toolbar.dart';
part 'desktop_layout_components.dart';

enum _ChatOverlay { sidebar, inspector }

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
  double _sidebarWidth = DesktopThemeTokens.sidebarWidth;
  double _inspectorWidth = DesktopThemeTokens.inspectorWidth;
  bool _sidebarVisible = true;
  bool _compactSidebarOpen = false;
  bool _inspectorOpen = false;
  final ScrollController _inspectorScrollController = ScrollController();
  _ChatOverlay? _activeChatOverlay;
  NavigatorState? _chatOverlayNavigator;
  ModalRoute<dynamic>? _chatOverlayRoute;
  Completer<ModalRoute<dynamic>?>? _chatOverlayRouteReady;
  Future<void>? _chatOverlayClosed;
  Future<void> _chatOverlayTransition = Future<void>.value();
  int _chatOverlaySession = 0;
  bool _preserveChatOverlayIntent = false;
  bool _chatOverlayDismissScheduled = false;

  String? _chatPageKeyId;
  GlobalKey<ChatPageState>? _chatPageKey;
  AppDependencies? _dependencies;
  ChatTokenUsageViewModel? _tokenUsageViewModel;
  ConversationMemoryViewModel? _memoryViewModel;

  Bot? get _activeBot => switch (widget.currentIndex) {
    0 => widget.selectedChatBot,
    1 => widget.selectedBot,
    _ => null,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dependencies = AppScope.maybeOf(context);
    if (_dependencies == dependencies) return;
    _tokenUsageViewModel?.dispose();
    _memoryViewModel?.dispose();
    _tokenUsageViewModel = null;
    _memoryViewModel = null;
    _dependencies = dependencies;
    _replaceTokenUsageViewModel();
    _replaceMemoryViewModel();
  }

  @override
  void didUpdateWidget(covariant DesktopLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedChatId != widget.selectedChatId) {
      _chatPageKeyId = null;
      _chatPageKey = null;
      _replaceTokenUsageViewModel();
      _replaceMemoryViewModel();
    } else if (oldWidget.selectedChatBot != widget.selectedChatBot) {
      _replaceMemoryViewModel();
    }
    if (widget.currentIndex != 0 && _inspectorOpen) {
      _inspectorOpen = false;
    }
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
    _inspectorScrollController.dispose();
    _tokenUsageViewModel?.dispose();
    _memoryViewModel?.dispose();
    super.dispose();
  }

  void _replaceTokenUsageViewModel() {
    final chatId = widget.selectedChatId;
    if (_tokenUsageViewModel?.chatId == chatId && chatId != null) return;
    _tokenUsageViewModel?.dispose();
    final dependencies = _dependencies;
    _tokenUsageViewModel =
        chatId == null || dependencies == null
            ? null
            : dependencies.createChatTokenUsageViewModel(chatId);
    final viewModel = _tokenUsageViewModel;
    if (viewModel != null) unawaited(viewModel.load());
  }

  void _replaceMemoryViewModel() {
    _memoryViewModel?.dispose();
    final chatId = widget.selectedChatId;
    final bot = widget.selectedChatBot;
    final dependencies = _dependencies;
    _memoryViewModel =
        chatId == null || bot == null || dependencies == null
            ? null
            : dependencies.createConversationMemoryViewModel(chatId, bot);
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
    return StarsChatThemeScope(
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
              DesktopThemeTokens.sidebarMinWidth,
              DesktopThemeTokens.sidebarMaxWidth,
            );
    final inspectorAvailable =
        width >= 800 && widget.currentIndex == 0 && _activeBot != null;
    final inspectorShouldDock =
        width >= 1500 && _inspectorOpen && inspectorAvailable;
    final dockInspector =
        inspectorShouldDock && _activeChatOverlay != _ChatOverlay.inspector;
    final overlayInspector =
        width < 1500 && _inspectorOpen && inspectorAvailable;
    final inspectorMaxWidth = math.min(
      DesktopThemeTokens.inspectorMaxWidth,
      math.max(
        DesktopThemeTokens.inspectorMinWidth,
        width -
            (showSidebar ? sidebarWidth : 0) -
            DesktopThemeTokens.detailMinWidth -
            DesktopThemeTokens.splitterHitWidth * 2,
      ),
    );
    final inspectorWidth =
        _inspectorWidth
            .clamp(DesktopThemeTokens.inspectorMinWidth, inspectorMaxWidth)
            .toDouble();

    if (isChat) {
      _closeChatOverlayForBreakpoint(
        width: width,
        sidebarDocked: sidebarDocked,
        inspectorDocked: inspectorShouldDock,
        inspectorAvailable: inspectorAvailable,
      );
    }

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: CallbackShortcuts(
        bindings: _shortcutBindings(
          context: context,
          isChat: isChat,
          overlaySidebar: overlaySidebar,
          inspectorAvailable: inspectorAvailable,
          useInspectorSheet: isChat && width < 1500,
        ),
        child: Focus(
          autofocus: true,
          child: ColoredBox(
            color: DesktopThemeTokens.shellBackground(context),
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
                              (delta) => _resizeSidebar(
                                delta,
                                availableWidth: width,
                                dockInspector: dockInspector,
                                inspectorWidth: inspectorWidth,
                              ),
                          onReset: () => _resetSidebarWidth(width),
                        ),
                      ],
                      Expanded(
                        child: Column(
                          children: [
                            _UnifiedDesktopToolbar(
                              currentIndex: widget.currentIndex,
                              bot: _activeBot,
                              sidebarVisible:
                                  overlaySidebar
                                      ? isChat
                                          ? _activeChatOverlay ==
                                              _ChatOverlay.sidebar
                                          : _compactSidebarOpen
                                      : _sidebarVisible,
                              inspectorVisible:
                                  dockInspector ||
                                  (isChat
                                      ? _activeChatOverlay ==
                                          _ChatOverlay.inspector
                                      : overlayInspector),
                              inspectorAvailable: inspectorAvailable,
                              compact: isChat && overlaySidebar,
                              isChat: isChat,
                              onToggleSidebar:
                                  () => _toggleSidebar(
                                    context,
                                    overlay: overlaySidebar,
                                    useChatSheet: isChat,
                                  ),
                              onToggleInspector:
                                  inspectorAvailable
                                      ? () => _toggleInspector(
                                        context,
                                        useChatSheet: isChat && width < 1500,
                                      )
                                      : null,
                              onCreateChat: widget.onCreateChat,
                              onSearchRequested:
                                  widget.currentIndex >= 2
                                      ? null
                                      : () => _requestSearch(
                                        context,
                                        isChat: isChat,
                                        overlaySidebar: overlaySidebar,
                                      ),
                              onClearChat:
                                  widget.currentIndex == 0 &&
                                          widget.selectedChatId != null
                                      ? _requestClearChat
                                      : null,
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: _buildWorkspace(context)),
                                  if (dockInspector) ...[
                                    _DesktopResizeHandle(
                                      label: S.of(context).showInspector,
                                      value: inspectorWidth,
                                      reversed: true,
                                      onResize:
                                          (delta) => _resizeInspector(
                                            delta,
                                            availableWidth: width,
                                            sidebarWidth:
                                                showSidebar ? sidebarWidth : 0,
                                          ),
                                      onReset: _resetInspectorWidth,
                                    ),
                                    SizedBox(
                                      width: inspectorWidth,
                                      child: _buildInspector(
                                        context,
                                        overlay: false,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isChat && overlaySidebar && _compactSidebarOpen)
                    _buildSidebarOverlay(context, width),
                  if (!isChat && overlayInspector)
                    _buildInspectorOverlay(context, width),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> _shortcutBindings({
    required BuildContext context,
    required bool isChat,
    required bool overlaySidebar,
    required bool inspectorAvailable,
    required bool useInspectorSheet,
  }) {
    return <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.keyB, control: true):
          () => _toggleSidebar(
            context,
            overlay: overlaySidebar,
            useChatSheet: isChat,
          ),
      const SingleActivator(LogicalKeyboardKey.keyS, control: true, meta: true):
          () => _toggleSidebar(
            context,
            overlay: overlaySidebar,
            useChatSheet: isChat,
          ),
      const SingleActivator(
        LogicalKeyboardKey.keyI,
        control: true,
        alt: true,
      ): () {
        if (inspectorAvailable) {
          _toggleInspector(context, useChatSheet: useInspectorSheet);
        }
      },
      const SingleActivator(
        LogicalKeyboardKey.keyI,
        meta: true,
        alt: true,
      ): () {
        if (inspectorAvailable) {
          _toggleInspector(context, useChatSheet: useInspectorSheet);
        }
      },
      const SingleActivator(LogicalKeyboardKey.comma, control: true):
          () => _selectPage(4),
      const SingleActivator(LogicalKeyboardKey.comma, meta: true):
          () => _selectPage(4),
      const SingleActivator(LogicalKeyboardKey.keyN, control: true):
          _invokePrimaryAction,
      const SingleActivator(LogicalKeyboardKey.keyN, meta: true):
          _invokePrimaryAction,
      const SingleActivator(LogicalKeyboardKey.keyF, control: true):
          () => _requestSearch(
            context,
            isChat: isChat,
            overlaySidebar: overlaySidebar,
          ),
      const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
          () => _requestSearch(
            context,
            isChat: isChat,
            overlaySidebar: overlaySidebar,
          ),
      const SingleActivator(LogicalKeyboardKey.keyK, control: true):
          () => _requestSearch(
            context,
            isChat: isChat,
            overlaySidebar: overlaySidebar,
          ),
      const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
          () => _requestSearch(
            context,
            isChat: isChat,
            overlaySidebar: overlaySidebar,
          ),
      const SingleActivator(LogicalKeyboardKey.escape): _closeTopOverlay,
    };
  }

  void _invokePrimaryAction() {
    if (widget.currentIndex == 0) {
      widget.onCreateChat?.call();
    } else if (widget.currentIndex == 1) {
      widget.onAddBot?.call();
    }
  }

  Future<void> _requestSearch(
    BuildContext context, {
    required bool isChat,
    required bool overlaySidebar,
  }) async {
    if (widget.currentIndex >= 2 || widget.onSearchRequested == null) return;
    if (isChat && overlaySidebar) {
      await _openChatOverlay(
        context,
        _ChatOverlay.sidebar,
        toggleIfActive: false,
      );
    } else {
      setState(() {
        if (overlaySidebar) {
          _compactSidebarOpen = true;
        } else {
          _sidebarVisible = true;
        }
      });
    }
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) widget.onSearchRequested?.call();
  }

  void _toggleSidebar(
    BuildContext context, {
    required bool overlay,
    required bool useChatSheet,
  }) {
    if (overlay && useChatSheet) {
      unawaited(_openChatOverlay(context, _ChatOverlay.sidebar));
      return;
    }
    setState(() {
      if (overlay) {
        _compactSidebarOpen = !_compactSidebarOpen;
      } else {
        _sidebarVisible = !_sidebarVisible;
      }
    });
  }

  void _toggleInspector(BuildContext context, {required bool useChatSheet}) {
    if (useChatSheet) {
      unawaited(_openChatOverlay(context, _ChatOverlay.inspector));
      return;
    }
    setState(() {
      _inspectorOpen = !_inspectorOpen;
      if (_inspectorOpen) _compactSidebarOpen = false;
    });
  }

  void _closeTopOverlay() {
    if (_activeChatOverlay != null) {
      unawaited(_dismissActiveChatOverlay());
      return;
    }
    if (_inspectorOpen) {
      setState(() => _inspectorOpen = false);
    } else if (_compactSidebarOpen) {
      setState(() => _compactSidebarOpen = false);
    }
  }

  Future<void> _openChatOverlay(
    BuildContext context,
    _ChatOverlay overlay, {
    bool toggleIfActive = true,
  }) => _enqueueChatOverlayTransition(
    () => _openChatOverlayNow(context, overlay, toggleIfActive: toggleIfActive),
  );

  Future<void> _openChatOverlayNow(
    BuildContext context,
    _ChatOverlay overlay, {
    required bool toggleIfActive,
  }) async {
    if (_activeChatOverlay == overlay) {
      if (toggleIfActive) {
        await _dismissActiveChatOverlayNow();
      } else {
        await _waitForChatOverlayRoute();
      }
      return;
    }
    if (_activeChatOverlay != null) {
      await _dismissActiveChatOverlayNow();
    }
    if (!mounted || !context.mounted || widget.currentIndex != 0) return;

    final session = ++_chatOverlaySession;
    final routeReady = Completer<ModalRoute<dynamic>?>();
    setState(() {
      _activeChatOverlay = overlay;
      _preserveChatOverlayIntent = false;
      if (overlay == _ChatOverlay.sidebar) {
        _sidebarVisible = true;
        _inspectorOpen = false;
      } else {
        _inspectorOpen = true;
      }
    });

    final navigator = Navigator.of(context, rootNavigator: true);
    _chatOverlayNavigator = navigator;
    _chatOverlayRoute = null;
    _chatOverlayRouteReady = routeReady;
    final side =
        overlay == _ChatOverlay.sidebar
            ? ShadSheetSide.left
            : ShadSheetSide.right;
    final targetWidth =
        overlay == _ChatOverlay.sidebar
            ? DesktopThemeTokens.sidebarWidth
            : DesktopThemeTokens.inspectorWidth;
    final closed = showChatShadSheet<void>(
      context: context,
      side: side,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      useRootNavigator: true,
      builder: (sheetContext) {
        final route = ModalRoute.of(sheetContext);
        if (!routeReady.isCompleted) routeReady.complete(route);
        if (_chatOverlaySession == session && _activeChatOverlay == overlay) {
          _chatOverlayRoute = route;
        }
        final availableWidth = math.max(
          0.0,
          MediaQuery.sizeOf(sheetContext).width - 32,
        );
        final width = math.min(targetWidth, availableWidth);
        return ShadSheet(
          draggable: false,
          scrollable: false,
          padding: overlay == _ChatOverlay.sidebar ? EdgeInsets.zero : null,
          constraints: BoxConstraints.tightFor(width: width),
          title:
              overlay == _ChatOverlay.inspector
                  ? Text(S.of(sheetContext).botInformation)
                  : null,
          closeIcon: StarsDesktopIconAction(
            icon: LucideIcons.x,
            label: MaterialLocalizations.of(sheetContext).closeButtonTooltip,
            onPressed: () => unawaited(_dismissActiveChatOverlay()),
          ),
          child: SizedBox.expand(
            child:
                overlay == _ChatOverlay.sidebar
                    ? _buildSidebar(sheetContext)
                    : _buildInspector(
                      sheetContext,
                      overlay: true,
                      showHeader: false,
                      contentPadding: const EdgeInsets.only(top: 12, right: 16),
                    ),
          ),
        );
      },
    ).then<void>((_) {});
    _chatOverlayClosed = closed;
    unawaited(_watchChatOverlayClosed(session, overlay, closed));
    await _waitForChatOverlayRoute();
  }

  Future<void> _dismissActiveChatOverlay() =>
      _enqueueChatOverlayTransition(_dismissActiveChatOverlayNow);

  Future<void> _dismissActiveChatOverlayNow() async {
    final session = _chatOverlaySession;
    final overlay = _activeChatOverlay;
    final closed = _chatOverlayClosed;
    final navigator = _chatOverlayNavigator;
    if (overlay == null || closed == null || navigator == null) {
      return;
    }
    final route = _chatOverlayRoute ?? await _waitForChatOverlayRoute();
    if (session != _chatOverlaySession || _chatOverlayClosed != closed) return;
    if (route != null && route.isActive) {
      if (route.isCurrent) {
        navigator.pop();
      } else {
        navigator.removeRoute(route);
      }
    }
    await closed;
    _completeChatOverlaySession(session, overlay, closed);
  }

  Future<ModalRoute<dynamic>?> _waitForChatOverlayRoute() async {
    final route = _chatOverlayRoute;
    if (route != null) return route;
    final routeReady = _chatOverlayRouteReady;
    final closed = _chatOverlayClosed;
    if (routeReady == null || closed == null) return null;
    return Future.any<ModalRoute<dynamic>?>([
      routeReady.future,
      closed.then<ModalRoute<dynamic>?>((_) => null),
    ]);
  }

  Future<void> _watchChatOverlayClosed(
    int session,
    _ChatOverlay overlay,
    Future<void> closed,
  ) async {
    await closed;
    await _enqueueChatOverlayTransition(() async {
      _completeChatOverlaySession(session, overlay, closed);
    });
  }

  void _completeChatOverlaySession(
    int session,
    _ChatOverlay overlay,
    Future<void> closed,
  ) {
    if (session != _chatOverlaySession || _chatOverlayClosed != closed) return;
    final preserveIntent = _preserveChatOverlayIntent;
    void clearSession() {
      _activeChatOverlay = null;
      _chatOverlayNavigator = null;
      _chatOverlayRoute = null;
      _chatOverlayRouteReady = null;
      _chatOverlayClosed = null;
      _preserveChatOverlayIntent = false;
      _chatOverlayDismissScheduled = false;
      if (!preserveIntent) {
        if (overlay == _ChatOverlay.sidebar) {
          _sidebarVisible = false;
        } else {
          _inspectorOpen = false;
        }
      }
    }

    if (mounted) {
      setState(clearSession);
    } else {
      clearSession();
    }
  }

  Future<void> _enqueueChatOverlayTransition(
    Future<void> Function() operation,
  ) {
    final scheduled = _chatOverlayTransition.then<void>((_) => operation());
    final guarded = scheduled.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'Stars desktop chat overlay',
          ),
        );
      },
    );
    _chatOverlayTransition = guarded;
    return guarded;
  }

  void _closeChatOverlayForBreakpoint({
    required double width,
    required bool sidebarDocked,
    required bool inspectorDocked,
    required bool inspectorAvailable,
  }) {
    final overlay = _activeChatOverlay;
    if (overlay == null || _chatOverlayDismissScheduled) return;
    final mustClose = switch (overlay) {
      _ChatOverlay.sidebar => sidebarDocked,
      _ChatOverlay.inspector => inspectorDocked || !inspectorAvailable,
    };
    if (!mustClose) return;

    _chatOverlayDismissScheduled = true;
    _preserveChatOverlayIntent = switch (overlay) {
      _ChatOverlay.sidebar => width >= 960,
      _ChatOverlay.inspector => width >= 1500,
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_dismissActiveChatOverlay());
    });
  }

  void _resizeSidebar(
    double delta, {
    required double availableWidth,
    required bool dockInspector,
    required double inspectorWidth,
  }) {
    final reserved =
        DesktopThemeTokens.detailMinWidth +
        (dockInspector ? inspectorWidth : 0) +
        DesktopThemeTokens.splitterHitWidth * (dockInspector ? 2 : 1);
    final compactDock = availableWidth < 1200;
    final minWidth = compactDock ? 260.0 : DesktopThemeTokens.sidebarMinWidth;
    final requestedMax =
        compactDock ? 280.0 : DesktopThemeTokens.sidebarMaxWidth;
    final maxWidth = math.min(
      requestedMax,
      math.max(minWidth, availableWidth - reserved),
    );
    final effectiveWidth = _sidebarWidth.clamp(minWidth, maxWidth).toDouble();
    setState(() {
      _sidebarWidth = (effectiveWidth + delta).clamp(minWidth, maxWidth);
    });
  }

  void _resetSidebarWidth(double availableWidth) {
    final defaultWidth =
        availableWidth < 1200 ? 280.0 : DesktopThemeTokens.sidebarWidth;
    setState(() => _sidebarWidth = defaultWidth);
  }

  void _resizeInspector(
    double delta, {
    required double availableWidth,
    required double sidebarWidth,
  }) {
    final maxWidth = math.min(
      DesktopThemeTokens.inspectorMaxWidth,
      math.max(
        DesktopThemeTokens.inspectorMinWidth,
        availableWidth -
            sidebarWidth -
            DesktopThemeTokens.detailMinWidth -
            DesktopThemeTokens.splitterHitWidth * 2,
      ),
    );
    final effectiveWidth =
        _inspectorWidth
            .clamp(DesktopThemeTokens.inspectorMinWidth, maxWidth)
            .toDouble();
    setState(() {
      _inspectorWidth = (effectiveWidth + delta).clamp(
        DesktopThemeTokens.inspectorMinWidth,
        maxWidth,
      );
    });
  }

  void _resetInspectorWidth() {
    setState(() => _inspectorWidth = DesktopThemeTokens.inspectorWidth);
  }

  Future<void> _requestClearChat() async {
    await _chatPageKey?.currentState?.requestClearChat();
  }
}
