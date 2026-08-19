import 'package:hyve/data/models/project_execution_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/project_turn.dart';
import 'package:hyve/domain/repositories/project_turn_repository.dart';

final class SqliteProjectTurnRepository implements ProjectTurnRepository {
  const SqliteProjectTurnRepository({
    required LocalDatabaseService localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;

  @override
  Future<ProjectTurn?> getTurn(String id) async {
    final records = await _localDatabase.loadProjectTurn(id);
    return records.isEmpty
        ? null
        : ProjectTurnRecord(records.single).toDomain();
  }

  @override
  Future<List<ProjectTurn>> getForProject(
    String projectId, {
    int limit = 100,
  }) async {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'Must be positive.');
    }
    return (await _localDatabase.loadProjectTurns(projectId, limit: limit))
        .map((record) => ProjectTurnRecord(record).toDomain())
        .toList(growable: false);
  }

  @override
  Future<void> save(ProjectTurn turn) {
    return _localDatabase.saveProjectTurn(
      ProjectTurnRecord.fromDomain(turn).values,
    );
  }
}
