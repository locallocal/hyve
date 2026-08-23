import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/view_models/project_members_view_model.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

final class ProjectMembersSheet extends StatefulWidget {
  const ProjectMembersSheet({
    super.key,
    required this.viewModel,
    this.embedded = false,
    this.disposeViewModel = true,
  });

  final ProjectMembersViewModel viewModel;
  final bool embedded;
  final bool disposeViewModel;

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
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
                Row(
                  children: <Widget>[
                    Icon(LucideIcons.bot, semanticLabel: copy.members),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        copy.members,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (!widget.embedded)
                      ProjectIconAction(
                        label: copy.close,
                        onPressed: () => Navigator.pop(context),
                        icon: LucideIcons.x,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ProjectTextInput(
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
                ),
                const SizedBox(height: 10),
                Column(
                  key: const ValueKey<String>('project-member-add'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (hasShadProjectTheme(context)) ...<Widget>[
                      Text(
                        copy.addAgent,
                        key: const ValueKey<String>('project-member-add-label'),
                        style: ShadTheme.of(context).textTheme.small,
                      ),
                      const SizedBox(height: 6),
                    ],
                    ProjectSelect<String>(
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
                          !widget.viewModel.mutating && available.isNotEmpty,
                      onChanged: (agentId) {
                        if (agentId != null) {
                          unawaited(widget.viewModel.add(agentId));
                        }
                      },
                    ),
                  ],
                ),
                if (widget.viewModel.errorCode.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        copy.memberError(widget.viewModel.errorCode),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                if (widget.viewModel.loading || widget.viewModel.mutating)
                  const LinearProgressIndicator(
                    key: ValueKey<String>('project-members-progress'),
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child:
                      members.isEmpty
                          ? ProjectEmptyState(
                            icon: LucideIcons.bot,
                            title: copy.noMembers,
                          )
                          : ReorderableListView.builder(
                            key: const ValueKey<String>('project-member-list'),
                            buildDefaultDragHandles: false,
                            itemCount: members.length,
                            onReorderItem:
                                normalized.isEmpty && !widget.viewModel.mutating
                                    ? (oldIndex, newIndex) => unawaited(
                                      widget.viewModel.reorder(
                                        oldIndex,
                                        newIndex,
                                      ),
                                    )
                                    : (_, _) {},
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return _MemberCard(
                                key: ValueKey<String>(
                                  'project-member-${member.membership.agentId}',
                                ),
                                member: member,
                                index: index,
                                dragEnabled:
                                    normalized.isEmpty &&
                                    !widget.viewModel.mutating,
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
              ],
            );
          },
        ),
      ),
    );
  }
}

final class _MemberCard extends StatelessWidget {
  const _MemberCard({
    super.key,
    required this.member,
    required this.index,
    required this.dragEnabled,
    required this.onPauseChanged,
    required this.onAccessChanged,
    required this.onRemove,
  });

  final ProjectMemberSnapshot member;
  final int index;
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
    final controls = <Widget>[
      SizedBox(
        width: 180,
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
          onChanged: (value) {
            if (value != null) onAccessChanged(value);
          },
        ),
      ),
      ProjectIconAction(
        key: ValueKey<String>('member-pause-${membership.agentId}'),
        label: paused ? copy.resume : copy.pause,
        onPressed: () => onPauseChanged(!paused),
        icon: paused ? LucideIcons.play : LucideIcons.pause,
      ),
      ProjectIconAction(
        key: ValueKey<String>('member-remove-${membership.agentId}'),
        label: copy.remove,
        onPressed: onRemove,
        icon: LucideIcons.trash2,
        destructive: true,
      ),
    ];
    return Semantics(
      container: true,
      label:
          '$name, ${paused ? copy.pausedStatus : copy.active}, '
          '${copy.storageAccess}: ${copy.storageAccessName(membership.projectStorageAccess)}',
      child: ProjectSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Padding(
          padding: EdgeInsets.zero,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < projectCompactWidth;
              final identity = Row(
                children: <Widget>[
                  ReorderableDragStartListener(
                    index: index,
                    enabled: dragEnabled,
                    child: const SizedBox.square(
                      dimension: 48,
                      child: Icon(LucideIcons.ellipsis),
                    ),
                  ),
                  if (hasShadProjectTheme(context))
                    ShadAvatar(
                      null,
                      size: const Size.square(40),
                      placeholder:
                          member.agent == null
                              ? const Icon(LucideIcons.circleSlash, size: 18)
                              : Text(name.characters.first.toUpperCase()),
                    )
                  else
                    CircleAvatar(
                      child:
                          member.agent == null
                              ? const Icon(Icons.person_off_outlined)
                              : Text(name.characters.first.toUpperCase()),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          paused ? copy.pausedStatus : copy.active,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    identity,
                    Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: controls,
                    ),
                  ],
                );
              }
              return Row(
                children: <Widget>[Expanded(child: identity), ...controls],
              );
            },
          ),
        ),
      ),
    );
  }
}
