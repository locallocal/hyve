import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';
import 'package:hyve/domain/use_cases/create_project.dart';

void main() {
  test('creates a project with distinct ordered Agent memberships', () async {
    final repository = _ProjectRepository();
    final createProject = CreateProject(
      projectRepository: repository,
      membershipRepository: _MembershipRepository(),
      clock: () => DateTime(2026, 8, 18),
    );

    final project = await createProject(
      name: '  Launch plan  ',
      agentIds: const ['researcher', 'writer', 'researcher'],
    );

    expect(project.name, 'Launch plan');
    expect(repository.added, [project]);
    expect(repository.memberships.single.map((item) => item.agentId), [
      'researcher',
      'writer',
    ]);
    expect(repository.memberships.single.map((item) => item.position), [0, 1]);
    expect(
      repository.memberships.single.map((item) => item.projectStorageAccess),
      everyElement(ProjectStorageAccess.read),
    );
  });

  test('allows a project without an Agent', () async {
    final repository = _ProjectRepository();
    final createProject = CreateProject(
      projectRepository: repository,
      membershipRepository: _MembershipRepository(),
    );

    final project = await createProject(name: 'Empty');

    expect(repository.added, [project]);
    expect(repository.memberships.single, isEmpty);
  });

  test('rejects an empty project name before persistence', () async {
    final repository = _ProjectRepository();
    final createProject = CreateProject(
      projectRepository: repository,
      membershipRepository: _MembershipRepository(),
    );

    await expectLater(
      createProject(name: '   ', agentIds: const ['researcher']),
      throwsArgumentError,
    );
    expect(repository.added, isEmpty);
  });
}

final class _ProjectRepository implements ProjectAggregateRepository {
  final List<Project> added = <Project>[];
  final List<List<ProjectMembership>> memberships = <List<ProjectMembership>>[];

  @override
  Stream<List<Project>> get changes => const Stream<List<Project>>.empty();

  @override
  Future<void> addProjectWithMemberships(
    Project project,
    Iterable<ProjectMembership> memberships,
  ) async {
    added.add(project);
    this.memberships.add(memberships.toList(growable: false));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _MembershipRepository implements ProjectMembershipRepository {
  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
