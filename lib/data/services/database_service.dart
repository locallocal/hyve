import 'dart:convert';
import 'dart:io';

import 'package:hyve/data/services/database_schema_v19.dart';
import 'package:hyve/domain/models/app_failure.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

typedef ApplicationSupportDirectoryProvider = Future<Directory> Function();
typedef ApplicationDocumentsDirectoryProvider = Future<Directory> Function();

class DatabaseService {
  DatabaseService({
    ApplicationSupportDirectoryProvider? applicationSupportDirectoryProvider,
    ApplicationDocumentsDirectoryProvider?
    applicationDocumentsDirectoryProvider,
    ApplicationDocumentsDirectoryProvider? legacyDocumentsDirectoryProvider,
  }) : _applicationSupportDirectoryProvider =
           applicationSupportDirectoryProvider ??
           applicationDocumentsDirectoryProvider ??
           getApplicationSupportDirectory,
       _legacyDocumentsDirectoryProvider =
           legacyDocumentsDirectoryProvider ??
           applicationDocumentsDirectoryProvider ??
           getApplicationDocumentsDirectory;

  final ApplicationSupportDirectoryProvider
  _applicationSupportDirectoryProvider;
  final ApplicationDocumentsDirectoryProvider _legacyDocumentsDirectoryProvider;
  Database? _database;
  Future<Database>? _openingDatabase;

  static const int databaseVersion = 19;
  static const String _databaseFileName = 'app.db';
  static const String _currentBackupName = '.hyve_backup_current';
  static const String _previousBackupName = '.hyve_backup_previous';
  static const String _backupManifestName = 'manifest.json';
  static const String _resetStagingPrefix = '.hyve_reset_staging_';
  static const String _backupStagingPrefix = '.hyve_backup_staging_';

  Future<Database> get database async {
    if (_database != null) return _database!;
    return initDatabase();
  }

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
    final support = await _applicationSupportDirectoryProvider();
    final legacyDocuments = await _legacyDocumentsDirectoryProvider();
    await support.create(recursive: true);
    await _recoverInterruptedReset(support);
    if (normalize(legacyDocuments.path) != normalize(support.path)) {
      await _recoverInterruptedReset(legacyDocuments);
    }

    final databasePath = join(support.path, _databaseFileName);
    final preparation = await _prepareDatabase(
      support: support,
      legacyDocuments: legacyDocuments,
      databasePath: databasePath,
    );
    final createsDatabase = !await databaseExists(databasePath);
    Database? database;
    try {
      database = await openDatabase(
        databasePath,
        version: databaseVersion,
        onConfigure: configure,
        onCreate: createSchema,
      );
      await _verifyIntegrity(database);
      await preparation?.commit();
      return database;
    } on Object {
      await database?.close();
      if (createsDatabase) await deleteDatabase(databasePath);
      await preparation?.rollback();
      rethrow;
    }
  }

  static Future<void> configure(Database database) async {
    await database.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> createSchema(Database db, int version) async {
    if (version != databaseVersion) {
      throw ArgumentError.value(
        version,
        'version',
        'Only schema version $databaseVersion can be created.',
      );
    }
    await DatabaseSchemaV19.create(db);
  }

  static Future<_ResetStage?> _prepareDatabase({
    required Directory support,
    required Directory legacyDocuments,
    required String databasePath,
  }) async {
    if (!await databaseExists(databasePath)) {
      return _stageObsoleteData(
        support: support,
        legacyDocuments: legacyDocuments,
        includeSupportData: false,
      );
    }

    int version;
    try {
      version = await _readVersion(databasePath);
    } on Object catch (error) {
      final restored = await _restoreLatestCurrentBackup(support, databasePath);
      if (!restored) {
        throw AppFailure.storage('database_recovery_failed', cause: error);
      }
      version = await _readVersion(databasePath);
    }
    if (version < databaseVersion) {
      return _stageObsoleteData(
        support: support,
        legacyDocuments: legacyDocuments,
        includeSupportData: true,
      );
    }
    if (version > databaseVersion) {
      throw AppFailure(
        kind: AppFailureKind.migration,
        code: 'database_downgrade_not_supported',
        retryable: false,
        arguments: <String, Object?>{
          'foundVersion': version,
          'expectedVersion': databaseVersion,
        },
      );
    }

    try {
      await _verifyDatabaseFile(databasePath);
      await _writeRollingBackup(support, databasePath);
    } on Object catch (error) {
      final restored = await _restoreLatestCurrentBackup(support, databasePath);
      if (!restored) {
        throw AppFailure.storage('database_recovery_failed', cause: error);
      }
    }
    return _stageObsoleteData(
      support: support,
      legacyDocuments: legacyDocuments,
      includeSupportData: false,
    );
  }

  static Future<int> _readVersion(String databasePath) async {
    Database? database;
    try {
      database = await openDatabase(
        databasePath,
        readOnly: true,
        singleInstance: false,
      );
      return await database.getVersion();
    } on Object catch (error) {
      throw AppFailure.storage('database_recovery_failed', cause: error);
    } finally {
      await database?.close();
    }
  }

  static Future<void> _verifyDatabaseFile(String databasePath) async {
    final database = await openDatabase(
      databasePath,
      readOnly: true,
      singleInstance: false,
    );
    try {
      if (await database.getVersion() != databaseVersion) {
        throw const FormatException('Backup schema version is not current.');
      }
      await _verifyIntegrity(database);
    } finally {
      await database.close();
    }
  }

  static Future<void> _verifyIntegrity(Database database) async {
    final quickCheck = await database.rawQuery('PRAGMA quick_check');
    final result = quickCheck.singleOrNull?.values.singleOrNull;
    if (result != 'ok') {
      throw const FormatException('SQLite quick_check failed.');
    }
    final foreignKeyFailures = await database.rawQuery(
      'PRAGMA foreign_key_check',
    );
    if (foreignKeyFailures.isNotEmpty) {
      throw const FormatException('SQLite foreign_key_check failed.');
    }
  }

  static Future<_ResetStage?> _stageObsoleteData({
    required Directory support,
    required Directory legacyDocuments,
    required bool includeSupportData,
  }) async {
    final namesByRoot = <String, Set<String>>{};
    void add(Directory root, Iterable<String> names) {
      (namesByRoot[normalize(root.path)] ??= <String>{}).addAll(names);
    }

    final supportPath = normalize(support.path);
    final legacyPath = normalize(legacyDocuments.path);
    if (includeSupportData) {
      add(support, <String>{
        _databaseFileName,
        '$_databaseFileName-wal',
        '$_databaseFileName-shm',
        'projects',
        'agents',
        '.pending_deletions',
        _currentBackupName,
        _previousBackupName,
      });
    }
    if (legacyPath != supportPath) {
      add(legacyDocuments, <String>{
        _databaseFileName,
        '$_databaseFileName-wal',
        '$_databaseFileName-shm',
        'chats',
        '.pending_deletions',
        _currentBackupName,
        _previousBackupName,
      });
    } else if (!includeSupportData) {
      // Compatibility for tests and custom providers that use one root: clean
      // the obsolete conversation directory without ever staging the live v19
      // database or its project/agent data.
      add(support, const <String>{'chats'});
    } else {
      add(support, const <String>{'chats'});
    }

    final stages = <_ResetRootStage>[];
    try {
      for (final entry in namesByRoot.entries) {
        final root = Directory(entry.key);
        if (!await root.exists()) continue;
        final stage = await _stageResetRoot(root, entry.value);
        if (stage != null) stages.add(stage);
      }
    } on Object {
      for (final stage in stages.reversed) {
        await stage.rollback();
      }
      rethrow;
    }
    return stages.isEmpty ? null : _ResetStage(stages);
  }

  static Future<_ResetRootStage?> _stageResetRoot(
    Directory root,
    Set<String> names,
  ) async {
    final candidates = <FileSystemEntity>[];
    for (final name in names) {
      final type = await FileSystemEntity.type(
        join(root.path, name),
        followLinks: false,
      );
      if (type == FileSystemEntityType.file) {
        candidates.add(File(join(root.path, name)));
      } else if (type == FileSystemEntityType.directory) {
        candidates.add(Directory(join(root.path, name)));
      }
    }
    await for (final entity in root.list(followLinks: false)) {
      final name = basename(entity.path);
      if (name.startsWith(_backupStagingPrefix)) candidates.add(entity);
    }
    if (candidates.isEmpty) return null;

    final staging = Directory(
      join(
        root.path,
        '$_resetStagingPrefix${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await staging.create(recursive: true);
    final moved = <String>[];
    try {
      for (final entity in candidates) {
        final name = basename(entity.path);
        await entity.rename(join(staging.path, name));
        moved.add(name);
      }
      return _ResetRootStage(root: root, staging: staging, names: moved);
    } on Object {
      final partial = _ResetRootStage(
        root: root,
        staging: staging,
        names: moved,
      );
      await partial.rollback();
      rethrow;
    }
  }

  static Future<void> _recoverInterruptedReset(Directory root) async {
    if (!await root.exists()) return;
    final stages = <Directory>[];
    await for (final entity in root.list(followLinks: false)) {
      if (entity is Directory &&
          basename(entity.path).startsWith(_resetStagingPrefix)) {
        stages.add(entity);
      }
    }
    stages.sort((left, right) => right.path.compareTo(left.path));
    for (final staging in stages) {
      final databasePath = join(root.path, _databaseFileName);
      var currentIsValid = false;
      if (await databaseExists(databasePath)) {
        try {
          await _verifyDatabaseFile(databasePath);
          currentIsValid = true;
        } on Object {
          currentIsValid = false;
        }
      }
      if (currentIsValid) {
        await staging.delete(recursive: true);
        continue;
      }
      final names = <String>[];
      await for (final entity in staging.list(followLinks: false)) {
        names.add(basename(entity.path));
      }
      await _ResetRootStage(
        root: root,
        staging: staging,
        names: names,
      ).rollback();
    }
  }

  static Future<void> _writeRollingBackup(
    Directory root,
    String databasePath,
  ) async {
    final staging = Directory(
      join(
        root.path,
        '$_backupStagingPrefix${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    final current = Directory(join(root.path, _currentBackupName));
    final previous = Directory(join(root.path, _previousBackupName));
    try {
      await staging.create(recursive: true);
      await File(databasePath).copy(join(staging.path, _databaseFileName));
      for (final name in const <String>['projects', 'agents']) {
        final directory = Directory(join(root.path, name));
        if (await directory.exists()) {
          await _copyDirectory(directory, Directory(join(staging.path, name)));
        }
      }
      await File(join(staging.path, _backupManifestName)).writeAsString(
        jsonEncode(<String, Object?>{
          'schema_version': databaseVersion,
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'includes': <String>[_databaseFileName, 'projects', 'agents'],
        }),
        flush: true,
      );
      if (await previous.exists()) await previous.delete(recursive: true);
      if (await current.exists()) await current.rename(previous.path);
      await staging.rename(current.path);
    } on Object {
      if (await staging.exists()) await staging.delete(recursive: true);
      rethrow;
    }
  }

  static Future<bool> _restoreLatestCurrentBackup(
    Directory root,
    String databasePath,
  ) async {
    for (final name in <String>[_currentBackupName, _previousBackupName]) {
      final backup = Directory(join(root.path, name));
      if (!await _isCurrentBackupValid(backup)) continue;
      try {
        await deleteDatabase(databasePath);
        await File(join(backup.path, _databaseFileName)).copy(databasePath);
        for (final dataRoot in const <String>['projects', 'agents']) {
          final current = Directory(join(root.path, dataRoot));
          if (await current.exists()) await current.delete(recursive: true);
          final saved = Directory(join(backup.path, dataRoot));
          if (await saved.exists()) await _copyDirectory(saved, current);
        }
        await _verifyDatabaseFile(databasePath);
        return true;
      } on Object {
        // Try the previous version 19 snapshot.
      }
    }
    return false;
  }

  static Future<bool> _isCurrentBackupValid(Directory backup) async {
    try {
      final manifest = File(join(backup.path, _backupManifestName));
      final database = File(join(backup.path, _databaseFileName));
      if (!await manifest.exists() || !await database.exists()) return false;
      final decoded = jsonDecode(await manifest.readAsString());
      if (decoded is! Map<String, Object?> ||
          decoded['schema_version'] != databaseVersion) {
        return false;
      }
      await _verifyDatabaseFile(database.path);
      return true;
    } on Object {
      return false;
    }
  }

  static Future<void> _copyDirectory(
    Directory source,
    Directory destination,
  ) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(followLinks: false)) {
      final target = join(destination.path, basename(entity.path));
      if (entity is File) {
        await entity.copy(target);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(target));
      }
    }
  }
}

final class _ResetStage {
  const _ResetStage(this.stages);

  final List<_ResetRootStage> stages;

  Future<void> rollback() async {
    for (final stage in stages.reversed) {
      await stage.rollback();
    }
  }

  Future<void> commit() async {
    for (final stage in stages) {
      await stage.commit();
    }
  }
}

final class _ResetRootStage {
  const _ResetRootStage({
    required this.root,
    required this.staging,
    required this.names,
  });

  final Directory root;
  final Directory staging;
  final List<String> names;

  Future<void> rollback() async {
    for (final name in names.reversed) {
      final stagedPath = join(staging.path, name);
      final type = await FileSystemEntity.type(stagedPath, followLinks: false);
      if (type == FileSystemEntityType.notFound) continue;
      final targetPath = join(root.path, name);
      final targetType = await FileSystemEntity.type(
        targetPath,
        followLinks: false,
      );
      if (targetType == FileSystemEntityType.file) {
        await File(targetPath).delete();
      } else if (targetType == FileSystemEntityType.directory) {
        await Directory(targetPath).delete(recursive: true);
      }
      if (type == FileSystemEntityType.file) {
        await File(stagedPath).rename(targetPath);
      } else if (type == FileSystemEntityType.directory) {
        await Directory(stagedPath).rename(targetPath);
      }
    }
    if (await staging.exists()) await staging.delete(recursive: true);
  }

  Future<void> commit() async {
    if (await staging.exists()) await staging.delete(recursive: true);
  }
}
