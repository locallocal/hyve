import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/view_models/project_workspace_cache.dart';

void main() {
  group('ProjectWorkspaceCache', () {
    test('keeps recently used snapshots and restores timeline position', () {
      final cache = ProjectWorkspaceCache(maxEntries: 2);

      cache.store(_snapshot('project-1'));
      cache.store(_snapshot('project-2'));
      expect(cache.peek('project-1')?.project.id, 'project-1');

      cache.rememberTimelineOffset('project-1', 128);
      cache.store(_snapshot('project-3'));

      expect(cache.peek('project-2'), isNull);
      expect(cache.peek('project-1')?.timelineOffset, 128);
      expect(cache.peek('project-3')?.project.id, 'project-3');
    });

    test('rejects an unbounded zero-sized cache', () {
      expect(() => ProjectWorkspaceCache(maxEntries: 0), throwsArgumentError);
    });
  });
}

ProjectWorkspaceSnapshot _snapshot(String projectId) {
  final now = DateTime.utc(2026, 8, 31);
  return ProjectWorkspaceSnapshot(
    project: Project(
      id: projectId,
      name: projectId,
      lastMessageAt: now,
      createdAt: now,
      updatedAt: now,
    ),
    agentStatuses: const [],
    activeAgents: const [],
    events: const [],
    turns: const {},
    deliveries: const {},
    runs: const {},
    decisions: const {},
    usageRecords: const [],
    agentNames: const {},
    agentsById: const {},
    currentUserProfile: null,
    hasEarlierEvents: false,
  );
}
