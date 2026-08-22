import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/bot_repository.dart';
import 'package:hyve/domain/repositories/chat_repository.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';
import 'package:hyve/ui/features/chats/view_models/chat_list_view_model.dart';

void main() {
  test(
    'ChatListViewModel loads immutable state and filters by bot or preview',
    () async {
      final chatRepository = _FakeChatRepository([
        _chat(
          'chat-1',
          'bot-1',
          'Architecture notes',
          botIds: const ['bot-1', 'bot-3'],
        ),
        _chat('chat-2', 'bot-2', 'Weekend plan'),
      ]);
      final botRepository = _FakeBotRepository([
        _bot('bot-1', 'Planner'),
        _bot('bot-2', 'Coder'),
        _bot('bot-3', 'Reviewer'),
      ]);
      final viewModel = ChatListViewModel(
        chatRepository: chatRepository,
        botRepository: botRepository,
      );
      addTearDown(viewModel.dispose);

      await viewModel.load();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.chats, hasLength(2));
      final chatsSnapshot = viewModel.chats;
      expect(
        () => viewModel.chats.add(_chat('x', 'x', 'x')),
        throwsUnsupportedError,
      );
      expect(() => viewModel.bots.clear(), throwsUnsupportedError);
      expect(() => viewModel.filteredChats.clear(), throwsUnsupportedError);
      expect(viewModel.projects.first.bots, hasLength(2));
      expect(() => viewModel.projects.clear(), throwsUnsupportedError);

      viewModel.search('coder');
      expect(viewModel.filteredChats.map((chat) => chat.id), ['chat-2']);

      viewModel.search('architecture');
      expect(viewModel.filteredChats.map((chat) => chat.id), ['chat-1']);

      viewModel.search('launch');
      expect(viewModel.filteredChats.map((chat) => chat.id), ['chat-2']);

      viewModel.search('reviewer');
      expect(viewModel.filteredProjects.map((project) => project.id), [
        'chat-1',
      ]);

      chatRepository.items.add(_chat('chat-3', 'bot-1', 'New snapshot'));
      await viewModel.load();

      expect(viewModel.chats, hasLength(3));
      expect(chatsSnapshot, hasLength(2));
    },
  );

  test(
    'ChatListViewModel exposes repository failures as presentation state',
    () async {
      final viewModel = ChatListViewModel(
        chatRepository: _FakeChatRepository(const [], error: StateError('db')),
        botRepository: _FakeBotRepository(const []),
      );
      addTearDown(viewModel.dispose);

      await viewModel.load();

      expect(viewModel.isLoading, isFalse);
      expect(
        viewModel.error,
        isA<AppFailure>().having(
          (failure) => failure.code,
          'code',
          'chat_list_load_failed',
        ),
      );
    },
  );

  test(
    'production path lists persisted Projects including zero members',
    () async {
      final projectRepository = _FakeProjectRepository([
        _project('project-1', 'With agent'),
        _project('project-2', 'Empty project'),
      ]);
      final viewModel = ChatListViewModel(
        chatRepository: _FakeChatRepository(const []),
        botRepository: _FakeBotRepository(const []),
        projectRepository: projectRepository,
        membershipRepository: _FakeMembershipRepository({
          'project-1': <ProjectMembership>[
            ProjectMembership(
              projectId: 'project-1',
              agentId: 'agent-1',
              position: 0,
              joinedAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
            ProjectMembership(
              projectId: 'project-1',
              agentId: 'agent-2',
              status: ProjectMembershipStatus.paused,
              position: 1,
              joinedAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          ],
        }),
        agentRepository: _FakeAgentRepository([
          _agent('agent-1', 'Planner'),
          _agent('agent-2', 'Paused reviewer'),
        ]),
      );
      addTearDown(viewModel.dispose);

      await viewModel.load();

      expect(viewModel.projects, hasLength(2));
      expect(viewModel.projects.first.usesProjectAgentRuntime, isTrue);
      expect(viewModel.projects.first.firstBot?.id, 'agent-1');
      expect(viewModel.projects.first.bots, hasLength(1));
      expect(viewModel.projects.last.firstBot, isNull);
      await viewModel.deleteChat('project-2');
      expect(projectRepository.deletedId, 'project-2');
    },
  );
}

Project _project(String id, String name) => Project(
  id: id,
  name: name,
  lastMessageAt: DateTime(2026),
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Agent _agent(String id, String name) => Agent(
  id: id,
  name: name,
  avatar: '',
  provider: 'Test',
  baseUrl: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: '',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Bot _bot(String id, String name) => Bot(
  id: id,
  name: name,
  avatar: '',
  provider: 'Test',
  baseURL: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: '',
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);

Chat _chat(
  String id,
  String botId,
  String preview, {
  List<String> botIds = const <String>[],
}) => Chat(
  id: id,
  botIds: botIds.isEmpty ? [botId] : botIds,
  name: id == 'chat-2' ? 'Launch project' : '',
  lastMessage: preview,
  lastMessageTimestamp: DateTime(2026),
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository(this.items, {this.error});

  final List<Chat> items;
  final Object? error;
  final StreamController<List<Chat>> controller =
      StreamController<List<Chat>>.broadcast();

  @override
  Stream<List<Chat>> get changes => controller.stream;

  @override
  Future<List<Chat>> getChats({bool forceRefresh = false}) async {
    if (error case final error?) throw error;
    return items;
  }

  @override
  Future<void> addChat(Chat chat) async {}

  @override
  Future<void> clearHistory(String id) async {}

  @override
  Future<void> deleteChat(String id) async {}

  @override
  Future<void> deleteChatsForBot(String botId) async {}

  @override
  Future<Chat?> getChat(String id) async => null;

  @override
  void invalidate() {}

  @override
  Future<void> updateLastMessage(String id, String content) async {}
}

class _FakeBotRepository implements BotRepository {
  _FakeBotRepository(this.items);

  final List<Bot> items;
  final StreamController<List<Bot>> controller =
      StreamController<List<Bot>>.broadcast();

  @override
  Stream<List<Bot>> get changes => controller.stream;

  @override
  Future<List<Bot>> getBots({bool forceRefresh = false}) async => items;

  @override
  Future<void> addBot(Bot bot) async {}

  @override
  Future<void> deleteBot(String id) async {}

  @override
  Future<Bot?> getBot(String id) async => null;

  @override
  Future<void> updateBot(Bot bot) async {}
}

class _FakeProjectRepository implements ProjectRepository {
  _FakeProjectRepository(this.items);

  final List<Project> items;
  String? deletedId;

  @override
  Stream<List<Project>> get changes => const Stream<List<Project>>.empty();

  @override
  Future<List<Project>> getProjects({bool forceRefresh = false}) async => items;

  @override
  Future<void> deleteProject(String id) async => deletedId = id;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMembershipRepository implements ProjectMembershipRepository {
  const _FakeMembershipRepository(this.byProject);

  final Map<String, List<ProjectMembership>> byProject;

  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<List<ProjectMembership>> getForProject(String projectId) async =>
      byProject[projectId] ?? const <ProjectMembership>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAgentRepository implements AgentRepository {
  const _FakeAgentRepository(this.items);

  final List<Agent> items;

  @override
  Stream<List<Agent>> get changes => const Stream<List<Agent>>.empty();

  @override
  Future<List<Agent>> getAgents({bool forceRefresh = false}) async => items;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
