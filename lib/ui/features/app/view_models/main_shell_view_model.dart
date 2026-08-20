import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/bot_repository.dart';
import 'package:hyve/ui/core/view_models/disposable_change_notifier.dart';

class MainShellViewModel extends DisposableChangeNotifier {
  MainShellViewModel({required BotRepository botRepository})
    : _botRepository = botRepository;

  final BotRepository _botRepository;

  int _currentIndex = 0;
  ProjectWorkspace? _selectedProject;
  Bot? _selectedChatBot;
  Bot? _selectedBot;
  bool _isEditingSelectedBot = false;
  int _selectedProfileSection = 0;

  int get currentIndex => _currentIndex;
  ProjectWorkspace? get selectedProject => _selectedProject;
  String? get selectedChatId => _selectedProject?.id;
  Bot? get selectedChatBot => _selectedChatBot;
  List<Bot> get selectedChatBots => _selectedProject?.bots ?? const <Bot>[];
  bool get selectedProjectUsesAgentRuntime =>
      _selectedProject?.usesProjectAgentRuntime ?? false;
  Bot? get selectedBot => _selectedBot;
  bool get isEditingSelectedBot => _isEditingSelectedBot;
  int get selectedProfileSection => _selectedProfileSection;
  bool get isChatSelectionVisible => _currentIndex == 0;

  void selectProject(ProjectWorkspace project) {
    final activeBot = project.firstBot;
    _selectedProject = project;
    _selectedChatBot = activeBot;
    _currentIndex = 0;
    notifyListeners();
  }

  void selectBot(Bot bot) {
    _selectedBot = bot;
    _isEditingSelectedBot = false;
    _currentIndex = 1;
    notifyListeners();
  }

  void editBot(Bot bot) {
    _selectedBot = bot;
    _isEditingSelectedBot = true;
    _currentIndex = 1;
    notifyListeners();
  }

  void clearSelectedChat() {
    _selectedProject = null;
    _selectedChatBot = null;
    notifyListeners();
  }

  void clearSelectedBot() {
    _selectedBot = null;
    _isEditingSelectedBot = false;
    notifyListeners();
  }

  void selectPage(int index) {
    _currentIndex = index;
    if (index == 1) {
      _selectedBot = null;
      _isEditingSelectedBot = false;
    }
    notifyListeners();
  }

  void selectProfileSection(int section) {
    _selectedProfileSection = section;
    _currentIndex = 4;
    notifyListeners();
  }

  void applyBotUpdate(Bot bot) {
    if (_selectedBot?.id == bot.id) _selectedBot = bot;
    final project = _selectedProject;
    if (project?.botById(bot.id) != null) {
      _selectedProject = project!.replaceBot(bot);
      if (_selectedChatBot?.id == bot.id) _selectedChatBot = bot;
    }
    notifyListeners();
  }

  Future<void> updateBot(Bot bot) async {
    if (isDisposed) return;
    await _botRepository.updateBot(bot);
    if (isDisposed) return;
    applyBotUpdate(bot);
  }

  Future<void> deleteSelectedBot() async {
    if (isDisposed) return;
    final botId = _selectedBot?.id;
    if (botId == null) return;
    await _botRepository.deleteBot(botId);
    if (isDisposed) return;
    final project = _selectedProject;
    if (project?.botById(botId) != null) {
      final updatedProject = project!.removeBot(botId);
      _selectedProject = updatedProject;
      _selectedChatBot = updatedProject.firstBot;
    }
    _selectedBot = null;
    _isEditingSelectedBot = false;
    notifyListeners();
  }
}
