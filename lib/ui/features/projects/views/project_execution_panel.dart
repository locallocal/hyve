import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/views/project_audit_event_list.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

const int _executionHistoryPageSize = 10;

final class ProjectExecutionPanel extends StatelessWidget {
  const ProjectExecutionPanel({
    super.key,
    required this.turns,
    required this.runs,
    required this.decisions,
    required this.usageRecords,
    required this.events,
    required this.agentNames,
    required this.onCancelRun,
    required this.onCancelTurn,
    required this.onCancelRootChain,
    this.embedded = false,
    this.onClose,
  });

  final Map<String, ProjectTurn> turns;
  final Map<String, AgentRun> runs;
  final Map<String, ParticipationDecision> decisions;
  final List<ModelTokenUsageRecord> usageRecords;
  final List<ProjectEvent> events;
  final Map<String, String> agentNames;
  final ValueChanged<String> onCancelRun;
  final ValueChanged<String> onCancelTurn;
  final ValueChanged<String> onCancelRootChain;
  final bool embedded;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ProjectDialogSurface(
      embedded: embedded,
      constraints: BoxConstraints(
        maxWidth: embedded ? double.infinity : 920,
        maxHeight: embedded ? double.infinity : 760,
      ),
      child: LayoutBuilder(
        builder:
            (context, constraints) => _content(
              context,
              hasBoundedHeight: constraints.hasBoundedHeight,
            ),
      ),
    );
  }

  Widget _content(BuildContext context, {required bool hasBoundedHeight}) {
    final copy = ProjectLocalizations.of(context);
    final sortedTurns = turns.values.toList(growable: false)
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    final totalUsage = ModelTokenUsage.sum(
      usageRecords.map((record) => record.usage),
    );
    final passCount =
        decisions.values
            .where((decision) => decision.choice == ParticipationChoice.pass)
            .length;
    final audits = events.reversed
        .where((event) => event.visibility == ProjectEventVisibility.audit)
        .toList(growable: false);
    final details = _ExecutionDetailTabs(
      turns: sortedTurns,
      runs: runs,
      decisions: decisions,
      usageRecords: usageRecords,
      audits: audits,
      agentNames: agentNames,
      onCancelRun: onCancelRun,
      onCancelTurn: onCancelTurn,
      onCancelRootChain: onCancelRootChain,
      hasBoundedHeight: hasBoundedHeight,
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ProjectSectionHeader(
              key: const ValueKey<String>('project-execution-header'),
              icon: LucideIcons.activity,
              title: copy.execution,
              description: copy.executionDescription,
              trailing:
                  onClose != null
                      ? ProjectBackAction(
                        key: const ValueKey<String>('project-execution-close'),
                        label: copy.backToMessages,
                        onPressed: onClose,
                      )
                      : !embedded
                      ? const SizedBox.square(dimension: 44)
                      : null,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _MetricChip(
                  icon: LucideIcons.play,
                  label: copy.totalRuns,
                  value: '${runs.length}',
                ),
                _MetricChip(
                  icon: LucideIcons.brain,
                  label: copy.decisions,
                  value: '${decisions.length}',
                ),
                _MetricChip(
                  icon: LucideIcons.circleSlash,
                  label: copy.passed,
                  value: '$passCount',
                ),
                _MetricChip(
                  icon: LucideIcons.chartNoAxesColumnIncreasing,
                  label: copy.tokenUsage,
                  value: '${totalUsage.effectiveTotalTokens}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasBoundedHeight) Expanded(child: details) else details,
          ],
        ),
      ),
    );
  }
}

enum _ExecutionDetailSection { runs, audits }

final class _ExecutionDetailTabs extends StatefulWidget {
  const _ExecutionDetailTabs({
    required this.turns,
    required this.runs,
    required this.decisions,
    required this.usageRecords,
    required this.audits,
    required this.agentNames,
    required this.onCancelRun,
    required this.onCancelTurn,
    required this.onCancelRootChain,
    required this.hasBoundedHeight,
  });

  final List<ProjectTurn> turns;
  final Map<String, AgentRun> runs;
  final Map<String, ParticipationDecision> decisions;
  final List<ModelTokenUsageRecord> usageRecords;
  final List<ProjectEvent> audits;
  final Map<String, String> agentNames;
  final ValueChanged<String> onCancelRun;
  final ValueChanged<String> onCancelTurn;
  final ValueChanged<String> onCancelRootChain;
  final bool hasBoundedHeight;

  @override
  State<_ExecutionDetailTabs> createState() => _ExecutionDetailTabsState();
}

final class _ExecutionDetailTabsState extends State<_ExecutionDetailTabs> {
  _ExecutionDetailSection _selected = _ExecutionDetailSection.runs;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final runHistory = _ExecutionHistory(
      turns: widget.turns,
      runs: widget.runs,
      decisions: widget.decisions,
      usageRecords: widget.usageRecords,
      agentNames: widget.agentNames,
      onCancelRun: widget.onCancelRun,
      onCancelTurn: widget.onCancelTurn,
      onCancelRootChain: widget.onCancelRootChain,
      hasBoundedHeight: widget.hasBoundedHeight,
    );
    final auditHistory = ProjectAuditEventList(
      events: widget.audits,
      hasBoundedHeight: widget.hasBoundedHeight,
    );
    if (hasShadProjectTheme(context)) {
      return ShadTabs<_ExecutionDetailSection>(
        value: _selected,
        onChanged: (value) => setState(() => _selected = value),
        gap: 12,
        maintainState: false,
        tabs: <ShadTab<_ExecutionDetailSection>>[
          ShadTab<_ExecutionDetailSection>(
            value: _ExecutionDetailSection.runs,
            leading: const Icon(LucideIcons.play, size: 16),
            trailing: ProjectBadge(
              key: const ValueKey<String>('project-execution-runs-count'),
              label: '${widget.turns.length}',
              variant: ProjectBadgeVariant.secondary,
            ),
            expandContent: widget.hasBoundedHeight,
            content: runHistory,
            child: Text(
              copy.executionRuns,
              key: const ValueKey<String>('project-execution-runs-tab'),
            ),
          ),
          ShadTab<_ExecutionDetailSection>(
            value: _ExecutionDetailSection.audits,
            leading: const Icon(LucideIcons.shieldCheck, size: 16),
            trailing: ProjectBadge(
              key: const ValueKey<String>('project-execution-audits-count'),
              label: '${widget.audits.length}',
              variant: ProjectBadgeVariant.secondary,
            ),
            expandContent: widget.hasBoundedHeight,
            content: auditHistory,
            child: Text(
              copy.auditEvents,
              key: const ValueKey<String>('project-execution-audits-tab'),
            ),
          ),
        ],
      );
    }

    final selectedContent = switch (_selected) {
      _ExecutionDetailSection.runs => runHistory,
      _ExecutionDetailSection.audits => auditHistory,
    };
    return Column(
      mainAxisSize:
          widget.hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
      children: <Widget>[
        SegmentedButton<_ExecutionDetailSection>(
          showSelectedIcon: false,
          segments: <ButtonSegment<_ExecutionDetailSection>>[
            ButtonSegment<_ExecutionDetailSection>(
              value: _ExecutionDetailSection.runs,
              icon: const Icon(Icons.play_arrow_outlined),
              label: Text(
                '${copy.executionRuns} · ${widget.turns.length}',
                key: const ValueKey<String>('project-execution-runs-tab'),
              ),
            ),
            ButtonSegment<_ExecutionDetailSection>(
              value: _ExecutionDetailSection.audits,
              icon: const Icon(Icons.verified_user_outlined),
              label: Text(
                '${copy.auditEvents} · ${widget.audits.length}',
                key: const ValueKey<String>('project-execution-audits-tab'),
              ),
            ),
          ],
          selected: <_ExecutionDetailSection>{_selected},
          onSelectionChanged: (selection) {
            setState(() => _selected = selection.single);
          },
        ),
        const SizedBox(height: 12),
        if (widget.hasBoundedHeight)
          Expanded(child: selectedContent)
        else
          selectedContent,
      ],
    );
  }
}

final class _ExecutionHistory extends StatefulWidget {
  const _ExecutionHistory({
    required this.turns,
    required this.runs,
    required this.decisions,
    required this.usageRecords,
    required this.agentNames,
    required this.onCancelRun,
    required this.onCancelTurn,
    required this.onCancelRootChain,
    required this.hasBoundedHeight,
  });

  final List<ProjectTurn> turns;
  final Map<String, AgentRun> runs;
  final Map<String, ParticipationDecision> decisions;
  final List<ModelTokenUsageRecord> usageRecords;
  final Map<String, String> agentNames;
  final ValueChanged<String> onCancelRun;
  final ValueChanged<String> onCancelTurn;
  final ValueChanged<String> onCancelRootChain;
  final bool hasBoundedHeight;

  int get itemCount => turns.length;

  @override
  State<_ExecutionHistory> createState() => _ExecutionHistoryState();
}

final class _ExecutionHistoryState extends State<_ExecutionHistory> {
  final ScrollController _scrollController = ScrollController();
  int _pageIndex = 0;

  int get _totalPages =>
      (widget.itemCount + _executionHistoryPageSize - 1) ~/
      _executionHistoryPageSize;

  @override
  void didUpdateWidget(covariant _ExecutionHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_totalPages == 0) {
      _pageIndex = 0;
    } else if (_pageIndex >= _totalPages) {
      _pageIndex = _totalPages - 1;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= _totalPages || pageIndex == _pageIndex) {
      return;
    }
    setState(() => _pageIndex = pageIndex);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    if (widget.itemCount == 0) {
      return ProjectEmptyState(
        icon: LucideIcons.activity,
        title: copy.noExecutions,
      );
    }

    final pageStart = _pageIndex * _executionHistoryPageSize;
    final pageEnd = (pageStart + _executionHistoryPageSize).clamp(
      pageStart,
      widget.itemCount,
    );
    final pageTurns = widget.turns.sublist(pageStart, pageEnd);
    final list = ListView(
      controller: _scrollController,
      primary: false,
      shrinkWrap: !widget.hasBoundedHeight,
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      physics:
          widget.hasBoundedHeight ? null : const NeverScrollableScrollPhysics(),
      key: const ValueKey<String>('project-execution-list'),
      children: <Widget>[
        for (final turn in pageTurns)
          _TurnCard(
            turn: turn,
            runs: widget.runs.values
                .where((run) => run.turnId == turn.id)
                .toList(growable: false),
            decisions: widget.decisions,
            usageRecords: widget.usageRecords,
            agentNames: widget.agentNames,
            onCancelRun: widget.onCancelRun,
            onCancelTurn: widget.onCancelTurn,
            onCancelRootChain: widget.onCancelRootChain,
          ),
      ],
    );
    return Column(
      mainAxisSize:
          widget.hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
      children: <Widget>[
        if (widget.hasBoundedHeight) Expanded(child: list) else list,
        if (_totalPages > 1) ...<Widget>[
          const SizedBox(height: 12),
          ProjectPagination(
            keyPrefix: 'project-execution',
            currentPage: _pageIndex + 1,
            totalPages: _totalPages,
            onPrevious:
                _pageIndex == 0 ? null : () => _showPage(_pageIndex - 1),
            onNext:
                _pageIndex == _totalPages - 1
                    ? null
                    : () => _showPage(_pageIndex + 1),
          ),
        ],
      ],
    );
  }
}

final class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    child: ProjectBadge(icon: icon, label: '$label · $value'),
  );
}

final class _TurnCard extends StatelessWidget {
  const _TurnCard({
    required this.turn,
    required this.runs,
    required this.decisions,
    required this.usageRecords,
    required this.agentNames,
    required this.onCancelRun,
    required this.onCancelTurn,
    required this.onCancelRootChain,
  });

  final ProjectTurn turn;
  final List<AgentRun> runs;
  final Map<String, ParticipationDecision> decisions;
  final List<ModelTokenUsageRecord> usageRecords;
  final Map<String, String> agentNames;
  final ValueChanged<String> onCancelRun;
  final ValueChanged<String> onCancelTurn;
  final ValueChanged<String> onCancelRootChain;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final orderedRuns = runs.toList(growable: false)
      ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
    final statusLabel = copy.turnStatus(turn.status);
    final visual = _turnVisual(turn.status);
    final activeRoots =
        orderedRuns
            .where((run) => !run.isTerminal)
            .map((run) => run.rootRunId)
            .where((id) => id.isNotEmpty)
            .toSet();
    final cancellationActions = <Widget>[
      if (!turn.isTerminal)
        ProjectActionButton(
          key: ValueKey<String>('cancel-turn-${turn.id}'),
          onPressed:
              () => unawaited(
                _confirmCancellation(
                  context,
                  title: copy.cancelTurnTitle,
                  description: copy.cancelTurnDescription,
                  confirmLabel: copy.cancelTurn,
                  confirmKey: ValueKey<String>(
                    'confirm-cancel-turn-${turn.id}',
                  ),
                  onConfirmed: () => onCancelTurn(turn.id),
                ),
              ),
          leading: const Icon(LucideIcons.square, size: 16),
          label: copy.cancelTurn,
          variant: ProjectActionVariant.outline,
        ),
      for (final rootId in activeRoots)
        ProjectActionButton(
          key: ValueKey<String>('cancel-root-chain-$rootId'),
          onPressed:
              () => unawaited(
                _confirmCancellation(
                  context,
                  title: copy.cancelRootChainTitle,
                  description: copy.cancelRootChainDescription,
                  confirmLabel: copy.cancelRootChain,
                  confirmKey: ValueKey<String>(
                    'confirm-cancel-root-chain-$rootId',
                  ),
                  onConfirmed: () => onCancelRootChain(rootId),
                ),
              ),
          leading: const Icon(LucideIcons.circleStop, size: 16),
          label: copy.cancelRootChain,
          variant: ProjectActionVariant.outline,
        ),
    ];
    return ProjectSurfaceCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 10),
      child: ProjectDisclosure(
        key: ValueKey<String>('project-turn-${turn.id}'),
        leading: ProjectIndicatorIcon(
          key: ValueKey<String>('project-turn-indicator-${turn.id}'),
          icon: visual.icon,
          tone: visual.tone,
          semanticLabel: statusLabel,
        ),
        title: Row(
          children: <Widget>[
            Flexible(
              child: Text(copy.messageSequence(turn.sourceMessageSequence)),
            ),
            const SizedBox(width: 8),
            ProjectBadge(
              key: ValueKey<String>('project-turn-status-${turn.id}'),
              label: statusLabel,
              variant: visual.badgeVariant,
            ),
          ],
        ),
        subtitle: ProjectMetadataWrap(
          items: <ProjectMetadataItem>[
            ProjectMetadataItem(
              icon: LucideIcons.messageSquareText,
              label: copy.routingMode(turn.routingMode),
            ),
            ProjectMetadataItem(
              icon: LucideIcons.bot,
              label: copy.runCount(orderedRuns.length),
            ),
            ProjectMetadataItem(
              icon: LucideIcons.send,
              label: copy.recipientCount(turn.recipientCount),
            ),
            ProjectMetadataItem(
              icon: LucideIcons.clock3,
              label: _executionTimestamp(context, turn.createdAt),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: <Widget>[
          if (cancellationActions.isNotEmpty)
            _CancellationToolbar(children: cancellationActions),
          for (final run in orderedRuns)
            Padding(
              padding: EdgeInsets.only(
                left: (run.deliveryDepth * 16).clamp(0, 48).toDouble(),
              ),
              child: _RunTile(
                run: run,
                decision: decisions[run.id],
                usage: ModelTokenUsage.sum(
                  usageRecords
                      .where((record) => record.runId == run.id)
                      .map((record) => record.usage),
                ),
                agentName:
                    agentNames[run.agentId] ?? run.agentSnapshot.agentName,
                onCancel: () => onCancelRun(run.id),
              ),
            ),
        ],
      ),
    );
  }
}

final class _RunTile extends StatelessWidget {
  const _RunTile({
    required this.run,
    required this.decision,
    required this.usage,
    required this.agentName,
    required this.onCancel,
  });

  final AgentRun run;
  final ParticipationDecision? decision;
  final ModelTokenUsage usage;
  final String agentName;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final duration = _duration(run);
    final report = run.contextReport;
    final statusLabel = copy.agentRunStatus(run.status);
    final visual = _runVisual(run.status);
    final shadTheme = ShadTheme.maybeOf(context);
    final materialScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        key: ValueKey<String>('project-run-surface-${run.id}'),
        color:
            shadTheme?.colorScheme.muted.withValues(alpha: 0.28) ??
            materialScheme.surfaceContainerLowest,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: shadTheme?.radius ?? BorderRadius.circular(8),
          side: BorderSide(
            color:
                shadTheme?.colorScheme.border ?? materialScheme.outlineVariant,
          ),
        ),
        child: ProjectDisclosure(
          key: ValueKey<String>('project-run-${run.id}'),
          leading: ProjectIndicatorIcon(
            key: ValueKey<String>('project-run-indicator-${run.id}'),
            icon: visual.icon,
            tone: visual.tone,
            semanticLabel: statusLabel,
            size: 30,
            iconSize: 14,
          ),
          title: Row(
            children: <Widget>[
              Flexible(child: Text(agentName)),
              const SizedBox(width: 8),
              ProjectBadge(
                key: ValueKey<String>('project-run-status-${run.id}'),
                label: statusLabel,
                variant: visual.badgeVariant,
              ),
            ],
          ),
          subtitle: ProjectMetadataWrap(
            spacing: 10,
            items: <ProjectMetadataItem>[
              ProjectMetadataItem(
                icon: LucideIcons.activity,
                label: copy.runPhase(run.phase),
              ),
              if (decision != null)
                ProjectMetadataItem(
                  icon: LucideIcons.brain,
                  label: copy.participationDecision(decision!),
                ),
              if (usage.hasData)
                ProjectMetadataItem(
                  icon: LucideIcons.chartNoAxesColumnIncreasing,
                  label: copy.tokens(usage.inputTokens, usage.outputTokens),
                ),
              if (duration.isNotEmpty)
                ProjectMetadataItem(
                  icon: LucideIcons.clock3,
                  label: copy.duration(duration),
                ),
              if (run.errorCode.isNotEmpty)
                ProjectMetadataItem(
                  icon: LucideIcons.triangleAlert,
                  label: copy.errorCode(run.errorCode),
                ),
            ],
          ),
          trailing:
              run.isTerminal
                  ? null
                  : ProjectIconAction(
                    key: ValueKey<String>('cancel-run-${run.id}'),
                    label: copy.cancelRun,
                    onPressed:
                        () => unawaited(
                          _confirmCancellation(
                            context,
                            title: copy.cancelRunTitle,
                            description: copy.cancelRunDescription,
                            confirmLabel: copy.cancelRun,
                            confirmKey: ValueKey<String>(
                              'confirm-cancel-run-${run.id}',
                            ),
                            onConfirmed: onCancel,
                          ),
                        ),
                    icon: LucideIcons.square,
                    variant: ShadButtonVariant.outline,
                  ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[_RunContextPanel(runId: run.id, report: report)],
        ),
      ),
    );
  }
}

final class _RunContextPanel extends StatelessWidget {
  const _RunContextPanel({required this.runId, required this.report});

  final String runId;
  final AgentRunContextReport report;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final shadTheme = ShadTheme.maybeOf(context);
    final materialScheme = Theme.of(context).colorScheme;
    final entries = <(String, String)>[
      (copy.runIdentifierLabel, runId),
      (
        copy.summarySegments,
        _identifierValue(report.conversationSummarySegmentIds),
      ),
      (copy.memories, _identifierValue(report.agentMemoryIds)),
      (
        copy.artifactVersionIds,
        _identifierValue(report.projectArtifactVersionIds),
      ),
      (copy.skills, _identifierValue(report.skillDigests)),
      (copy.tools, _identifierValue(report.toolNames)),
      (copy.memoryRevision, '${report.agentMemoryRevision}'),
      (copy.coveredThroughMessage, '${report.coveredThroughMessageSequence}'),
    ];
    return Column(
      key: ValueKey<String>('project-run-context-$runId'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Divider(
          height: 1,
          color: shadTheme?.colorScheme.border ?? materialScheme.outlineVariant,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            const Icon(LucideIcons.fileText, size: 15),
            const SizedBox(width: 7),
            Text(
              copy.contextReport,
              style:
                  shadTheme?.textTheme.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ) ??
                  Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final (index, entry) in entries.indexed) ...<Widget>[
          if (index > 0)
            Divider(
              height: 17,
              color:
                  shadTheme?.colorScheme.border ??
                  materialScheme.outlineVariant,
            ),
          _ContextEntry(label: entry.$1, value: entry.$2),
        ],
      ],
    );
  }
}

final class _ContextEntry extends StatelessWidget {
  const _ContextEntry({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.maybeOf(context);
    final labelStyle =
        shadTheme?.textTheme.muted ?? Theme.of(context).textTheme.bodySmall;
    final valueStyle = (shadTheme?.textTheme.small ??
            Theme.of(context).textTheme.bodyMedium)
        ?.copyWith(fontFamily: 'monospace');
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 480;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: labelStyle),
              const SizedBox(height: 3),
              Text(value, style: valueStyle),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 152, child: Text(label, style: labelStyle)),
            const SizedBox(width: 12),
            Expanded(child: Text(value, style: valueStyle)),
          ],
        );
      },
    );
  }
}

final class _CancellationToolbar extends StatelessWidget {
  const _CancellationToolbar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: children,
      ),
    ),
  );
}

Future<void> _confirmCancellation(
  BuildContext context, {
  required String title,
  required String description,
  required String confirmLabel,
  required Key confirmKey,
  required VoidCallback onConfirmed,
}) async {
  final copy = ProjectLocalizations.of(context);
  final confirmed = await showProjectConfirmation(
    context: context,
    title: title,
    description: description,
    cancelLabel: copy.cancel,
    confirmLabel: confirmLabel,
    destructive: true,
    confirmKey: confirmKey,
  );
  if (confirmed && context.mounted) onConfirmed();
}

String _duration(AgentRun run) {
  final start = run.startedAt;
  final end = run.completedAt;
  if (start == null) return '';
  final elapsed = (end ?? DateTime.now()).difference(start);
  return elapsed.inMilliseconds < 1000
      ? '${elapsed.inMilliseconds} ms'
      : '${(elapsed.inMilliseconds / 1000).toStringAsFixed(1)} s';
}

String _executionTimestamp(BuildContext context, DateTime timestamp) =>
    intl.DateFormat.yMd(
      Localizations.localeOf(context).toString(),
    ).add_jm().format(timestamp.toLocal());

String _identifierValue(Iterable<String> values) =>
    values.isEmpty ? '-' : values.join(', ');

({IconData icon, ProjectIndicatorTone tone, ProjectBadgeVariant badgeVariant})
_turnVisual(ProjectTurnStatus status) => switch (status) {
  ProjectTurnStatus.completed => (
    icon: LucideIcons.circleCheck,
    tone: ProjectIndicatorTone.success,
    badgeVariant: ProjectBadgeVariant.secondary,
  ),
  ProjectTurnStatus.partial => (
    icon: LucideIcons.triangleAlert,
    tone: ProjectIndicatorTone.warning,
    badgeVariant: ProjectBadgeVariant.outline,
  ),
  ProjectTurnStatus.failed => (
    icon: LucideIcons.circleAlert,
    tone: ProjectIndicatorTone.destructive,
    badgeVariant: ProjectBadgeVariant.destructive,
  ),
  ProjectTurnStatus.cancelled => (
    icon: LucideIcons.circleStop,
    tone: ProjectIndicatorTone.neutral,
    badgeVariant: ProjectBadgeVariant.outline,
  ),
  ProjectTurnStatus.created => (
    icon: LucideIcons.clock3,
    tone: ProjectIndicatorTone.neutral,
    badgeVariant: ProjectBadgeVariant.outline,
  ),
  _ => (
    icon: LucideIcons.loaderCircle,
    tone: ProjectIndicatorTone.primary,
    badgeVariant: ProjectBadgeVariant.secondary,
  ),
};

({IconData icon, ProjectIndicatorTone tone, ProjectBadgeVariant badgeVariant})
_runVisual(AgentRunStatus status) => switch (status) {
  AgentRunStatus.completed => (
    icon: LucideIcons.circleCheck,
    tone: ProjectIndicatorTone.success,
    badgeVariant: ProjectBadgeVariant.secondary,
  ),
  AgentRunStatus.passed => (
    icon: LucideIcons.circleSlash,
    tone: ProjectIndicatorTone.neutral,
    badgeVariant: ProjectBadgeVariant.outline,
  ),
  AgentRunStatus.failed ||
  AgentRunStatus.timedOut ||
  AgentRunStatus.limitExceeded => (
    icon: LucideIcons.circleAlert,
    tone: ProjectIndicatorTone.destructive,
    badgeVariant: ProjectBadgeVariant.destructive,
  ),
  AgentRunStatus.cancelled || AgentRunStatus.interrupted => (
    icon: LucideIcons.circleStop,
    tone: ProjectIndicatorTone.neutral,
    badgeVariant: ProjectBadgeVariant.outline,
  ),
  AgentRunStatus.queued => (
    icon: LucideIcons.clock3,
    tone: ProjectIndicatorTone.neutral,
    badgeVariant: ProjectBadgeVariant.outline,
  ),
  _ => (
    icon: LucideIcons.loaderCircle,
    tone: ProjectIndicatorTone.primary,
    badgeVariant: ProjectBadgeVariant.secondary,
  ),
};
