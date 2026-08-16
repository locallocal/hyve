import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/use_cases/skill_catalog.dart';

void main() {
  test('recalls relevant entries from a large catalog within bounds', () {
    const catalog = SkillCatalog(maxEntries: 3, maxEstimatedTokens: 100);
    final result = catalog.recall(
      query: 'Please summarize this PDF document',
      candidates: [
        for (var index = 0; index < 20; index++)
          _entry(
            'unrelated-$index',
            'Generate decorative color palettes.',
            priority: index,
          ),
        _entry(
          'pdf-processing',
          'Extract and summarize PDF documents and forms.',
        ),
      ],
    );

    expect(result, hasLength(3));
    expect(result.first.name, 'pdf-processing');
  });

  test('uses deterministic priority and name ordering for equal matches', () {
    const catalog = SkillCatalog(maxEntries: 3);
    final result = catalog.recall(
      query: 'general request',
      candidates: [
        _entry('zeta', 'General workflow.', priority: 1),
        _entry('alpha', 'General workflow.', priority: 1),
        _entry('high', 'General workflow.', priority: 2),
      ],
    );

    expect(result.map((entry) => entry.name), ['high', 'alpha', 'zeta']);
  });
}

SkillCatalogEntry _entry(String name, String description, {int priority = 0}) =>
    SkillCatalogEntry(
      id: 'user:$name',
      name: name,
      description: description,
      contentDigest: 'digest-$name',
      priority: priority,
    );
