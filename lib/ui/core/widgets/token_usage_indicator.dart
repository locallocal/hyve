import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';

/// Icon-led token usage display shared by conversation and bot detail views.
class TokenUsageIndicator extends StatelessWidget {
  const TokenUsageIndicator({
    super.key,
    required this.usage,
    this.showBreakdown = false,
  });

  final ModelTokenUsage usage;
  final bool showBreakdown;

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    final numberFormat = NumberFormat.compact(
      locale: Localizations.localeOf(context).toString(),
    );
    final semanticsLabel =
        usage.hasData
            ? '${localizations.tokenUsage}: '
                '${localizations.totalTokens} '
                '${usage.effectiveTotalTokens}, '
                '${localizations.inputTokens} ${usage.inputTokens}, '
                '${localizations.outputTokens} ${usage.outputTokens}'
            : '${localizations.tokenUsage}: '
                '${localizations.noTokenUsageRecorded}';

    if (showBreakdown) {
      return Semantics(
        container: true,
        label: semanticsLabel,
        child: ExcludeSemantics(
          child: Wrap(
            key: const ValueKey<String>('token-usage-breakdown'),
            spacing: 12,
            runSpacing: 12,
            children: [
              _TokenMetric(
                key: const ValueKey<String>('token-usage-total'),
                icon: Icons.data_usage_rounded,
                label: localizations.totalTokens,
                value: numberFormat.format(usage.effectiveTotalTokens),
              ),
              _TokenMetric(
                key: const ValueKey<String>('token-usage-input'),
                icon: Icons.login_rounded,
                label: localizations.inputTokens,
                value: numberFormat.format(usage.inputTokens),
              ),
              _TokenMetric(
                key: const ValueKey<String>('token-usage-output'),
                icon: Icons.logout_rounded,
                label: localizations.outputTokens,
                value: numberFormat.format(usage.outputTokens),
              ),
            ],
          ),
        ),
      );
    }

    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: semanticsLabel,
      child: Semantics(
        label: semanticsLabel,
        child: ExcludeSemantics(
          child: Container(
            key: const ValueKey<String>('token-usage-indicator'),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.data_usage_rounded,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Text(
                  numberFormat.format(usage.effectiveTotalTokens),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TokenMetric extends StatelessWidget {
  const _TokenMetric({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 132),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 19, color: colors.primary),
              const SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
