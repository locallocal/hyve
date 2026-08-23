part of 'theme.dart';

/// A keyboard-accessible action surface for desktop cards and rich rows.
///
/// Shad cards are presentation surfaces rather than buttons. This adapter
/// supplies the missing focus, activation, hover, and semantic behavior while
/// allowing the caller to keep interactive children such as overflow menus.
class HyveDesktopActionSurface extends StatefulWidget {
  const HyveDesktopActionSurface({
    super.key,
    required this.label,
    required this.onPressed,
    required this.builder,
    this.hint,
    this.focusNode,
    this.liftOnHover = true,
  });

  final String label;
  final String? hint;
  final VoidCallback onPressed;
  final Widget Function(BuildContext context, bool highlighted) builder;
  final FocusNode? focusNode;
  final bool liftOnHover;

  @override
  State<HyveDesktopActionSurface> createState() =>
      _HyveDesktopActionSurfaceState();
}

class _HyveDesktopActionSurfaceState extends State<HyveDesktopActionSurface> {
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _setFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant HyveDesktopActionSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _setFocusNode(widget.focusNode);
    }
  }

  void _setFocusNode(FocusNode? focusNode) {
    _ownsFocusNode = focusNode == null;
    _focusNode = focusNode ?? FocusNode(debugLabel: 'HyveDesktopActionSurface');
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = HyveDesktopTokens.of(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final highlighted = _hovered || _focused;
    return Semantics(
      container: true,
      button: true,
      label: widget.label,
      hint: widget.hint,
      onTap: widget.onPressed,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        mouseCursor: SystemMouseCursors.click,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed();
              return null;
            },
          ),
        },
        onShowHoverHighlight: (value) {
          if (_hovered != value) setState(() => _hovered = value);
        },
        onShowFocusHighlight: (value) {
          if (_focused != value) setState(() => _focused = value);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration:
                disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            transform:
                widget.liftOnHover && _hovered
                    ? (Matrix4.identity()..translateByDouble(0, -2, 0, 1))
                    : Matrix4.identity(),
            decoration:
                _focused
                    ? BoxDecoration(
                      border: Border.all(
                        color: tokens.focusRing,
                        width: tokens.highContrast ? 3 : 2,
                      ),
                      borderRadius: HyveDesktopThemeSpec.containerRadius,
                    )
                    : null,
            child: widget.builder(context, highlighted),
          ),
        ),
      ),
    );
  }
}
