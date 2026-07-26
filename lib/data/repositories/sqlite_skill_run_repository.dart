import 'package:stars/data/models/skill_records.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/skill_run_repository.dart';

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
