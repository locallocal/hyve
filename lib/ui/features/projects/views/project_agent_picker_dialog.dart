import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';
import 'package:hyve/utils/theme.dart';

/// A searchable, keyboard-accessible picker for adding a project agent.
final class ProjectAgentPickerDialog extends StatefulWidget {
  const ProjectAgentPickerDialog({super.key, required this.agents});

  final List<Agent> agents;

  @override
  State<ProjectAgentPickerDialog> createState() =>
      _ProjectAgentPickerDialogState();
}

final class _ProjectAgentPickerDialogState
    extends State<ProjectAgentPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final windowSize = MediaQuery.sizeOf(context);
    final content = SizedBox(
      key: const ValueKey<String>('project-agent-picker-content'),
      width: (windowSize.width - 80).clamp(0.0, 520.0),
      height: (windowSize.height - 220).clamp(240.0, 420.0),
      child: _buildContent(context, copy),
    );

    if (hasShadProjectTheme(context)) {
      return HyveDialog(
        title: Text(copy.addAgent),
        description: Text(copy.addAgentDescription),
        closeButtonKey: const ValueKey<String>('project-agent-picker-close'),
        constraints: const BoxConstraints(maxWidth: 568),
        scrollable: false,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        child: content,
      );
    }

    return AlertDialog(
      title: Text(copy.addAgent),
      content: content,
      actions: <Widget>[
        TextButton(
          key: const ValueKey<String>('project-agent-picker-close'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(copy.close),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ProjectLocalizations copy) {
    final normalized = _query.trim().toLowerCase();
    final matches = widget.agents
        .where((agent) => _matches(agent, normalized))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ProjectTextInput(
          key: const ValueKey<String>('project-agent-picker-search'),
          controller: _searchController,
          label: copy.searchAvailableAgents,
          showLabel: false,
          leading: const Icon(LucideIcons.search, size: 16),
          trailing:
              _query.isEmpty
                  ? null
                  : ProjectIconAction(
                    label: copy.close,
                    icon: LucideIcons.x,
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 12),
        Expanded(
          child:
              matches.isEmpty
                  ? ProjectEmptyState(
                    icon: LucideIcons.bot,
                    title:
                        widget.agents.isEmpty
                            ? copy.noAvailableAgents
                            : copy.noMatchingAgents,
                  )
                  : ListView.builder(
                    key: const ValueKey<String>('project-agent-picker-list'),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final agent = matches[index];
                      return _AgentPickerOption(
                        key: ValueKey<String>(
                          'project-agent-picker-option-${agent.id}',
                        ),
                        agent: agent,
                        onPressed: () => Navigator.of(context).pop(agent.id),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  bool _matches(Agent agent, String normalized) {
    if (normalized.isEmpty) return true;
    return <String>[
      agent.name,
      agent.id,
      agent.provider,
      agent.model,
    ].any((value) => value.toLowerCase().contains(normalized));
  }
}

final class _AgentPickerOption extends StatelessWidget {
  const _AgentPickerOption({
    super.key,
    required this.agent,
    required this.onPressed,
  });

  final Agent agent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final details = <String>[
      agent.provider.trim(),
      agent.model.trim(),
    ].where((value) => value.isNotEmpty).join(' · ');
    final subtitle = details.isEmpty ? agent.id : details;
    final semanticsLabel = '${copy.addAgent}: ${agent.name}';

    if (!hasShadProjectTheme(context)) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: ProjectActorAvatar(agent: agent, size: 36),
          title: Text(agent.name),
          subtitle: Text(subtitle),
          trailing: const Icon(LucideIcons.plus, size: 18),
          onTap: onPressed,
        ),
      );
    }

    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: HyveDesktopActionSurface(
        label: semanticsLabel,
        hint: subtitle,
        liftOnHover: false,
        onPressed: onPressed,
        builder: (context, highlighted) {
          final foreground =
              highlighted
                  ? theme.colorScheme.accentForeground
                  : theme.colorScheme.cardForeground;
          return ShadCard(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            backgroundColor:
                highlighted ? theme.colorScheme.accent : theme.colorScheme.card,
            child: Row(
              children: <Widget>[
                ProjectActorAvatar(agent: agent, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        agent.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.small.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  LucideIcons.plus,
                  size: 18,
                  color: theme.colorScheme.mutedForeground,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
