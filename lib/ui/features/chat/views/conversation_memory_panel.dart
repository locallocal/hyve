import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/use_cases/compact_conversation.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:stars/ui/features/chat/view_models/chat_generation_view_model.dart';
import 'package:stars/ui/features/chat/view_models/conversation_memory_view_model.dart';
import 'package:stars/utils/theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const double _memoryIconLabelGap = 9;
const double _memoryTrailingControlWidth = 44;

final class ConversationMemoryPanel extends StatefulWidget {
  const ConversationMemoryPanel({
    super.key,
    required this.viewModel,
    required this.generationViewModel,
  });

  final ConversationMemoryViewModel viewModel;
  final ChatGenerationViewModel? generationViewModel;

  @override
  State<ConversationMemoryPanel> createState() =>
      _ConversationMemoryPanelState();
}

final class _ConversationMemoryPanelState
    extends State<ConversationMemoryPanel> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_changed);
    widget.generationViewModel?.addListener(_changed);
    unawaited(widget.viewModel.load());
  }

  @override
  void didUpdateWidget(covariant ConversationMemoryPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.removeListener(_changed);
      widget.viewModel.addListener(_changed);
      unawaited(widget.viewModel.load());
    }
    if (oldWidget.generationViewModel != widget.generationViewModel) {
      oldWidget.generationViewModel?.removeListener(_changed);
      widget.generationViewModel?.addListener(_changed);
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_changed);
    widget.generationViewModel?.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final state = viewModel.state;
    final report = widget.generationViewModel?.contextAssemblyReport;
    final numberFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    );
    return Material(
      type: MaterialType.transparency,
      child: Column(
        key: const ValueKey<String>('conversation-memory-panel'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 25),
          Text(
            S.of(context).contextAndMemory,
            key: const ValueKey<String>('conversation-memory-section-title'),
            style: DesktopThemeTokens.sectionTitleStyle(context),
          ),
          const SizedBox(height: 12),
          if (report != null) ...[
            _MemoryMetric(
              key: const ValueKey<String>('memory-context-window'),
              icon: Icons.memory_rounded,
              label: S.of(context).contextWindow,
              value: numberFormat.format(report.contextWindowTokens),
            ),
            _MemoryMetric(
              key: const ValueKey<String>('memory-estimated-usage'),
              icon: Icons.data_usage_rounded,
              label: S.of(context).estimatedContextUsage,
              value:
                  '${numberFormat.format(report.estimatedInputTokens)} / '
                  '${numberFormat.format(report.inputBudgetTokens)}',
            ),
            _MemoryMetric(
              key: const ValueKey<String>('memory-retained-turns'),
              icon: Icons.forum_outlined,
              label: S.of(context).retainedRecentTurns,
              value: numberFormat.format(report.includedTurnIds.length),
            ),
          ],
          _MemoryMetric(
            key: const ValueKey<String>('memory-summarized-turns'),
            icon: Icons.summarize_outlined,
            label: S.of(context).summarizedTurns,
            value: numberFormat.format(
              viewModel.summary?.metadata.sourceMessageIds.length ?? 0,
            ),
          ),
          _MemoryMetric(
            key: const ValueKey<String>('memory-compaction-status'),
            icon: Icons.sync_rounded,
            label: S.of(context).compactionStatus,
            valueWidth: _memoryTrailingControlWidth,
            valueTextAlign: TextAlign.center,
            value:
                viewModel.compacting
                    ? S.of(context).compactingContext
                    : _statusLabel(context, state?.compactionStatus),
          ),
          _AutomaticMemoryRow(
            enabled: !viewModel.loading,
            value: state?.autoMemoryEnabled ?? true,
            onChanged:
                (value) => unawaited(viewModel.setAutoMemoryEnabled(value)),
          ),
          const SizedBox(height: 10),
          _MemoryActions(
            compacting: viewModel.compacting,
            onViewSummary: () => _showSummary(context),
            onManage: () => _showMemoryManager(context),
            onCompact: () => unawaited(_compact(context)),
          ),
          if (viewModel.error != null) ...[
            const SizedBox(height: 10),
            Text(
              viewModel.error.toString(),
              style: (DesktopThemeTokens.metaStyle(context) ??
                      const TextStyle())
                  .copyWith(color: DesktopThemeTokens.error(context)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _compact(BuildContext context) async {
    try {
      final result = await widget.viewModel.compactNow();
      if (!context.mounted) return;
      final text = switch (result) {
        ConversationCompactionResult.committed =>
          S.of(context).contextCompacted,
        ConversationCompactionResult.noCandidates =>
          S.of(context).nothingToCompact,
        ConversationCompactionResult.revisionConflict =>
          S.of(context).memoryChangedRetry,
        ConversationCompactionResult.invalidSummary =>
          S.of(context).invalidSummary,
      };
      _showNotice(
        context,
        text,
        destructive:
            result == ConversationCompactionResult.revisionConflict ||
            result == ConversationCompactionResult.invalidSummary,
      );
    } on Object catch (error) {
      if (context.mounted) {
        _showNotice(context, error.toString(), destructive: true);
      }
    }
  }

  void _showSummary(BuildContext context) {
    final markdown = widget.viewModel.summary?.markdown;
    if (markdown == null || markdown.trim().isEmpty) {
      _showNotice(context, S.of(context).noConversationSummary);
      return;
    }
    unawaited(
      showChatShadDialog<void>(
        context: context,
        builder:
            (dialogContext) => ShadDialog(
              key: const ValueKey<String>('conversation-summary-dialog'),
              title: Text(
                S.of(dialogContext).conversationSummary,
                style: DesktopThemeTokens.pageTitleStyle(dialogContext),
              ),
              description: Text(S.of(dialogContext).automaticSummaryWarning),
              constraints: const BoxConstraints(maxWidth: 720),
              actions: [
                ShadButton.outline(
                  key: const ValueKey<String>('conversation-summary-close'),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    MaterialLocalizations.of(dialogContext).closeButtonLabel,
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 520,
                  child: _ConversationSummaryDocument(markdown: markdown),
                ),
              ),
            ),
      ),
    );
  }

  void _showNotice(
    BuildContext context,
    String message, {
    bool destructive = false,
  }) {
    final sonner = ShadSonner.maybeOf(context);
    if (sonner != null) {
      sonner.show(
        destructive
            ? ShadToast.destructive(title: Text(message))
            : ShadToast(title: Text(message)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      ),
    );
  }

  void _showMemoryManager(BuildContext context) {
    unawaited(
      showChatShadDialog<void>(
        context: context,
        builder:
            (dialogContext) =>
                _MemoryManagerDialog(viewModel: widget.viewModel),
      ),
    );
  }
}

final class _ConversationSummaryDocument extends StatelessWidget {
  const _ConversationSummaryDocument({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final tokens = StarsDesktopTokens.of(context);
    return ShadCard(
      key: const ValueKey<String>('conversation-summary-surface'),
      width: double.infinity,
      padding: EdgeInsets.zero,
      backgroundColor: tokens.raisedSurface,
      radius: DesktopThemeTokens.containerRadius,
      border: ShadBorder.all(color: tokens.separator, width: 1),
      child: Markdown(
        key: const ValueKey<String>('conversation-summary-markdown'),
        data: _summaryMarkdownBody(markdown),
        selectable: true,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        styleSheet: _summaryMarkdownStyle(context),
      ),
    );
  }
}

MarkdownStyleSheet _summaryMarkdownStyle(BuildContext context) {
  final tokens = StarsDesktopTokens.of(context);
  final body = (DesktopThemeTokens.bodyStyle(context) ??
          const TextStyle(fontSize: 14))
      .copyWith(color: tokens.primaryText, height: 1.6);
  final pageTitle = (DesktopThemeTokens.pageTitleStyle(context) ?? body)
      .copyWith(color: tokens.primaryText);
  final sectionTitle = (DesktopThemeTokens.toolbarTitleStyle(context) ?? body)
      .copyWith(color: tokens.primaryText);
  final subsectionTitle = body.copyWith(fontWeight: FontWeight.w600);
  final meta = (DesktopThemeTokens.metaStyle(context) ??
          const TextStyle(fontSize: 12))
      .copyWith(color: tokens.secondaryText, height: 1.5);

  return MarkdownStyleSheet(
    p: body,
    pPadding: const EdgeInsets.only(bottom: 4),
    h1: pageTitle,
    h1Padding: const EdgeInsets.only(top: 8, bottom: 8),
    h2: sectionTitle,
    h2Padding: const EdgeInsets.only(top: 12, bottom: 6),
    h3: subsectionTitle,
    h3Padding: const EdgeInsets.only(top: 10, bottom: 4),
    h4: subsectionTitle,
    h4Padding: const EdgeInsets.only(top: 8, bottom: 4),
    h5: meta.copyWith(fontWeight: FontWeight.w600),
    h5Padding: const EdgeInsets.only(top: 6, bottom: 2),
    h6: meta.copyWith(fontWeight: FontWeight.w600),
    h6Padding: const EdgeInsets.only(top: 6, bottom: 2),
    strong: const TextStyle(fontWeight: FontWeight.w600),
    em: const TextStyle(fontStyle: FontStyle.italic),
    a: TextStyle(
      color: tokens.accent,
      decoration: TextDecoration.underline,
      decorationColor: tokens.accent,
    ),
    code: meta.copyWith(
      color: tokens.primaryText,
      backgroundColor: tokens.controlFill,
      fontFamily: 'monospace',
    ),
    blockquote: body.copyWith(color: tokens.secondaryText),
    blockquotePadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    blockquoteDecoration: BoxDecoration(
      color: tokens.controlFill,
      borderRadius: DesktopThemeTokens.itemRadius,
      border: Border(left: BorderSide(color: tokens.separator, width: 3)),
    ),
    codeblockPadding: const EdgeInsets.all(12),
    codeblockDecoration: BoxDecoration(
      color: tokens.controlFill,
      borderRadius: DesktopThemeTokens.itemRadius,
      border: Border.all(color: tokens.separator),
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: tokens.separator)),
    ),
    listBullet: body.copyWith(color: tokens.secondaryText),
    listBulletPadding: const EdgeInsets.only(right: 6),
    listIndent: 22,
    tableHead: subsectionTitle,
    tableBody: body,
    tableBorder: TableBorder.all(color: tokens.separator),
    tableCellsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    blockSpacing: 12,
  );
}

String _summaryMarkdownBody(String markdown) {
  final lines = markdown.replaceAll('\r\n', '\n').split('\n');
  final headingIndex = lines.indexWhere((line) => line.trim().isNotEmpty);
  if (headingIndex < 0 || lines[headingIndex].trim() != '# 会话摘要') {
    return markdown;
  }
  var bodyStart = headingIndex + 1;
  while (bodyStart < lines.length && lines[bodyStart].trim().isEmpty) {
    bodyStart++;
  }
  final body = lines.sublist(bodyStart).join('\n');
  return body.trim().isEmpty ? markdown : body;
}

final class _MemoryMetric extends StatelessWidget {
  const _MemoryMetric({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueWidth,
    this.valueTextAlign = TextAlign.right,
  });

  final IconData icon;
  final String label;
  final String value;
  final double? valueWidth;
  final TextAlign valueTextAlign;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: DesktopThemeTokens.mutedText(context)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(label, style: DesktopThemeTokens.bodyStyle(context)),
        ),
        const SizedBox(width: 8),
        if (valueWidth case final width?)
          SizedBox(
            width: width,
            child: SelectableText(
              value,
              textAlign: valueTextAlign,
              style: DesktopThemeTokens.metaStyle(context),
            ),
          )
        else
          Flexible(
            child: SelectableText(
              value,
              textAlign: valueTextAlign,
              style: DesktopThemeTokens.metaStyle(context),
            ),
          ),
      ],
    ),
  );
}

final class _AutomaticMemoryRow extends StatelessWidget {
  const _AutomaticMemoryRow({
    required this.enabled,
    required this.value,
    required this.onChanged,
  });

  final bool enabled;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            LucideIcons.brain,
            size: 17,
            color: DesktopThemeTokens.mutedText(context),
          ),
          const SizedBox(
            key: ValueKey<String>('automatic-memory-icon-gap'),
            width: _memoryIconLabelGap,
          ),
          Expanded(
            child: Text(
              S.of(context).automaticMemory,
              style: DesktopThemeTokens.bodyStyle(context),
            ),
          ),
          const SizedBox(width: 8),
          ShadSwitch(
            key: const ValueKey<String>('automatic-memory-switch'),
            width: _memoryTrailingControlWidth,
            value: value,
            enabled: enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    ),
  );
}

final class _MemoryActions extends StatelessWidget {
  const _MemoryActions({
    required this.compacting,
    required this.onViewSummary,
    required this.onManage,
    required this.onCompact,
  });

  final bool compacting;
  final VoidCallback onViewSummary;
  final VoidCallback onManage;
  final VoidCallback onCompact;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    key: const ValueKey<String>('conversation-memory-actions'),
    builder: (context, constraints) {
      const spacing = 8.0;
      final compactLayout = constraints.maxWidth < 320;
      final buttonWidth =
          ((constraints.maxWidth - spacing * 2) / 3)
              .clamp(0.0, double.infinity)
              .toDouble();
      final padding = EdgeInsets.symmetric(horizontal: compactLayout ? 3 : 8);
      final iconSize = compactLayout ? 14.0 : 15.0;
      Widget label(String value) => Flexible(
        child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      );

      final viewSummary = ShadButton.outline(
        key: const ValueKey<String>('memory-view-summary'),
        size: ShadButtonSize.sm,
        width: buttonWidth,
        padding: padding,
        gap: _memoryIconLabelGap,
        onPressed: onViewSummary,
        leading: Icon(LucideIcons.fileText, size: iconSize),
        child: label(S.of(context).viewSummary),
      );
      final manage = ShadButton.outline(
        key: const ValueKey<String>('memory-manage'),
        size: ShadButtonSize.sm,
        width: buttonWidth,
        padding: padding,
        gap: _memoryIconLabelGap,
        onPressed: onManage,
        leading: Icon(LucideIcons.brain, size: iconSize),
        child: label(S.of(context).manageMemory),
      );
      final compact = ShadButton.outline(
        key: const ValueKey<String>('memory-compact-now'),
        size: ShadButtonSize.sm,
        width: buttonWidth,
        padding: padding,
        gap: _memoryIconLabelGap,
        onPressed: compacting ? null : onCompact,
        leading:
            compacting
                ? const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Icon(LucideIcons.minimize2, size: iconSize),
        child: label(S.of(context).compactNow),
      );

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [viewSummary, manage, compact],
      );
    },
  );
}

final class _MemoryManagerDialog extends StatefulWidget {
  const _MemoryManagerDialog({required this.viewModel});

  final ConversationMemoryViewModel viewModel;

  @override
  State<_MemoryManagerDialog> createState() => _MemoryManagerDialogState();
}

final class _MemoryManagerDialogState extends State<_MemoryManagerDialog> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_changed);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _query.trim().toLowerCase();
    final items = widget.viewModel.items
        .where(
          (item) =>
              normalized.isEmpty ||
              item.content.toLowerCase().contains(normalized) ||
              item.memoryKey.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
    final tokens = StarsDesktopTokens.of(context);
    return ShadDialog(
      key: const ValueKey<String>('conversation-memory-manager-dialog'),
      title: Text(
        S.of(context).manageMemory,
        style: DesktopThemeTokens.pageTitleStyle(context),
      ),
      description: Text(S.of(context).automaticSummaryWarning),
      constraints: const BoxConstraints(maxWidth: 760),
      actions: [
        ShadButton.raw(
          variant: ShadButtonVariant.outline,
          foregroundColor: tokens.danger,
          onPressed: () => unawaited(widget.viewModel.clearAutomaticMemory()),
          leading: const Icon(LucideIcons.trash2, size: 16),
          child: Text(S.of(context).clearAutomaticMemory),
        ),
        ShadButton.outline(
          enabled: !widget.viewModel.compacting,
          onPressed:
              widget.viewModel.compacting
                  ? null
                  : () => unawaited(widget.viewModel.compactNow(rebuild: true)),
          leading:
              widget.viewModel.compacting
                  ? const SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(LucideIcons.refreshCw, size: 16),
          child: Text(S.of(context).rebuildMemory),
        ),
        ShadButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
      child: SizedBox(
        height: 520,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StarsSearchField(
                key: const ValueKey<String>('memory-search-input'),
                hintText: S.of(context).searchMemory,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 4),
                  children: [
                    if (widget.viewModel.summary case final summary?) ...[
                      _SummaryMemoryCard(summary: summary),
                      if (items.isNotEmpty) const SizedBox(height: 10),
                    ],
                    for (var index = 0; index < items.length; index++) ...[
                      _MemoryItemTile(
                        item: items[index],
                        viewModel: widget.viewModel,
                      ),
                      if (index != items.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _SummaryMemoryCard extends StatelessWidget {
  const _SummaryMemoryCard({required this.summary});

  final ConversationSummaryDocument summary;

  @override
  Widget build(BuildContext context) {
    final tokens = StarsDesktopTokens.of(context);
    return ShadCard(
      key: const ValueKey<String>('memory-summary-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      backgroundColor: tokens.controlFill,
      border: ShadBorder.all(color: tokens.separator, width: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              LucideIcons.fileText,
              size: 17,
              color: tokens.secondaryText,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).conversationSummary,
                  style: DesktopThemeTokens.bodyStyle(
                    context,
                  )?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(
                  summary.markdown,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: DesktopThemeTokens.metaStyle(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _MemoryItemTile extends StatelessWidget {
  const _MemoryItemTile({required this.item, required this.viewModel});

  final ConversationMemoryItem item;
  final ConversationMemoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final tokens = StarsDesktopTokens.of(context);
    final locale = Localizations.localeOf(context).toString();
    final updatedAt = DateFormat.yMd(
      locale,
    ).add_Hm().format(item.updatedAt.toLocal());
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          item.content,
          style: DesktopThemeTokens.bodyStyle(
            context,
          )?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ShadBadge.outline(child: Text(_kindLabel(context, item.kind))),
            ShadBadge.outline(
              child: Text('${(item.confidence * 100).round()}%'),
            ),
            Text(updatedAt, style: DesktopThemeTokens.metaStyle(context)),
          ],
        ),
      ],
    );
    final actions = Wrap(
      spacing: 2,
      children: [
        _MemoryIconAction(
          key: ValueKey<String>('memory-pin-${item.id}'),
          label:
              item.state == ConversationMemoryItemState.pinned
                  ? S.of(context).unpinMemory
                  : S.of(context).pinMemory,
          icon:
              item.state == ConversationMemoryItemState.pinned
                  ? LucideIcons.pinOff
                  : LucideIcons.pin,
          onPressed:
              () => unawaited(
                viewModel.saveItem(
                  item,
                  state:
                      item.state == ConversationMemoryItemState.pinned
                          ? ConversationMemoryItemState.active
                          : ConversationMemoryItemState.pinned,
                ),
              ),
        ),
        _MemoryIconAction(
          key: ValueKey<String>('memory-edit-${item.id}'),
          label: S.of(context).editMemory,
          icon: LucideIcons.pencil,
          onPressed: () => _edit(context),
        ),
        _MemoryIconAction(
          key: ValueKey<String>('memory-forget-${item.id}'),
          label:
              item.state == ConversationMemoryItemState.forgotten
                  ? S.of(context).restoreMemory
                  : S.of(context).forgetMemory,
          icon:
              item.state == ConversationMemoryItemState.forgotten
                  ? LucideIcons.rotateCcw
                  : LucideIcons.eyeOff,
          foregroundColor:
              item.state == ConversationMemoryItemState.forgotten
                  ? null
                  : tokens.danger,
          onPressed:
              () => unawaited(
                item.state == ConversationMemoryItemState.forgotten
                    ? viewModel.restoreItem(item)
                    : viewModel.forgetItem(item),
              ),
        ),
      ],
    );
    return ShadCard(
      key: ValueKey<String>('memory-item-${item.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      backgroundColor: tokens.raisedSurface,
      border: ShadBorder.all(color: tokens.separator, width: 1),
      child: LayoutBuilder(
        builder:
            (context, constraints) =>
                constraints.maxWidth >= 480
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: details),
                        const SizedBox(width: 12),
                        actions,
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        details,
                        const SizedBox(height: 10),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: actions,
                        ),
                      ],
                    ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final controller = TextEditingController(text: item.content);
    final value = await showChatShadDialog<String>(
      context: context,
      builder:
          (dialogContext) => ShadDialog(
            title: Text(
              S.of(dialogContext).editMemory,
              style: DesktopThemeTokens.pageTitleStyle(dialogContext),
            ),
            constraints: const BoxConstraints(maxWidth: 560),
            actions: [
              ShadButton.outline(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  MaterialLocalizations.of(dialogContext).cancelButtonLabel,
                ),
              ),
              ShadButton(
                onPressed:
                    () => Navigator.pop(dialogContext, controller.text.trim()),
                child: Text(S.of(dialogContext).save),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ShadInput(
                controller: controller,
                minLines: 4,
                maxLines: 6,
              ),
            ),
          ),
    );
    controller.dispose();
    if (value != null && value.isNotEmpty) {
      await viewModel.saveItem(item, content: value);
    }
  }
}

final class _MemoryIconAction extends StatelessWidget {
  const _MemoryIconAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    onTap: onPressed,
    child: ExcludeSemantics(
      child: ShadTooltip(
        builder: (context) => Text(label),
        child: ShadIconButton.raw(
          variant: ShadButtonVariant.ghost,
          width: 34,
          height: 34,
          iconSize: 16,
          foregroundColor: foregroundColor,
          onPressed: onPressed,
          icon: Icon(icon),
        ),
      ),
    ),
  );
}

String _statusLabel(
  BuildContext context,
  ConversationCompactionStatus? status,
) => switch (status) {
  ConversationCompactionStatus.background => S.of(context).compactingContext,
  ConversationCompactionStatus.synchronous => S.of(context).compactingContext,
  ConversationCompactionStatus.failed => S.of(context).compactionFailed,
  _ => S.of(context).idle,
};

String _kindLabel(BuildContext context, ConversationMemoryKind kind) =>
    switch (kind) {
      ConversationMemoryKind.fact => S.of(context).memoryFact,
      ConversationMemoryKind.preference => S.of(context).memoryPreference,
      ConversationMemoryKind.decision => S.of(context).memoryDecision,
      ConversationMemoryKind.openTask => S.of(context).memoryTask,
      ConversationMemoryKind.unresolvedQuestion => S.of(context).memoryQuestion,
      ConversationMemoryKind.artifactReference => S.of(context).memoryArtifact,
      ConversationMemoryKind.correction => S.of(context).memoryCorrection,
    };
