import 'package:file_picker/file_picker.dart';
import 'package:hyve/domain/models/models.dart';

final class SkillPickerService {
  const SkillPickerService();

  Future<SkillImportSource?> pickDirectory() async {
    final selectedPath = await FilePicker.getDirectoryPath();
    if (selectedPath == null || selectedPath.isEmpty) return null;
    return SkillImportSource(
      kind: SkillImportKind.directory,
      path: selectedPath,
    );
  }

  Future<SkillImportSource?> pickZipArchive() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    final selectedPath = file?.path;
    if (selectedPath == null || selectedPath.isEmpty) return null;
    return SkillImportSource(
      kind: SkillImportKind.zipArchive,
      path: selectedPath,
    );
  }
}
