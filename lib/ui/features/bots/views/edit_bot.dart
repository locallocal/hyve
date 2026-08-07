import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/core/dependency_injection/app_scope.dart';
import 'package:stars/ui/core/view_models/token_usage_timeline.dart';
import 'package:stars/ui/core/widgets/common.dart';
import 'package:stars/ui/core/widgets/logo.dart';
import 'package:stars/ui/core/widgets/token_usage_indicator.dart';
import 'package:stars/ui/features/bots/view_models/bot_token_usage_view_model.dart';
import 'package:stars/ui/features/bots/view_models/bot_skill_view_model.dart';
import 'package:stars/ui/features/bots/views/bot_mcp_tool_picker.dart';
import 'package:stars/ui/features/bots/views/bot_token_usage.dart';
import 'package:stars/ui/features/bots/views/skill_description_test_dialog.dart';
import 'package:stars/utils/theme.dart';
import 'package:stars/utils/utils.dart';

class EditBotPage extends StatefulWidget {
  final Bot bot;
  final Future<void> Function(Bot) onBotUpdated;
  final Future<void> Function() onBotDeleted;
  final Future<String?> Function()? avatarPicker;
  final bool embedded;
  final bool readOnly;
  final BotSkillViewModel? skillViewModel;
  final Future<BotMcpCatalog> Function()? mcpCatalogLoader;

  const EditBotPage({
    super.key,
    required this.bot,
    required this.onBotUpdated,
    required this.onBotDeleted,
    this.avatarPicker,
    this.embedded = false,
    this.readOnly = false,
    this.skillViewModel,
    this.mcpCatalogLoader,
  });

  @override
  State<EditBotPage> createState() => _EditAIBotPageState();
}

class _EditAIBotPageState extends State<EditBotPage> {
  final _skillSearchController = TextEditingController();
  late final TextEditingController nameController;
  late final TextEditingController providerController;
  late final TextEditingController apiTypeController;
  late final TextEditingController apiKeyController;
  late final TextEditingController baseURLController;
  late final TextEditingController selectedModelController;
  late final TextEditingController systemPromptController;

  late String selectedProvider;
  late String selectedModel;
  bool _isPasswordVisible = false;
  bool _isSaving = false;
  bool _isSaved = false;
  bool _isDeleting = false;
  int _editRevision = 0;
  File? avatarImage;
  BotTokenUsageViewModel? _tokenUsageViewModel;
  BotSkillViewModel? _skillViewModel;
  bool _ownsSkillViewModel = false;
  List<McpServer> _mcpServers = const [];
  Map<String, List<McpToolDescriptor>> _mcpToolsByServer = const {};
  late Set<String> _mcpServerIds;
  late Set<McpToolConfiguration> _mcpToolConfigurations;
  late bool _modelSupportsMcp;
  late bool _initialModelSupportsMcp;
  late bool _modelSupportsAutomaticSkillActivation;
  late bool _initialModelSupportsAutomaticSkillActivation;
  bool _isLoadingMcpServers = false;
  bool _startedLoadingMcpServers = false;
  bool _resolvedInitialMcpCapability = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.bot.name);
    providerController = TextEditingController(text: widget.bot.provider);
    apiTypeController = TextEditingController(text: widget.bot.apiType);
    apiKeyController = TextEditingController(text: widget.bot.apiKey);
    baseURLController = TextEditingController(text: widget.bot.baseURL);
    selectedModelController = TextEditingController(text: widget.bot.model);
    systemPromptController = TextEditingController(
      text: widget.bot.systemPrompt.isNotEmpty ? widget.bot.systemPrompt : '',
    );
    selectedProvider = widget.bot.provider;
    selectedModel = widget.bot.model;
    _mcpServerIds = widget.bot.mcpServerIds;
    _mcpToolConfigurations = widget.bot.mcpTools;
    _modelSupportsMcp = widget.bot.configuredSupportsMcp ?? false;
    _initialModelSupportsMcp = _modelSupportsMcp;
    _modelSupportsAutomaticSkillActivation =
        widget.bot.configuredSupportsAutomaticSkillActivation ?? false;
    _initialModelSupportsAutomaticSkillActivation =
        _modelSupportsAutomaticSkillActivation;
    if (widget.bot.avatar.isNotEmpty) {
      avatarImage = File(widget.bot.avatar);
    }
    final injectedSkillViewModel = widget.skillViewModel;
    if (injectedSkillViewModel != null) {
      _skillViewModel =
          injectedSkillViewModel..addListener(_handleSkillChanged);
      _modelSupportsAutomaticSkillActivation =
          injectedSkillViewModel.supportsAutoActivation;
      _initialModelSupportsAutomaticSkillActivation =
          _modelSupportsAutomaticSkillActivation;
      unawaited(injectedSkillViewModel.load());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dependencies = AppScope.maybeOf(context);
    if (!_startedLoadingMcpServers) {
      final loader =
          widget.mcpCatalogLoader ??
          (dependencies == null
              ? null
              : () async {
                final servers =
                    await dependencies.mcpServerRepository.getServers();
                final tools = await Future.wait(
                  servers.map(
                    (server) async => (
                      server.id,
                      await dependencies.mcpServerRepository.getTools(
                        server.id,
                      ),
                    ),
                  ),
                );
                return (
                  servers: servers,
                  toolsByServer: {
                    for (final entry in tools) entry.$1: entry.$2,
                  },
                );
              });
      if (loader != null) {
        _startedLoadingMcpServers = true;
        unawaited(_loadMcpCatalog(loader));
      }
    }
    if (dependencies == null) return;
    if (!_resolvedInitialMcpCapability) {
      _resolvedInitialMcpCapability = true;
      final supportsMcp =
          dependencies.aiProviderRepository.create(widget.bot).supportMcp();
      final supportsAutomaticSkillActivation =
          widget.bot.configuredSupportsAutomaticSkillActivation ??
          dependencies.aiProviderRepository
              .create(widget.bot)
              .capabilities
              .supportsAutomaticSkillActivation;
      _initialModelSupportsMcp = supportsMcp;
      _initialModelSupportsAutomaticSkillActivation =
          supportsAutomaticSkillActivation;
      if (supportsMcp != _modelSupportsMcp) {
        _modelSupportsMcp = supportsMcp;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
      if (supportsAutomaticSkillActivation !=
          _modelSupportsAutomaticSkillActivation) {
        _modelSupportsAutomaticSkillActivation =
            supportsAutomaticSkillActivation;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
    }
    if (widget.readOnly && _tokenUsageViewModel == null) {
      _tokenUsageViewModel = dependencies.createBotTokenUsageViewModel(
        widget.bot.id,
      )..addListener(_handleTokenUsageChanged);
      unawaited(_tokenUsageViewModel!.load());
    }
    if (_skillViewModel == null) {
      _ownsSkillViewModel = true;
      _skillViewModel = dependencies.createBotSkillViewModel(widget.bot)
        ..addListener(_handleSkillChanged);
      unawaited(_skillViewModel!.load());
    }
    _skillViewModel?.updateSupportsAutoActivation(
      _modelSupportsAutomaticSkillActivation,
    );
  }

  void _handleTokenUsageChanged() {
    if (mounted) setState(() {});
  }

  void _handleSkillChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadMcpCatalog(Future<BotMcpCatalog> Function() loader) async {
    setState(() => _isLoadingMcpServers = true);
    try {
      final catalog = await loader();
      if (!mounted) return;
      setState(() {
        _mcpServers = List<McpServer>.unmodifiable(
          List<McpServer>.of(catalog.servers)
            ..sort((left, right) => left.name.compareTo(right.name)),
        );
        _mcpToolsByServer = Map<String, List<McpToolDescriptor>>.unmodifiable({
          for (final entry in catalog.toolsByServer.entries)
            entry.key: List<McpToolDescriptor>.unmodifiable(entry.value),
        });
      });
    } on Object {
      if (mounted) {
        setState(() {
          _mcpServers = const [];
          _mcpToolsByServer = const {};
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingMcpServers = false);
    }
  }

  Future<void> _pickImage() async {
    if (widget.readOnly) return;
    final imagePath = await widget.avatarPicker?.call();

    if (imagePath != null && mounted) {
      setState(() {
        avatarImage = File(imagePath);
        _editRevision += 1;
        _isSaved = false;
      });
    }
  }

  @override
  void dispose() {
    _skillSearchController.dispose();
    nameController.dispose();
    providerController.dispose();
    apiTypeController.dispose();
    apiKeyController.dispose();
    baseURLController.dispose();
    selectedModelController.dispose();
    systemPromptController.dispose();
    _tokenUsageViewModel
      ?..removeListener(_handleTokenUsageChanged)
      ..dispose();
    _skillViewModel?.removeListener(_handleSkillChanged);
    if (_ownsSkillViewModel) _skillViewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.bodyLarge?.fontSize;
    return Scaffold(
      key:
          widget.embedded
              ? const ValueKey<String>('desktop-bot-detail-scaffold')
              : null,
      backgroundColor:
          widget.embedded ? DesktopThemeTokens.workspaceSurface(context) : null,
      appBar:
          widget.embedded
              ? null
              : AppBar(
                centerTitle: true,
                title: Text(
                  widget.readOnly
                      ? S.of(context).details
                      : S.of(context).editBot,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.surface,
                scrolledUnderElevation: 0,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                actions: [if (!widget.readOnly) _buildDeleteButton(fontSize)],
              ),
      body: Center(
        child: ConstrainedBox(
          key:
              widget.embedded
                  ? const ValueKey<String>('desktop-bot-detail-content')
                  : null,
          constraints: BoxConstraints(
            maxWidth:
                widget.embedded
                    ? DesktopThemeTokens.formContentMaxWidth +
                        DesktopThemeTokens.formPagePadding.horizontal
                    : 800,
          ),
          child: SingleChildScrollView(
            padding:
                widget.embedded
                    ? DesktopThemeTokens.formPagePadding
                    : const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.embedded) ...[
                  Row(
                    children: [
                      ShadTooltip(
                        builder: (context) => Text(S.of(context).botAvatar),
                        child: ShadButton.ghost(
                          width: 56,
                          height: 56,
                          padding: EdgeInsets.zero,
                          enabled: !widget.readOnly,
                          onPressed: widget.readOnly ? null : _pickImage,
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                avatarImage == null
                                    ? getFrostedProviderColor(
                                      selectedProvider,
                                      Theme.of(context).colorScheme.primary,
                                    )
                                    : Theme.of(context).colorScheme.primary,
                            backgroundImage:
                                avatarImage != null
                                    ? FileImage(avatarImage!)
                                    : null,
                            child:
                                avatarImage == null
                                    ? buildProviderLogo(
                                      context,
                                      '',
                                      selectedProvider,
                                      28,
                                    )
                                    : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.bot.name,
                              style: DesktopThemeTokens.pageTitleStyle(context),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${widget.bot.provider} · ${widget.bot.model}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DesktopThemeTokens.metaStyle(context),
                            ),
                          ],
                        ),
                      ),
                      if (!widget.readOnly) _buildDeleteButton(fontSize),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                // 头像选择
                if (!widget.embedded) ...[
                  Center(
                    child: GestureDetector(
                      onTap: widget.readOnly ? null : _pickImage,
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor:
                            avatarImage == null
                                ? getFrostedProviderColor(
                                  selectedProvider,
                                  Theme.of(context).colorScheme.primary,
                                )
                                : Theme.of(context).colorScheme.primary,
                        backgroundImage:
                            avatarImage != null
                                ? FileImage(avatarImage!)
                                : null,
                        child:
                            avatarImage == null
                                ? buildProviderLogo(
                                  context,
                                  '',
                                  selectedProvider,
                                  64,
                                )
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 基本信息分组
                _buildFormSection(
                  context,
                  S.of(context).basicInformation,
                  [_buildNameInput(fontSize)],
                  sectionKey: const ValueKey<String>(
                    'desktop-bot-basic-section',
                  ),
                ),
                SizedBox(height: widget.embedded ? 20 : 16),

                // API提供商分组
                _buildFormSection(
                  context,
                  S.of(context).providerInformation,
                  [
                    _buildProviderInput(fontSize),
                    _buildApiTypeInput(fontSize),
                    _buildApiAddressInput(fontSize),
                    _buildApiKeyInput(fontSize),
                  ],
                  sectionKey: const ValueKey<String>(
                    'desktop-bot-provider-section',
                  ),
                ),
                SizedBox(height: widget.embedded ? 20 : 16),

                // API提供商分组
                _buildFormSection(
                  context,
                  S.of(context).modelConfiguration,
                  [
                    _buildModelsInput(fontSize),
                    _buildSystemPromptInput(fontSize),
                  ],
                  sectionKey: const ValueKey<String>(
                    'desktop-bot-model-section',
                  ),
                ),
                if (_modelSupportsMcp) ...[
                  SizedBox(height: widget.embedded ? 20 : 16),
                  _buildFormSection(
                    context,
                    S.of(context).mcpServers,
                    [_buildMcpToolPicker()],
                    sectionKey: const ValueKey<String>(
                      'desktop-bot-mcp-section',
                    ),
                  ),
                ],
                if (_modelSupportsAutomaticSkillActivation) ...[
                  SizedBox(height: widget.embedded ? 20 : 16),
                  _buildFormSection(
                    context,
                    S.of(context).botSkills,
                    [_buildBotSkills()],
                    sectionKey: const ValueKey<String>(
                      'desktop-bot-skills-section',
                    ),
                  ),
                ],
                if (widget.readOnly) ...[
                  SizedBox(height: widget.embedded ? 20 : 16),
                  _buildFormSection(
                    context,
                    S.of(context).tokenUsage,
                    [_buildTokenUsage()],
                    sectionKey: const ValueKey<String>(
                      'desktop-bot-token-usage-section',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          widget.readOnly
              ? null
              : widget.embedded
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShadSeparator.horizontal(),
                  ColoredBox(
                    key: const ValueKey<String>(
                      'desktop-bot-save-bar-background',
                    ),
                    color: DesktopThemeTokens.workspaceSurface(context),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ShadButton(
                            key: const ValueKey<String>('desktop-bot-save'),
                            enabled: !_isSaving && !_isSaved && !_isDeleting,
                            onPressed:
                                _isSaving || _isSaved || _isDeleting
                                    ? null
                                    : _saveBot,
                            leading:
                                _isSaving
                                    ? SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            ShadTheme.of(
                                              context,
                                            ).colorScheme.primaryForeground,
                                      ),
                                    )
                                    : Icon(
                                      _isSaved
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.check_rounded,
                                      size: 17,
                                    ),
                            child: Text(
                              _isSaving
                                  ? S.of(context).savingChanges
                                  : _isSaved
                                  ? S.of(context).changesSaved
                                  : S.of(context).saveChanges,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _saveBot,
                  child: Text(
                    S.of(context).saveChanges,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildTokenUsage() {
    final viewModel = _tokenUsageViewModel;
    if (viewModel?.isLoading ?? false) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    final usage = viewModel?.usage ?? ModelTokenUsage.empty;
    if (!widget.embedded) {
      return TokenUsageIndicator(usage: usage, showBreakdown: true);
    }
    return BotTokenUsagePanel(
      usage: usage,
      conversationUsages: viewModel?.conversationUsages ?? const [],
      dailyBuckets: viewModel?.dailyBuckets ?? const [],
      visibleBuckets: viewModel?.visibleBuckets ?? const [],
      granularity: viewModel?.granularity ?? TokenUsageGranularity.day,
      selectedDay: viewModel?.selectedDay,
      onShowDaily: viewModel?.showDaily,
      onBucketSelected:
          viewModel == null ||
                  viewModel.granularity == TokenUsageGranularity.hour
              ? null
              : (bucket) => viewModel.selectDay(bucket.start),
    );
  }

  Widget _buildBotSkills() {
    final viewModel = _skillViewModel;
    final strings = S.of(context);
    if (viewModel?.isLoading ?? false) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (viewModel == null || viewModel.skills.isEmpty) {
      return Text(
        strings.noSkillsInstalledDescription,
        style:
            widget.embedded
                ? DesktopThemeTokens.bodyStyle(
                  context,
                )?.copyWith(color: DesktopThemeTokens.mutedText(context))
                : Theme.of(context).textTheme.bodyMedium,
      );
    }

    final addButton =
        widget.embedded
            ? ShadButton.outline(
              key: const ValueKey<String>('add-bot-skill'),
              size: ShadButtonSize.sm,
              width: 0,
              enabled: !widget.readOnly && viewModel.availableSkills.isNotEmpty,
              onPressed: widget.readOnly ? null : _showAddSkillDialog,
              leading: const Icon(LucideIcons.plus, size: 15),
              child: Text(strings.addSkill),
            )
            : OutlinedButton.icon(
              key: const ValueKey<String>('add-bot-skill'),
              onPressed:
                  widget.readOnly || viewModel.availableSkills.isEmpty
                      ? null
                      : _showAddSkillDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(strings.addSkill),
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.botSkillsDescription,
                style:
                    widget.embedded
                        ? DesktopThemeTokens.metaStyle(context)
                        : Theme.of(context).textTheme.bodySmall,
              ),
            ),
            if (!widget.readOnly) ...[
              const SizedBox(width: 12),
              if (viewModel.availableSkills.isEmpty)
                Tooltip(message: strings.allSkillsAdded, child: addButton)
              else
                addButton,
            ],
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
                  style:
                      widget.embedded
                          ? ShadTheme.of(context).textTheme.small
                          : Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  strings.noBotSkillsAddedDescription,
                  style:
                      widget.embedded
                          ? DesktopThemeTokens.metaStyle(context)
                          : Theme.of(context).textTheme.bodySmall,
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
            _buildBotSkillRow(viewModel.paginatedAddedSkills[index], viewModel),
            if (index != viewModel.paginatedAddedSkills.length - 1)
              if (widget.embedded)
                const ShadSeparator.horizontal()
              else
                const Divider(height: 1),
          ],
          if (viewModel.totalAddedPages > 1) ...[
            const SizedBox(height: 12),
            _buildSkillPagination(
              keyPrefix: 'bot-skills',
              currentPage: viewModel.currentAddedPage,
              totalPages: viewModel.totalAddedPages,
              hasPreviousPage: viewModel.hasPreviousAddedPage,
              hasNextPage: viewModel.hasNextAddedPage,
              onPreviousPage: viewModel.previousAddedPage,
              onNextPage: viewModel.nextAddedPage,
              embedded: widget.embedded,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildBotSkillRow(SkillDescriptor skill, BotSkillViewModel viewModel) {
    final strings = S.of(context);
    final binding = viewModel.bindingFor(skill.id);
    final enabled = binding?.enabled ?? false;
    final switchWidget = Semantics(
      label: strings.autoActivation,
      toggled: enabled,
      enabled: !widget.readOnly,
      child:
          widget.embedded
              ? ShadSwitch(
                key: ValueKey<String>('bot-skill-toggle-${skill.id}'),
                value: enabled,
                enabled: !widget.readOnly,
                onChanged:
                    widget.readOnly
                        ? null
                        : (value) => _setSkillEnabled(skill.id, value),
              )
              : Switch(
                key: ValueKey<String>('bot-skill-toggle-${skill.id}'),
                value: enabled,
                onChanged:
                    widget.readOnly
                        ? null
                        : (value) => _setSkillEnabled(skill.id, value),
              ),
    );
    final removeButton =
        widget.embedded
            ? ShadTooltip(
              builder: (context) => Text(strings.removeSkill),
              child: ShadIconButton.ghost(
                key: ValueKey<String>('remove-bot-skill-${skill.id}'),
                width: 30,
                height: 30,
                padding: EdgeInsets.zero,
                iconSize: 16,
                enabled: !widget.readOnly,
                onPressed:
                    widget.readOnly ? null : () => _removeBotSkill(skill.id),
                icon: const Icon(LucideIcons.trash2),
              ),
            )
            : IconButton(
              key: ValueKey<String>('remove-bot-skill-${skill.id}'),
              tooltip: strings.removeSkill,
              onPressed:
                  widget.readOnly ? null : () => _removeBotSkill(skill.id),
              icon: const Icon(Icons.delete_outline_rounded),
            );

    return Padding(
      key: ValueKey<String>('bot-skill-${skill.id}'),
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
                      style:
                          widget.embedded
                              ? ShadTheme.of(context).textTheme.small
                              : Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      skill.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          widget.embedded
                              ? DesktopThemeTokens.metaStyle(context)
                              : Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ExcludeSemantics(
                child: Text(
                  strings.autoActivation,
                  key: ValueKey<String>('bot-skill-auto-${skill.id}'),
                  style:
                      widget.embedded
                          ? DesktopThemeTokens.metaStyle(context)
                          : Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 12),
              switchWidget,
              if (!widget.readOnly) ...[const SizedBox(width: 8), removeButton],
            ],
          ),
          if (enabled && viewModel.supportsAutoActivation) ...[
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ShadButton.ghost(
                key: ValueKey<String>('test-skill-description-${skill.id}'),
                size: ShadButtonSize.sm,
                width: 0,
                onPressed: () => _showSkillDescriptionTest(skill),
                leading: const Icon(LucideIcons.flaskConical, size: 14),
                child: Text(strings.testSkillDescription),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillPagination({
    required String keyPrefix,
    required int currentPage,
    required int totalPages,
    required bool hasPreviousPage,
    required bool hasNextPage,
    required VoidCallback onPreviousPage,
    required VoidCallback onNextPage,
    required bool embedded,
  }) {
    final localizations = MaterialLocalizations.of(context);
    final indicator = Text(
      '$currentPage / $totalPages',
      key: ValueKey<String>('$keyPrefix-page-indicator'),
    );
    if (!embedded) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            key: ValueKey<String>('$keyPrefix-previous-page'),
            tooltip: localizations.previousPageTooltip,
            onPressed: hasPreviousPage ? onPreviousPage : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          const SizedBox(width: 10),
          indicator,
          const SizedBox(width: 10),
          IconButton(
            key: ValueKey<String>('$keyPrefix-next-page'),
            tooltip: localizations.nextPageTooltip,
            onPressed: hasNextPage ? onNextPage : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      );
    }
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
        indicator,
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
    if (widget.readOnly) return;
    final viewModel = _skillViewModel;
    if (viewModel == null || viewModel.availableSkills.isEmpty) return;
    _skillSearchController.clear();
    viewModel.clearAvailableSearch();
    viewModel.resetAvailablePage();
    if (widget.embedded) {
      try {
        await showShadDialog<void>(
          context: context,
          builder:
              (dialogContext) => StatefulBuilder(
                builder:
                    (dialogContext, setDialogState) => ShadDialog(
                      title: Text(S.of(context).addSkill),
                      description: Text(S.of(context).botSkillsDescription),
                      constraints: const BoxConstraints(maxWidth: 620),
                      actions: [
                        ShadButton.outline(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(S.of(context).cancel),
                        ),
                      ],
                      child: _buildAvailableSkillPicker(
                        dialogContext,
                        viewModel,
                        embedded: true,
                        refresh: setDialogState,
                      ),
                    ),
              ),
        );
      } finally {
        viewModel.clearAvailableSearch();
      }
      return;
    }
    try {
      await showDialog<void>(
        context: context,
        builder:
            (dialogContext) => StatefulBuilder(
              builder:
                  (dialogContext, setDialogState) => AlertDialog(
                    title: Text(S.of(context).addSkill),
                    content: SizedBox(
                      width: 520,
                      child: _buildAvailableSkillPicker(
                        dialogContext,
                        viewModel,
                        embedded: false,
                        refresh: setDialogState,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(S.of(context).cancel),
                      ),
                    ],
                  ),
            ),
      );
    } finally {
      viewModel.clearAvailableSearch();
    }
  }

  Widget _buildAvailableSkillPicker(
    BuildContext dialogContext,
    BotSkillViewModel viewModel, {
    required bool embedded,
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
          if (embedded) ...[
            StarsSearchField(
              key: const ValueKey<String>('bot-skill-search-field'),
              hintText: strings.searchSkills,
              semanticLabel: strings.searchSkills,
              controller: _skillSearchController,
              autofocus: true,
              onChanged: (query) {
                viewModel.searchAvailableSkills(query);
                refresh(() {});
              },
              suffixIcon:
                  viewModel.availableQuery.isEmpty
                      ? null
                      : IconButton(
                        key: const ValueKey<String>('clear-bot-skill-search'),
                        tooltip: strings.clearSearch,
                        onPressed: () {
                          _skillSearchController.clear();
                          viewModel.clearAvailableSearch();
                          refresh(() {});
                        },
                        icon: const Icon(LucideIcons.x, size: 16),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
            ),
            const SizedBox(height: 12),
          ],
          if (skills.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                strings.noMatchingSkills,
                textAlign: TextAlign.center,
                style:
                    embedded
                        ? DesktopThemeTokens.metaStyle(context)
                        : Theme.of(context).textTheme.bodySmall,
              ),
            ),
          for (var index = 0; index < skills.length; index++) ...[
            Padding(
              key: ValueKey<String>('available-bot-skill-${skills[index].id}'),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skills[index].name,
                          style:
                              embedded
                                  ? ShadTheme.of(context).textTheme.small
                                  : Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          skills[index].description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              embedded
                                  ? DesktopThemeTokens.metaStyle(context)
                                  : Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (embedded)
                    ShadButton(
                      key: ValueKey<String>(
                        'add-bot-skill-${skills[index].id}',
                      ),
                      size: ShadButtonSize.sm,
                      width: 0,
                      onPressed:
                          () => _addBotSkillFromDialog(
                            dialogContext,
                            skills[index].id,
                          ),
                      leading: const Icon(LucideIcons.plus, size: 14),
                      child: Text(strings.addSkill),
                    )
                  else
                    FilledButton.tonalIcon(
                      key: ValueKey<String>(
                        'add-bot-skill-${skills[index].id}',
                      ),
                      onPressed:
                          () => _addBotSkillFromDialog(
                            dialogContext,
                            skills[index].id,
                          ),
                      icon: const Icon(Icons.add_rounded, size: 17),
                      label: Text(strings.addSkill),
                    ),
                ],
              ),
            ),
            if (index != skills.length - 1)
              if (embedded)
                const ShadSeparator.horizontal()
              else
                const Divider(height: 1),
          ],
          if (viewModel.totalAvailablePages > 1) ...[
            const SizedBox(height: 12),
            _buildSkillPagination(
              keyPrefix: 'available-skills',
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
              embedded: embedded,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _setSkillEnabled(String skillId, bool enabled) async {
    if (widget.readOnly) return;
    try {
      await _skillViewModel?.setEnabled(skillId, enabled);
    } catch (error) {
      if (mounted) showSnackBar(context, error.toString());
    }
  }

  Future<void> _addBotSkillFromDialog(
    BuildContext dialogContext,
    String skillId,
  ) async {
    if (widget.readOnly) return;
    try {
      await _skillViewModel?.addSkill(skillId);
      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
    } catch (error) {
      if (mounted) showSnackBar(context, error.toString());
    }
  }

  Future<void> _removeBotSkill(String skillId) async {
    if (widget.readOnly) return;
    try {
      await _skillViewModel?.removeSkill(skillId);
    } catch (error) {
      if (mounted) showSnackBar(context, error.toString());
    }
  }

  Future<void> _showSkillDescriptionTest(SkillDescriptor skill) async {
    final testCase = await showSkillDescriptionTestDialog(
      context: context,
      skill: skill,
      desktopMode: widget.embedded,
    );
    if (testCase == null || !mounted) return;
    try {
      final report = await _skillViewModel!.testDescription(
        skillId: skill.id,
        cases: [testCase],
      );
      if (!mounted) return;
      final result = report.results.single;
      showSnackBar(
        context,
        '${S.of(context).skillDescriptionTestResult}: '
        '${result.activations}/${result.runs}',
      );
    } catch (error) {
      if (mounted) showSnackBar(context, error.toString());
    }
  }

  Widget _buildFormSection(
    BuildContext context,
    String title,
    List<Widget> children, {
    Key? sectionKey,
  }) {
    if (!widget.embedded) {
      return buildSectionContainer(
        context,
        title,
        widget.readOnly && children.length > 1
            ? [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const Divider(height: 16),
              ],
            ]
            : children,
      );
    }
    final tokens = StarsDesktopTokens.of(context);
    return ShadCard(
      key: sectionKey,
      width: double.infinity,
      padding: const EdgeInsets.all(DesktopThemeTokens.botFormSectionPadding),
      backgroundColor: tokens.raisedSurface,
      border: ShadBorder.all(
        color: tokens.separator,
        width: DesktopThemeTokens.botFormSectionBorderWidth,
      ),
      columnCrossAxisAlignment: CrossAxisAlignment.stretch,
      title: Text(
        title,
        style: DesktopThemeTokens.sectionTitleStyle(
          context,
        )?.copyWith(fontSize: DesktopThemeTokens.botFormSectionTitleFontSize),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: widget.readOnly ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1)
                if (widget.readOnly) ...[
                  const SizedBox(height: 8),
                  const ShadSeparator.horizontal(
                    margin: DesktopThemeTokens.settingsRowSeparatorMargin,
                  ),
                  const SizedBox(height: 8),
                ] else
                  const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveBot() async {
    if (widget.readOnly || _isSaving || _isDeleting) return;
    if (nameController.text.trim().isEmpty) {
      showSnackBar(context, S.of(context).fillRequiredFields);
      return;
    }
    final navigator = Navigator.of(context);
    final updatedBot = Bot(
      id: widget.bot.id,
      name: nameController.text.trim(),
      avatar: avatarImage?.path ?? widget.bot.avatar,
      provider:
          widget.embedded
              ? widget.bot.provider
              : providerController.text.trim(),
      baseURL:
          widget.embedded ? widget.bot.baseURL : baseURLController.text.trim(),
      apiKey:
          widget.embedded ? widget.bot.apiKey : apiKeyController.text.trim(),
      apiType:
          widget.embedded ? widget.bot.apiType : apiTypeController.text.trim(),
      model:
          widget.embedded
              ? widget.bot.model
              : selectedModelController.text.trim(),
      systemPrompt: systemPromptController.text.trim(),
      parameters: {
        Bot.parameterSupportsMcp: _modelSupportsMcp,
        Bot.parameterSupportsAutomaticSkillActivation:
            _modelSupportsAutomaticSkillActivation,
        Bot.parameterMcpServers:
            _modelSupportsMcp
                ? (_mcpServerIds.toList()..sort())
                : const <String>[],
        Bot.parameterMcpTools:
            _modelSupportsMcp
                ? ((_mcpToolConfigurations.toList()
                      ..sort((left, right) => left.key.compareTo(right.key)))
                    .map((configuration) => configuration.toMap())
                    .toList(growable: false))
                : const <Map<String, Object?>>[],
      },
      createTimestamp: widget.bot.createTimestamp,
      modifyTimestamp: DateTime.now(),
    );

    final saveRevision = _editRevision;
    var saved = false;
    setState(() {
      _isSaving = true;
      _isSaved = false;
    });
    try {
      await widget.onBotUpdated(updatedBot);
      saved = true;
      if (!widget.embedded && mounted) {
        navigator.pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = widget.embedded && saved && _editRevision == saveRevision;
        });
      }
    }
  }

  void _markUnsaved(String _) {
    if (!mounted) return;
    setState(() {
      _editRevision += 1;
      _isSaved = false;
    });
  }

  Widget _buildDetailValue({
    required Key key,
    required String label,
    required IconData icon,
    required String value,
    Widget? trailing,
    TextAlign textAlign = TextAlign.end,
  }) {
    final materialTheme = Theme.of(context);
    final displayValue = value.trim().isEmpty ? '—' : value;
    final labelStyle =
        widget.embedded
            ? DesktopThemeTokens.bodyStyle(context)
            : materialTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            );
    final valueStyle =
        widget.embedded
            ? DesktopThemeTokens.metaStyle(context)
            : materialTheme.textTheme.bodySmall?.copyWith(
              color: materialTheme.colorScheme.onSurfaceVariant,
            );
    final iconColor =
        widget.embedded
            ? DesktopThemeTokens.mutedText(context)
            : materialTheme.colorScheme.primary;

    final leading = SizedBox(
      width: DesktopThemeTokens.settingsRowIconSlotWidth,
      child: Icon(
        icon,
        size: widget.embedded ? DesktopThemeTokens.settingsRowIconSize : 20,
        color: iconColor,
      ),
    );

    return KeyedSubtree(
      key: key,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useSettingsRowLayout = constraints.maxWidth >= 600;
          if (useSettingsRowLayout) {
            return Padding(
              padding: DesktopThemeTokens.settingsRowPadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: DesktopThemeTokens.settingsRowMinHeight,
                ),
                child: Row(
                  children: [
                    leading,
                    const SizedBox(
                      width: DesktopThemeTokens.settingsRowIconGap,
                    ),
                    Expanded(child: Text(label, style: labelStyle)),
                    const SizedBox(
                      width: DesktopThemeTokens.settingsRowValueGap,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: DesktopThemeTokens.settingsRowValueMaxWidth,
                      ),
                      child: SelectableText(
                        displayValue,
                        textAlign: textAlign,
                        style: valueStyle,
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing,
                    ],
                  ],
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.embedded ? 8 : 0,
              vertical: 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leading,
                SizedBox(
                  width:
                      widget.embedded
                          ? DesktopThemeTokens.settingsRowIconGap
                          : 16,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: labelStyle),
                            const SizedBox(height: 2),
                            SelectableText(
                              displayValue,
                              textAlign: TextAlign.start,
                              style: valueStyle,
                            ),
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 8),
                        trailing,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailApiKey() {
    final apiKey = apiKeyController.text;
    final displayValue =
        apiKey.isEmpty
            ? ''
            : _isPasswordVisible
            ? apiKey
            : '••••••••••••';
    return _buildDetailValue(
      key: const ValueKey<String>('bot-detail-api-key'),
      label: S.of(context).apiKey,
      icon: Icons.key_outlined,
      value: displayValue,
      trailing:
          apiKey.isEmpty
              ? null
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailAction(
                    key: const ValueKey<String>('bot-detail-copy-api-key'),
                    tooltip: S.of(context).copyApiKey,
                    icon: Icons.copy_outlined,
                    onPressed:
                        () => Clipboard.setData(ClipboardData(text: apiKey)),
                  ),
                  _buildDetailAction(
                    key: const ValueKey<String>('bot-detail-toggle-api-key'),
                    tooltip:
                        _isPasswordVisible
                            ? S.of(context).hideApiKey
                            : S.of(context).showApiKey,
                    icon:
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ],
              ),
    );
  }

  Widget _buildDetailAction({
    required Key key,
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    if (widget.embedded) {
      return ShadTooltip(
        builder: (context) => Text(tooltip),
        child: ShadIconButton.ghost(
          key: key,
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 16,
          width: 28,
          height: 28,
          padding: EdgeInsets.zero,
        ),
      );
    }
    return IconButton(
      key: key,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
    );
  }

  Widget _buildDesktopInput({
    Key? key,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    Widget? trailing,
    String? placeholder,
    bool obscureText = false,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    final shadTheme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: shadTheme.textTheme.small),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: ShadInput(
            key: key,
            controller: controller,
            placeholder: placeholder == null ? null : Text(placeholder),
            leading: SizedBox(
              width: 17,
              height: 30,
              child: Center(child: Icon(icon, size: 17)),
            ),
            trailing: trailing,
            obscureText: obscureText,
            readOnly: readOnly,
            alignment: Alignment.centerLeft,
            placeholderAlignment: Alignment.centerLeft,
            crossAxisAlignment: CrossAxisAlignment.center,
            constraints: const BoxConstraints(
              minHeight: DesktopThemeTokens.botFormFieldHeight,
            ),
            textInputAction: TextInputAction.next,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTextarea({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? placeholder,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    final shadTheme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: shadTheme.textTheme.small),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: ShadTextarea(
            controller: controller,
            placeholder: placeholder == null ? null : Text(placeholder),
            leading: Icon(icon, size: 17),
            minHeight: 112,
            maxHeight: 220,
            readOnly: readOnly,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _desktopInputAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return ShadTooltip(
      builder: (context) => Text(tooltip),
      child: ShadIconButton.ghost(
        enabled: onPressed != null,
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: 16,
        width: 28,
        height: 28,
        padding: EdgeInsets.zero,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        size: 24,
        color: Theme.of(context).colorScheme.primary,
      ),
      suffixIcon: suffixIcon,
      border: const OutlineInputBorder(
        borderSide: BorderSide(width: 0, style: BorderStyle.none),
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildDeleteButton(double? fontSize) {
    Future<void> deleteBot() async {
      if (widget.readOnly || _isDeleting || _isSaving) return;
      final shouldDelete =
          widget.embedded
              ? await showShadDialog<bool>(
                context: context,
                variant: ShadDialogVariant.alert,
                builder:
                    (context) => ShadDialog.alert(
                      title: Text(S.of(context).deleteBot),
                      description: Text(
                        desktopConversationText(
                          context,
                          S.of(context).confirmDeleteBot(widget.bot.name),
                        ),
                      ),
                      actions: [
                        ShadButton.outline(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(S.of(context).cancel),
                        ),
                        ShadButton.destructive(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(S.of(context).delete),
                        ),
                      ],
                    ),
              )
              : await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Center(
                        child: Text(
                          S.of(context).deleteBot,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                      content: Text(
                        desktopConversationText(
                          context,
                          S.of(context).confirmDeleteBot(widget.bot.name),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            S.of(context).cancel,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            S.of(context).delete,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
              );

      if (shouldDelete != true) return;

      if (_isDeleting || _isSaving) return;
      setState(() => _isDeleting = true);
      try {
        await widget.onBotDeleted();
        if (!widget.embedded && mounted) {
          Navigator.pop(context);
        }
      } finally {
        if (mounted) {
          setState(() => _isDeleting = false);
        }
      }
    }

    if (widget.embedded) {
      return ShadTooltip(
        builder: (context) => Text(S.of(context).deleteBot),
        child: ShadIconButton.destructive(
          enabled: !_isSaving && !_isDeleting,
          width: 34,
          height: 34,
          padding: EdgeInsets.zero,
          iconSize: 18,
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: _isSaving || _isDeleting ? null : deleteBot,
        ),
      );
    }

    return IconButton(
      tooltip: S.of(context).deleteBot,
      icon: Icon(
        Icons.delete_outline_rounded,
        size: 24,
        color: Theme.of(context).colorScheme.error,
      ),
      onPressed: deleteBot,
    );
  }

  Widget _buildNameInput(double? fontSize) {
    if (widget.readOnly) {
      return _buildDetailValue(
        key: const ValueKey<String>('bot-detail-name'),
        label: S.of(context).botName,
        icon: Icons.auto_awesome_outlined,
        value: nameController.text,
      );
    }
    if (widget.embedded) {
      return _buildDesktopInput(
        key: const ValueKey<String>('desktop-bot-name'),
        label: S.of(context).botName,
        icon: Icons.auto_awesome_outlined,
        controller: nameController,
        placeholder: S.of(context).enterBotName,
        readOnly: widget.readOnly,
        onChanged: widget.readOnly ? null : _markUnsaved,
      );
    }
    return TextField(
      controller: nameController,
      readOnly: widget.readOnly,
      decoration: _fieldDecoration(
        label: S.of(context).botName,
        icon: Icons.auto_awesome_outlined,
        hintText: S.of(context).enterBotName,
      ),
    );
  }

  Widget _buildProviderInput(double? fontSize) {
    if (widget.readOnly) {
      return _buildDetailValue(
        key: const ValueKey<String>('bot-detail-provider'),
        label: S.of(context).provider,
        icon: Icons.business_outlined,
        value: providerController.text,
      );
    }
    if (widget.embedded) {
      return _buildDesktopInput(
        key: const ValueKey<String>('desktop-bot-provider'),
        label: S.of(context).provider,
        icon: Icons.business_outlined,
        controller: providerController,
        readOnly: true,
      );
    }
    return TextField(
      controller: providerController,
      readOnly: widget.readOnly,
      onChanged:
          widget.readOnly
              ? null
              : (value) => setState(() => selectedProvider = value),
      decoration: _fieldDecoration(
        label: S.of(context).provider,
        icon: Icons.business_outlined,
      ),
    );
  }

  Widget _buildApiTypeInput(double? fontSize) {
    if (widget.readOnly) {
      return _buildDetailValue(
        key: const ValueKey<String>('bot-detail-api-type'),
        label: S.of(context).apiType,
        icon: Icons.category_outlined,
        value: apiTypeController.text,
      );
    }
    if (widget.embedded) {
      return _buildDesktopInput(
        key: const ValueKey<String>('desktop-bot-api-type'),
        label: S.of(context).apiType,
        icon: Icons.category_outlined,
        controller: apiTypeController,
        readOnly: true,
      );
    }
    return TextField(
      controller: apiTypeController,
      readOnly: widget.readOnly,
      decoration: _fieldDecoration(
        label: S.of(context).apiType,
        icon: Icons.category_outlined,
      ),
    );
  }

  Widget _buildApiAddressInput(double? fontSize) {
    if (widget.readOnly) {
      return _buildDetailValue(
        key: const ValueKey<String>('bot-detail-base-url'),
        label: S.of(context).apiAddress,
        icon: Icons.link_rounded,
        value: baseURLController.text,
      );
    }
    if (widget.embedded) {
      return _buildDesktopInput(
        key: const ValueKey<String>('desktop-bot-base-url'),
        label: S.of(context).apiAddress,
        icon: Icons.link_rounded,
        controller: baseURLController,
        readOnly: true,
      );
    }
    return TextField(
      controller: baseURLController,
      readOnly: widget.readOnly,
      decoration: _fieldDecoration(
        label: S.of(context).apiAddress,
        icon: Icons.link_rounded,
      ),
    );
  }

  Widget _buildApiKeyInput(double? fontSize) {
    if (widget.readOnly) return _buildDetailApiKey();
    if (widget.embedded) {
      return _buildDesktopInput(
        key: const ValueKey<String>('desktop-bot-api-key'),
        label: S.of(context).apiKey,
        icon: Icons.key_outlined,
        controller: apiKeyController,
        obscureText: !_isPasswordVisible,
        readOnly: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _desktopInputAction(
              tooltip: S.of(context).copyApiKey,
              icon: Icons.copy_outlined,
              onPressed:
                  apiKeyController.text.isEmpty
                      ? null
                      : () => Clipboard.setData(
                        ClipboardData(text: apiKeyController.text),
                      ),
            ),
            _desktopInputAction(
              tooltip:
                  _isPasswordVisible
                      ? S.of(context).hideApiKey
                      : S.of(context).showApiKey,
              icon:
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ],
        ),
      );
    }
    return TextField(
      controller: apiKeyController,
      obscureText: !_isPasswordVisible,
      readOnly: widget.readOnly,
      decoration: _fieldDecoration(
        label: S.of(context).apiKey,
        icon: Icons.key_outlined,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: S.of(context).copyApiKey,
              icon: const Icon(Icons.copy_outlined, size: 17),
              onPressed:
                  apiKeyController.text.isEmpty
                      ? null
                      : () => Clipboard.setData(
                        ClipboardData(text: apiKeyController.text),
                      ),
            ),
            IconButton(
              tooltip:
                  _isPasswordVisible
                      ? S.of(context).hideApiKey
                      : S.of(context).showApiKey,
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelsInput(double? fontSize) {
    if (widget.readOnly) {
      return _buildDetailValue(
        key: const ValueKey<String>('bot-detail-model'),
        label: S.of(context).model,
        icon: Icons.memory_outlined,
        value: selectedModelController.text,
      );
    }
    if (widget.embedded) {
      return _buildDesktopInput(
        key: const ValueKey<String>('desktop-bot-model'),
        label: S.of(context).model,
        icon: Icons.memory_outlined,
        controller: selectedModelController,
        readOnly: true,
      );
    }
    return TextField(
      controller: selectedModelController,
      readOnly: widget.readOnly,
      onChanged: (value) {
        final stillSelectedModel = value.trim() == widget.bot.model;
        setState(() {
          _modelSupportsMcp = stillSelectedModel && _initialModelSupportsMcp;
          _modelSupportsAutomaticSkillActivation =
              stillSelectedModel &&
              _initialModelSupportsAutomaticSkillActivation;
          _skillViewModel?.updateSupportsAutoActivation(
            _modelSupportsAutomaticSkillActivation,
          );
          _editRevision += 1;
          _isSaved = false;
        });
      },
      decoration: _fieldDecoration(
        label: S.of(context).model,
        icon: Icons.memory_outlined,
      ),
    );
  }

  Widget _buildMcpToolPicker() {
    return BotMcpToolPicker(
      servers: _mcpServers,
      toolsByServer: _mcpToolsByServer,
      selectedServerIds: _mcpServerIds,
      configurations: _mcpToolConfigurations,
      isLoading: _isLoadingMcpServers,
      embedded: widget.embedded,
      readOnly: widget.readOnly,
      onSelectedServerIdsChanged: (serverIds) {
        setState(() {
          _mcpServerIds = serverIds;
          _editRevision += 1;
          _isSaved = false;
        });
      },
      onChanged: (configurations) {
        setState(() {
          _mcpToolConfigurations = configurations;
          _editRevision += 1;
          _isSaved = false;
        });
      },
    );
  }

  Widget _buildSystemPromptInput(double? fontSize) {
    if (widget.readOnly) {
      return _buildDetailValue(
        key: const ValueKey<String>('bot-detail-system-prompt'),
        label: S.of(context).systemPrompt.replaceAll(':', ''),
        icon: Icons.subject_rounded,
        value: systemPromptController.text,
        textAlign: TextAlign.start,
      );
    }
    if (widget.embedded) {
      return _buildDesktopTextarea(
        label: S.of(context).systemPrompt.replaceAll(':', ''),
        icon: Icons.subject_rounded,
        controller: systemPromptController,
        placeholder: S.of(context).enterSystemPrompt,
        readOnly: widget.readOnly,
        onChanged: widget.readOnly ? null : _markUnsaved,
      );
    }
    return TextField(
      controller: systemPromptController,
      readOnly: widget.readOnly,
      decoration: _fieldDecoration(
        label: S.of(context).systemPrompt.replaceAll(':', ''),
        icon: Icons.subject_rounded,
        hintText: S.of(context).enterSystemPrompt,
      ),
      minLines: 4,
      maxLines: 8,
    );
  }
}
