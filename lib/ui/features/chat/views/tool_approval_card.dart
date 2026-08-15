import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/utils/theme.dart';

final class ToolApprovalCard extends StatelessWidget {
  const ToolApprovalCard({
    super.key,
    required this.request,
    required this.onDecision,
    this.desktopMode = false,
  });

  static const _desktopMaxContentHeight = 360.0;
  static const _mobileMaxContentHeight = 320.0;

  final ToolApprovalRequest request;
  final ValueChanged<ToolApprovalDecision> onDecision;
  final bool desktopMode;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final toolTitle =
        request.definition.title.trim().isEmpty
            ? request.definition.name
            : request.definition.title.trim();
    final riskColor = _riskColor(context);
    final hasDetails =
        request.definition.description.trim().isNotEmpty ||
        request.call.arguments.isNotEmpty;
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final maxContentHeight =
        (viewportHeight * (desktopMode ? 0.42 : 0.35))
            .clamp(
              140.0,
              desktopMode ? _desktopMaxContentHeight : _mobileMaxContentHeight,
            )
            .toDouble();
    final content = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxContentHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, strings, toolTitle, riskColor),
          if (hasDetails)
            Flexible(
              child: SingleChildScrollView(
                key: const ValueKey<String>('tool-approval-scroll'),
                child: _buildDetails(context, strings),
              ),
            ),
          const SizedBox(height: 14),
          desktopMode
              ? const ShadSeparator.horizontal()
              : const Divider(height: 1),
          const SizedBox(height: 12),
          _buildActions(context, strings),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        container: true,
        liveRegion: true,
        label:
            '${strings.toolCalls}: $toolTitle, '
            '${request.definition.riskLevel.name}',
        child:
            desktopMode
                ? ShadCard(
                  key: const ValueKey<String>('tool-approval-card'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  backgroundColor: StarsDesktopTokens.of(context).controlFill,
                  radius: StarsDesktopThemeSpec.statusRadius,
                  border: ShadBorder.all(
                    color: riskColor.withValues(alpha: 0.32),
                  ),
                  child: content,
                )
                : Container(
                  key: const ValueKey<String>('tool-approval-card'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer.withValues(alpha: 0.45),
                    border: Border.all(
                      color: riskColor.withValues(alpha: 0.32),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: content,
                ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, S strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (request.definition.description.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            request.definition.description.trim(),
            style:
                desktopMode
                    ? StarsDesktopThemeSpec.bodyStyle(context)
                    : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        if (request.call.arguments.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildArguments(context, strings),
        ],
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    S strings,
    String toolTitle,
    Color riskColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ExcludeSemantics(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.12),
              borderRadius:
                  desktopMode
                      ? StarsDesktopThemeSpec.itemRadius
                      : BorderRadius.circular(10),
            ),
            child: Icon(_riskIcon, size: 18, color: riskColor),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.toolCalls,
                style:
                    desktopMode
                        ? StarsDesktopThemeSpec.metaStyle(context)
                        : Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
              ),
              const SizedBox(height: 2),
              Text(
                toolTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    desktopMode
                        ? StarsDesktopThemeSpec.toolbarTitleStyle(context)
                        : Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _buildRiskBadge(context, riskColor),
      ],
    );
  }

  Widget _buildRiskBadge(BuildContext context, Color riskColor) {
    final label = request.definition.riskLevel.name;
    if (desktopMode) {
      return ShadBadge.raw(
        key: const ValueKey<String>('tool-approval-risk'),
        variant: switch (request.definition.riskLevel) {
          ToolRiskLevel.readOnly => ShadBadgeVariant.outline,
          ToolRiskLevel.write => ShadBadgeVariant.secondary,
          ToolRiskLevel.destructive => ShadBadgeVariant.destructive,
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label),
      );
    }

    return Container(
      key: const ValueKey<String>('tool-approval-risk'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.1),
        border: Border.all(color: riskColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: riskColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildArguments(BuildContext context, S strings) {
    final summary = request.call.arguments.entries
        .map((entry) => '${entry.key}: ${_formatArgumentValue(entry.value)}')
        .join('\n');
    final foreground =
        desktopMode
            ? StarsDesktopThemeSpec.text(context)
            : Theme.of(context).colorScheme.onSurface;
    final panel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              desktopMode ? LucideIcons.braces : Icons.data_object_rounded,
              size: 16,
              color:
                  desktopMode
                      ? StarsDesktopThemeSpec.mutedText(context)
                      : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 7),
            Text(
              strings.details,
              style:
                  desktopMode
                      ? StarsDesktopThemeSpec.sectionTitleStyle(context)
                      : Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SelectableText(
          summary,
          key: const ValueKey<String>('tool-approval-arguments'),
          style: TextStyle(
            color: foreground,
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.55,
          ),
        ),
      ],
    );

    if (desktopMode) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: StarsDesktopThemeSpec.raisedSurface(context),
          border: Border.all(color: StarsDesktopThemeSpec.outline(context)),
          borderRadius: StarsDesktopThemeSpec.controlRadius,
        ),
        child: panel,
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: panel,
    );
  }

  Widget _buildActions(BuildContext context, S strings) {
    if (desktopMode) {
      final approveButton =
          request.definition.riskLevel == ToolRiskLevel.destructive
              ? ShadButton.destructive(
                key: const ValueKey<String>('approve-tool-call'),
                size: ShadButtonSize.sm,
                width: 0,
                leading: const Icon(LucideIcons.shieldCheck, size: 15),
                onPressed: () => onDecision(ToolApprovalDecision.allowOnce),
                child: Text(strings.confirm),
              )
              : ShadButton(
                key: const ValueKey<String>('approve-tool-call'),
                size: ShadButtonSize.sm,
                width: 0,
                leading: const Icon(LucideIcons.shieldCheck, size: 15),
                onPressed: () => onDecision(ToolApprovalDecision.allowOnce),
                child: Text(strings.confirm),
              );
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            ShadButton.outline(
              key: const ValueKey<String>('deny-tool-call'),
              size: ShadButtonSize.sm,
              width: 0,
              leading: const Icon(LucideIcons.x, size: 15),
              onPressed: () => onDecision(ToolApprovalDecision.deny),
              child: Text(strings.cancel),
            ),
            approveButton,
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            key: const ValueKey<String>('deny-tool-call'),
            onPressed: () => onDecision(ToolApprovalDecision.deny),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: Text(strings.cancel),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            key: const ValueKey<String>('approve-tool-call'),
            style:
                request.definition.riskLevel == ToolRiskLevel.destructive
                    ? FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    )
                    : null,
            onPressed: () => onDecision(ToolApprovalDecision.allowOnce),
            icon: const Icon(Icons.verified_user_outlined, size: 18),
            label: Text(strings.confirm),
          ),
        ),
      ],
    );
  }

  Color _riskColor(BuildContext context) => switch (request
      .definition
      .riskLevel) {
    ToolRiskLevel.readOnly => Theme.of(context).colorScheme.primary,
    ToolRiskLevel.write => StarsDesktopThemeSpec.warning(context),
    ToolRiskLevel.destructive => StarsDesktopThemeSpec.error(context),
  };

  IconData get _riskIcon => switch (request.definition.riskLevel) {
    ToolRiskLevel.readOnly => LucideIcons.eye,
    ToolRiskLevel.write => LucideIcons.filePenLine,
    ToolRiskLevel.destructive => LucideIcons.triangleAlert,
  };

  String _formatArgumentValue(Object? value) {
    if (value is String) return value;
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } on JsonUnsupportedObjectError {
      return value.toString();
    }
  }
}
