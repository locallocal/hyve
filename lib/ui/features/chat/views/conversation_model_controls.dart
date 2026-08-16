import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/repositories/ai_provider_repository.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';

const double _modelControlWidth = 44;

/// Conversation-scoped model options shown in the bot-information inspector.
final class ConversationModelControls extends StatefulWidget {
  const ConversationModelControls({super.key, required this.provider});

  final AiProvider provider;

  @override
  State<ConversationModelControls> createState() =>
      _ConversationModelControlsState();
}

final class _ConversationModelControlsState
    extends State<ConversationModelControls> {
  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    return Column(
      key: const ValueKey<String>('conversation-model-controls'),
      children: [
        if (provider.supportWebSearch())
          _ModelControlRow(
            key: const ValueKey<String>('conversation-web-search-row'),
            switchKey: const ValueKey<String>('conversation-web-search-toggle'),
            icon: LucideIcons.globe,
            label: S.of(context).webSearch,
            value: provider.getWebSearch(),
            onChanged: (value) {
              setState(() {
                provider.setWebSearch(value);
              });
            },
          ),
        if (provider.supportDeepThinking())
          _ModelControlRow(
            key: const ValueKey<String>('conversation-deep-thinking-row'),
            switchKey: const ValueKey<String>(
              'conversation-deep-thinking-toggle',
            ),
            icon: LucideIcons.brain,
            label: S.of(context).deepThinking,
            value: provider.getDeepThinking(),
            onChanged: (value) {
              setState(() {
                provider.setDeepThinking(value);
              });
            },
          ),
      ],
    );
  }
}

final class _ModelControlRow extends StatelessWidget {
  const _ModelControlRow({
    super.key,
    required this.switchKey,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final Key switchKey;
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final toggle = ShadSwitch(
      key: switchKey,
      width: _modelControlWidth,
      value: value,
      onChanged: onChanged,
    );
    return MergeSemantics(
      child: HyveInspectorInfoRow(
        icon: icon,
        label: label,
        padding: const EdgeInsets.symmetric(vertical: 5),
        crossAxisAlignment: CrossAxisAlignment.center,
        trailingWidth: _modelControlWidth,
        trailing: toggle,
      ),
    );
  }
}
