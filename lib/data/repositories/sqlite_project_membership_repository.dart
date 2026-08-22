import 'dart:async';

import 'package:hyve/data/models/project_agent_records.dart';
import 'package:hyve/data/models/project_execution_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/project_event.dart';
import 'package:hyve/domain/models/project_membership.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';

final class SqliteProjectMembershipRepository
    implements ProjectMembershipRepository {
  SqliteProjectMembershipRepository({
    required LocalDatabaseService localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;
  final StreamController<String> _changes =
      StreamController<String>.broadcast();

  @override
  Stream<String> get changes => _changes.stream;

  @override
  Future<List<ProjectMembership>> getForProject(String projectId) async {
    return (await _localDatabase.loadProjectMemberships(projectId))
        .map((record) => ProjectMembershipRecord(record).toDomain())
        .toList(growable: false);
  }

  @override
  Future<List<ProjectMembership>> getForAgent(String agentId) async {
    return (await _localDatabase.loadAgentMemberships(agentId))
        .map((record) => ProjectMembershipRecord(record).toDomain())
        .toList(growable: false);
  }

  @override
  Future<ProjectMembership?> getMembership(
    String projectId,
    String agentId,
  ) async {
    final records = await _localDatabase.loadProjectMembership(
      projectId,
      agentId,
    );
    return records.isEmpty
        ? null
        : ProjectMembershipRecord(records.single).toDomain();
  }

  @override
  Future<void> save(ProjectMembership membership) async {
    await _localDatabase.saveProjectMembershipWithAudit(
      ProjectMembershipRecord.fromDomain(membership).values,
      ProjectEventRecord.fromDomain(
        _auditEvent(
          projectId: membership.projectId,
          agentId: membership.agentId,
          status: membership.status,
          timestamp: membership.updatedAt,
          generation: membership.membershipGeneration,
        ),
      ).values,
    );
    _emit(membership.projectId);
  }

  @override
  Future<void> saveAll(Iterable<ProjectMembership> memberships) async {
    final snapshot = memberships.toList(growable: false);
    await _localDatabase.saveProjectMemberships(
      snapshot.map(
        (membership) => ProjectMembershipRecord.fromDomain(membership).values,
      ),
    );
    for (final projectId in snapshot.map((item) => item.projectId).toSet()) {
      _emit(projectId);
    }
  }

  @override
  Future<void> remove(
    String projectId,
    String agentId,
    DateTime removedAt,
  ) async {
    await _localDatabase.markProjectMembershipRemovedWithAudit(
      projectId,
      agentId,
      removedAt.millisecondsSinceEpoch,
      ProjectEventRecord.fromDomain(
        _auditEvent(
          projectId: projectId,
          agentId: agentId,
          status: ProjectMembershipStatus.removed,
          timestamp: removedAt,
          generation: 0,
        ),
      ).values,
    );
    _emit(projectId);
  }

  void _emit(String projectId) {
    if (!_changes.isClosed) _changes.add(projectId);
  }

  Future<void> dispose() => _changes.close();
}

ProjectEvent _auditEvent({
  required String projectId,
  required String agentId,
  required ProjectMembershipStatus status,
  required DateTime timestamp,
  required int generation,
}) => ProjectEvent(
  id:
      'membership-$projectId-$agentId-$generation-${status.name}-'
      '${timestamp.microsecondsSinceEpoch}',
  projectId: projectId,
  sequence: 1,
  eventType: ProjectEventType.membershipChanged,
  actorType: ProjectEventActorType.user,
  actorId: 'current-user',
  actorNameSnapshot: 'User',
  visibility: ProjectEventVisibility.audit,
  payload: MembershipChangedPayload(
    agentId: agentId,
    currentStatus: status.name,
  ),
  createdAt: timestamp,
  updatedAt: timestamp,
);
