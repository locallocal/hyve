import 'package:flutter/material.dart';
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
    final actor =
        event.actorNameSnapshot.isEmpty
            ? event.actorType.name
            : event.actorNameSnapshot;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

IconData _eventIcon(ProjectEventType type) => switch (type) {
  ProjectEventType.membershipChanged => Icons.group_outlined,
  ProjectEventType.projectArtifactChanged => Icons.folder_outlined,
  ProjectEventType.runStatusChanged => Icons.monitor_heart_outlined,
  ProjectEventType.participationDecision => Icons.psychology_outlined,
  ProjectEventType.systemNotice => Icons.info_outline,
  _ => Icons.receipt_long_outlined,
};
