import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/view_models/project_artifacts_controller.dart';
import 'package:hyve/ui/features/projects/views/project_file_drop_target.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

final class ProjectArtifactsPanel extends StatelessWidget {
  const ProjectArtifactsPanel({super.key, required this.viewModel});

  final ProjectArtifactsController viewModel;

  @override
  Widget build(BuildContext context) =>
      ProjectArtifactsDialog(viewModel: viewModel, embedded: true);
}

final class ProjectArtifactsDialog extends StatefulWidget {
  const ProjectArtifactsDialog({
    super.key,
    required this.viewModel,
    this.embedded = false,
  });

  final ProjectArtifactsController viewModel;
  final bool embedded;

  @override
  State<ProjectArtifactsDialog> createState() => _ProjectArtifactsDialogState();
}

enum _ArtifactAction { preview, rename, delete }

final class _ProjectArtifactsDialogState extends State<ProjectArtifactsDialog> {
  final TextEditingController _search = TextEditingController();
  Timer? _searchDebounce;
  ProjectArtifactKind? _kind;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(widget.viewModel.refreshArtifacts());
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _scheduleFilter(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _searchDebounce = null;
      if (mounted) unawaited(_applyFilter());
    });
  }

  void _submitFilter(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = null;
    unawaited(_applyFilter());
  }

  Future<void> _applyFilter() {
    return widget.viewModel.refreshArtifacts(
      query: _search.text,
      kinds:
          _kind == null
              ? const <ProjectArtifactKind>{}
              : <ProjectArtifactKind>{_kind!},
    );
  }

  Future<void> _createText() async {
    final copy = ProjectLocalizations.of(context);
    final pathController = TextEditingController(text: 'documents/untitled.md');
    final contentController = TextEditingController();
    final accepted = await showProjectFormDialog(
      context: context,
      title: copy.newTextArtifact,
      cancelLabel: copy.cancel,
      confirmLabel: copy.create,
      contentBuilder:
          (dialogContext) => SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProjectTextInput(
                  key: const ValueKey<String>('artifact-new-path'),
                  controller: pathController,
                  label: copy.relativePath,
                  leading: const Icon(LucideIcons.fileText, size: 16),
                ),
                const SizedBox(height: 12),
                if (hasShadProjectTheme(dialogContext)) ...[
                  Text(
                    copy.content,
                    style: ShadTheme.of(dialogContext).textTheme.small,
                  ),
                  const SizedBox(height: 6),
                  ShadTextarea(
                    key: const ValueKey<String>('artifact-new-content'),
                    controller: contentController,
                    minHeight: 180,
                    maxHeight: 320,
                    resizable: false,
                  ),
                ] else
                  TextField(
                    key: const ValueKey<String>('artifact-new-content'),
                    controller: contentController,
                    minLines: 8,
                    maxLines: 16,
                    decoration: InputDecoration(labelText: copy.content),
                  ),
              ],
            ),
          ),
    );
    if (accepted && mounted) {
      await widget.viewModel.createTextArtifact(
        relativePath: pathController.text,
        content: contentController.text,
      );
    }
    pathController.dispose();
    contentController.dispose();
  }

  Future<void> _rename(ProjectArtifactEntry entry) async {
    final copy = ProjectLocalizations.of(context);
    final controller = TextEditingController(text: entry.artifact.relativePath);
    final accepted = await showProjectFormDialog(
      context: context,
      title: copy.moveOrRename,
      cancelLabel: copy.cancel,
      confirmLabel: copy.save,
      contentBuilder:
          (_) => SizedBox(
            width: 520,
            child: ProjectTextInput(
              key: const ValueKey<String>('artifact-move-path'),
              controller: controller,
              label: copy.relativePath,
              leading: const Icon(LucideIcons.fileText, size: 16),
            ),
          ),
    );
    if (accepted && mounted) {
      await widget.viewModel.moveArtifact(entry, controller.text);
    }
    controller.dispose();
  }

  Future<void> _delete(ProjectArtifactEntry entry) async {
    final copy = ProjectLocalizations.of(context);
    final accepted = await showProjectConfirmation(
      context: context,
      title: copy.deleteArtifact,
      description: copy.deleteArtifactDescription(entry.artifact.relativePath),
      cancelLabel: copy.cancel,
      confirmLabel: copy.delete,
      destructive: true,
    );
    if (accepted && mounted) {
      await widget.viewModel.deleteArtifact(entry);
    }
  }

  void _handleAction(_ArtifactAction action, ProjectArtifactEntry entry) {
    switch (action) {
      case _ArtifactAction.preview:
        _preview(entry);
      case _ArtifactAction.rename:
        unawaited(_rename(entry));
      case _ArtifactAction.delete:
        unawaited(_delete(entry));
    }
  }

  void _preview(ProjectArtifactEntry entry) {
    showProjectDialog<void>(
      context: context,
      builder:
          (_) => ProjectArtifactPreviewDialog(
            viewModel: widget.viewModel,
            entry: entry,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final content = ProjectFileDropTarget(
      idleLabel: copy.dropFilesToImport,
      activeLabel: copy.releaseToImport,
      onDropped: (paths) {
        unawaited(widget.viewModel.importArtifactPaths(paths));
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.embedded ? double.infinity : 900,
          maxHeight: widget.embedded ? double.infinity : 680,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AnimatedBuilder(
            animation: widget.viewModel,
            builder: (context, _) {
              final viewModel = widget.viewModel;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.folderKanban,
                        semanticLabel: copy.artifacts,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        copy.artifacts,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      if (!widget.embedded)
                        ProjectIconAction(
                          label: copy.close,
                          onPressed: () => Navigator.pop(context),
                          icon: LucideIcons.x,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const minimumToolbarWidth = 720.0;
                      final toolbarWidth =
                          constraints.maxWidth < minimumToolbarWidth
                              ? minimumToolbarWidth
                              : constraints.maxWidth;
                      return SingleChildScrollView(
                        key: const ValueKey<String>('artifact-toolbar'),
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: toolbarWidth,
                          height: 36,
                          child: Row(
                            key: const ValueKey<String>(
                              'artifact-primary-toolbar',
                            ),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  key: const ValueKey<String>(
                                    'artifact-search-container',
                                  ),
                                  height: 36,
                                  child: ProjectTextInput(
                                    key: const ValueKey<String>(
                                      'artifact-search-field',
                                    ),
                                    controller: _search,
                                    label: copy.searchArtifacts,
                                    showLabel: false,
                                    leading: const Icon(
                                      LucideIcons.search,
                                      size: 16,
                                    ),
                                    onChanged: _scheduleFilter,
                                    onSubmitted: _submitFilter,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 160,
                                height: 36,
                                key: const ValueKey<String>(
                                  'artifact-kind-filter',
                                ),
                                child: ProjectSelect<ProjectArtifactKind>(
                                  initialValue: _kind,
                                  placeholder: copy.allTypes,
                                  options: [
                                    for (final kind
                                        in ProjectArtifactKind.values)
                                      ProjectSelectOption<ProjectArtifactKind>(
                                        value: kind,
                                        label: copy.artifactKind(kind),
                                      ),
                                  ],
                                  onChanged: (kind) {
                                    setState(() => _kind = kind);
                                    unawaited(_applyFilter());
                                  },
                                ),
                              ),
                              if (_kind != null) ...[
                                const SizedBox(width: 10),
                                ProjectActionButton(
                                  label: copy.allTypes,
                                  onPressed: () {
                                    setState(() => _kind = null);
                                    unawaited(_applyFilter());
                                  },
                                  variant: ProjectActionVariant.ghost,
                                  leading: const Icon(LucideIcons.x, size: 16),
                                ),
                              ],
                              const SizedBox(width: 10),
                              ProjectActionButton(
                                key: const ValueKey<String>(
                                  'artifact-import-button',
                                ),
                                onPressed:
                                    viewModel.artifactBusy
                                        ? null
                                        : () => unawaited(
                                          viewModel.importPickedArtifacts(),
                                        ),
                                leading: const Icon(
                                  LucideIcons.fileUp,
                                  size: 16,
                                ),
                                label: copy.importFiles,
                                variant: ProjectActionVariant.outline,
                              ),
                              const SizedBox(width: 10),
                              ProjectActionButton(
                                key: const ValueKey<String>(
                                  'artifact-create-button',
                                ),
                                onPressed:
                                    viewModel.artifactBusy
                                        ? null
                                        : () => unawaited(_createText()),
                                leading: const Icon(LucideIcons.plus, size: 16),
                                label: copy.createText,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (viewModel.artifactBusy)
                    const LinearProgressIndicator(
                      key: ValueKey<String>('artifact-loading'),
                    ),
                  if (viewModel.errorCode.startsWith('artifact_'))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        copy.artifactError(viewModel.errorCode),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child:
                        viewModel.artifacts.isEmpty
                            ? ProjectEmptyState(
                              icon: LucideIcons.file,
                              title: copy.noArtifacts,
                            )
                            : ListView.builder(
                              key: const ValueKey<String>('artifact-list'),
                              itemCount: viewModel.artifacts.length,
                              itemBuilder: (context, index) {
                                final entry = viewModel.artifacts[index];
                                final artifact = entry.artifact;
                                final version = entry.currentVersion;
                                return ProjectSurfaceCard(
                                  key: ValueKey<String>(
                                    'project-artifact-${artifact.id}',
                                  ),
                                  padding: EdgeInsets.zero,
                                  child: ListTile(
                                    leading: Icon(_kindIcon(artifact.kind)),
                                    title: Text(artifact.relativePath),
                                    subtitle: Text(
                                      '${copy.artifactKind(artifact.kind)} · '
                                      '${version.byteLength} B · '
                                      'v${version.versionNumber} · '
                                      '${copy.actorSource(artifact)}\n'
                                      '${version.contentDigest.substring(0, 12)}'
                                      '${entry.snippet.isEmpty ? '' : ' · ${entry.snippet}'}',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    isThreeLine: true,
                                    onTap: () => _preview(entry),
                                    trailing:
                                        ProjectOverflowMenu<_ArtifactAction>(
                                          onSelected:
                                              (action) =>
                                                  _handleAction(action, entry),
                                          items: [
                                            ProjectMenuItem<_ArtifactAction>(
                                              value: _ArtifactAction.preview,
                                              label: copy.previewAndHistory,
                                              icon: LucideIcons.eye,
                                            ),
                                            ProjectMenuItem<_ArtifactAction>(
                                              value: _ArtifactAction.rename,
                                              label: copy.moveOrRename,
                                              icon: LucideIcons.pencil,
                                            ),
                                            ProjectMenuItem<_ArtifactAction>(
                                              value: _ArtifactAction.delete,
                                              label: copy.delete,
                                              icon: LucideIcons.trash2,
                                              destructive: true,
                                            ),
                                          ],
                                        ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    return ProjectDialogSurface(
      embedded: widget.embedded,
      constraints: BoxConstraints(
        maxWidth: widget.embedded ? double.infinity : 900,
        maxHeight: widget.embedded ? double.infinity : 680,
      ),
      child: content,
    );
  }
}

final class ProjectArtifactPreviewDialog extends StatefulWidget {
  const ProjectArtifactPreviewDialog({
    super.key,
    required this.viewModel,
    required this.entry,
  });

  final ProjectArtifactsController viewModel;
  final ProjectArtifactEntry entry;

  @override
  State<ProjectArtifactPreviewDialog> createState() =>
      _ProjectArtifactPreviewDialogState();
}

final class _ProjectArtifactPreviewDialogState
    extends State<ProjectArtifactPreviewDialog> {
  late ProjectArtifactEntry _entry = widget.entry;
  List<ProjectArtifactVersion> _versions = const [];
  List<ProjectArtifactMessageReference> _references = const [];
  ProjectArtifactReadResult? _read;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load({String versionId = ''}) async {
    setState(() => _loading = true);
    final versions = await widget.viewModel.artifactVersions(_entry);
    final read = await widget.viewModel.previewArtifact(
      _entry,
      versionId: versionId,
    );
    final references = await widget.viewModel.artifactMessageReferences(
      _entry,
      versionId: read?.version.id ?? versionId,
    );
    if (!mounted) return;
    setState(() {
      _versions = versions;
      _references = references;
      _read = read;
      _loading = false;
    });
  }

  Future<void> _writeVersion() async {
    final current = _read;
    if (current?.text == null) return;
    final copy = ProjectLocalizations.of(context);
    final controller = TextEditingController(text: current!.text);
    final accepted = await showProjectFormDialog(
      context: context,
      title: copy.writeNewVersion,
      cancelLabel: copy.cancel,
      confirmLabel: copy.createVersion,
      contentBuilder:
          (dialogContext) => SizedBox(
            width: 640,
            child:
                hasShadProjectTheme(dialogContext)
                    ? ShadTextarea(
                      key: const ValueKey<String>('artifact-version-content'),
                      controller: controller,
                      minHeight: 280,
                      maxHeight: 440,
                      resizable: false,
                    )
                    : TextField(
                      key: const ValueKey<String>('artifact-version-content'),
                      controller: controller,
                      minLines: 12,
                      maxLines: 24,
                    ),
          ),
    );
    if (accepted && mounted) {
      final updated = await widget.viewModel.writeTextArtifactVersion(
        entry: _entry,
        content: controller.text,
      );
      if (updated != null && mounted) {
        _entry = updated;
        await _load(versionId: updated.currentVersion.id);
      }
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final read = _read;
    final copy = ProjectLocalizations.of(context);
    final content = SizedBox(
      width: 720,
      height: 520,
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${copy.source(copy.actorSource(_entry.artifact))}'
                    '${_entry.artifact.sourceRunId.isEmpty ? '' : ' · run ${_entry.artifact.sourceRunId}'}',
                  ),
                  if (read != null)
                    Text(
                      copy.versionProvenance(
                        read.version.versionNumber,
                        read.version.createdById,
                        read.version.sourceRunId,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final version in _versions)
                        ProjectBadge(
                          label:
                              'v${version.versionNumber} · '
                              '${version.byteLength} B',
                          variant:
                              read?.version.id == version.id
                                  ? ProjectBadgeVariant.primary
                                  : ProjectBadgeVariant.outline,
                          onPressed:
                              () => unawaited(_load(versionId: version.id)),
                        ),
                    ],
                  ),
                  const Divider(),
                  if (_references.isNotEmpty) ...[
                    Text(
                      copy.referencingMessages(_references.length),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(
                      height: 96,
                      child: ListView.builder(
                        key: const ValueKey<String>(
                          'artifact-message-references',
                        ),
                        itemCount: _references.length,
                        itemBuilder: (context, index) {
                          final reference = _references[index];
                          final actor =
                              reference.actorName.isEmpty
                                  ? reference.actorId
                                  : reference.actorName;
                          return ListTile(
                            dense: true,
                            title: Text(
                              '#${reference.messageSequence} · $actor',
                            ),
                            subtitle: Text(
                              reference.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                  Expanded(
                    child:
                        read == null
                            ? Center(child: Text(copy.unableToReadVersion))
                            : read.text == null
                            ? Center(
                              child: Text(
                                copy.unsupportedPreview(
                                  read.version.mimeType,
                                  read.version.contentDigest,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                            : SingleChildScrollView(
                              child: SelectableText(read.text!),
                            ),
                  ),
                  if (read != null && !read.endOfFile)
                    Text(copy.previewTruncated),
                ],
              ),
    );
    final actions = <Widget>[
      if (read?.text != null &&
          read?.version.id == _entry.artifact.currentVersionId)
        ProjectActionButton(
          key: const ValueKey<String>('artifact-write-version'),
          onPressed: () => unawaited(_writeVersion()),
          leading: const Icon(LucideIcons.pencil, size: 16),
          label: copy.writeNewVersion,
          variant: ProjectActionVariant.outline,
        ),
      ProjectActionButton(
        onPressed: () => Navigator.pop(context),
        label: copy.close,
      ),
    ];
    if (hasShadProjectTheme(context)) {
      return ShadDialog(
        title: Text(_entry.artifact.relativePath),
        actions: actions,
        child: content,
      );
    }
    return AlertDialog(
      title: Text(_entry.artifact.relativePath),
      content: content,
      actions: actions,
    );
  }
}

IconData _kindIcon(ProjectArtifactKind kind) => switch (kind) {
  ProjectArtifactKind.image => Icons.image_outlined,
  ProjectArtifactKind.audio => Icons.audio_file_outlined,
  ProjectArtifactKind.video => Icons.video_file_outlined,
  ProjectArtifactKind.code => Icons.code,
  ProjectArtifactKind.dataset => Icons.table_chart_outlined,
  ProjectArtifactKind.archive => Icons.archive_outlined,
  _ => Icons.insert_drive_file_outlined,
};
