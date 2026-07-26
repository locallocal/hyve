import 'package:stars/data/services/skills/skill_picker_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/skill_repository.dart';

final class SkillPickerRepositoryImpl implements SkillPickerRepository {
  const SkillPickerRepositoryImpl({required SkillPickerService service})
    : _service = service;

  final SkillPickerService _service;

  @override
  Future<SkillImportSource?> pickDirectory() => _service.pickDirectory();

  @override
  Future<SkillImportSource?> pickZipArchive() => _service.pickZipArchive();
}
