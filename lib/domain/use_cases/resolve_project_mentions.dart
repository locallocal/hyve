import 'package:hyve/domain/models/models.dart';

final class ProjectMentionResolution {
  ProjectMentionResolution({required Iterable<Bot> bots})
    : bots = List<Bot>.unmodifiable(bots);

  final List<Bot> bots;

  bool get hasTargets => bots.isNotEmpty;
}

/// Resolves explicit `@agent name` references against one project's members.
final class ResolveProjectMentions {
  const ResolveProjectMentions();

  ProjectMentionResolution call({
    required String text,
    required Iterable<Bot> projectBots,
  }) {
    final candidates = <Bot>[
      for (final bot in projectBots)
        if (bot.name.trim().isNotEmpty) bot,
    ]..sort(
      (left, right) =>
          right.name.trim().length.compareTo(left.name.trim().length),
    );
    final matches = <({int start, int nameLength, Bot bot})>[];
    for (final bot in candidates) {
      final name = bot.name.trim();
      final expression = RegExp(
        '(^|\\s)@${RegExp.escape(name)}(?=\\s|[，。！？、,.!?;；:]|\$)',
        caseSensitive: false,
        multiLine: true,
      );
      for (final match in expression.allMatches(text)) {
        matches.add((
          start: match.start + (match.group(1)?.length ?? 0),
          nameLength: name.length,
          bot: bot,
        ));
      }
    }
    matches.sort((left, right) {
      final byPosition = left.start.compareTo(right.start);
      if (byPosition != 0) return byPosition;
      return right.nameLength.compareTo(left.nameLength);
    });

    final matched = <String, Bot>{};
    int? claimedStart;
    for (final match in matches) {
      if (match.start == claimedStart) continue;
      claimedStart = match.start;
      matched.putIfAbsent(match.bot.id, () => match.bot);
    }
    return ProjectMentionResolution(bots: matched.values);
  }
}
