import 'dart:async';

import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_delivery_repository.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/domain/repositories/agent_run_repository.dart';
import 'package:hyve/domain/repositories/project_agent_cursor_repository.dart';
import 'package:hyve/domain/repositories/project_event_repository.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';
import 'package:hyve/domain/repositories/project_turn_repository.dart';
import 'package:hyve/domain/use_cases/agent_inbox_coordinator.dart';
import 'package:hyve/domain/use_cases/route_project_message.dart';
import 'package:hyve/ui/core/view_models/disposable_change_notifier.dart';

enum ProjectAgentActivity {
  idle,
  deciding,
  replying,
  catchingUp,
  paused,
  failed,
}

final class ProjectAgentStatusSnapshot {
  const ProjectAgentStatusSnapshot({
    required this.agentId,
    required this.activity,
    required this.lastProcessedMessageSequence,
    required this.latestMessageSequence,
    required this.backlog,
    this.activeRunId = '',
  });

  final String agentId;
  final ProjectAgentActivity activity;
  final int lastProcessedMessageSequence;
  final int latestMessageSequence;
  final int backlog;
  final String activeRunId;
}

final class ProjectWorkspaceViewModel extends DisposableChangeNotifier {
  ProjectWorkspaceViewModel({
    required this.projectId,
    required RouteProjectMessage routeProjectMessage,
    required ProjectRepository projectRepository,
    required ProjectMembershipRepository membershipRepository,
    required ProjectEventRepository eventRepository,
    required ProjectTurnRepository turnRepository,
    required AgentRepository agentRepository,
    required ProjectAgentCursorRepository cursorRepository,
    required AgentRunRepository runRepository,
    required AgentDeliveryRepository deliveryRepository,
    required AgentInboxCoordinator inboxCoordinator,
  }) : _routeProjectMessage = routeProjectMessage,
       _projectRepository = projectRepository,
       _membershipRepository = membershipRepository,
       _eventRepository = eventRepository,
       _turnRepository = turnRepository,
       _agentRepository = agentRepository,
       _cursorRepository = cursorRepository,
       _runRepository = runRepository,
       _deliveryRepository = deliveryRepository,
       _inboxCoordinator = inboxCoordinator {
    _cursorSubscription = _cursorRepository.changes.listen((key) {
      if (key.projectId == projectId) unawaited(refresh());
    });
    _membershipSubscription = _membershipRepository.changes.listen((id) {
      if (id == projectId) unawaited(refresh());
    });
    _eventSubscription = _eventRepository.changes.listen((id) {
      if (id == projectId) unawaited(refresh());
    });
    _agentSubscription = _agentRepository.changes.listen((_) {
      unawaited(refresh());
    });
    _projectSubscription = _projectRepository.changes.listen((projects) {
      if (projects.any((project) => project.id == projectId)) {
        unawaited(refresh());
      }
    });
    _deliverySubscription = _deliveryRepository.changes.listen((id) {
      if (id == projectId) unawaited(refresh());
    });
  }

  final String projectId;
  final RouteProjectMessage _routeProjectMessage;
  final ProjectRepository _projectRepository;
  final ProjectMembershipRepository _membershipRepository;
  final ProjectEventRepository _eventRepository;
  final ProjectTurnRepository _turnRepository;
  final AgentRepository _agentRepository;
  final ProjectAgentCursorRepository _cursorRepository;
  final AgentRunRepository _runRepository;
  final AgentDeliveryRepository _deliveryRepository;
  final AgentInboxCoordinator _inboxCoordinator;
  late final StreamSubscription<ProjectAgentInboxKey> _cursorSubscription;
  late final StreamSubscription<String> _membershipSubscription;
  late final StreamSubscription<String> _eventSubscription;
  late final StreamSubscription<List<Agent>> _agentSubscription;
  late final StreamSubscription<List<Project>> _projectSubscription;
  late final StreamSubscription<String> _deliverySubscription;

  List<ProjectAgentStatusSnapshot> _agentStatuses = const [];
  Project? _project;
  List<Agent> _activeAgents = const [];
  List<ProjectEvent> _events = const [];
  Map<String, ProjectTurn> _turns = const {};
  Map<String, AgentDelivery> _deliveries = const {};
  Map<String, AgentRun> _runs = const {};
  Map<String, String> _agentNames = const {};
  bool _submitting = false;
  String _errorCode = '';

  List<ProjectAgentStatusSnapshot> get agentStatuses => _agentStatuses;
  Project? get project => _project;
  List<Agent> get activeAgents => _activeAgents;
  List<ProjectEvent> get events => _events;
  Map<String, ProjectTurn> get turns => _turns;
  Map<String, AgentDelivery> get deliveries => _deliveries;
  Map<String, AgentRun> get runs => _runs;
  Map<String, String> get agentNames => _agentNames;
  bool get submitting => _submitting;
  String get errorCode => _errorCode;

  Future<void> refresh() async {
    final project = await _projectRepository.getProject(projectId);
    if (project == null || isDisposed) return;
    final memberships = await _membershipRepository.getForProject(projectId);
    final activeMemberships = memberships
        .where(
          (membership) => membership.status == ProjectMembershipStatus.active,
        )
        .toList(growable: false);
    final agentsById = <String, Agent>{
      for (final agent in await _agentRepository.getAgents()) agent.id: agent,
    };
    final events = await _eventRepository.getEvents(projectId, limit: 200);
    final turns = await _turnRepository.getForProject(projectId, limit: 200);
    final deliveryRecords = await Future.wait(<Future<AgentDelivery?>>[
      for (final event in events)
        if (event.eventType == ProjectEventType.agentDelivery)
          _deliveryRepository.getForEvent(event.id),
    ]);
    final turnRuns = await Future.wait(<Future<List<AgentRun>>>[
      for (final turn in turns) _runRepository.getForTurn(turn.id),
    ]);
    final cursors = await _cursorRepository.getForProject(projectId);
    final byAgent = <String, AgentMessageCursor>{
      for (final cursor in cursors) cursor.agentId: cursor,
    };
    final statuses = <ProjectAgentStatusSnapshot>[];
    for (final membership in memberships.where(
      (item) => item.status != ProjectMembershipStatus.removed,
    )) {
      final cursor = byAgent[membership.agentId];
      final run =
          cursor?.activeRunId == null
              ? null
              : await _runRepository.getRun(cursor!.activeRunId!);
      final last =
          cursor?.lastProcessedMessageSequence ??
          membership.joinMessageSequence;
      statuses.add(
        ProjectAgentStatusSnapshot(
          agentId: membership.agentId,
          activity: _activity(membership, cursor, run, project),
          lastProcessedMessageSequence: last,
          latestMessageSequence: project.lastMessageSequence,
          backlog:
              project.lastMessageSequence > last
                  ? project.lastMessageSequence - last
                  : 0,
          activeRunId: cursor?.activeRunId ?? '',
        ),
      );
    }
    if (isDisposed) return;
    _project = project;
    _activeAgents = List<Agent>.unmodifiable([
      for (final membership in activeMemberships)
        if (agentsById[membership.agentId] case final agent?) agent,
    ]);
    _events = List<ProjectEvent>.unmodifiable(events);
    _turns = Map<String, ProjectTurn>.unmodifiable({
      for (final turn in turns) turn.id: turn,
    });
    _deliveries = Map<String, AgentDelivery>.unmodifiable({
      for (final delivery in deliveryRecords)
        if (delivery != null) delivery.eventId: delivery,
    });
    _runs = Map<String, AgentRun>.unmodifiable({
      for (final values in turnRuns)
        for (final run in values) run.id: run,
    });
    _agentNames = Map<String, String>.unmodifiable({
      for (final entry in agentsById.entries) entry.key: entry.value.name,
    });
    _agentStatuses = List<ProjectAgentStatusSnapshot>.unmodifiable(statuses);
    notifyListeners();
  }

  Future<RoutedProjectMessage?> submit(ProjectMessageDraft draft) async {
    if (_submitting || draft.isEmpty) return null;
    _submitting = true;
    _errorCode = '';
    notifyListeners();
    try {
      return await _routeProjectMessage(projectId: projectId, draft: draft);
    } on ProjectMessageRouteFailure catch (failure) {
      _errorCode = failure.code;
      return null;
    } finally {
      if (!isDisposed) {
        _submitting = false;
        notifyListeners();
      }
    }
  }

  bool cancelRun(String runId) => _inboxCoordinator.cancelRun(runId);

  Future<int> cancelTurn(String turnId) => _inboxCoordinator.cancelTurn(turnId);

  int cancelActiveRuns() {
    var cancelled = 0;
    for (final runId
        in _agentStatuses
            .map((status) => status.activeRunId)
            .where((runId) => runId.isNotEmpty)
            .toSet()) {
      if (_inboxCoordinator.cancelRun(runId)) cancelled++;
    }
    return cancelled;
  }

  ProjectAgentActivity _activity(
    ProjectMembership membership,
    AgentMessageCursor? cursor,
    AgentRun? run,
    Project project,
  ) {
    if (membership.status != ProjectMembershipStatus.active ||
        cursor?.workerState == AgentInboxWorkerState.paused) {
      return ProjectAgentActivity.paused;
    }
    if (cursor?.workerState == AgentInboxWorkerState.error) {
      return ProjectAgentActivity.failed;
    }
    if (run?.phase == AgentRunPhase.decision && !run!.isTerminal) {
      return ProjectAgentActivity.deciding;
    }
    if (run?.phase == AgentRunPhase.reply && !run!.isTerminal) {
      return ProjectAgentActivity.replying;
    }
    if ((cursor?.lastProcessedMessageSequence ??
            membership.joinMessageSequence) <
        project.lastMessageSequence) {
      return ProjectAgentActivity.catchingUp;
    }
    return ProjectAgentActivity.idle;
  }

  @override
  void dispose() {
    _cursorSubscription.cancel();
    _membershipSubscription.cancel();
    _eventSubscription.cancel();
    _agentSubscription.cancel();
    _projectSubscription.cancel();
    _deliverySubscription.cancel();
    super.dispose();
  }
}
