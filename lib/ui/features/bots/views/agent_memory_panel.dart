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
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 480;
            return Align(
              alignment: AlignmentDirectional.centerEnd,
              child: ShadButton.outline(
                key: const ValueKey<String>('manage-agent-memory'),
                width: compact ? double.infinity : null,
                leading: const Icon(LucideIcons.brain, size: 16),
                onPressed: () => _showManager(context),
                child: Text(
                  '${S.of(context).manageMemory} (${viewModel.items.length})',
                ),
              ),
            );
          },
        ),
      ],
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
    return ShadDialog(
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
          (dialogContext) => ShadDialog(
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
