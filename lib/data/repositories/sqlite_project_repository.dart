import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hyve/data/models/project_agent_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/project.dart';
import 'package:hyve/domain/models/project_membership.dart';
import 'package:hyve/domain/repositories/project_repository.dart';

final class SqliteProjectRepository implements ProjectAggregateRepository {
  SqliteProjectRepository({
    required LocalDatabaseService localDatabase,
    required ProjectAgentStorageService storage,
  }) : _localDatabase = localDatabase,
       _storage = storage;

  final LocalDatabaseService _localDatabase;
  final ProjectAgentStorageService _storage;
  final StreamController<List<Project>> _changes =
      StreamController<List<Project>>.broadcast();
  List<Project>? _cache;

  @override
  Stream<List<Project>> get changes => _changes.stream;

  @override
  Future<List<Project>> getProjects({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _snapshot;
    _cache =
        (await _localDatabase.loadProjects())
            .map((record) => ProjectRecord(record).toDomain())
            .toList();
    return _snapshot;
  }

  @override
  Future<Project?> getProject(String id) async {
    for (final project in _cache ?? const <Project>[]) {
      if (project.id == id) return project;
    }
    final records = await _localDatabase.loadProject(id);
    return records.isEmpty ? null : ProjectRecord(records.single).toDomain();
  }

  @override
  Future<void> addProject(Project project) {
    return addProjectWithMemberships(project, const <ProjectMembership>[]);
  }

  @override
  Future<void> addProjectWithMemberships(
    Project project,
    Iterable<ProjectMembership> memberships,
  ) async {
    final root = await _storage.projectRoot(project.id);
    final createdRoot = !await root.exists();
    await _storage.ensureProjectRoot(project.id);
    try {
      await _localDatabase.insertProjectWithMemberships(
        ProjectRecord.fromDomain(project).values,
        memberships.map(
          (membership) => ProjectMembershipRecord.fromDomain(membership).values,
        ),
      );
    } on Object {
      if (createdRoot) await _storage.deleteProjectRoot(project.id);
      rethrow;
    }
    await _upsertCache(project);
  }

  @override
  Future<void> updateProject(Project project) async {
    final values = Map<String, Object?>.from(
      ProjectRecord.fromDomain(project).values,
    )..remove('id');
    await _localDatabase.updateProject(project.id, values);
    await _upsertCache(project);
  }

  @override
  Future<void> deleteProject(String id) async {
    final staged = await _storage.stageProjectDeletion(id);
    try {
      await _localDatabase.deleteProject(id);
    } on Object {
      await staged?.rollback();
      rethrow;
    }
    await staged?.commit();
    _cache = _cache?.where((project) => project.id != id).toList();
    _emit();
  }

  Future<void> _upsertCache(Project project) async {
    if (_cache == null) {
      await getProjects(forceRefresh: true);
    } else {
      _cache = <Project>[
        for (final item in _cache!)
          if (item.id != project.id) item,
        project,
      ]..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    }
    _emit();
  }

  List<Project> get _snapshot =>
      List<Project>.unmodifiable(_cache ?? const <Project>[]);

  void _emit() {
    if (!_changes.isClosed) _changes.add(_snapshot);
  }

  @visibleForTesting
  Future<void> dispose() => _changes.close();
}
