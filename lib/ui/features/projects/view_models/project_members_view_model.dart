import 'dart:async';

import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/domain/repositories/project_agent_cursor_repository.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';
import 'package:hyve/domain/use_cases/manage_project_members.dart';
import 'package:hyve/ui/core/view_models/disposable_change_notifier.dart';

final class ProjectMemberSnapshot {
  const ProjectMemberSnapshot({
    required this.membership,
    required this.agent,
    this.activeRunId = '',
  });

  final ProjectMembership membership;
  final Agent? agent;
  final String activeRunId;

  bool get hasActiveRun => activeRunId.isNotEmpty;
}

final class ProjectMembersViewModel extends DisposableChangeNotifier {
  ProjectMembersViewModel({
    required this.projectId,
    required AgentRepository agentRepository,
    required ProjectMembershipRepository membershipRepository,
    required ProjectAgentCursorRepository cursorRepository,
    required ManageProjectMembers manageMembers,
  }) : _agentRepository = agentRepository,
       _membershipRepository = membershipRepository,
       _cursorRepository = cursorRepository,
       _manageMembers = manageMembers {
    _agentSubscription = _agentRepository.changes.listen((_) {
      unawaited(load());
    });
    _membershipSubscription = _membershipRepository.changes.listen((id) {
      if (id == projectId) unawaited(load());
    });
    _cursorSubscription = _cursorRepository.changes.listen((key) {
      if (key.projectId == projectId) unawaited(load());
    });
  }

  final String projectId;
  final AgentRepository _agentRepository;
  final ProjectMembershipRepository _membershipRepository;
  final ProjectAgentCursorRepository _cursorRepository;
  final ManageProjectMembers _manageMembers;
  late final StreamSubscription<List<Agent>> _agentSubscription;
  late final StreamSubscription<String> _membershipSubscription;
  late final StreamSubscription<ProjectAgentInboxKey> _cursorSubscription;

  List<ProjectMemberSnapshot> _members = const <ProjectMemberSnapshot>[];
  List<Agent> _availableAgents = const <Agent>[];
  bool _loading = false;
  bool _mutating = false;
  String _errorCode = '';
  int _generation = 0;

  List<ProjectMemberSnapshot> get members => _members;
  List<Agent> get availableAgents => _availableAgents;
  bool get loading => _loading;
  bool get mutating => _mutating;
  String get errorCode => _errorCode;

  Future<void> load() async {
    if (isDisposed) return;
    final generation = ++_generation;
    _loading = true;
    notifyListeners();
    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        _agentRepository.getAgents(),
        _membershipRepository.getForProject(projectId),
        _cursorRepository.getForProject(projectId),
      ]);
      if (isDisposed || generation != _generation) return;
      final agents = results[0] as List<Agent>;
      final memberships = (results[1] as List<ProjectMembership>)
          .where((item) => item.status != ProjectMembershipStatus.removed)
          .toList(growable: false)
        ..sort((left, right) => left.position.compareTo(right.position));
      final cursors = <String, AgentMessageCursor>{
        for (final cursor in results[2] as List<AgentMessageCursor>)
          cursor.agentId: cursor,
      };
      final agentsById = <String, Agent>{
        for (final agent in agents) agent.id: agent,
      };
      final memberIds = memberships.map((item) => item.agentId).toSet();
      _members =
          List<ProjectMemberSnapshot>.unmodifiable(<ProjectMemberSnapshot>[
            for (final membership in memberships)
              ProjectMemberSnapshot(
                membership: membership,
                agent: agentsById[membership.agentId],
                activeRunId: cursors[membership.agentId]?.activeRunId ?? '',
              ),
          ]);
      _availableAgents = List<Agent>.unmodifiable(
        agents.where((agent) => !memberIds.contains(agent.id)),
      );
      _errorCode = '';
    } on Object {
      if (!isDisposed && generation == _generation) {
        _errorCode = 'project_members_load_failed';
      }
    } finally {
      if (!isDisposed && generation == _generation) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> add(String agentId) =>
      _mutate(() => _manageMembers.add(projectId, agentId));

  Future<void> setPaused(String agentId, {required bool paused}) => _mutate(
    () =>
        paused
            ? _manageMembers.pause(projectId, agentId)
            : _manageMembers.resume(projectId, agentId),
  );

  Future<void> setStorageAccess(String agentId, ProjectStorageAccess access) =>
      _mutate(
        () => _manageMembers.setStorageAccess(projectId, agentId, access),
      );

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (_mutating || oldIndex == newIndex) return;
    final ordered = _members.toList(growable: true);
    final moved = ordered.removeAt(oldIndex);
    ordered.insert(newIndex, moved);
    await _mutate(
      () => _manageMembers.reorder(
        projectId,
        ordered.map((item) => item.membership.agentId),
      ),
    );
  }

  Future<void> remove(String agentId) =>
      _mutate(() => _manageMembers.remove(projectId, agentId));

  void clearError() {
    if (_errorCode.isEmpty) return;
    _errorCode = '';
    notifyListeners();
  }

  Future<void> _mutate(Future<Object?> Function() operation) async {
    if (_mutating || isDisposed) return;
    _mutating = true;
    _errorCode = '';
    notifyListeners();
    try {
      await operation();
      await load();
    } on ProjectMemberMutationFailure catch (failure) {
      _errorCode = failure.code;
    } on Object {
      _errorCode = 'project_member_update_failed';
    } finally {
      if (!isDisposed) {
        _mutating = false;
        notifyListeners();
      }
    }
  }

  @override
  void disposeResources() {
    unawaited(_agentSubscription.cancel());
    unawaited(_membershipSubscription.cancel());
    unawaited(_cursorSubscription.cancel());
  }
}
