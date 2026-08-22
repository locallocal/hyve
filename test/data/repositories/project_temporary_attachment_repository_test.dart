import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/repositories/file_project_temporary_attachment_repository.dart';
import 'package:hyve/data/repositories/sqlite_chat_repository.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test(
    'chat clear reclaims temporary attachments and keeps artifacts',
    () async {
      final support = await Directory.systemTemp.createTemp(
        'hyve-project-tmp-',
      );
      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: DatabaseService.databaseVersion,
          onConfigure: DatabaseService.configure,
          onCreate: DatabaseService.createSchema,
        ),
      );
      final storage = ProjectAgentStorageService(
        supportDirectoryProvider: () async => support,
      );
      final attachments = FileProjectTemporaryAttachmentRepository(
        storage: storage,
      );
      final localDatabase = LocalDatabaseService(
        databaseProvider: () async => database,
      );
      final chats = SqliteChatRepository(
        localDatabase: localDatabase,
        projectAgentStorage: storage,
      );
      addTearDown(() async {
        await chats.dispose();
        await database.close();
        await support.delete(recursive: true);
      });
      final now = DateTime.utc(2026, 8, 22).millisecondsSinceEpoch;
      await database.insert('projects', <String, Object?>{
        'id': 'project-1',
        'name': 'Project',
        'ui_metadata_json': '{}',
        'response_policy_json': '{}',
        'last_event_sequence': 0,
        'last_message_sequence': 0,
        'last_message': '',
        'last_message_at': now,
        'created_at': now,
        'updated_at': now,
      });
      final source = File(path.join(support.path, 'report.txt'));
      await source.writeAsString('temporary report');
      final persisted = await attachments.persist(
        projectId: 'project-1',
        sourcePaths: <String>[source.path],
      );
      final artifactMarker = File(
        path.join(
          (await storage.ensureProjectRoot('project-1')).path,
          'artifacts',
          'blobs',
          'formal.txt',
        ),
      );
      await artifactMarker.writeAsString('formal');

      expect(persisted.single, contains('tmp/message_attachments'));
      expect(await File(persisted.single).readAsString(), 'temporary report');

      await chats.clearHistory('project-1');

      expect(await File(persisted.single).exists(), isFalse);
      expect(await artifactMarker.exists(), isTrue);
    },
  );
}
