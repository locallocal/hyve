import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

const int _auditEventPageSize = 20;

/// Displays project audit events independently from broadcast run history.
final class ProjectAuditEventList extends StatefulWidget {
  const ProjectAuditEventList({
    super.key,
    required this.events,
    required this.hasBoundedHeight,
  });

  final List<ProjectEvent> events;
  final bool hasBoundedHeight;

  @override
  State<ProjectAuditEventList> createState() => _ProjectAuditEventListState();
}

final class _ProjectAuditEventListState extends State<ProjectAuditEventList> {
  final ScrollController _scrollController = ScrollController();
  int _pageIndex = 0;

  int get _totalPages =>
      (widget.events.length + _auditEventPageSize - 1) ~/ _auditEventPageSize;

  @override
  void didUpdateWidget(covariant ProjectAuditEventList oldWidget) {
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
    if (widget.events.isEmpty) {
      return ProjectEmptyState(
        icon: LucideIcons.shieldCheck,
        title: copy.noAuditEvents,
      );
    }

    final pageStart = _pageIndex * _auditEventPageSize;
    final pageEnd = (pageStart + _auditEventPageSize).clamp(
      pageStart,
      widget.events.length,
    );
    final pageEvents = widget.events.sublist(pageStart, pageEnd);
    final list = ListView(
      key: const ValueKey<String>('project-audit-events-list'),
      controller: _scrollController,
      primary: false,
      shrinkWrap: !widget.hasBoundedHeight,
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      physics:
          widget.hasBoundedHeight ? null : const NeverScrollableScrollPhysics(),
      children: <Widget>[
        for (final event in pageEvents)
          ProjectSurfaceCard(
            key: ValueKey<String>('project-audit-event-card-${event.id}'),
            padding: EdgeInsets.zero,
            child: _AuditEventTile(
              key: ValueKey<String>('project-audit-event-tile-${event.id}'),
              event: event,
            ),
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
            keyPrefix: 'project-audit-events',
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

final class _AuditEventTile extends StatelessWidget {
  const _AuditEventTile({super.key, required this.event});

  final ProjectEvent event;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.maybeOf(context);
    final copy = ProjectLocalizations.of(context);
    final typeLabel = copy.auditEventType(event.eventType);
    final actor = copy.auditActor(event.actorType, event.actorNameSnapshot);
    final summary = _eventSummary(copy, event);
    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ProjectIndicatorIcon(
              key: ValueKey<String>('project-audit-indicator-${event.id}'),
              icon: _eventIcon(event.eventType),
              tone: _eventTone(event),
              semanticLabel: typeLabel,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          typeLabel,
                          style:
                              shadTheme?.textTheme.small.copyWith(
                                fontWeight: FontWeight.w600,
                              ) ??
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ProjectBadge(
                        key: ValueKey<String>(
                          'project-audit-actor-${event.id}',
                        ),
                        label: actor,
                        variant: _actorBadgeVariant(event.actorType),
                      ),
                    ],
                  ),
                  if (summary.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style:
                          shadTheme?.textTheme.p ??
                          Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 8),
                  ProjectMetadataWrap(
                    items: <ProjectMetadataItem>[
                      ProjectMetadataItem(
                        icon: LucideIcons.info,
                        label: copy.auditSequence(event.sequence),
                      ),
                      ProjectMetadataItem(
                        icon: LucideIcons.clock3,
                        label: _auditTimestamp(context, event.createdAt),
                      ),
                      ProjectMetadataItem(
                        icon: LucideIcons.fileText,
                        label: event.id,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _eventSummary(ProjectLocalizations copy, ProjectEvent event) {
  final payload = event.payload;
  return switch (payload) {
    ProjectMessagePayload() => event.content.trim(),
    ParticipationDecisionPayload(
      :final choice,
      :final reasonCode,
      :final intendedContribution,
    ) =>
      <String>[
        copy.participationChoice(choice),
        copy.participationReason(reasonCode),
        if (intendedContribution.trim().isNotEmpty) intendedContribution.trim(),
      ].join(' · '),
    AgentDeliveryPayload(:final kind, :final summary) => copy.auditDelivery(
      kind.name,
      summary,
    ),
    MembershipChangedPayload(
      :final agentId,
      :final previousStatus,
      :final currentStatus,
    ) =>
      copy.membershipChange(agentId, previousStatus, currentStatus),
    ProjectArtifactChangedPayload(:final artifactId, :final changeKind) => copy
        .artifactChange(changeKind, artifactId),
    RunStatusChangedPayload(:final phase, :final status, :final errorCode) =>
      copy.auditRunChange(phase, status, errorCode),
    SystemNoticePayload(:final code, :final detail) => copy.auditSystemNotice(
      code,
      detail,
    ),
  };
}

String _auditTimestamp(BuildContext context, DateTime timestamp) =>
    intl.DateFormat.yMd(
      Localizations.localeOf(context).toString(),
    ).add_jm().format(timestamp.toLocal());

ProjectBadgeVariant _actorBadgeVariant(ProjectEventActorType type) =>
    switch (type) {
      ProjectEventActorType.user => ProjectBadgeVariant.primary,
      ProjectEventActorType.agent => ProjectBadgeVariant.secondary,
      ProjectEventActorType.system => ProjectBadgeVariant.outline,
    };

ProjectIndicatorTone _eventTone(ProjectEvent event) {
  if (event.terminalState == ProjectEventTerminalState.failed ||
      event.terminalState == ProjectEventTerminalState.timedOut ||
      event.terminalState == ProjectEventTerminalState.limitExceeded) {
    return ProjectIndicatorTone.destructive;
  }
  final payload = event.payload;
  if (payload is RunStatusChangedPayload) {
    return switch (payload.status) {
      'failed' ||
      'timedOut' ||
      'limitExceeded' => ProjectIndicatorTone.destructive,
      'completed' => ProjectIndicatorTone.success,
      'cancelled' || 'interrupted' => ProjectIndicatorTone.neutral,
      _ => ProjectIndicatorTone.primary,
    };
  }
  return switch (event.eventType) {
    ProjectEventType.projectArtifactChanged => ProjectIndicatorTone.warning,
    ProjectEventType.membershipChanged ||
    ProjectEventType.participationDecision => ProjectIndicatorTone.primary,
    _ => ProjectIndicatorTone.neutral,
  };
}

IconData _eventIcon(ProjectEventType type) => switch (type) {
  ProjectEventType.userMessage ||
  ProjectEventType.agentMessage => LucideIcons.messageSquareText,
  ProjectEventType.membershipChanged => LucideIcons.bot,
  ProjectEventType.projectArtifactChanged => LucideIcons.folderKanban,
  ProjectEventType.runStatusChanged => LucideIcons.activity,
  ProjectEventType.participationDecision => LucideIcons.brain,
  ProjectEventType.agentDelivery => LucideIcons.send,
  ProjectEventType.systemNotice => LucideIcons.info,
};
