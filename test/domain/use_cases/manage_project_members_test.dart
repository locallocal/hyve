import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/domain/repositories/project_agent_cursor_repository.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';
import 'package:hyve/domain/use_cases/manage_project_members.dart';

void main() {
  test('manages membership lifecycle, order, access, and active run', () async {
    final now = DateTime.utc(2026, 8, 22);
    final memberships = _MembershipRepository(<ProjectMembership>[
      _membership('project-1', 'agent-1', 0, now),
      _membership('project-1', 'agent-2', 1, now),
    ]);
    final cursors = _CursorRepository();
    final wakes = <String>[];
    final cancelled = <String>[];
    final manage = ManageProjectMembers(
      projectRepository: _ProjectRepository(_project(now)),
      agentRepository: _AgentRepository(<Agent>[
        _agent('agent-1', now),
        _agent('agent-2', now),
        _agent('agent-3', now),
      ]),
      membershipRepository: memberships,
      cursorRepository: cursors,
      wakeup: (projectId, agentIds) async => wakes.addAll(agentIds),
      cancelRun: (runId) {
        cancelled.add(runId);
        return true;
      },
      clock: () => now,
    );

    await manage.pause('project-1', 'agent-1');
    expect(memberships.item('agent-1').status, ProjectMembershipStatus.paused);
    await manage.resume('project-1', 'agent-1');
    expect(memberships.item('agent-1').status, ProjectMembershipStatus.active);
    expect(wakes, ['agent-1']);

    await manage.setStorageAccess(
      'project-1',
      'agent-1',
      ProjectStorageAccess.readWrite,
    );
    expect(
      memberships.item('agent-1').projectStorageAccess,
      ProjectStorageAccess.readWrite,
    );
    await manage.reorder('project-1', const <String>['agent-2', 'agent-1']);
    expect(memberships.item('agent-2').position, 0);
    expect(memberships.item('agent-1').position, 1);

    cursors.activeRunId = 'run-1';
    await manage.remove('project-1', 'agent-1');
    expect(cancelled, ['run-1']);
    expect(memberships.item('agent-1').status, ProjectMembershipStatus.removed);

    final added = await manage.add('project-1', 'agent-3');
    expect(added.joinMessageSequence, 7);
    expect(added.position, 1);
    expect(added.projectStorageAccess, ProjectStorageAccess.read);

    final rejoined = await manage.add('project-1', 'agent-1');
    expect(rejoined.membershipGeneration, 2);
    expect(rejoined.joinMessageSequence, 7);
    expect(rejoined.position, 2);
    expect(wakes, ['agent-1', 'agent-3', 'agent-1']);
  });

  test('rejects stale reorder input without changing positions', () async {
    final now = DateTime.utc(2026, 8, 22);
    final memberships = _MembershipRepository(<ProjectMembership>[
      _membership('project-1', 'agent-1', 0, now),
      _membership('project-1', 'agent-2', 1, now),
    ]);
    final manage = ManageProjectMembers(
      projectRepository: _ProjectRepository(_project(now)),
      agentRepository: _AgentRepository(<Agent>[]),
      membershipRepository: memberships,
      cursorRepository: _CursorRepository(),
      wakeup: (_, _) async {},
      cancelRun: (_) => false,
      clock: () => now,
    );

    await expectLater(
      manage.reorder('project-1', const <String>['agent-1']),
      throwsA(
        isA<ProjectMemberMutationFailure>().having(
          (failure) => failure.code,
          'code',
          'member_order_stale',
        ),
      ),
    );
    expect(memberships.item('agent-1').position, 0);
    expect(memberships.item('agent-2').position, 1);
  });
}

Project _project(DateTime now) => Project(
  id: 'project-1',
  name: 'Project',
  lastMessageSequence: 7,
  lastMessageAt: now,
  createdAt: now,
  updatedAt: now,
);

Agent _agent(String id, DateTime now) => Agent(
  id: id,
  name: id,
  avatar: '',
  provider: 'test',
  baseUrl: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: '',
  createdAt: now,
  updatedAt: now,
);

ProjectMembership _membership(
  String projectId,
  String agentId,
  int position,
  DateTime now,
) => ProjectMembership(
  projectId: projectId,
  agentId: agentId,
  position: position,
  joinedAt: now,
  updatedAt: now,
);

final class _ProjectRepository implements ProjectRepository {
  const _ProjectRepository(this.project);

  final Project project;

  @override
  Stream<List<Project>> get changes => const Stream<List<Project>>.empty();

  @override
  Future<Project?> getProject(String id) async =>
      id == project.id ? project : null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _AgentRepository implements AgentRepository {
  const _AgentRepository(this.agents);

  final List<Agent> agents;

  @override
  Stream<List<Agent>> get changes => const Stream<List<Agent>>.empty();

  @override
  Future<Agent?> getAgent(String id) async =>
      agents.where((agent) => agent.id == id).firstOrNull;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _MembershipRepository implements ProjectMembershipRepository {
  _MembershipRepository(Iterable<ProjectMembership> items)
    : _items = <String, ProjectMembership>{
        for (final item in items) item.agentId: item,
      };

  final Map<String, ProjectMembership> _items;

  ProjectMembership item(String agentId) => _items[agentId]!;

  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<List<ProjectMembership>> getForProject(String projectId) async =>
      _items.values
          .where((item) => item.projectId == projectId)
          .toList(growable: false);

  @override
  Future<ProjectMembership?> getMembership(
    String projectId,
    String agentId,
  ) async => _items[agentId];

  @override
  Future<void> save(ProjectMembership membership) async {
    _items[membership.agentId] = membership;
  }

  @override
  Future<void> saveAll(Iterable<ProjectMembership> memberships) async {
    for (final membership in memberships) {
      _items[membership.agentId] = membership;
    }
  }

  @override
  Future<void> remove(
    String projectId,
    String agentId,
    DateTime removedAt,
  ) async {
    _items[agentId] = _items[agentId]!.copyWith(
      status: ProjectMembershipStatus.removed,
      removedAt: removedAt,
      updatedAt: removedAt,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _CursorRepository implements ProjectAgentCursorRepository {
  String activeRunId = '';

  @override
  Stream<ProjectAgentInboxKey> get changes =>
      const Stream<ProjectAgentInboxKey>.empty();

  @override
  Future<AgentMessageCursor?> getCursor(
    String projectId,
    String agentId,
  ) async => AgentMessageCursor(
    projectId: projectId,
    agentId: agentId,
    lastProcessedMessageSequence: 0,
    activeRunId: activeRunId.isEmpty ? null : activeRunId,
    updatedAt: DateTime.utc(2026, 8, 22),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
