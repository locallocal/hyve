import 'package:file_picker/file_picker.dart';
import 'package:stars/domain/models/models.dart';

final class SkillPickerService {
  const SkillPickerService();

  Future<SkillImportSource?> pickDirectory() async {
    final selectedPath = await FilePicker.platform.getDirectoryPath();
    if (selectedPath == null || selectedPath.isEmpty) return null;
    return SkillImportSource(
      kind: SkillImportKind.directory,
      path: selectedPath,
    );
  }

  Future<SkillImportSource?> pickZipArchive() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      allowMultiple: false,
      withData: false,
    );
    final selectedPath = result?.files.single.path;
    if (selectedPath == null || selectedPath.isEmpty) return null;
    return SkillImportSource(
      kind: SkillImportKind.zipArchive,
      path: selectedPath,
    );
  }
}
