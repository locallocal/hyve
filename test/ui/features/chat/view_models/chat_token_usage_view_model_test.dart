import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/chat_repository.dart';
import 'package:stars/domain/repositories/message_repository.dart';
import 'package:stars/ui/features/chat/view_models/chat_token_usage_view_model.dart';

void main() {
  test('groups usage by consecutive days and drills into 24 hours', () async {
    final messages = _FakeMessageRepository([
      _message('first', DateTime(2026, 7, 24, 10), input: 100, output: 20),
      _message('second', DateTime(2026, 7, 24, 12), input: 40, output: 10),
      _message('third', DateTime(2026, 7, 26, 3), input: 60, output: 15),
    ]);
    final chats = _FakeChatRepository();
    final viewModel = ChatTokenUsageViewModel(
      chatId: 'chat-1',
      messageRepository: messages,
      chatRepository: chats,
      now: () => DateTime(2026, 7, 26, 12),
    );
    addTearDown(viewModel.dispose);

    await viewModel.load();

    expect(viewModel.dailyBuckets, hasLength(3));
    expect(viewModel.dailyBuckets[0].start, DateTime(2026, 7, 24));
    expect(viewModel.dailyBuckets[0].usage.effectiveTotalTokens, 170);
    expect(viewModel.dailyBuckets[1].start, DateTime(2026, 7, 25));
    expect(viewModel.dailyBuckets[1].usage.effectiveTotalTokens, 0);
    expect(viewModel.dailyBuckets[2].usage.effectiveTotalTokens, 75);
    expect(viewModel.totalUsage.effectiveTotalTokens, 245);

    viewModel.selectDay(DateTime(2026, 7, 24, 18));

    expect(viewModel.granularity, TokenUsageGranularity.hour);
    expect(viewModel.visibleBuckets, hasLength(24));
    expect(viewModel.visibleBuckets[10].usage.effectiveTotalTokens, 120);
    expect(viewModel.visibleBuckets[12].usage.effectiveTotalTokens, 50);
    expect(viewModel.visibleBuckets[11].usage.effectiveTotalTokens, 0);
    expect(viewModel.visibleTotalUsage.effectiveTotalTokens, 170);

    viewModel.showDaily();
    expect(viewModel.granularity, TokenUsageGranularity.day);
    expect(viewModel.visibleTotalUsage.effectiveTotalTokens, 245);
  });

  test('reloads after a message repository change', () async {
    final messages = _FakeMessageRepository([
      _message('first', DateTime(2026, 7, 24, 10), input: 10, output: 5),
    ]);
    final viewModel = ChatTokenUsageViewModel(
      chatId: 'chat-1',
      messageRepository: messages,
      chatRepository: _FakeChatRepository(),
    );
    addTearDown(viewModel.dispose);
    await viewModel.load();

    messages.messages = [
      ...messages.messages,
      _message('second', DateTime(2026, 7, 24, 11), input: 20, output: 10),
    ];
    messages.notifyChanged();
    await _waitFor(() => viewModel.totalUsage.effectiveTotalTokens == 45);

    expect(viewModel.dailyBuckets.single.usage.inputTokens, 30);
    expect(viewModel.dailyBuckets.single.usage.outputTokens, 15);
  });

  test('today only includes hours through the current hour', () async {
    final viewModel = ChatTokenUsageViewModel(
      chatId: 'chat-1',
      messageRepository: _FakeMessageRepository([
        _message('current', DateTime(2026, 7, 26, 10), input: 20, output: 5),
      ]),
      chatRepository: _FakeChatRepository(),
      now: () => DateTime(2026, 7, 26, 14, 30),
    );
    addTearDown(viewModel.dispose);
    await viewModel.load();

    viewModel.selectDay(DateTime(2026, 7, 26));

    expect(viewModel.visibleBuckets, hasLength(15));
    expect(viewModel.visibleBuckets.first.start.hour, 0);
    expect(viewModel.visibleBuckets.last.start.hour, 14);
    expect(viewModel.visibleBuckets[10].usage.effectiveTotalTokens, 25);
  });
}

Message _message(
  String id,
  DateTime timestamp, {
  required int input,
  required int output,
}) {
  return Message(
    messageId: id,
    turnId: 'turn-$id',
    chatId: 'chat-1',
    botId: 'bot-1',
    senderId: 'bot-1',
    content: id,
    tokenUsage: ModelTokenUsage(
      model: 'test-model',
      inputTokens: input,
      outputTokens: output,
      totalTokens: input + output,
    ),
    timestamp: timestamp,
  );
}

class _FakeMessageRepository implements MessageRepository {
  _FakeMessageRepository(this.messages);

  final StreamController<void> _changes = StreamController<void>.broadcast();
  List<Message> messages;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<Message>> getMessages(String chatId) async => messages;

  @override
  Future<List<ModelTokenUsageRecord>> getTokenUsageRecordsForChat(
    String chatId,
  ) async {
    return [
      for (final message in messages)
        ModelTokenUsageRecord(
          messageId: message.messageId,
          chatId: message.chatId,
          botId: message.botId,
          timestamp: message.timestamp,
          usage: message.tokenUsage,
        ),
    ];
  }

  void notifyChanged() => _changes.add(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeChatRepository implements ChatRepository {
  @override
  Stream<List<Chat>> get changes => const Stream<List<Chat>>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _waitFor(bool Function() predicate) async {
  for (var attempt = 0; attempt < 100; attempt += 1) {
    if (predicate()) return;
    await Future<void>.delayed(Duration.zero);
  }
  fail('Timed out waiting for token usage to refresh.');
}
