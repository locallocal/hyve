import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/conversation_memory_repository.dart';
import 'package:stars/domain/use_cases/compact_conversation.dart';

final class ConversationMemoryViewModel extends ChangeNotifier {
  ConversationMemoryViewModel({
    required this.chatId,
    required this.bot,
    required ConversationMemoryRepository repository,
    required CompactConversation compactConversation,
  }) : _repository = repository,
       _compactConversation = compactConversation {
    _subscription = _repository.changes
        .where((changedChatId) => changedChatId == chatId)
        .listen((_) => unawaited(load()));
  }

  final String chatId;
  final Bot bot;
  final ConversationMemoryRepository _repository;
  final CompactConversation _compactConversation;
  StreamSubscription<String>? _subscription;

  ConversationMemoryState? _state;
  ConversationSummaryDocument? _summary;
  List<ConversationMemoryItem> _items = const [];
  bool _loading = false;
  bool _compacting = false;
  AppFailure? _error;

  ConversationMemoryState? get state => _state;
  ConversationSummaryDocument? get summary => _summary;
  List<ConversationMemoryItem> get items => _items;
  bool get loading => _loading;
  bool get compacting => _compacting;
  AppFailure? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final state = await _repository.getState(chatId);
      final summary = await _repository.getActiveSummary(chatId);
      final items = await _repository.getItems(chatId);
      _state = state;
      _summary = summary;
      _items = items;
    } catch (error) {
      _error = AppFailure.from(error, code: 'conversation_memory_load_failed');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<ConversationCompactionResult> compactNow({
    bool rebuild = false,
  }) async {
    if (_compacting) return ConversationCompactionResult.noCandidates;
    _compacting = true;
    _error = null;
    notifyListeners();
    try {
      if (rebuild) await _repository.clearAutomaticMemory(chatId);
      final result = await _compactConversation(
        bot: bot,
        chatId: chatId,
        manual: true,
      );
      await load();
      return result;
    } catch (error) {
      _error = AppFailure.from(
        error,
        code: 'conversation_memory_update_failed',
      );
      notifyListeners();
      rethrow;
    } finally {
      _compacting = false;
      notifyListeners();
    }
  }

  Future<void> setAutoMemoryEnabled(bool enabled) async {
    await _repository.setAutoMemoryEnabled(chatId, enabled);
    await load();
  }

  Future<void> saveItem(
    ConversationMemoryItem item, {
    String? content,
    ConversationMemoryItemState? state,
  }) async {
    await _repository.saveUserItem(
      item.copyWith(content: content, state: state, updatedAt: DateTime.now()),
    );
    await load();
  }

  Future<void> forgetItem(ConversationMemoryItem item) async {
    await _repository.forgetItem(chatId, item.id);
    await load();
  }

  Future<void> restoreItem(ConversationMemoryItem item) async {
    await _repository.restoreItem(chatId, item.id);
    await load();
  }

  Future<void> clearAutomaticMemory() async {
    await _repository.clearAutomaticMemory(chatId);
    await load();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
