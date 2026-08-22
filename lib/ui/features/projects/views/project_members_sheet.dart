import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/view_models/project_members_view_model.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(copy.removeMemberTitle(name)),
            content: Text(copy.removeMemberDescription(member.hasActiveRun)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(copy.cancel),
              ),
              FilledButton(
                key: const ValueKey<String>('confirm-remove-project-member'),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(copy.remove),
              ),
            ],
          ),
    );
    if (confirmed == true && mounted) {
      await widget.viewModel.remove(member.membership.agentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: widget.embedded ? double.infinity : 760,
        maxHeight: widget.embedded ? double.infinity : 720,
      ),
      child: _buildContent(context),
    );
    if (widget.embedded) return content;
    return Dialog(child: content);
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
                    Icon(Icons.group_outlined, semanticLabel: copy.members),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        copy.members,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (!widget.embedded)
                      IconButton(
                        tooltip: copy.close,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey<String>('project-member-search'),
                  controller: _search,
                  decoration: InputDecoration(
                    labelText: copy.searchAgents,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _query.isEmpty
                            ? null
                            : IconButton(
                              tooltip: copy.close,
                              onPressed: () {
                                _search.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.clear),
                            ),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  key: const ValueKey<String>('project-member-add'),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey<String>(
                      'project-member-add-options-${available.map((item) => item.id).join('-')}',
                    ),
                    isExpanded: true,
                    decoration: InputDecoration(labelText: copy.addAgent),
                    items: <DropdownMenuItem<String>>[
                      for (final agent in available)
                        DropdownMenuItem<String>(
                          value: agent.id,
                          child: Text(
                            agent.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    hint: Text(
                      available.isEmpty
                          ? copy.noAvailableAgents
                          : copy.addAgent,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onChanged:
                        widget.viewModel.mutating || available.isEmpty
                            ? null
                            : (agentId) {
                              if (agentId != null) {
                                unawaited(widget.viewModel.add(agentId));
                              }
                            },
                  ),
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
                          ? Center(child: Text(copy.noMembers))
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
      DropdownButton<ProjectStorageAccess>(
        key: ValueKey<String>('member-access-${membership.agentId}'),
        value: membership.projectStorageAccess,
        items: <DropdownMenuItem<ProjectStorageAccess>>[
          for (final access in ProjectStorageAccess.values)
            DropdownMenuItem<ProjectStorageAccess>(
              value: access,
              child: Text(copy.storageAccessName(access)),
            ),
        ],
        onChanged: (value) {
          if (value != null) onAccessChanged(value);
        },
      ),
      IconButton(
        key: ValueKey<String>('member-pause-${membership.agentId}'),
        tooltip: paused ? copy.resume : copy.pause,
        onPressed: () => onPauseChanged(!paused),
        icon: Icon(paused ? Icons.play_arrow : Icons.pause_outlined),
      ),
      IconButton(
        key: ValueKey<String>('member-remove-${membership.agentId}'),
        tooltip: copy.remove,
        onPressed: onRemove,
        icon: const Icon(Icons.person_remove_outlined),
      ),
    ];
    return Semantics(
      container: true,
      label:
          '$name, ${paused ? copy.pausedStatus : copy.active}, '
          '${copy.storageAccess}: ${copy.storageAccessName(membership.projectStorageAccess)}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final identity = Row(
                children: <Widget>[
                  ReorderableDragStartListener(
                    index: index,
                    enabled: dragEnabled,
                    child: const SizedBox.square(
                      dimension: 48,
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
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
