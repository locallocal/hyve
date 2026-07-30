import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:stars/ui/features/skills/view_models/skill_library_view_model.dart';
import 'package:stars/utils/theme.dart';
import 'package:stars/utils/utils.dart';

class SkillLibraryPage extends StatefulWidget {
  const SkillLibraryPage({super.key, required this.viewModel});

  final SkillLibraryViewModel viewModel;

  @override
  State<SkillLibraryPage> createState() => _SkillLibraryPageState();
}

class _SkillLibraryPageState extends State<SkillLibraryPage> {
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  SkillLibraryViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: viewModel.query);
  }

  @override
  void didUpdateWidget(covariant SkillLibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != viewModel &&
        _searchController.text != viewModel.query) {
      _searchController.text = viewModel.query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    viewModel.clearSearch();
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return isDesktopOrTabletPlatform(context)
            ? _buildDesktop(context)
            : _buildMobile(context);
      },
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final strings = S.of(context);
    return ColoredBox(
      color: DesktopThemeTokens.workspaceSurface(context),
      child: SingleChildScrollView(
        key: ValueKey<String>('skill-library-page-${viewModel.currentPage}'),
        padding: DesktopThemeTokens.formPagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: DesktopThemeTokens.formContentMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.skillLibrary,
                            style: DesktopThemeTokens.pageTitleStyle(context),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            strings.skillLibraryDescription,
                            style: DesktopThemeTokens.bodyStyle(
                              context,
                            )?.copyWith(
                              color: DesktopThemeTokens.mutedText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ShadButton.outline(
                      key: const ValueKey<String>('import-skill-folder'),
                      enabled: !viewModel.isImporting,
                      onPressed: () => _importDirectory(context),
                      leading: const Icon(LucideIcons.folderUp, size: 16),
                      child: Text(strings.importSkillFolder),
                    ),
                    const SizedBox(width: 8),
                    ShadButton(
                      key: const ValueKey<String>('import-skill-zip'),
                      enabled: !viewModel.isImporting,
                      onPressed: () => _importZip(context),
                      leading:
                          viewModel.isImporting
                              ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(LucideIcons.fileArchive, size: 16),
                      child: Text(
                        viewModel.isImporting
                            ? strings.importingSkill
                            : strings.importSkillZip,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ShadAlert(
                  icon: const Icon(LucideIcons.shieldCheck),
                  title: Text(strings.skillNotExecutable),
                  description: Text(strings.skillSafetyDescription),
                ),
                if (viewModel.error != null) ...[
                  const SizedBox(height: 16),
                  ShadAlert.destructive(
                    icon: const Icon(LucideIcons.circleAlert),
                    title: Text(
                      strings.skillImportFailed(viewModel.error.toString()),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _buildSearchField(context),
                const SizedBox(height: 24),
                if (viewModel.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: ShadProgress(),
                    ),
                  )
                else if (viewModel.skills.isEmpty)
                  _buildDesktopEmpty(context)
                else if (viewModel.filteredSkills.isEmpty)
                  _buildDesktopSearchEmpty(context)
                else
                  _buildDesktopSkills(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopEmpty(BuildContext context) {
    final strings = S.of(context);
    return DesktopEmptyStateCard(
      icon: LucideIcons.wrench,
      title: strings.noSkillsInstalled,
      description: strings.noSkillsInstalledDescription,
    );
  }

  Widget _buildDesktopSearchEmpty(BuildContext context) {
    final strings = S.of(context);
    return DesktopEmptyStateCard(
      icon: LucideIcons.search,
      title: strings.noMatchingSkills,
      description: strings.tryDifferentSearch,
      action: ShadButton(
        size: ShadButtonSize.sm,
        onPressed: _clearSearch,
        leading: const Icon(LucideIcons.x, size: 16),
        child: Text(strings.clearSearch),
      ),
    );
  }

  Widget _buildDesktopSkills(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 800 ? 2 : 1;
        const gap = 14.0;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final skill in viewModel.paginatedSkills)
                  SizedBox(
                    width: itemWidth,
                    child: _DesktopSkillCard(
                      skill: skill,
                      onOpen: () => _showDetails(context, skill),
                      onUninstall: () => _confirmUninstall(context, skill),
                    ),
                  ),
              ],
            ),
            if (viewModel.totalPages > 1) ...[
              const SizedBox(height: 20),
              _buildPagination(context, desktop: true),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPagination(BuildContext context, {required bool desktop}) {
    final localizations = MaterialLocalizations.of(context);
    final pageIndicator = Semantics(
      label: '${viewModel.currentPage} / ${viewModel.totalPages}',
      child: Text(
        '${viewModel.currentPage} / ${viewModel.totalPages}',
        key: const ValueKey<String>('skill-page-indicator'),
      ),
    );
    if (!desktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            key: const ValueKey<String>('skill-previous-page'),
            tooltip: localizations.previousPageTooltip,
            onPressed:
                viewModel.hasPreviousPage ? viewModel.previousPage : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          const SizedBox(width: 12),
          pageIndicator,
          const SizedBox(width: 12),
          IconButton(
            key: const ValueKey<String>('skill-next-page'),
            tooltip: localizations.nextPageTooltip,
            onPressed: viewModel.hasNextPage ? viewModel.nextPage : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShadButton.outline(
          key: const ValueKey<String>('skill-previous-page'),
          size: ShadButtonSize.sm,
          enabled: viewModel.hasPreviousPage,
          onPressed: viewModel.previousPage,
          leading: const Icon(LucideIcons.chevronLeft, size: 16),
          child: Text(localizations.previousPageTooltip),
        ),
        const SizedBox(width: 16),
        pageIndicator,
        const SizedBox(width: 16),
        ShadButton.outline(
          key: const ValueKey<String>('skill-next-page'),
          size: ShadButtonSize.sm,
          enabled: viewModel.hasNextPage,
          onPressed: viewModel.nextPage,
          trailing: const Icon(LucideIcons.chevronRight, size: 16),
          child: Text(localizations.nextPageTooltip),
        ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    final strings = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.skillLibrary),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'folder') {
                _importDirectory(context);
              } else {
                _importZip(context);
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'folder',
                    child: Text(strings.importSkillFolder),
                  ),
                  PopupMenuItem(
                    value: 'zip',
                    child: Text(strings.importSkillZip),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _buildSearchField(context),
          ),
          Expanded(child: _buildMobileBody(context)),
        ],
      ),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    final strings = S.of(context);
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.skills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.build_outlined, size: 40),
              const SizedBox(height: 12),
              Text(strings.noSkillsInstalled),
              const SizedBox(height: 6),
              Text(
                strings.noSkillsInstalledDescription,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    if (viewModel.filteredSkills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 40),
              const SizedBox(height: 12),
              Text(strings.noMatchingSkills),
              const SizedBox(height: 6),
              Text(strings.tryDifferentSearch, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _clearSearch,
                child: Text(strings.clearSearch),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            key: ValueKey<String>(
              'skill-library-mobile-page-${viewModel.currentPage}',
            ),
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.paginatedSkills.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final skill = viewModel.paginatedSkills[index];
              return Card(
                child: ListTile(
                  title: Text(skill.name),
                  subtitle: Text(
                    skill.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _showDetails(context, skill),
                  trailing: IconButton(
                    tooltip: strings.uninstallSkill,
                    onPressed: () => _confirmUninstall(context, skill),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            },
          ),
        ),
        if (viewModel.totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPagination(context, desktop: false),
          ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final strings = S.of(context);
    final hasQuery = viewModel.query.isNotEmpty;
    return StarsSearchField(
      key: const ValueKey<String>('skill-search-field'),
      hintText: strings.searchSkills,
      semanticLabel: strings.searchSkills,
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: viewModel.search,
      suffixIcon:
          hasQuery
              ? IconButton(
                key: const ValueKey<String>('clear-skill-search'),
                tooltip: strings.clearSearch,
                onPressed: _clearSearch,
                icon: const Icon(LucideIcons.x, size: 16),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              )
              : null,
    );
  }

  Future<void> _importDirectory(BuildContext context) async {
    await _runImport(context, viewModel.importDirectory);
  }

  Future<void> _importZip(BuildContext context) async {
    await _runImport(context, viewModel.importZipArchive);
  }

  Future<void> _runImport(
    BuildContext context,
    Future<SkillDescriptor?> Function() action,
  ) async {
    try {
      final skill = await action();
      if (!context.mounted || skill == null) return;
      _showMessage(context, S.of(context).skillImportSucceeded);
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, S.of(context).skillImportFailed(error.toString()));
    }
  }

  Future<void> _showDetails(BuildContext context, SkillDescriptor skill) async {
    try {
      final content = await viewModel.loadContent(skill.id);
      if (!context.mounted) return;
      if (isDesktopOrTabletPlatform(context)) {
        await showShadDialog<void>(
          context: context,
          builder: (dialogContext) => _SkillDetailsDialog(content: content),
        );
      } else {
        await showDialog<void>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: Text(skill.name),
                content: SizedBox(
                  width: 520,
                  child: SingleChildScrollView(
                    child: SelectableText(content.instructions),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      MaterialLocalizations.of(context).closeButtonLabel,
                    ),
                  ),
                ],
              ),
        );
      }
    } catch (error) {
      if (context.mounted) _showMessage(context, error.toString());
    }
  }

  Future<void> _confirmUninstall(
    BuildContext context,
    SkillDescriptor skill,
  ) async {
    final strings = S.of(context);
    final confirmed =
        isDesktopOrTabletPlatform(context)
            ? await showShadDialog<bool>(
              context: context,
              variant: ShadDialogVariant.alert,
              builder:
                  (dialogContext) => ShadDialog.alert(
                    title: Text(strings.uninstallSkill),
                    description: Text(
                      strings.confirmUninstallSkill(skill.name),
                    ),
                    actions: [
                      ShadButton.outline(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(strings.cancel),
                      ),
                      ShadButton.destructive(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(strings.uninstallSkill),
                      ),
                    ],
                  ),
            )
            : await showDialog<bool>(
              context: context,
              builder:
                  (dialogContext) => AlertDialog(
                    title: Text(strings.uninstallSkill),
                    content: Text(strings.confirmUninstallSkill(skill.name)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(strings.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(strings.uninstallSkill),
                      ),
                    ],
                  ),
            );
    if (confirmed != true) return;
    try {
      await viewModel.uninstall(skill.id);
    } catch (error) {
      if (context.mounted) _showMessage(context, error.toString());
    }
  }

  void _showMessage(BuildContext context, String message) {
    if (isDesktopOrTabletPlatform(context)) {
      ShadSonner.of(context).show(ShadToast(title: Text(message)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _DesktopSkillCard extends StatefulWidget {
  const _DesktopSkillCard({
    required this.skill,
    required this.onOpen,
    required this.onUninstall,
  });

  final SkillDescriptor skill;
  final VoidCallback onOpen;
  final VoidCallback onUninstall;

  @override
  State<_DesktopSkillCard> createState() => _DesktopSkillCardState();
}

class _DesktopSkillCardState extends State<_DesktopSkillCard> {
  static const double _menuContentWidth = 184;
  static const EdgeInsets _menuPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );

  final ShadPopoverController _menuController = ShadPopoverController();
  final FocusNode _menuFocusNode = FocusNode(
    debugLabel: 'desktop-skill-card-actions',
  );
  bool _menuActionInvokedByPointer = false;

  @override
  void dispose() {
    _menuController.dispose();
    _menuFocusNode.dispose();
    super.dispose();
  }

  void _invokeMenuAction(VoidCallback action) {
    final invokedByPointer = _menuActionInvokedByPointer;
    _menuActionInvokedByPointer = false;
    if (invokedByPointer) {
      FocusManager.instance.primaryFocus?.unfocus();
      _menuFocusNode.unfocus();
    }
    _menuController.hide();
    action();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!invokedByPointer &&
          FocusManager.instance.highlightMode ==
              FocusHighlightMode.traditional) {
        _menuFocusNode.requestFocus();
      } else {
        _menuFocusNode.unfocus();
      }
    });
  }

  Widget _buildActionMenu(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return ShadPopover(
      controller: _menuController,
      anchor: const ShadAnchorAuto(
        offset: Offset(0, 4),
        followerAnchor: AlignmentDirectional.topStart,
        targetAnchor: AlignmentDirectional.bottomEnd,
        fallback: ShadAnchorAuto(
          offset: Offset(0, -4),
          followerAnchor: AlignmentDirectional.bottomStart,
          targetAnchor: AlignmentDirectional.topEnd,
        ),
      ),
      padding: EdgeInsets.zero,
      popover:
          (context) => Listener(
            onPointerDown: (_) => _menuActionInvokedByPointer = true,
            onPointerUp:
                (_) => WidgetsBinding.instance.addPostFrameCallback((_) {
                  _menuActionInvokedByPointer = false;
                }),
            onPointerCancel: (_) => _menuActionInvokedByPointer = false,
            child: SizedBox(
              key: ValueKey<String>(
                'desktop-skill-action-menu-${widget.skill.id}',
              ),
              width: _menuContentWidth + _menuPadding.horizontal,
              child: Padding(
                padding: _menuPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShadButton.ghost(
                      key: ValueKey<String>(
                        'desktop-skill-details-${widget.skill.id}',
                      ),
                      size: ShadButtonSize.sm,
                      onPressed: () => _invokeMenuAction(widget.onOpen),
                      mainAxisAlignment: MainAxisAlignment.start,
                      leading: const Icon(LucideIcons.info, size: 16),
                      child: Text(S.of(context).details),
                    ),
                    ShadButton.raw(
                      key: ValueKey<String>(
                        'desktop-skill-uninstall-${widget.skill.id}',
                      ),
                      variant: ShadButtonVariant.ghost,
                      size: ShadButtonSize.sm,
                      foregroundColor: colors.destructive,
                      onPressed: () => _invokeMenuAction(widget.onUninstall),
                      mainAxisAlignment: MainAxisAlignment.start,
                      leading: const Icon(LucideIcons.trash2, size: 16),
                      child: Text(S.of(context).uninstall),
                    ),
                  ],
                ),
              ),
            ),
          ),
      child: StarsDesktopIconAction(
        key: ValueKey<String>('desktop-skill-menu-button-${widget.skill.id}'),
        icon: LucideIcons.ellipsis,
        label: MaterialLocalizations.of(context).showMenuTooltip,
        focusNode: _menuFocusNode,
        onPressed: _menuController.toggle,
        hoverBackgroundColor: Colors.transparent,
        showFocusRing: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return ShadCard(
      width: double.infinity,
      title: Row(
        children: [
          Expanded(child: Text(widget.skill.name)),
          ShadBadge.outline(
            child: Text(
              widget.skill.version.isEmpty
                  ? strings.skillUserScope
                  : 'v${widget.skill.version}',
            ),
          ),
        ],
      ),
      description: Text(
        widget.skill.description,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      footer: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: _buildActionMenu(context),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 10),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (widget.skill.hasScripts)
              ShadBadge.destructive(child: Text(strings.skillScriptsDisabled)),
            if (widget.skill.hasReferences)
              ShadBadge.secondary(
                child: Text(strings.skillReferencesAvailable),
              ),
            if (widget.skill.hasAssets)
              ShadBadge.secondary(child: Text(strings.skillAssetsAvailable)),
            if (widget.skill.diagnostics.isNotEmpty)
              ShadBadge.outline(
                child: Text(
                  '${strings.skillValidationWarnings} '
                  '${widget.skill.diagnostics.length}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SkillDetailsDialog extends StatelessWidget {
  const _SkillDetailsDialog({required this.content});

  final SkillContent content;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final skill = content.descriptor;
    return ShadDialog(
      title: Text(skill.name),
      description: Text(skill.description),
      constraints: const BoxConstraints(maxWidth: 720),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
      child: SizedBox(
        height: 520,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                label: strings.skillVersion,
                value: skill.version.isEmpty ? '—' : skill.version,
              ),
              _DetailRow(label: strings.skillSource, value: skill.sourceUri),
              _DetailRow(
                label: strings.skillDigest,
                value: skill.contentDigest,
              ),
              if (skill.compatibility.isNotEmpty)
                _DetailRow(
                  label: strings.skillCompatibility,
                  value: skill.compatibility,
                ),
              _DetailRow(
                label: strings.skillFiles,
                value: content.files.join('\n'),
              ),
              if (skill.diagnostics.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  strings.skillValidationWarnings,
                  style: ShadTheme.of(context).textTheme.small,
                ),
                const SizedBox(height: 6),
                for (final diagnostic in skill.diagnostics)
                  Text('• ${diagnostic.message}'),
              ],
              const SizedBox(height: 18),
              const ShadSeparator.horizontal(),
              const SizedBox(height: 18),
              SelectableText(
                content.instructions,
                style: ShadTheme.of(context).textTheme.p,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: ShadTheme.of(context).textTheme.muted),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
