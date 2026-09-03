import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/domain/repositories/project_agent_cursor_repository.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';
import 'package:hyve/domain/use_cases/manage_project_members.dart';
import 'package:hyve/ui/features/projects/view_models/project_agent_activity.dart';
import 'package:hyve/ui/features/projects/view_models/project_members_view_model.dart';
import 'package:hyve/ui/features/projects/views/project_members_sheet.dart';
import 'package:hyve/utils/theme.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  testWidgets('narrow member sheet adds, pauses, grants access, and removes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 760);
    addTearDown(tester.view.reset);
    final now = DateTime.utc(2026, 8, 22);
    final avatarPath = File('assets/images/profile/avatar.png').absolute.path;
    final agents = _AgentRepository(<Agent>[
      _agent('agent-1', 'Researcher', now, avatar: avatarPath),
      _agent('agent-2', 'Writer', now),
    ]);
    final memberships = _MembershipRepository(<ProjectMembership>[
      _membership('agent-1', now),
    ]);
    final cursors = _CursorRepository(now)..activeRunId = 'run-1';
    final cancelled = <String>[];
    final manager = ManageProjectMembers(
      projectRepository: _ProjectRepository(now),
      agentRepository: agents,
      membershipRepository: memberships,
      cursorRepository: cursors,
      wakeup: (_, _) async {},
      cancelRun: (id) {
        cancelled.add(id);
        return true;
      },
      clock: () => now,
    );
    final viewModel = ProjectMembersViewModel(
      projectId: 'project-1',
      agentRepository: agents,
      membershipRepository: memberships,
      cursorRepository: cursors,
      manageMembers: manager,
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        home: Scaffold(
          body: ProjectMembersSheet(
            viewModel: viewModel,
            embedded: true,
            disposeViewModel: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Researcher'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('project-member-list')),
      findsOneWidget,
    );
    expect(find.byIcon(LucideIcons.ellipsis), findsNothing);
    expect(find.byIcon(LucideIcons.gripVertical), findsNothing);
    final memberAvatar = tester.widget<CircleAvatar>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('member-avatar-agent-1')),
        matching: find.byType(CircleAvatar),
      ),
    );
    expect(memberAvatar.backgroundImage, isA<FileImage>());
    expect((memberAvatar.backgroundImage! as FileImage).file.path, avatarPath);
    expect(memberAvatar.child, isNull);

    await tester.tap(find.byKey(const ValueKey<String>('project-member-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Writer').last);
    await tester.pumpAndSettle();
    expect(find.text('Writer'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('member-pause-agent-1')),
    );
    await tester.pumpAndSettle();
    expect(memberships.item('agent-1').status, ProjectMembershipStatus.paused);

    await tester.tap(
      find.byKey(const ValueKey<String>('member-access-agent-1')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read & write').last);
    await tester.pumpAndSettle();
    expect(
      memberships.item('agent-1').projectStorageAccess,
      ProjectStorageAccess.readWrite,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('member-remove-agent-1')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('active run'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('confirm-remove-project-member')),
    );
    await tester.pumpAndSettle();
    expect(cancelled, ['run-1']);
    expect(memberships.item('agent-1').status, ProjectMembershipStatus.removed);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop member panel uses Shad controls and filters safely', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 760);
    addTearDown(tester.view.reset);
    final now = DateTime.utc(2026, 8, 22);
    final avatarPath = File('assets/images/profile/avatar.png').absolute.path;
    final agents = _AgentRepository(<Agent>[
      _agent('agent-1', 'Researcher', now, avatar: avatarPath),
      _agent('agent-2', 'Writer', now),
    ]);
    final memberships = _MembershipRepository(<ProjectMembership>[
      _membership('agent-1', now),
    ]);
    final cursors = _CursorRepository(now);
    final statuses = ValueNotifier<List<ProjectAgentStatusSnapshot>>(
      const <ProjectAgentStatusSnapshot>[
        ProjectAgentStatusSnapshot(
          agentId: 'agent-1',
          activity: ProjectAgentActivity.replying,
          lastProcessedMessageSequence: 1,
          latestMessageSequence: 3,
          backlog: 2,
          activeRunId: 'run-1',
        ),
      ],
    );
    addTearDown(statuses.dispose);
    final viewModel = ProjectMembersViewModel(
      projectId: 'project-1',
      agentRepository: agents,
      membershipRepository: memberships,
      cursorRepository: cursors,
      manageMembers: ManageProjectMembers(
        projectRepository: _ProjectRepository(now),
        agentRepository: agents,
        membershipRepository: memberships,
        cursorRepository: cursors,
        wakeup: (_, _) async {},
        cancelRun: (_) => true,
        clock: () => now,
      ),
    );
    addTearDown(viewModel.dispose);

    await withDesktopPlatform(() async {
      await tester.pumpWidget(
        shadHarness(
          brightness: Brightness.light,
          locale: const Locale('en'),
          homeBuilder:
              (_) => ValueListenableBuilder<List<ProjectAgentStatusSnapshot>>(
                valueListenable: statuses,
                builder:
                    (_, agentStatuses, _) => Scaffold(
                      body: ProjectMembersSheet(
                        viewModel: viewModel,
                        agentStatuses: agentStatuses,
                        embedded: true,
                        disposeViewModel: false,
                      ),
                    ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('project-member-add-label')),
        findsOneWidget,
      );
      expect(find.byType(ShadInput), findsOneWidget);
      expect(find.byType(ShadSelect<String>), findsOneWidget);
      expect(find.byType(ShadSelect<ProjectStorageAccess>), findsOneWidget);
      final memberSearch = find.descendant(
        of: find.byKey(const ValueKey<String>('project-member-search')),
        matching: find.byType(ShadInput),
      );
      final memberSearchInput = tester.widget<ShadInput>(memberSearch);
      final memberAddSelect = find.descendant(
        of: find.byKey(const ValueKey<String>('project-member-add-select')),
        matching: find.byType(ShadSelect<String>),
      );
      expect(
        tester.getSize(memberAddSelect).height,
        HyveDesktopThemeSpec.botFormFieldHeight,
      );
      expect(
        tester.getSize(memberAddSelect).height,
        tester.getSize(memberSearch).height,
      );
      expect(memberSearchInput.alignment, AlignmentDirectional.centerStart);
      expect(
        memberSearchInput.placeholderAlignment,
        AlignmentDirectional.centerStart,
      );
      expect(
        tester
            .getRect(
              find.descendant(
                of: memberSearch,
                matching: find.text('Search agents'),
              ),
            )
            .center
            .dy,
        closeTo(tester.getRect(memberSearch).center.dy, 0.5),
      );
      expect(
        tester
            .getRect(
              find.descendant(
                of: memberSearch,
                matching: find.byType(EditableText),
              ),
            )
            .center
            .dy,
        closeTo(tester.getRect(memberSearch).center.dy, 0.5),
      );
      expect(find.byType(ShadCard), findsOneWidget);
      expect(find.byType(ShadAvatar), findsOneWidget);
      final memberAvatar = tester.widget<ShadAvatar>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('member-avatar-agent-1')),
          matching: find.byType(ShadAvatar),
        ),
      );
      expect(memberAvatar.src, avatarPath);
      expect(
        find.byKey(const ValueKey<String>('member-activity-agent-1')),
        findsOneWidget,
      );
      expect(find.text('Replying'), findsOneWidget);
      expect(find.text('Processed 1 / latest 3'), findsOneWidget);
      expect(find.text('2 pending'), findsOneWidget);
      expect(find.byIcon(LucideIcons.ellipsis), findsNothing);
      expect(find.byIcon(LucideIcons.gripVertical), findsNothing);

      statuses.value = const <ProjectAgentStatusSnapshot>[
        ProjectAgentStatusSnapshot(
          agentId: 'agent-1',
          activity: ProjectAgentActivity.idle,
          lastProcessedMessageSequence: 3,
          latestMessageSequence: 3,
          backlog: 0,
        ),
      ];
      await tester.pump();

      expect(find.text('Replying'), findsNothing);
      expect(find.text('Caught up'), findsOneWidget);
      expect(find.text('Processed 3 / latest 3'), findsOneWidget);
      expect(find.text('2 pending'), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey<String>('project-member-search')),
        'Writer',
      );
      await tester.pump();

      expect(find.text('Researcher'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('multiple members expose an explicit reorder handle', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 760);
    addTearDown(tester.view.reset);
    final now = DateTime.utc(2026, 8, 22);
    final agents = _AgentRepository(<Agent>[
      _agent('agent-1', 'Researcher', now),
      _agent('agent-2', 'Writer', now),
    ]);
    final memberships = _MembershipRepository(<ProjectMembership>[
      _membership('agent-1', now, position: 0),
      _membership('agent-2', now, position: 1),
    ]);
    final cursors = _CursorRepository(now);
    final viewModel = ProjectMembersViewModel(
      projectId: 'project-1',
      agentRepository: agents,
      membershipRepository: memberships,
      cursorRepository: cursors,
      manageMembers: ManageProjectMembers(
        projectRepository: _ProjectRepository(now),
        agentRepository: agents,
        membershipRepository: memberships,
        cursorRepository: cursors,
        wakeup: (_, _) async {},
        cancelRun: (_) => true,
        clock: () => now,
      ),
    );
    addTearDown(viewModel.dispose);

    await withDesktopPlatform(() async {
      await tester.pumpWidget(
        shadHarness(
          brightness: Brightness.light,
          locale: const Locale('en'),
          homeBuilder:
              (_) => Scaffold(
                body: ProjectMembersSheet(
                  viewModel: viewModel,
                  embedded: true,
                  disposeViewModel: false,
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.ellipsis), findsNothing);
      expect(find.byIcon(LucideIcons.gripVertical), findsNWidgets(2));
      expect(
        find.byKey(const ValueKey<String>('member-reorder-agent-1')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Drag to reorder Researcher',
        ),
        findsOneWidget,
      );
      final memberList = tester.widget<ReorderableListView>(
        find.byKey(const ValueKey<String>('project-member-list')),
      );
      const proxyChild = SizedBox.square(dimension: 24);
      expect(memberList.proxyDecorator, isNotNull);
      expect(
        memberList.proxyDecorator!(proxyChild, 0, kAlwaysCompleteAnimation),
        same(proxyChild),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

Agent _agent(String id, String name, DateTime now, {String avatar = ''}) =>
    Agent(
      id: id,
      name: name,
      avatar: avatar,
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
  String agentId,
  DateTime now, {
  int position = 0,
}) => ProjectMembership(
  projectId: 'project-1',
  agentId: agentId,
  position: position,
  joinedAt: now,
  updatedAt: now,
);

final class _ProjectRepository implements ProjectRepository {
  const _ProjectRepository(this.now);

  final DateTime now;

  @override
  Stream<List<Project>> get changes => const Stream<List<Project>>.empty();

  @override
  Future<Project?> getProject(String id) async => Project(
    id: 'project-1',
    name: 'Project',
    lastMessageSequence: 2,
    lastMessageAt: now,
    createdAt: now,
    updatedAt: now,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _AgentRepository implements AgentRepository {
  const _AgentRepository(this.items);

  final List<Agent> items;

  @override
  Stream<List<Agent>> get changes => const Stream<List<Agent>>.empty();

  @override
  Future<List<Agent>> getAgents({bool forceRefresh = false}) async => items;

  @override
  Future<Agent?> getAgent(String id) async =>
      items.where((agent) => agent.id == id).firstOrNull;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _MembershipRepository implements ProjectMembershipRepository {
  _MembershipRepository(Iterable<ProjectMembership> items)
    : _items = <String, ProjectMembership>{
        for (final item in items) item.agentId: item,
      };

  final Map<String, ProjectMembership> _items;

  ProjectMembership item(String id) => _items[id]!;

  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<List<ProjectMembership>> getForProject(String projectId) async =>
      _items.values.toList(growable: false);

  @override
  Future<List<ProjectMembership>> getForAgent(String agentId) async => _items
      .values
      .where((membership) => membership.agentId == agentId)
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
}

final class _CursorRepository implements ProjectAgentCursorRepository {
  _CursorRepository(this.now);

  final DateTime now;
  String activeRunId = '';

  AgentMessageCursor _cursor(String agentId) => AgentMessageCursor(
    projectId: 'project-1',
    agentId: agentId,
    lastProcessedMessageSequence: 0,
    activeRunId:
        agentId == 'agent-1' && activeRunId.isNotEmpty ? activeRunId : null,
    updatedAt: now,
  );

  @override
  Stream<ProjectAgentInboxKey> get changes =>
      const Stream<ProjectAgentInboxKey>.empty();

  @override
  Future<List<AgentMessageCursor>> getForProject(String projectId) async =>
      <AgentMessageCursor>[_cursor('agent-1')];

  @override
  Future<AgentMessageCursor?> getCursor(
    String projectId,
    String agentId,
  ) async => _cursor(agentId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
