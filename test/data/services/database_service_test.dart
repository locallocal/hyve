import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:hyve/domain/models/app_failure.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('version 19 schema', () {
    test('creates only the new Project and Agent persistence model', () async {
      final database = await _openCurrentDatabase();
      addTearDown(database.close);

      await _expectCurrentSchema(database);
      expect(await database.getVersion(), 19);
      expect(await database.rawQuery('PRAGMA quick_check'), [
        <String, Object?>{'quick_check': 'ok'},
      ]);
      expect(await database.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    });

    test('does not create a SQLite store for AgentMemory content', () async {
      final database = await _openCurrentDatabase();
      addTearDown(database.close);

      final tables = await _tableNames(database);
      expect(
        tables,
        isNot(
          containsAll(<String>[
            'agent_memory_items',
            'agent_memory_state',
            'project_memory_items',
            'conversation_memory_items',
          ]),
        ),
      );
      final auditColumns = await database.rawQuery(
        'PRAGMA table_info(agent_memory_evolution_runs)',
      );
      expect(
        auditColumns.map((column) => column['name']),
        isNot(containsAll(<String>['content', 'summary', 'embedding'])),
      );
      expect(
        (await database.rawQuery(
          'PRAGMA table_info(agents)',
        )).map((column) => column['name']),
        containsAll(<String>[
          'memory_policy_json',
          'memory_backend',
          'memory_backend_ref',
        ]),
      );
    });

    test(
      'deleting a Project cascades Project data but preserves Agent data',
      () async {
        final database = await _openCurrentDatabase();
        addTearDown(database.close);
        await _insertProjectGraph(database);

        await database.delete(
          'projects',
          where: 'id = ?',
          whereArgs: const ['project-1'],
        );

        expect(await database.query('projects'), isEmpty);
        expect(await database.query('project_memberships'), isEmpty);
        expect(await database.query('project_events'), isEmpty);
        expect(await database.query('project_event_targets'), isEmpty);
        expect(await database.query('agents'), hasLength(1));
        expect(await database.query('agent_skill_bindings'), hasLength(1));
        expect(await database.rawQuery('PRAGMA foreign_key_check'), isEmpty);
      },
    );

    test(
      'deleting an Agent preserves Project and snapshotted event history',
      () async {
        final database = await _openCurrentDatabase();
        addTearDown(database.close);
        await _insertProjectGraph(database);

        await database.delete(
          'agents',
          where: 'id = ?',
          whereArgs: const ['agent-1'],
        );

        expect(await database.query('agents'), isEmpty);
        expect(await database.query('project_memberships'), isEmpty);
        expect(await database.query('agent_skill_bindings'), isEmpty);
        expect(await database.query('projects'), hasLength(1));
        expect(await database.query('project_events'), hasLength(1));
        expect(await database.query('project_event_targets'), hasLength(1));
        expect(
          (await database.query(
            'project_events',
          )).single['actor_name_snapshot'],
          'Researcher',
        );
        expect(await database.rawQuery('PRAGMA foreign_key_check'), isEmpty);
      },
    );

    test('allows a Project with no Agent membership', () async {
      final database = await _openCurrentDatabase();
      addTearDown(database.close);

      await database.insert('projects', _projectRow('empty-project'));

      expect(await database.query('projects'), hasLength(1));
      expect(await database.query('project_memberships'), isEmpty);
    });

    test('allows an Agent to bind a bundled Skill id', () async {
      final database = await _openCurrentDatabase();
      addTearDown(database.close);
      await database.insert('agents', _agentRow('agent-bundled'));

      await database.insert('agent_skill_bindings', <String, Object?>{
        'agent_id': 'agent-bundled',
        'skill_id': 'system:conversation-history',
        'enabled': 1,
        'activation_mode': 'auto',
        'priority': 0,
        'created_at': 1,
        'updated_at': 1,
      });

      expect(await database.query('agent_skill_bindings'), hasLength(1));
      expect(await database.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    });
  });

  group('version 19 reset and recovery', () {
    test('reopens a current Application Support database intact', () async {
      final roots = await _TemporaryRoots.create('hyve_current_');
      addTearDown(roots.delete);
      final initial = await _openFileDatabase(roots.databasePath, version: 19);
      await initial.insert('agents', _agentRow('current-agent'));
      await initial.close();

      final reopened = await roots.service().initDatabase();
      addTearDown(reopened.close);

      expect(
        await reopened.query(
          'agents',
          where: 'id = ?',
          whereArgs: const ['current-agent'],
        ),
        hasLength(1),
      );
      expect(
        File(path.join(roots.legacy.path, 'app.db')).existsSync(),
        isFalse,
      );
    });

    test(
      'resets lower versions and only removes explicitly named roots',
      () async {
        final roots = await _TemporaryRoots.create('hyve_reset_');
        addTearDown(roots.delete);
        final obsolete = await _openFileDatabase(
          roots.databasePath,
          version: 18,
          createCurrentSchema: false,
        );
        await obsolete.close();
        for (final directory in <Directory>[
          Directory(path.join(roots.support.path, 'projects', 'old-project')),
          Directory(path.join(roots.support.path, 'agents', 'old-agent')),
          Directory(path.join(roots.legacy.path, 'chats', 'old-chat')),
          Directory(path.join(roots.support.path, 'skills', 'bundles', 'kept')),
          Directory(path.join(roots.support.path, 'unrelated')),
        ]) {
          await directory.create(recursive: true);
          await File(path.join(directory.path, 'marker')).writeAsString('data');
        }
        final legacy = await _openFileDatabase(
          path.join(roots.legacy.path, 'app.db'),
          version: 18,
          createCurrentSchema: false,
        );
        await legacy.close();

        final reset = await roots.service().initDatabase();
        addTearDown(reset.close);

        await _expectCurrentSchema(reset);
        expect(
          Directory(path.join(roots.support.path, 'projects')).existsSync(),
          isFalse,
        );
        expect(
          Directory(path.join(roots.support.path, 'agents')).existsSync(),
          isFalse,
        );
        expect(
          Directory(path.join(roots.legacy.path, 'chats')).existsSync(),
          isFalse,
        );
        expect(
          File(path.join(roots.legacy.path, 'app.db')).existsSync(),
          isFalse,
        );
        expect(
          File(
            path.join(
              roots.support.path,
              'skills',
              'bundles',
              'kept',
              'marker',
            ),
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            path.join(roots.support.path, 'unrelated', 'marker'),
          ).existsSync(),
          isTrue,
        );
      },
    );

    test('rejects a newer database without deleting it', () async {
      final roots = await _TemporaryRoots.create('hyve_newer_');
      addTearDown(roots.delete);
      final newer = await _openFileDatabase(
        roots.databasePath,
        version: 20,
        createCurrentSchema: false,
      );
      await newer.close();

      await expectLater(
        roots.service().initDatabase(),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.code,
            'code',
            'database_downgrade_not_supported',
          ),
        ),
      );
      expect(File(roots.databasePath).existsSync(), isTrue);
      expect(await _readVersion(roots.databasePath), 20);
    });

    test(
      'restores v19 database plus Project and Agent roots from backup',
      () async {
        final roots = await _TemporaryRoots.create('hyve_recovery_');
        addTearDown(roots.delete);
        final initialService = roots.service();
        final initial = await initialService.initDatabase();
        await initial.insert('agents', _agentRow('recovered-agent'));
        await initial.insert('projects', _projectRow('recovered-project'));
        final projectAsset = File(
          path.join(
            roots.support.path,
            'projects',
            'recovered-project',
            'asset',
          ),
        );
        final agentMemory = File(
          path.join(roots.support.path, 'agents', 'recovered-agent', 'memory'),
        );
        await projectAsset.parent.create(recursive: true);
        await agentMemory.parent.create(recursive: true);
        await projectAsset.writeAsString('saved project');
        await agentMemory.writeAsString('saved agent');
        await initial.close();

        final checked = await roots.service().initDatabase();
        await checked.close();
        await projectAsset.writeAsString('uncommitted project');
        await agentMemory.writeAsString('uncommitted agent');
        await File(
          roots.databasePath,
        ).writeAsBytes(<int>[0, 1, 2, 3], flush: true);

        final recovered = await roots.service().initDatabase();
        addTearDown(recovered.close);

        expect(await recovered.query('agents'), hasLength(1));
        expect(await recovered.query('projects'), hasLength(1));
        expect(await projectAsset.readAsString(), 'saved project');
        expect(await agentMemory.readAsString(), 'saved agent');
        expect(await recovered.rawQuery('PRAGMA quick_check'), [
          <String, Object?>{'quick_check': 'ok'},
        ]);
      },
    );

    test('does not replace corrupt v19 data without a valid backup', () async {
      final roots = await _TemporaryRoots.create('hyve_corrupt_');
      addTearDown(roots.delete);
      await File(
        roots.databasePath,
      ).writeAsBytes(<int>[0, 1, 2, 3], flush: true);

      await expectLater(
        roots.service().initDatabase(),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.code,
            'code',
            'database_recovery_failed',
          ),
        ),
      );
      expect(await File(roots.databasePath).readAsBytes(), <int>[0, 1, 2, 3]);
    });
  });
}

Future<void> _insertProjectGraph(Database database) async {
  await database.insert('agents', _agentRow('agent-1'));
  await database.insert('projects', _projectRow('project-1'));
  await database.insert('project_memberships', <String, Object?>{
    'project_id': 'project-1',
    'agent_id': 'agent-1',
    'status': 'active',
    'position': 0,
    'project_storage_access': 'read',
    'capability_restrictions_json': '{}',
    'membership_generation': 1,
    'join_message_sequence': 0,
    'joined_at': 1,
    'removed_at': null,
    'updated_at': 1,
  });
  await database.insert('agent_skill_bindings', <String, Object?>{
    'agent_id': 'agent-1',
    'skill_id': 'system:conversation-history',
    'enabled': 1,
    'activation_mode': 'auto',
    'priority': 0,
    'created_at': 1,
    'updated_at': 1,
  });
  await database.insert('project_events', <String, Object?>{
    'id': 'event-1',
    'project_id': 'project-1',
    'turn_id': '',
    'run_id': '',
    'sequence': 1,
    'message_sequence': 1,
    'event_type': 'agentMessage',
    'actor_type': 'agent',
    'actor_id': 'agent-1',
    'actor_name_snapshot': 'Researcher',
    'actor_avatar_snapshot': '',
    'visibility': 'project',
    'reply_to_event_id': '',
    'reply_to_message_sequence': null,
    'root_message_id': 'event-1',
    'autonomous_depth': 0,
    'content': 'snapshot survives Agent deletion',
    'payload_json': '{"reasoning":""}',
    'terminal_state': 'completed',
    'has_partial_content': 0,
    'created_at': 1,
    'updated_at': 1,
  });
  await database.insert('project_event_targets', <String, Object?>{
    'event_id': 'event-1',
    'agent_id': 'agent-1',
    'target_kind': 'mention',
    'position': 0,
  });
}

Map<String, Object?> _agentRow(String id) => <String, Object?>{
  'id': id,
  'name': 'Agent',
  'avatar': '',
  'provider': 'Provider',
  'base_url': 'https://example.test',
  'api_key': '',
  'api_type': 'openai',
  'model': 'model',
  'system_prompt': '',
  'parameters_json': '{}',
  'memory_policy_json': _memoryPolicyJson,
  'memory_backend': 'file',
  'memory_backend_ref': '',
  'created_at': 1,
  'updated_at': 1,
};

Map<String, Object?> _projectRow(String id) => <String, Object?>{
  'id': id,
  'name': 'Project',
  'ui_metadata_json': '{}',
  'response_policy_json': _responsePolicyJson,
  'last_event_sequence': 0,
  'last_message_sequence': 0,
  'last_message': '',
  'last_message_at': 1,
  'created_at': 1,
  'updated_at': 1,
};

const _memoryPolicyJson =
    '{"schemaVersion":1,"autoEvolutionEnabled":true,'
    '"projectFactDefaultScope":"sourceProjectOnly",'
    '"autoCrossProjectKinds":["userPreference","learnedPattern",'
    '"capabilityNote","reflection"],'
    '"privateCrossProject":"requireUserApproval",'
    '"uncertainCrossProject":"requireUserApproval","secretLike":"reject",'
    '"retrieval":{"maxItems":12,"tokenBudget":2048,"minConfidence":0.65}}';

const _responsePolicyJson =
    '{"schemaVersion":1,"broadcastDecision":{"concurrency":4,'
    '"maxInputTokens":4096,"maxOutputTokens":128,"timeoutMs":10000,'
    '"maxAttempts":1,"failureOutcome":"pass"},"replyConcurrency":2,'
    '"autonomousChain":{"maxDepth":4,"maxAgentMessagesPerRoot":16},'
    '"delivery":{"defaultVisibility":"project","maxDepth":4,'
    '"maxDeliveriesPerTurn":8}}';

Future<void> _expectCurrentSchema(Database database) async {
  expect(
    await _tableNames(database),
    unorderedEquals(const <String>{
      'agents',
      'projects',
      'project_memberships',
      'project_turns',
      'project_events',
      'project_event_targets',
      'agent_runs',
      'project_agent_cursors',
      'agent_message_receipts',
      'participation_decisions',
      'agent_deliveries',
      'project_artifacts',
      'project_artifact_versions',
      'project_event_artifacts',
      'project_artifact_search_documents',
      'conversation_summary_state',
      'conversation_summary_segments',
      'agent_memory_evolution_runs',
      'token_usage_records',
      'skills',
      'agent_skill_bindings',
      'skill_activations',
      'project_skill_pins',
      'skill_publishers',
      'skill_catalogs',
      'skill_script_grants',
      'skill_organization_policy',
      'skill_compliance_events',
      'mcp_servers',
      'mcp_tools',
      'profile',
    }),
  );
}

Future<Set<String>> _tableNames(Database database) async {
  final rows = await database.rawQuery('''
    SELECT name FROM sqlite_master
    WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
  ''');
  return rows.map((row) => row['name']! as String).toSet();
}

Future<Database> _openCurrentDatabase() {
  return databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 19,
      onConfigure: DatabaseService.configure,
      onCreate: DatabaseService.createSchema,
    ),
  );
}

Future<Database> _openFileDatabase(
  String databasePath, {
  required int version,
  bool createCurrentSchema = true,
}) {
  return databaseFactoryFfi.openDatabase(
    databasePath,
    options: OpenDatabaseOptions(
      version: version,
      onConfigure: DatabaseService.configure,
      onCreate:
          createCurrentSchema
              ? DatabaseService.createSchema
              : (database, _) => database.execute(
                'CREATE TABLE obsolete_data (id TEXT PRIMARY KEY)',
              ),
    ),
  );
}

Future<int> _readVersion(String databasePath) async {
  final database = await databaseFactoryFfi.openDatabase(
    databasePath,
    options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
  );
  try {
    return database.getVersion();
  } finally {
    await database.close();
  }
}

final class _TemporaryRoots {
  const _TemporaryRoots({required this.support, required this.legacy});

  static Future<_TemporaryRoots> create(String prefix) async {
    final root = await Directory.systemTemp.createTemp(prefix);
    final support = Directory(path.join(root.path, 'support'));
    final legacy = Directory(path.join(root.path, 'documents'));
    await support.create(recursive: true);
    await legacy.create(recursive: true);
    return _TemporaryRoots(support: support, legacy: legacy);
  }

  final Directory support;
  final Directory legacy;

  String get databasePath => path.join(support.path, 'app.db');

  DatabaseService service() => DatabaseService(
    applicationSupportDirectoryProvider: () async => support,
    legacyDocumentsDirectoryProvider: () async => legacy,
  );

  Future<void> delete() => support.parent.delete(recursive: true);
}
