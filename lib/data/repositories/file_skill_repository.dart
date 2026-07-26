import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:stars/data/models/skill_records.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/data/services/skills/skill_package_storage_service.dart';
import 'package:stars/data/services/skills/skill_parser.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/skill_repository.dart';

final class FileSkillRepository implements SkillRepository {
  FileSkillRepository({
    required LocalDatabaseService localDatabase,
    required SkillPackageStorageService storageService,
    required SkillParser parser,
  }) : _localDatabase = localDatabase,
       _storageService = storageService,
       _parser = parser;

  final LocalDatabaseService _localDatabase;
  final SkillPackageStorageService _storageService;
  final SkillParser _parser;
  final StreamController<List<SkillDescriptor>> _changes =
      StreamController<List<SkillDescriptor>>.broadcast();
  List<SkillDescriptor>? _cache;

  @override
  Stream<List<SkillDescriptor>> get changes => _changes.stream;

  @override
  Future<List<SkillDescriptor>> getInstalled({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache != null) return _snapshot;
    final records = await _localDatabase.loadSkills();
    _cache =
        records.map((record) => SkillRecord(record).toDomain()).toList()
          ..sort((left, right) => left.name.compareTo(right.name));
    return _snapshot;
  }

  @override
  Future<SkillDescriptor?> getById(String id) async {
    final cached = _cache?.where((item) => item.id == id).firstOrNull;
    if (cached != null) return cached;
    final records = await _localDatabase.loadSkill(id);
    return records.isEmpty ? null : SkillRecord(records.single).toDomain();
  }

  @override
  Future<SkillContent> load(String skillId, {String? contentDigest}) async {
    final descriptor = await getById(skillId);
    if (descriptor == null) {
      throw const SkillInstallException('Skill 不存在或已卸载。');
    }
    if (contentDigest != null && contentDigest != descriptor.contentDigest) {
      throw const SkillInstallException('请求的 Skill 版本已不再安装。');
    }
    return SkillContent(
      descriptor: descriptor,
      instructions: await _storageService.readInstructions(descriptor.rootPath),
      files: await _storageService.listFiles(descriptor.rootPath),
    );
  }

  @override
  Future<SkillDescriptor> install(SkillImportSource source) async {
    final staged = await _storageService.stage(source);
    var committed = false;
    try {
      final parsed = await _parser.parse(
        staged.skillRoot,
        validateDirectoryName:
            path.normalize(staged.skillRoot.path) !=
            path.normalize(staged.stagingDirectory.path),
      );
      if (parsed.validationStatus == SkillValidationStatus.invalid) {
        final errors = parsed.diagnostics
            .where((item) => item.severity == SkillDiagnosticSeverity.error)
            .map((item) => item.message)
            .join('；');
        throw SkillInstallException(errors);
      }

      final scope = SkillScope.user;
      final stored = await _storageService.commit(
        staged,
        scope: scope.name,
        skillName: parsed.name,
      );
      committed = true;
      final existingRecords = await _localDatabase.loadSkillByScopeAndName(
        scope.name,
        parsed.name,
      );
      final existing =
          existingRecords.isEmpty
              ? null
              : SkillRecord(existingRecords.single).toDomain();
      final now = DateTime.now();
      final descriptor = SkillDescriptor(
        id: '${scope.name}:${parsed.name}',
        name: parsed.name,
        description: parsed.description,
        version: parsed.version,
        scope: scope,
        sourceUri: staged.sourceUri,
        rootPath: stored.rootPath,
        contentDigest: stored.contentDigest,
        trustState: SkillTrustState.userReviewed,
        validationStatus: parsed.validationStatus,
        compatibility: parsed.compatibility,
        requestedToolNames: parsed.requestedToolNames,
        diagnostics: parsed.diagnostics,
        hasScripts: parsed.hasScripts,
        hasReferences: parsed.hasReferences,
        hasAssets: parsed.hasAssets,
        installedAt: existing?.installedAt ?? now,
        updatedAt: now,
      );
      await _localDatabase.upsertSkill(
        SkillRecord.fromDomain(descriptor).values,
      );
      await _refreshAndEmit();
      return descriptor;
    } finally {
      if (!committed) await _storageService.cleanup(staged);
    }
  }

  @override
  Future<void> uninstall(String skillId) async {
    final descriptor = await getById(skillId);
    if (descriptor == null) return;
    await _localDatabase.deleteSkill(skillId);
    await _storageService.removeInstallation(descriptor);
    await _refreshAndEmit();
  }

  Future<void> _refreshAndEmit() async {
    await getInstalled(forceRefresh: true);
    if (!_changes.isClosed) _changes.add(_snapshot);
  }

  List<SkillDescriptor> get _snapshot =>
      List<SkillDescriptor>.unmodifiable(_cache ?? const []);

  Future<void> dispose() => _changes.close();
}
