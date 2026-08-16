part of 'message_input.dart';

extension _MessageInputToolbar on _MessageInputState {
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
