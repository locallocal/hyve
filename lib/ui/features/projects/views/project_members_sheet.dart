import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/view_models/project_agent_activity.dart';
import 'package:hyve/ui/features/projects/view_models/project_members_view_model.dart';
import 'package:hyve/ui/features/projects/views/project_agent_picker_dialog.dart';
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

  Future<void> _showAgentPicker() async {
    final agentId = await showProjectDialog<String>(
      context: context,
      builder:
          (_) => ProjectAgentPickerDialog(
            agents: widget.viewModel.availableAgents,
          ),
    );
    if (agentId != null && mounted) {
      await widget.viewModel.add(agentId);
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: ProjectTextInput(
                        key: const ValueKey<String>('project-member-search'),
                        controller: _search,
                        label: copy.searchAgents,
                        showLabel: false,
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    ProjectIconAction(
                      key: const ValueKey<String>('project-member-add'),
                      icon: LucideIcons.plus,
                      label: copy.addAgent,
                      variant: ShadButtonVariant.outline,
                      hitTargetSize: HyveDesktopThemeSpec.botFormFieldHeight,
                      buttonSize: HyveDesktopThemeSpec.botFormFieldHeight,
                      onPressed:
                          widget.viewModel.mutating ||
                                  widget.viewModel.availableAgents.isEmpty
                              ? null
                              : () => unawaited(_showAgentPicker()),
                    ),
                  ],
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
                                          widget.viewModel.canReorder
                                      ? (oldIndex, newIndex) => unawaited(
                                        widget.viewModel.reorder(
                                          oldIndex,
                                          newIndex,
                                        ),
                                      )
                                      : (_, _) {},
                              itemBuilder: (context, index) {
                                final member = members[index];
                                final agentId = member.membership.agentId;
                                final keepReorderVisuals =
                                    widget.viewModel.reordering;
                                final updatingAccess = widget.viewModel
                                    .isUpdatingStorageAccess(agentId);
                                final showDragHandle =
                                    members.length > 1 && normalized.isEmpty;
                                return _MemberCard(
                                  key: ValueKey<String>(
                                    'project-member-$agentId',
                                  ),
                                  member: member,
                                  processingStatus: statusesByAgent[agentId],
                                  index: index,
                                  enabled:
                                      (!widget.viewModel.mutating &&
                                          !updatingAccess) ||
                                      keepReorderVisuals,
                                  updatingAccess: updatingAccess,
                                  showDragHandle: showDragHandle,
                                  dragEnabled:
                                      showDragHandle &&
                                      (widget.viewModel.canReorder ||
                                          keepReorderVisuals),
                                  onPauseChanged:
                                      (paused) => unawaited(
                                        widget.viewModel.setPaused(
                                          agentId,
                                          paused: paused,
                                        ),
                                      ),
                                  onAccessChanged:
                                      (access) => unawaited(
                                        widget.viewModel.setStorageAccess(
                                          agentId,
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
    required this.updatingAccess,
    required this.showDragHandle,
    required this.dragEnabled,
    required this.onPauseChanged,
    required this.onAccessChanged,
    required this.onRemove,
  });

  final ProjectMemberSnapshot member;
  final ProjectAgentStatusSnapshot? processingStatus;
  final int index;
  final bool enabled;
  final bool updatingAccess;
  final bool showDragHandle;
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
        enabled: enabled || updatingAccess,
        trailing:
            updatingAccess
                ? _MemberAccessProgressIndicator(agentId: membership.agentId)
                : null,
        blockInteraction: updatingAccess,
        statusLabel: updatingAccess ? copy.updatingStorageAccess : null,
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
        if (showDragHandle) ...<Widget>[
          Semantics(
            container: true,
            label: copy.reorderMember(name),
            enabled: dragEnabled,
            child: ReorderableDragStartListener(
              key: ValueKey<String>('member-reorder-${membership.agentId}'),
              index: index,
              enabled: dragEnabled,
              child: ExcludeSemantics(
                child:
                    shadTheme == null
                        ? Tooltip(
                          message: copy.reorderMember(name),
                          child: MouseRegion(
                            cursor:
                                dragEnabled
                                    ? SystemMouseCursors.grab
                                    : MouseCursor.defer,
                            child: const SizedBox.square(
                              dimension: 36,
                              child: Icon(LucideIcons.gripVertical, size: 18),
                            ),
                          ),
                        )
                        : ShadTooltip(
                          builder: (_) => Text(copy.reorderMember(name)),
                          child: ShadGestureDetector(
                            cursor:
                                dragEnabled
                                    ? SystemMouseCursors.grab
                                    : MouseCursor.defer,
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

final class _MemberAccessProgressIndicator extends StatelessWidget {
  const _MemberAccessProgressIndicator({required this.agentId});

  final String agentId;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.maybeOf(context);
    final color =
        shadTheme?.colorScheme.mutedForeground ??
        Theme.of(context).colorScheme.primary;
    return ExcludeSemantics(
      child: SizedBox.square(
        key: ValueKey<String>('member-access-progress-$agentId'),
        dimension: 14,
        child: CircularProgressIndicator(color: color, strokeWidth: 2),
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
