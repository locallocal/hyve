import 'package:flutter/material.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/generated/l10n.dart';

class AttachmentBars extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onFilePressed;
  final List<InputModality> inputModalities;

  const AttachmentBars({
    super.key,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onFilePressed,
    required this.inputModalities,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.bodyMedium?.fontSize ?? 16.0;
    return Container(
      padding: const EdgeInsets.only(
        bottom: 4.0,
        left: 16.0,
        right: 16.0,
        top: 4.0,
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (inputModalities.contains(InputModality.image))
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: S.of(context).takePhoto,
                        style: IconButton.styleFrom(
                          minimumSize: const Size.square(48),
                          maximumSize: const Size.square(48),
                        ),
                        icon: Icon(
                          Icons.photo_camera,
                          size: 24,
                          semanticLabel: S.of(context).takePhoto,
                        ),
                        onPressed: onCameraPressed,
                      ),
                      Text(
                        S.of(context).takePhoto,
                        style: TextStyle(fontSize: fontSize - 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          if (inputModalities.contains(InputModality.image))
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: S.of(context).chooseFromGallery,
                        style: IconButton.styleFrom(
                          minimumSize: const Size.square(48),
                          maximumSize: const Size.square(48),
                        ),
                        icon: Icon(
                          Icons.insert_photo,
                          size: 24,
                          semanticLabel: S.of(context).chooseFromGallery,
                        ),
                        onPressed: onGalleryPressed,
                      ),
                      Text(
                        S.of(context).chooseFromGallery,
                        style: TextStyle(fontSize: fontSize - 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          if (inputModalities.contains(InputModality.file))
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: S.of(context).uploadFile,
                        style: IconButton.styleFrom(
                          minimumSize: const Size.square(48),
                          maximumSize: const Size.square(48),
                        ),
                        icon: Icon(
                          Icons.upload_file_rounded,
                          size: 24,
                          semanticLabel: S.of(context).uploadFile,
                        ),
                        onPressed: onFilePressed,
                      ),
                      Text(
                        S.of(context).uploadFile,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
