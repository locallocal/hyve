import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/bot_repository.dart';
import 'package:hyve/domain/use_cases/create_project.dart';
import 'package:hyve/ui/core/view_models/disposable_change_notifier.dart';

enum NewProjectValidationError { nameRequired, botRequired }

final class NewProjectViewModel extends DisposableChangeNotifier {
  NewProjectViewModel({
    required BotRepository botRepository,
    required CreateProject createProject,
  }) : _botRepository = botRepository,
       _createProject = createProject;

  final BotRepository _botRepository;
  final CreateProject _createProject;

  List<Bot> _bots = const <Bot>[];
  List<String> _selectedBotIds = const <String>[];
  String _name = '';
  bool _isLoading = false;
  bool _isSaving = false;
  AppFailure? _error;
  Set<NewProjectValidationError> _validationErrors = const {};

  List<Bot> get bots => _bots;
  List<String> get selectedBotIds => _selectedBotIds;
  String get name => _name;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  AppFailure? get error => _error;
  Set<NewProjectValidationError> get validationErrors => _validationErrors;
  bool get canSubmit =>
      _name.trim().isNotEmpty && _selectedBotIds.isNotEmpty && !_isSaving;

  Future<void> load() async {
    if (isDisposed || _isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bots = List<Bot>.unmodifiable(await _botRepository.getBots());
      final availableIds = _bots.map((bot) => bot.id).toSet();
      _selectedBotIds = List<String>.unmodifiable(
        _selectedBotIds.where(availableIds.contains),
      );
    } on Object catch (error) {
      _error = AppFailure.from(error, code: 'project_bots_load_failed');
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void setName(String value) {
    if (isDisposed || _name == value) return;
    _name = value;
    if (value.trim().isNotEmpty &&
        _validationErrors.contains(NewProjectValidationError.nameRequired)) {
      _validationErrors = Set<NewProjectValidationError>.unmodifiable(
        _validationErrors.difference(const {
          NewProjectValidationError.nameRequired,
        }),
      );
    }
    notifyListeners();
  }

  void toggleBot(String botId) {
    if (isDisposed || _isSaving || !_bots.any((bot) => bot.id == botId)) {
      return;
    }
    final selected = _selectedBotIds.toList();
    if (selected.contains(botId)) {
      selected.remove(botId);
    } else {
      selected.add(botId);
    }
    _selectedBotIds = List<String>.unmodifiable(selected);
    if (selected.isNotEmpty &&
        _validationErrors.contains(NewProjectValidationError.botRequired)) {
      _validationErrors = Set<NewProjectValidationError>.unmodifiable(
        _validationErrors.difference(const {
          NewProjectValidationError.botRequired,
        }),
      );
    }
    notifyListeners();
  }

  void clearError() {
    if (isDisposed || _error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<ProjectWorkspace?> submit() async {
    if (isDisposed || _isSaving) return null;
    final errors = <NewProjectValidationError>{};
    if (_name.trim().isEmpty) {
      errors.add(NewProjectValidationError.nameRequired);
    }
    if (_selectedBotIds.isEmpty) {
      errors.add(NewProjectValidationError.botRequired);
    }
    _validationErrors = Set<NewProjectValidationError>.unmodifiable(errors);
    if (errors.isNotEmpty) {
      notifyListeners();
      return null;
    }

    final selectedById = <String, Bot>{for (final bot in _bots) bot.id: bot};
    final selectedBots = <Bot>[
      for (final id in _selectedBotIds)
        if (selectedById[id] case final bot?) bot,
    ];
    if (selectedBots.isEmpty) {
      _validationErrors = const {NewProjectValidationError.botRequired};
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      final project = await _createProject(
        name: _name,
        agentIds: selectedBots.map((bot) => bot.id),
      );
      return ProjectWorkspace(
        chat: Chat(
          id: project.id,
          name: project.name,
          botIds: selectedBots.map((bot) => bot.id),
          lastMessage: project.lastMessage,
          lastMessageTimestamp: project.lastMessageAt,
          createTimestamp: project.createdAt,
          modifyTimestamp: project.updatedAt,
        ),
        bots: selectedBots,
      );
    } on Object catch (error) {
      _error = AppFailure.from(error, code: 'project_create_failed');
      return null;
    } finally {
      if (!isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }
}
