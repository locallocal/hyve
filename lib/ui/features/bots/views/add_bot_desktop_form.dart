part of 'add_bot.dart';

// State mutations remain owned by the host State object in this library part.
// ignore_for_file: invalid_use_of_protected_member

extension _AddBotDesktopForm on _AddBotPageState {
  Widget _buildEmbeddedDesktop(BuildContext context) {
    final isHuggingFace = providerController.text == 'HuggingFace';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildDesktopHeader(context),
          const ShadSeparator.horizontal(),
          Expanded(
            child: Scrollbar(
              controller: _desktopScrollController,
              child: SingleChildScrollView(
                controller: _desktopScrollController,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _AddBotPageState._desktopFormWidth,
                    ),
                    child: ShadForm(
                      key: _desktopFormKey,
                      autovalidateMode:
                          ShadAutovalidateMode.alwaysAfterFirstValidation,
                      child: FocusTraversalGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDesktopSection(
                              context,
                              S.of(context).basicInformation,
                              [_buildDesktopNameInput()],
                              sectionKey: const ValueKey<String>(
                                'add-bot-basic-section',
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDesktopSection(
                              context,
                              S.of(context).providerInformation,
                              [
                                _buildDesktopProviderInput(),
                                if (isHuggingFace)
                                  _buildDesktopSubProviderInput(),
                                _buildDesktopApiTypeSelector(),
                                _buildDesktopApiAddressInput(),
                                _buildDesktopApiKeyInput(),
                              ],
                              sectionKey: const ValueKey<String>(
                                'add-bot-provider-section',
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDesktopSection(
                              context,
                              S.of(context).modelConfiguration,
                              [
                                _buildDesktopModelsInput(),
                                _buildDesktopSystemPromptInput(),
                              ],
                              sectionKey: const ValueKey<String>(
                                'add-bot-model-section',
                              ),
                            ),
                            if (_selectedModelSupportsMcp) ...[
                              const SizedBox(height: 20),
                              _buildDesktopSection(
                                context,
                                S.of(context).mcpServers,
                                [_buildMcpServerPicker()],
                                sectionKey: const ValueKey<String>(
                                  'add-bot-mcp-section',
                                ),
                              ),
                            ],
                            if (widget.skillViewModel?.supportsAutoActivation ??
                                false) ...[
                              const SizedBox(height: 20),
                              _buildDesktopSection(
                                context,
                                S.of(context).botSkills,
                                [
                                  AddBotSkills(
                                    viewModel: widget.skillViewModel!,
                                  ),
                                ],
                                sectionKey: const ValueKey<String>(
                                  'add-bot-skills-section',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildDesktopFooter(context),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    final strings = S.of(context);
    final tokens = StarsDesktopTokens.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
      child: Row(
        children: [
          ShadTooltip(
            builder: (context) => Text(strings.botAvatar),
            child: ShadButton.ghost(
              width: 48,
              height: 48,
              padding: EdgeInsets.zero,
              onPressed: _pickImage,
              child: Semantics(
                label: strings.botAvatar,
                image: true,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          avatarImage == null
                              ? getFrostedProviderColor(
                                providerController.text,
                                tokens.accent,
                              )
                              : tokens.accent,
                      backgroundImage:
                          avatarImage != null ? FileImage(avatarImage!) : null,
                      child:
                          avatarImage == null
                              ? buildProviderLogo(
                                context,
                                '',
                                providerController.text,
                                24,
                              )
                              : null,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: tokens.raisedSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: tokens.separator, width: 0),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 11,
                          color: tokens.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.addBot,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DesktopThemeTokens.pageTitleStyle(context),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.botInformation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DesktopThemeTokens.metaStyle(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StarsDesktopIconAction(
            key: const ValueKey<String>('add-bot-close'),
            icon: LucideIcons.x,
            iconSize: 18,
            label: MaterialLocalizations.of(context).closeButtonTooltip,
            enabled: !_isSubmitting,
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSection(
    BuildContext context,
    String title,
    List<Widget> children, {
    required Key sectionKey,
  }) {
    final tokens = StarsDesktopTokens.of(context);
    return ShadCard(
      key: sectionKey,
      width: double.infinity,
      padding: const EdgeInsets.all(_AddBotPageState._desktopSectionPadding),
      backgroundColor: tokens.raisedSurface,
      border: ShadBorder.all(
        color: tokens.separator,
        width: _AddBotPageState._desktopSectionBorderWidth,
      ),
      columnCrossAxisAlignment: CrossAxisAlignment.stretch,
      title: Text(
        title,
        style: DesktopThemeTokens.sectionTitleStyle(
          context,
        )?.copyWith(fontSize: DesktopThemeTokens.botFormSectionTitleFontSize),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ShadSeparator.horizontal(),
        ColoredBox(
          color: shadTheme.colorScheme.background,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _AddBotPageState._desktopFormWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage case final error?)
                        StarsInlineErrorAlert(
                          error: error,
                          isDesktop: true,
                          onDismiss: _dismissError,
                          alertKey: const ValueKey<String>(
                            'add-bot-error-alert',
                          ),
                          messageKey: const ValueKey<String>(
                            'add-bot-error-message',
                          ),
                          dismissKey: const ValueKey<String>(
                            'dismiss-add-bot-error',
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ShadButton.outline(
                            enabled: !_isSubmitting,
                            onPressed:
                                _isSubmitting
                                    ? null
                                    : () => Navigator.of(context).pop(),
                            child: Text(S.of(context).cancel),
                          ),
                          const SizedBox(width: 8),
                          ShadButton(
                            key: const ValueKey<String>('add-bot-submit'),
                            enabled: !_isSubmitting,
                            onPressed: _isSubmitting ? null : _submitBot,
                            leading:
                                _isSubmitting
                                    ? SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            shadTheme
                                                .colorScheme
                                                .primaryForeground,
                                      ),
                                    )
                                    : const Icon(Icons.add_rounded, size: 17),
                            child: Text(S.of(context).addBot),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _desktopIconButton({
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
        width: _AddBotPageState._desktopDropdownButtonSize,
        height: _AddBotPageState._desktopDropdownButtonSize,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _desktopInputLeading(IconData icon) {
    return SizedBox(
      width: 17,
      height: 30,
      child: Center(child: Icon(icon, size: 17)),
    );
  }

  Widget _desktopMenuAnchor<T>({
    Key? key,
    required List<T> options,
    required T? selectedValue,
    required Widget Function(MenuController controller) fieldBuilder,
    required ValueChanged<T> onSelected,
    String Function(T value)? labelBuilder,
    Widget Function(T value)? leadingBuilder,
    double? menuWidth,
    bool alignEnd = false,
    bool constrainMenuWidth = false,
  }) {
    assert(!alignEnd || menuWidth != null);
    final tokens = StarsDesktopTokens.of(context);
    return MenuAnchor(
      key: key,
      crossAxisUnconstrained: !constrainMenuWidth,
      alignmentOffset: Offset(
        alignEnd ? _AddBotPageState._desktopDropdownButtonSize - menuWidth! : 0,
        4,
      ),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(tokens.raisedSurface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(
          Colors.black.withValues(alpha: tokens.highContrast ? 0 : 0.18),
        ),
        elevation: WidgetStatePropertyAll(tokens.highContrast ? 0 : 6),
        minimumSize:
            menuWidth == null
                ? null
                : WidgetStatePropertyAll(Size(menuWidth, 0)),
        maximumSize: WidgetStatePropertyAll(Size(menuWidth ?? 420, 360)),
        side: WidgetStatePropertyAll(
          BorderSide(color: tokens.separator, width: 0),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: DesktopThemeTokens.containerRadius,
          ),
        ),
      ),
      menuChildren: [
        for (final option in options)
          MenuItemButton(
            leadingIcon: leadingBuilder?.call(option),
            trailingIcon:
                option == selectedValue
                    ? Icon(Icons.check_rounded, size: 16, color: tokens.accent)
                    : const SizedBox.square(dimension: 16),
            onPressed: () => onSelected(option),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180),
              child: Text(
                labelBuilder?.call(option) ?? option.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
      builder: (context, controller, child) => fieldBuilder(controller),
    );
  }

  void _toggleMenu(MenuController controller) {
    controller.isOpen ? controller.close() : controller.open();
  }

  Widget _buildDesktopNameInput() {
    return ShadInputFormField(
      key: const ValueKey<String>('add-bot-name'),
      id: 'name',
      controller: nameController,
      textInputAction: TextInputAction.next,
      label: Text(S.of(context).botName),
      placeholder: Text(S.of(context).enterBotName),
      leading: _desktopInputLeading(Icons.auto_awesome_outlined),
      constraints: _AddBotPageState._desktopInputConstraints,
      validator:
          (value) =>
              value.trim().isEmpty ? S.of(context).fillRequiredFields : null,
    );
  }

  Widget _buildDesktopProviderInput() {
    return ShadInputFormField(
      key: const ValueKey<String>('add-bot-provider'),
      id: 'provider',
      controller: providerController,
      textInputAction: TextInputAction.next,
      label: Text(S.of(context).provider),
      placeholder: Text(S.of(context).selectProvider),
      leading: _desktopInputLeading(Icons.business_outlined),
      constraints: _AddBotPageState._desktopInputConstraints,
      onChanged: _handleProviderTextChanged,
      trailing: _desktopMenuAnchor(
        options: providersInfo.keys.toList(growable: false),
        selectedValue: providerController.text,
        onSelected: _onProviderChanged,
        menuWidth: _AddBotPageState._desktopProviderMenuWidth,
        alignEnd: true,
        leadingBuilder:
            (provider) => buildProviderLogo(context, '', provider, 18),
        fieldBuilder:
            (menuController) => _desktopIconButton(
              tooltip: S.of(context).selectProvider,
              icon: Icons.expand_more_rounded,
              onPressed: () => _toggleMenu(menuController),
            ),
      ),
    );
  }

  Widget _buildDesktopSubProviderInput() {
    final subProviders =
        providersInfo[providerController.text]?['sub_providers']
            as Map<String, Map>;
    return _desktopMenuAnchor(
      options: subProviders.keys.toList(growable: false),
      selectedValue: subProviderController.text,
      onSelected: _onSubProviderChanged,
      leadingBuilder:
          (provider) => buildProviderLogo(context, '', provider, 18),
      fieldBuilder:
          (menuController) => ShadInputFormField(
            key: const ValueKey<String>('add-bot-sub-provider'),
            id: 'subProvider',
            controller: subProviderController,
            textInputAction: TextInputAction.next,
            label: Text('${S.of(context).provider} (HuggingFace)'),
            placeholder: Text(S.of(context).selectProvider),
            leading: _desktopInputLeading(Icons.hub_outlined),
            constraints: _AddBotPageState._desktopInputConstraints,
            onChanged: _handleSubProviderTextChanged,
            trailing: _desktopIconButton(
              tooltip: S.of(context).selectProvider,
              icon: Icons.expand_more_rounded,
              onPressed: () => _toggleMenu(menuController),
            ),
          ),
    );
  }

  Widget _buildDesktopApiTypeSelector() {
    return _desktopMenuAnchor(
      options: Bot.getAllApiTypes(),
      selectedValue: apiTypeController.text,
      onSelected: (value) {
        setState(() => apiTypeController.text = value);
      },
      fieldBuilder:
          (menuController) => ShadInputFormField(
            key: const ValueKey<String>('add-bot-api-type'),
            id: 'apiType',
            controller: apiTypeController,
            enabled: _isCustomProvider,
            textInputAction: TextInputAction.next,
            label: Text(S.of(context).apiType),
            leading: _desktopInputLeading(Icons.category_outlined),
            constraints: _AddBotPageState._desktopInputConstraints,
            trailing: _desktopIconButton(
              tooltip: S.of(context).apiType,
              icon: Icons.expand_more_rounded,
              onPressed:
                  _isCustomProvider ? () => _toggleMenu(menuController) : null,
            ),
          ),
    );
  }

  Widget _buildDesktopApiAddressInput() {
    return ShadInputFormField(
      key: const ValueKey<String>('add-bot-base-url'),
      id: 'baseUrl',
      controller: baseURLController,
      textInputAction: TextInputAction.next,
      label: Text(S.of(context).apiAddress),
      leading: _desktopInputLeading(Icons.link_rounded),
      constraints: _AddBotPageState._desktopInputConstraints,
      validator:
          (value) =>
              value.trim().isEmpty ? S.of(context).enterApiAddress : null,
    );
  }

  Widget _buildDesktopApiKeyInput() {
    return ShadInputFormField(
      key: const ValueKey<String>('add-bot-api-key'),
      id: 'apiKey',
      controller: apiKeyController,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.next,
      label: Text(S.of(context).apiKey),
      leading: _desktopInputLeading(Icons.key_outlined),
      constraints: _AddBotPageState._desktopInputConstraints,
      validator:
          (value) =>
              value.trim().isEmpty ? S.of(context).pleaseEnterApiKey : null,
      trailing: _desktopIconButton(
        tooltip:
            _isPasswordVisible
                ? S.of(context).hideApiKey
                : S.of(context).showApiKey,
        icon: _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
    );
  }

  Widget _buildDesktopModelsInput() {
    return ShadInputFormField(
      key: const ValueKey<String>('add-bot-model'),
      id: 'model',
      controller: selectedModelController,
      textInputAction: TextInputAction.next,
      label: Text(S.of(context).model),
      placeholder: Text(S.of(context).selectModel),
      leading: _desktopInputLeading(Icons.memory_outlined),
      constraints: _AddBotPageState._desktopInputConstraints,
      trailing:
          providerModels.isEmpty
              ? _isLoadingModels
                  ? const SizedBox.square(
                    dimension: 30,
                    child: Center(
                      child: SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                  : _desktopIconButton(
                    tooltip: S.of(context).fetchModelList,
                    icon: Icons.refresh_rounded,
                    onPressed: _fetchModels,
                  )
              : _desktopMenuAnchor<AiModelInfo>(
                key: const ValueKey<String>('add-bot-model-menu'),
                options: providerModels,
                selectedValue: _modelInfoById(selectedModelController.text),
                labelBuilder: (model) => model.modelId,
                menuWidth: _AddBotPageState._desktopModelMenuWidth,
                alignEnd: true,
                constrainMenuWidth: true,
                onSelected: (value) {
                  setState(() => selectedModelController.text = value.modelId);
                },
                fieldBuilder:
                    (menuController) => _desktopIconButton(
                      tooltip: S.of(context).selectModel,
                      icon: Icons.expand_more_rounded,
                      onPressed: () => _toggleMenu(menuController),
                    ),
              ),
    );
  }

  Widget _buildDesktopSystemPromptInput() {
    return ShadTextareaFormField(
      key: const ValueKey<String>('add-bot-system-prompt'),
      id: 'systemPrompt',
      controller: systemPromptController,
      label: Text(S.of(context).systemPrompt),
      leading: const Icon(Icons.notes_rounded, size: 17),
      minHeight: 96,
      maxHeight: 96,
      resizable: false,
    );
  }
}
