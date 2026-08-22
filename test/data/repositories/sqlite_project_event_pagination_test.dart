import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/models/project_execution_records.dart';
import 'package:hyve/data/repositories/sqlite_project_event_repository.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/project_event.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test(
    'loads the latest event window and paginates older events in order',
    () async {
      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: DatabaseService.databaseVersion,
          onConfigure: DatabaseService.configure,
          onCreate: DatabaseService.createSchema,
        ),
      );
      addTearDown(database.close);
      final repository = SqliteProjectEventRepository(
        localDatabase: LocalDatabaseService(
          databaseProvider: () async => database,
        ),
      );
      addTearDown(repository.dispose);
      final now = DateTime.utc(2026, 8, 22);
      await database.insert('projects', <String, Object?>{
        'id': 'project-1',
        'name': 'Large timeline',
        'response_policy_json': '{}',
        'last_event_sequence': 250,
        'last_message_sequence': 250,
        'last_message': 'Message 250',
        'last_message_at': now.millisecondsSinceEpoch,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      });
      final batch = database.batch();
      for (var sequence = 1; sequence <= 250; sequence++) {
        final event = ProjectEvent(
          id: 'event-$sequence',
          projectId: 'project-1',
          sequence: sequence,
          messageSequence: sequence,
          eventType: ProjectEventType.userMessage,
          actorType: ProjectEventActorType.user,
          actorId: 'user',
          actorNameSnapshot: 'User',
          content: 'Message $sequence',
          payload: ProjectMessagePayload(),
          createdAt: now.add(Duration(seconds: sequence)),
          updatedAt: now.add(Duration(seconds: sequence)),
        );
        batch.insert(
          'project_events',
          ProjectEventRecord.fromDomain(event).values,
        );
      }
      await batch.commit(noResult: true);

      final stopwatch = Stopwatch()..start();
      final latest = await repository.getEvents('project-1', limit: 100);
      final older = await repository.getEvents(
        'project-1',
        beforeSequence: latest.first.sequence,
        limit: 100,
      );
      stopwatch.stop();

      expect(
        latest.map((event) => event.sequence),
        orderedEquals(<int>[
          for (var sequence = 151; sequence <= 250; sequence++) sequence,
        ]),
      );
      expect(
        older.map((event) => event.sequence),
        orderedEquals(<int>[
          for (var sequence = 51; sequence <= 150; sequence++) sequence,
        ]),
      );
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
      await expectLater(
        repository.getEvents(
          'project-1',
          afterSequence: 10,
          beforeSequence: 20,
        ),
        throwsArgumentError,
      );
    },
  );
}
