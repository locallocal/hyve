import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
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
        .where((event) => event.messageSequence == null)
        .take(50)
        .toList(growable: false);
    final history = _ExecutionHistory(
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
            Row(
              children: <Widget>[
                Icon(LucideIcons.activity, semanticLabel: copy.execution),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    copy.execution,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (!embedded) const SizedBox.square(dimension: 44),
              ],
            ),
            const SizedBox(height: 12),
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
            if (hasBoundedHeight) Expanded(child: history) else history,
          ],
        ),
      ),
    );
  }
}

final class _ExecutionHistory extends StatefulWidget {
  const _ExecutionHistory({
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

  int get itemCount => turns.length + audits.length;

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
    final turnStart = pageStart.clamp(0, widget.turns.length);
    final turnEnd = pageEnd.clamp(turnStart, widget.turns.length);
    final auditStart = (pageStart - widget.turns.length).clamp(
      0,
      widget.audits.length,
    );
    final auditEnd = (pageEnd - widget.turns.length).clamp(
      auditStart,
      widget.audits.length,
    );
    final pageTurns = widget.turns.sublist(turnStart, turnEnd);
    final pageAudits = widget.audits.sublist(auditStart, auditEnd);
    final list = ListView(
      controller: _scrollController,
      primary: false,
      shrinkWrap: !widget.hasBoundedHeight,
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
        if (pageAudits.isNotEmpty) ...<Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: Text(
              copy.auditEvents,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final event in pageAudits) _AuditEventTile(event: event),
        ],
      ],
    );
    return Column(
      mainAxisSize:
          widget.hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
      children: <Widget>[
        if (widget.hasBoundedHeight) Expanded(child: list) else list,
        if (_totalPages > 1) ...<Widget>[
          const SizedBox(height: 12),
          _ExecutionPagination(
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

final class _ExecutionPagination extends StatelessWidget {
  const _ExecutionPagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

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
          key: const ValueKey<String>('project-execution-previous-page'),
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
            key: const ValueKey<String>('project-execution-page-indicator'),
          ),
        ),
        const SizedBox(width: 12),
        ProjectIconAction(
          key: const ValueKey<String>('project-execution-next-page'),
          icon: LucideIcons.chevronRight,
          label: localizations.nextPageTooltip,
          variant: ShadButtonVariant.outline,
          onPressed: onNext,
        ),
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
    final activeRoots =
        orderedRuns
            .where((run) => !run.isTerminal)
            .map((run) => run.rootRunId)
            .where((id) => id.isNotEmpty)
            .toSet();
    return ProjectSurfaceCard(
      padding: EdgeInsets.zero,
      child: ProjectDisclosure(
        key: ValueKey<String>('project-turn-${turn.id}'),
        leading: Icon(_turnIcon(turn.status)),
        title: Text(
          '#${turn.sourceMessageSequence} · ${turn.routingMode.name}',
        ),
        subtitle: Text(
          '${turn.status.name} · ${orderedRuns.length} ${copy.totalRuns.toLowerCase()}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: <Widget>[
          if (!turn.isTerminal)
            Align(
              alignment: Alignment.centerRight,
              child: ProjectActionButton(
                key: ValueKey<String>('cancel-turn-${turn.id}'),
                onPressed: () => onCancelTurn(turn.id),
                leading: const Icon(LucideIcons.square, size: 16),
                label: copy.cancelTurn,
                variant: ProjectActionVariant.destructive,
              ),
            ),
          for (final rootId in activeRoots)
            Align(
              alignment: Alignment.centerRight,
              child: ProjectActionButton(
                onPressed: () => onCancelRootChain(rootId),
                leading: const Icon(LucideIcons.circleStop, size: 16),
                label: copy.cancelRootChain,
                variant: ProjectActionVariant.outline,
              ),
            ),
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
    return ProjectSurfaceCard(
      padding: EdgeInsets.zero,
      child: ProjectDisclosure(
        key: ValueKey<String>('project-run-${run.id}'),
        leading: Icon(_runIcon(run.status)),
        title: Text(
          '$agentName · ${copy.runStatus(run.phase.name, run.status.name)}',
        ),
        subtitle: Text(
          <String>[
            run.id,
            if (decision != null) copy.participationDecision(decision!),
            if (usage.hasData)
              copy.tokens(usage.inputTokens, usage.outputTokens),
            if (duration.isNotEmpty) copy.duration(duration),
            if (run.errorCode.isNotEmpty) copy.errorCode(run.errorCode),
          ].join('\n'),
        ),
        trailing:
            run.isTerminal
                ? null
                : ProjectIconAction(
                  label: copy.cancelRun,
                  onPressed: onCancel,
                  icon: LucideIcons.square,
                  destructive: true,
                ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(copy.contextReport),
          Text(
            copy.identifiers(
              copy.summarySegments,
              report.conversationSummarySegmentIds,
            ),
          ),
          Text(copy.identifiers(copy.memories, report.agentMemoryIds)),
          Text(
            copy.identifiers(
              copy.artifactVersionIds,
              report.projectArtifactVersionIds,
            ),
          ),
          Text(copy.identifiers(copy.skills, report.skillDigests)),
          Text(copy.identifiers(copy.tools, report.toolNames)),
          Text('memoryRevision: ${report.agentMemoryRevision}'),
          Text('coveredThrough: ${report.coveredThroughMessageSequence}'),
        ],
      ),
    );
  }
}

final class _AuditEventTile extends StatelessWidget {
  const _AuditEventTile({required this.event});

  final ProjectEvent event;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.maybeOf(context);
    final actor =
        event.actorNameSnapshot.isEmpty
            ? event.actorType.name
            : event.actorNameSnapshot;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(_eventIcon(event.eventType), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  event.eventType.name,
                  style:
                      shadTheme?.textTheme.small.copyWith(
                        fontWeight: FontWeight.w500,
                      ) ??
                      Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.id} · $actor',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      shadTheme?.textTheme.muted ??
                      Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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

IconData _turnIcon(ProjectTurnStatus status) => switch (status) {
  ProjectTurnStatus.completed => Icons.check_circle_outline,
  ProjectTurnStatus.partial => Icons.warning_amber_outlined,
  ProjectTurnStatus.failed => Icons.error_outline,
  ProjectTurnStatus.cancelled => Icons.cancel_outlined,
  _ => Icons.sync,
};

IconData _runIcon(AgentRunStatus status) => switch (status) {
  AgentRunStatus.completed => Icons.check_circle_outline,
  AgentRunStatus.passed => Icons.skip_next_outlined,
  AgentRunStatus.failed ||
  AgentRunStatus.timedOut ||
  AgentRunStatus.limitExceeded => Icons.error_outline,
  AgentRunStatus.cancelled ||
  AgentRunStatus.interrupted => Icons.cancel_outlined,
  _ => Icons.pending_outlined,
};

IconData _eventIcon(ProjectEventType type) => switch (type) {
  ProjectEventType.membershipChanged => Icons.group_outlined,
  ProjectEventType.projectArtifactChanged => Icons.folder_outlined,
  ProjectEventType.runStatusChanged => Icons.monitor_heart_outlined,
  ProjectEventType.participationDecision => Icons.psychology_outlined,
  ProjectEventType.systemNotice => Icons.info_outline,
  _ => Icons.receipt_long_outlined,
};
