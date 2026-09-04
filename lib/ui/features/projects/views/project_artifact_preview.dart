import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';

/// Displays an artifact version with an in-app renderer when one is available.
final class ProjectArtifactPreview extends StatelessWidget {
  const ProjectArtifactPreview({
    super.key,
    required this.read,
    required this.filePath,
  });

  final ProjectArtifactReadResult? read;
  final String? filePath;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final current = read;
    if (current == null) {
      return Center(child: Text(copy.unableToReadVersion));
    }
    if (current.text case final text?) {
      return SingleChildScrollView(
        key: const ValueKey<String>('artifact-text-preview'),
        child: SelectableText(text),
      );
    }
    final mimeType =
        current.version.mimeType.toLowerCase().split(';').first.trim();
    final localPath = filePath;
    if (mimeType.startsWith('image/') && localPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ColoredBox(
          color: Colors.black,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            child: Center(
              child: Image.file(
                File(localPath),
                key: const ValueKey<String>('artifact-image-preview'),
                fit: BoxFit.contain,
                errorBuilder:
                    (_, _, _) => Text(
                      copy.unableToReadVersion,
                      style: const TextStyle(color: Colors.white),
                    ),
              ),
            ),
          ),
        ),
      );
    }
    return Center(
      child: Text(
        copy.unsupportedPreview(
          current.version.mimeType,
          current.version.contentDigest,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
