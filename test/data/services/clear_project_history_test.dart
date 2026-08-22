import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:hyve/data/services/local_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test(
    'clear history removes the execution graph and resets cursors',
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
      final service = LocalDatabaseService(
        databaseProvider: () async => database,
      );
      const projectId = 'clear-project';
      const activeAgentId = 'active-agent';
      const pausedAgentId = 'paused-agent';
      final now = DateTime(2026, 8, 20, 10);
      final millis = now.millisecondsSinceEpoch;

      for (final agentId in <String>[activeAgentId, pausedAgentId]) {
        await database.insert('agents', _agent(agentId, millis));
      }
      await database.insert('projects', _project(projectId, millis));
      for (final member in <(String, String)>[
        (activeAgentId, 'active'),
        (pausedAgentId, 'paused'),
      ]) {
        await database.insert(
          'project_memberships',
          _membership(projectId, member.$1, member.$2, millis),
        );
        await database.insert(
          'project_agent_cursors',
          _cursor(projectId, member.$1, member.$2, millis),
        );
      }
      await database.insert('project_turns', _turn(projectId, millis));
      await database.insert('project_events', _event(projectId, millis));
      await database.insert(
        'agent_runs',
        _run(projectId, activeAgentId, millis),
      );
      await database.insert(
        'participation_decisions',
        _decision(projectId, activeAgentId, millis),
      );
      await database.insert(
        'agent_message_receipts',
        _receipt(projectId, activeAgentId, millis),
      );
      await database.insert(
        'conversation_summary_state',
        _summaryState(projectId, millis),
      );
      await database.insert(
        'conversation_summary_segments',
        _summarySegment(projectId, millis),
      );
      await database.insert('project_artifacts', _artifact(projectId, millis));
      await database.insert(
        'project_artifact_versions',
        _artifactVersion(millis),
      );
      await database.insert('project_event_artifacts', <String, Object?>{
        'event_id': 'clear-event',
        'artifact_id': 'kept-artifact',
        'artifact_version_id': 'kept-version',
        'relation': 'attachment',
        'position': 0,
      });
      await database.insert(
        'skill_activations',
        _skillActivation(projectId, activeAgentId, millis),
      );

      await service.clearChatHistory(
        projectId,
        now.add(const Duration(minutes: 1)),
      );

      for (final table in <String>[
        'project_events',
        'project_turns',
        'agent_runs',
        'agent_message_receipts',
        'participation_decisions',
        'conversation_summary_state',
        'conversation_summary_segments',
        'skill_activations',
        'project_event_artifacts',
      ]) {
        expect(await database.query(table), isEmpty, reason: table);
      }
      expect(await database.query('project_artifacts'), hasLength(1));
      expect(await database.query('project_artifact_versions'), hasLength(1));
      expect(await database.query('project_memberships'), hasLength(2));
      final cursors = await database.query(
        'project_agent_cursors',
        orderBy: 'agent_id ASC',
      );
      expect(
        cursors.map((row) => row['last_processed_message_sequence']),
        everyElement(0),
      );
      expect(
        cursors.map((row) => row['processing_message_sequence']),
        everyElement(isNull),
      );
      expect(cursors.map((row) => row['active_run_id']), everyElement(isNull));
      expect(cursors.map((row) => row['lease_owner']), everyElement(''));
      expect(cursors.first['worker_state'], 'idle');
      expect(cursors.last['worker_state'], 'paused');
      final project = (await database.query('projects')).single;
      expect(project['last_event_sequence'], 0);
      expect(project['last_message_sequence'], 0);
      expect(project['last_message'], '');
      expect(await database.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );
}

Map<String, Object?> _agent(String id, int now) => <String, Object?>{
  'id': id,
  'name': id,
  'avatar': '',
  'provider': 'test',
  'base_url': '',
  'api_key': '',
  'api_type': 'openai',
  'model': 'test',
  'system_prompt': '',
  'parameters_json': '{}',
  'memory_policy_json': '{}',
  'memory_backend': 'file',
  'memory_backend_ref': '',
  'created_at': now,
  'updated_at': now,
};

Map<String, Object?> _project(String id, int now) => <String, Object?>{
  'id': id,
  'name': 'Clear project',
  'ui_metadata_json': '{}',
  'response_policy_json': '{}',
  'last_event_sequence': 4,
  'last_message_sequence': 4,
  'last_message': 'old message',
  'last_message_at': now,
  'created_at': now,
  'updated_at': now,
};

Map<String, Object?> _membership(
  String projectId,
  String agentId,
  String status,
  int now,
) => <String, Object?>{
  'project_id': projectId,
  'agent_id': agentId,
  'status': status,
  'position': status == 'active' ? 0 : 1,
  'project_storage_access': 'read',
  'capability_restrictions_json': '{}',
  'membership_generation': 1,
  'join_message_sequence': 4,
  'joined_at': now,
  'removed_at': null,
  'updated_at': now,
};

Map<String, Object?> _cursor(
  String projectId,
  String agentId,
  String status,
  int now,
) => <String, Object?>{
  'project_id': projectId,
  'agent_id': agentId,
  'last_processed_message_sequence': 3,
  'processing_message_sequence': 4,
  'worker_state': status == 'active' ? 'processing' : 'paused',
  'active_run_id': 'clear-run',
  'lease_owner': 'old-worker',
  'lease_expires_at': now + 60000,
  'last_error': 'old-error',
  'updated_at': now,
};

Map<String, Object?> _turn(String projectId, int now) => <String, Object?>{
  'id': 'clear-turn',
  'project_id': projectId,
  'root_event_id': 'clear-event',
  'initiator_type': 'user',
  'initiator_id': 'me',
  'routing_mode': 'broadcast',
  'source_message_id': 'clear-event',
  'source_message_sequence': 4,
  'recipient_count': 1,
  'root_turn_id': 'clear-turn',
  'autonomous_depth': 0,
  'status': 'running',
  'no_participant': 0,
  'created_at': now,
  'completed_at': null,
};

Map<String, Object?> _event(String projectId, int now) => <String, Object?>{
  'id': 'clear-event',
  'project_id': projectId,
  'turn_id': 'clear-turn',
  'run_id': '',
  'sequence': 4,
  'message_sequence': 4,
  'event_type': 'userMessage',
  'actor_type': 'user',
  'actor_id': 'me',
  'actor_name_snapshot': 'Me',
  'actor_avatar_snapshot': '',
  'visibility': 'project',
  'reply_to_event_id': '',
  'reply_to_message_sequence': null,
  'root_message_id': 'clear-event',
  'autonomous_depth': 0,
  'content': 'old message',
  'payload_json': '{}',
  'terminal_state': 'completed',
  'has_partial_content': 0,
  'created_at': now,
  'updated_at': now,
};

Map<String, Object?> _run(String projectId, String agentId, int now) =>
    <String, Object?>{
      'id': 'clear-run',
      'project_id': projectId,
      'turn_id': 'clear-turn',
      'agent_id': agentId,
      'source_message_event_id': 'clear-event',
      'source_message_sequence': 4,
      'context_through_message_sequence': 4,
      'parent_run_id': '',
      'root_run_id': 'clear-run',
      'delivery_depth': 0,
      'phase': 'decision',
      'status': 'completed',
      'agent_snapshot_json': '{}',
      'context_report_json': '{}',
      'started_at': now,
      'completed_at': now,
      'error_code': '',
      'created_at': now,
    };

Map<String, Object?> _decision(String projectId, String agentId, int now) =>
    <String, Object?>{
      'run_id': 'clear-run',
      'agent_id': agentId,
      'project_id': projectId,
      'turn_id': 'clear-turn',
      'message_sequence': 4,
      'choice': 'pass',
      'reason_code': 'not_needed',
      'intended_contribution': '',
      'created_at': now,
    };

Map<String, Object?> _receipt(String projectId, String agentId, int now) =>
    <String, Object?>{
      'project_id': projectId,
      'agent_id': agentId,
      'message_sequence': 4,
      'message_event_id': 'clear-event',
      'turn_id': 'clear-turn',
      'outcome': 'passed',
      'decision_run_id': 'clear-run',
      'reply_run_id': '',
      'reply_event_id': '',
      'started_at': now,
      'completed_at': now,
      'error_code': '',
    };

Map<String, Object?> _summaryState(String projectId, int now) =>
    <String, Object?>{
      'project_id': projectId,
      'revision': 1,
      'active_summary_set_id': 'clear-set',
      'covered_through_message_sequence': 4,
      'compaction_status': 'idle',
      'last_error': '',
      'last_compacted_at': now,
      'updated_at': now,
    };

Map<String, Object?> _summarySegment(String projectId, int now) =>
    <String, Object?>{
      'id': 'clear-summary',
      'project_id': projectId,
      'summary_set_id': 'clear-set',
      'source_start_message_sequence': 1,
      'source_end_message_sequence': 4,
      'summary_kind': 'rolling',
      'source_event_ids_json': '["clear-event"]',
      'source_digest': 'source',
      'summary_file_name': 'summary.md',
      'summary_content_digest': 'summary',
      'summary_content_bytes': 7,
      'estimated_token_count': 2,
      'provider': 'test',
      'model': 'test',
      'prompt_version': 1,
      'status': 'active',
      'created_at': now,
      'updated_at': now,
    };

Map<String, Object?> _artifact(String projectId, int now) => <String, Object?>{
  'id': 'kept-artifact',
  'project_id': projectId,
  'name': 'kept.txt',
  'relative_path': 'kept.txt',
  'kind': 'text',
  'mime_type': 'text/plain',
  'current_version_id': 'kept-version',
  'search_status': 'ready',
  'metadata_json': '{}',
  'created_by_type': 'user',
  'created_by_id': 'me',
  'source_run_id': '',
  'created_at': now,
  'updated_at': now,
};

Map<String, Object?> _artifactVersion(int now) => <String, Object?>{
  'id': 'kept-version',
  'artifact_id': 'kept-artifact',
  'version_number': 1,
  'relative_blob_path': 'blobs/kept/1',
  'content_digest': 'digest',
  'byte_length': 4,
  'mime_type': 'text/plain',
  'created_by_type': 'user',
  'created_by_id': 'me',
  'source_run_id': '',
  'created_at': now,
};

Map<String, Object?> _skillActivation(
  String projectId,
  String agentId,
  int now,
) => <String, Object?>{
  'id': 'clear-activation',
  'run_id': 'clear-run',
  'turn_id': 'clear-turn',
  'project_id': projectId,
  'agent_id': agentId,
  'message_event_id': 'clear-event',
  'skill_id': 'test-skill',
  'skill_name': 'Test',
  'content_digest': 'skill',
  'trigger_type': 'auto',
  'status': 'completed',
  'duration_ms': 1,
  'error_code': '',
  'started_at': now,
  'completed_at': now,
};
