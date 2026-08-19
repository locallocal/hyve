import 'package:hyve/domain/models/project_membership.dart';

abstract interface class ProjectMembershipRepository {
  Stream<String> get changes;

  Future<List<ProjectMembership>> getForProject(String projectId);

  Future<List<ProjectMembership>> getForAgent(String agentId);

  Future<ProjectMembership?> getMembership(String projectId, String agentId);

  Future<void> save(ProjectMembership membership);

  Future<void> saveAll(Iterable<ProjectMembership> memberships);

  Future<void> remove(String projectId, String agentId, DateTime removedAt);
}
