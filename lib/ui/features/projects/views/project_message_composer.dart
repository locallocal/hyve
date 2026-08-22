import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

final class StructuredProjectMessageController extends TextEditingController {
  StructuredProjectMessageController({
    super.text,
    Iterable<MentionSpan> mentions = const <MentionSpan>[],
  }) : _mentions = mentions.toList()..sort(_compareSpans) {
    ProjectMessageDraft(text: text, mentions: _mentions);
  }

  final List<MentionSpan> _mentions;
  bool _applyingStructuredEdit = false;

  List<MentionSpan> get mentions => List<MentionSpan>.unmodifiable(_mentions);

  ProjectMessageDraft draft({
    Iterable<PendingAttachment> attachments = const <PendingAttachment>[],
  }) => ProjectMessageDraft(
    text: text,
    mentions: _mentions,
    attachments: attachments,
  );

  @override
  set value(TextEditingValue newValue) {
    final previousText = text;
    super.value = newValue;
    if (!_applyingStructuredEdit && previousText != newValue.text) {
      _reconcileTextEdit(previousText, newValue.text);
    }
  }

  void insertMention({required Agent agent, required TextRange replaceRange}) {
    if (!replaceRange.isValid ||
        replaceRange.start < 0 ||
        replaceRange.end > text.length) {
      throw ArgumentError.value(replaceRange, 'replaceRange');
    }
    final displayText = '@${agent.name}';
    final replacement = '$displayText ';
    final oldText = text;
    _applyEdit(replaceRange.start, replaceRange.end, replacement.length);
    _mentions.add(
      MentionSpan(
        agentId: agent.id,
        start: replaceRange.start,
        length: displayText.length,
        displayTextSnapshot: displayText,
      ),
    );
    _mentions.sort(_compareSpans);
    final nextText = oldText.replaceRange(
      replaceRange.start,
      replaceRange.end,
      replacement,
    );
    _applyingStructuredEdit = true;
    value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(
        offset: replaceRange.start + replacement.length,
      ),
    );
    _applyingStructuredEdit = false;
  }

  /// Converts only unambiguous plain-text mentions. Duplicate display names
  /// remain plain text and never guess an Agent id.
  void convertUniquePlainTextMentions(Iterable<Agent> activeAgents) {
    final byName = <String, List<Agent>>{};
    for (final agent in activeAgents) {
      final name = agent.name.trim();
      if (name.isEmpty) continue;
      byName.putIfAbsent(name.toLowerCase(), () => <Agent>[]).add(agent);
    }
    final unique = <Agent>[
      for (final entries in byName.values)
        if (entries.length == 1) entries.single,
    ]..sort((left, right) => right.name.length.compareTo(left.name.length));
    final occupied = <int>{
      for (final mention in _mentions)
        for (var offset = mention.start; offset < mention.end; offset++) offset,
    };
    for (final agent in unique) {
      final expression = RegExp(
        '(^|\\s)@${RegExp.escape(agent.name.trim())}'
        r'(?=\s|[，。！？、,.!?;；:]|$)',
        caseSensitive: false,
        multiLine: true,
      );
      for (final match in expression.allMatches(text)) {
        final start = match.start + (match.group(1)?.length ?? 0);
        final display = text.substring(start, match.end);
        final end = start + display.length;
        if ([for (var i = start; i < end; i++) i].any(occupied.contains)) {
          continue;
        }
        _mentions.add(
          MentionSpan(
            agentId: agent.id,
            start: start,
            length: display.length,
            displayTextSnapshot: display,
          ),
        );
        for (var i = start; i < end; i++) {
          occupied.add(i);
        }
      }
    }
    _mentions.sort(_compareSpans);
  }

  void removeMentionsForInactiveAgents(Set<String> activeAgentIds) {
    _mentions.removeWhere(
      (mention) => !activeAgentIds.contains(mention.agentId),
    );
  }

  void _reconcileTextEdit(String oldText, String newText) {
    var prefix = 0;
    final shortest =
        oldText.length < newText.length ? oldText.length : newText.length;
    while (prefix < shortest && oldText[prefix] == newText[prefix]) {
      prefix++;
    }
    var suffix = 0;
    while (suffix < shortest - prefix &&
        oldText[oldText.length - suffix - 1] ==
            newText[newText.length - suffix - 1]) {
      suffix++;
    }
    _applyEdit(
      prefix,
      oldText.length - suffix,
      newText.length - prefix - suffix,
    );
  }

  void _applyEdit(int oldStart, int oldEnd, int replacementLength) {
    final delta = replacementLength - (oldEnd - oldStart);
    final retained = <MentionSpan>[];
    for (final mention in _mentions) {
      if (mention.end <= oldStart) {
        retained.add(mention);
      } else if (mention.start >= oldEnd) {
        retained.add(mention.shifted(delta));
      }
    }
    _mentions
      ..clear()
      ..addAll(retained);
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final children = <InlineSpan>[];
    var offset = 0;
    for (final mention in _mentions) {
      if (mention.start > text.length || mention.end > text.length) {
        continue;
      }
      if (mention.start > offset) {
        children.add(TextSpan(text: text.substring(offset, mention.start)));
      }
      children.add(
        TextSpan(
          text: text.substring(mention.start, mention.end),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      offset = mention.end;
    }
    if (offset < text.length) {
      children.add(TextSpan(text: text.substring(offset)));
    }
    return TextSpan(style: style, children: children);
  }
}

final class ProjectMessageComposer extends StatefulWidget {
  const ProjectMessageComposer({
    super.key,
    required this.controller,
    required this.activeAgents,
    required this.onSend,
    this.attachments = const <PendingAttachment>[],
    this.activeRunCount = 0,
    this.onCancelRuns,
    this.onPickAttachment,
    this.onRemoveAttachment,
    this.onToggleAttachmentPromotion,
    this.hintText = '',
  });

  final StructuredProjectMessageController controller;
  final List<Agent> activeAgents;
  final List<PendingAttachment> attachments;
  final ValueChanged<ProjectMessageDraft> onSend;
  final int activeRunCount;
  final VoidCallback? onCancelRuns;
  final VoidCallback? onPickAttachment;
  final ValueChanged<int>? onRemoveAttachment;
  final void Function(int index, bool promote)? onToggleAttachmentPromotion;
  final String hintText;

  @override
  State<ProjectMessageComposer> createState() => _ProjectMessageComposerState();
}

final class _ProjectMessageComposerState extends State<ProjectMessageComposer> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant ProjectMessageComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _focusNode.dispose();
    super.dispose();
  }

  void _changed() {
    widget.controller.convertUniquePlainTextMentions(widget.activeAgents);
    if (mounted) setState(() {});
  }

  ({int start, String query})? get _mentionQuery {
    final selection = widget.controller.selection;
    if (!selection.isValid || !selection.isCollapsed) return null;
    final cursor = selection.baseOffset;
    if (cursor < 0 || cursor > widget.controller.text.length) return null;
    final before = widget.controller.text.substring(0, cursor);
    final start = before.lastIndexOf('@');
    if (start < 0 ||
        (start > 0 && !RegExp(r'\s').hasMatch(before[start - 1]))) {
      return null;
    }
    final query = before.substring(start + 1);
    if (query.contains(RegExp(r'\s'))) return null;
    return (start: start, query: query.toLowerCase());
  }

  List<Agent> get _candidates {
    final query = _mentionQuery;
    if (query == null) return const <Agent>[];
    return widget.activeAgents
        .where((agent) => agent.name.toLowerCase().contains(query.query))
        .take(6)
        .toList(growable: false);
  }

  bool get _canSend =>
      widget.controller.text.trim().isNotEmpty || widget.attachments.isNotEmpty;

  void _send() {
    if (!_canSend) return;
    widget.onSend(widget.controller.draft(attachments: widget.attachments));
  }

  @override
  Widget build(BuildContext context) {
    final candidates = _candidates;
    final copy = ProjectLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (candidates.isNotEmpty)
          _MentionSuggestions(
            candidates: candidates,
            onSelected: _selectMention,
          ),
        if (widget.attachments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AttachmentList(
              attachments: widget.attachments,
              copy: copy,
              onToggle: widget.onToggleAttachmentPromotion,
              onRemove: widget.onRemoveAttachment,
            ),
          ),
        CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.enter, control: true):
                _send,
            const SingleActivator(LogicalKeyboardKey.enter, meta: true): _send,
          },
          child: ProjectSurfaceCard(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasShadProjectTheme(context))
                  ShadTextarea(
                    key: const ValueKey<String>('project-message-field'),
                    controller: widget.controller,
                    focusNode: _focusNode,
                    placeholder: Text(
                      widget.hintText.isEmpty
                          ? copy.broadcastHint
                          : widget.hintText,
                    ),
                    minHeight: 72,
                    maxHeight: 180,
                    resizable: false,
                    onSubmitted: (_) => _send(),
                  )
                else
                  TextField(
                    key: const ValueKey<String>('project-message-field'),
                    controller: widget.controller,
                    focusNode: _focusNode,
                    minLines: 2,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText:
                          widget.hintText.isEmpty
                              ? copy.broadcastHint
                              : widget.hintText,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                const SizedBox(height: 8),
                _ComposerToolbar(
                  canSend: _canSend,
                  activeRunCount: widget.activeRunCount,
                  copy: copy,
                  onPickAttachment: widget.onPickAttachment,
                  onCancelRuns: widget.onCancelRuns,
                  onSend: _send,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _selectMention(Agent agent) {
    final query = _mentionQuery;
    if (query == null) return;
    widget.controller.insertMention(
      agent: agent,
      replaceRange: TextRange(
        start: query.start,
        end: widget.controller.selection.baseOffset,
      ),
    );
    _focusNode.requestFocus();
  }
}

final class _MentionSuggestions extends StatelessWidget {
  const _MentionSuggestions({
    required this.candidates,
    required this.onSelected,
  });

  final List<Agent> candidates;
  final ValueChanged<Agent> onSelected;

  @override
  Widget build(BuildContext context) {
    if (hasShadProjectTheme(context)) {
      return ProjectSurfaceCard(
        key: const ValueKey<String>('project-mention-suggestions'),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final agent in candidates)
              ShadButton.ghost(
                key: ValueKey<String>('project-mention-${agent.id}'),
                leading: const Icon(LucideIcons.bot, size: 16),
                mainAxisAlignment: MainAxisAlignment.start,
                onPressed: () => onSelected(agent),
                child: Text(agent.name),
              ),
          ],
        ),
      );
    }
    return Material(
      key: const ValueKey<String>('project-mention-suggestions'),
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final agent in candidates)
            ListTile(
              key: ValueKey<String>('project-mention-${agent.id}'),
              dense: true,
              title: Text(agent.name),
              onTap: () => onSelected(agent),
            ),
        ],
      ),
    );
  }
}

final class _AttachmentList extends StatelessWidget {
  const _AttachmentList({
    required this.attachments,
    required this.copy,
    required this.onToggle,
    required this.onRemove,
  });

  final List<PendingAttachment> attachments;
  final ProjectLocalizations copy;
  final void Function(int index, bool promote)? onToggle;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Wrap(
      key: const ValueKey<String>('project-message-attachments'),
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var index = 0; index < attachments.length; index++)
          _AttachmentChip(
            key: ValueKey<String>('project-attachment-$index'),
            attachment: attachments[index],
            label:
                attachments[index].displayName.isEmpty
                    ? copy.attachment(index + 1)
                    : attachments[index].displayName,
            tooltip:
                attachments[index].promoteToProjectArtifact
                    ? copy.savedAsProjectArtifact
                    : copy.saveAsProjectArtifact,
            removeLabel: copy.remove,
            onToggle:
                onToggle == null
                    ? null
                    : (selected) => onToggle!(index, selected),
            onRemove: onRemove == null ? null : () => onRemove!(index),
          ),
      ],
    ),
  );
}

final class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    super.key,
    required this.attachment,
    required this.label,
    required this.tooltip,
    required this.removeLabel,
    required this.onToggle,
    required this.onRemove,
  });

  final PendingAttachment attachment;
  final String label;
  final String tooltip;
  final String removeLabel;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final promoted = attachment.promoteToProjectArtifact;
    if (hasShadProjectTheme(context)) {
      return Semantics(
        label: '$label, $tooltip',
        selected: promoted,
        child: ShadTooltip(
          builder: (_) => Text(tooltip),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShadBadge.raw(
                variant:
                    promoted
                        ? ShadBadgeVariant.secondary
                        : ShadBadgeVariant.outline,
                onPressed: onToggle == null ? null : () => onToggle!(!promoted),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      promoted ? LucideIcons.folderKanban : LucideIcons.file,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              if (onRemove != null)
                ProjectIconAction(
                  icon: LucideIcons.x,
                  label: removeLabel,
                  onPressed: onRemove,
                ),
            ],
          ),
        ),
      );
    }
    return Tooltip(
      message: tooltip,
      child: InputChip(
        selected: promoted,
        avatar: Icon(
          promoted ? Icons.inventory_2_outlined : Icons.attach_file,
          size: 16,
        ),
        label: Text(label),
        onSelected: onToggle,
        onDeleted: onRemove,
      ),
    );
  }
}

final class _ComposerToolbar extends StatelessWidget {
  const _ComposerToolbar({
    required this.canSend,
    required this.activeRunCount,
    required this.copy,
    required this.onPickAttachment,
    required this.onCancelRuns,
    required this.onSend,
  });

  final bool canSend;
  final int activeRunCount;
  final ProjectLocalizations copy;
  final VoidCallback? onPickAttachment;
  final VoidCallback? onCancelRuns;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.end,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 8,
    runSpacing: 8,
    children: [
      if (onPickAttachment != null)
        ProjectActionButton(
          key: const ValueKey<String>('project-pick-attachment'),
          label: copy.addAttachment,
          onPressed: onPickAttachment,
          variant: ProjectActionVariant.ghost,
          leading: const Icon(LucideIcons.paperclip, size: 16),
        ),
      if (activeRunCount > 0 && onCancelRuns != null)
        ProjectActionButton(
          key: const ValueKey<String>('project-cancel-runs'),
          label: copy.stopRuns,
          onPressed: onCancelRuns,
          variant: ProjectActionVariant.outline,
          leading: const Icon(LucideIcons.square, size: 16),
        ),
      ProjectActionButton(
        key: const ValueKey<String>('project-send-message'),
        label: copy.send,
        onPressed: canSend ? onSend : null,
        leading: const Icon(LucideIcons.send, size: 16),
      ),
    ],
  );
}

int _compareSpans(MentionSpan left, MentionSpan right) =>
    left.start.compareTo(right.start);
