import 'package:stars/domain/models/models.dart';

abstract interface class SkillRepository {
  Stream<List<SkillDescriptor>> get changes;

  Future<List<SkillDescriptor>> getInstalled({bool forceRefresh = false});

  Future<SkillDescriptor?> getById(String id);

  Future<SkillContent> load(String skillId, {String? contentDigest});

  Future<SkillDescriptor> install(SkillImportSource source);

  Future<void> uninstall(String skillId);
}

abstract interface class SkillPickerRepository {
  Future<SkillImportSource?> pickDirectory();

  Future<SkillImportSource?> pickZipArchive();
}
