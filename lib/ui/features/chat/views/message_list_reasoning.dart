part of 'message_list.dart';

class _ReasoningSectionState extends State<ReasoningSection>
    with SingleTickerProviderStateMixin {
  static const _itemValue = 'reasoning';

  late bool _mobileExpanded;
  late final ShadAccordionController<String> _desktopController;
  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool? _shouldRotate;

  @override
  void initState() {
    super.initState();
    _mobileExpanded = true;
    _desktopController = ShadAccordionController<String>(
      widget.isDesktop && widget.isStreaming ? _itemValue : null,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRotation();
  }

  @override
  void didUpdateWidget(covariant ReasoningSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDesktop != widget.isDesktop ||
        oldWidget.isStreaming != widget.isStreaming) {
      _updateRotation();
    }
    if (!widget.isDesktop || oldWidget.isStreaming == widget.isStreaming) {
      return;
    }
    final isOpen = _desktopController.value.contains(_itemValue);
    if (widget.isStreaming != isOpen) {
      _desktopController.toggle(_itemValue);
    }
  }

  void _updateRotation() {
    final shouldRotate =
        widget.isDesktop &&
        widget.isStreaming &&
        !MediaQuery.disableAnimationsOf(context);
    if (_shouldRotate == shouldRotate) return;
    _shouldRotate = shouldRotate;
    if (shouldRotate) {
      _rotationController.repeat();
    } else {
      _rotationController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _desktopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.bodyLarge?.fontSize ?? 14;
    final strings = S.of(context);

    if (widget.isDesktop) {
      final disableAnimations = MediaQuery.disableAnimationsOf(context);
      final title =
          widget.isStreaming
              ? strings.thinkingInProgress
              : widget.durationMs == null
              ? strings.thinkingCompleted
              : strings.thinkingCompletedWithDuration(
                _formatDuration(widget.durationMs!),
              );

      return ShadCard(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        backgroundColor: StarsDesktopTheme.statusCardBackground(context),
        radius: BorderRadius.circular(StarsDesktopTheme.cardRadius),
        border: ShadBorder.all(color: StarsDesktopTheme.borderColor(context)),
        child: ShadAccordion<String>(
          controller: _desktopController,
          maintainState: true,
          children: [
            ShadAccordionItem<String>(
              value: _itemValue,
              separator: const SizedBox.shrink(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              duration:
                  disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
              underlineTitleOnHover: false,
              iconData: LucideIcons.chevronDown,
              title: ListenableBuilder(
                listenable: _desktopController,
                builder:
                    (context, child) => Semantics(
                      expanded: _desktopController.value.contains(_itemValue),
                      child: child,
                    ),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child:
                          widget.isStreaming
                              ? RotationTransition(
                                key: const ValueKey<String>(
                                  'reasoning-streaming-spinner',
                                ),
                                turns: _rotationController,
                                child: Icon(
                                  LucideIcons.loaderCircle,
                                  size: 16,
                                  color: StarsDesktopTheme.mutedText(context),
                                ),
                              )
                              : Icon(
                                LucideIcons.brain,
                                size: 16,
                                color: StarsDesktopTheme.mutedText(context),
                              ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: fontSize - 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReasoningMarkdown(context, fontSize),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: StarsDesktopTheme.statusCardBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StarsDesktopTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _mobileExpanded = !_mobileExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.psychology_alt_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.processInformation,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: fontSize - 1,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          strings.deepThinking,
                          style: TextStyle(
                            fontSize: fontSize - 3,
                            color: StarsDesktopTheme.mutedText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 180),
                    turns: _mobileExpanded ? 0 : 0.5,
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: StarsDesktopTheme.mutedText(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_mobileExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildReasoningMarkdown(context, fontSize),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReasoningMarkdown(BuildContext context, double fontSize) {
    return MarkdownBody(
      data: widget.reasoning,
      selectable: true,
      onTapLink:
          (text, href, title) => unawaited(
            _openMarkdownLink(context, href, widget.actionViewModel),
          ),
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: StarsDesktopTheme.mutedText(context),
          fontSize: fontSize - 1,
          height: 1.5,
        ),
        code: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          backgroundColor: StarsDesktopTheme.elevatedSurface(context),
          fontSize: fontSize - 2,
        ),
        a: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
          decorationColor: Theme.of(context).colorScheme.primary,
        ),
        codeblockDecoration: BoxDecoration(
          color: StarsDesktopTheme.elevatedSurface(context),
          borderRadius: BorderRadius.circular(widget.isDesktop ? 8 : 12),
          border: Border.all(color: StarsDesktopTheme.borderColor(context)),
        ),
        blockSpacing: 8,
      ),
    );
  }
}

Future<void> _openMarkdownLink(
  BuildContext context,
  String? href,
  MessageActionViewModel? actions,
) async {
  if (href == null || href.trim().isEmpty) return;
  final normalized = href.trim();
  if (await actions?.openExternal(normalized) == true) return;
  if (!context.mounted) return;

  final sonner = ShadSonner.maybeOf(context);
  if (sonner == null) {
    showSnackBar(context, S.of(context).linkOpenFailed);
    return;
  }
  sonner.show(
    ShadToast.destructive(
      title: Text(S.of(context).linkOpenFailed),
      action: ShadButton.outline(
        size: ShadButtonSize.sm,
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: normalized));
        },
        leading: const Icon(LucideIcons.copy, size: 16),
        child: Text(MaterialLocalizations.of(context).copyButtonLabel),
      ),
    ),
  );
}
