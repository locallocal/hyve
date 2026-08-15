import 'package:stars/generated/l10n.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:stars/utils/theme.dart';
import 'package:stars/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

part 'message_input_textarea.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final AiProvider provider;
  final bool requestInProgress;
  final bool canCancel;
  final bool isStopping;
  final bool hasPendingAttachments;
  final bool desktopMode;
  final bool autofocus;
  final int focusRequestToken;
  final VoidCallback onSend;
  final VoidCallback onCancelRequest;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onFilePressed;
  final ValueChanged<String> onImageSizeSelected;
  final ValueChanged<String> onImageStyleSelected;
  final ValueChanged<String> onVideoRatioSelected;

  const MessageInput({
    super.key,
    required this.provider,
    required this.controller,
    required this.requestInProgress,
    this.canCancel = false,
    this.isStopping = false,
    this.hasPendingAttachments = false,
    this.desktopMode = false,
    this.autofocus = false,
    this.focusRequestToken = 0,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onFilePressed,
    required this.onImageSizeSelected,
    required this.onImageStyleSelected,
    required this.onVideoRatioSelected,
    required this.onSend,
    required this.onCancelRequest,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  String selectedImageStyle = '';
  String selectedImageRatio = '';
  String selectedVideoRatio = '';
  final FocusNode _focusNode = FocusNode();
  final FocusNode _attachmentButtonFocusNode = FocusNode();
  final ShadPopoverController _attachmentPopoverController =
      ShadPopoverController();
  final ShadPopoverController _imageOptionsPopoverController =
      ShadPopoverController();
  final ShadPopoverController _videoOptionsPopoverController =
      ShadPopoverController();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    if (widget.provider.getOutputModalites().contains(OutputModality.image) &&
        widget.provider.getSupportedImageSizes().isNotEmpty) {
      selectedImageRatio = widget.provider.getSupportedImageSizes().first;
    }
    if (widget.provider.getOutputModalites().contains(OutputModality.video) &&
        widget.provider.getSupportVideoRatios().isNotEmpty) {
      selectedVideoRatio = widget.provider.getSupportVideoRatios().first;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.autofocus) {
        _focusNode.requestFocus();
        Future<void>.delayed(const Duration(milliseconds: 320), () {
          if (mounted) _focusNode.requestFocus();
        });
      }
      if (selectedImageRatio.isNotEmpty) {
        widget.onImageSizeSelected(selectedImageRatio);
      }
      if (selectedVideoRatio.isNotEmpty) {
        widget.onVideoRatioSelected(selectedVideoRatio);
      }
    });
    _focusNode.addListener(_handleFocusChanged);
    _attachmentPopoverController.addListener(_handlePopoverChanged);
    _imageOptionsPopoverController.addListener(_handlePopoverChanged);
    _videoOptionsPopoverController.addListener(_handlePopoverChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _attachmentButtonFocusNode.dispose();
    _attachmentPopoverController
      ..removeListener(_handlePopoverChanged)
      ..dispose();
    _imageOptionsPopoverController
      ..removeListener(_handlePopoverChanged)
      ..dispose();
    _videoOptionsPopoverController
      ..removeListener(_handlePopoverChanged)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusRequestToken != widget.focusRequestToken) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  void _handleFocusChanged() {
    if (_hasFocus != _focusNode.hasFocus) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  void _handlePopoverChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _togglePopover(ShadPopoverController target) {
    for (final controller in [
      _attachmentPopoverController,
      _imageOptionsPopoverController,
      _videoOptionsPopoverController,
    ]) {
      if (!identical(controller, target)) {
        controller.hide();
      }
    }
    target.toggle();
  }

  bool get _canSubmit =>
      widget.controller.text.trim().isNotEmpty || widget.hasPendingAttachments;

  bool get _isDesktop => widget.desktopMode;

  bool get _isComposing {
    final composing = widget.controller.value.composing;
    return composing.isValid && !composing.isCollapsed;
  }

  KeyEventResult _handleComposerKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        (event.logicalKey != LogicalKeyboardKey.enter &&
            event.logicalKey != LogicalKeyboardKey.numpadEnter)) {
      return KeyEventResult.ignored;
    }

    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isShiftPressed ||
        keyboard.isAltPressed ||
        keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        _isComposing) {
      return KeyEventResult.ignored;
    }

    if (!widget.requestInProgress && _canSubmit) {
      _submit();
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.bodyLarge?.fontSize ?? 14;
    final isDesktop = _isDesktop || isDesktopPlatform(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final shadTheme = isDesktop ? ShadTheme.of(context) : null;

    return Column(
      children: [
        AnimatedContainer(
          duration:
              isDesktop && disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
          margin: EdgeInsets.only(
            left: isDesktop ? 0 : 16,
            right: isDesktop ? 0 : 16,
            top: 8,
          ),
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 12 : 8,
            isDesktop ? 8 : 0,
            isDesktop ? 12 : 8,
            isDesktop ? 10 : 14,
          ),
          decoration: BoxDecoration(
            color:
                isDesktop
                    ? shadTheme!.colorScheme.card
                    : Theme.of(context).colorScheme.secondary,
            borderRadius:
                isDesktop
                    ? StarsDesktopThemeSpec.containerRadius
                    : BorderRadius.circular(16),
            border: Border.all(
              color:
                  _hasFocus && isDesktop
                      ? shadTheme!.colorScheme.ring
                      : isDesktop
                      ? shadTheme!.colorScheme.border
                      : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Focus(
                canRequestFocus: false,
                skipTraversal: true,
                onKeyEvent: isDesktop ? _handleComposerKeyEvent : null,
                child:
                    isDesktop
                        ? StarsChatTextarea(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          placeholder: Text(S.of(context).messageHint),
                          maxHeight:
                              MediaQuery.sizeOf(context).height < 680
                                  ? 120
                                  : 160,
                          style: shadTheme!.textTheme.p.copyWith(
                            height: 1.45,
                            fontSize: fontSize,
                          ),
                        )
                        : TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) {
                            if (!widget.requestInProgress &&
                                !_isComposing &&
                                _canSubmit) {
                              _submit();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: S.of(context).messageHint,
                            hintStyle: TextStyle(
                              fontSize: fontSize,
                              color:
                                  StarsDesktopTokens.of(context).tertiaryText,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 12,
                            ),
                          ),
                          maxLines: 6,
                          minLines: 3,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(fontSize: fontSize),
                        ),
              ),
              SizedBox(height: isDesktop ? 6 : 12),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.controller,
                builder: (context, value, child) {
                  return _buildBottomToolbar(context, fontSize, isDesktop);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomToolbar(
    BuildContext context,
    double fontSize,
    bool isDesktop,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (widget.provider.getOutputModalites().contains(
                    OutputModality.image,
                  ) &&
                  (widget.provider.getSupportImageStyles().isNotEmpty ||
                      widget.provider.getSupportedImageSizes().isNotEmpty))
                _buildImageOptionsMenu(context, isDesktop),
              if (widget.provider.getOutputModalites().contains(
                    OutputModality.video,
                  ) &&
                  widget.provider.getSupportVideoRatios().isNotEmpty)
                _buildVideoOptionsMenu(context, isDesktop),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_supportsAttachments) _buildAttachmentMenu(context, isDesktop),
            const SizedBox(width: 10),
            _buildPrimaryActionButton(context, isDesktop),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachmentMenu(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      final disableAnimations = MediaQuery.disableAnimationsOf(context);
      return ShadPopover(
        controller: _attachmentPopoverController,
        effects: disableAnimations ? const [] : null,
        reverseDuration: disableAnimations ? Duration.zero : null,
        popover:
            (context) => SizedBox(
              width: 220,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.provider.getInputModalites().contains(
                    InputModality.image,
                  ))
                    _buildDesktopPopoverItem(
                      icon: LucideIcons.images,
                      label: S.of(context).chooseFromGallery,
                      onPressed: () {
                        _attachmentPopoverController.hide();
                        widget.onGalleryPressed();
                      },
                    ),
                  if (widget.provider.getInputModalites().contains(
                    InputModality.file,
                  ))
                    _buildDesktopPopoverItem(
                      icon: LucideIcons.fileUp,
                      label: S.of(context).uploadFile,
                      onPressed: () {
                        _attachmentPopoverController.hide();
                        widget.onFilePressed();
                      },
                    ),
                ],
              ),
            ),
        child: _buildCircleActionButton(
          context,
          icon: LucideIcons.plus,
          tooltip: S.of(context).addAttachment,
          focusNode: _attachmentButtonFocusNode,
          active:
              _attachmentPopoverController.isOpen ||
              widget.hasPendingAttachments,
          onPressed: () => _togglePopover(_attachmentPopoverController),
        ),
      );
    }

    return _buildMobileAttachmentMenu(context);
  }

  Widget _buildMobileAttachmentMenu(BuildContext context) {
    final menuChildren = <Widget>[
      if (widget.provider.getInputModalites().contains(InputModality.image))
        MenuItemButton(
          leadingIcon: const Icon(Icons.photo_camera_outlined, size: 18),
          onPressed: widget.onCameraPressed,
          child: Text(S.of(context).takePhoto),
        ),
      if (widget.provider.getInputModalites().contains(InputModality.image))
        MenuItemButton(
          leadingIcon: const Icon(Icons.photo_library_outlined, size: 18),
          onPressed: widget.onGalleryPressed,
          child: Text(S.of(context).chooseFromGallery),
        ),
      if (widget.provider.getInputModalites().contains(InputModality.file))
        MenuItemButton(
          leadingIcon: const Icon(Icons.upload_file_outlined, size: 18),
          onPressed: widget.onFilePressed,
          child: Text(S.of(context).uploadFile),
        ),
    ];

    return MenuAnchor(
      menuChildren: menuChildren,
      builder: (context, controller, child) {
        return _buildCircleActionButton(
          context,
          icon: Icons.add_rounded,
          tooltip: S.of(context).addAttachment,
          active: controller.isOpen || widget.hasPendingAttachments,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }

  Widget _buildImageOptionsMenu(BuildContext context, bool isDesktop) {
    final styles = widget.provider.getSupportImageStyles();
    final sizes = widget.provider.getSupportedImageSizes();

    if (isDesktop) {
      final disableAnimations = MediaQuery.disableAnimationsOf(context);
      return ShadPopover(
        controller: _imageOptionsPopoverController,
        effects: disableAnimations ? const [] : null,
        reverseDuration: disableAnimations ? Duration.zero : null,
        popover:
            (context) => SizedBox(
              width: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (styles.isNotEmpty) ...[
                    _buildPopoverSectionLabel(
                      context,
                      S.of(context).imageStyle,
                    ),
                    const SizedBox(height: 4),
                    for (final style in styles)
                      _buildDesktopPopoverItem(
                        icon: LucideIcons.brush,
                        label: style,
                        selected: selectedImageStyle == style,
                        onPressed: () {
                          setState(() {
                            selectedImageStyle =
                                selectedImageStyle == style ? '' : style;
                          });
                          widget.onImageStyleSelected(selectedImageStyle);
                          _imageOptionsPopoverController.hide();
                        },
                      ),
                  ],
                  if (styles.isNotEmpty && sizes.isNotEmpty)
                    const SizedBox(height: 8),
                  if (sizes.isNotEmpty) ...[
                    _buildPopoverSectionLabel(context, S.of(context).imageSize),
                    const SizedBox(height: 4),
                    for (final size in sizes)
                      _buildDesktopPopoverItem(
                        icon: LucideIcons.ratio,
                        label: size,
                        selected: selectedImageRatio == size,
                        onPressed: () {
                          setState(() {
                            selectedImageRatio = size;
                          });
                          widget.onImageSizeSelected(size);
                          _imageOptionsPopoverController.hide();
                        },
                      ),
                  ],
                ],
              ),
            ),
        child: _buildActionChip(
          context,
          icon: LucideIcons.image,
          label: _imageOptionsLabel(context),
          active: _imageOptionsPopoverController.isOpen,
          onTap: () => _togglePopover(_imageOptionsPopoverController),
        ),
      );
    }

    return MenuAnchor(
      menuChildren: [
        if (styles.isNotEmpty)
          SubmenuButton(
            leadingIcon: const Icon(Icons.brush_outlined, size: 18),
            menuChildren:
                styles
                    .map(
                      (style) => MenuItemButton(
                        leadingIcon:
                            selectedImageStyle == style
                                ? const Icon(Icons.check_rounded, size: 18)
                                : const SizedBox(width: 18),
                        onPressed: () {
                          setState(() {
                            selectedImageStyle =
                                selectedImageStyle == style ? '' : style;
                          });
                          widget.onImageStyleSelected(selectedImageStyle);
                        },
                        child: Text(style),
                      ),
                    )
                    .toList(),
            child: Text(S.of(context).imageStyle),
          ),
        if (sizes.isNotEmpty)
          SubmenuButton(
            leadingIcon: const Icon(Icons.aspect_ratio_outlined, size: 18),
            menuChildren:
                sizes
                    .map(
                      (size) => MenuItemButton(
                        leadingIcon:
                            selectedImageRatio == size
                                ? const Icon(Icons.check_rounded, size: 18)
                                : const SizedBox(width: 18),
                        onPressed: () {
                          setState(() {
                            selectedImageRatio = size;
                          });
                          widget.onImageSizeSelected(size);
                        },
                        child: Text(size),
                      ),
                    )
                    .toList(),
            child: Text(S.of(context).imageSize),
          ),
      ],
      builder: (context, controller, child) {
        return _buildActionChip(
          context,
          icon: Icons.image_outlined,
          label:
              selectedImageStyle.isEmpty
                  ? selectedImageRatio
                  : '$selectedImageStyle · $selectedImageRatio',
          active: controller.isOpen,
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }

  Widget _buildVideoOptionsMenu(BuildContext context, bool isDesktop) {
    final ratios = widget.provider.getSupportVideoRatios();

    if (isDesktop) {
      final disableAnimations = MediaQuery.disableAnimationsOf(context);
      return ShadPopover(
        controller: _videoOptionsPopoverController,
        effects: disableAnimations ? const [] : null,
        reverseDuration: disableAnimations ? Duration.zero : null,
        popover:
            (context) => SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final ratio in ratios)
                    _buildDesktopPopoverItem(
                      icon: LucideIcons.ratio,
                      label: ratio,
                      selected: selectedVideoRatio == ratio,
                      onPressed: () {
                        setState(() {
                          selectedVideoRatio = ratio;
                        });
                        widget.onVideoRatioSelected(ratio);
                        _videoOptionsPopoverController.hide();
                      },
                    ),
                ],
              ),
            ),
        child: _buildActionChip(
          context,
          icon: LucideIcons.video,
          label: selectedVideoRatio,
          active: _videoOptionsPopoverController.isOpen,
          onTap: () => _togglePopover(_videoOptionsPopoverController),
        ),
      );
    }

    return MenuAnchor(
      menuChildren:
          ratios
              .map(
                (ratio) => MenuItemButton(
                  leadingIcon:
                      selectedVideoRatio == ratio
                          ? const Icon(Icons.check_rounded, size: 18)
                          : const SizedBox(width: 18),
                  onPressed: () {
                    setState(() {
                      selectedVideoRatio = ratio;
                    });
                    widget.onVideoRatioSelected(ratio);
                  },
                  child: Text(ratio),
                ),
              )
              .toList(),
      builder: (context, controller, child) {
        return _buildActionChip(
          context,
          icon: Icons.video_camera_back_outlined,
          label: selectedVideoRatio,
          active: controller.isOpen,
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }

  String _imageOptionsLabel(BuildContext context) {
    final parts = [
      if (selectedImageStyle.isNotEmpty) selectedImageStyle,
      if (selectedImageRatio.isNotEmpty) selectedImageRatio,
    ];
    return parts.isEmpty ? S.of(context).imageStyle : parts.join(' · ');
  }

  Widget _buildPopoverSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(label, style: ShadTheme.of(context).textTheme.muted),
    );
  }

  Widget _buildDesktopPopoverItem({
    double width = 220,
    required IconData icon,
    required String label,
    bool selected = false,
    required VoidCallback onPressed,
  }) {
    final leading = ExcludeSemantics(child: Icon(icon, size: 16));
    final trailing =
        selected
            ? const ExcludeSemantics(child: Icon(LucideIcons.check, size: 16))
            : null;
    final child = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
    );
    final button =
        selected
            ? ShadButton.secondary(
              size: ShadButtonSize.sm,
              width: width,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              mainAxisAlignment: MainAxisAlignment.start,
              expands: true,
              leading: leading,
              trailing: trailing,
              onPressed: onPressed,
              child: child,
            )
            : ShadButton.ghost(
              size: ShadButtonSize.sm,
              width: width,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              mainAxisAlignment: MainAxisAlignment.start,
              expands: true,
              leading: leading,
              onPressed: onPressed,
              child: child,
            );
    return Semantics(selected: selected, child: button);
  }

  Widget _buildPrimaryActionButton(BuildContext context, bool isDesktop) {
    final enabled =
        widget.requestInProgress
            ? widget.canCancel && !widget.isStopping
            : _canSubmit;
    final onPressed =
        enabled
            ? (widget.requestInProgress ? widget.onCancelRequest : _submit)
            : null;
    final backgroundColor =
        widget.requestInProgress
            ? StarsDesktopThemeSpec.primaryActionColor(
              context,
            ).withValues(alpha: 0.92)
            : enabled
            ? StarsDesktopThemeSpec.primaryActionColor(context)
            : StarsDesktopThemeSpec.primaryActionColor(
              context,
            ).withValues(alpha: 0.18);
    final foregroundColor =
        enabled
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);

    if (!isDesktop) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          icon: Icon(
            widget.requestInProgress && widget.canCancel
                ? Icons.stop_rounded
                : widget.requestInProgress
                ? Icons.hourglass_top_rounded
                : Icons.send_rounded,
            color: foregroundColor,
          ),
          tooltip:
              widget.requestInProgress
                  ? widget.canCancel
                      ? S.of(context).pauseGeneration
                      : S.of(context).generating
                  : S.of(context).send,
          onPressed: onPressed,
        ),
      );
    }

    final label =
        widget.isStopping
            ? S.of(context).stopping
            : widget.requestInProgress && !widget.canCancel
            ? S.of(context).generating
            : widget.requestInProgress
            ? S.of(context).stop
            : S.of(context).send;
    const actionIconSize = 17.0;
    final icon =
        widget.requestInProgress && widget.canCancel
            ? const _DesktopStopIcon(size: actionIconSize)
            : Icon(
              widget.requestInProgress
                  ? LucideIcons.loaderCircle
                  : LucideIcons.send,
              size: actionIconSize,
            );
    final button =
        widget.requestInProgress
            ? ShadButton.secondary(
              size: ShadButtonSize.sm,
              width: 0,
              height: 36,
              enabled: enabled,
              onPressed: onPressed,
              leading: icon,
              child: Text(label),
            )
            : ShadButton(
              size: ShadButtonSize.sm,
              width: 0,
              height: 36,
              backgroundColor: StarsDesktopThemeSpec.primaryActionColor(
                context,
              ),
              enabled: enabled,
              onPressed: onPressed,
              leading: icon,
              child: Text(label),
            );
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 96),
      child: button,
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final useDesktopStyle = _isDesktop || isDesktopPlatform(context);
    if (useDesktopStyle) {
      final iconWidget = Icon(icon, size: 16);
      return active
          ? ShadButton.secondary(
            size: ShadButtonSize.sm,
            leading: iconWidget,
            onPressed: onTap,
            child: Text(label),
          )
          : ShadButton.outline(
            size: ShadButtonSize.sm,
            leading: iconWidget,
            onPressed: onTap,
            child: Text(label),
          );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color:
              active
                  ? Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.12)
                  : StarsDesktopTokens.of(context).controlFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                active
                    ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.22)
                    : StarsDesktopTokens.of(context).separator,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  active
                      ? Theme.of(context).colorScheme.primary
                      : StarsDesktopTokens.of(context).secondaryText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color:
                    active
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleActionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    FocusNode? focusNode,
    bool active = false,
    required VoidCallback onPressed,
  }) {
    if (_isDesktop || isDesktopPlatform(context)) {
      final effectiveFocusNode = focusNode ?? _attachmentButtonFocusNode;
      return StarsDesktopIconAction(
        icon: icon,
        label: tooltip,
        focusNode: effectiveFocusNode,
        variant:
            active ? ShadButtonVariant.secondary : ShadButtonVariant.outline,
        onPressed: onPressed,
      );
    }
    final foregroundColor =
        active
            ? Theme.of(context).colorScheme.primary
            : StarsDesktopTokens.of(context).secondaryText;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(48),
        maximumSize: const Size.square(48),
        padding: EdgeInsets.zero,
      ),
      icon: DecoratedBox(
        decoration: BoxDecoration(
          color:
              active
                  ? Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.10)
                  : StarsDesktopTokens.of(context).controlFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                active
                    ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2)
                    : StarsDesktopTokens.of(context).separator,
          ),
        ),
        child: SizedBox.square(
          dimension: 34,
          child: Center(
            child: Icon(icon, color: foregroundColor, semanticLabel: tooltip),
          ),
        ),
      ),
    );
  }

  void _submit() {
    widget.onSend();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  bool get _supportsAttachments =>
      widget.provider.getInputModalites().contains(InputModality.image) ||
      widget.provider.getInputModalites().contains(InputModality.file);
}

/// A controlled auto-growing adapter for shadcn_ui 0.55's textarea.
///
/// In 0.55, [ShadTextarea.minHeight] and [ShadTextarea.maxHeight] describe the
/// editable area rather than the complete decorated control. Measuring here
/// keeps the visible control within the desktop composer's 44–120/160 contract.
