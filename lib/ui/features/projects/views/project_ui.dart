import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';

const double projectContentMaxWidth = 920;
const double projectInspectorWidth = 392;
const double projectCompactWidth = 560;

bool hasShadProjectTheme(BuildContext context) =>
    ShadTheme.maybeOf(context) != null;

enum ProjectActionVariant { primary, secondary, outline, ghost, destructive }

enum ProjectBadgeVariant { primary, secondary, outline, destructive }

final class ProjectSelectOption<T> {
  const ProjectSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

final class ProjectMenuItem<T> {
  const ProjectMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.destructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool destructive;
}

/// Keeps project pages aligned with the app's Shadcn desktop system while
/// retaining the Material-only mobile shell.
final class ProjectThemeScope extends StatelessWidget {
  const ProjectThemeScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final baseTheme = ShadTheme.maybeOf(context);
    if (baseTheme == null) return child;
    return ShadTheme(
      data: baseTheme.copyWith(
        cardTheme: baseTheme.cardTheme.copyWith(shadows: const []),
      ),
      child: child,
    );
  }
}

final class ProjectActionButton extends StatelessWidget {
  const ProjectActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.variant = ProjectActionVariant.primary,
    this.compact = true,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final ProjectActionVariant variant;
  final bool compact;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (hasShadProjectTheme(context)) {
      return ShadButton.raw(
        variant: switch (variant) {
          ProjectActionVariant.primary => ShadButtonVariant.primary,
          ProjectActionVariant.secondary => ShadButtonVariant.secondary,
          ProjectActionVariant.outline => ShadButtonVariant.outline,
          ProjectActionVariant.ghost => ShadButtonVariant.ghost,
          ProjectActionVariant.destructive => ShadButtonVariant.destructive,
        },
        size: compact ? ShadButtonSize.sm : ShadButtonSize.regular,
        width: width,
        enabled: onPressed != null,
        onPressed: onPressed,
        leading: leading,
        child: Text(label),
      );
    }

    final child = Text(label);
    final icon = leading;
    return switch (variant) {
      ProjectActionVariant.primary =>
        icon == null
            ? FilledButton(onPressed: onPressed, child: child)
            : FilledButton.icon(onPressed: onPressed, icon: icon, label: child),
      ProjectActionVariant.secondary || ProjectActionVariant.outline =>
        icon == null
            ? OutlinedButton(onPressed: onPressed, child: child)
            : OutlinedButton.icon(
              onPressed: onPressed,
              icon: icon,
              label: child,
            ),
      ProjectActionVariant.ghost =>
        icon == null
            ? TextButton(onPressed: onPressed, child: child)
            : TextButton.icon(onPressed: onPressed, icon: icon, label: child),
      ProjectActionVariant.destructive => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        onPressed: onPressed,
        child:
            icon == null
                ? child
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [icon, const SizedBox(width: 8), child],
                ),
      ),
    };
  }
}

final class ProjectIconAction extends StatelessWidget {
  const ProjectIconAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool? selected;
  final bool destructive;

  @override
  Widget build(BuildContext context) => HyveDesktopIconAction(
    icon: icon,
    label: label,
    onPressed: onPressed,
    selected: selected,
    variant:
        destructive ? ShadButtonVariant.destructive : ShadButtonVariant.ghost,
  );
}

final class ProjectBadge extends StatelessWidget {
  const ProjectBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = ProjectBadgeVariant.outline,
    this.onPressed,
  });

  final String label;
  final IconData? icon;
  final ProjectBadgeVariant variant;
  final VoidCallback? onPressed;

  Widget get _child => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (icon != null) ...[Icon(icon, size: 14), const SizedBox(width: 6)],
      Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    if (hasShadProjectTheme(context)) {
      return ShadBadge.raw(
        variant: switch (variant) {
          ProjectBadgeVariant.primary => ShadBadgeVariant.primary,
          ProjectBadgeVariant.secondary => ShadBadgeVariant.secondary,
          ProjectBadgeVariant.outline => ShadBadgeVariant.outline,
          ProjectBadgeVariant.destructive => ShadBadgeVariant.destructive,
        },
        onPressed: onPressed,
        child: _child,
      );
    }
    if (onPressed == null) {
      return Chip(
        avatar: icon == null ? null : Icon(icon, size: 16),
        label: Text(label),
      );
    }
    return ActionChip(
      avatar: icon == null ? null : Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

final class ProjectSurfaceCard extends StatelessWidget {
  const ProjectSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 8),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final card =
        hasShadProjectTheme(context)
            ? ShadCard(width: double.infinity, padding: padding, child: child)
            : Card(
              margin: EdgeInsets.zero,
              child: Padding(padding: padding, child: child),
            );
    return Padding(padding: margin, child: card);
  }
}

final class ProjectOverflowMenu<T> extends StatelessWidget {
  const ProjectOverflowMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.label,
  });

  final List<ProjectMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel =
        label ?? MaterialLocalizations.of(context).moreButtonTooltip;
    if (hasShadProjectTheme(context)) {
      return HyveDesktopMenu<T>(
        items: [
          for (final item in items)
            HyveDesktopMenuItem<T>(
              value: item.value,
              label: item.label,
              leading: item.icon == null ? null : Icon(item.icon, size: 16),
              destructive: item.destructive,
            ),
        ],
        onSelected: onSelected,
        alignEnd: true,
        triggerBuilder:
            (_, toggle, isOpen) => ProjectIconAction(
              icon: LucideIcons.ellipsis,
              label: effectiveLabel,
              selected: isOpen,
              onPressed: toggle,
            ),
      );
    }
    return PopupMenuButton<T>(
      tooltip: effectiveLabel,
      onSelected: onSelected,
      itemBuilder:
          (_) => [
            for (final item in items)
              PopupMenuItem<T>(
                value: item.value,
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      Icon(item.icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(item.label),
                  ],
                ),
              ),
          ],
    );
  }
}

final class ProjectTextInput extends StatelessWidget {
  const ProjectTextInput({
    super.key,
    required this.controller,
    required this.label,
    this.leading,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (hasShadProjectTheme(context)) {
      final theme = ShadTheme.of(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: theme.textTheme.small),
          const SizedBox(height: 6),
          ShadInput(
            controller: controller,
            focusNode: focusNode,
            placeholder: Text(label),
            leading: leading,
            trailing: trailing,
            enabled: enabled,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ],
      );
    }
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: leading,
        suffixIcon: trailing,
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

final class ProjectSelect<T> extends StatelessWidget {
  const ProjectSelect({
    super.key,
    required this.options,
    required this.placeholder,
    required this.onChanged,
    this.initialValue,
    this.enabled = true,
  });

  final List<ProjectSelectOption<T>> options;
  final String placeholder;
  final T? initialValue;
  final bool enabled;
  final ValueChanged<T?>? onChanged;

  String _labelFor(T value) =>
      options.firstWhere((option) => option.value == value).label;

  @override
  Widget build(BuildContext context) {
    if (hasShadProjectTheme(context)) {
      return ShadSelect<T>(
        initialValue: initialValue,
        enabled: enabled,
        placeholder: Text(placeholder),
        minWidth: 180,
        maxHeight: 320,
        selectedOptionBuilder: (_, value) => Text(_labelFor(value)),
        options: [
          for (final option in options)
            ShadOption<T>(value: option.value, child: Text(option.label)),
        ],
        onChanged: onChanged,
      );
    }
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      isExpanded: true,
      decoration: InputDecoration(labelText: placeholder),
      hint: Text(placeholder, overflow: TextOverflow.ellipsis),
      items: [
        for (final option in options)
          DropdownMenuItem<T>(
            value: option.value,
            child: Text(option.label, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}

final class ProjectEmptyState extends StatelessWidget {
  const ProjectEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.maybeOf(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color:
                    shadTheme?.colorScheme.mutedForeground ??
                    Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    shadTheme?.textTheme.large ??
                    Theme.of(context).textTheme.titleMedium,
              ),
              if (description != null) ...[
                const SizedBox(height: 6),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style:
                      shadTheme?.textTheme.muted ??
                      Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}

final class ProjectDialogSurface extends StatelessWidget {
  const ProjectDialogSurface({
    super.key,
    required this.child,
    required this.constraints,
    this.embedded = false,
  });

  final Widget child;
  final BoxConstraints constraints;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(constraints: constraints, child: child);
    if (embedded) return content;
    if (hasShadProjectTheme(context)) {
      return ShadDialog(
        padding: EdgeInsets.zero,
        gap: 0,
        scrollable: false,
        closeIcon: const SizedBox.shrink(),
        constraints: constraints,
        child: content,
      );
    }
    return Dialog(child: content);
  }
}

Future<T?> showProjectDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  if (hasShadProjectTheme(context)) {
    return showShadDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: builder,
  );
}

Future<bool> showProjectConfirmation({
  required BuildContext context,
  required String title,
  required String description,
  required String cancelLabel,
  required String confirmLabel,
  bool destructive = false,
  Key? confirmKey,
}) async {
  final confirmed = await showProjectDialog<bool>(
    context: context,
    builder: (dialogContext) {
      if (hasShadProjectTheme(dialogContext)) {
        return ShadDialog.alert(
          title: Text(title),
          description: Text(description),
          actions: [
            ShadButton.outline(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(cancelLabel),
            ),
            ShadButton.raw(
              key: confirmKey,
              variant:
                  destructive
                      ? ShadButtonVariant.destructive
                      : ShadButtonVariant.primary,
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(confirmLabel),
            ),
          ],
        );
      }
      return AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            key: confirmKey,
            style:
                destructive
                    ? FilledButton.styleFrom(
                      backgroundColor:
                          Theme.of(dialogContext).colorScheme.error,
                      foregroundColor:
                          Theme.of(dialogContext).colorScheme.onError,
                    )
                    : null,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

Future<bool> showProjectFormDialog({
  required BuildContext context,
  required String title,
  required WidgetBuilder contentBuilder,
  required String cancelLabel,
  required String confirmLabel,
  bool destructive = false,
  Key? confirmKey,
}) async {
  final confirmed = await showProjectDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final content = contentBuilder(dialogContext);
      if (hasShadProjectTheme(dialogContext)) {
        return ShadDialog(
          title: Text(title),
          actions: [
            ShadButton.outline(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(cancelLabel),
            ),
            ShadButton.raw(
              key: confirmKey,
              variant:
                  destructive
                      ? ShadButtonVariant.destructive
                      : ShadButtonVariant.primary,
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(confirmLabel),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: content,
          ),
        );
      }
      return AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            key: confirmKey,
            style:
                destructive
                    ? FilledButton.styleFrom(
                      backgroundColor:
                          Theme.of(dialogContext).colorScheme.error,
                      foregroundColor:
                          Theme.of(dialogContext).colorScheme.onError,
                    )
                    : null,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
