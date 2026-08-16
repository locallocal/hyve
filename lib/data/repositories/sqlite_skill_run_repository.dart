import 'package:hyve/data/models/skill_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/skill_run_repository.dart';

final class SqliteSkillRunRepository implements SkillRunRepository {
  const SqliteSkillRunRepository({required LocalDatabaseService localDatabase})
    : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;

  @override
  Future<void> saveActivations(Iterable<SkillActivationRecord> records) async {
    await _localDatabase.upsertSkillActivations(
      records.map(
        (record) => SkillActivationDbRecord.fromDomain(record).values,
      ),
    );
  }

  @override
  Future<List<SkillActivationRecord>> getForRun(String runId) async {
    final records = await _localDatabase.loadSkillActivationsForRun(runId);
    return List<SkillActivationRecord>.unmodifiable(
      records.map((record) => SkillActivationDbRecord(record).toDomain()),
    );
  }
}
