import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/core/dependency_injection/app_scope.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/view_models/project_agent_activity.dart';
import 'package:hyve/ui/features/projects/view_models/project_members_view_model.dart';
import 'package:hyve/ui/features/projects/view_models/project_workspace_view_model.dart';
import 'package:hyve/ui/features/projects/views/project_artifacts_dialog.dart';
import 'package:hyve/ui/features/projects/views/project_event_list.dart';
import 'package:hyve/ui/features/projects/views/project_execution_panel.dart';
import 'package:hyve/ui/features/projects/views/project_members_sheet.dart';
import 'package:hyve/ui/features/projects/views/project_message_composer.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

export 'package:hyve/ui/features/projects/views/project_event_list.dart'
    show ProjectDeliveryCard;

/// Commands exposed by an embedded Project workspace to its desktop shell.
final class ProjectWorkspaceController {
  _ProjectWorkspacePageState? _state;

  Future<void> showMembers() async {
    final state = _state;
    if (state != null) await state._showMembers();
  }

  void showArtifacts() => _state?._showArtifacts();

  void showExecution() => _state?._showExecution();

  void _attach(_ProjectWorkspacePageState state) => _state = state;

  void _detach(_ProjectWorkspacePageState state) {
    if (identical(_state, state)) _state = null;
  }
}

final class ProjectWorkspacePage extends StatefulWidget {
  const ProjectWorkspacePage({
    super.key,
    required this.projectId,
    this.projectName = '',
    this.embedded = false,
    this.controller,
  });

  final String projectId;
  final String projectName;
  final bool embedded;
  final ProjectWorkspaceController? controller;

  @override
  State<ProjectWorkspacePage> createState() => _ProjectWorkspacePageState();
}

final class _ProjectWorkspacePageState extends State<ProjectWorkspacePage> {
  final StructuredProjectMessageController _composer =
      StructuredProjectMessageController();
  ProjectWorkspaceViewModel? _viewModel;
  ProjectMembersViewModel? _membersViewModel;
  final List<PendingAttachment> _attachments = <PendingAttachment>[];

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant ProjectWorkspacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
  }

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
    widget.controller?._detach(this);
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

  void _toggleAttachmentPromotion(int index, bool promote) {
    setState(() {
      _attachments[index] = _attachments[index].copyWith(
        promoteToProjectArtifact: promote,
      );
    });
  }

  Future<void> _showMembers() async {
    final viewModel = _membersViewModel!;
    if (hasShadProjectTheme(context)) {
      await showProjectDialog<void>(
        context: context,
        builder:
            (_) => ProjectMembersSheet(
              viewModel: viewModel,
              disposeViewModel: false,
            ),
      );
      return;
    }
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
    await showProjectDialog<void>(
      context: context,
      builder:
          (_) => ProjectMembersSheet(
            viewModel: viewModel,
            disposeViewModel: false,
          ),
    );
  }

  void _showArtifacts() {
    showProjectDialog<void>(
      context: context,
      builder: (_) => ProjectArtifactsDialog(viewModel: _viewModel!),
    );
  }

  void _showExecution() {
    showProjectDialog<void>(
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
    return ProjectThemeScope(
      child: ListenableBuilder(
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
                final shadTheme = ShadTheme.maybeOf(context);
                final inspectorBreakpoint =
                    shadTheme?.breakpoints.xl.value ?? 1180;
                final persistentInspector =
                    constraints.maxWidth >= inspectorBreakpoint;
                return Scaffold(
                  appBar:
                      widget.embedded
                          ? null
                          : AppBar(
                            title: Text(title),
                            centerTitle: false,
                            scrolledUnderElevation: 0,
                            actions: <Widget>[
                              ProjectIconAction(
                                key: const ValueKey<String>(
                                  'project-members-button',
                                ),
                                label: copy.members,
                                onPressed: () => unawaited(_showMembers()),
                                icon: LucideIcons.bot,
                              ),
                              if (!persistentInspector)
                                ProjectIconAction(
                                  key: const ValueKey<String>(
                                    'project-artifacts-button',
                                  ),
                                  label: copy.artifacts,
                                  onPressed: _showArtifacts,
                                  icon: LucideIcons.folderKanban,
                                ),
                              if (!persistentInspector)
                                ProjectIconAction(
                                  key: const ValueKey<String>(
                                    'project-execution-button',
                                  ),
                                  label: copy.execution,
                                  onPressed: _showExecution,
                                  icon: LucideIcons.activity,
                                ),
                              const SizedBox(width: 4),
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
                                  width: projectInspectorWidth,
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
      ),
    );
  }

  Widget _workspace(
    ProjectWorkspaceViewModel viewModel,
    ProjectLocalizations copy,
  ) => Column(
    children: <Widget>[
      ProjectContentBounds(
        child: _AgentStatusStrip(
          statuses: viewModel.agentStatuses,
          agents: viewModel.activeAgents,
        ),
      ),
      if (viewModel.activeAgents.isEmpty)
        ProjectContentBounds(
          child: _NoAgentsNotice(message: copy.noAgentsNotice),
        ),
      Expanded(
        child: ProjectContentBounds(
          child: ProjectEventList(
            events: viewModel.events,
            turns: viewModel.turns,
            deliveries: viewModel.deliveries,
            runs: viewModel.runs,
            agentNames: viewModel.agentNames,
            hasEarlier: viewModel.hasEarlierEvents,
            loadingEarlier: viewModel.eventPageBusy,
            onLoadEarlier: () => unawaited(viewModel.loadEarlierEvents()),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
      if (viewModel.errorCode.isNotEmpty)
        ProjectContentBounds(
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
      ProjectContentBounds(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ProjectMessageComposer(
          controller: _composer,
          activeAgents: viewModel.activeAgents,
          attachments: _attachments,
          hintText: copy.broadcastHint,
          onPickAttachment: () => unawaited(_pickAttachment()),
          onRemoveAttachment:
              (index) => setState(() => _attachments.removeAt(index)),
          onToggleAttachmentPromotion: _toggleAttachmentPromotion,
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

final class _PersistentProjectInspector extends StatefulWidget {
  const _PersistentProjectInspector({
    required this.artifacts,
    required this.execution,
  });

  final Widget artifacts;
  final Widget execution;

  @override
  State<_PersistentProjectInspector> createState() =>
      _PersistentProjectInspectorState();
}

final class _PersistentProjectInspectorState
    extends State<_PersistentProjectInspector> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    if (hasShadProjectTheme(context)) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: ShadTabs<int>(
          value: _selected,
          onChanged: (value) => setState(() => _selected = value),
          gap: 12,
          contentConstraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height,
          ),
          tabs: <ShadTab<int>>[
            ShadTab<int>(
              value: 0,
              leading: const Icon(LucideIcons.folderKanban, size: 16),
              content: widget.artifacts,
              expandContent: true,
              child: Text(copy.artifacts),
            ),
            ShadTab<int>(
              value: 1,
              leading: const Icon(LucideIcons.activity, size: 16),
              content: widget.execution,
              expandContent: true,
              child: Text(copy.execution),
            ),
          ],
        ),
      );
    }
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
          Expanded(
            child: TabBarView(
              children: <Widget>[widget.artifacts, widget.execution],
            ),
          ),
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
                    '${copy.processed(status.lastProcessedMessageSequence, status.latestMessageSequence)}'
                    '${status.errorCode.isEmpty ? '' : ', ${copy.errorCode(status.errorCode)}'}',
                child: ProjectBadge(
                  icon: _activityIcon(status.activity),
                  variant:
                      status.activity == ProjectAgentActivity.failed
                          ? ProjectBadgeVariant.destructive
                          : status.activeRunId.isNotEmpty
                          ? ProjectBadgeVariant.secondary
                          : ProjectBadgeVariant.outline,
                  label:
                      '${names[status.agentId] ?? status.agentId} · '
                      '${copy.activity(status.activity)} · '
                      '${copy.processed(status.lastProcessedMessageSequence, status.latestMessageSequence)}'
                      '${status.backlog > 0 ? ' · ${copy.backlog(status.backlog)}' : ''}'
                      '${status.errorCode.isEmpty ? '' : ' · ${copy.errorCode(status.errorCode)}'}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _NoAgentsNotice extends StatelessWidget {
  const _NoAgentsNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    if (hasShadProjectTheme(context)) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ShadAlert(
          key: const ValueKey<String>('project-no-agents-notice'),
          icon: const Icon(LucideIcons.info),
          description: Text(message),
        ),
      );
    }
    return MaterialBanner(
      key: const ValueKey<String>('project-no-agents-notice'),
      content: Text(message),
      leading: const Icon(Icons.info_outline),
      actions: const <Widget>[],
    );
  }
}

IconData _activityIcon(ProjectAgentActivity activity) => switch (activity) {
  ProjectAgentActivity.idle => Icons.check_circle_outline,
  ProjectAgentActivity.deciding => Icons.psychology_outlined,
  ProjectAgentActivity.willReply => Icons.pending_outlined,
  ProjectAgentActivity.skipped => Icons.next_plan_outlined,
  ProjectAgentActivity.replying => Icons.chat_bubble_outline,
  ProjectAgentActivity.catchingUp => Icons.sync,
  ProjectAgentActivity.paused => Icons.pause_circle_outline,
  ProjectAgentActivity.failed => Icons.error_outline,
};
