part of 'message_input.dart';

extension _MessageInputMenus on _MessageInputState {
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
                          _updateState(() {
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
                          _updateState(() {
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
                          _updateState(() {
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
                          _updateState(() {
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
                        _updateState(() {
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
                    _updateState(() {
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
}
