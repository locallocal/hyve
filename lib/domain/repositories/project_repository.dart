import 'package:hyve/domain/models/project.dart';
import 'package:hyve/domain/models/project_membership.dart';

abstract interface class ProjectRepository {
  Stream<List<Project>> get changes;

  Future<List<Project>> getProjects({bool forceRefresh = false});

  Future<Project?> getProject(String id);

  Future<void> addProject(Project project);

  Future<void> updateProject(Project project);

  /// Deletes the Project aggregate without deleting any Agent.
  Future<void> deleteProject(String id);
}

abstract interface class ProjectAggregateRepository
    implements ProjectRepository {
  Future<void> addProjectWithMemberships(
    Project project,
    Iterable<ProjectMembership> memberships,
  );
}
