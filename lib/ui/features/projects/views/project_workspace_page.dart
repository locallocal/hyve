import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/core/dependency_injection/app_scope.dart';
import 'package:hyve/ui/features/projects/view_models/project_workspace_view_model.dart';
import 'package:hyve/ui/features/projects/views/project_message_composer.dart';

final class ProjectWorkspacePage extends StatefulWidget {
  const ProjectWorkspacePage({
    super.key,
    required this.projectId,
    this.projectName = '',
  });

  final String projectId;
  final String projectName;

  @override
  State<ProjectWorkspacePage> createState() => _ProjectWorkspacePageState();
}

final class _ProjectWorkspacePageState extends State<ProjectWorkspacePage> {
  final StructuredProjectMessageController _composer =
      StructuredProjectMessageController();
  ProjectWorkspaceViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) return;
    _viewModel = AppScope.of(
      context,
    ).projectAgents.createWorkspaceViewModel(widget.projectId);
    unawaited(_viewModel!.refresh());
  }

  @override
  void dispose() {
    _composer.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  Future<void> _submit(ProjectMessageDraft draft) async {
    final routed = await _viewModel!.submit(draft);
    if (routed != null && mounted) _composer.clear();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final project = viewModel.project;
        final title =
            project?.name ??
            (widget.projectName.trim().isEmpty
                ? '项目工作区'
                : widget.projectName.trim());
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            centerTitle: true,
            scrolledUnderElevation: 0,
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                _AgentStatusStrip(
                  statuses: viewModel.agentStatuses,
                  agents: viewModel.activeAgents,
                ),
                Expanded(
                  child: _ProjectEventTimeline(
                    events: viewModel.events,
                    turns: viewModel.turns,
                  ),
                ),
                if (viewModel.errorCode.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text(
                      _routeErrorText(viewModel.errorCode),
                      key: const ValueKey<String>('project-route-error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: ProjectMessageComposer(
                    controller: _composer,
                    activeAgents: viewModel.activeAgents,
                    activeRunCount:
                        viewModel.agentStatuses
                            .where((status) => status.activeRunId.isNotEmpty)
                            .length,
                    onCancelRuns: viewModel.cancelActiveRuns,
                    onSend: (draft) => unawaited(_submit(draft)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

final class _AgentStatusStrip extends StatelessWidget {
  const _AgentStatusStrip({required this.statuses, required this.agents});

  final List<ProjectAgentStatusSnapshot> statuses;
  final List<Agent> agents;

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) return const SizedBox.shrink();
    final names = <String, String>{
      for (final agent in agents) agent.id: agent.name,
    };
    return SingleChildScrollView(
      key: const ValueKey<String>('project-agent-statuses'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          for (final status in statuses)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Chip(
                avatar: Icon(_activityIcon(status.activity), size: 16),
                label: Text(
                  '${names[status.agentId] ?? status.agentId} · '
                  '${_activityText(status.activity)}'
                  '${status.backlog > 0 ? ' (${status.backlog})' : ''}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _ProjectEventTimeline extends StatelessWidget {
  const _ProjectEventTimeline({required this.events, required this.turns});

  final List<ProjectEvent> events;
  final Map<String, ProjectTurn> turns;

  @override
  Widget build(BuildContext context) {
    final messages = events
        .where((event) => event.messageSequence != null)
        .toList(growable: false);
    if (messages.isEmpty) {
      return const Center(child: Text('发送消息开始协作；不使用 @ 时将广播。'));
    }
    return ListView.builder(
      key: const ValueKey<String>('project-event-timeline'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final event = messages[index];
        final fromUser = event.actorType == ProjectEventActorType.user;
        final turn = turns[event.turnId];
        return Align(
          alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color:
                  fromUser
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!fromUser)
                  Text(
                    event.actorNameSnapshot,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                Text(event.content),
                if (turn?.noParticipant == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '本条消息没有智能体需要补充',
                      key: ValueKey<String>('no-participant-${event.id}'),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _routeErrorText(String code) => switch (code) {
  'project_message_target_not_active' => '被 @ 的智能体已不在项目中，请删除或重新选择。',
  _ => '消息发送失败（$code）',
};

String _activityText(ProjectAgentActivity activity) => switch (activity) {
  ProjectAgentActivity.idle => '空闲',
  ProjectAgentActivity.deciding => '判断中',
  ProjectAgentActivity.replying => '回复中',
  ProjectAgentActivity.catchingUp => '追赶中',
  ProjectAgentActivity.paused => '已暂停',
  ProjectAgentActivity.failed => '失败',
};

IconData _activityIcon(ProjectAgentActivity activity) => switch (activity) {
  ProjectAgentActivity.idle => Icons.check_circle_outline,
  ProjectAgentActivity.deciding => Icons.psychology_outlined,
  ProjectAgentActivity.replying => Icons.chat_bubble_outline,
  ProjectAgentActivity.catchingUp => Icons.sync,
  ProjectAgentActivity.paused => Icons.pause_circle_outline,
  ProjectAgentActivity.failed => Icons.error_outline,
};
