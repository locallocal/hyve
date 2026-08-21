import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/view_models/project_workspace_view_model.dart';

final class ProjectArtifactsDialog extends StatefulWidget {
  const ProjectArtifactsDialog({super.key, required this.viewModel});

  final ProjectWorkspaceViewModel viewModel;

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
    final pathController = TextEditingController(text: 'documents/untitled.md');
    final contentController = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('新建文本产物'),
            content: SizedBox(
              width: 600,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    key: const ValueKey<String>('artifact-new-path'),
                    controller: pathController,
                    decoration: const InputDecoration(
                      labelText: '项目内相对路径',
                      hintText: 'documents/notes.md',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey<String>('artifact-new-content'),
                    controller: contentController,
                    minLines: 8,
                    maxLines: 16,
                    decoration: const InputDecoration(labelText: '内容'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('创建'),
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
    final controller = TextEditingController(text: entry.artifact.relativePath);
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('移动或重命名'),
            content: TextField(
              key: const ValueKey<String>('artifact-move-path'),
              controller: controller,
              decoration: const InputDecoration(labelText: '项目内相对路径'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('保存'),
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
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('删除产物？'),
            content: Text(
              '将删除 ${entry.artifact.relativePath} 的全部版本。'
              '已被消息或交付引用的产物不会被删除。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('删除'),
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
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 680),
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
                        '项目产物',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: '关闭',
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
                            labelText: '搜索名称、路径和正文',
                            suffixIcon: IconButton(
                              tooltip: '搜索',
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
                        hint: const Text('全部类型'),
                        items: [
                          const DropdownMenuItem<ProjectArtifactKind?>(
                            value: null,
                            child: Text('全部类型'),
                          ),
                          for (final kind in ProjectArtifactKind.values)
                            DropdownMenuItem<ProjectArtifactKind?>(
                              value: kind,
                              child: Text(_kindText(kind)),
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
                                    unawaited(viewModel.importPickedArtifact()),
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text('导入文件'),
                      ),
                      FilledButton.icon(
                        key: const ValueKey<String>('artifact-create-button'),
                        onPressed:
                            viewModel.artifactBusy
                                ? null
                                : () => unawaited(_createText()),
                        icon: const Icon(Icons.note_add_outlined),
                        label: const Text('新建文本'),
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
                        _artifactErrorText(viewModel.errorCode),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child:
                        viewModel.artifacts.isEmpty
                            ? const Center(child: Text('暂无匹配的项目产物'))
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
                                    '${_kindText(artifact.kind)} · '
                                    '${version.byteLength} B · '
                                    'v${version.versionNumber} · '
                                    '${_sourceText(artifact)}\n'
                                    '${version.contentDigest.substring(0, 12)}'
                                    '${entry.snippet.isEmpty ? '' : ' · ${entry.snippet}'}',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  isThreeLine: true,
                                  onTap: () => _preview(entry),
                                  trailing: PopupMenuButton<_ArtifactAction>(
                                    onSelected:
                                        (action) =>
                                            _handleAction(action, entry),
                                    itemBuilder:
                                        (_) => const [
                                          PopupMenuItem(
                                            value: _ArtifactAction.preview,
                                            child: Text('预览与版本历史'),
                                          ),
                                          PopupMenuItem(
                                            value: _ArtifactAction.rename,
                                            child: Text('移动或重命名'),
                                          ),
                                          PopupMenuItem(
                                            value: _ArtifactAction.delete,
                                            child: Text('删除'),
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
      ),
    );
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
    final controller = TextEditingController(text: current!.text);
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('写入新版本'),
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
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('创建版本'),
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
                      '来源：${_sourceText(_entry.artifact)}'
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
                              ? const Center(child: Text('无法读取此版本'))
                              : read.text == null
                              ? Center(
                                child: Text(
                                  '该类型不支持文本预览。\n'
                                  'MIME：${read.version.mimeType}\n'
                                  'SHA-256：${read.version.contentDigest}',
                                  textAlign: TextAlign.center,
                                ),
                              )
                              : SingleChildScrollView(
                                child: SelectableText(read.text!),
                              ),
                    ),
                    if (read != null && !read.endOfFile)
                      const Text('预览仅显示前 32 KiB；可由智能体按块继续读取。'),
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
            label: const Text('写入新版本'),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

String _sourceText(ProjectArtifact artifact) => switch (artifact
    .createdByType) {
  ProjectArtifactActorType.user => '用户',
  ProjectArtifactActorType.agent =>
    artifact.createdById.isEmpty ? '智能体' : '智能体 ${artifact.createdById}',
  ProjectArtifactActorType.system => '系统',
};

String _kindText(ProjectArtifactKind kind) => switch (kind) {
  ProjectArtifactKind.attachment => '附件',
  ProjectArtifactKind.document => '文档',
  ProjectArtifactKind.code => '代码',
  ProjectArtifactKind.image => '图片',
  ProjectArtifactKind.audio => '音频',
  ProjectArtifactKind.video => '视频',
  ProjectArtifactKind.dataset => '数据',
  ProjectArtifactKind.archive => '压缩包',
  ProjectArtifactKind.generated => '生成内容',
  ProjectArtifactKind.other => '其他',
};

IconData _kindIcon(ProjectArtifactKind kind) => switch (kind) {
  ProjectArtifactKind.image => Icons.image_outlined,
  ProjectArtifactKind.audio => Icons.audio_file_outlined,
  ProjectArtifactKind.video => Icons.video_file_outlined,
  ProjectArtifactKind.code => Icons.code,
  ProjectArtifactKind.dataset => Icons.table_chart_outlined,
  ProjectArtifactKind.archive => Icons.archive_outlined,
  _ => Icons.insert_drive_file_outlined,
};

String _artifactErrorText(String code) => switch (code) {
  'artifact_path_invalid' => '路径无效；请使用项目内相对路径。',
  'artifact_path_conflict' => '该项目路径已存在。',
  'artifact_size_limit_exceeded' => '文件超过项目产物大小限制。',
  'artifact_is_referenced' => '产物已被消息或交付引用，不能删除。',
  'artifact_version_conflict' => '当前版本已变化，请重新打开后再编辑。',
  'artifact_source_symlink_rejected' => '不允许导入符号链接。',
  _ => '产物操作失败（$code）',
};
