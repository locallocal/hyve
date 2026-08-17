import 'package:hyve/domain/models/bot.dart';
import 'package:hyve/domain/models/chat.dart';

/// A project together with the agents that participate in its conversation.
final class Project {
  Project({required this.chat, required Iterable<Bot> bots})
    : bots = _orderedUniqueBots(chat, bots);

  final Chat chat;
  final List<Bot> bots;

  String get id => chat.id;
  String get name => chat.name;
  List<String> get botIds => chat.projectBotIds;

  Bot get firstBot => bots.first;

  Bot? botById(String id) {
    for (final bot in bots) {
      if (bot.id == id) return bot;
    }
    return null;
  }

  Project replaceBot(Bot updated) => Project(
    chat: chat,
    bots: [
      for (final bot in bots)
        if (bot.id == updated.id) updated else bot,
    ],
  );

  Project? removeBot(String id) {
    final remaining = bots.where((bot) => bot.id != id).toList();
    if (remaining.isEmpty) return null;
    return Project(
      chat: chat.copyWith(botIds: remaining.map((bot) => bot.id).toList()),
      bots: remaining,
    );
  }
}

List<Bot> _orderedUniqueBots(Chat chat, Iterable<Bot> bots) {
  final available = <String, Bot>{};
  for (final bot in bots) {
    final id = bot.id.trim();
    if (id.isNotEmpty) available.putIfAbsent(id, () => bot);
  }
  final ordered = <Bot>[
    for (final id in chat.projectBotIds)
      if (available[id] case final bot?) bot,
  ];
  if (ordered.length != chat.projectBotIds.length) {
    throw StateError('Every project member must resolve to an agent.');
  }
  return List<Bot>.unmodifiable(ordered);
}
