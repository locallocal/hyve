import 'package:flutter/material.dart';
import 'package:hyve/domain/models/models.dart';

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
    this.hintText = '输入消息；不选择 @ 时将广播给全部智能体',
  });

  final StructuredProjectMessageController controller;
  final List<Agent> activeAgents;
  final List<PendingAttachment> attachments;
  final ValueChanged<ProjectMessageDraft> onSend;
  final int activeRunCount;
  final VoidCallback? onCancelRuns;
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (candidates.isNotEmpty)
          Material(
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
                    onTap: () {
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
                    },
                  ),
              ],
            ),
          ),
        TextField(
          key: const ValueKey<String>('project-message-field'),
          controller: widget.controller,
          focusNode: _focusNode,
          minLines: 2,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.activeRunCount > 0 && widget.onCancelRuns != null)
                  IconButton(
                    key: const ValueKey<String>('project-cancel-runs'),
                    tooltip: '停止运行',
                    onPressed: widget.onCancelRuns,
                    icon: const Icon(Icons.stop_rounded),
                  ),
                IconButton(
                  key: const ValueKey<String>('project-send-message'),
                  tooltip: '发送',
                  onPressed: _canSend ? _send : null,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
          onSubmitted: (_) => _send(),
        ),
      ],
    );
  }
}

int _compareSpans(MentionSpan left, MentionSpan right) =>
    left.start.compareTo(right.start);
