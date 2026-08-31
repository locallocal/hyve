import 'dart:collection';

import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/view_models/project_agent_activity.dart';

/// A bounded, in-memory cache of presentation-ready project workspaces.
///
/// The database repositories remain the source of truth. This cache only keeps
/// immutable snapshots that have already been prepared for the project UI, so
/// returning to a recently opened project does not show a loading frame or
/// rebuild its timeline from raw records before a background refresh completes.
final class ProjectWorkspaceCache {
  ProjectWorkspaceCache({this.maxEntries = 5}) {
    if (maxEntries < 1) {
      throw ArgumentError.value(maxEntries, 'maxEntries', 'Must be positive.');
    }
  }

  final int maxEntries;
  final LinkedHashMap<String, _ProjectWorkspaceCacheEntry> _entries =
      LinkedHashMap<String, _ProjectWorkspaceCacheEntry>();

  ProjectWorkspaceSnapshot? peek(String projectId) {
    final entry = _entries.remove(projectId);
    if (entry == null) return null;
    _entries[projectId] = entry;
    return entry.snapshot.timelineOffset == entry.timelineOffset
        ? entry.snapshot
        : entry.snapshot._copyWithTimelineOffset(entry.timelineOffset);
  }

  void store(ProjectWorkspaceSnapshot snapshot) {
    _entries.remove(snapshot.project.id);
    _entries[snapshot.project.id] = _ProjectWorkspaceCacheEntry(snapshot);
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void rememberTimelineOffset(String projectId, double offset) {
    final entry = _entries.remove(projectId);
    if (entry == null) return;
    entry.timelineOffset = offset;
    _entries[projectId] = entry;
  }
}

final class _ProjectWorkspaceCacheEntry {
  _ProjectWorkspaceCacheEntry(this.snapshot)
    : timelineOffset = snapshot.timelineOffset;

  final ProjectWorkspaceSnapshot snapshot;
  double timelineOffset;
}

/// Immutable state that is expensive to reconstruct when switching projects.
final class ProjectWorkspaceSnapshot {
  ProjectWorkspaceSnapshot({
    required this.project,
    required Iterable<ProjectAgentStatusSnapshot> agentStatuses,
    required Iterable<Agent> activeAgents,
    required Iterable<ProjectEvent> events,
    required Map<String, ProjectTurn> turns,
    required Map<String, AgentDelivery> deliveries,
    required Map<String, AgentRun> runs,
    required Map<String, ParticipationDecision> decisions,
    required Iterable<ModelTokenUsageRecord> usageRecords,
    required Map<String, String> agentNames,
    required Map<String, Agent> agentsById,
    required this.currentUserProfile,
    required this.hasEarlierEvents,
    this.timelineOffset = 0,
  }) : agentStatuses = List<ProjectAgentStatusSnapshot>.unmodifiable(
         agentStatuses,
       ),
       activeAgents = List<Agent>.unmodifiable(activeAgents),
       events = List<ProjectEvent>.unmodifiable(events),
       turns = Map<String, ProjectTurn>.unmodifiable(turns),
       deliveries = Map<String, AgentDelivery>.unmodifiable(deliveries),
       runs = Map<String, AgentRun>.unmodifiable(runs),
       decisions = Map<String, ParticipationDecision>.unmodifiable(decisions),
       usageRecords = List<ModelTokenUsageRecord>.unmodifiable(usageRecords),
       agentNames = Map<String, String>.unmodifiable(agentNames),
       agentsById = Map<String, Agent>.unmodifiable(agentsById);

  final Project project;
  final List<ProjectAgentStatusSnapshot> agentStatuses;
  final List<Agent> activeAgents;
  final List<ProjectEvent> events;
  final Map<String, ProjectTurn> turns;
  final Map<String, AgentDelivery> deliveries;
  final Map<String, AgentRun> runs;
  final Map<String, ParticipationDecision> decisions;
  final List<ModelTokenUsageRecord> usageRecords;
  final Map<String, String> agentNames;
  final Map<String, Agent> agentsById;
  final Profile? currentUserProfile;
  final bool hasEarlierEvents;
  final double timelineOffset;

  ProjectWorkspaceSnapshot._reuse({
    required this.project,
    required this.agentStatuses,
    required this.activeAgents,
    required this.events,
    required this.turns,
    required this.deliveries,
    required this.runs,
    required this.decisions,
    required this.usageRecords,
    required this.agentNames,
    required this.agentsById,
    required this.currentUserProfile,
    required this.hasEarlierEvents,
    required this.timelineOffset,
  });

  ProjectWorkspaceSnapshot _copyWithTimelineOffset(double timelineOffset) =>
      ProjectWorkspaceSnapshot._reuse(
        project: project,
        agentStatuses: agentStatuses,
        activeAgents: activeAgents,
        events: events,
        turns: turns,
        deliveries: deliveries,
        runs: runs,
        decisions: decisions,
        usageRecords: usageRecords,
        agentNames: agentNames,
        agentsById: agentsById,
        currentUserProfile: currentUserProfile,
        hasEarlierEvents: hasEarlierEvents,
        timelineOffset: timelineOffset,
      );
}
