import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/view_models/project_workspace_view_model.dart';

final class ProjectArtifactsPanel extends StatelessWidget {
  const ProjectArtifactsPanel({super.key, required this.viewModel});

  final ProjectWorkspaceViewModel viewModel;

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

  final ProjectWorkspaceViewModel viewModel;
  final bool embedded;

  @override
  State<ProjectArtifactsDialog> createState() => _ProjectArtifactsDialogState();
}

enum _ArtifactAction { preview, rename, delete }

final class _ProjectArtifactsDialogState extends State<ProjectArtifactsDialog> {
  final TextEditingController _search = TextEditingController();
  ProjectArtifactKind? _kind;

  @override
  void initState() {
    super.initState();
    unawaited(widget.viewModel.refreshArtifacts());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(copy.newTextArtifact),
            content: SizedBox(
              width: 600,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    key: const ValueKey<String>('artifact-new-path'),
                    controller: pathController,
                    decoration: InputDecoration(
                      labelText: copy.relativePath,
                      hintText: 'documents/notes.md',
                    ),
                  ),
                  const SizedBox(height: 12),
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(copy.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(copy.create),
              ),
            ],
          ),
    );
    if (accepted == true && mounted) {
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
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(copy.moveOrRename),
            content: TextField(
              key: const ValueKey<String>('artifact-move-path'),
              controller: controller,
              decoration: InputDecoration(labelText: copy.relativePath),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(copy.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(copy.save),
              ),
            ],
          ),
    );
    if (accepted == true && mounted) {
      await widget.viewModel.moveArtifact(entry, controller.text);
    }
    controller.dispose();
  }

  Future<void> _delete(ProjectArtifactEntry entry) async {
    final copy = ProjectLocalizations.of(context);
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(copy.deleteArtifact),
            content: Text(
              copy.deleteArtifactDescription(entry.artifact.relativePath),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(copy.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(copy.delete),
              ),
            ],
          ),
    );
    if (accepted == true && mounted) {
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
    showDialog<void>(
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
    final content = ConstrainedBox(
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
                    Text(
                      copy.artifacts,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    if (!widget.embedded)
                      IconButton(
                        tooltip: copy.close,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 320,
                      child: TextField(
                        key: const ValueKey<String>('artifact-search-field'),
                        controller: _search,
                        decoration: InputDecoration(
                          labelText: copy.searchArtifacts,
                          suffixIcon: IconButton(
                            tooltip: copy.search,
                            onPressed: () => unawaited(_applyFilter()),
                            icon: const Icon(Icons.search),
                          ),
                        ),
                        onSubmitted: (_) => unawaited(_applyFilter()),
                      ),
                    ),
                    DropdownButton<ProjectArtifactKind?>(
                      key: const ValueKey<String>('artifact-kind-filter'),
                      value: _kind,
                      hint: Text(copy.allTypes),
                      items: [
                        DropdownMenuItem<ProjectArtifactKind?>(
                          value: null,
                          child: Text(copy.allTypes),
                        ),
                        for (final kind in ProjectArtifactKind.values)
                          DropdownMenuItem<ProjectArtifactKind?>(
                            value: kind,
                            child: Text(copy.artifactKind(kind)),
                          ),
                      ],
                      onChanged: (kind) {
                        setState(() => _kind = kind);
                        unawaited(_applyFilter());
                      },
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey<String>('artifact-import-button'),
                      onPressed:
                          viewModel.artifactBusy
                              ? null
                              : () =>
                                  unawaited(viewModel.importPickedArtifacts()),
                      icon: const Icon(Icons.upload_file_outlined),
                      label: Text(copy.importFiles),
                    ),
                    FilledButton.icon(
                      key: const ValueKey<String>('artifact-create-button'),
                      onPressed:
                          viewModel.artifactBusy
                              ? null
                              : () => unawaited(_createText()),
                      icon: const Icon(Icons.note_add_outlined),
                      label: Text(copy.createText),
                    ),
                  ],
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
                          ? Center(child: Text(copy.noArtifacts))
                          : ListView.separated(
                            key: const ValueKey<String>('artifact-list'),
                            itemCount: viewModel.artifacts.length,
                            separatorBuilder:
                                (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final entry = viewModel.artifacts[index];
                              final artifact = entry.artifact;
                              final version = entry.currentVersion;
                              return ListTile(
                                key: ValueKey<String>(
                                  'project-artifact-${artifact.id}',
                                ),
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
                                trailing: PopupMenuButton<_ArtifactAction>(
                                  onSelected:
                                      (action) => _handleAction(action, entry),
                                  itemBuilder:
                                      (_) => [
                                        PopupMenuItem(
                                          value: _ArtifactAction.preview,
                                          child: Text(copy.previewAndHistory),
                                        ),
                                        PopupMenuItem(
                                          value: _ArtifactAction.rename,
                                          child: Text(copy.moveOrRename),
                                        ),
                                        PopupMenuItem(
                                          value: _ArtifactAction.delete,
                                          child: Text(copy.delete),
                                        ),
                                      ],
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
    );
    return widget.embedded ? content : Dialog(child: content);
  }
}

final class ProjectArtifactPreviewDialog extends StatefulWidget {
  const ProjectArtifactPreviewDialog({
    super.key,
    required this.viewModel,
    required this.entry,
  });

  final ProjectWorkspaceViewModel viewModel;
  final ProjectArtifactEntry entry;

  @override
  State<ProjectArtifactPreviewDialog> createState() =>
      _ProjectArtifactPreviewDialogState();
}

final class _ProjectArtifactPreviewDialogState
    extends State<ProjectArtifactPreviewDialog> {
  late ProjectArtifactEntry _entry = widget.entry;
  List<ProjectArtifactVersion> _versions = const [];
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
    if (!mounted) return;
    setState(() {
      _versions = versions;
      _read = read;
      _loading = false;
    });
  }

  Future<void> _writeVersion() async {
    final current = _read;
    if (current?.text == null) return;
    final copy = ProjectLocalizations.of(context);
    final controller = TextEditingController(text: current!.text);
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(copy.writeNewVersion),
            content: SizedBox(
              width: 640,
              child: TextField(
                key: const ValueKey<String>('artifact-version-content'),
                controller: controller,
                minLines: 12,
                maxLines: 24,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(copy.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(copy.createVersion),
              ),
            ],
          ),
    );
    if (accepted == true && mounted) {
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
    return AlertDialog(
      title: Text(_entry.artifact.relativePath),
      content: SizedBox(
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
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final version in _versions)
                          ChoiceChip(
                            label: Text(
                              'v${version.versionNumber} · '
                              '${version.byteLength} B',
                            ),
                            selected: read?.version.id == version.id,
                            onSelected:
                                (_) => unawaited(_load(versionId: version.id)),
                          ),
                      ],
                    ),
                    const Divider(),
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
      ),
      actions: [
        if (read?.text != null &&
            read?.version.id == _entry.artifact.currentVersionId)
          TextButton.icon(
            key: const ValueKey<String>('artifact-write-version'),
            onPressed: () => unawaited(_writeVersion()),
            icon: const Icon(Icons.edit_note_outlined),
            label: Text(copy.writeNewVersion),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(copy.close),
        ),
      ],
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
