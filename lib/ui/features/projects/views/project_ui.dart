import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/core/widgets/logo.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/utils/theme.dart';

const double projectContentMaxWidth = 920;
const double projectInspectorWidth = 392;
const double projectCompactWidth = 560;

bool hasShadProjectTheme(BuildContext context) =>
    ShadTheme.maybeOf(context) != null;

/// Keeps an actor's avatar presentation consistent across project surfaces.
///
/// For agent actors, the current [agent] is authoritative. Snapshot values
/// also support user and historical actors that have no current agent record.
final class ProjectActorAvatar extends StatelessWidget {
  const ProjectActorAvatar({
    super.key,
    this.agent,
    this.fallbackName = '',
    this.fallbackAvatar = '',
    this.size = 40,
  });

  final Agent? agent;
  final String fallbackName;
  final String fallbackAvatar;
  final double size;

  String get _avatarPath {
    final currentAgent = agent;
    return (currentAgent == null ? fallbackAvatar : currentAgent.avatar).trim();
  }

  String get _initial {
    final currentName = agent?.name.trim();
    final normalized =
        currentName == null || currentName.isEmpty
            ? fallbackName.trim()
            : currentName;
    return normalized.isEmpty
        ? '?'
        : String.fromCharCode(normalized.runes.first).toUpperCase();
  }

  ImageProvider<Object>? _materialImage(String avatarPath) {
    if (avatarPath.isEmpty) return null;
    if (avatarPath.startsWith('assets/')) return AssetImage(avatarPath);
    final uri = Uri.tryParse(avatarPath);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(avatarPath);
    }
    return FileImage(File(avatarPath));
  }

  @override
  Widget build(BuildContext context) {
    final currentAgent = agent;
    final avatarPath = _avatarPath;
    final hasAvatar = avatarPath.isNotEmpty;
    final shadTheme = ShadTheme.maybeOf(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor =
        hasAvatar
            ? primaryColor
            : currentAgent == null
            ? shadTheme?.colorScheme.muted ??
                Theme.of(context).colorScheme.surfaceContainerHighest
            : getFrostedProviderColor(currentAgent.provider, primaryColor);
    final placeholder =
        currentAgent == null
            ? Text(
              _initial,
              style:
                  shadTheme?.textTheme.small.copyWith(
                    color: shadTheme.colorScheme.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ) ??
                  Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            )
            : buildProviderLogo(context, '', currentAgent.provider, size / 2);
    if (shadTheme != null) {
      return ShadAvatar(
        hasAvatar ? avatarPath : null,
        size: Size.square(size),
        backgroundColor: backgroundColor,
        placeholder: placeholder,
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      backgroundImage: _materialImage(avatarPath),
      child: hasAvatar ? null : placeholder,
    );
  }
}

/// Keeps every primary project workspace section on the same responsive axis.
final class ProjectContentBounds extends StatelessWidget {
  const ProjectContentBounds({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: projectContentMaxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    ),
  );
}

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
    this.variant = ShadButtonVariant.ghost,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool? selected;
  final bool destructive;
  final ShadButtonVariant variant;

  @override
  Widget build(BuildContext context) => HyveDesktopIconAction(
    icon: icon,
    label: label,
    onPressed: onPressed,
    selected: selected,
    variant: destructive ? ShadButtonVariant.destructive : variant,
  );
}

/// Consistent title, annotation, and bordered icon for project sections.
final class ProjectSectionHeader extends StatelessWidget {
  const ProjectSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.maybeOf(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (shadTheme == null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, semanticLabel: title),
          )
        else
          Container(
            key: const ValueKey<String>('project-section-header-icon-frame'),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: shadTheme.colorScheme.border),
              borderRadius: shadTheme.radius,
            ),
            child: Icon(
              icon,
              size: 18,
              color: shadTheme.colorScheme.foreground,
              semanticLabel: title,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  title,
                  style:
                      shadTheme?.textTheme.h4 ??
                      Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style:
                    shadTheme?.textTheme.muted ??
                    Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (trailing case final trailing?) trailing,
      ],
    );
  }
}

/// Standard back navigation used by project detail surfaces.
///
/// Keeping the outline variant here ensures section-to-message navigation and
/// artifact directory navigation retain the same Shad interaction styling.
final class ProjectBackAction extends StatelessWidget {
  const ProjectBackAction({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ProjectIconAction(
    icon: LucideIcons.arrowLeft,
    label: label,
    onPressed: onPressed,
    variant: ShadButtonVariant.outline,
  );
}

/// Compact previous/next pagination shared by project detail lists.
final class ProjectPagination extends StatelessWidget {
  const ProjectPagination({
    super.key,
    required this.keyPrefix,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  }) : assert(keyPrefix.length > 0),
       assert(currentPage > 0),
       assert(totalPages > 0),
       assert(currentPage <= totalPages);

  final String keyPrefix;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ProjectIconAction(
          key: ValueKey<String>('$keyPrefix-previous-page'),
          icon: LucideIcons.chevronLeft,
          label: localizations.previousPageTooltip,
          variant: ShadButtonVariant.outline,
          onPressed: onPrevious,
        ),
        const SizedBox(width: 12),
        Semantics(
          label: '$currentPage / $totalPages',
          child: Text(
            '$currentPage / $totalPages',
            key: ValueKey<String>('$keyPrefix-page-indicator'),
          ),
        ),
        const SizedBox(width: 12),
        ProjectIconAction(
          key: ValueKey<String>('$keyPrefix-next-page'),
          icon: LucideIcons.chevronRight,
          label: localizations.nextPageTooltip,
          variant: ShadButtonVariant.outline,
          onPressed: onNext,
        ),
      ],
    );
  }
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

/// Responsive disclosure that uses the Shad accordion interaction on desktop
/// and the native Material expansion pattern in the mobile-only theme.
final class ProjectDisclosure extends StatelessWidget {
  const ProjectDisclosure({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.childrenPadding,
    this.trailing,
    this.expandedCrossAxisAlignment = CrossAxisAlignment.center,
  });

  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final EdgeInsetsGeometry childrenPadding;
  final CrossAxisAlignment expandedCrossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (!hasShadProjectTheme(context)) {
      return ExpansionTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        childrenPadding: childrenPadding,
        expandedCrossAxisAlignment: expandedCrossAxisAlignment,
        children: children,
      );
    }

    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final shadTheme = ShadTheme.of(context);
    return ShadAccordion<String>(
      children: <ShadAccordionItem<String>>[
        ShadAccordionItem<String>(
          value: 'details',
          separator: const SizedBox.shrink(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration:
              disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
          underlineTitleOnHover: false,
          iconData: LucideIcons.chevronDown,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconTheme.merge(
                data: const IconThemeData(size: 20),
                child: leading,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DefaultTextStyle.merge(
                      style: shadTheme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      child: title,
                    ),
                    const SizedBox(height: 3),
                    DefaultTextStyle.merge(
                      style: shadTheme.textTheme.muted,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      child: subtitle,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
          child: Padding(
            padding: childrenPadding,
            child: Column(
              crossAxisAlignment: expandedCrossAxisAlignment,
              children: children,
            ),
          ),
        ),
      ],
    );
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
    this.showLabel = true,
  });

  final TextEditingController controller;
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    if (hasShadProjectTheme(context)) {
      final theme = ShadTheme.of(context);
      final input = ShadInput(
        controller: controller,
        focusNode: focusNode,
        padding: HyveDesktopThemeSpec.formFieldPadding,
        placeholder: Text(label),
        leading:
            leading != null
                ? SizedBox(height: 44, child: Center(child: leading))
                : leading,
        trailing: trailing,
        enabled: enabled,
        alignment: AlignmentDirectional.centerStart,
        placeholderAlignment: AlignmentDirectional.centerStart,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      );
      if (!showLabel) return input;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: theme.textTheme.small),
          const SizedBox(height: 6),
          input,
        ],
      );
    }
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        labelText: showLabel ? label : null,
        hintText: showLabel ? null : label,
        isDense: !showLabel,
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
    if (shadTheme != null && description != null) {
      return DesktopEmptyStateCard(
        icon: icon,
        title: title,
        description: description!,
        action: action,
      );
    }
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
      return HyveDialog(
        padding: EdgeInsets.zero,
        gap: 0,
        scrollable: false,
        closeButtonKey: const ValueKey<String>('project-dialog-close'),
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
        return HyveDialog(
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
