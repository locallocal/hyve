import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/features/chat/view_models/chat_token_usage_view_model.dart';
import 'package:stars/utils/theme.dart';

class ConversationTokenUsagePanel extends StatelessWidget {
  const ConversationTokenUsagePanel({super.key, required this.viewModel});

  final ChatTokenUsageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final hourly = viewModel.granularity == TokenUsageGranularity.hour;
        final selectedDay = viewModel.selectedDay;
        final locale = Localizations.localeOf(context).toString();
        return Column(
          key: const ValueKey<String>('conversation-token-usage-panel'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(height: 25),
            Text(
              key: const ValueKey<String>('token-usage-section-title'),
              S.of(context).tokenUsage,
              style: DesktopThemeTokens.sectionTitleStyle(context),
            ),
            const SizedBox(height: 12),
            if (viewModel.isLoading && viewModel.dailyBuckets.isEmpty)
              const Center(
                child: SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else ...[
              _InspectorTokenUsageSummary(usage: viewModel.visibleTotalUsage),
              const Divider(
                key: ValueKey<String>('token-usage-section-divider'),
                height: 25,
              ),
              Row(
                key: const ValueKey<String>('token-usage-granularity-header'),
                children: [
                  Expanded(
                    child: Text(
                      key: const ValueKey<String>(
                        'token-usage-granularity-title',
                      ),
                      hourly
                          ? S.of(context).hourlyTokenUsage
                          : S.of(context).dailyTokenUsage,
                      style: DesktopThemeTokens.sectionTitleStyle(context),
                    ),
                  ),
                  if (hourly)
                    IconButton(
                      key: const ValueKey<String>('token-usage-back-to-daily'),
                      visualDensity: VisualDensity.compact,
                      tooltip: S.of(context).backToDailyUsage,
                      onPressed: viewModel.showDaily,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    ),
                ],
              ),
              if (selectedDay != null) ...[
                const SizedBox(height: 2),
                Text(
                  DateFormat.yMMMd(locale).format(selectedDay),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ] else if (viewModel.dailyBuckets.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  key: const ValueKey<String>('token-usage-drilldown-hint'),
                  S.of(context).clickDayForHourlyUsage,
                  style: DesktopThemeTokens.metaStyle(context),
                ),
              ],
              const SizedBox(height: 10),
              TokenUsageChart(
                buckets: viewModel.visibleBuckets,
                granularity: viewModel.granularity,
                onBucketSelected:
                    hourly
                        ? null
                        : (bucket) => viewModel.selectDay(bucket.start),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _InspectorTokenUsageSummary extends StatelessWidget {
  const _InspectorTokenUsageSummary({required this.usage});

  final ModelTokenUsage usage;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.compact(
      locale: Localizations.localeOf(context).toString(),
    );
    return Semantics(
      container: true,
      label:
          '${S.of(context).tokenUsage}: '
          '${S.of(context).totalTokens} ${usage.effectiveTotalTokens}, '
          '${S.of(context).inputTokens} ${usage.inputTokens}, '
          '${S.of(context).outputTokens} ${usage.outputTokens}',
      child: ExcludeSemantics(
        child: Column(
          key: const ValueKey<String>('inspector-token-usage-summary'),
          children: [
            _InspectorTokenMetric(
              key: const ValueKey<String>('inspector-token-usage-total'),
              icon: Icons.data_usage_rounded,
              label: S.of(context).totalTokens,
              value: numberFormat.format(usage.effectiveTotalTokens),
            ),
            _InspectorTokenMetric(
              key: const ValueKey<String>('inspector-token-usage-input'),
              icon: Icons.login_rounded,
              label: S.of(context).inputTokens,
              value: numberFormat.format(usage.inputTokens),
            ),
            _InspectorTokenMetric(
              key: const ValueKey<String>('inspector-token-usage-output'),
              icon: Icons.logout_rounded,
              label: S.of(context).outputTokens,
              value: numberFormat.format(usage.outputTokens),
            ),
          ],
        ),
      ),
    );
  }
}

class _InspectorTokenMetric extends StatelessWidget {
  const _InspectorTokenMetric({
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: DesktopThemeTokens.mutedText(context)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(label, style: DesktopThemeTokens.bodyStyle(context)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: SelectableText(
              value,
              textAlign: TextAlign.right,
              style: DesktopThemeTokens.metaStyle(context),
            ),
          ),
        ],
      ),
    );
  }
}

class TokenUsageChart extends StatelessWidget {
  const TokenUsageChart({
    super.key,
    required this.buckets,
    required this.granularity,
    this.onBucketSelected,
  });

  final List<TokenUsageBucket> buckets;
  final TokenUsageGranularity granularity;
  final ValueChanged<TokenUsageBucket>? onBucketSelected;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) {
      return SizedBox(
        key: const ValueKey<String>('token-usage-chart-empty'),
        height: 150,
        child: Center(child: Text(S.of(context).noTokenUsageRecorded)),
      );
    }

    final maximum = buckets.fold<int>(
      0,
      (value, bucket) => math.max(value, bucket.usage.effectiveTotalTokens),
    );
    final locale = Localizations.localeOf(context).toString();
    final numberFormat = NumberFormat.compact(locale: locale);
    final isDaily = granularity == TokenUsageGranularity.day;

    if (isDaily) {
      return Column(
        key: const ValueKey<String>('token-usage-chart'),
        children: [
          for (final bucket in buckets)
            _HorizontalTokenUsageBar(
              bucket: bucket,
              maximum: maximum,
              bucketKey: 'token-usage-bucket-day-${_dateKey(bucket.start)}',
              barKey: 'token-usage-bar-day-${_dateKey(bucket.start)}',
              label: DateFormat.Md(locale).format(bucket.start),
              valueLabel: numberFormat.format(
                bucket.usage.effectiveTotalTokens,
              ),
              onTap:
                  onBucketSelected == null
                      ? null
                      : () => onBucketSelected!(bucket),
            ),
        ],
      );
    }

    return Column(
      key: const ValueKey<String>('token-usage-chart'),
      children: [
        for (final bucket in buckets)
          _HorizontalTokenUsageBar(
            bucket: bucket,
            maximum: maximum,
            bucketKey: 'token-usage-bucket-hour-${bucket.start.hour}',
            barKey: 'token-usage-bar-hour-${bucket.start.hour}',
            label: '${bucket.start.hour.toString().padLeft(2, '0')}:00',
            valueLabel: numberFormat.format(bucket.usage.effectiveTotalTokens),
          ),
      ],
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class _HorizontalTokenUsageBar extends StatelessWidget {
  const _HorizontalTokenUsageBar({
    required this.bucket,
    required this.maximum,
    required this.bucketKey,
    required this.barKey,
    required this.label,
    required this.valueLabel,
    this.onTap,
  });

  final TokenUsageBucket bucket;
  final int maximum;
  final String bucketKey;
  final String barKey;
  final String label;
  final String valueLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final total = bucket.usage.effectiveTotalTokens;
    final semanticsLabel =
        '$label, ${S.of(context).totalTokens} $total, '
        '${S.of(context).inputTokens} ${bucket.usage.inputTokens}, '
        '${S.of(context).outputTokens} ${bucket.usage.outputTokens}';
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: semanticsLabel,
      child: Semantics(
        button: onTap != null,
        label: semanticsLabel,
        child: GestureDetector(
          key: ValueKey<String>(bucketKey),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 38,
            child: Row(
              children: [
                SizedBox(
                  width: 42,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width =
                          total == 0 || maximum == 0
                              ? 2.0
                              : math.max(
                                4.0,
                                constraints.maxWidth * total / maximum,
                              );
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          key: ValueKey<String>(barKey),
                          width: width,
                          height: 12,
                          decoration: BoxDecoration(
                            color:
                                total == 0
                                    ? colors.surfaceContainerHighest
                                    : colors.primary,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 42,
                  child: Text(
                    valueLabel,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelSmall,
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
