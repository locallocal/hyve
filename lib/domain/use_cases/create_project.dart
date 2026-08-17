import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/use_cases/create_chat.dart';

/// Creates a named project whose conversation can be handled by any of its
/// distinct agents.
final class CreateProject {
  const CreateProject({required CreateChat createChat})
    : _createChat = createChat;

  final CreateChat _createChat;

  Future<Project> call({
    required String name,
    required Iterable<Bot> bots,
  }) async {
    final projectName = name.trim();
    if (projectName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Project name cannot be empty.');
    }
    final uniqueBots = <String, Bot>{};
    for (final bot in bots) {
      final id = bot.id.trim();
      if (id.isNotEmpty) uniqueBots.putIfAbsent(id, () => bot);
    }
    if (uniqueBots.isEmpty) {
      throw ArgumentError.value(
        bots,
        'bots',
        'A project must contain at least one agent.',
      );
    }

    final members = List<Bot>.unmodifiable(uniqueBots.values);
    final chat = await _createChat(name: projectName, bots: members);
    return Project(chat: chat, bots: members);
  }
}
