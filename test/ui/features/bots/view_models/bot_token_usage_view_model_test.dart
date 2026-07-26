import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/chat_repository.dart';
import 'package:stars/domain/repositories/message_repository.dart';
import 'package:stars/ui/features/bots/view_models/bot_token_usage_view_model.dart';

void main() {
  test('loads and sorts per-conversation usage with chat previews', () async {
    final messages = _FakeMessageRepository({
      'chat-small': const ModelTokenUsage(inputTokens: 20, outputTokens: 5),
      'chat-large': const ModelTokenUsage(inputTokens: 60, outputTokens: 15),
    });
    final chats = _FakeChatRepository([
      _chat('chat-small', 'Short conversation'),
      _chat('chat-large', 'Large conversation'),
    ]);
    final viewModel = BotTokenUsageViewModel(
      botId: 'bot-1',
      messageRepository: messages,
      chatRepository: chats,
    );
    addTearDown(viewModel.dispose);

    await viewModel.load();

    expect(viewModel.usage.effectiveTotalTokens, 100);
    expect(viewModel.conversationUsages.map((entry) => entry.chatId), [
      'chat-large',
      'chat-small',
    ]);
    expect(viewModel.conversationUsages.first.preview, 'Large conversation');
    expect(viewModel.conversationUsages.first.usage.effectiveTotalTokens, 75);
  });
}

Chat _chat(String id, String lastMessage) => Chat(
  id: id,
  botId: 'bot-1',
  lastMessage: lastMessage,
  lastMessageTimestamp: DateTime(2026, 7, 26),
  createTimestamp: DateTime(2026, 7, 26),
  modifyTimestamp: DateTime(2026, 7, 26),
);

class _FakeMessageRepository implements MessageRepository {
  _FakeMessageRepository(this.usageByChat);

  final Map<String, ModelTokenUsage> usageByChat;

  @override
  Stream<void> get changes => const Stream<void>.empty();

  @override
  Future<Map<String, ModelTokenUsage>> getTokenUsageByChatForBot(
    String botId,
  ) async => usageByChat;

  @override
  Future<ModelTokenUsage> getTokenUsageForBot(String botId) async {
    return ModelTokenUsage.sum(usageByChat.values);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository(this.chats);

  final List<Chat> chats;

  @override
  Stream<List<Chat>> get changes => const Stream<List<Chat>>.empty();

  @override
  Future<List<Chat>> getChats({bool forceRefresh = false}) async => chats;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
