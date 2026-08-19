import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hyve/data/models/project_agent_records.dart';
import 'package:hyve/data/services/bot_api_key_cipher.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/agent.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';

final class SqliteAgentRepository implements AgentRepository {
  SqliteAgentRepository({
    required LocalDatabaseService localDatabase,
    required BotApiKeyCipher apiKeyCipher,
    required ProjectAgentStorageService storage,
  }) : _localDatabase = localDatabase,
       _apiKeyCipher = apiKeyCipher,
       _storage = storage;

  final LocalDatabaseService _localDatabase;
  final BotApiKeyCipher _apiKeyCipher;
  final ProjectAgentStorageService _storage;
  final StreamController<List<Agent>> _changes =
      StreamController<List<Agent>>.broadcast();
  List<Agent>? _cache;

  @override
  Stream<List<Agent>> get changes => _changes.stream;

  @override
  Future<List<Agent>> getAgents({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _snapshot;
    _cache = await _restoreAll(await _localDatabase.loadAgents());
    return _snapshot;
  }

  @override
  Future<Agent?> getAgent(String id) async {
    for (final agent in _cache ?? const <Agent>[]) {
      if (agent.id == id) return agent;
    }
    final records = await _localDatabase.loadAgent(id);
    return records.isEmpty ? null : _restore(records.single);
  }

  @override
  Future<void> addAgent(Agent agent) async {
    var createdFileRoot = false;
    if (agent.memoryBackend == AgentMemoryBackend.file) {
      final root = await _storage.agentRoot(agent.id);
      createdFileRoot = !await root.exists();
      await _storage.ensureAgentRoot(agent.id);
    }
    try {
      await _localDatabase.insertAgent(await _record(agent));
    } on Object {
      if (createdFileRoot) await _storage.deleteAgentRoot(agent.id);
      rethrow;
    }
    await _upsertCache(agent);
  }

  @override
  Future<void> updateAgent(Agent agent) async {
    if (agent.memoryBackend == AgentMemoryBackend.file) {
      await _storage.ensureAgentRoot(agent.id);
    }
    final values = Map<String, Object?>.from(await _record(agent))
      ..remove('id');
    await _localDatabase.updateAgent(agent.id, values);
    await _upsertCache(agent);
  }

  @override
  Future<void> deleteAgent(String id) async {
    final staged = await _storage.stageAgentDeletion(id);
    try {
      await _localDatabase.deleteAgent(id);
    } on Object {
      await staged?.rollback();
      rethrow;
    }
    await staged?.commit();
    _cache = _cache?.where((agent) => agent.id != id).toList();
    _emit();
  }

  Future<Map<String, Object?>> _record(Agent agent) async {
    final storedApiKey = await _apiKeyCipher.encrypt(
      botId: agent.id,
      apiKey: agent.apiKey,
    );
    return AgentRecord.fromDomain(agent, storedApiKey: storedApiKey).values;
  }

  Future<List<Agent>> _restoreAll(
    Iterable<Map<String, Object?>> records,
  ) async {
    final agents = <Agent>[];
    for (final record in records) {
      agents.add(await _restore(record));
    }
    return agents;
  }

  Future<Agent> _restore(Map<String, Object?> values) async {
    final record = AgentRecord(values);
    final stored = record.storedApiKey;
    if (stored.isEmpty) return record.toDomain(apiKey: '');
    if (!_apiKeyCipher.isEncrypted(stored)) {
      throw const FormatException(
        'Agent API key does not use the current encrypted format.',
      );
    }
    return record.toDomain(
      apiKey: await _apiKeyCipher.decrypt(botId: record.id, encrypted: stored),
    );
  }

  Future<void> _upsertCache(Agent agent) async {
    if (_cache == null) {
      _cache = await _restoreAll(await _localDatabase.loadAgents());
    } else {
      _cache = <Agent>[
        for (final item in _cache!)
          if (item.id != agent.id) item,
        agent,
      ];
    }
    _emit();
  }

  List<Agent> get _snapshot => List<Agent>.unmodifiable(_cache ?? const []);

  void _emit() {
    if (!_changes.isClosed) _changes.add(_snapshot);
  }

  @visibleForTesting
  Future<void> dispose() => _changes.close();
}
