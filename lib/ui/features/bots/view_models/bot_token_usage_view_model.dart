import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/message_repository.dart';

class BotTokenUsageViewModel extends ChangeNotifier {
  BotTokenUsageViewModel({
    required this.botId,
    required MessageRepository messageRepository,
  }) : _messageRepository = messageRepository;

  final String botId;
  final MessageRepository _messageRepository;

  ModelTokenUsage _usage = ModelTokenUsage.empty;
  Object? _error;
  bool _isLoading = false;

  ModelTokenUsage get usage => _usage;
  Object? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _usage = await _messageRepository.getTokenUsageForBot(botId);
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
