import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/chat_repository.dart';

typedef Clock = DateTime Function();

class CreateChat {
  CreateChat({required ChatRepository chatRepository, Clock? clock})
    : _chatRepository = chatRepository,
      _clock = clock ?? DateTime.now;

  final ChatRepository _chatRepository;
  final Clock _clock;
  int _sequence = 0;

  Future<Chat> call({String name = '', required Iterable<Bot> bots}) async {
    final now = _clock();
    _sequence = (_sequence + 1) & 0x7fffffff;
    final projectName = name.trim();
    if (projectName.length > 80) {
      throw ArgumentError.value(name, 'name', 'Must be at most 80 characters.');
    }
    final botIds = <String>{...bots.map((item) => item.id)}
      ..removeWhere((id) => id.trim().isEmpty);
    if (botIds.isEmpty) {
      throw ArgumentError.value(
        bots,
        'bots',
        'A project must contain at least one agent.',
      );
    }
    final chat = Chat(
      id: 'chat_${now.microsecondsSinceEpoch}_$_sequence',
      name: projectName,
      botIds: List<String>.unmodifiable(botIds),
      lastMessage: '',
      lastMessageTimestamp: now,
      createTimestamp: now,
      modifyTimestamp: now,
    );
    await _chatRepository.addChat(chat);
    return chat;
  }
}
