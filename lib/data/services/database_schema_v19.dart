import 'package:sqflite/sqflite.dart';

abstract final class DatabaseSchemaV19 {
  static Future<void> create(DatabaseExecutor db) async {
    await _createAgents(db);
    await _createProjects(db);
    await _createProjectExecution(db);
    await _createProjectArtifacts(db);
    await _createConversationSummaries(db);
    await _createUsage(db);
    await _createSkills(db);
    await _createSkillEcosystem(db);
    await _createMcp(db);
    await _createProfile(db);
  }

  static Future<void> _createAgents(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE agents (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatar TEXT NOT NULL,
        provider TEXT NOT NULL,
        base_url TEXT NOT NULL,
        api_key TEXT NOT NULL,
        api_type TEXT NOT NULL,
        model TEXT NOT NULL,
        system_prompt TEXT NOT NULL,
        parameters_json TEXT NOT NULL DEFAULT '{}',
        memory_policy_json TEXT NOT NULL,
        memory_backend TEXT NOT NULL DEFAULT 'file'
          CHECK (memory_backend IN ('file', 'externalVector')),
        memory_backend_ref TEXT NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        CHECK (
          (memory_backend = 'file' AND memory_backend_ref = '') OR
          (memory_backend = 'externalVector' AND memory_backend_ref != '')
        )
      )
    ''');
  }

  static Future<void> _createProjects(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        ui_metadata_json TEXT NOT NULL DEFAULT '{}',
        response_policy_json TEXT NOT NULL,
        last_event_sequence INTEGER NOT NULL DEFAULT 0
          CHECK (last_event_sequence >= 0),
        last_message_sequence INTEGER NOT NULL DEFAULT 0
          CHECK (last_message_sequence >= 0),
        last_message TEXT NOT NULL DEFAULT '',
        last_message_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE project_memberships (
        project_id TEXT NOT NULL,
        agent_id TEXT NOT NULL,
        status TEXT NOT NULL
          CHECK (status IN ('active', 'paused', 'removed')),
        position INTEGER NOT NULL CHECK (position >= 0),
        project_storage_access TEXT NOT NULL DEFAULT 'read'
          CHECK (project_storage_access IN ('none', 'read', 'readWrite')),
        capability_restrictions_json TEXT NOT NULL DEFAULT '{}',
        membership_generation INTEGER NOT NULL DEFAULT 1
          CHECK (membership_generation >= 1),
        join_message_sequence INTEGER NOT NULL DEFAULT 0
          CHECK (join_message_sequence >= 0),
        joined_at INTEGER NOT NULL,
        removed_at INTEGER,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (project_id, agent_id),
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE,
        CHECK (
          (status = 'removed' AND removed_at IS NOT NULL) OR
          (status != 'removed' AND removed_at IS NULL)
        )
      )
    ''');
    await db.execute(
      'CREATE INDEX project_memberships_agent_index '
      'ON project_memberships(agent_id, status)',
    );
  }

  static Future<void> _createProjectExecution(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE project_turns (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        root_event_id TEXT NOT NULL,
        initiator_type TEXT NOT NULL
          CHECK (initiator_type IN ('user', 'agent', 'system')),
        initiator_id TEXT NOT NULL DEFAULT '',
        routing_mode TEXT NOT NULL
          CHECK (routing_mode IN ('targeted', 'broadcast', 'delivery')),
        source_message_id TEXT NOT NULL,
        source_message_sequence INTEGER NOT NULL
          CHECK (source_message_sequence > 0),
        recipient_count INTEGER NOT NULL CHECK (recipient_count >= 0),
        root_turn_id TEXT NOT NULL,
        autonomous_depth INTEGER NOT NULL DEFAULT 0
          CHECK (autonomous_depth >= 0),
        status TEXT NOT NULL,
        no_participant INTEGER NOT NULL DEFAULT 0
          CHECK (no_participant IN (0, 1)),
        created_at INTEGER NOT NULL,
        completed_at INTEGER,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX project_turns_project_index '
      'ON project_turns(project_id, created_at DESC)',
    );
    await db.execute('''
      CREATE TABLE project_events (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        turn_id TEXT NOT NULL DEFAULT '',
        run_id TEXT NOT NULL DEFAULT '',
        sequence INTEGER NOT NULL CHECK (sequence > 0),
        message_sequence INTEGER CHECK (message_sequence > 0),
        event_type TEXT NOT NULL,
        actor_type TEXT NOT NULL
          CHECK (actor_type IN ('user', 'agent', 'system')),
        actor_id TEXT NOT NULL DEFAULT '',
        actor_name_snapshot TEXT NOT NULL DEFAULT '',
        actor_avatar_snapshot TEXT NOT NULL DEFAULT '',
        visibility TEXT NOT NULL DEFAULT 'project'
          CHECK (visibility IN ('project', 'targets', 'audit')),
        reply_to_event_id TEXT NOT NULL DEFAULT '',
        reply_to_message_sequence INTEGER,
        root_message_id TEXT NOT NULL DEFAULT '',
        autonomous_depth INTEGER NOT NULL DEFAULT 0
          CHECK (autonomous_depth >= 0),
        content TEXT NOT NULL DEFAULT '',
        payload_json TEXT NOT NULL,
        terminal_state TEXT NOT NULL,
        has_partial_content INTEGER NOT NULL DEFAULT 0
          CHECK (has_partial_content IN (0, 1)),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        UNIQUE (project_id, sequence),
        UNIQUE (project_id, message_sequence),
        CHECK (terminal_state != 'draft' OR message_sequence IS NULL)
      )
    ''');
    await db.execute(
      'CREATE INDEX project_events_project_message_index '
      'ON project_events(project_id, message_sequence)',
    );
    await db.execute('''
      CREATE TABLE project_event_targets (
        event_id TEXT NOT NULL,
        agent_id TEXT NOT NULL,
        target_kind TEXT NOT NULL
          CHECK (target_kind IN ('mention', 'broadcast', 'delivery')),
        position INTEGER NOT NULL CHECK (position >= 0),
        PRIMARY KEY (event_id, agent_id),
        FOREIGN KEY (event_id) REFERENCES project_events(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE agent_runs (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        turn_id TEXT NOT NULL,
        agent_id TEXT NOT NULL,
        source_message_event_id TEXT NOT NULL,
        source_message_sequence INTEGER NOT NULL
          CHECK (source_message_sequence > 0),
        context_through_message_sequence INTEGER NOT NULL,
        parent_run_id TEXT NOT NULL DEFAULT '',
        root_run_id TEXT NOT NULL,
        delivery_depth INTEGER NOT NULL DEFAULT 0 CHECK (delivery_depth >= 0),
        phase TEXT NOT NULL CHECK (phase IN ('decision', 'reply', 'delivery')),
        status TEXT NOT NULL,
        agent_snapshot_json TEXT NOT NULL,
        context_report_json TEXT NOT NULL DEFAULT '{"conversationSummarySegmentIds":[],"agentMemoryIds":[],"projectArtifactVersionIds":[],"skillDigests":[],"toolNames":[],"agentMemoryRevision":0,"coveredThroughMessageSequence":0}',
        started_at INTEGER,
        completed_at INTEGER,
        error_code TEXT NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (turn_id) REFERENCES project_turns(id) ON DELETE CASCADE,
        CHECK (context_through_message_sequence >= source_message_sequence)
      )
    ''');
    await db.execute(
      'CREATE INDEX agent_runs_project_status_index '
      'ON agent_runs(project_id, status)',
    );
    await db.execute(
      'CREATE INDEX agent_runs_turn_index ON agent_runs(turn_id, created_at)',
    );
    await db.execute('''
      CREATE TABLE project_agent_cursors (
        project_id TEXT NOT NULL,
        agent_id TEXT NOT NULL,
        last_processed_message_sequence INTEGER NOT NULL DEFAULT 0,
        processing_message_sequence INTEGER,
        worker_state TEXT NOT NULL DEFAULT 'idle',
        active_run_id TEXT,
        lease_owner TEXT NOT NULL DEFAULT '',
        lease_expires_at INTEGER,
        last_error TEXT NOT NULL DEFAULT '',
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (project_id, agent_id),
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE agent_message_receipts (
        project_id TEXT NOT NULL,
        agent_id TEXT NOT NULL,
        message_sequence INTEGER NOT NULL CHECK (message_sequence > 0),
        message_event_id TEXT NOT NULL,
        turn_id TEXT NOT NULL,
        outcome TEXT NOT NULL,
        decision_run_id TEXT NOT NULL DEFAULT '',
        reply_run_id TEXT NOT NULL DEFAULT '',
        reply_event_id TEXT NOT NULL DEFAULT '',
        started_at INTEGER,
        completed_at INTEGER NOT NULL,
        error_code TEXT NOT NULL DEFAULT '',
        PRIMARY KEY (project_id, agent_id, message_sequence),
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE participation_decisions (
        run_id TEXT PRIMARY KEY,
        agent_id TEXT NOT NULL,
        project_id TEXT NOT NULL,
        turn_id TEXT NOT NULL,
        message_sequence INTEGER NOT NULL,
        choice TEXT NOT NULL CHECK (choice IN ('reply', 'pass')),
        reason_code TEXT NOT NULL,
        intended_contribution TEXT NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL,
        FOREIGN KEY (run_id) REFERENCES agent_runs(id) ON DELETE CASCADE,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE agent_deliveries (
        event_id TEXT PRIMARY KEY,
        source_run_id TEXT NOT NULL,
        source_agent_id TEXT NOT NULL,
        kind TEXT NOT NULL,
        summary TEXT NOT NULL,
        payload TEXT NOT NULL,
        visibility TEXT NOT NULL DEFAULT 'project',
        request_public_reply INTEGER NOT NULL DEFAULT 0,
        root_turn_id TEXT NOT NULL,
        depth INTEGER NOT NULL DEFAULT 0,
        payload_digest TEXT NOT NULL,
        FOREIGN KEY (event_id) REFERENCES project_events(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createProjectArtifacts(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE project_artifacts (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        name TEXT NOT NULL,
        relative_path TEXT NOT NULL,
        kind TEXT NOT NULL,
        mime_type TEXT NOT NULL DEFAULT '',
        current_version_id TEXT NOT NULL DEFAULT '',
        search_status TEXT NOT NULL DEFAULT 'pending',
        metadata_json TEXT NOT NULL DEFAULT '{}',
        created_by_type TEXT NOT NULL,
        created_by_id TEXT NOT NULL DEFAULT '',
        source_run_id TEXT NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        UNIQUE (project_id, relative_path)
      )
    ''');
    await db.execute('''
      CREATE TABLE project_artifact_versions (
        id TEXT PRIMARY KEY,
        artifact_id TEXT NOT NULL,
        version_number INTEGER NOT NULL CHECK (version_number > 0),
        relative_blob_path TEXT NOT NULL,
        content_digest TEXT NOT NULL,
        byte_length INTEGER NOT NULL CHECK (byte_length >= 0),
        mime_type TEXT NOT NULL DEFAULT '',
        created_by_type TEXT NOT NULL,
        created_by_id TEXT NOT NULL DEFAULT '',
        source_run_id TEXT NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL,
        FOREIGN KEY (artifact_id) REFERENCES project_artifacts(id)
          ON DELETE CASCADE,
        UNIQUE (artifact_id, version_number)
      )
    ''');
    await db.execute('''
      CREATE TABLE project_event_artifacts (
        event_id TEXT NOT NULL,
        artifact_id TEXT NOT NULL,
        artifact_version_id TEXT NOT NULL,
        relation TEXT NOT NULL,
        position INTEGER NOT NULL CHECK (position >= 0),
        PRIMARY KEY (event_id, artifact_version_id, relation),
        FOREIGN KEY (event_id) REFERENCES project_events(id) ON DELETE CASCADE,
        FOREIGN KEY (artifact_id) REFERENCES project_artifacts(id),
        FOREIGN KEY (artifact_version_id) REFERENCES project_artifact_versions(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE project_artifact_search_documents (
        artifact_id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        name TEXT NOT NULL,
        relative_path TEXT NOT NULL,
        labels_text TEXT NOT NULL DEFAULT '',
        extracted_text TEXT NOT NULL DEFAULT '',
        content_digest TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (artifact_id) REFERENCES project_artifacts(id)
          ON DELETE CASCADE,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createConversationSummaries(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE conversation_summary_state (
        project_id TEXT PRIMARY KEY,
        revision INTEGER NOT NULL DEFAULT 0,
        active_summary_set_id TEXT NOT NULL DEFAULT '',
        covered_through_message_sequence INTEGER NOT NULL DEFAULT 0,
        compaction_status TEXT NOT NULL DEFAULT 'idle',
        last_error TEXT NOT NULL DEFAULT '',
        last_compacted_at INTEGER,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE conversation_summary_segments (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        summary_set_id TEXT NOT NULL,
        source_start_message_sequence INTEGER NOT NULL,
        source_end_message_sequence INTEGER NOT NULL,
        summary_kind TEXT NOT NULL CHECK (summary_kind IN ('rolling', 'rangeExtract')),
        source_event_ids_json TEXT NOT NULL DEFAULT '[]',
        source_digest TEXT NOT NULL,
        summary_file_name TEXT NOT NULL,
        summary_content_digest TEXT NOT NULL,
        summary_content_bytes INTEGER NOT NULL DEFAULT 0
          CHECK (summary_content_bytes >= 0),
        estimated_token_count INTEGER NOT NULL DEFAULT 0,
        provider TEXT NOT NULL DEFAULT '',
        model TEXT NOT NULL DEFAULT '',
        prompt_version INTEGER NOT NULL DEFAULT 1,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        CHECK (source_end_message_sequence >= source_start_message_sequence)
      )
    ''');
    await db.execute(
      'CREATE INDEX conversation_summary_project_status_index '
      'ON conversation_summary_segments(project_id, status)',
    );
    await db.execute('''
      CREATE TABLE agent_memory_evolution_runs (
        id TEXT PRIMARY KEY,
        agent_id TEXT NOT NULL,
        source_project_id TEXT NOT NULL DEFAULT '',
        source_event_ids_json TEXT NOT NULL DEFAULT '[]',
        provider TEXT NOT NULL DEFAULT '',
        model TEXT NOT NULL DEFAULT '',
        prompt_version INTEGER NOT NULL DEFAULT 1,
        input_digest TEXT NOT NULL DEFAULT '',
        input_count INTEGER NOT NULL DEFAULT 0,
        result_count INTEGER NOT NULL DEFAULT 0,
        input_token_count INTEGER NOT NULL DEFAULT 0,
        output_token_count INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL,
        error_code TEXT NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL,
        completed_at INTEGER,
        FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createUsage(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE token_usage_records (
        operation_id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL DEFAULT '',
        agent_id TEXT NOT NULL DEFAULT '',
        run_id TEXT NOT NULL DEFAULT '',
        operation_kind TEXT NOT NULL DEFAULT 'chat_reply',
        token_model TEXT NOT NULL DEFAULT '',
        input_token_count INTEGER NOT NULL DEFAULT 0,
        output_token_count INTEGER NOT NULL DEFAULT 0,
        total_token_count INTEGER NOT NULL DEFAULT 0,
        timestamp INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
      'CREATE INDEX token_usage_records_project_index '
      'ON token_usage_records(project_id)',
    );
    await db.execute(
      'CREATE INDEX token_usage_records_agent_index '
      'ON token_usage_records(agent_id)',
    );
  }

  static Future<void> _createSkills(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE skills (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        version TEXT NOT NULL DEFAULT '',
        scope TEXT NOT NULL,
        source_uri TEXT NOT NULL DEFAULT '',
        root_path TEXT NOT NULL,
        content_digest TEXT NOT NULL,
        trust_state TEXT NOT NULL,
        validation_status TEXT NOT NULL,
        compatibility TEXT NOT NULL DEFAULT '',
        requested_tools_json TEXT NOT NULL DEFAULT '[]',
        diagnostics_json TEXT NOT NULL DEFAULT '[]',
        has_scripts INTEGER NOT NULL DEFAULT 0,
        has_references INTEGER NOT NULL DEFAULT 0,
        has_assets INTEGER NOT NULL DEFAULT 0,
        publisher_id TEXT NOT NULL DEFAULT '',
        publisher_name TEXT NOT NULL DEFAULT '',
        signature_status TEXT NOT NULL DEFAULT 'unsigned',
        catalog_id TEXT NOT NULL DEFAULT '',
        catalog_entry_id TEXT NOT NULL DEFAULT '',
        update_policy TEXT NOT NULL DEFAULT 'manual',
        installed_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(scope, name)
      )
    ''');
    await db.execute('''
      CREATE TABLE agent_skill_bindings (
        agent_id TEXT NOT NULL,
        skill_id TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        activation_mode TEXT NOT NULL DEFAULT 'auto',
        priority INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (agent_id, skill_id),
        FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX agent_skill_bindings_skill_index '
      'ON agent_skill_bindings(skill_id)',
    );
    await db.execute('''
      CREATE TABLE skill_activations (
        id TEXT PRIMARY KEY,
        run_id TEXT NOT NULL,
        turn_id TEXT NOT NULL DEFAULT '',
        project_id TEXT NOT NULL DEFAULT '',
        agent_id TEXT NOT NULL DEFAULT '',
        message_event_id TEXT NOT NULL DEFAULT '',
        skill_id TEXT NOT NULL,
        skill_name TEXT NOT NULL,
        content_digest TEXT NOT NULL,
        trigger_type TEXT NOT NULL,
        status TEXT NOT NULL,
        duration_ms INTEGER,
        error_code TEXT NOT NULL DEFAULT '',
        started_at INTEGER NOT NULL,
        completed_at INTEGER
      )
    ''');
    await db.execute(
      'CREATE INDEX skill_activations_run_index ON skill_activations(run_id)',
    );
    await db.execute('''
      CREATE TABLE project_skill_pins (
        project_id TEXT NOT NULL,
        skill_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        PRIMARY KEY (project_id, skill_id),
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createSkillEcosystem(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE skill_publishers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        key_id TEXT NOT NULL,
        public_key TEXT NOT NULL,
        organization TEXT NOT NULL DEFAULT '',
        trusted INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE skill_catalogs (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        index_uri TEXT NOT NULL,
        publisher_id TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        last_error TEXT NOT NULL DEFAULT '',
        last_fetched_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE skill_script_grants (
        skill_id TEXT PRIMARY KEY,
        content_digest TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 0,
        approved_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE skill_organization_policy (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        allow_unsigned_skills INTEGER NOT NULL DEFAULT 1,
        allow_unknown_publishers INTEGER NOT NULL DEFAULT 0,
        allow_script_execution INTEGER NOT NULL DEFAULT 1,
        allow_automatic_updates INTEGER NOT NULL DEFAULT 0,
        allowed_publishers_json TEXT NOT NULL DEFAULT '[]',
        updated_at INTEGER
      )
    ''');
    await db.execute('INSERT INTO skill_organization_policy (id) VALUES (1)');
    await db.execute('''
      CREATE TABLE skill_compliance_events (
        id TEXT PRIMARY KEY,
        event_type TEXT NOT NULL,
        skill_id TEXT NOT NULL DEFAULT '',
        content_digest TEXT NOT NULL DEFAULT '',
        publisher_id TEXT NOT NULL DEFAULT '',
        decision TEXT NOT NULL DEFAULT '',
        reason TEXT NOT NULL DEFAULT '',
        metadata_json TEXT NOT NULL DEFAULT '{}',
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createMcp(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE mcp_servers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        transport_type TEXT NOT NULL
          CHECK (transport_type IN ('streamableHttp', 'stdio')),
        transport_config_json TEXT NOT NULL,
        remote_server_name TEXT NOT NULL DEFAULT '',
        remote_server_version TEXT NOT NULL DEFAULT '',
        capabilities_json TEXT NOT NULL DEFAULT '{}',
        connection_status TEXT NOT NULL DEFAULT 'disconnected',
        last_error_code TEXT NOT NULL DEFAULT '',
        last_connected_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE mcp_tools (
        server_id TEXT NOT NULL,
        remote_name TEXT NOT NULL,
        title TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        input_schema_json TEXT NOT NULL,
        output_schema_json TEXT,
        annotations_json TEXT NOT NULL DEFAULT '{}',
        task_support TEXT NOT NULL
          CHECK (task_support IN ('forbidden', 'optional', 'required')),
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (server_id, remote_name),
        FOREIGN KEY (server_id) REFERENCES mcp_servers(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createProfile(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        avatar TEXT NOT NULL,
        font_size REAL NOT NULL,
        theme_mode INTEGER NOT NULL,
        language TEXT NOT NULL,
        show_execution_status INTEGER NOT NULL
          CHECK (show_execution_status IN (0, 1)),
        create_timestamp INTEGER NOT NULL,
        modify_timestamp INTEGER NOT NULL
      )
    ''');
  }
}
