import 'package:flutter/widgets.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/view_models/project_agent_activity.dart';

/// Feature-local copy with an English fallback for every non-Chinese locale.
///
/// The project workspace is intentionally self-contained while it is being
/// migrated from the legacy Chat surface. Keeping these strings typed avoids
/// leaking raw status/error codes into user-facing copy.
final class ProjectLocalizations {
  const ProjectLocalizations._(this.isChinese);

  factory ProjectLocalizations.of(BuildContext context) =>
      ProjectLocalizations._(
        Localizations.localeOf(context).languageCode == 'zh',
      );

  final bool isChinese;

  String _text(String english, String chinese) => isChinese ? chinese : english;

  String get workspace => _text('Project workspace', '项目工作区');
  String get artifacts => _text('Project artifacts', '项目产物');
  String get members => _text('Project members', '项目成员');
  String get execution => _text('Execution details', '执行详情');
  String get close => _text('Close', '关闭');
  String get cancel => _text('Cancel', '取消');
  String get create => _text('Create', '创建');
  String get save => _text('Save', '保存');
  String get delete => _text('Delete', '删除');
  String get search => _text('Search', '搜索');
  String get retry => _text('Retry', '重试');
  String get unknown => _text('unknown', '未知');
  String get user => _text('User', '用户');
  String get agent => _text('Agent', '智能体');
  String get system => _text('System', '系统');
  String get noAgentsNotice => _text(
    'This project has no active agents. Messages are saved, but no reply will be generated.',
    '当前项目没有活跃智能体；消息会被保存，但不会产生回复。',
  );
  String get emptyTimeline => _text(
    'Send a message to start collaborating. Messages without @ are broadcast.',
    '发送消息开始协作；不使用 @ 时将广播。',
  );
  String get loadingWorkspace => _text('Loading project', '正在加载项目');
  String get loadEarlierEvents => _text('Load earlier events', '加载更早事件');
  String get broadcastHint => _text(
    'Type a message. Without @ it will be broadcast to all active agents.',
    '输入消息；不选择 @ 时将广播给全部活跃智能体。',
  );
  String attachment(int index) => _text('Attachment $index', '附件 $index');
  String get addAttachment => _text('Add attachment', '添加附件');
  String get saveAsProjectArtifact =>
      _text('Save as a Project artifact', '保存为项目正式产物');
  String get savedAsProjectArtifact =>
      _text('Will be saved as a Project artifact', '将保存为项目正式产物');
  String get dropFilesToImport =>
      _text('Drop files here to import', '拖放文件到此处导入');
  String get releaseToImport => _text('Release to import', '松开即可导入');
  String versionProvenance(int version, String actorId, String runId) => _text(
    'Version $version · agent ${actorId.isEmpty ? 'system' : actorId}'
        '${runId.isEmpty ? '' : ' · run $runId'}',
    '版本 $version · 智能体 ${actorId.isEmpty ? '系统' : actorId}'
        '${runId.isEmpty ? '' : ' · 运行 $runId'}',
  );
  String referencingMessages(int count) =>
      _text('$count referencing messages', '$count 条引用消息');
  String get stopRuns => _text('Stop active runs', '停止运行');
  String get send => _text('Send', '发送');
  String activity(ProjectAgentActivity activity) => switch (activity) {
    ProjectAgentActivity.idle => _text('Caught up', '已跟上'),
    ProjectAgentActivity.deciding => _text('Deciding', '判断中'),
    ProjectAgentActivity.willReply => _text('Will reply', '将回复'),
    ProjectAgentActivity.skipped => _text('Skipped', '已跳过'),
    ProjectAgentActivity.replying => _text('Replying', '回复中'),
    ProjectAgentActivity.catchingUp => _text('Catching up', '追赶中'),
    ProjectAgentActivity.paused => _text('Paused', '已暂停'),
    ProjectAgentActivity.failed => _text('Failed', '失败'),
  };
  String processed(int processed, int latest) => _text(
    'Processed $processed / latest $latest',
    '已处理 $processed / 最新 $latest',
  );
  String backlog(int count) => _text('$count pending', '积压 $count');
  String get noParticipant => _text(
    'No agent needed to add anything to this message.',
    '本条消息没有智能体需要补充。',
  );
  String replyingTo(int sequence) =>
      _text('Replying to message #$sequence', '回复消息 #$sequence');
  String get requestedPublicReply => _text('Public reply requested', '请求公开回复');
  String artifactVersions(Iterable<String> ids) =>
      _text('Artifact versions: ${ids.join(', ')}', '产物版本：${ids.join('，')}');
  String get auditDetails => _text('Audit details', '审计详情');
  String eventId(String id) => _text('Event: $id', '事件：$id');
  String turnId(String id, String status) =>
      _text('Turn: $id · $status', '轮次：$id · $status');
  String sourceRun(String id) => _text('Source run: $id', '来源运行：$id');
  String deliveryRun(String id, String status) =>
      _text('Delivery run: $id · $status', '交付运行：$id · $status');
  String rootRun(String id) => _text('Root run: $id', '根运行：$id');
  String deliveryDepth(int depth) =>
      _text('Delivery depth: $depth', '交付深度：$depth');
  String targetRuns(String value) =>
      _text('Target runs: $value', '目标运行：$value');
  String routeError(String code) => switch (code) {
    'project_message_target_not_active' => _text(
      'A mentioned agent is no longer active. Remove or select it again.',
      '被 @ 的智能体已不在项目中，请删除或重新选择。',
    ),
    _ => _text('Message failed to send ($code)', '消息发送失败（$code）'),
  };

  String get newTextArtifact => _text('New text artifact', '新建文本产物');
  String get relativePath => _text('Project-relative path', '项目内相对路径');
  String get content => _text('Content', '内容');
  String get moveOrRename => _text('Move or rename', '移动或重命名');
  String get deleteArtifact => _text('Delete artifact?', '删除产物？');
  String deleteArtifactDescription(String path) => _text(
    'Delete every version of $path? Artifacts referenced by a message or delivery cannot be deleted.',
    '将删除 $path 的全部版本。已被消息或交付引用的产物不会被删除。',
  );
  String get searchArtifacts =>
      _text('Search name, path, and content', '搜索名称、路径和正文');
  String get allTypes => _text('All types', '全部类型');
  String get importFiles => _text('Import files', '批量导入');
  String get createText => _text('New text', '新建文本');
  String get noArtifacts => _text('No matching project artifacts', '暂无匹配的项目产物');
  String get previewAndHistory =>
      _text('Preview and version history', '预览与版本历史');
  String get writeNewVersion => _text('Write new version', '写入新版本');
  String get createVersion => _text('Create version', '创建版本');
  String source(String value) => _text('Source: $value', '来源：$value');
  String get unableToReadVersion =>
      _text('Unable to read this version', '无法读取此版本');
  String unsupportedPreview(String mime, String digest) => _text(
    'Text preview is not supported for this type.\nMIME: $mime\nSHA-256: $digest',
    '该类型不支持文本预览。\nMIME：$mime\nSHA-256：$digest',
  );
  String get previewTruncated => _text(
    'Only the first 32 KiB is shown. Agents can continue reading in chunks.',
    '预览仅显示前 32 KiB；智能体可按块继续读取。',
  );
  String actorSource(ProjectArtifact artifact) => switch (artifact
      .createdByType) {
    ProjectArtifactActorType.user => user,
    ProjectArtifactActorType.agent =>
      artifact.createdById.isEmpty
          ? agent
          : _text(
            'Agent ${artifact.createdById}',
            '智能体 ${artifact.createdById}',
          ),
    ProjectArtifactActorType.system => system,
  };
  String artifactKind(ProjectArtifactKind kind) => switch (kind) {
    ProjectArtifactKind.attachment => _text('Attachment', '附件'),
    ProjectArtifactKind.document => _text('Document', '文档'),
    ProjectArtifactKind.code => _text('Code', '代码'),
    ProjectArtifactKind.image => _text('Image', '图片'),
    ProjectArtifactKind.audio => _text('Audio', '音频'),
    ProjectArtifactKind.video => _text('Video', '视频'),
    ProjectArtifactKind.dataset => _text('Dataset', '数据'),
    ProjectArtifactKind.archive => _text('Archive', '压缩包'),
    ProjectArtifactKind.generated => _text('Generated', '生成内容'),
    ProjectArtifactKind.other => _text('Other', '其他'),
  };
  String artifactError(String code) => switch (code) {
    'artifact_path_invalid' => _text(
      'Use a valid project-relative path.',
      '路径无效；请使用项目内相对路径。',
    ),
    'artifact_path_conflict' => _text(
      'That project path already exists.',
      '该项目路径已存在。',
    ),
    'artifact_size_limit_exceeded' => _text(
      'The file exceeds the artifact size limit.',
      '文件超过项目产物大小限制。',
    ),
    'artifact_is_referenced' => _text(
      'This artifact is referenced and cannot be deleted.',
      '产物已被消息或交付引用，不能删除。',
    ),
    'artifact_version_conflict' => _text(
      'The current version changed. Reopen it before editing.',
      '当前版本已变化，请重新打开后再编辑。',
    ),
    'artifact_source_symlink_rejected' => _text(
      'Symbolic links cannot be imported.',
      '不允许导入符号链接。',
    ),
    _ => _text('Artifact operation failed ($code)', '产物操作失败（$code）'),
  };

  String get searchAgents => _text('Search agents', '搜索智能体');
  String get addAgent => _text('Add agent', '添加智能体');
  String get noMembers => _text('No project members yet', '项目暂无成员');
  String get noAvailableAgents =>
      _text('No agents are available to add', '没有可添加的智能体');
  String get deletedAgent => _text('Deleted agent', '已删除的智能体');
  String get pause => _text('Pause', '暂停');
  String get resume => _text('Resume', '恢复');
  String get remove => _text('Remove', '移除');
  String get storageAccess => _text('Artifact access', '产物权限');
  String storageAccessName(ProjectStorageAccess access) => switch (access) {
    ProjectStorageAccess.none => _text('None', '无'),
    ProjectStorageAccess.read => _text('Read', '只读'),
    ProjectStorageAccess.readWrite => _text('Read & write', '读写'),
  };
  String removeMemberTitle(String name) => _text('Remove $name?', '移除 $name？');
  String removeMemberDescription(bool hasActiveRun) =>
      hasActiveRun
          ? _text(
            'The agent has an active run. Removing it cancels that run; other agents continue.',
            '该智能体正在运行。移除会取消它的当前运行，其他智能体不受影响。',
          )
          : _text(
            'The agent will stop receiving new project messages.',
            '该智能体将不再接收新的项目消息。',
          );
  String memberError(String code) =>
      _text('Member update failed ($code)', '成员更新失败（$code）');

  String get totalRuns => _text('Runs', '运行');
  String get decisions => _text('Decisions', '判断');
  String get passed => _text('Passed', '已跳过');
  String get tokenUsage => _text('Token usage', 'Token 用量');
  String tokens(int input, int output) =>
      _text('Input $input · output $output', '输入 $input · 输出 $output');
  String get noExecutions => _text('No execution records yet', '暂无执行记录');
  String get cancelRun => _text('Cancel run', '取消运行');
  String get cancelTurn => _text('Cancel turn', '取消轮次');
  String get cancelRootChain => _text('Cancel root chain', '取消根消息链');
  String get contextReport => _text('Context report', '上下文报告');
  String get auditEvents => _text('Audit events', '审计事件');
  String get summarySegments => _text('Summary segments', '摘要片段');
  String get memories => _text('Agent memories', '智能体记忆');
  String get artifactVersionIds => _text('Artifact versions', '产物版本');
  String get skills => _text('Skills', '技能');
  String get tools => _text('Tools', '工具');
  String get active => _text('Active', '活跃');
  String get pausedStatus => _text('Paused', '已暂停');
  String runStatus(String phase, String status) => '$phase · $status';
  String duration(String value) => _text('Duration: $value', '耗时：$value');
  String errorCode(String value) => _text('Error: $value', '错误码：$value');
  String identifiers(String label, Iterable<String> values) =>
      '$label: ${values.isEmpty ? '-' : values.join(', ')}';
}
