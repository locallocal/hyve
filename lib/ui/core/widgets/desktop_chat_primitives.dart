import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/utils/theme.dart';

part 'dialog_primitives.dart';

// Shared desktop interaction primitives used by multiple feature views.
const IconData desktopProjectIcon = LucideIcons.folderKanban;
const IconData desktopBotIcon = LucideIcons.bot;
const double hyveInspectorIconLabelGap = 9;
const double _appIconCornerRadiusRatio = 0.24;

BorderRadius desktopAppIconBorderRadius(double size) =>
    BorderRadius.all(Radius.circular(size * _appIconCornerRadiusRatio));

/// A compact, dismissible inline error shared by chat and form workflows.
class HyveInlineErrorAlert extends StatelessWidget {
  const HyveInlineErrorAlert({
    super.key,
    required this.error,
    required this.isDesktop,
    required this.onDismiss,
    this.alertKey,
    this.messageKey,
    this.dismissKey,
    this.padding = const EdgeInsets.only(bottom: 8),
  });

  final String error;
  final bool isDesktop;
  final VoidCallback onDismiss;
  final Key? alertKey;
  final Key? messageKey;
  final Key? dismissKey;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final closeLabel = MaterialLocalizations.of(context).closeButtonTooltip;
    return Padding(
      padding: padding,
      child: ShadAlert.destructive(
        key: alertKey,
        decoration: const ShadDecoration(
          border: ShadBorder(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        crossAxisAlignment: CrossAxisAlignment.center,
        iconPadding: const EdgeInsetsDirectional.only(end: 8),
        icon: const SizedBox(
          width: 36,
          height: 44,
          child: Center(child: Icon(LucideIcons.circleAlert, size: 18)),
        ),
        description: Align(
          alignment: Alignment.center,
          child: Text(error, key: messageKey, textAlign: TextAlign.center),
        ),
        trailing: HyveDesktopIconAction(
          key: dismissKey,
          icon: LucideIcons.x,
          label: closeLabel,
          iconSize: 16,
          onPressed: onDismiss,
        ),
      ),
    );
  }
}

/// A shared label/value row for the desktop conversation inspector.
///
/// The label always starts after the same icon gutter. Text values occupy the
/// available trailing region and align to its right edge, while controls can
/// opt into a fixed-width trailing column.
class HyveInspectorInfoRow extends StatelessWidget {
  const HyveInspectorInfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.trailingWidth,
    this.valueTextAlign = TextAlign.right,
    this.padding = const EdgeInsets.symmetric(vertical: 9),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.iconLabelGapKey,
  }) : assert(
         (value == null) != (trailing == null),
         'Provide either value or trailing.',
       );

  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final double? trailingWidth;
  final TextAlign valueTextAlign;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final Key? iconLabelGapKey;

  @override
  Widget build(BuildContext context) {
    final trailingContent =
        trailing ??
        SelectableText(
          value!,
          textAlign: valueTextAlign,
          style: HyveDesktopThemeSpec.metaStyle(context),
        );
    final trailingColumn = switch (trailingWidth) {
      final width? => SizedBox(width: width, child: trailingContent),
      null => Flexible(
        child: Align(alignment: Alignment.centerRight, child: trailingContent),
      ),
    };

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Icon(icon, size: 17, color: HyveDesktopThemeSpec.mutedText(context)),
          SizedBox(key: iconLabelGapKey, width: hyveInspectorIconLabelGap),
          Expanded(
            child: Text(label, style: HyveDesktopThemeSpec.bodyStyle(context)),
          ),
          const SizedBox(width: 8),
          trailingColumn,
        ],
      ),
    );
  }
}

/// Applies desktop-chat-specific layout and surface overrides without
/// changing the app-wide Shad theme.
class HyveChatThemeScope extends StatelessWidget {
  const HyveChatThemeScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final baseTheme = ShadTheme.of(context);
    final chatTheme = baseTheme.copyWith(
      breakpoints: ShadBreakpoints(
        tn: 0,
        sm: 800,
        md: 960,
        lg: 1200,
        xl: 1500,
        xxl: 1800,
      ),
      cardTheme: baseTheme.cardTheme.copyWith(shadows: const []),
      resizableTheme: baseTheme.resizableTheme.copyWith(
        dividerSize: 5,
        dividerThickness: 1,
        resetOnDoubleTap: true,
        showHandle: false,
      ),
    );

    return ShadTheme(data: chatTheme, child: child);
  }
}

/// Shows a Shad dialog while preserving the local desktop-chat theme.
///
/// The package dialog route is inserted above the local [ShadTheme]. Capturing
/// and re-applying the theme here keeps chat-only breakpoints and component
/// overrides available inside the route.
Future<T?> showChatShadDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? barrierLabel,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  Color barrierColor = const Color(0xcc000000),
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  List<AnimateEffect<dynamic>>? animateIn,
  List<AnimateEffect<dynamic>>? animateOut,
  ShadDialogVariant variant = ShadDialogVariant.primary,
  bool opaque = true,
  FocusNode? returnFocusNode,
}) async {
  final chatTheme = ShadTheme.of(context);
  final focusToRestore = returnFocusNode ?? FocusManager.instance.primaryFocus;
  final effectiveBarrierLabel =
      barrierLabel ??
      MaterialLocalizations.of(context).modalBarrierDismissLabel;

  try {
    return await showShadDialog<T>(
      context: context,
      builder: (routeContext) {
        return ShadTheme(data: chatTheme, child: Builder(builder: builder));
      },
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: effectiveBarrierLabel,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      animateIn: animateIn,
      animateOut: animateOut,
      variant: variant,
      opaque: opaque,
    );
  } finally {
    _restoreFocus(focusToRestore);
  }
}

/// Shows a Shad sheet while preserving the local desktop-chat theme.
///
/// Dialogs and sheets deliberately share the same [useRootNavigator] default
/// so nested navigators cannot split the desktop overlay stack unexpectedly.
Future<T?> showChatShadSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  ShadSheetSide? side,
  String? barrierLabel,
  bool useRootNavigator = true,
  bool isDismissible = true,
  Color? backgroundColor,
  ShapeBorder? shape,
  Color barrierColor = const Color(0xcc000000),
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  List<AnimateEffect<dynamic>>? animateIn,
  List<AnimateEffect<dynamic>>? animateOut,
  FocusNode? returnFocusNode,
}) async {
  final chatTheme = ShadTheme.of(context);
  final focusToRestore = returnFocusNode ?? FocusManager.instance.primaryFocus;
  final effectiveBarrierLabel =
      barrierLabel ??
      MaterialLocalizations.of(context).modalBarrierDismissLabel;

  try {
    return await showShadSheet<T>(
      context: context,
      builder: (routeContext) {
        return ShadTheme(data: chatTheme, child: Builder(builder: builder));
      },
      side: side,
      backgroundColor: backgroundColor,
      barrierLabel: effectiveBarrierLabel,
      shape: shape,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      animateIn: animateIn,
      animateOut: animateOut,
    );
  } finally {
    _restoreFocus(focusToRestore);
  }
}

void _restoreFocus(FocusNode? focusNode) {
  if (focusNode == null) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (focusNode.context != null && focusNode.canRequestFocus) {
      focusNode.requestFocus();
    }
  });
}

/// An accessible desktop icon action with a minimum 44 by 44 hit target.
///
/// [icon] is expected to be a Lucide icon. The tooltip and button intentionally
/// share one focus node so keyboard focus exposes the same label as hover.
class HyveDesktopIconAction extends StatefulWidget {
  const HyveDesktopIconAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.variant = ShadButtonVariant.ghost,
    this.focusNode,
    this.enabled = true,
    this.selected,
    this.autofocus = false,
    this.iconSize = 18,
    this.hitTargetSize = 44,
    this.buttonSize = 36,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.showFocusRing = true,
  }) : assert(hitTargetSize >= 44, 'Icon actions need a 44px touch target.'),
       assert(buttonSize > 0 && buttonSize <= hitTargetSize),
       assert(
         variant != ShadButtonVariant.link,
         'ShadIconButton does not support the link variant.',
       );

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final ShadButtonVariant variant;
  final FocusNode? focusNode;
  final bool enabled;
  final bool? selected;
  final bool autofocus;
  final double iconSize;
  final double hitTargetSize;
  final double buttonSize;
  final Color? hoverBackgroundColor;
  final Color? foregroundColor;
  final bool showFocusRing;

  @override
  State<HyveDesktopIconAction> createState() => _HyveDesktopIconActionState();
}

class _HyveDesktopIconActionState extends State<HyveDesktopIconAction> {
  late FocusNode _focusNode;
  late bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _setFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant HyveDesktopIconAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _setFocusNode(widget.focusNode);
    }
  }

  void _setFocusNode(FocusNode? focusNode) {
    _ownsFocusNode = focusNode == null;
    _focusNode =
        focusNode ??
        FocusNode(debugLabel: 'HyveDesktopIconAction(${widget.label})');
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = widget.enabled && widget.onPressed != null;
    final shadTheme = ShadTheme.maybeOf(context);
    if (shadTheme == null) {
      return Semantics(
        container: true,
        label: widget.label,
        button: true,
        enabled: effectiveEnabled,
        selected: widget.selected,
        onTap: effectiveEnabled ? widget.onPressed : null,
        child: Tooltip(
          message: widget.label,
          child: SizedBox.square(
            dimension: widget.hitTargetSize,
            child: IconButton(
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              onPressed: effectiveEnabled ? widget.onPressed : null,
              iconSize: widget.iconSize,
              color: widget.foregroundColor,
              icon: Icon(widget.icon, size: widget.iconSize),
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: widget.label,
      button: true,
      enabled: effectiveEnabled,
      selected: widget.selected,
      onTap: effectiveEnabled ? widget.onPressed : null,
      child: ExcludeSemantics(
        child: ShadTooltip(
          focusNode: _focusNode,
          builder: (context) => Text(widget.label),
          child: SizedBox.square(
            dimension: widget.hitTargetSize,
            child: Center(
              child: ShadIconButton.raw(
                variant: widget.variant,
                width: widget.buttonSize,
                height: widget.buttonSize,
                padding: EdgeInsets.zero,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                enabled: effectiveEnabled,
                onPressed: widget.onPressed,
                hoverBackgroundColor: widget.hoverBackgroundColor,
                foregroundColor: widget.foregroundColor,
                decoration:
                    widget.showFocusRing
                        ? null
                        : const ShadDecoration(disableSecondaryBorder: true),
                iconSize: widget.iconSize,
                icon: Icon(widget.icon, size: widget.iconSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Data for one entry in a [HyveDesktopMenu].
class HyveDesktopMenuItem<T> {
  const HyveDesktopMenuItem({
    required this.value,
    required this.label,
    this.key,
    this.leading,
    this.enabled = true,
    this.selected = false,
    this.destructive = false,
  });

  final T value;
  final String label;
  final Key? key;
  final Widget? leading;
  final bool enabled;
  final bool selected;
  final bool destructive;
}

/// The standard click/tap menu for desktop controls.
///
/// This keeps all desktop selection and overflow menus on Shad popovers while
/// [HyveContextMenu] owns secondary-click menus. The trigger is responsible
/// for its own visual style and should normally be a
/// [HyveDesktopIconAction], [ShadButton], or [ShadInput].
class HyveDesktopMenu<T> extends StatefulWidget {
  const HyveDesktopMenu({
    super.key,
    required this.items,
    required this.onSelected,
    required this.triggerBuilder,
    this.width = 220,
    this.maxHeight = 360,
    this.alignEnd = false,
  });

  final List<HyveDesktopMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final Widget Function(BuildContext context, VoidCallback toggle, bool isOpen)
  triggerBuilder;
  final double width;
  final double maxHeight;
  final bool alignEnd;

  @override
  State<HyveDesktopMenu<T>> createState() => _HyveDesktopMenuState<T>();
}

class _HyveDesktopMenuState<T> extends State<HyveDesktopMenu<T>> {
  late final ShadPopoverController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ShadPopoverController()..addListener(_handleChanged);
  }

  void _handleChanged() {
    if (mounted) setState(() {});
  }

  void _select(HyveDesktopMenuItem<T> item) {
    if (!item.enabled) return;
    _controller.hide();
    widget.onSelected(item.value);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final anchor = ShadAnchor(
      offset: const Offset(0, 4),
      childAlignment:
          widget.alignEnd
              ? AlignmentDirectional.topEnd
              : AlignmentDirectional.topStart,
      overlayAlignment:
          widget.alignEnd
              ? AlignmentDirectional.bottomEnd
              : AlignmentDirectional.bottomStart,
    );
    return ShadPopover(
      controller: _controller,
      anchor: anchor,
      padding: EdgeInsets.zero,
      popover:
          (context) => ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.width,
              maxWidth: widget.width,
              maxHeight: widget.maxHeight,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final item in widget.items)
                    Semantics(
                      selected: item.selected,
                      child: ShadButton.raw(
                        key: item.key,
                        variant:
                            item.selected
                                ? ShadButtonVariant.secondary
                                : ShadButtonVariant.ghost,
                        size: ShadButtonSize.sm,
                        height: 36,
                        enabled: item.enabled,
                        expands: true,
                        mainAxisAlignment: MainAxisAlignment.start,
                        foregroundColor:
                            item.destructive ? colors.destructive : null,
                        leading: item.leading,
                        trailing:
                            item.selected
                                ? const Icon(LucideIcons.check, size: 16)
                                : const SizedBox.square(dimension: 16),
                        onPressed: () => _select(item),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      child: widget.triggerBuilder(
        context,
        _controller.toggle,
        _controller.isOpen,
      ),
    );
  }
}

class _OpenHyveContextMenuIntent extends Intent {
  const _OpenHyveContextMenuIntent();
}

/// Adds mouse and keyboard access to the same Shad context-menu items.
///
/// shadcn_ui 0.55's [ShadContextMenuRegion] owns pointer positioning but does
/// not handle Shift+F10 or the platform Menu key. This adapter keeps the
/// pointer region and keyboard-anchored menu independently controlled while
/// ensuring only one is open at a time.
class HyveContextMenu extends StatefulWidget {
  const HyveContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.focusNode,
    this.constraints = const BoxConstraints(minWidth: 180),
    this.keyboardAnchor = const ShadAnchorAuto(
      offset: Offset(0, 4),
      followerAnchor: AlignmentDirectional.topStart,
      targetAnchor: AlignmentDirectional.bottomStart,
      fallback: ShadAnchorAuto(
        offset: Offset(0, -4),
        followerAnchor: AlignmentDirectional.bottomStart,
        targetAnchor: AlignmentDirectional.topStart,
      ),
    ),
    this.enabled = true,
    this.childManagesFocus = false,
  });

  final Widget child;
  final List<Widget> items;
  final FocusNode? focusNode;
  final BoxConstraints constraints;
  final ShadAnchorBase keyboardAnchor;
  final bool enabled;

  /// Whether [child] already installs a focus widget with [focusNode].
  ///
  /// This avoids an extra tab stop when a keyboard-accessible action surface
  /// also owns the focus used to open this context menu.
  final bool childManagesFocus;

  @override
  State<HyveContextMenu> createState() => _HyveContextMenuState();
}

class _HyveContextMenuState extends State<HyveContextMenu> {
  late final ShadContextMenuController _pointerController;
  late final ShadContextMenuController _keyboardController;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  FocusNode? _pointerReturnFocus;

  bool get _canOpen => widget.enabled && widget.items.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _pointerController = ShadContextMenuController();
    _keyboardController = ShadContextMenuController();
    _pointerController.addListener(_handlePointerMenuChanged);
    _keyboardController.addListener(_handleKeyboardMenuChanged);
    _setFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant HyveContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _setFocusNode(widget.focusNode);
    }
    if (!_canOpen) {
      _pointerController.hide();
      _keyboardController.hide();
    }
  }

  void _setFocusNode(FocusNode? focusNode) {
    _ownsFocusNode = focusNode == null;
    _focusNode = focusNode ?? FocusNode(debugLabel: 'HyveContextMenu');
  }

  void _handlePointerMenuChanged() {
    if (_pointerController.isOpen) {
      _pointerReturnFocus ??= FocusManager.instance.primaryFocus;
      _keyboardController.hide();
    } else {
      final returnFocus = _pointerReturnFocus;
      _pointerReturnFocus = null;
      _scheduleFocusRestore(returnFocus);
    }
  }

  void _handleKeyboardMenuChanged() {
    if (_keyboardController.isOpen) {
      _pointerController.hide();
      _focusNode.requestFocus();
    } else {
      _scheduleFocusRestore();
    }
  }

  void _scheduleFocusRestore([FocusNode? preferredFocus]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pointerController.isOpen || _keyboardController.isOpen) {
        return;
      }
      final target =
          preferredFocus?.context != null && preferredFocus!.canRequestFocus
              ? preferredFocus
              : _focusNode;
      if (target.context != null && target.canRequestFocus) {
        target.requestFocus();
      }
    });
  }

  Object? _openKeyboardMenu(_OpenHyveContextMenuIntent intent) {
    if (_canOpen) _keyboardController.show();
    return null;
  }

  @override
  void dispose() {
    _pointerController.removeListener(_handlePointerMenuChanged);
    _keyboardController.removeListener(_handleKeyboardMenuChanged);
    _pointerController.dispose();
    _keyboardController.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !widget.childManagesFocus || widget.focusNode != null,
      'A child-managed context menu requires a shared focusNode.',
    );
    Widget trigger =
        widget.childManagesFocus
            ? widget.child
            : Focus(
              focusNode: _focusNode,
              canRequestFocus: widget.enabled,
              child: widget.child,
            );

    if (!_canOpen) return trigger;

    trigger = Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.f10, shift: true):
            _OpenHyveContextMenuIntent(),
        SingleActivator(LogicalKeyboardKey.contextMenu):
            _OpenHyveContextMenuIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenHyveContextMenuIntent:
              CallbackAction<_OpenHyveContextMenuIntent>(
                onInvoke: _openKeyboardMenu,
              ),
        },
        child: trigger,
      ),
    );

    return ShadContextMenu(
      controller: _keyboardController,
      anchor: widget.keyboardAnchor,
      constraints: widget.constraints,
      items: widget.items,
      child: ShadContextMenuRegion(
        controller: _pointerController,
        constraints: widget.constraints,
        items: widget.items,
        child: trigger,
      ),
    );
  }
}
