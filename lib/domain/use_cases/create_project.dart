import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';

typedef ProjectClock = DateTime Function();

final class CreateProject {
  CreateProject({
    required ProjectRepository projectRepository,
    required ProjectMembershipRepository membershipRepository,
    ProjectClock? clock,
  }) : _projectRepository = projectRepository,
       _membershipRepository = membershipRepository,
       _clock = clock ?? DateTime.now;

  final ProjectRepository _projectRepository;
  final ProjectMembershipRepository _membershipRepository;
  final ProjectClock _clock;
  int _sequence = 0;

  Future<Project> call({
    required String name,
    Iterable<String> agentIds = const <String>[],
  }) async {
    final projectName = name.trim();
    if (projectName.isEmpty || projectName.length > 80) {
      throw ArgumentError.value(
        name,
        'name',
        'Project name must contain between 1 and 80 characters.',
      );
    }

    final now = _clock();
    _sequence = (_sequence + 1) & 0x7fffffff;
    final project = Project(
      id: 'project_${now.microsecondsSinceEpoch}_$_sequence',
      name: projectName,
      lastMessageAt: now,
      createdAt: now,
      updatedAt: now,
    );
    final ids = <String>{
      for (final id in agentIds)
        if (id.trim().isNotEmpty) id.trim(),
    };
    final memberships = <ProjectMembership>[
      for (final entry in ids.indexed)
        ProjectMembership(
          projectId: project.id,
          agentId: entry.$2,
          position: entry.$1,
          joinedAt: now,
          updatedAt: now,
        ),
    ];

    final repository = _projectRepository;
    if (repository is ProjectAggregateRepository) {
      await repository.addProjectWithMemberships(project, memberships);
      return project;
    }

    await repository.addProject(project);
    try {
      await _membershipRepository.saveAll(memberships);
    } on Object {
      await repository.deleteProject(project.id);
      rethrow;
    }
    return project;
  }
}
