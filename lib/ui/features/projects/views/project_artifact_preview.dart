import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/chat/views/audio_player_widget.dart';
import 'package:hyve/ui/features/chat/views/video_player_widget.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/utils/theme.dart';

enum ProjectArtifactPreviewType {
  text,
  code,
  markdown,
  html,
  image,
  audio,
  video,
  unsupported,
}

extension ProjectArtifactPreviewTypeX on ProjectArtifactPreviewType {
  bool get requiresLocalFile => switch (this) {
    ProjectArtifactPreviewType.image ||
    ProjectArtifactPreviewType.audio ||
    ProjectArtifactPreviewType.video => true,
    _ => false,
  };
}

const _markdownExtensions = <String>{'md', 'markdown', 'mdown', 'mkd', 'mdx'};
const _htmlExtensions = <String>{'html', 'htm', 'xhtml'};
const _imageExtensions = <String>{
  'avif',
  'bmp',
  'gif',
  'jpeg',
  'jpg',
  'png',
  'svg',
  'webp',
};
const _audioExtensions = <String>{
  'aac',
  'flac',
  'm4a',
  'mp3',
  'oga',
  'ogg',
  'opus',
  'wav',
};
const _videoExtensions = <String>{
  'avi',
  'm4v',
  'mkv',
  'mov',
  'mp4',
  'mpeg',
  'mpg',
  'ogv',
  'webm',
};
const _codeExtensions = <String>{
  'bash',
  'c',
  'cc',
  'conf',
  'cpp',
  'cs',
  'css',
  'cxx',
  'dart',
  'env',
  'fish',
  'go',
  'gradle',
  'h',
  'hpp',
  'ini',
  'java',
  'js',
  'json',
  'jsonl',
  'jsx',
  'kt',
  'kts',
  'less',
  'mjs',
  'php',
  'ps1',
  'py',
  'rb',
  'rs',
  'sass',
  'scss',
  'sh',
  'sql',
  'swift',
  'toml',
  'ts',
  'tsx',
  'xml',
  'yaml',
  'yml',
  'zsh',
};

/// Resolves a renderer using MIME first and the filename as a resilient
/// fallback for imported files whose MIME type is unavailable.
ProjectArtifactPreviewType projectArtifactPreviewType({
  required String mimeType,
  required String fileName,
  required ProjectArtifactKind kind,
  required bool hasText,
}) {
  final normalizedMime = mimeType.toLowerCase().split(';').first.trim();
  final normalizedName = fileName.toLowerCase().trim();
  final dotIndex = normalizedName.lastIndexOf('.');
  final extension =
      dotIndex >= 0 && dotIndex < normalizedName.length - 1
          ? normalizedName.substring(dotIndex + 1)
          : '';

  if (const <String>{
        'text/markdown',
        'text/x-markdown',
        'application/markdown',
      }.contains(normalizedMime) ||
      _markdownExtensions.contains(extension)) {
    return ProjectArtifactPreviewType.markdown;
  }
  if (const <String>{
        'text/html',
        'application/xhtml+xml',
      }.contains(normalizedMime) ||
      _htmlExtensions.contains(extension)) {
    return ProjectArtifactPreviewType.html;
  }
  if (normalizedMime.startsWith('image/') ||
      _imageExtensions.contains(extension) ||
      kind == ProjectArtifactKind.image) {
    return ProjectArtifactPreviewType.image;
  }
  if (normalizedMime.startsWith('audio/') ||
      _audioExtensions.contains(extension) ||
      kind == ProjectArtifactKind.audio) {
    return ProjectArtifactPreviewType.audio;
  }
  if (normalizedMime.startsWith('video/') ||
      _videoExtensions.contains(extension) ||
      kind == ProjectArtifactKind.video) {
    return ProjectArtifactPreviewType.video;
  }
  if (_isCodeMimeType(normalizedMime) ||
      _codeExtensions.contains(extension) ||
      kind == ProjectArtifactKind.code ||
      const <String>{'dockerfile', 'makefile'}.contains(normalizedName)) {
    return ProjectArtifactPreviewType.code;
  }
  if (normalizedMime.startsWith('text/') || hasText) {
    return ProjectArtifactPreviewType.text;
  }
  return ProjectArtifactPreviewType.unsupported;
}

bool _isCodeMimeType(String mimeType) =>
    mimeType.startsWith('text/x-') ||
    const <String>{
      'application/javascript',
      'application/json',
      'application/ld+json',
      'application/sql',
      'application/xml',
      'application/x-httpd-php',
      'application/x-javascript',
      'application/x-sh',
      'application/x-yaml',
      'application/yaml',
      'text/css',
      'text/javascript',
      'text/typescript',
    }.contains(mimeType);

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

    final previewType = projectArtifactPreviewType(
      mimeType: current.version.mimeType,
      fileName: current.artifact.name,
      kind: current.artifact.kind,
      hasText: current.text != null,
    );
    final preview = switch (previewType) {
      ProjectArtifactPreviewType.text => _ArtifactTextPreview(
        text: current.text,
      ),
      ProjectArtifactPreviewType.code => _ArtifactCodePreview(
        text: current.text,
      ),
      ProjectArtifactPreviewType.markdown => _ArtifactMarkdownPreview(
        text: current.text,
      ),
      ProjectArtifactPreviewType.html => _ArtifactHtmlPreview(
        text: current.text,
      ),
      ProjectArtifactPreviewType.image => _ArtifactImagePreview(
        filePath: filePath,
        isSvg:
            current.version.mimeType.toLowerCase().contains('svg') ||
            current.artifact.name.toLowerCase().endsWith('.svg'),
      ),
      ProjectArtifactPreviewType.audio => _ArtifactAudioPreview(
        filePath: filePath,
      ),
      ProjectArtifactPreviewType.video => _ArtifactVideoPreview(
        filePath: filePath,
      ),
      ProjectArtifactPreviewType.unsupported => Center(
        child: Text(
          copy.unsupportedPreview(
            current.version.mimeType,
            current.version.contentDigest,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    };

    return KeyedSubtree(
      key: const ValueKey<String>('artifact-preview-content'),
      child: preview,
    );
  }
}

final class _ArtifactTextPreview extends StatelessWidget {
  const _ArtifactTextPreview({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final value = text;
    if (value == null) return _unreadablePreview(context);
    return SingleChildScrollView(
      key: const ValueKey<String>('artifact-text-preview'),
      padding: const EdgeInsets.all(20),
      child: SelectableText(
        value,
        style: TextStyle(
          color: HyveDesktopTokens.of(context).primaryText,
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }
}

final class _ArtifactCodePreview extends StatelessWidget {
  const _ArtifactCodePreview({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final value = text;
    if (value == null) return _unreadablePreview(context);
    final tokens = HyveDesktopTokens.of(context);
    return SingleChildScrollView(
      key: const ValueKey<String>('artifact-code-preview'),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          value,
          style: TextStyle(
            color: tokens.primaryText,
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.55,
          ),
        ),
      ),
    );
  }
}

final class _ArtifactMarkdownPreview extends StatelessWidget {
  const _ArtifactMarkdownPreview({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final value = text;
    if (value == null) return _unreadablePreview(context);
    final tokens = HyveDesktopTokens.of(context);
    final bodyStyle = TextStyle(
      color: tokens.primaryText,
      fontSize: 14,
      height: 1.6,
    );
    return Markdown(
      key: const ValueKey<String>('artifact-markdown-preview'),
      data: value,
      selectable: true,
      padding: const EdgeInsets.all(20),
      styleSheet: MarkdownStyleSheet(
        p: bodyStyle,
        h1: bodyStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
        h2: bodyStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        h3: bodyStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
        code: bodyStyle.copyWith(
          fontFamily: 'monospace',
          fontSize: 13,
          backgroundColor: tokens.controlFill,
        ),
        codeblockPadding: const EdgeInsets.all(14),
        codeblockDecoration: BoxDecoration(
          color: tokens.controlFill,
          border: Border.all(color: tokens.separator),
          borderRadius: BorderRadius.circular(8),
        ),
        blockquoteDecoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(color: tokens.separator, width: 3),
          ),
        ),
        blockquotePadding:
            Directionality.of(context) == TextDirection.ltr
                ? const EdgeInsets.only(left: 14)
                : const EdgeInsets.only(right: 14),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.separator)),
        ),
      ),
    );
  }
}

final class _ArtifactHtmlPreview extends StatelessWidget {
  const _ArtifactHtmlPreview({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final value = text;
    if (value == null) return _unreadablePreview(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: HtmlWidget(
        value,
        key: const ValueKey<String>('artifact-html-preview'),
        renderMode: RenderMode.listView,
        textStyle: TextStyle(
          color: HyveDesktopTokens.of(context).primaryText,
          fontSize: 14,
          height: 1.6,
        ),
        onTapUrl: (_) => true,
      ),
    );
  }
}

final class _ArtifactImagePreview extends StatelessWidget {
  const _ArtifactImagePreview({required this.filePath, required this.isSvg});

  final String? filePath;
  final bool isSvg;

  @override
  Widget build(BuildContext context) {
    final path = filePath;
    if (path == null) return _unreadablePreview(context, dark: true);
    final image =
        isSvg
            ? SvgPicture.file(
              File(path),
              key: const ValueKey<String>('artifact-image-preview'),
              fit: BoxFit.contain,
              placeholderBuilder:
                  (_) => const Center(child: CircularProgressIndicator()),
            )
            : Image.file(
              File(path),
              key: const ValueKey<String>('artifact-image-preview'),
              fit: BoxFit.contain,
              errorBuilder:
                  (_, _, _) => _unreadablePreview(context, dark: true),
            );
    return ColoredBox(
      color: Colors.black,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 5,
        child: Center(child: image),
      ),
    );
  }
}

final class _ArtifactAudioPreview extends StatelessWidget {
  const _ArtifactAudioPreview({required this.filePath});

  final String? filePath;

  @override
  Widget build(BuildContext context) {
    final path = filePath;
    if (path == null) return _unreadablePreview(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SizedBox(
            key: const ValueKey<String>('artifact-audio-preview'),
            child: AudioPlayerWidget(
              key: ValueKey<String>('artifact-audio-player-$path'),
              audioFilePath: path,
            ),
          ),
        ),
      ),
    );
  }
}

final class _ArtifactVideoPreview extends StatelessWidget {
  const _ArtifactVideoPreview({required this.filePath});

  final String? filePath;

  @override
  Widget build(BuildContext context) {
    final path = filePath;
    if (path == null) return _unreadablePreview(context, dark: true);
    return VideoPlayerWidget(
      key: ValueKey<String>('artifact-video-preview-$path'),
      videoFilePath: path,
      expand: true,
    );
  }
}

Widget _unreadablePreview(BuildContext context, {bool dark = false}) => Center(
  child: Text(
    ProjectLocalizations.of(context).unableToReadVersion,
    textAlign: TextAlign.center,
    style: dark ? const TextStyle(color: Colors.white) : null,
  ),
);
