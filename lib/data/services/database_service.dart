import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

typedef ApplicationDocumentsDirectoryProvider = Future<Directory> Function();

class DatabaseService {
  DatabaseService({
    ApplicationDocumentsDirectoryProvider?
    applicationDocumentsDirectoryProvider,
  }) : _applicationDocumentsDirectoryProvider =
           applicationDocumentsDirectoryProvider ??
           getApplicationDocumentsDirectory;

  final ApplicationDocumentsDirectoryProvider
  _applicationDocumentsDirectoryProvider;
  Database? _database;
  Future<Database>? _openingDatabase;
  static const int databaseVersion = 13;

  // 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    return initDatabase();
  }

  // 初始化数据库
  Future<Database> initDatabase() async {
    if (_database != null) return _database!;
    final opening = _openingDatabase;
    if (opening != null) return opening;

    final future = _openDatabase();
    _openingDatabase = future;
    try {
      _database = await future;
      return _database!;
    } finally {
      _openingDatabase = null;
    }
  }

  Future<Database> _openDatabase() async {
    final Directory appDocDir = await _applicationDocumentsDirectoryProvider();
    final String appDocPath = appDocDir.path;
    final path = join(appDocPath, 'app.db');

    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: createSchema,
      onUpgrade: migrateSchema,
    );
  }

  static Future<void> createSchema(Database db, int version) async {
    // 创建聊天列表表
    await db.execute('''
          CREATE TABLE chats (
            id TEXT PRIMARY KEY,
            bot_id TEXT,
            last_message TEXT,
            last_message_timestamp INTEGER,
            create_timestamp INTERGER,
            modify_timestamp INTERGER
          );
        ''');

    // 创建聊天消息表
    await db.execute('''
          CREATE TABLE messages (
            message_id TEXT NOT NULL UNIQUE,
            turn_id TEXT NOT NULL,
            run_id TEXT NOT NULL DEFAULT '',
            chat_id TEXT,
            bot_id TEXT,
            sender_id TEXT,
            content TEXT,
            reasoning TEXT,
            process_info TEXT,
            images TEXT,
            files TEXT,
            audio TEXT,
            music TEXT,
            video TEXT,
            token_model TEXT NOT NULL DEFAULT '',
            input_token_count INTEGER NOT NULL DEFAULT 0,
            output_token_count INTEGER NOT NULL DEFAULT 0,
            total_token_count INTEGER NOT NULL DEFAULT 0,
            terminal_state TEXT NOT NULL DEFAULT '',
            has_partial_content INTEGER NOT NULL DEFAULT 0,
            timestamp INTEGER
          );
        ''');
    await db.execute(
      'CREATE UNIQUE INDEX messages_message_id_unique '
      'ON messages(message_id)',
    );
    await db.execute('CREATE INDEX messages_bot_id_index ON messages(bot_id)');
    await _createTokenUsageSchema(db);
    await _createSkillSchema(db);
    await _createSkillEcosystemSchema(db);
    await _createConversationSkillPinSchema(db);
    await _createMcpSchema(db);

    // 创建智能体表
    await db.execute('''
          CREATE TABLE bots (
            id TEXT PRIMARY KEY,
            name TEXT,
            avatar TEXT,
            provider TEXT,
            base_url TEXT,
            api_key TEXT,
            api_type TEXT,
            model TEXT,
            system_prompt TEXT,
            parameters TEXT,
            create_timestamp INTEGER,
            modify_timestamp INTEGER
          );
        ''');

    // 创建个人资料表
    await db.execute('''
          CREATE TABLE profile (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            avatar TEXT,
            font_size DOUBLE,
            theme_mode INTEGER,
            language TEXT,
            show_execution_status INTEGER NOT NULL DEFAULT 1,
            create_timestamp INTEGER,
            modify_timestamp INTEGER
          );
        ''');
  }

  static Future<void> migrateSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _addColumnIfMissing(db, 'messages', 'process_info', 'TEXT');
    }
    if (oldVersion < 3) {
      await _addColumnIfMissing(db, 'messages', 'message_id', 'TEXT');
      await _addColumnIfMissing(db, 'messages', 'turn_id', 'TEXT');
      await _addColumnIfMissing(
        db,
        'messages',
        'run_id',
        "TEXT NOT NULL DEFAULT ''",
      );
      await _addColumnIfMissing(
        db,
        'messages',
        'terminal_state',
        "TEXT NOT NULL DEFAULT ''",
      );
      await _addColumnIfMissing(
        db,
        'messages',
        'has_partial_content',
        'INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute('''
        UPDATE messages
        SET message_id = 'legacy:' || chat_id || ':' || rowid
        WHERE message_id IS NULL OR message_id = ''
      ''');
      await db.execute('''
        UPDATE messages
        SET turn_id = 'legacy-turn:' || chat_id || ':' || rowid
        WHERE turn_id IS NULL OR turn_id = ''
      ''');
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS messages_message_id_unique '
        'ON messages(message_id)',
      );
    }
    if (oldVersion < 4) {
      await _addColumnIfMissing(
        db,
        'profile',
        'show_execution_status',
        'INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (oldVersion < 5) {
      await _addColumnIfMissing(
        db,
        'messages',
        'token_model',
        "TEXT NOT NULL DEFAULT ''",
      );
      await _addColumnIfMissing(
        db,
        'messages',
        'input_token_count',
        'INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(
        db,
        'messages',
        'output_token_count',
        'INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(
        db,
        'messages',
        'total_token_count',
        'INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS messages_bot_id_index '
        'ON messages(bot_id)',
      );
    }
    if (oldVersion < 6) {
      await _createTokenUsageSchema(db);
      await db.execute('''
        INSERT OR REPLACE INTO token_usage_records (
          message_id,
          chat_id,
          bot_id,
          token_model,
          input_token_count,
          output_token_count,
          total_token_count,
          timestamp
        )
        SELECT
          message_id,
          COALESCE(chat_id, ''),
          COALESCE(bot_id, ''),
          COALESCE(token_model, ''),
          COALESCE(input_token_count, 0),
          COALESCE(output_token_count, 0),
          COALESCE(total_token_count, 0),
          COALESCE(timestamp, 0)
        FROM messages
        WHERE message_id IS NOT NULL
          AND message_id != ''
          AND (
            COALESCE(input_token_count, 0) > 0
            OR COALESCE(output_token_count, 0) > 0
            OR COALESCE(total_token_count, 0) > 0
          )
      ''');
    }
    if (oldVersion < 7) {
      await _createSkillSchema(db);
    }
    if (oldVersion < 8 && newVersion >= 8) {
      await _createConversationSkillPinSchema(db);
    }
    if (oldVersion < 11 && newVersion >= 11) {
      await _addColumnIfMissing(
        db,
        'skills',
        'publisher_id',
        "TEXT NOT NULL DEFAULT ''",
      );
      await _addColumnIfMissing(
        db,
        'skills',
        'publisher_name',
        "TEXT NOT NULL DEFAULT ''",
      );
      await _addColumnIfMissing(
        db,
        'skills',
        'signature_status',
        "TEXT NOT NULL DEFAULT 'unsigned'",
      );
      await _addColumnIfMissing(
        db,
        'skills',
        'catalog_id',
        "TEXT NOT NULL DEFAULT ''",
      );
      await _addColumnIfMissing(
        db,
        'skills',
        'catalog_entry_id',
        "TEXT NOT NULL DEFAULT ''",
      );
      await _addColumnIfMissing(
        db,
        'skills',
        'update_policy',
        "TEXT NOT NULL DEFAULT 'manual'",
      );
      await _createSkillEcosystemSchema(db);
    }
    if (oldVersion < 13 && newVersion >= 13) {
      await _resetMcpSchema(db);
    }
  }

  static Future<void> _createTokenUsageSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS token_usage_records (
        message_id TEXT PRIMARY KEY,
        chat_id TEXT NOT NULL DEFAULT '',
        bot_id TEXT NOT NULL DEFAULT '',
        token_model TEXT NOT NULL DEFAULT '',
        input_token_count INTEGER NOT NULL DEFAULT 0,
        output_token_count INTEGER NOT NULL DEFAULT 0,
        total_token_count INTEGER NOT NULL DEFAULT 0,
        timestamp INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS token_usage_records_chat_id_index '
      'ON token_usage_records(chat_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS token_usage_records_bot_id_index '
      'ON token_usage_records(bot_id)',
    );
  }

  static Future<void> _createSkillSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS skills (
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
      CREATE TABLE IF NOT EXISTS bot_skill_bindings (
        bot_id TEXT NOT NULL,
        skill_id TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        activation_mode TEXT NOT NULL DEFAULT 'auto',
        priority INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (bot_id, skill_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS bot_skill_bindings_skill_id_index '
      'ON bot_skill_bindings(skill_id)',
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS skill_activations (
        id TEXT PRIMARY KEY,
        run_id TEXT NOT NULL,
        chat_id TEXT NOT NULL,
        message_id TEXT NOT NULL DEFAULT '',
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
      'CREATE INDEX IF NOT EXISTS skill_activations_run_id_index '
      'ON skill_activations(run_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS skill_activations_chat_id_index '
      'ON skill_activations(chat_id)',
    );
  }

  static Future<void> _createSkillEcosystemSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS skill_publishers (
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
      CREATE TABLE IF NOT EXISTS skill_catalogs (
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
      CREATE TABLE IF NOT EXISTS skill_script_grants (
        skill_id TEXT PRIMARY KEY,
        content_digest TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 0,
        approved_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS skill_organization_policy (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        allow_unsigned_skills INTEGER NOT NULL DEFAULT 1,
        allow_unknown_publishers INTEGER NOT NULL DEFAULT 0,
        allow_script_execution INTEGER NOT NULL DEFAULT 1,
        allow_automatic_updates INTEGER NOT NULL DEFAULT 0,
        allowed_publishers_json TEXT NOT NULL DEFAULT '[]',
        updated_at INTEGER
      )
    ''');
    await db.execute('''
      INSERT OR IGNORE INTO skill_organization_policy (id) VALUES (1)
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS skill_compliance_events (
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
    await db.execute(
      'CREATE INDEX IF NOT EXISTS skill_compliance_events_skill_id_index '
      'ON skill_compliance_events(skill_id, timestamp DESC)',
    );
  }

  static Future<void> _createConversationSkillPinSchema(
    DatabaseExecutor db,
  ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS conversation_skill_pins (
        chat_id TEXT NOT NULL,
        skill_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        PRIMARY KEY (chat_id, skill_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS conversation_skill_pins_skill_id_index '
      'ON conversation_skill_pins(skill_id)',
    );
  }

  static Future<void> _createMcpSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mcp_servers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        namespace TEXT NOT NULL UNIQUE,
        transport_type TEXT NOT NULL
          CHECK (transport_type IN ('streamableHttp', 'stdio')),
        transport_config_json TEXT NOT NULL,
        remote_server_name TEXT NOT NULL DEFAULT '',
        remote_server_version TEXT NOT NULL DEFAULT '',
        capabilities_json TEXT NOT NULL DEFAULT '{}',
        connection_status TEXT NOT NULL DEFAULT 'disconnected'
          CHECK (connection_status IN (
            'disconnected',
            'connecting',
            'connected',
            'authorizationRequired',
            'error'
          )),
        last_error_code TEXT NOT NULL DEFAULT '',
        last_connected_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mcp_tools (
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
    await db.execute(
      'CREATE INDEX IF NOT EXISTS mcp_tools_server_id_index '
      'ON mcp_tools(server_id)',
    );
  }

  static Future<void> _resetMcpSchema(DatabaseExecutor db) async {
    await db.execute('DROP TABLE IF EXISTS mcp_tools');
    await db.execute('DROP TABLE IF EXISTS mcp_servers');
    await _createMcpSchema(db);
  }

  static Future<void> _addColumnIfMissing(
    Database db,
    String tableName,
    String columnName,
    String columnType,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    final hasColumn = columns.any((column) => column['name'] == columnName);
    if (!hasColumn) {
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN $columnName $columnType',
      );
    }
  }
}
