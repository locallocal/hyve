import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyve/domain/models/agent_memory.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/ui/features/bots/view_models/agent_memory_view_model.dart';
import 'package:hyve/utils/theme.dart';

final class AgentMemoryPanel extends StatefulWidget {
  const AgentMemoryPanel({super.key, required this.viewModel});

  final AgentMemoryViewModel viewModel;

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
        const Divider(height: 25),
        Text(
          'Agent Memory',
          style: HyveDesktopThemeSpec.sectionTitleStyle(context),
        ),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(S.of(context).automaticMemory),
          subtitle: Text(
            'Long-term memory belongs to this Agent across projects.',
            style: HyveDesktopThemeSpec.metaStyle(context),
          ),
          value: viewModel.autoEvolutionEnabled,
          onChanged:
              viewModel.loading
                  ? null
                  : (value) =>
                      unawaited(viewModel.setAutoEvolutionEnabled(value)),
        ),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          key: const ValueKey<String>('manage-agent-memory'),
          onPressed: () => _showManager(context),
          icon: const Icon(Icons.psychology_outlined, size: 17),
          label: Text(
            '${S.of(context).manageMemory} (${viewModel.items.length})',
          ),
        ),
      ],
    );
  }

  void _showManager(BuildContext context) {
    unawaited(
      showDialog<void>(
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
    return AlertDialog(
      title: Text(S.of(context).manageMemory),
      content: SizedBox(
        width: 680,
        height: 500,
        child:
            items.isEmpty
                ? Center(child: Text(S.of(context).noConversationSummary))
                : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder:
                      (context, index) => _AgentMemoryTile(
                        memory: items[index],
                        viewModel: widget.viewModel,
                      ),
                ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}

final class _AgentMemoryTile extends StatelessWidget {
  const _AgentMemoryTile({required this.memory, required this.viewModel});

  final AgentMemory memory;
  final AgentMemoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: SelectableText(memory.content),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          '${memory.kind.name} · ${memory.state.name} · '
          '${memory.reuseScope.name} · v${memory.version}',
          style: HyveDesktopThemeSpec.metaStyle(context),
        ),
      ),
      trailing: Wrap(
        spacing: 2,
        children: <Widget>[
          if (memory.state == AgentMemoryState.candidate)
            HyveDesktopIconAction(
              icon: Icons.check_rounded,
              label: S.of(context).save,
              onPressed: () => unawaited(viewModel.approve(memory)),
            ),
          HyveDesktopIconAction(
            icon: Icons.edit_outlined,
            label: S.of(context).editMemory,
            onPressed: () => _edit(context),
          ),
          HyveDesktopIconAction(
            icon: Icons.visibility_off_outlined,
            label: S.of(context).forgetMemory,
            onPressed: () => unawaited(viewModel.forget(memory)),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final controller = TextEditingController(text: memory.content);
    final value = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(S.of(dialogContext).editMemory),
            content: TextField(
              controller: controller,
              minLines: 3,
              maxLines: 8,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  MaterialLocalizations.of(dialogContext).cancelButtonLabel,
                ),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.pop(dialogContext, controller.text.trim()),
                child: Text(S.of(dialogContext).save),
              ),
            ],
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
