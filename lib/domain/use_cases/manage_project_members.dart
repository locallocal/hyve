import 'package:hyve/domain/models/agent.dart';
import 'package:hyve/domain/models/project_membership.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/domain/repositories/project_agent_cursor_repository.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';

typedef ProjectMemberClock = DateTime Function();
typedef ProjectMemberWakeup =
    Future<void> Function(String projectId, Iterable<String> agentIds);
typedef ProjectMemberRunCanceller = bool Function(String runId);

final class ProjectMemberMutationFailure implements Exception {
  const ProjectMemberMutationFailure(this.code);

  final String code;

  @override
  String toString() => 'ProjectMemberMutationFailure($code)';
}

/// Owns membership lifecycle invariants and keeps them out of presentation.
final class ManageProjectMembers {
  ManageProjectMembers({
    required ProjectRepository projectRepository,
    required AgentRepository agentRepository,
    required ProjectMembershipRepository membershipRepository,
    required ProjectAgentCursorRepository cursorRepository,
    required ProjectMemberWakeup wakeup,
    required ProjectMemberRunCanceller cancelRun,
    ProjectMemberClock? clock,
  }) : _projectRepository = projectRepository,
       _agentRepository = agentRepository,
       _membershipRepository = membershipRepository,
       _cursorRepository = cursorRepository,
       _wakeup = wakeup,
       _cancelRun = cancelRun,
       _clock = clock ?? DateTime.now;

  final ProjectRepository _projectRepository;
  final AgentRepository _agentRepository;
  final ProjectMembershipRepository _membershipRepository;
  final ProjectAgentCursorRepository _cursorRepository;
  final ProjectMemberWakeup _wakeup;
  final ProjectMemberRunCanceller _cancelRun;
  final ProjectMemberClock _clock;

  Future<ProjectMembership> add(String projectId, String agentId) async {
    final project = await _projectRepository.getProject(projectId);
    final Agent? agent = await _agentRepository.getAgent(agentId);
    if (project == null) {
      throw const ProjectMemberMutationFailure('project_not_found');
    }
    if (agent == null) {
      throw const ProjectMemberMutationFailure('agent_not_found');
    }
    final memberships = await _membershipRepository.getForProject(projectId);
    final existing = memberships.where((item) => item.agentId == agentId);
    final current = existing.isEmpty ? null : existing.single;
    if (current != null && current.status != ProjectMembershipStatus.removed) {
      return current;
    }
    final now = _clock();
    final position =
        memberships
            .where((item) => item.status != ProjectMembershipStatus.removed)
            .length;
    final membership =
        current == null
            ? ProjectMembership(
              projectId: projectId,
              agentId: agentId,
              position: position,
              joinMessageSequence: project.lastMessageSequence,
              joinedAt: now,
              updatedAt: now,
            )
            : current.copyWith(
              status: ProjectMembershipStatus.active,
              position: position,
              projectStorageAccess: ProjectStorageAccess.read,
              membershipGeneration: current.membershipGeneration + 1,
              joinMessageSequence: project.lastMessageSequence,
              joinedAt: now,
              clearRemovedAt: true,
              updatedAt: now,
            );
    await _membershipRepository.save(membership);
    await _wakeup(projectId, <String>[agentId]);
    return membership;
  }

  Future<ProjectMembership> pause(String projectId, String agentId) =>
      _setStatus(projectId, agentId, ProjectMembershipStatus.paused);

  Future<ProjectMembership> resume(String projectId, String agentId) async {
    final membership = await _setStatus(
      projectId,
      agentId,
      ProjectMembershipStatus.active,
    );
    await _wakeup(projectId, <String>[agentId]);
    return membership;
  }

  Future<ProjectMembership> setStorageAccess(
    String projectId,
    String agentId,
    ProjectStorageAccess access,
  ) async {
    final current = await _requireMembership(projectId, agentId);
    final updated = current.copyWith(
      projectStorageAccess: access,
      updatedAt: _clock(),
    );
    await _membershipRepository.save(updated);
    return updated;
  }

  Future<void> reorder(String projectId, Iterable<String> agentIds) async {
    final orderedIds = agentIds.toList(growable: false);
    if (orderedIds.toSet().length != orderedIds.length) {
      throw const ProjectMemberMutationFailure('member_order_invalid');
    }
    final memberships = (await _membershipRepository.getForProject(projectId))
        .where((item) => item.status != ProjectMembershipStatus.removed)
        .toList(growable: false);
    final byId = <String, ProjectMembership>{
      for (final membership in memberships) membership.agentId: membership,
    };
    if (orderedIds.length != byId.length ||
        !orderedIds.every(byId.containsKey)) {
      throw const ProjectMemberMutationFailure('member_order_stale');
    }
    final now = _clock();
    await _membershipRepository.saveAll(<ProjectMembership>[
      for (final entry in orderedIds.indexed)
        byId[entry.$2]!.copyWith(position: entry.$1, updatedAt: now),
    ]);
  }

  Future<void> remove(String projectId, String agentId) async {
    await _requireMembership(projectId, agentId);
    final cursor = await _cursorRepository.getCursor(projectId, agentId);
    final activeRunId = cursor?.activeRunId ?? '';
    if (activeRunId.isNotEmpty) _cancelRun(activeRunId);
    await _membershipRepository.remove(projectId, agentId, _clock());
  }

  Future<ProjectMembership> _setStatus(
    String projectId,
    String agentId,
    ProjectMembershipStatus status,
  ) async {
    final current = await _requireMembership(projectId, agentId);
    if (current.status == status) return current;
    final updated = current.copyWith(status: status, updatedAt: _clock());
    await _membershipRepository.save(updated);
    return updated;
  }

  Future<ProjectMembership> _requireMembership(
    String projectId,
    String agentId,
  ) async {
    final membership = await _membershipRepository.getMembership(
      projectId,
      agentId,
    );
    if (membership == null ||
        membership.status == ProjectMembershipStatus.removed) {
      throw const ProjectMemberMutationFailure('project_member_not_found');
    }
    return membership;
  }
}
