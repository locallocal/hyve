import 'package:hyve/generated/l10n.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/ai_provider_repository.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/utils/theme.dart';
import 'package:hyve/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

part 'message_input_textarea.dart';
part 'message_input_menus.dart';
part 'message_input_toolbar.dart';

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
  void _updateState(VoidCallback callback) => setState(callback);

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
                    ? HyveDesktopThemeSpec.containerRadius
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
                        ? HyveChatTextarea(
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
                              color: HyveDesktopTokens.of(context).tertiaryText,
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
}
