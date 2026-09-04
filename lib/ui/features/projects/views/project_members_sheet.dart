import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/view_models/project_agent_activity.dart';
import 'package:hyve/ui/features/projects/view_models/project_members_view_model.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';
import 'package:hyve/utils/theme.dart';

final class ProjectMembersSheet extends StatefulWidget {
  const ProjectMembersSheet({
    super.key,
    required this.viewModel,
    this.agentStatuses = const <ProjectAgentStatusSnapshot>[],
    this.embedded = false,
    this.disposeViewModel = true,
    this.onClose,
  });

  final ProjectMembersViewModel viewModel;
  final List<ProjectAgentStatusSnapshot> agentStatuses;
  final bool embedded;
  final bool disposeViewModel;
  final VoidCallback? onClose;

  @override
  State<ProjectMembersSheet> createState() => _ProjectMembersSheetState();
}

final class _ProjectMembersSheetState extends State<ProjectMembersSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    unawaited(widget.viewModel.load());
  }

  @override
  void dispose() {
    _search.dispose();
    if (widget.disposeViewModel) widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _confirmRemove(ProjectMemberSnapshot member) async {
    final copy = ProjectLocalizations.of(context);
    final name = member.agent?.name ?? copy.deletedAgent;
    final confirmed = await showProjectConfirmation(
      context: context,
      title: copy.removeMemberTitle(name),
      description: copy.removeMemberDescription(member.hasActiveRun),
      cancelLabel: copy.cancel,
      confirmLabel: copy.remove,
      destructive: true,
      confirmKey: const ValueKey<String>('confirm-remove-project-member'),
    );
    if (confirmed && mounted) {
      await widget.viewModel.remove(member.membership.agentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProjectDialogSurface(
      embedded: widget.embedded,
      constraints: BoxConstraints(
        maxWidth: widget.embedded ? double.infinity : 760,
        maxHeight: widget.embedded ? double.infinity : 720,
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final shadTheme = ShadTheme.maybeOf(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final statusesByAgent = <String, ProjectAgentStatusSnapshot>{
              for (final status in widget.agentStatuses) status.agentId: status,
            };
            final normalized = _query.trim().toLowerCase();
            final members = widget.viewModel.members
                .where(
                  (item) =>
                      normalized.isEmpty ||
                      (item.agent?.name.toLowerCase().contains(normalized) ??
                          item.membership.agentId.toLowerCase().contains(
                            normalized,
                          )),
                )
                .toList(growable: false);
            final available = widget.viewModel.availableAgents
                .where(
                  (agent) =>
                      normalized.isEmpty ||
                      agent.name.toLowerCase().contains(normalized),
                )
                .toList(growable: false);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ProjectSectionHeader(
                  key: const ValueKey<String>('project-members-header'),
                  icon: LucideIcons.bot,
                  title: copy.members,
                  description: copy.membersDescription,
                  trailing:
                      widget.onClose != null
                          ? ProjectBackAction(
                            key: const ValueKey<String>(
                              'project-members-close',
                            ),
                            label: copy.backToMessages,
                            onPressed: widget.onClose,
                          )
                          : !widget.embedded
                          ? const SizedBox.square(dimension: 44)
                          : null,
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < projectCompactWidth;
                    final search = ProjectTextInput(
                      key: const ValueKey<String>('project-member-search'),
                      controller: _search,
                      label: copy.searchAgents,
                      leading: const Icon(LucideIcons.search, size: 16),
                      trailing:
                          _query.isEmpty
                              ? null
                              : ProjectIconAction(
                                label: copy.close,
                                onPressed: () {
                                  _search.clear();
                                  setState(() => _query = '');
                                },
                                icon: LucideIcons.x,
                              ),
                      onChanged: (value) => setState(() => _query = value),
                    );
                    final add = Column(
                      key: const ValueKey<String>('project-member-add'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (shadTheme != null) ...<Widget>[
                          Text(
                            copy.addAgent,
                            key: const ValueKey<String>(
                              'project-member-add-label',
                            ),
                            style: shadTheme.textTheme.small,
                          ),
                          const SizedBox(height: 6),
                        ],
                        SizedBox(
                          key: const ValueKey<String>(
                            'project-member-add-select',
                          ),
                          height:
                              shadTheme == null
                                  ? null
                                  : HyveDesktopThemeSpec.botFormFieldHeight,
                          child: ProjectSelect<String>(
                            key: ValueKey<String>(
                              'project-member-add-options-${available.map((item) => item.id).join('-')}',
                            ),
                            placeholder:
                                available.isEmpty
                                    ? copy.noAvailableAgents
                                    : copy.addAgent,
                            options: <ProjectSelectOption<String>>[
                              for (final agent in available)
                                ProjectSelectOption<String>(
                                  value: agent.id,
                                  label: agent.name,
                                ),
                            ],
                            enabled:
                                !widget.viewModel.mutating &&
                                available.isNotEmpty,
                            onChanged: (agentId) {
                              if (agentId != null) {
                                unawaited(widget.viewModel.add(agentId));
                              }
                            },
                          ),
                        ),
                      ],
                    );
                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          search,
                          const SizedBox(height: 12),
                          add,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(child: search),
                        const SizedBox(width: 12),
                        SizedBox(width: 240, child: add),
                      ],
                    );
                  },
                ),
                if (widget.viewModel.errorCode.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Semantics(
                      liveRegion: true,
                      child:
                          shadTheme == null
                              ? Text(
                                copy.memberError(widget.viewModel.errorCode),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              )
                              : ShadAlert.destructive(
                                icon: const Icon(LucideIcons.circleAlert),
                                title: Text(
                                  copy.memberError(widget.viewModel.errorCode),
                                ),
                              ),
                    ),
                  ),
                if (widget.viewModel.loading &&
                    widget.viewModel.members.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child:
                        shadTheme == null
                            ? const LinearProgressIndicator(
                              key: ValueKey<String>('project-members-progress'),
                            )
                            : const ShadProgress(
                              key: ValueKey<String>('project-members-progress'),
                            ),
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child:
                      members.isEmpty
                          ? ProjectEmptyState(
                            icon: LucideIcons.bot,
                            title: copy.noMembers,
                          )
                          : AbsorbPointer(
                            key: const ValueKey<String>(
                              'project-member-reorder-guard',
                            ),
                            absorbing: widget.viewModel.reordering,
                            child: ReorderableListView.builder(
                              key: const ValueKey<String>(
                                'project-member-list',
                              ),
                              buildDefaultDragHandles: false,
                              proxyDecorator: _undecoratedMemberDragProxy,
                              itemCount: members.length,
                              onReorderItem:
                                  normalized.isEmpty &&
                                          !widget.viewModel.mutating
                                      ? (oldIndex, newIndex) => unawaited(
                                        widget.viewModel.reorder(
                                          oldIndex,
                                          newIndex,
                                        ),
                                      )
                                      : (_, _) {},
                              itemBuilder: (context, index) {
                                final member = members[index];
                                final keepReorderVisuals =
                                    widget.viewModel.reordering;
                                return _MemberCard(
                                  key: ValueKey<String>(
                                    'project-member-${member.membership.agentId}',
                                  ),
                                  member: member,
                                  processingStatus:
                                      statusesByAgent[member
                                          .membership
                                          .agentId],
                                  index: index,
                                  enabled:
                                      !widget.viewModel.mutating ||
                                      keepReorderVisuals,
                                  dragEnabled:
                                      members.length > 1 &&
                                      normalized.isEmpty &&
                                      (!widget.viewModel.mutating ||
                                          keepReorderVisuals),
                                  onPauseChanged:
                                      (paused) => unawaited(
                                        widget.viewModel.setPaused(
                                          member.membership.agentId,
                                          paused: paused,
                                        ),
                                      ),
                                  onAccessChanged:
                                      (access) => unawaited(
                                        widget.viewModel.setStorageAccess(
                                          member.membership.agentId,
                                          access,
                                        ),
                                      ),
                                  onRemove:
                                      () => unawaited(_confirmRemove(member)),
                                );
                              },
                            ),
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _undecoratedMemberDragProxy(Widget child, int _, Animation<double> _) =>
    child;

final class _MemberCard extends StatelessWidget {
  const _MemberCard({
    super.key,
    required this.member,
    required this.processingStatus,
    required this.index,
    required this.enabled,
    required this.dragEnabled,
    required this.onPauseChanged,
    required this.onAccessChanged,
    required this.onRemove,
  });

  final ProjectMemberSnapshot member;
  final ProjectAgentStatusSnapshot? processingStatus;
  final int index;
  final bool enabled;
  final bool dragEnabled;
  final ValueChanged<bool> onPauseChanged;
  final ValueChanged<ProjectStorageAccess> onAccessChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final membership = member.membership;
    final paused = membership.status == ProjectMembershipStatus.paused;
    final name = member.agent?.name ?? copy.deletedAgent;
    final shadTheme = ShadTheme.maybeOf(context);
    final status = processingStatus;

    Widget accessControl() => KeyedSubtree(
      key: ValueKey<String>('member-access-${membership.agentId}'),
      child: ProjectSelect<ProjectStorageAccess>(
        initialValue: membership.projectStorageAccess,
        placeholder: copy.storageAccess,
        options: <ProjectSelectOption<ProjectStorageAccess>>[
          for (final access in ProjectStorageAccess.values)
            ProjectSelectOption<ProjectStorageAccess>(
              value: access,
              label: copy.storageAccessName(access),
            ),
        ],
        enabled: enabled,
        onChanged: (value) {
          if (value != null) onAccessChanged(value);
        },
      ),
    );
    final pauseAction = ProjectIconAction(
      key: ValueKey<String>('member-pause-${membership.agentId}'),
      label: paused ? copy.resume : copy.pause,
      onPressed: enabled ? () => onPauseChanged(!paused) : null,
      icon: paused ? LucideIcons.play : LucideIcons.pause,
    );
    final removeAction = ProjectIconAction(
      key: ValueKey<String>('member-remove-${membership.agentId}'),
      label: copy.remove,
      onPressed: enabled ? onRemove : null,
      icon: LucideIcons.trash2,
      destructive: true,
    );
    final identity = Row(
      children: <Widget>[
        if (dragEnabled) ...<Widget>[
          Semantics(
            container: true,
            label: copy.reorderMember(name),
            child: ReorderableDragStartListener(
              key: ValueKey<String>('member-reorder-${membership.agentId}'),
              index: index,
              child: ExcludeSemantics(
                child:
                    shadTheme == null
                        ? Tooltip(
                          message: copy.reorderMember(name),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            child: const SizedBox.square(
                              dimension: 36,
                              child: Icon(LucideIcons.gripVertical, size: 18),
                            ),
                          ),
                        )
                        : ShadTooltip(
                          builder: (_) => Text(copy.reorderMember(name)),
                          child: ShadGestureDetector(
                            cursor: SystemMouseCursors.grab,
                            child: SizedBox.square(
                              dimension: 36,
                              child: Icon(
                                LucideIcons.gripVertical,
                                size: 18,
                                color: shadTheme.colorScheme.mutedForeground,
                              ),
                            ),
                          ),
                        ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        _MemberAvatar(
          key: ValueKey<String>('member-avatar-${membership.agentId}'),
          agent: member.agent,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    shadTheme == null
                        ? Theme.of(context).textTheme.titleSmall
                        : shadTheme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
              ),
              const SizedBox(height: 6),
              if (status == null)
                ProjectBadge(
                  key: ValueKey<String>('member-status-${membership.agentId}'),
                  label: paused ? copy.pausedStatus : copy.active,
                  icon:
                      paused
                          ? LucideIcons.circlePause
                          : LucideIcons.circleCheck,
                  variant:
                      paused
                          ? ProjectBadgeVariant.secondary
                          : ProjectBadgeVariant.outline,
                )
              else
                _MemberProcessingSummary(status: status),
            ],
          ),
        ),
      ],
    );
    return Semantics(
      container: true,
      label:
          '$name, '
          '${status == null ? (paused ? copy.pausedStatus : copy.active) : copy.activity(status.activity)}, '
          '${copy.storageAccess}: ${copy.storageAccessName(membership.projectStorageAccess)}',
      child: ProjectSurfaceCard(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < projectCompactWidth;
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  identity,
                  const SizedBox(height: 12),
                  accessControl(),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[pauseAction, removeAction],
                  ),
                ],
              );
            }
            return Row(
              children: <Widget>[
                Expanded(child: identity),
                const SizedBox(width: 16),
                SizedBox(width: 180, child: accessControl()),
                const SizedBox(width: 4),
                pauseAction,
                removeAction,
              ],
            );
          },
        ),
      ),
    );
  }
}

final class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({super.key, required this.agent});

  final Agent? agent;

  @override
  Widget build(BuildContext context) {
    if (agent != null) return ProjectActorAvatar(agent: agent);
    return ShadTheme.maybeOf(context) == null
        ? const CircleAvatar(child: Icon(Icons.person_off_outlined))
        : const ShadAvatar(
          null,
          size: Size.square(40),
          placeholder: Icon(LucideIcons.circleSlash, size: 18),
        );
  }
}

final class _MemberProcessingSummary extends StatelessWidget {
  const _MemberProcessingSummary({required this.status});

  final ProjectAgentStatusSnapshot status;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final progress = copy.processed(
      status.lastProcessedMessageSequence,
      status.latestMessageSequence,
    );
    return Semantics(
      container: true,
      label:
          '${copy.activity(status.activity)}, $progress'
          '${status.backlog > 0 ? ', ${copy.backlog(status.backlog)}' : ''}'
          '${status.errorCode.isEmpty ? '' : ', ${copy.errorCode(status.errorCode)}'}',
      child: ExcludeSemantics(
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            ProjectBadge(
              key: ValueKey<String>('member-activity-${status.agentId}'),
              label: copy.activity(status.activity),
              icon: _activityIcon(status.activity),
              variant:
                  status.activity == ProjectAgentActivity.failed
                      ? ProjectBadgeVariant.destructive
                      : status.activeRunId.isNotEmpty
                      ? ProjectBadgeVariant.secondary
                      : ProjectBadgeVariant.outline,
            ),
            _ProcessingMeta(
              key: ValueKey<String>('member-progress-${status.agentId}'),
              icon: LucideIcons.listChecks,
              label: progress,
            ),
            if (status.backlog > 0)
              ProjectBadge(
                key: ValueKey<String>('member-backlog-${status.agentId}'),
                label: copy.backlog(status.backlog),
                icon: LucideIcons.clock3,
                variant: ProjectBadgeVariant.secondary,
              ),
            if (status.errorCode.isNotEmpty)
              ProjectBadge(
                key: ValueKey<String>('member-error-${status.agentId}'),
                label: copy.errorCode(status.errorCode),
                icon: LucideIcons.circleAlert,
                variant: ProjectBadgeVariant.destructive,
              ),
          ],
        ),
      ),
    );
  }
}

final class _ProcessingMeta extends StatelessWidget {
  const _ProcessingMeta({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.maybeOf(context);
    final color =
        shadTheme?.colorScheme.mutedForeground ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style:
              shadTheme?.textTheme.muted.copyWith(fontSize: 12) ??
              Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

IconData _activityIcon(ProjectAgentActivity activity) => switch (activity) {
  ProjectAgentActivity.idle => LucideIcons.circleCheck,
  ProjectAgentActivity.deciding => LucideIcons.brainCircuit,
  ProjectAgentActivity.willReply => LucideIcons.circleEllipsis,
  ProjectAgentActivity.skipped => LucideIcons.skipForward,
  ProjectAgentActivity.replying => LucideIcons.messageSquareText,
  ProjectAgentActivity.catchingUp => LucideIcons.refreshCw,
  ProjectAgentActivity.paused => LucideIcons.circlePause,
  ProjectAgentActivity.failed => LucideIcons.circleAlert,
};
