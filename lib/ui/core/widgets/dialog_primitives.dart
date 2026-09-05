part of 'desktop_chat_primitives.dart';

/// The close action shared by every primary desktop dialog.
///
/// It matches the Theme Settings dialog: a 44px hit target, an 18px Lucide X,
/// and the platform-localized close tooltip.
class HyveDialogCloseButton extends StatelessWidget {
  const HyveDialogCloseButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.variant = ShadButtonVariant.ghost,
    this.foregroundColor,
    this.hoverBackgroundColor,
  });

  final VoidCallback? onPressed;
  final bool enabled;
  final ShadButtonVariant variant;
  final Color? foregroundColor;
  final Color? hoverBackgroundColor;

  @override
  Widget build(BuildContext context) => HyveDesktopIconAction(
    icon: LucideIcons.x,
    iconSize: 18,
    label: MaterialLocalizations.of(context).closeButtonTooltip,
    enabled: enabled,
    variant: variant,
    foregroundColor: foregroundColor,
    hoverBackgroundColor: hoverBackgroundColor,
    onPressed: onPressed,
  );
}

ShadPosition hyveDialogClosePosition(BuildContext context) =>
    ShadPosition.directional(
      top: 12,
      end: 8,
      textDirection: Directionality.of(context),
    );

/// Canonical sizing modes for primary in-app dialogs.
enum HyveDialogSize {
  /// Lets the dialog follow its content up to the Shad default constraints.
  intrinsic,

  /// Fills the standard large workflow surface while preserving window insets.
  large,
}

const Size hyveLargeDialogMaxSize = Size(840, 720);

/// Resolves the shared large-dialog size from the available app window.
///
/// Keeping this calculation here prevents feature dialogs from drifting apart
/// and ensures resized desktop windows retain a usable outer margin.
Size hyveLargeDialogSizeOf(BuildContext context) {
  final windowSize = MediaQuery.sizeOf(context);
  final inset = windowSize.width < 900 || windowSize.height < 760 ? 16.0 : 24.0;
  return Size(
    (windowSize.width - inset * 2)
        .clamp(0.0, hyveLargeDialogMaxSize.width)
        .toDouble(),
    (windowSize.height - inset * 2)
        .clamp(0.0, hyveLargeDialogMaxSize.height)
        .toDouble(),
  );
}

/// A primary Shad dialog with Hyve's standard accessible close action.
class HyveDialog extends StatelessWidget {
  const HyveDialog({
    super.key,
    this.title,
    this.description,
    this.child,
    this.actions = const <Widget>[],
    this.showCloseButton = true,
    this.closeButtonKey,
    this.closeButtonEnabled = true,
    this.onClose,
    this.closeButtonVariant = ShadButtonVariant.ghost,
    this.closeButtonForegroundColor,
    this.closeButtonHoverBackgroundColor,
    this.radius,
    this.backgroundColor,
    this.expandActionsWhenTiny,
    this.padding,
    this.gap,
    this.constraints,
    this.size = HyveDialogSize.intrinsic,
    this.border,
    this.shadows,
    this.removeBorderRadiusWhenTiny,
    this.actionsAxis,
    this.actionsMainAxisSize,
    this.actionsMainAxisAlignment,
    this.actionsVerticalDirection,
    this.titleStyle,
    this.descriptionStyle,
    this.titleTextAlign,
    this.descriptionTextAlign,
    this.alignment,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.scrollable,
    this.scrollPadding,
    this.actionsGap,
    this.useSafeArea,
    this.titlePinned,
    this.descriptionPinned,
    this.actionsPinned,
  }) : assert(
         size == HyveDialogSize.intrinsic || constraints == null,
         'Large dialogs use the shared responsive constraints.',
       );

  final Widget? title;
  final Widget? description;
  final Widget? child;
  final List<Widget> actions;
  final bool showCloseButton;
  final Key? closeButtonKey;
  final bool closeButtonEnabled;
  final VoidCallback? onClose;
  final ShadButtonVariant closeButtonVariant;
  final Color? closeButtonForegroundColor;
  final Color? closeButtonHoverBackgroundColor;
  final BorderRadius? radius;
  final Color? backgroundColor;
  final bool? expandActionsWhenTiny;
  final EdgeInsetsGeometry? padding;
  final double? gap;
  final BoxConstraints? constraints;
  final HyveDialogSize size;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;
  final bool? removeBorderRadiusWhenTiny;
  final Axis? actionsAxis;
  final MainAxisSize? actionsMainAxisSize;
  final MainAxisAlignment? actionsMainAxisAlignment;
  final VerticalDirection? actionsVerticalDirection;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final TextAlign? titleTextAlign;
  final TextAlign? descriptionTextAlign;
  final Alignment? alignment;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final bool? scrollable;
  final EdgeInsetsGeometry? scrollPadding;
  final double? actionsGap;
  final bool? useSafeArea;
  final bool? titlePinned;
  final bool? descriptionPinned;
  final bool? actionsPinned;

  @override
  Widget build(BuildContext context) {
    final effectiveConstraints = switch (size) {
      HyveDialogSize.intrinsic => constraints,
      HyveDialogSize.large => BoxConstraints.tight(
        hyveLargeDialogSizeOf(context),
      ),
    };
    return ShadDialog(
      title: title,
      description: description,
      actions: actions,
      closeIcon:
          showCloseButton
              ? HyveDialogCloseButton(
                key: closeButtonKey,
                enabled: closeButtonEnabled,
                variant: closeButtonVariant,
                foregroundColor: closeButtonForegroundColor,
                hoverBackgroundColor: closeButtonHoverBackgroundColor,
                onPressed:
                    closeButtonEnabled
                        ? onClose ?? () => Navigator.of(context).pop()
                        : null,
              )
              : const SizedBox.shrink(),
      closeIconPosition: hyveDialogClosePosition(context),
      radius: radius,
      backgroundColor: backgroundColor,
      expandActionsWhenTiny: expandActionsWhenTiny,
      padding: padding,
      gap: gap,
      constraints: effectiveConstraints,
      border: border,
      shadows: shadows,
      removeBorderRadiusWhenTiny: removeBorderRadiusWhenTiny,
      actionsAxis: actionsAxis,
      actionsMainAxisSize: actionsMainAxisSize,
      actionsMainAxisAlignment: actionsMainAxisAlignment,
      actionsVerticalDirection: actionsVerticalDirection,
      titleStyle: titleStyle,
      descriptionStyle: descriptionStyle,
      titleTextAlign: titleTextAlign,
      descriptionTextAlign: descriptionTextAlign,
      alignment: alignment,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      scrollable: scrollable,
      scrollPadding: scrollPadding,
      actionsGap: actionsGap,
      useSafeArea: useSafeArea,
      titlePinned: titlePinned,
      descriptionPinned: descriptionPinned,
      actionsPinned: actionsPinned,
      child: child,
    );
  }
}
