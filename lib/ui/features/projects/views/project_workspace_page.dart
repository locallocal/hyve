import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/core/dependency_injection/app_scope.dart';
import 'package:hyve/ui/features/projects/view_models/project_workspace_view_model.dart';
import 'package:hyve/ui/features/projects/views/project_artifacts_dialog.dart';
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
  final List<PendingAttachment> _attachments = <PendingAttachment>[];

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
    if (routed != null && mounted) {
      _composer.clear();
      setState(_attachments.clear);
    }
  }

  Future<void> _pickAttachment() async {
    final attachment = await _viewModel!.pickMessageAttachment();
    if (attachment == null || !mounted) return;
    setState(() => _attachments.add(attachment));
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
            actions: [
              IconButton(
                key: const ValueKey<String>('project-artifacts-button'),
                tooltip: '项目产物',
                onPressed:
                    () => showDialog<void>(
                      context: context,
                      builder:
                          (_) => ProjectArtifactsDialog(viewModel: viewModel),
                    ),
                icon: const Icon(Icons.folder_open_outlined),
              ),
            ],
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
                    deliveries: viewModel.deliveries,
                    runs: viewModel.runs,
                    agentNames: viewModel.agentNames,
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
                    attachments: _attachments,
                    onPickAttachment: () => unawaited(_pickAttachment()),
                    onRemoveAttachment:
                        (index) => setState(() => _attachments.removeAt(index)),
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

final class ProjectDeliveryCard extends StatelessWidget {
  const ProjectDeliveryCard({
    super.key,
    required this.event,
    required this.delivery,
    required this.turn,
    required this.agentNames,
    required this.runs,
  });

  final ProjectEvent event;
  final AgentDelivery? delivery;
  final ProjectTurn? turn;
  final Map<String, String> agentNames;
  final Map<String, AgentRun> runs;

  @override
  Widget build(BuildContext context) {
    final payload = event.payload as AgentDeliveryPayload;
    final targets = event.targetAgentIds
        .map((id) => agentNames[id] ?? id)
        .join('、');
    final deliveryRun = runs[event.runId];
    final childRuns =
        runs.values.where((run) => run.parentRunId == event.runId).toList()
          ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
    return Card(
      key: ValueKey<String>('project-delivery-card-${event.id}'),
      margin: const EdgeInsets.symmetric(vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: ValueKey<String>('project-delivery-expansion-${event.id}'),
        leading: const Icon(Icons.forward_to_inbox_outlined),
        title: Text(payload.summary),
        subtitle: Text(
          '${event.actorNameSnapshot} → $targets · ${payload.kind.name}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            children: <Widget>[
              Chip(label: Text(payload.kind.name)),
              Chip(label: Text(event.visibility.name)),
              if (payload.requestPublicReply) const Chip(label: Text('请求公开回复')),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(payload.payload),
          if (payload.projectArtifactVersionIds.isNotEmpty)
            Text('产物版本：${payload.projectArtifactVersionIds.join('，')}'),
          const SizedBox(height: 12),
          Container(
            key: ValueKey<String>('project-delivery-audit-${event.id}'),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('审计详情'),
                Text('事件：${event.id}'),
                Text('轮次：${event.turnId} · ${turn?.status.name ?? 'unknown'}'),
                Text('来源运行：${delivery?.sourceRunId ?? '-'}'),
                Text(
                  '交付运行：${event.runId} · ${deliveryRun?.status.name ?? 'unknown'}',
                ),
                Text('根运行：${deliveryRun?.rootRunId ?? '-'}'),
                Text(
                  '交付深度：${delivery?.depth ?? deliveryRun?.deliveryDepth ?? 0}',
                ),
                if (childRuns.isNotEmpty)
                  Text(
                    '目标运行：${childRuns.map((run) => '${agentNames[run.agentId] ?? run.agentId}:${run.status.name}').join('，')}',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _ProjectEventTimeline extends StatelessWidget {
  const _ProjectEventTimeline({
    required this.events,
    required this.turns,
    required this.deliveries,
    required this.runs,
    required this.agentNames,
  });

  final List<ProjectEvent> events;
  final Map<String, ProjectTurn> turns;
  final Map<String, AgentDelivery> deliveries;
  final Map<String, AgentRun> runs;
  final Map<String, String> agentNames;

  @override
  Widget build(BuildContext context) {
    final messages = events
        .where(
          (event) =>
              event.messageSequence != null ||
              event.eventType == ProjectEventType.systemNotice,
        )
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
        if (event.eventType == ProjectEventType.systemNotice) {
          final notice = event.payload as SystemNoticePayload;
          return Align(
            alignment: Alignment.center,
            child: Container(
              key: ValueKey<String>('project-system-notice-${event.id}'),
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${notice.code}${notice.detail.isEmpty ? '' : ' · ${notice.detail}'}',
              ),
            ),
          );
        }
        if (event.eventType == ProjectEventType.agentDelivery) {
          return Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ProjectDeliveryCard(
                event: event,
                delivery: deliveries[event.id],
                turn: turn,
                agentNames: agentNames,
                runs: runs,
              ),
            ),
          );
        }
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
