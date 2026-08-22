import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

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
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
                if (!embedded)
                  ProjectIconAction(
                    label: copy.close,
                    onPressed: () => Navigator.pop(context),
                    icon: LucideIcons.x,
                  ),
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
            Expanded(
              child:
                  sortedTurns.isEmpty && audits.isEmpty
                      ? ProjectEmptyState(
                        icon: LucideIcons.activity,
                        title: copy.noExecutions,
                      )
                      : ListView(
                        key: const ValueKey<String>('project-execution-list'),
                        children: <Widget>[
                          for (final turn in sortedTurns)
                            _TurnCard(
                              turn: turn,
                              runs: runs.values
                                  .where((run) => run.turnId == turn.id)
                                  .toList(growable: false),
                              decisions: decisions,
                              usageRecords: usageRecords,
                              agentNames: agentNames,
                              onCancelRun: onCancelRun,
                              onCancelTurn: onCancelTurn,
                              onCancelRootChain: onCancelRootChain,
                            ),
                          if (audits.isNotEmpty) ...<Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                              child: Text(
                                copy.auditEvents,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            for (final event in audits)
                              _AuditEventTile(event: event),
                          ],
                        ],
                      ),
            ),
          ],
        ),
      ),
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
      child: _ExecutionDisclosure(
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
      child: _ExecutionDisclosure(
        key: ValueKey<String>('project-run-${run.id}'),
        leading: Icon(_runIcon(run.status)),
        title: Text(
          '$agentName · ${copy.runStatus(run.phase.name, run.status.name)}',
        ),
        subtitle: Text(
          <String>[
            run.id,
            if (decision != null)
              '${decision!.choice.name}:${decision!.reasonCode}',
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

final class _ExecutionDisclosure extends StatelessWidget {
  const _ExecutionDisclosure({
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
