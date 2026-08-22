import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/core/dependency_injection/app_scope.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/view_models/project_members_view_model.dart';
import 'package:hyve/ui/features/projects/view_models/project_workspace_view_model.dart';
import 'package:hyve/ui/features/projects/views/project_artifacts_dialog.dart';
import 'package:hyve/ui/features/projects/views/project_event_list.dart';
import 'package:hyve/ui/features/projects/views/project_execution_panel.dart';
import 'package:hyve/ui/features/projects/views/project_members_sheet.dart';
import 'package:hyve/ui/features/projects/views/project_message_composer.dart';

export 'package:hyve/ui/features/projects/views/project_event_list.dart'
    show ProjectDeliveryCard;

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
  static const double _persistentInspectorBreakpoint = 1180;

  final StructuredProjectMessageController _composer =
      StructuredProjectMessageController();
  ProjectWorkspaceViewModel? _viewModel;
  ProjectMembersViewModel? _membersViewModel;
  final List<PendingAttachment> _attachments = <PendingAttachment>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) return;
    final dependencies = AppScope.of(context).projectAgents;
    _viewModel = dependencies.createWorkspaceViewModel(widget.projectId);
    _membersViewModel = dependencies.createMembersViewModel(widget.projectId);
    unawaited(_viewModel!.refresh());
    unawaited(_membersViewModel!.load());
  }

  @override
  void dispose() {
    _composer.dispose();
    _viewModel?.dispose();
    _membersViewModel?.dispose();
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

  Future<void> _showMembers() async {
    final viewModel = _membersViewModel!;
    if (MediaQuery.sizeOf(context).width < 700) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder:
            (_) => FractionallySizedBox(
              heightFactor: 0.9,
              child: ProjectMembersSheet(
                viewModel: viewModel,
                embedded: true,
                disposeViewModel: false,
              ),
            ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder:
          (_) => ProjectMembersSheet(
            viewModel: viewModel,
            disposeViewModel: false,
          ),
    );
  }

  void _showArtifacts() {
    showDialog<void>(
      context: context,
      builder: (_) => ProjectArtifactsDialog(viewModel: _viewModel!),
    );
  }

  void _showExecution() {
    showDialog<void>(
      context: context,
      builder: (_) => _executionPanel(_viewModel!),
    );
  }

  ProjectExecutionPanel _executionPanel(
    ProjectWorkspaceViewModel viewModel, {
    bool embedded = false,
  }) => ProjectExecutionPanel(
    turns: viewModel.turns,
    runs: viewModel.runs,
    decisions: viewModel.decisions,
    usageRecords: viewModel.usageRecords,
    events: viewModel.events,
    agentNames: viewModel.agentNames,
    embedded: embedded,
    onCancelRun: (runId) {
      viewModel.cancelRun(runId);
      unawaited(viewModel.refresh());
    },
    onCancelTurn: (turnId) {
      unawaited(viewModel.cancelTurn(turnId).then((_) => viewModel.refresh()));
    },
    onCancelRootChain: (rootRunId) {
      viewModel.cancelRootChain(rootRunId);
      unawaited(viewModel.refresh());
    },
  );

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: viewModel,
      builder:
          (context, _) => LayoutBuilder(
            builder: (context, constraints) {
              final copy = ProjectLocalizations.of(context);
              final project = viewModel.project;
              final title =
                  project?.name ??
                  (widget.projectName.trim().isEmpty
                      ? copy.workspace
                      : widget.projectName.trim());
              final persistentInspector =
                  constraints.maxWidth >= _persistentInspectorBreakpoint;
              return Scaffold(
                appBar: AppBar(
                  title: Text(title),
                  centerTitle: true,
                  scrolledUnderElevation: 0,
                  actions: <Widget>[
                    IconButton(
                      key: const ValueKey<String>('project-members-button'),
                      tooltip: copy.members,
                      onPressed: () => unawaited(_showMembers()),
                      icon: const Icon(Icons.group_outlined),
                    ),
                    if (!persistentInspector)
                      IconButton(
                        key: const ValueKey<String>('project-artifacts-button'),
                        tooltip: copy.artifacts,
                        onPressed: _showArtifacts,
                        icon: const Icon(Icons.folder_open_outlined),
                      ),
                    if (!persistentInspector)
                      IconButton(
                        key: const ValueKey<String>('project-execution-button'),
                        tooltip: copy.execution,
                        onPressed: _showExecution,
                        icon: const Icon(Icons.monitor_heart_outlined),
                      ),
                  ],
                ),
                body: SafeArea(
                  top: false,
                  child:
                      persistentInspector
                          ? Row(
                            children: <Widget>[
                              Expanded(child: _workspace(viewModel, copy)),
                              const VerticalDivider(width: 1),
                              SizedBox(
                                width: 390,
                                child: _PersistentProjectInspector(
                                  artifacts: ProjectArtifactsPanel(
                                    viewModel: viewModel,
                                  ),
                                  execution: _executionPanel(
                                    viewModel,
                                    embedded: true,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : _workspace(viewModel, copy),
                ),
              );
            },
          ),
    );
  }

  Widget _workspace(
    ProjectWorkspaceViewModel viewModel,
    ProjectLocalizations copy,
  ) => Column(
    children: <Widget>[
      _AgentStatusStrip(
        statuses: viewModel.agentStatuses,
        agents: viewModel.activeAgents,
      ),
      if (viewModel.activeAgents.isEmpty)
        MaterialBanner(
          key: const ValueKey<String>('project-no-agents-notice'),
          content: Text(copy.noAgentsNotice),
          leading: const Icon(Icons.info_outline),
          actions: <Widget>[
            TextButton(
              onPressed: () => unawaited(_showMembers()),
              child: Text(copy.addAgent),
            ),
          ],
        ),
      Expanded(
        child: ProjectEventList(
          events: viewModel.events,
          turns: viewModel.turns,
          deliveries: viewModel.deliveries,
          runs: viewModel.runs,
          agentNames: viewModel.agentNames,
          hasEarlier: viewModel.hasEarlierEvents,
          loadingEarlier: viewModel.eventPageBusy,
          onLoadEarlier: () => unawaited(viewModel.loadEarlierEvents()),
        ),
      ),
      if (viewModel.errorCode.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Semantics(
            liveRegion: true,
            child: Text(
              copy.routeError(viewModel.errorCode),
              key: const ValueKey<String>('project-route-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ProjectMessageComposer(
          controller: _composer,
          activeAgents: viewModel.activeAgents,
          attachments: _attachments,
          hintText: copy.broadcastHint,
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
  );
}

final class _PersistentProjectInspector extends StatelessWidget {
  const _PersistentProjectInspector({
    required this.artifacts,
    required this.execution,
  });

  final Widget artifacts;
  final Widget execution;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          TabBar(
            tabs: <Tab>[
              Tab(
                icon: const Icon(Icons.folder_outlined),
                text: copy.artifacts,
              ),
              Tab(
                icon: const Icon(Icons.monitor_heart_outlined),
                text: copy.execution,
              ),
            ],
          ),
          Expanded(child: TabBarView(children: <Widget>[artifacts, execution])),
        ],
      ),
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
    final copy = ProjectLocalizations.of(context);
    final names = <String, String>{
      for (final agent in agents) agent.id: agent.name,
    };
    return SingleChildScrollView(
      key: const ValueKey<String>('project-agent-statuses'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: <Widget>[
          for (final status in statuses)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Semantics(
                label:
                    '${names[status.agentId] ?? status.agentId}, '
                    '${copy.activity(status.activity)}, '
                    '${copy.processed(status.lastProcessedMessageSequence, status.latestMessageSequence)}',
                child: Chip(
                  avatar: Icon(_activityIcon(status.activity), size: 16),
                  label: Text(
                    '${names[status.agentId] ?? status.agentId} · '
                    '${copy.activity(status.activity)} · '
                    '${copy.processed(status.lastProcessedMessageSequence, status.latestMessageSequence)}'
                    '${status.backlog > 0 ? ' · ${copy.backlog(status.backlog)}' : ''}',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

IconData _activityIcon(ProjectAgentActivity activity) => switch (activity) {
  ProjectAgentActivity.idle => Icons.check_circle_outline,
  ProjectAgentActivity.deciding => Icons.psychology_outlined,
  ProjectAgentActivity.replying => Icons.chat_bubble_outline,
  ProjectAgentActivity.catchingUp => Icons.sync,
  ProjectAgentActivity.paused => Icons.pause_circle_outline,
  ProjectAgentActivity.failed => Icons.error_outline,
};
