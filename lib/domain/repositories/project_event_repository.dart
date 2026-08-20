import 'package:hyve/domain/models/project_event.dart';

abstract interface class ProjectEventRepository {
  Stream<String> get changes;

  Future<ProjectEvent?> getEvent(String id);

  Future<List<ProjectEvent>> getEvents(
    String projectId, {
    int? afterSequence,
    int limit = 100,
  });

  Future<ProjectEvent?> getMessageAt(String projectId, int messageSequence);

  Future<ProjectEvent?> getAgentReplyForRun(String runId);

  Future<int> countAgentMessagesForRoot(String projectId, String rootMessageId);

  Future<List<ProjectEvent>> getVisibleMessagesThrough(
    String projectId,
    String agentId,
    int throughMessageSequence, {
    int limit = 200,
  });

  Future<void> save(ProjectEvent event);
}
