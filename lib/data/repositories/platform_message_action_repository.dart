import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stars/domain/models/app_failure.dart';
import 'package:stars/domain/repositories/message_action_repository.dart';
import 'package:url_launcher/url_launcher.dart';

final class PlatformMessageActionRepository implements MessageActionRepository {
  const PlatformMessageActionRepository();

  @override
  Future<MediaExportResult> saveImage({
    required String sourcePath,
    required String dialogTitle,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const AppFailure.storage('message_image_missing');
    }
    if (Platform.isAndroid || Platform.isIOS) {
      final saved = await GallerySaver.saveImage(
        sourcePath,
        albumName: 'Stars',
      );
      if (saved != true) {
        throw const AppFailure.storage('message_image_export_failed');
      }
      return MediaExportResult.saved;
    }
    final fileName = source.uri.pathSegments.last;
    final destination = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: FileType.image,
      allowedExtensions: const ['png', 'jpg', 'jpeg'],
    );
    if (destination == null) return MediaExportResult.cancelled;
    await source.copy(destination);
    return MediaExportResult.saved;
  }

  @override
  Future<void> shareImage({required String sourcePath, required String text}) =>
      Share.shareXFiles([XFile(sourcePath)], text: text);

  @override
  Future<bool> openExternal(Uri uri) async {
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
