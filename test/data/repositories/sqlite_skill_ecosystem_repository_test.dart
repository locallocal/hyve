import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stars/data/models/skill_records.dart';
import 'package:stars/data/repositories/sqlite_skill_ecosystem_repository.dart';
import 'package:stars/data/services/database_service.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'round-trips Phase 5 policy, publisher, grant, and audit state',
    () async {
      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
      );
      addTearDown(database.close);
      await DatabaseService.configure(database);
      await DatabaseService.createSchema(
        database,
        DatabaseService.databaseVersion,
      );
      final localDatabase = LocalDatabaseService(
        databaseProvider: () async => database,
      );
      final repository = SqliteSkillEcosystemRepository(
        localDatabase: localDatabase,
      );
      final now = DateTime(2026, 7, 31, 12);
      final publisher = SkillPublisher(
        id: 'publisher-1',
        name: 'Publisher',
        keyId: 'key-1',
        publicKey: 'public-key',
        organization: 'Example',
        createdAt: now,
        updatedAt: now,
      );
      await repository.savePublisher(publisher);
      await repository.saveOrganizationPolicy(
        SkillOrganizationPolicy(
          allowUnsignedSkills: false,
          allowScriptExecution: true,
          allowedPublisherIds: const {'publisher-1'},
          updatedAt: now,
        ),
      );
      await repository.saveCatalog(
        SkillCatalogSource(
          id: 'catalog-1',
          name: 'Catalog',
          indexUri: Uri.parse('https://catalog.example/index.json'),
          publisherId: publisher.id,
          lastFetchedAt: now,
        ),
      );
      await repository.saveScriptGrant(
        SkillScriptGrant(
          skillId: 'user:example',
          contentDigest: 'digest',
          enabled: true,
          approvedAt: now,
        ),
      );
      await repository.appendComplianceEvent(
        SkillComplianceEvent(
          id: 'event-1',
          type: SkillComplianceEventType.scriptEnabled,
          skillId: 'user:example',
          contentDigest: 'digest',
          decision: 'allow',
          metadata: const {'tool': 'skill.example.run'},
          timestamp: now,
        ),
      );

      expect((await repository.getPublisher(publisher.id))?.name, 'Publisher');
      expect((await repository.getOrganizationPolicy()).allowedPublisherIds, {
        'publisher-1',
      });
      expect((await repository.getCatalogs()).single.id, 'catalog-1');
      expect(
        (await repository.getScriptGrant('user:example'))?.contentDigest,
        'digest',
      );
      final event =
          (await repository.getComplianceEvents(
            skillId: 'user:example',
          )).single;
      expect(event.type, SkillComplianceEventType.scriptEnabled);
      expect(event.metadata, {'tool': 'skill.example.run'});
    },
  );

  test('persists the per-Skill update strategy', () async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);
    await DatabaseService.configure(database);
    await DatabaseService.createSchema(
      database,
      DatabaseService.databaseVersion,
    );
    final localDatabase = LocalDatabaseService(
      databaseProvider: () async => database,
    );
    final repository = SqliteSkillEcosystemRepository(
      localDatabase: localDatabase,
    );
    final timestamp = DateTime(2026, 7, 31);
    await localDatabase.upsertSkill(
      SkillRecord.fromDomain(
        SkillDescriptor(
          id: 'user:example',
          name: 'example',
          description: 'Example',
          version: '1.0.0',
          scope: SkillScope.user,
          sourceUri: 'https://catalog.example/example.zip',
          rootPath: '/skills/example',
          contentDigest: 'digest',
          trustState: SkillTrustState.userReviewed,
          validationStatus: SkillValidationStatus.valid,
          compatibility: '',
          installedAt: timestamp,
          updatedAt: timestamp,
        ),
      ).values,
    );

    await repository.setSkillUpdatePolicy(
      'user:example',
      SkillUpdatePolicy.pinned,
    );

    final row = (await localDatabase.loadSkill('user:example')).single;
    expect(SkillRecord(row).toDomain().updatePolicy, SkillUpdatePolicy.pinned);
  });
}
