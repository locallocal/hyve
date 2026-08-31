import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

/// Displays project audit events independently from broadcast run history.
final class ProjectAuditEventList extends StatelessWidget {
  const ProjectAuditEventList({
    super.key,
    required this.events,
    required this.hasBoundedHeight,
  });

  final List<ProjectEvent> events;
  final bool hasBoundedHeight;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    if (events.isEmpty) {
      return ProjectEmptyState(
        icon: LucideIcons.shieldCheck,
        title: copy.noAuditEvents,
      );
    }
    return ListView(
      key: const ValueKey<String>('project-audit-events-list'),
      primary: false,
      shrinkWrap: !hasBoundedHeight,
      physics: hasBoundedHeight ? null : const NeverScrollableScrollPhysics(),
      children: <Widget>[
        ProjectSurfaceCard(
          key: const ValueKey<String>('project-audit-events-card'),
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    const Icon(LucideIcons.shieldCheck, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        copy.auditEvents,
                        style:
                            ShadTheme.maybeOf(context)?.textTheme.h4 ??
                            Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ProjectBadge(
                      label: '${events.length}',
                      variant: ProjectBadgeVariant.outline,
                    ),
                  ],
                ),
              ),
              const _AuditSeparator(),
              for (
                var index = 0;
                index < events.length;
                index += 1
              ) ...<Widget>[
                _AuditEventTile(event: events[index]),
                if (index != events.length - 1) const _AuditSeparator(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

final class _AuditSeparator extends StatelessWidget {
  const _AuditSeparator();

  @override
  Widget build(BuildContext context) =>
      hasShadProjectTheme(context)
          ? const ShadSeparator.horizontal(
            margin: EdgeInsets.symmetric(horizontal: 16),
          )
          : const Divider(height: 1, indent: 16, endIndent: 16);
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
