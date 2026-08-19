import 'package:hyve/domain/models/project_event.dart';

abstract interface class ProjectEventRepository {
  Stream<String> get changes;

  Future<ProjectEvent?> getEvent(String id);

  Future<List<ProjectEvent>> getEvents(
    String projectId, {
    int? afterSequence,
    int limit = 100,
  });

  Future<void> save(ProjectEvent event);
}
