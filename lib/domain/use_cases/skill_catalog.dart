import 'package:hyve/domain/models/models.dart';

/// Builds a bounded, deterministic Skill catalog for model disclosure.
///
/// Filtering happens before ranking. Ranking is only a recall step: the model
/// still decides whether a disclosed Skill should be activated.
final class SkillCatalog {
  const SkillCatalog({this.maxEntries = 12, this.maxEstimatedTokens = 1500})
    : assert(maxEntries > 0),
      assert(maxEstimatedTokens > 0);

  final int maxEntries;
  final int maxEstimatedTokens;

  List<SkillCatalogEntry> recall({
    required String query,
    required Iterable<SkillCatalogEntry> candidates,
  }) {
    final queryTerms = _terms(query);
    final ranked =
        candidates.map((candidate) {
            final name = candidate.name.toLowerCase();
            final description = candidate.description.toLowerCase();
            final searchable = '$name $description';
            var score = candidate.priority;
            if (query.toLowerCase().contains(name)) score += 10000;
            for (final term in queryTerms) {
              if (name.contains(term)) score += 200;
              if (description.contains(term)) score += 40;
              if (searchable.contains(term)) score += 10;
            }
            return (candidate: candidate, score: score);
          }).toList()
          ..sort((left, right) {
            final byScore = right.score.compareTo(left.score);
            if (byScore != 0) return byScore;
            final byPriority = right.candidate.priority.compareTo(
              left.candidate.priority,
            );
            if (byPriority != 0) return byPriority;
            return left.candidate.name.compareTo(right.candidate.name);
          });

    final result = <SkillCatalogEntry>[];
    var estimatedTokens = 0;
    for (final entry in ranked) {
      if (result.length >= maxEntries) break;
      final entryTokens = _estimateTokens(
        '${entry.candidate.name}\n${entry.candidate.description}',
      );
      if (result.isNotEmpty &&
          estimatedTokens + entryTokens > maxEstimatedTokens) {
        continue;
      }
      result.add(entry.candidate);
      estimatedTokens += entryTokens;
    }
    return List<SkillCatalogEntry>.unmodifiable(result);
  }

  Set<String> _terms(String source) {
    final normalized = source.toLowerCase();
    final terms =
        RegExp(
          r'[\p{L}\p{N}]+',
          unicode: true,
        ).allMatches(normalized).map((match) => match.group(0)!).toSet();
    final cjk = RegExp(r'[\u3400-\u9fff]');
    final characters =
        normalized.runes
            .map(String.fromCharCode)
            .where((character) => cjk.hasMatch(character))
            .toList();
    for (var index = 0; index + 1 < characters.length; index++) {
      terms.add('${characters[index]}${characters[index + 1]}');
    }
    return terms.where((term) => term.length > 1).toSet();
  }

  int _estimateTokens(String source) => (source.runes.length + 3) ~/ 4;
}
