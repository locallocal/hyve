import 'dart:async';

import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/bot_repository.dart';
import 'package:hyve/domain/repositories/chat_repository.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';
import 'package:hyve/ui/core/view_models/disposable_change_notifier.dart';

class ChatListViewModel extends DisposableChangeNotifier {
  ChatListViewModel({
    required ChatRepository chatRepository,
    required BotRepository botRepository,
    ProjectRepository? projectRepository,
    ProjectMembershipRepository? membershipRepository,
    AgentRepository? agentRepository,
  }) : _chatRepository = chatRepository,
       _botRepository = botRepository,
       _projectRepository = projectRepository,
       _membershipRepository = membershipRepository,
       _agentRepository = agentRepository {
    _chatSubscription = _chatRepository.changes.listen((_) => load());
    _botSubscription = _botRepository.changes.listen((_) => load());
    _projectSubscription = _projectRepository?.changes.listen((_) => load());
    _membershipSubscription = _membershipRepository?.changes.listen(
      (_) => load(),
    );
    _agentSubscription = _agentRepository?.changes.listen((_) => load());
  }

  final ChatRepository _chatRepository;
  final BotRepository _botRepository;
  final ProjectRepository? _projectRepository;
  final ProjectMembershipRepository? _membershipRepository;
  final AgentRepository? _agentRepository;
  late final StreamSubscription<List<Chat>> _chatSubscription;
  late final StreamSubscription<List<Bot>> _botSubscription;
  late final StreamSubscription<List<Project>>? _projectSubscription;
  late final StreamSubscription<String>? _membershipSubscription;
  late final StreamSubscription<List<Agent>>? _agentSubscription;

  List<Chat> _chats = const [];
  List<Bot> _bots = const [];
  List<ProjectWorkspace> _projects = const [];
  List<Chat> _filteredChats = const [];
  List<ProjectWorkspace> _filteredProjects = const [];
  String _query = '';
  AppFailure? _error;
  bool _isLoading = false;
  bool _hasLoaded = false;
  int _loadGeneration = 0;

  List<Chat> get chats => _chats;
  List<Bot> get bots => _bots;
  List<ProjectWorkspace> get projects => _projects;
  List<Chat> get filteredChats => _filteredChats;
  List<ProjectWorkspace> get filteredProjects => _filteredProjects;
  String get query => _query;
  AppFailure? get error => _error;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;

  Future<void> load() async {
    if (isDisposed) return;
    final generation = ++_loadGeneration;
    final isInitialLoad = !_hasLoaded;
    _isLoading = true;
    _error = null;
    if (isInitialLoad) notifyListeners();
    try {
      final modern =
          _projectRepository != null &&
          _membershipRepository != null &&
          _agentRepository != null;
      final results =
          modern
              ? await _loadProjectWorkspaces()
              : await _loadLegacyWorkspaces();
      if (isDisposed || generation != _loadGeneration) return;
      _chats = results.chats;
      _bots = results.bots;
      _projects = results.workspaces;
      _applyFilter();
      _hasLoaded = true;
    } catch (error) {
      if (isDisposed || generation != _loadGeneration) return;
      _error = AppFailure.from(error, code: 'chat_list_load_failed');
    } finally {
      if (!isDisposed && generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void search(String query) {
    _query = query;
    _applyFilter();
    notifyListeners();
  }

  Future<void> deleteChat(String id) =>
      _projectRepository?.deleteProject(id) ?? _chatRepository.deleteChat(id);

  Future<_ProjectListState> _loadLegacyWorkspaces() async {
    final results = await Future.wait<Object>([
      _chatRepository.getChats(),
      _botRepository.getBots(),
    ]);
    final chats = List<Chat>.unmodifiable(results[0] as List<Chat>);
    final bots = List<Bot>.unmodifiable(results[1] as List<Bot>);
    return _ProjectListState(
      chats: chats,
      bots: bots,
      workspaces: List<ProjectWorkspace>.unmodifiable(
        chats.map((chat) => ProjectWorkspace(chat: chat, bots: bots)),
      ),
    );
  }

  Future<_ProjectListState> _loadProjectWorkspaces() async {
    final domainProjects = await _projectRepository!.getProjects();
    final agents = await _agentRepository!.getAgents();
    final memberships = await Future.wait([
      for (final project in domainProjects)
        _membershipRepository!.getForProject(project.id),
    ]);
    final agentById = <String, Agent>{
      for (final agent in agents) agent.id: agent,
    };
    final botById = <String, Bot>{
      for (final agent in agents) agent.id: _presentationBot(agent),
    };
    final chats = <Chat>[];
    final workspaces = <ProjectWorkspace>[];
    for (final entry in domainProjects.indexed) {
      final project = entry.$2;
      final memberIds = memberships[entry.$1]
          .where(
            (membership) =>
                membership.status == ProjectMembershipStatus.active &&
                agentById.containsKey(membership.agentId),
          )
          .map((membership) => membership.agentId)
          .toList(growable: false);
      final chat = Chat(
        id: project.id,
        name: project.name,
        botIds: memberIds,
        lastMessage: project.lastMessage,
        lastMessageTimestamp: project.lastMessageAt,
        createTimestamp: project.createdAt,
        modifyTimestamp: project.updatedAt,
      );
      chats.add(chat);
      workspaces.add(
        ProjectWorkspace(
          chat: chat,
          bots: [for (final id in memberIds) botById[id]!],
          usesProjectAgentRuntime: true,
        ),
      );
    }
    return _ProjectListState(
      chats: List<Chat>.unmodifiable(chats),
      bots: List<Bot>.unmodifiable(botById.values),
      workspaces: List<ProjectWorkspace>.unmodifiable(workspaces),
    );
  }

  void _applyFilter() {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) {
      _filteredChats = _chats;
      _filteredProjects = _projects;
      return;
    }
    final botNames = <String, String>{
      for (final bot in _bots) bot.id: bot.name.toLowerCase(),
    };
    _filteredChats = List<Chat>.unmodifiable(
      _chats.where(
        (chat) =>
            chat.name.toLowerCase().contains(normalized) ||
            chat.lastMessage.toLowerCase().contains(normalized) ||
            chat.projectBotIds.any(
              (botId) => botNames[botId]?.contains(normalized) ?? false,
            ),
      ),
    );
    final matchingChatIds = _filteredChats.map((chat) => chat.id).toSet();
    _filteredProjects = List<ProjectWorkspace>.unmodifiable(
      _projects.where((project) => matchingChatIds.contains(project.id)),
    );
  }

  @override
  void disposeResources() {
    unawaited(_chatSubscription.cancel());
    unawaited(_botSubscription.cancel());
    unawaited(_projectSubscription?.cancel());
    unawaited(_membershipSubscription?.cancel());
    unawaited(_agentSubscription?.cancel());
  }
}

final class _ProjectListState {
  const _ProjectListState({
    required this.chats,
    required this.bots,
    required this.workspaces,
  });

  final List<Chat> chats;
  final List<Bot> bots;
  final List<ProjectWorkspace> workspaces;
}

Bot _presentationBot(Agent agent) => Bot(
  id: agent.id,
  name: agent.name,
  avatar: agent.avatar,
  provider: agent.provider,
  baseURL: agent.baseUrl,
  apiKey: agent.apiKey,
  apiType: agent.apiType,
  model: agent.model,
  systemPrompt: agent.systemPrompt,
  parameters: Map<String, dynamic>.from(agent.parameters),
  createTimestamp: agent.createdAt,
  modifyTimestamp: agent.updatedAt,
);
