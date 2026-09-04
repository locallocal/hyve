import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/view_models/project_artifacts_controller.dart';
import 'package:hyve/ui/features/projects/views/project_artifact_browser.dart';
import 'package:hyve/ui/features/projects/views/project_artifact_preview.dart';
import 'package:hyve/ui/features/projects/views/project_file_drop_target.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';
import 'package:hyve/utils/theme.dart';

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
    this.onClose,
  });

  final ProjectArtifactsController viewModel;
  final bool embedded;
  final VoidCallback? onClose;

  @override
  State<ProjectArtifactsDialog> createState() => _ProjectArtifactsDialogState();
}

enum _ArtifactAction { preview, openExternal, rename, delete }

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
      case _ArtifactAction.openExternal:
        unawaited(widget.viewModel.openArtifact(entry));
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

  Widget _artifactResults(
    BuildContext context,
    ProjectLocalizations copy,
    ProjectArtifactsController viewModel, {
    required bool hasBoundedHeight,
  }) {
    return ProjectArtifactBrowser(
      artifacts: viewModel.artifacts,
      hasBoundedHeight: hasBoundedHeight,
      onPreview: _preview,
      actionBuilder:
          (entry) => ProjectOverflowMenu<_ArtifactAction>(
            onSelected: (action) => _handleAction(action, entry),
            items: <ProjectMenuItem<_ArtifactAction>>[
              ProjectMenuItem<_ArtifactAction>(
                value: _ArtifactAction.preview,
                label: copy.previewAndHistory,
                icon: LucideIcons.eye,
              ),
              ProjectMenuItem<_ArtifactAction>(
                value: _ArtifactAction.openExternal,
                label: copy.openInSystemApp,
                icon: LucideIcons.externalLink,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final shadTheme = ShadTheme.maybeOf(context);
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
        child: LayoutBuilder(
          builder:
              (context, panelConstraints) => Padding(
                padding: const EdgeInsets.all(20),
                child: AnimatedBuilder(
                  animation: widget.viewModel,
                  builder: (context, _) {
                    final viewModel = widget.viewModel;
                    final hasBoundedHeight = panelConstraints.hasBoundedHeight;
                    final results = _artifactResults(
                      context,
                      copy,
                      viewModel,
                      hasBoundedHeight: hasBoundedHeight,
                    );
                    return Column(
                      mainAxisSize:
                          hasBoundedHeight
                              ? MainAxisSize.max
                              : MainAxisSize.min,
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
                              style:
                                  shadTheme?.textTheme.h4 ??
                                  Theme.of(context).textTheme.titleLarge,
                            ),
                            const Spacer(),
                            if (widget.onClose != null)
                              ProjectBackAction(
                                key: const ValueKey<String>(
                                  'project-artifacts-close',
                                ),
                                label: copy.backToMessages,
                                onPressed: widget.onClose,
                              )
                            else if (!widget.embedded)
                              const SizedBox.square(dimension: 44),
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
                                height: HyveDesktopThemeSpec.botFormFieldHeight,
                                child: Row(
                                  key: const ValueKey<String>(
                                    'artifact-primary-toolbar',
                                  ),
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        key: const ValueKey<String>(
                                          'artifact-search-container',
                                        ),
                                        height:
                                            HyveDesktopThemeSpec
                                                .botFormFieldHeight,
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
                                      height:
                                          HyveDesktopThemeSpec
                                              .botFormFieldHeight,
                                      key: const ValueKey<String>(
                                        'artifact-kind-filter',
                                      ),
                                      child: ProjectSelect<ProjectArtifactKind>(
                                        initialValue: _kind,
                                        placeholder: copy.allTypes,
                                        options: [
                                          for (final kind
                                              in ProjectArtifactKind.values)
                                            ProjectSelectOption<
                                              ProjectArtifactKind
                                            >(
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
                                        leading: const Icon(
                                          LucideIcons.x,
                                          size: 16,
                                        ),
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
                                                viewModel
                                                    .importPickedArtifacts(),
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
                                      leading: const Icon(
                                        LucideIcons.plus,
                                        size: 16,
                                      ),
                                      label: copy.createText,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        if (viewModel.artifactBusy)
                          shadTheme == null
                              ? const LinearProgressIndicator(
                                key: ValueKey<String>('artifact-loading'),
                              )
                              : const ShadProgress(
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
                        if (hasBoundedHeight)
                          Expanded(child: results)
                        else
                          results,
                      ],
                    );
                  },
                ),
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
  String? _filePath;
  bool _loading = true;
  bool _openingExternal = false;
  bool _openFailed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load({String versionId = ''}) async {
    setState(() {
      _loading = true;
      _openFailed = false;
    });
    final versions = await widget.viewModel.artifactVersions(_entry);
    final read = await widget.viewModel.previewArtifact(
      _entry,
      versionId: versionId,
    );
    final references = await widget.viewModel.artifactMessageReferences(
      _entry,
      versionId: read?.version.id ?? versionId,
    );
    final mimeType =
        read?.version.mimeType.toLowerCase().split(';').first.trim();
    final filePath =
        read == null || mimeType?.startsWith('image/') != true
            ? null
            : await widget.viewModel.prepareArtifactFile(
              _entry,
              versionId: read.version.id,
            );
    if (!mounted) return;
    setState(() {
      _versions = versions;
      _references = references;
      _read = read;
      _filePath = filePath;
      _loading = false;
    });
  }

  Future<void> _openExternally() async {
    setState(() {
      _openingExternal = true;
      _openFailed = false;
    });
    final opened = await widget.viewModel.openArtifact(
      _entry,
      versionId: _read?.version.id ?? '',
    );
    if (!mounted) return;
    setState(() {
      _openingExternal = false;
      _openFailed = !opened;
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
    final window = MediaQuery.sizeOf(context);
    final content = SizedBox(
      width: (window.width - 64).clamp(280.0, 720.0).toDouble(),
      height: (window.height - 160).clamp(320.0, 520.0).toDouble(),
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
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        ProjectActionButton(
                          key: const ValueKey<String>('artifact-open-external'),
                          onPressed:
                              _openingExternal
                                  ? null
                                  : () => unawaited(_openExternally()),
                          leading:
                              _openingExternal
                                  ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(
                                    LucideIcons.externalLink,
                                    size: 16,
                                  ),
                          label: copy.openInSystemApp,
                          variant: ProjectActionVariant.outline,
                        ),
                        if (read?.text != null &&
                            read?.version.id ==
                                _entry.artifact.currentVersionId)
                          ProjectActionButton(
                            key: const ValueKey<String>(
                              'artifact-write-version',
                            ),
                            onPressed: () => unawaited(_writeVersion()),
                            leading: const Icon(LucideIcons.pencil, size: 16),
                            label: copy.writeNewVersion,
                            variant: ProjectActionVariant.outline,
                          ),
                      ],
                    ),
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
                          return Material(
                            type: MaterialType.transparency,
                            child: ListTile(
                              dense: true,
                              title: Text(
                                '#${reference.messageSequence} · $actor',
                              ),
                              subtitle: Text(
                                reference.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                  Expanded(
                    child: ProjectArtifactPreview(
                      read: read,
                      filePath: _filePath,
                    ),
                  ),
                  if (read != null && !read.endOfFile && read.text != null)
                    Text(copy.previewTruncated),
                  if (_openFailed)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        copy.unableToOpenArtifact,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
    );
    final actions = <Widget>[
      ProjectActionButton(
        onPressed: () => Navigator.pop(context),
        label: copy.close,
      ),
    ];
    if (hasShadProjectTheme(context)) {
      return HyveDialog(
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
