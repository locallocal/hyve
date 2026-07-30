import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/core/widgets/common.dart';
import 'package:stars/ui/features/bots/view_models/bot_skill_view_model.dart';
import 'package:stars/utils/theme.dart';

/// Desktop Skill editor for a Bot that has not been persisted yet.
///
/// The supplied [BotSkillViewModel] uses an in-memory binding repository. Its
/// bindings are persisted together with the new Bot when the form is submitted.
class AddBotSkills extends StatefulWidget {
  const AddBotSkills({super.key, required this.viewModel});

  final BotSkillViewModel viewModel;

  @override
  State<AddBotSkills> createState() => _AddBotSkillsState();
}

class _AddBotSkillsState extends State<AddBotSkills> {
  BotSkillViewModel get viewModel => widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final strings = S.of(context);
    if (viewModel.isLoading) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (viewModel.skills.isEmpty) {
      return Text(
        strings.noSkillsInstalledDescription,
        style: DesktopThemeTokens.bodyStyle(
          context,
        )?.copyWith(color: DesktopThemeTokens.mutedText(context)),
      );
    }

    final addButton = ShadButton.outline(
      key: const ValueKey<String>('add-bot-skill'),
      size: ShadButtonSize.sm,
      width: 0,
      enabled: viewModel.availableSkills.isNotEmpty,
      onPressed: _showAddSkillDialog,
      leading: const Icon(LucideIcons.plus, size: 15),
      child: Text(strings.addSkill),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.botSkillsDescription,
                style: DesktopThemeTokens.metaStyle(context),
              ),
            ),
            const SizedBox(width: 12),
            if (viewModel.availableSkills.isEmpty)
              Tooltip(message: strings.allSkillsAdded, child: addButton)
            else
              addButton,
          ],
        ),
        const SizedBox(height: 10),
        if (viewModel.addedSkills.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.noBotSkillsAdded,
                  style: ShadTheme.of(context).textTheme.small,
                ),
                const SizedBox(height: 4),
                Text(
                  strings.noBotSkillsAddedDescription,
                  style: DesktopThemeTokens.metaStyle(context),
                ),
              ],
            ),
          )
        else ...[
          for (
            var index = 0;
            index < viewModel.paginatedAddedSkills.length;
            index++
          ) ...[
            _buildSkillRow(viewModel.paginatedAddedSkills[index]),
            if (index != viewModel.paginatedAddedSkills.length - 1)
              const ShadSeparator.horizontal(),
          ],
          if (viewModel.totalAddedPages > 1) ...[
            const SizedBox(height: 12),
            _buildPagination(
              keyPrefix: 'add-bot-skills',
              currentPage: viewModel.currentAddedPage,
              totalPages: viewModel.totalAddedPages,
              hasPreviousPage: viewModel.hasPreviousAddedPage,
              hasNextPage: viewModel.hasNextAddedPage,
              onPreviousPage: viewModel.previousAddedPage,
              onNextPage: viewModel.nextAddedPage,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSkillRow(SkillDescriptor skill) {
    final strings = S.of(context);
    final binding = viewModel.bindingFor(skill.id);
    final enabled = binding?.enabled ?? false;
    final mode = binding?.activationMode ?? SkillActivationMode.manual;

    return Padding(
      key: ValueKey<String>('add-bot-selected-skill-${skill.id}'),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.name,
                      style: ShadTheme.of(context).textTheme.small,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      skill.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DesktopThemeTokens.metaStyle(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ShadSwitch(
                key: ValueKey<String>('add-bot-skill-toggle-${skill.id}'),
                value: enabled,
                onChanged: (value) => _setEnabled(skill.id, value),
                label: Text(
                  enabled ? strings.skillEnabled : strings.skillDisabled,
                ),
              ),
              const SizedBox(width: 8),
              ShadTooltip(
                builder: (context) => Text(strings.removeSkill),
                child: ShadIconButton.ghost(
                  key: ValueKey<String>('remove-add-bot-skill-${skill.id}'),
                  width: 30,
                  height: 30,
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  onPressed: () => _removeSkill(skill.id),
                  icon: const Icon(LucideIcons.trash2),
                ),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildModeChoice(
                  key: ValueKey<String>('add-bot-skill-manual-${skill.id}'),
                  label: strings.manualActivation,
                  description: strings.manualActivationDescription,
                  selected: mode == SkillActivationMode.manual,
                  onPressed:
                      () => _setMode(skill.id, SkillActivationMode.manual),
                ),
                _buildModeChoice(
                  key: ValueKey<String>('add-bot-skill-always-${skill.id}'),
                  label: strings.alwaysActivation,
                  description: strings.alwaysActivationDescription,
                  selected: mode == SkillActivationMode.always,
                  onPressed:
                      () => _setMode(skill.id, SkillActivationMode.always),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeChoice({
    required Key key,
    required String label,
    required String description,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return ShadTooltip(
      builder: (context) => Text(description),
      child:
          selected
              ? ShadButton.secondary(
                key: key,
                size: ShadButtonSize.sm,
                width: 0,
                onPressed: onPressed,
                leading: const Icon(LucideIcons.check, size: 14),
                child: Text(label),
              )
              : ShadButton.outline(
                key: key,
                size: ShadButtonSize.sm,
                width: 0,
                onPressed: onPressed,
                child: Text(label),
              ),
    );
  }

  Widget _buildPagination({
    required String keyPrefix,
    required int currentPage,
    required int totalPages,
    required bool hasPreviousPage,
    required bool hasNextPage,
    required VoidCallback onPreviousPage,
    required VoidCallback onNextPage,
  }) {
    final localizations = MaterialLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShadTooltip(
          builder: (context) => Text(localizations.previousPageTooltip),
          child: ShadIconButton.outline(
            key: ValueKey<String>('$keyPrefix-previous-page'),
            width: 32,
            height: 32,
            padding: EdgeInsets.zero,
            iconSize: 16,
            enabled: hasPreviousPage,
            onPressed: onPreviousPage,
            icon: const Icon(LucideIcons.chevronLeft),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$currentPage / $totalPages',
          key: ValueKey<String>('$keyPrefix-page-indicator'),
        ),
        const SizedBox(width: 12),
        ShadTooltip(
          builder: (context) => Text(localizations.nextPageTooltip),
          child: ShadIconButton.outline(
            key: ValueKey<String>('$keyPrefix-next-page'),
            width: 32,
            height: 32,
            padding: EdgeInsets.zero,
            iconSize: 16,
            enabled: hasNextPage,
            onPressed: onNextPage,
            icon: const Icon(LucideIcons.chevronRight),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddSkillDialog() async {
    if (viewModel.availableSkills.isEmpty) return;
    viewModel.resetAvailablePage();
    await showShadDialog<void>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (dialogContext, refresh) => ShadDialog(
                  title: Text(S.of(context).addSkill),
                  description: Text(S.of(context).botSkillsDescription),
                  constraints: const BoxConstraints(maxWidth: 620),
                  actions: [
                    ShadButton.outline(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(S.of(context).cancel),
                    ),
                  ],
                  child: _buildAvailableSkills(dialogContext, refresh: refresh),
                ),
          ),
    );
  }

  Widget _buildAvailableSkills(
    BuildContext dialogContext, {
    required StateSetter refresh,
  }) {
    final strings = S.of(context);
    final skills = viewModel.paginatedAvailableSkills;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < skills.length; index++) ...[
            Padding(
              key: ValueKey<String>(
                'available-add-bot-skill-${skills[index].id}',
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skills[index].name,
                          style: ShadTheme.of(context).textTheme.small,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          skills[index].description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: DesktopThemeTokens.metaStyle(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ShadButton(
                    key: ValueKey<String>(
                      'select-add-bot-skill-${skills[index].id}',
                    ),
                    size: ShadButtonSize.sm,
                    width: 0,
                    onPressed: () => _addSkill(dialogContext, skills[index].id),
                    leading: const Icon(LucideIcons.plus, size: 14),
                    child: Text(strings.addSkill),
                  ),
                ],
              ),
            ),
            if (index != skills.length - 1) const ShadSeparator.horizontal(),
          ],
          if (viewModel.totalAvailablePages > 1) ...[
            const SizedBox(height: 12),
            _buildPagination(
              keyPrefix: 'available-add-bot-skills',
              currentPage: viewModel.currentAvailablePage,
              totalPages: viewModel.totalAvailablePages,
              hasPreviousPage: viewModel.hasPreviousAvailablePage,
              hasNextPage: viewModel.hasNextAvailablePage,
              onPreviousPage: () {
                viewModel.previousAvailablePage();
                refresh(() {});
              },
              onNextPage: () {
                viewModel.nextAvailablePage();
                refresh(() {});
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addSkill(BuildContext dialogContext, String skillId) async {
    try {
      await viewModel.addSkill(skillId);
      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
    } catch (error) {
      if (mounted) showSnackBar(context, error.toString());
    }
  }

  Future<void> _removeSkill(String skillId) async {
    try {
      await viewModel.removeSkill(skillId);
    } catch (error) {
      if (mounted) showSnackBar(context, error.toString());
    }
  }

  Future<void> _setEnabled(String skillId, bool enabled) async {
    try {
      await viewModel.setEnabled(skillId, enabled);
    } catch (error) {
      if (mounted) showSnackBar(context, error.toString());
    }
  }

  Future<void> _setMode(
    String skillId,
    SkillActivationMode activationMode,
  ) async {
    try {
      await viewModel.setActivationMode(skillId, activationMode);
    } catch (error) {
      if (mounted) showSnackBar(context, error.toString());
    }
  }
}
