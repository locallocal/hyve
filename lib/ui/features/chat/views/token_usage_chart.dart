import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/ui/features/chat/view_models/chat_token_usage_view_model.dart';
import 'package:hyve/utils/theme.dart';

enum TokenUsageChartOrientation { horizontal, vertical }

enum TokenUsageMetric { total, input, output }

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
        final populatedBuckets = viewModel.visibleBuckets
            .where((bucket) => bucket.usage.hasData)
            .toList(growable: false);
        return Column(
          key: const ValueKey<String>('conversation-token-usage-panel'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(height: 25),
            Text(
              key: const ValueKey<String>('token-usage-section-title'),
              S.of(context).tokenUsage,
              style: HyveDesktopThemeSpec.sectionTitleStyle(context),
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
                visibleBuckets: populatedBuckets,
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
    this.chartMetrics = const <TokenUsageMetric>[TokenUsageMetric.total],
  }) : assert(chartMetrics.length > 0);

  final List<TokenUsageBucket> dailyBuckets;
  final List<TokenUsageBucket> visibleBuckets;
  final TokenUsageGranularity granularity;
  final DateTime? selectedDay;
  final VoidCallback onShowDaily;
  final ValueChanged<TokenUsageBucket>? onBucketSelected;
  final TokenUsageChartOrientation chartOrientation;
  final List<TokenUsageMetric> chartMetrics;

  @override
  Widget build(BuildContext context) {
    final hourly = granularity == TokenUsageGranularity.hour;
    final locale = Localizations.localeOf(context).toString();
    final maximum = _maximumTokenUsage(visibleBuckets, chartMetrics);
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
                style: HyveDesktopThemeSpec.sectionTitleStyle(context),
              ),
            ),
            if (hourly)
              HyveDesktopIconAction(
                key: const ValueKey<String>('token-usage-back-to-daily'),
                icon: LucideIcons.arrowLeft,
                label: S.of(context).backToDailyUsage,
                onPressed: onShowDaily,
                iconSize: 18,
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
            style: HyveDesktopThemeSpec.metaStyle(context),
          ),
        ],
        const SizedBox(height: 10),
        for (var index = 0; index < chartMetrics.length; index++) ...[
          if (index > 0) const SizedBox(height: 24),
          _TokenUsageMetricChart(
            metric: chartMetrics[index],
            showTitle: chartMetrics.length > 1,
            buckets: visibleBuckets,
            granularity: granularity,
            onBucketSelected: onBucketSelected,
            orientation: chartOrientation,
            maximum: maximum,
          ),
        ],
      ],
    );
  }
}

class _TokenUsageMetricChart extends StatelessWidget {
  const _TokenUsageMetricChart({
    required this.metric,
    required this.showTitle,
    required this.buckets,
    required this.granularity,
    required this.onBucketSelected,
    required this.orientation,
    required this.maximum,
  });

  final TokenUsageMetric metric;
  final bool showTitle;
  final List<TokenUsageBucket> buckets;
  final TokenUsageGranularity granularity;
  final ValueChanged<TokenUsageBucket>? onBucketSelected;
  final TokenUsageChartOrientation orientation;
  final int maximum;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey<String>('token-usage-metric-${metric.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showTitle) ...<Widget>[
          Text(
            key: ValueKey<String>('token-usage-metric-title-${metric.name}'),
            _tokenUsageMetricLabel(context, metric),
            style: HyveDesktopThemeSpec.sectionTitleStyle(context),
          ),
          const SizedBox(height: 8),
        ],
        TokenUsageChart(
          buckets: buckets,
          granularity: granularity,
          metric: metric,
          maximum: maximum,
          onBucketSelected: onBucketSelected,
          orientation: orientation,
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
  Widget build(BuildContext context) =>
      HyveInspectorInfoRow(icon: icon, label: label, value: value);
}

class TokenUsageChart extends StatelessWidget {
  const TokenUsageChart({
    super.key,
    required this.buckets,
    required this.granularity,
    this.metric = TokenUsageMetric.total,
    this.maximum,
    this.onBucketSelected,
    this.orientation = TokenUsageChartOrientation.horizontal,
  });

  final List<TokenUsageBucket> buckets;
  final TokenUsageGranularity granularity;
  final TokenUsageMetric metric;
  final int? maximum;
  final ValueChanged<TokenUsageBucket>? onBucketSelected;
  final TokenUsageChartOrientation orientation;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) {
      return SizedBox(
        key: ValueKey<String>(_metricKey('token-usage-chart-empty', metric)),
        height: 150,
        child: Center(child: Text(S.of(context).noTokenUsageRecorded)),
      );
    }

    final chartMaximum =
        maximum ?? _maximumTokenUsage(buckets, <TokenUsageMetric>[metric]);
    final locale = Localizations.localeOf(context).toString();
    final numberFormat = NumberFormat.compact(locale: locale);
    final isDaily = granularity == TokenUsageGranularity.day;

    if (orientation == TokenUsageChartOrientation.vertical) {
      return _VerticalTokenUsageChart(
        buckets: buckets,
        maximum: chartMaximum,
        granularity: granularity,
        metric: metric,
        onBucketSelected: onBucketSelected,
      );
    }

    if (isDaily) {
      return Column(
        key: ValueKey<String>(_metricKey('token-usage-chart', metric)),
        children: [
          for (final bucket in buckets)
            _HorizontalTokenUsageBar(
              bucket: bucket,
              maximum: chartMaximum,
              metric: metric,
              bucketKey: _bucketKey(
                'bucket',
                metric,
                TokenUsageGranularity.day,
                bucket,
              ),
              barKey: _bucketKey(
                'bar',
                metric,
                TokenUsageGranularity.day,
                bucket,
              ),
              label: DateFormat.Md(locale).format(bucket.start),
              valueLabel: numberFormat.format(
                _tokenUsageValue(bucket.usage, metric),
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
      key: ValueKey<String>(_metricKey('token-usage-chart', metric)),
      children: [
        for (final bucket in buckets)
          _HorizontalTokenUsageBar(
            bucket: bucket,
            maximum: chartMaximum,
            metric: metric,
            bucketKey: _bucketKey(
              'bucket',
              metric,
              TokenUsageGranularity.hour,
              bucket,
            ),
            barKey: _bucketKey(
              'bar',
              metric,
              TokenUsageGranularity.hour,
              bucket,
            ),
            label: '${bucket.start.hour.toString().padLeft(2, '0')}:00',
            valueLabel: numberFormat.format(
              _tokenUsageValue(bucket.usage, metric),
            ),
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
    required this.metric,
    required this.onBucketSelected,
  });

  final List<TokenUsageBucket> buckets;
  final int maximum;
  final TokenUsageGranularity granularity;
  final TokenUsageMetric metric;
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
          key: ValueKey<String>(_metricKey('token-usage-chart', metric)),
          height: 176,
          child: ListView.builder(
            key: ValueKey<String>(
              _metricKey('token-usage-chart-vertical', metric),
            ),
            scrollDirection: Axis.horizontal,
            itemCount: buckets.length,
            itemExtent: slotWidth,
            itemBuilder: (context, index) {
              final bucket = buckets[index];
              final bucketKey = _bucketKey(
                'bucket',
                metric,
                granularity,
                bucket,
              );
              final barKey = _bucketKey('bar', metric, granularity, bucket);
              final label =
                  isDaily
                      ? DateFormat.Md(locale).format(bucket.start)
                      : '${bucket.start.hour.toString().padLeft(2, '0')}:00';
              return _VerticalTokenUsageBar(
                bucket: bucket,
                maximum: maximum,
                metric: metric,
                bucketKey: bucketKey,
                barKey: barKey,
                label: label,
                valueLabel: numberFormat.format(
                  _tokenUsageValue(bucket.usage, metric),
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
    required this.metric,
    required this.bucketKey,
    required this.barKey,
    required this.label,
    required this.valueLabel,
    this.onTap,
  });

  final TokenUsageBucket bucket;
  final int maximum;
  final TokenUsageMetric metric;
  final String bucketKey;
  final String barKey;
  final String label;
  final String valueLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final value = _tokenUsageValue(bucket.usage, metric);
    final semanticsLabel = _tokenUsageSemanticsLabel(
      context,
      label,
      bucket.usage,
      metric,
    );
    final materialColors = Theme.of(context).colorScheme;
    final shadColors = ShadTheme.maybeOf(context)?.colorScheme;

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
                          value == 0 || maximum == 0
                              ? 2.0
                              : math.max(
                                6.0,
                                constraints.maxHeight * value / maximum,
                              );
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          key: ValueKey<String>(barKey),
                          width: 18,
                          height: height,
                          decoration: BoxDecoration(
                            color:
                                value == 0
                                    ? shadColors?.muted ??
                                        materialColors.surfaceContainerHighest
                                    : shadColors?.primary ??
                                        materialColors.primary,
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
                    color:
                        shadColors?.mutedForeground ??
                        materialColors.onSurfaceVariant,
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
    required this.metric,
    required this.bucketKey,
    required this.barKey,
    required this.label,
    required this.valueLabel,
    this.onTap,
  });

  final TokenUsageBucket bucket;
  final int maximum;
  final TokenUsageMetric metric;
  final String bucketKey;
  final String barKey;
  final String label;
  final String valueLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final value = _tokenUsageValue(bucket.usage, metric);
    final semanticsLabel = _tokenUsageSemanticsLabel(
      context,
      label,
      bucket.usage,
      metric,
    );
    final materialColors = Theme.of(context).colorScheme;
    final shadColors = ShadTheme.maybeOf(context)?.colorScheme;

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
                      color:
                          shadColors?.mutedForeground ??
                          materialColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width =
                          value == 0 || maximum == 0
                              ? 2.0
                              : math.max(
                                4.0,
                                constraints.maxWidth * value / maximum,
                              );
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          key: ValueKey<String>(barKey),
                          width: width,
                          height: 12,
                          decoration: BoxDecoration(
                            color:
                                value == 0
                                    ? shadColors?.muted ??
                                        materialColors.surfaceContainerHighest
                                    : shadColors?.primary ??
                                        materialColors.primary,
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

int _maximumTokenUsage(
  List<TokenUsageBucket> buckets,
  Iterable<TokenUsageMetric> metrics,
) {
  return buckets.fold<int>(0, (maximum, bucket) {
    return metrics.fold<int>(
      maximum,
      (value, metric) =>
          math.max(value, _tokenUsageValue(bucket.usage, metric)),
    );
  });
}

int _tokenUsageValue(ModelTokenUsage usage, TokenUsageMetric metric) {
  return switch (metric) {
    TokenUsageMetric.total => usage.effectiveTotalTokens,
    TokenUsageMetric.input => usage.inputTokens,
    TokenUsageMetric.output => usage.outputTokens,
  };
}

String _tokenUsageMetricLabel(BuildContext context, TokenUsageMetric metric) {
  return switch (metric) {
    TokenUsageMetric.total => S.of(context).totalTokens,
    TokenUsageMetric.input => S.of(context).inputTokens,
    TokenUsageMetric.output => S.of(context).outputTokens,
  };
}

String _tokenUsageSemanticsLabel(
  BuildContext context,
  String bucketLabel,
  ModelTokenUsage usage,
  TokenUsageMetric metric,
) {
  if (metric != TokenUsageMetric.total) {
    return '$bucketLabel, ${_tokenUsageMetricLabel(context, metric)} '
        '${_tokenUsageValue(usage, metric)}';
  }
  return '$bucketLabel, ${S.of(context).totalTokens} '
      '${usage.effectiveTotalTokens}, '
      '${S.of(context).inputTokens} ${usage.inputTokens}, '
      '${S.of(context).outputTokens} ${usage.outputTokens}';
}

String _metricKey(String base, TokenUsageMetric metric) {
  return metric == TokenUsageMetric.total ? base : '$base-${metric.name}';
}

String _bucketKey(
  String kind,
  TokenUsageMetric metric,
  TokenUsageGranularity granularity,
  TokenUsageBucket bucket,
) {
  final bucketValue = switch (granularity) {
    TokenUsageGranularity.day => _tokenUsageDateKey(bucket.start),
    TokenUsageGranularity.hour => bucket.start.hour.toString(),
  };
  return _metricKey(
    'token-usage-$kind-${granularity.name}-$bucketValue',
    metric,
  );
}

String _tokenUsageDateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
