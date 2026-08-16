part of 'message_input.dart';

/// A controlled auto-growing adapter for shadcn_ui 0.55's textarea.
///
/// In 0.55, [ShadTextarea.minHeight] and [ShadTextarea.maxHeight] describe the
/// editable area rather than the complete decorated control. Measuring here
/// keeps the visible control within the desktop composer's 44–120/160 contract.
class StarsChatTextarea extends StatefulWidget {
  const StarsChatTextarea({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.style,
    required this.maxHeight,
  }) : assert(maxHeight >= minHeight);

  final TextEditingController controller;
  final FocusNode focusNode;
  final Widget placeholder;
  final TextStyle style;
  final double maxHeight;

  static const double minHeight = 44;
  static const double caretAllowance = 3;
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );

  @override
  State<StarsChatTextarea> createState() => _StarsChatTextareaState();
}

class _StarsChatTextareaState extends State<StarsChatTextarea> {
  late String _text;

  @override
  void initState() {
    super.initState();
    _text = widget.controller.text;
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant StarsChatTextarea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      _text = widget.controller.text;
      widget.controller.addListener(_handleTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    final text = widget.controller.text;
    if (!mounted || text == _text) return;
    setState(() => _text = text);
  }

  TextStyle _scaledStyle(BuildContext context) {
    final fontSize = widget.style.fontSize;
    if (fontSize == null) {
      return widget.style;
    }
    return widget.style.copyWith(
      fontSize: MediaQuery.textScalerOf(context).scale(fontSize),
    );
  }

  double _measureHeight(
    BuildContext context,
    double maxWidth,
    TextStyle style,
  ) {
    final horizontalPadding = StarsChatTextarea.contentPadding.horizontal;
    final verticalPadding = StarsChatTextarea.contentPadding.vertical;
    final availableWidth =
        (maxWidth - horizontalPadding - StarsChatTextarea.caretAllowance)
            .clamp(1.0, double.infinity)
            .toDouble();
    final painter = TextPainter(
      text: TextSpan(
        text: '${_text.isEmpty ? ' ' : _text}\u200B',
        style: style,
      ),
      textDirection: Directionality.of(context),
      locale: Localizations.maybeLocaleOf(context),
    )..layout(maxWidth: availableWidth);
    final measured = painter.height + verticalPadding;
    return measured
        .clamp(StarsChatTextarea.minHeight, widget.maxHeight)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final style = _scaledStyle(context);
        final maxWidth =
            constraints.hasBoundedWidth
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
        final height = _measureHeight(context, maxWidth, style);
        final editableHeight =
            height - StarsChatTextarea.contentPadding.vertical;

        return SizedBox(
          height: height,
          child: MediaQuery.withNoTextScaling(
            child: ShadTextarea(
              controller: widget.controller,
              focusNode: widget.focusNode,
              placeholder: widget.placeholder,
              placeholderStyle: style.copyWith(
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
              style: style,
              padding: StarsChatTextarea.contentPadding,
              decoration: ShadDecoration.none,
              constraints: BoxConstraints.tightFor(height: height),
              minHeight: editableHeight,
              maxHeight: editableHeight,
              resizable: false,
              contextMenuBuilder:
                  (context, editableTextState) => MediaQuery(
                    data: mediaQuery,
                    child: Builder(
                      builder:
                          (context) => ShadInputState.defaultContextMenuBuilder(
                            context,
                            editableTextState,
                          ),
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }
}

class _DesktopStopIcon extends StatelessWidget {
  const _DesktopStopIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      key: const ValueKey('desktop-stop-icon'),
      dimension: size,
      child: Center(
        child: SizedBox.square(
          key: const ValueKey('desktop-stop-glyph'),
          dimension: 15,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color:
                  IconTheme.of(context).color ??
                  DefaultTextStyle.of(context).style.color,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ),
      ),
    );
  }
}
