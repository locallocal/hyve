import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/core/dependency_injection/app_scope.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/view_models/project_members_view_model.dart';
import 'package:hyve/ui/features/projects/view_models/project_workspace_view_model.dart';
import 'package:hyve/ui/features/projects/views/project_artifacts_dialog.dart';
import 'package:hyve/ui/features/projects/views/project_event_list.dart';
import 'package:hyve/ui/features/projects/views/project_execution_panel.dart';
import 'package:hyve/ui/features/projects/views/project_initial_load_gate.dart';
import 'package:hyve/ui/features/projects/views/project_members_sheet.dart';
import 'package:hyve/ui/features/projects/views/project_message_composer.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

export 'package:hyve/ui/features/projects/views/project_event_list.dart'
    show ProjectDeliveryCard;

/// Primary surfaces that share the Project workspace's content area.
enum ProjectWorkspacePane { messages, members, artifacts, execution }

/// Commands exposed by an embedded Project workspace to its desktop shell.
final class ProjectWorkspaceController
    extends ValueNotifier<ProjectWorkspacePane> {
  ProjectWorkspaceController() : super(ProjectWorkspacePane.messages);

  bool get showingMembers => value == ProjectWorkspacePane.members;
  bool get showingArtifacts => value == ProjectWorkspacePane.artifacts;
  bool get showingExecution => value == ProjectWorkspacePane.execution;

  void showMembers() {
    value = ProjectWorkspacePane.members;
  }

  void showMessages() {
    value = ProjectWorkspacePane.messages;
  }

  void toggleMembers() => showingMembers ? showMessages() : showMembers();

  void showArtifacts() {
    value = ProjectWorkspacePane.artifacts;
  }

  void toggleArtifacts() => showingArtifacts ? showMessages() : showArtifacts();

  void showExecution() {
    value = ProjectWorkspacePane.execution;
  }

  void toggleExecution() => showingExecution ? showMessages() : showExecution();
}

/// Retains all workspace surfaces so switching project tools never
/// recreates the message timeline, its scroll position, or composer state.
final class ProjectWorkspacePaneStack extends StatelessWidget {
  const ProjectWorkspacePaneStack({
    super.key,
    required this.pane,
    required this.messages,
    required this.members,
    required this.artifacts,
    required this.execution,
  });

  final ProjectWorkspacePane pane;
  final Widget messages;
  final Widget members;
  final Widget artifacts;
  final Widget execution;

  @override
  Widget build(BuildContext context) {
    Widget cachedPane({
      required ProjectWorkspacePane target,
      required PageStorageKey<String> storageKey,
      required Widget child,
    }) {
      final active = pane == target;
      return ExcludeFocus(
        excluding: !active,
        child: TickerMode(
          enabled: active,
          child: KeyedSubtree(key: storageKey, child: child),
        ),
      );
    }

    return IndexedStack(
      key: const ValueKey<String>('project-workspace-pane-stack'),
      index: pane.index,
      sizing: StackFit.expand,
      children: <Widget>[
        cachedPane(
          target: ProjectWorkspacePane.messages,
          storageKey: const PageStorageKey<String>('project-message-list-page'),
          child: messages,
        ),
        cachedPane(
          target: ProjectWorkspacePane.members,
          storageKey: const PageStorageKey<String>('project-members-page'),
          child: members,
        ),
        cachedPane(
          target: ProjectWorkspacePane.artifacts,
          storageKey: const PageStorageKey<String>('project-artifacts-page'),
          child: artifacts,
        ),
        cachedPane(
          target: ProjectWorkspacePane.execution,
          storageKey: const PageStorageKey<String>('project-execution-page'),
          child: execution,
        ),
      ],
    );
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
  late ProjectWorkspaceController _workspaceController;
  late bool _ownsWorkspaceController;
  final List<PendingAttachment> _attachments = <PendingAttachment>[];

  @override
  void initState() {
    super.initState();
    _bindWorkspaceController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant ProjectWorkspacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsWorkspaceController) _workspaceController.dispose();
      _bindWorkspaceController(widget.controller);
    }
  }

  void _bindWorkspaceController(ProjectWorkspaceController? controller) {
    _workspaceController = controller ?? ProjectWorkspaceController();
    _ownsWorkspaceController = controller == null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) return;
    final appDependencies = AppScope.of(context);
    final dependencies = appDependencies.projectAgents;
    _viewModel = dependencies.createWorkspaceViewModel(
      widget.projectId,
      profileRepository: appDependencies.profileRepository,
      messageActionRepository: appDependencies.messageActionRepository,
    );
    _membersViewModel = dependencies.createMembersViewModel(widget.projectId);
    unawaited(_viewModel!.refresh());
  }

  @override
  void dispose() {
    _composer.dispose();
    _viewModel?.dispose();
    _membersViewModel?.dispose();
    if (_ownsWorkspaceController) _workspaceController.dispose();
    super.dispose();
  }

  Future<void> _submit(ProjectMessageDraft draft) async {
    final submission = _viewModel!.submit(draft);
    _composer.clear();
    setState(_attachments.clear);
    final routed = await submission;
    if (routed == null && mounted) {
      _composer.restoreDraft(draft);
      setState(() => _attachments.addAll(draft.attachments));
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

  Widget _membersSheet(
    ProjectMembersViewModel membersViewModel, {
    bool embedded = false,
    VoidCallback? onClose,
  }) {
    final workspaceViewModel = _viewModel!;
    return ListenableBuilder(
      listenable: workspaceViewModel,
      builder:
          (_, _) => ProjectMembersSheet(
            viewModel: membersViewModel,
            agentStatuses: workspaceViewModel.agentStatuses,
            embedded: embedded,
            disposeViewModel: false,
            onClose: onClose,
          ),
    );
  }

  ProjectExecutionPanel _executionPanel(
    ProjectWorkspaceViewModel viewModel, {
    bool embedded = false,
    VoidCallback? onClose,
  }) => ProjectExecutionPanel(
    turns: viewModel.turns,
    runs: viewModel.runs,
    decisions: viewModel.decisions,
    usageRecords: viewModel.usageRecords,
    events: viewModel.events,
    agentNames: viewModel.agentNames,
    embedded: embedded,
    onClose: onClose,
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
        listenable: _workspaceController,
        builder: (context, _) {
          final pane = _workspaceController.value;
          final showingMembers = pane == ProjectWorkspacePane.members;
          final showingArtifacts = pane == ProjectWorkspacePane.artifacts;
          final showingExecution = pane == ProjectWorkspacePane.execution;
          return PopScope(
            canPop: pane == ProjectWorkspacePane.messages,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _workspaceController.showMessages();
            },
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
                                      label:
                                          showingMembers
                                              ? copy.backToMessages
                                              : copy.members,
                                      onPressed:
                                          _workspaceController.toggleMembers,
                                      icon:
                                          showingMembers
                                              ? LucideIcons.messageSquareText
                                              : LucideIcons.bot,
                                      selected: showingMembers,
                                    ),
                                    if (!persistentInspector)
                                      ProjectIconAction(
                                        key: const ValueKey<String>(
                                          'project-artifacts-button',
                                        ),
                                        label:
                                            showingArtifacts
                                                ? copy.backToMessages
                                                : copy.artifacts,
                                        onPressed:
                                            _workspaceController
                                                .toggleArtifacts,
                                        icon:
                                            showingArtifacts
                                                ? LucideIcons.messageSquareText
                                                : LucideIcons.folderKanban,
                                        selected: showingArtifacts,
                                      ),
                                    if (!persistentInspector)
                                      ProjectIconAction(
                                        key: const ValueKey<String>(
                                          'project-execution-button',
                                        ),
                                        label:
                                            showingExecution
                                                ? copy.backToMessages
                                                : copy.execution,
                                        onPressed:
                                            _workspaceController
                                                .toggleExecution,
                                        icon:
                                            showingExecution
                                                ? LucideIcons.messageSquareText
                                                : LucideIcons.activity,
                                        selected: showingExecution,
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
                                      Expanded(
                                        child: _workspacePane(
                                          viewModel,
                                          copy,
                                          pane: pane,
                                        ),
                                      ),
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
                                  : _workspacePane(viewModel, copy, pane: pane),
                        ),
                      );
                    },
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _workspacePane(
    ProjectWorkspaceViewModel viewModel,
    ProjectLocalizations copy, {
    required ProjectWorkspacePane pane,
  }) {
    return ProjectWorkspacePaneStack(
      pane: pane,
      messages: _workspace(viewModel, copy),
      members: _membersSheet(
        _membersViewModel!,
        embedded: true,
        onClose: _workspaceController.showMessages,
      ),
      artifacts: ProjectArtifactsDialog(
        viewModel: viewModel,
        embedded: true,
        onClose: _workspaceController.showMessages,
      ),
      execution: _executionPanel(
        viewModel,
        embedded: true,
        onClose: _workspaceController.showMessages,
      ),
    );
  }

  Widget _workspace(
    ProjectWorkspaceViewModel viewModel,
    ProjectLocalizations copy,
  ) {
    final hasActiveAgents = viewModel.activeAgents.isNotEmpty;
    final hasTimelineEntries = ProjectEventList.hasTimelineEntries(
      viewModel.events,
    );
    return ProjectInitialLoadGate(
      ready: viewModel.project != null,
      loadingLabel: copy.loadingWorkspace,
      child: Column(
        children: <Widget>[
          if (!hasActiveAgents && hasTimelineEntries)
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
                agentsById: viewModel.agentsById,
                currentUserProfile: viewModel.currentUserProfile,
                hasEarlier: viewModel.hasEarlierEvents,
                loadingEarlier: viewModel.eventPageBusy,
                onLoadEarlier: () => unawaited(viewModel.loadEarlierEvents()),
                initialScrollOffset: viewModel.timelineOffset,
                onScrollOffsetChanged: viewModel.rememberTimelineOffset,
                padding: const EdgeInsets.symmetric(vertical: 12),
                emptyIcon:
                    hasActiveAgents
                        ? LucideIcons.messageSquareText
                        : LucideIcons.bot,
                emptyTitle:
                    hasActiveAgents
                        ? copy.emptyTimelineTitle
                        : copy.noAgentsTitle,
                emptyDescription:
                    hasActiveAgents ? copy.emptyTimeline : copy.noAgentsNotice,
                emptyAction:
                    hasActiveAgents
                        ? null
                        : ProjectActionButton(
                          label: copy.members,
                          onPressed: _workspaceController.showMembers,
                          leading: const Icon(LucideIcons.bot, size: 16),
                        ),
              ),
            ),
          ),
          if (viewModel.errorCode.isNotEmpty)
            ProjectContentBounds(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Semantics(
                liveRegion: true,
                child:
                    hasShadProjectTheme(context)
                        ? ShadAlert.destructive(
                          key: const ValueKey<String>('project-route-error'),
                          icon: const Icon(LucideIcons.circleAlert),
                          description: Text(
                            copy.routeError(viewModel.errorCode),
                          ),
                        )
                        : Text(
                          copy.routeError(viewModel.errorCode),
                          key: const ValueKey<String>('project-route-error'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
              ),
            ),
          ProjectContentBounds(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ProjectMessageComposer(
              controller: _composer,
              activeAgents: viewModel.activeAgents,
              attachments: _attachments,
              submitting: viewModel.submitting,
              hintText: copy.broadcastHint,
              onPickAttachment: () => unawaited(_pickAttachment()),
              onRemoveAttachment:
                  (index) => setState(() => _attachments.removeAt(index)),
              onToggleAttachmentPromotion: _toggleAttachmentPromotion,
              onSend: (draft) => unawaited(_submit(draft)),
            ),
          ),
        ],
      ),
    );
  }
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
