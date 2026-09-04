import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

/// Browses flat artifact paths as a retained, project-relative folder tree.
final class ProjectArtifactBrowser extends StatefulWidget {
  const ProjectArtifactBrowser({
    super.key,
    required this.artifacts,
    required this.hasBoundedHeight,
    required this.onPreview,
    required this.actionBuilder,
  });

  final List<ProjectArtifactEntry> artifacts;
  final bool hasBoundedHeight;
  final ValueChanged<ProjectArtifactEntry> onPreview;
  final Widget Function(ProjectArtifactEntry entry) actionBuilder;

  @override
  State<ProjectArtifactBrowser> createState() => _ProjectArtifactBrowserState();
}

final class _ProjectArtifactBrowserState extends State<ProjectArtifactBrowser> {
  List<String> _path = const <String>[];

  @override
  void didUpdateWidget(covariant ProjectArtifactBrowser oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.artifacts, widget.artifacts)) return;
    final validPath = _nearestValidPath(_path, widget.artifacts);
    if (validPath.length != _path.length) _path = validPath;
  }

  void _openDirectory(String name) {
    setState(() => _path = List<String>.unmodifiable(<String>[..._path, name]));
  }

  void _goBack() {
    if (_path.isEmpty) return;
    setState(
      () =>
          _path = List<String>.unmodifiable(_path.sublist(0, _path.length - 1)),
    );
  }

  void _goToDepth(int depth) {
    if (depth < 0 || depth >= _path.length) {
      setState(() => _path = const <String>[]);
      return;
    }
    setState(
      () => _path = List<String>.unmodifiable(_path.sublist(0, depth + 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final directoryCounts = <String, int>{};
    final files = <ProjectArtifactEntry>[];
    for (final entry in widget.artifacts) {
      final segments = _artifactPathSegments(entry);
      if (!_startsWith(segments, _path) || segments.length <= _path.length) {
        continue;
      }
      if (segments.length == _path.length + 1) {
        files.add(entry);
      } else {
        final directory = segments[_path.length];
        directoryCounts[directory] = (directoryCounts[directory] ?? 0) + 1;
      }
    }
    final directories = directoryCounts.entries.toList(growable: false)
      ..sort((left, right) => _compareNames(left.key, right.key));
    files.sort(
      (left, right) => _compareNames(left.artifact.name, right.artifact.name),
    );
    final itemCount = directories.length + files.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ArtifactPathNavigation(
          path: _path,
          onBack: _path.isEmpty ? null : _goBack,
          onNavigate: _goToDepth,
        ),
        const SizedBox(height: 8),
        if (itemCount == 0)
          ProjectEmptyState(icon: LucideIcons.file, title: copy.noArtifacts)
        else if (widget.hasBoundedHeight)
          Expanded(
            child: _ArtifactDirectoryList(
              directories: directories,
              files: files,
              onOpenDirectory: _openDirectory,
              onPreview: widget.onPreview,
              actionBuilder: widget.actionBuilder,
            ),
          )
        else
          _ArtifactDirectoryList(
            directories: directories,
            files: files,
            shrinkWrap: true,
            onOpenDirectory: _openDirectory,
            onPreview: widget.onPreview,
            actionBuilder: widget.actionBuilder,
          ),
      ],
    );
  }
}

final class _ArtifactPathNavigation extends StatelessWidget {
  const _ArtifactPathNavigation({
    required this.path,
    required this.onBack,
    required this.onNavigate,
  });

  final List<String> path;
  final VoidCallback? onBack;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final breadcrumb =
        hasShadProjectTheme(context)
            ? ShadBreadcrumb(
              children: <Widget>[
                if (path.isEmpty)
                  Text(copy.artifactRoot)
                else
                  ShadBreadcrumbLink(
                    key: const ValueKey<String>('artifact-breadcrumb-root'),
                    onPressed: () => onNavigate(-1),
                    child: Text(copy.artifactRoot),
                  ),
                for (var index = 0; index < path.length; index++)
                  if (index == path.length - 1)
                    Text(path[index])
                  else
                    ShadBreadcrumbLink(
                      key: ValueKey<String>(
                        'artifact-breadcrumb-${path.take(index + 1).join('/')}',
                      ),
                      onPressed: () => onNavigate(index),
                      child: Text(path[index]),
                    ),
              ],
            )
            : Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                TextButton(
                  key: const ValueKey<String>('artifact-breadcrumb-root'),
                  onPressed: path.isEmpty ? null : () => onNavigate(-1),
                  child: Text(copy.artifactRoot),
                ),
                for (var index = 0; index < path.length; index++) ...<Widget>[
                  const Icon(Icons.chevron_right, size: 16),
                  TextButton(
                    onPressed:
                        index == path.length - 1
                            ? null
                            : () => onNavigate(index),
                    child: Text(path[index]),
                  ),
                ],
              ],
            );
    return Row(
      children: <Widget>[
        ProjectIconAction(
          key: const ValueKey<String>('artifact-directory-back'),
          label: copy.backToParentFolder,
          onPressed: onBack,
          icon: LucideIcons.arrowLeft,
          variant: ShadButtonVariant.outline,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: breadcrumb,
          ),
        ),
      ],
    );
  }
}

final class _ArtifactDirectoryList extends StatelessWidget {
  const _ArtifactDirectoryList({
    required this.directories,
    required this.files,
    required this.onOpenDirectory,
    required this.onPreview,
    required this.actionBuilder,
    this.shrinkWrap = false,
  });

  final List<MapEntry<String, int>> directories;
  final List<ProjectArtifactEntry> files;
  final ValueChanged<String> onOpenDirectory;
  final ValueChanged<ProjectArtifactEntry> onPreview;
  final Widget Function(ProjectArtifactEntry entry) actionBuilder;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    return ListView.builder(
      key: const ValueKey<String>('artifact-list'),
      primary: shrinkWrap ? false : null,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: directories.length + files.length,
      itemBuilder: (context, index) {
        if (index < directories.length) {
          final directory = directories[index];
          return ProjectSurfaceCard(
            key: ValueKey<String>('artifact-directory-${directory.key}'),
            padding: EdgeInsets.zero,
            child: Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: const Icon(LucideIcons.folder),
                title: Text(directory.key),
                subtitle: Text(copy.folderArtifactCount(directory.value)),
                trailing: const Icon(LucideIcons.chevronRight, size: 18),
                onTap: () => onOpenDirectory(directory.key),
              ),
            ),
          );
        }
        final entry = files[index - directories.length];
        final artifact = entry.artifact;
        final version = entry.currentVersion;
        return ProjectSurfaceCard(
          key: ValueKey<String>('project-artifact-${artifact.id}'),
          padding: EdgeInsets.zero,
          child: Material(
            type: MaterialType.transparency,
            child: ListTile(
              leading: Icon(projectArtifactKindIcon(artifact.kind)),
              title: Text(artifact.name),
              subtitle: Text(
                '${copy.artifactKind(artifact.kind)} · '
                '${version.byteLength} B · v${version.versionNumber} · '
                '${copy.actorSource(artifact)}'
                '${entry.snippet.isEmpty ? '' : '\n${entry.snippet}'}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => onPreview(entry),
              trailing: actionBuilder(entry),
            ),
          ),
        );
      },
    );
  }
}

List<String> _nearestValidPath(
  List<String> requested,
  List<ProjectArtifactEntry> artifacts,
) {
  var candidate = requested;
  while (candidate.isNotEmpty &&
      !artifacts.any(
        (entry) => _startsWith(_artifactPathSegments(entry), candidate),
      )) {
    candidate = candidate.sublist(0, candidate.length - 1);
  }
  return List<String>.unmodifiable(candidate);
}

List<String> _artifactPathSegments(ProjectArtifactEntry entry) => entry
    .artifact
    .relativePath
    .replaceAll('\\', '/')
    .split('/')
    .where((segment) => segment.isNotEmpty)
    .toList(growable: false);

bool _startsWith(List<String> value, List<String> prefix) {
  if (value.length < prefix.length) return false;
  for (var index = 0; index < prefix.length; index++) {
    if (value[index] != prefix[index]) return false;
  }
  return true;
}

int _compareNames(String left, String right) =>
    left.toLowerCase().compareTo(right.toLowerCase());

IconData projectArtifactKindIcon(ProjectArtifactKind kind) => switch (kind) {
  ProjectArtifactKind.image => LucideIcons.image,
  ProjectArtifactKind.audio => LucideIcons.fileAudio,
  ProjectArtifactKind.video => LucideIcons.fileVideo,
  ProjectArtifactKind.code => LucideIcons.code,
  ProjectArtifactKind.dataset => LucideIcons.table,
  ProjectArtifactKind.archive => LucideIcons.archive,
  _ => LucideIcons.fileText,
};
