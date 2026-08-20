import 'package:hyve/domain/models/bot.dart';
import 'package:hyve/domain/models/chat.dart';

/// Read-only presentation summary for the project list and app shell.
///
/// Project execution uses Project, Agent and ProjectMembership directly.
final class ProjectWorkspace {
  ProjectWorkspace({
    required this.chat,
    required Iterable<Bot> bots,
    this.usesProjectAgentRuntime = false,
  }) : bots = _orderedUniqueBots(chat, bots);

  final Chat chat;
  final List<Bot> bots;
  final bool usesProjectAgentRuntime;

  String get id => chat.id;
  String get name => chat.name;
  List<String> get botIds => chat.projectBotIds;

  Bot? get firstBot => bots.isEmpty ? null : bots.first;

  Bot? botById(String id) {
    for (final bot in bots) {
      if (bot.id == id) return bot;
    }
    return null;
  }

  ProjectWorkspace replaceBot(Bot updated) => ProjectWorkspace(
    chat: chat,
    usesProjectAgentRuntime: usesProjectAgentRuntime,
    bots: [
      for (final bot in bots)
        if (bot.id == updated.id) updated else bot,
    ],
  );

  ProjectWorkspace removeBot(String id) {
    final remaining = bots.where((bot) => bot.id != id).toList();
    return ProjectWorkspace(
      chat: chat.copyWith(botIds: remaining.map((bot) => bot.id).toList()),
      bots: remaining,
      usesProjectAgentRuntime: usesProjectAgentRuntime,
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
