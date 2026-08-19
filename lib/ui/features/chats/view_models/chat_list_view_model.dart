import 'dart:async';

import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/bot_repository.dart';
import 'package:hyve/domain/repositories/chat_repository.dart';
import 'package:hyve/ui/core/view_models/disposable_change_notifier.dart';

class ChatListViewModel extends DisposableChangeNotifier {
  ChatListViewModel({
    required ChatRepository chatRepository,
    required BotRepository botRepository,
  }) : _chatRepository = chatRepository,
       _botRepository = botRepository {
    _chatSubscription = _chatRepository.changes.listen((_) => load());
    _botSubscription = _botRepository.changes.listen((_) => load());
  }

  final ChatRepository _chatRepository;
  final BotRepository _botRepository;
  late final StreamSubscription<List<Chat>> _chatSubscription;
  late final StreamSubscription<List<Bot>> _botSubscription;

  List<Chat> _chats = const [];
  List<Bot> _bots = const [];
  List<ProjectWorkspace> _projects = const [];
  List<Chat> _filteredChats = const [];
  List<ProjectWorkspace> _filteredProjects = const [];
  String _query = '';
  AppFailure? _error;
  bool _isLoading = false;
  int _loadGeneration = 0;

  List<Chat> get chats => _chats;
  List<Bot> get bots => _bots;
  List<ProjectWorkspace> get projects => _projects;
  List<Chat> get filteredChats => _filteredChats;
  List<ProjectWorkspace> get filteredProjects => _filteredProjects;
  String get query => _query;
  AppFailure? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    if (isDisposed) return;
    final generation = ++_loadGeneration;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait<Object>([
        _chatRepository.getChats(),
        _botRepository.getBots(),
      ]);
      if (isDisposed || generation != _loadGeneration) return;
      _chats = List<Chat>.unmodifiable(results[0] as List<Chat>);
      _bots = List<Bot>.unmodifiable(results[1] as List<Bot>);
      _projects = List<ProjectWorkspace>.unmodifiable(
        _chats.map((chat) => ProjectWorkspace(chat: chat, bots: _bots)),
      );
      _applyFilter();
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

  Future<void> deleteChat(String id) => _chatRepository.deleteChat(id);

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
  }
}
