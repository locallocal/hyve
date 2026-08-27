import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hyve/domain/models/agent_memory.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/ui/core/widgets/common.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/ui/features/bots/view_models/agent_memory_view_model.dart';
import 'package:hyve/utils/theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final class AgentMemoryPanel extends StatefulWidget {
  const AgentMemoryPanel({
    super.key,
    required this.viewModel,
    this.showSectionHeader = true,
  });

  final AgentMemoryViewModel viewModel;
  final bool showSectionHeader;

  @override
  State<AgentMemoryPanel> createState() => _AgentMemoryPanelState();
}

final class _AgentMemoryPanelState extends State<AgentMemoryPanel> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_changed);
    unawaited(widget.viewModel.load());
  }

  @override
  void didUpdateWidget(covariant AgentMemoryPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel == widget.viewModel) return;
    oldWidget.viewModel.removeListener(_changed);
    widget.viewModel.addListener(_changed);
    unawaited(widget.viewModel.load());
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
    final viewModel = widget.viewModel;
    return Column(
      key: const ValueKey<String>('agent-memory-panel'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.showSectionHeader) ...[
          const ShadSeparator.horizontal(
            margin: EdgeInsets.symmetric(vertical: 12),
          ),
          Text(
            S.of(context).agentMemory,
            style: HyveDesktopThemeSpec.sectionTitleStyle(context),
          ),
          const SizedBox(height: 12),
        ],
        Semantics(
          container: true,
          toggled: viewModel.autoEvolutionEnabled,
          enabled: !viewModel.loading,
          label: S.of(context).agentMemoryAutoEvolution,
          child: Row(
            key: const ValueKey<String>('agent-memory-auto-evolution-row'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                LucideIcons.brain,
                size: HyveDesktopThemeSpec.settingsRowIconSize,
                color: HyveDesktopTokens.of(context).secondaryText,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.of(context).agentMemoryAutoEvolution,
                      style: ShadTheme.of(context).textTheme.small,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      S.of(context).agentMemoryDescription,
                      style: HyveDesktopThemeSpec.metaStyle(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ExcludeSemantics(
                child: ShadSwitch(
                  key: const ValueKey<String>(
                    'agent-memory-auto-evolution-switch',
                  ),
                  value: viewModel.autoEvolutionEnabled,
                  enabled: !viewModel.loading,
                  onChanged:
                      viewModel.loading
                          ? null
                          : (value) => unawaited(
                            viewModel.setAutoEvolutionEnabled(value),
                          ),
                ),
              ),
            ],
          ),
        ),
        if (viewModel.error case final error?) ...[
          const SizedBox(height: 12),
          Text(
            safeFailureMessage(context, error),
            key: const ValueKey<String>('agent-memory-error'),
            style: (HyveDesktopThemeSpec.metaStyle(context) ??
                    const TextStyle())
                .copyWith(color: HyveDesktopThemeSpec.error(context)),
          ),
        ],
        const SizedBox(height: 16),
        _AgentMemoryActions(
          compacting: viewModel.compacting,
          onViewSummary: () => _showSummary(context),
          onManage: () => _showManager(context),
          onCompact: () => unawaited(_compact(context)),
        ),
      ],
    );
  }

  Future<void> _compact(BuildContext context) async {
    try {
      final compacted = await widget.viewModel.compactNow();
      if (!context.mounted) return;
      showHyveNotice(
        context,
        compacted == 0
            ? S.of(context).nothingToCompact
            : S.of(context).contextCompacted,
      );
    } on Object catch (error) {
      if (!context.mounted) return;
      showHyveNotice(
        context,
        safeFailureMessage(context, error),
        tone: HyveNoticeTone.error,
      );
    }
  }

  void _showSummary(BuildContext context) {
    final items = widget.viewModel.summaryItems;
    unawaited(
      showChatShadDialog<void>(
        context: context,
        builder:
            (dialogContext) => HyveDialog(
              key: const ValueKey<String>('agent-memory-summary-dialog'),
              title: Text(
                S.of(dialogContext).agentMemory,
                style: HyveDesktopThemeSpec.pageTitleStyle(dialogContext),
              ),
              description: Text(S.of(dialogContext).agentMemoryDescription),
              constraints: const BoxConstraints(maxWidth: 720),
              actions: <Widget>[
                ShadButton.outline(
                  key: const ValueKey<String>('agent-memory-summary-close'),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    MaterialLocalizations.of(dialogContext).closeButtonLabel,
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: math.min(
                    420,
                    MediaQuery.sizeOf(dialogContext).height * 0.52,
                  ),
                  child:
                      items.isEmpty
                          ? Center(child: Text(S.of(context).noAgentMemory))
                          : SingleChildScrollView(
                            child: SelectableText(
                              items
                                  .map((memory) => '• ${memory.content}')
                                  .join('\n\n'),
                              key: const ValueKey<String>(
                                'agent-memory-summary-content',
                              ),
                            ),
                          ),
                ),
              ),
            ),
      ),
    );
  }

  void _showManager(BuildContext context) {
    unawaited(
      showChatShadDialog<void>(
        context: context,
        builder:
            (dialogContext) => _AgentMemoryDialog(viewModel: widget.viewModel),
      ),
    );
  }
}

final class _AgentMemoryActions extends StatelessWidget {
  const _AgentMemoryActions({
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

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ShadButton.outline(
            key: const ValueKey<String>('memory-view-summary'),
            size: ShadButtonSize.sm,
            width: buttonWidth,
            padding: padding,
            gap: hyveInspectorIconLabelGap,
            onPressed: onViewSummary,
            leading: Icon(LucideIcons.fileText, size: iconSize),
            child: label(S.of(context).viewSummary),
          ),
          ShadButton.outline(
            key: const ValueKey<String>('memory-manage'),
            size: ShadButtonSize.sm,
            width: buttonWidth,
            padding: padding,
            gap: hyveInspectorIconLabelGap,
            onPressed: onManage,
            leading: Icon(LucideIcons.brain, size: iconSize),
            child: label(S.of(context).manageMemory),
          ),
          ShadButton.outline(
            key: const ValueKey<String>('memory-compact-now'),
            size: ShadButtonSize.sm,
            width: buttonWidth,
            padding: padding,
            gap: hyveInspectorIconLabelGap,
            onPressed: compacting ? null : onCompact,
            leading:
                compacting
                    ? const SizedBox.square(
                      dimension: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Icon(LucideIcons.minimize2, size: iconSize),
            child: label(S.of(context).compactNow),
          ),
        ],
      );
    },
  );
}

final class _AgentMemoryDialog extends StatefulWidget {
  const _AgentMemoryDialog({required this.viewModel});

  final AgentMemoryViewModel viewModel;

  @override
  State<_AgentMemoryDialog> createState() => _AgentMemoryDialogState();
}

final class _AgentMemoryDialogState extends State<_AgentMemoryDialog> {
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
    final items = widget.viewModel.items;
    final dialogHeight = math.min(
      500.0,
      MediaQuery.sizeOf(context).height * 0.62,
    );
    return HyveDialog(
      key: const ValueKey<String>('agent-memory-manager-dialog'),
      title: Text(
        S.of(context).agentMemory,
        style: HyveDesktopThemeSpec.pageTitleStyle(context),
      ),
      description: Text(S.of(context).agentMemoryDescription),
      constraints: const BoxConstraints(maxWidth: 720),
      actions: <Widget>[
        ShadButton.outline(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SizedBox(
          height: dialogHeight,
          child:
              items.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          LucideIcons.brain,
                          size: 28,
                          color: HyveDesktopTokens.of(context).secondaryText,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          S.of(context).noAgentMemory,
                          style: HyveDesktopThemeSpec.metaStyle(context),
                        ),
                      ],
                    ),
                  )
                  : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 4),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder:
                        (context, index) => _AgentMemoryTile(
                          memory: items[index],
                          viewModel: widget.viewModel,
                        ),
                  ),
        ),
      ),
    );
  }
}

final class _AgentMemoryTile extends StatelessWidget {
  const _AgentMemoryTile({required this.memory, required this.viewModel});

  final AgentMemory memory;
  final AgentMemoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final tokens = HyveDesktopTokens.of(context);
    return ShadCard(
      key: ValueKey<String>('agent-memory-item-${memory.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      backgroundColor: tokens.controlFill,
      border: ShadBorder.all(color: tokens.separator, width: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SelectableText(memory.content),
          const SizedBox(height: 6),
          Text(
            '${memory.kind.name} · ${memory.state.name} · '
            '${memory.reuseScope.name} · v${memory.version}',
            style: HyveDesktopThemeSpec.metaStyle(context),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Wrap(
              spacing: 2,
              children: <Widget>[
                if (memory.state == AgentMemoryState.candidate)
                  HyveDesktopIconAction(
                    icon: LucideIcons.check,
                    label: S.of(context).save,
                    onPressed: () => unawaited(viewModel.approve(memory)),
                  ),
                HyveDesktopIconAction(
                  icon: LucideIcons.pencil,
                  label: S.of(context).editMemory,
                  onPressed: () => _edit(context),
                ),
                HyveDesktopIconAction(
                  icon: LucideIcons.eyeOff,
                  label: S.of(context).forgetMemory,
                  onPressed: () => unawaited(viewModel.forget(memory)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final controller = TextEditingController(text: memory.content);
    final value = await showChatShadDialog<String>(
      context: context,
      builder:
          (dialogContext) => HyveDialog(
            title: Text(
              S.of(dialogContext).editMemory,
              style: HyveDesktopThemeSpec.pageTitleStyle(dialogContext),
            ),
            constraints: const BoxConstraints(maxWidth: 560),
            actions: <Widget>[
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
                maxLines: 8,
              ),
            ),
          ),
    );
    controller.dispose();
    if (value == null || value.isEmpty) return;
    await viewModel.correct(
      memory,
      content: value,
      reuseScope: memory.reuseScope,
    );
  }
}
