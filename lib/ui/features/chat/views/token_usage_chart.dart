import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/features/chat/view_models/chat_token_usage_view_model.dart';
import 'package:stars/utils/theme.dart';

enum TokenUsageChartOrientation { horizontal, vertical }

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
              TokenUsageTimelineSection(
                dailyBuckets: viewModel.dailyBuckets,
                visibleBuckets: viewModel.visibleBuckets,
                granularity: viewModel.granularity,
                selectedDay: selectedDay,
                onShowDaily: viewModel.showDaily,
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

class TokenUsageTimelineSection extends StatelessWidget {
  const TokenUsageTimelineSection({
    super.key,
    required this.dailyBuckets,
    required this.visibleBuckets,
    required this.granularity,
    required this.selectedDay,
    required this.onShowDaily,
    this.onBucketSelected,
    this.chartOrientation = TokenUsageChartOrientation.horizontal,
  });

  final List<TokenUsageBucket> dailyBuckets;
  final List<TokenUsageBucket> visibleBuckets;
  final TokenUsageGranularity granularity;
  final DateTime? selectedDay;
  final VoidCallback onShowDaily;
  final ValueChanged<TokenUsageBucket>? onBucketSelected;
  final TokenUsageChartOrientation chartOrientation;

  @override
  Widget build(BuildContext context) {
    final hourly = granularity == TokenUsageGranularity.hour;
    final locale = Localizations.localeOf(context).toString();
    return Column(
      key: const ValueKey<String>('token-usage-timeline-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          key: const ValueKey<String>('token-usage-granularity-header'),
          children: [
            Expanded(
              child: Text(
                key: const ValueKey<String>('token-usage-granularity-title'),
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
                onPressed: onShowDaily,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
              ),
          ],
        ),
        if (selectedDay != null) ...[
          const SizedBox(height: 2),
          Text(
            DateFormat.yMMMd(locale).format(selectedDay!),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ] else if (dailyBuckets.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            key: const ValueKey<String>('token-usage-drilldown-hint'),
            S.of(context).clickDayForHourlyUsage,
            style: DesktopThemeTokens.metaStyle(context),
          ),
        ],
        const SizedBox(height: 10),
        TokenUsageChart(
          buckets: visibleBuckets,
          granularity: granularity,
          onBucketSelected: onBucketSelected,
          orientation: chartOrientation,
        ),
      ],
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
    this.orientation = TokenUsageChartOrientation.horizontal,
  });

  final List<TokenUsageBucket> buckets;
  final TokenUsageGranularity granularity;
  final ValueChanged<TokenUsageBucket>? onBucketSelected;
  final TokenUsageChartOrientation orientation;

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

    if (orientation == TokenUsageChartOrientation.vertical) {
      return _VerticalTokenUsageChart(
        buckets: buckets,
        maximum: maximum,
        granularity: granularity,
        onBucketSelected: onBucketSelected,
      );
    }

    if (isDaily) {
      return Column(
        key: const ValueKey<String>('token-usage-chart'),
        children: [
          for (final bucket in buckets)
            _HorizontalTokenUsageBar(
              bucket: bucket,
              maximum: maximum,
              bucketKey:
                  'token-usage-bucket-day-${_tokenUsageDateKey(bucket.start)}',
              barKey: 'token-usage-bar-day-${_tokenUsageDateKey(bucket.start)}',
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
}

class _VerticalTokenUsageChart extends StatelessWidget {
  const _VerticalTokenUsageChart({
    required this.buckets,
    required this.maximum,
    required this.granularity,
    required this.onBucketSelected,
  });

  final List<TokenUsageBucket> buckets;
  final int maximum;
  final TokenUsageGranularity granularity;
  final ValueChanged<TokenUsageBucket>? onBucketSelected;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final numberFormat = NumberFormat.compact(locale: locale);
    final isDaily = granularity == TokenUsageGranularity.day;
    final minimumSlotWidth = isDaily ? 64.0 : 50.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.hasBoundedWidth
                ? constraints.maxWidth
                : minimumSlotWidth * buckets.length;
        final slotWidth = math.max(
          minimumSlotWidth,
          availableWidth / buckets.length,
        );
        return SizedBox(
          key: const ValueKey<String>('token-usage-chart'),
          height: 176,
          child: ListView.builder(
            key: const ValueKey<String>('token-usage-chart-vertical'),
            scrollDirection: Axis.horizontal,
            itemCount: buckets.length,
            itemExtent: slotWidth,
            itemBuilder: (context, index) {
              final bucket = buckets[index];
              final bucketKey =
                  isDaily
                      ? 'token-usage-bucket-day-'
                          '${_tokenUsageDateKey(bucket.start)}'
                      : 'token-usage-bucket-hour-${bucket.start.hour}';
              final barKey =
                  isDaily
                      ? 'token-usage-bar-day-'
                          '${_tokenUsageDateKey(bucket.start)}'
                      : 'token-usage-bar-hour-${bucket.start.hour}';
              final label =
                  isDaily
                      ? DateFormat.Md(locale).format(bucket.start)
                      : '${bucket.start.hour.toString().padLeft(2, '0')}:00';
              return _VerticalTokenUsageBar(
                bucket: bucket,
                maximum: maximum,
                bucketKey: bucketKey,
                barKey: barKey,
                label: label,
                valueLabel: numberFormat.format(
                  bucket.usage.effectiveTotalTokens,
                ),
                onTap:
                    onBucketSelected == null
                        ? null
                        : () => onBucketSelected!(bucket),
              );
            },
          ),
        );
      },
    );
  }
}

class _VerticalTokenUsageBar extends StatelessWidget {
  const _VerticalTokenUsageBar({
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                  child: Text(
                    valueLabel,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 120,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final height =
                          total == 0 || maximum == 0
                              ? 2.0
                              : math.max(
                                6.0,
                                constraints.maxHeight * total / maximum,
                              );
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          key: ValueKey<String>(barKey),
                          width: 18,
                          height: height,
                          decoration: BoxDecoration(
                            color:
                                total == 0
                                    ? colors.surfaceContainerHighest
                                    : colors.primary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
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

String _tokenUsageDateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
