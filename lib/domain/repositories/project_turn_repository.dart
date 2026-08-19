import 'package:hyve/domain/models/project_turn.dart';

abstract interface class ProjectTurnRepository {
  Future<ProjectTurn?> getTurn(String id);

  Future<List<ProjectTurn>> getForProject(String projectId, {int limit = 100});

  Future<void> save(ProjectTurn turn);
}
