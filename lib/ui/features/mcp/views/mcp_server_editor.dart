part of 'mcp_servers_page.dart';

class _McpServerEditorDialog extends StatefulWidget {
  const _McpServerEditorDialog({required this.desktop, this.server});

  final bool desktop;
  final McpServer? server;

  @override
  State<_McpServerEditorDialog> createState() => _McpServerEditorDialogState();
}

class _McpServerEditorDialogState extends State<_McpServerEditorDialog> {
  static const double _desktopFieldWidth =
      DesktopThemeTokens.addBotFormFieldWidth;
  static const double _desktopSectionPadding =
      DesktopThemeTokens.botFormSectionPadding;
  static const double _desktopSectionBorderWidth =
      DesktopThemeTokens.botFormSectionBorderWidth;
  static const double _desktopDropdownButtonSize = 30;
  static const double _desktopTransportMenuWidth = 256;
  static const double _desktopFormWidth =
      _desktopFieldWidth +
      _desktopSectionPadding * 2 +
      _desktopSectionBorderWidth * 2;
  static const BoxConstraints _desktopInputConstraints = BoxConstraints(
    minHeight: DesktopThemeTokens.botFormFieldHeight,
  );

  final _desktopFormKey = GlobalKey<ShadFormState>();
  final _desktopScrollController = ScrollController();
  late final TextEditingController _nameController;
  late final TextEditingController _transportController;
  late final TextEditingController _endpointController;
  late final TextEditingController _commandController;
  late final TextEditingController _argumentsController;
  late final TextEditingController _environmentController;
  late final TextEditingController _tokenController;
  late final TextEditingController _authController;
  late McpTransportType _transportType;
  late McpAuthType _authType;

  @override
  void initState() {
    super.initState();
    final server = widget.server;
    final httpTransport = switch (server?.transport) {
      final McpStreamableHttpServerTransport transport => transport,
      _ => null,
    };
    final stdioTransport = switch (server?.transport) {
      final McpStdioServerTransport transport => transport,
      _ => null,
    };
    _nameController = TextEditingController(text: server?.name ?? '');
    _transportController = TextEditingController();
    _endpointController = TextEditingController(
      text: httpTransport?.endpoint.toString() ?? '',
    );
    _commandController = TextEditingController(
      text: stdioTransport?.command ?? '',
    );
    _argumentsController = TextEditingController(
      text: stdioTransport?.arguments.join('\n') ?? '',
    );
    _environmentController = TextEditingController();
    _tokenController = TextEditingController();
    _authController = TextEditingController();
    _transportType = server?.transport.type ?? McpTransportType.streamableHttp;
    _authType = httpTransport?.authType ?? McpAuthType.none;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTransportController();
    _syncAuthController();
  }

  @override
  void dispose() {
    _desktopScrollController.dispose();
    _nameController.dispose();
    _transportController.dispose();
    _endpointController.dispose();
    _commandController.dispose();
    _argumentsController.dispose();
    _environmentController.dispose();
    _tokenController.dispose();
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.desktop
        ? _buildDesktopDialog(context)
        : _buildMobileDialog(context);
  }

  Widget _buildDesktopDialog(BuildContext context) {
    final windowSize = MediaQuery.sizeOf(context);
    final inset =
        windowSize.width < 900 || windowSize.height < 760 ? 16.0 : 24.0;
    final dialogWidth =
        (windowSize.width - inset * 2).clamp(0.0, 840.0).toDouble();
    final dialogHeight =
        (windowSize.height - inset * 2).clamp(0.0, 720.0).toDouble();

    return ShadDialog(
      constraints: BoxConstraints.tightFor(
        width: dialogWidth,
        height: dialogHeight,
      ),
      padding: EdgeInsets.zero,
      gap: 0,
      scrollable: false,
      useSafeArea: false,
      removeBorderRadiusWhenTiny: false,
      closeIcon: const SizedBox.shrink(),
      child: SizedBox(
        key: const ValueKey<String>('mcp-server-dialog-content'),
        width: dialogWidth,
        height: dialogHeight,
        child: Scaffold(
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
                          maxWidth: _desktopFormWidth,
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
                                  [_buildDesktopNameInput(context)],
                                  sectionKey: const ValueKey<String>(
                                    'mcp-server-basic-section',
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildDesktopSection(
                                  context,
                                  S.of(context).mcpConnectionSettings,
                                  [
                                    _buildDesktopTransportInput(context),
                                    if (_transportType ==
                                        McpTransportType.streamableHttp) ...[
                                      _buildDesktopEndpointInput(context),
                                      _buildDesktopAuthInput(context),
                                      if (_authType ==
                                          McpAuthType.oauthAccessToken)
                                        _buildDesktopTokenInput(context),
                                    ] else ...[
                                      _buildDesktopCommandInput(context),
                                      _buildDesktopArgumentsInput(context),
                                      _buildDesktopEnvironmentInput(context),
                                    ],
                                  ],
                                  sectionKey: const ValueKey<String>(
                                    'mcp-server-connection-section',
                                  ),
                                ),
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
        ),
      ),
    );
  }

  Widget _buildMobileDialog(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.server == null
            ? S.of(context).addMcpServer
            : S.of(context).editMcpServer,
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: S.of(context).mcpServerName,
                ),
              ),
              const SizedBox(height: 12),
              if (_transportType == McpTransportType.streamableHttp) ...[
                TextField(
                  controller: _endpointController,
                  autocorrect: false,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: S.of(context).mcpEndpoint,
                    hintText: 'https://example.com/mcp',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<McpAuthType>(
                  initialValue: _authType,
                  decoration: InputDecoration(
                    labelText: S.of(context).mcpAuthentication,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: McpAuthType.none,
                      child: Text(S.of(context).mcpNoAuthentication),
                    ),
                    DropdownMenuItem(
                      value: McpAuthType.oauthAccessToken,
                      child: Text(S.of(context).mcpAccessToken),
                    ),
                  ],
                  onChanged: (value) => _setAuthType(value ?? McpAuthType.none),
                ),
                if (_authType == McpAuthType.oauthAccessToken) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tokenController,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: S.of(context).mcpAccessToken,
                      helperText:
                          widget.server == null
                              ? S.of(context).mcpTokenStoredSecurely
                              : S.of(context).mcpTokenLeaveBlank,
                    ),
                  ),
                ],
              ] else ...[
                TextField(
                  controller: _commandController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: S.of(context).mcpCommand,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _argumentsController,
                  autocorrect: false,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: S.of(context).mcpArguments,
                    helperText: S.of(context).mcpArgumentsDescription,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _environmentController,
                  autocorrect: false,
                  obscureText: true,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: S.of(context).mcpEnvironment,
                    helperText: S.of(context).mcpEnvironmentDescription,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(S.of(context).saveAndConnect),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    final strings = S.of(context);
    final tokens = StarsDesktopTokens.of(context);
    final editing = widget.server != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.controlFill,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hub_outlined,
              size: 23,
              color: tokens.secondaryText,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editing ? strings.editMcpServer : strings.addMcpServer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DesktopThemeTokens.pageTitleStyle(context),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.mcpServersDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DesktopThemeTokens.metaStyle(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ShadTooltip(
            builder:
                (context) =>
                    Text(MaterialLocalizations.of(context).closeButtonTooltip),
            child: ShadIconButton.ghost(
              onPressed: () => Navigator.of(context).pop(),
              width: 36,
              height: 36,
              iconSize: 17,
              icon: const Icon(Icons.close_rounded),
            ),
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
      padding: const EdgeInsets.all(_desktopSectionPadding),
      backgroundColor: tokens.raisedSurface,
      border: ShadBorder.all(
        color: tokens.separator,
        width: _desktopSectionBorderWidth,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ShadSeparator.horizontal(),
        ColoredBox(
          color: ShadTheme.of(context).colorScheme.background,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _desktopFormWidth,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.outline(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(S.of(context).cancel),
                      ),
                      const SizedBox(width: 8),
                      ShadButton(
                        onPressed: _save,
                        leading: const Icon(Icons.link_rounded, size: 17),
                        child: Text(S.of(context).saveAndConnect),
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

  Widget _buildDesktopNameInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-name'),
      id: 'name',
      controller: _nameController,
      textInputAction: TextInputAction.next,
      label: Text(S.of(context).mcpServerName),
      leading: _desktopInputLeading(Icons.hub_outlined),
      constraints: _desktopInputConstraints,
      validator:
          (value) =>
              value.trim().isEmpty ? S.of(context).fillRequiredFields : null,
    );
  }

  Widget _buildDesktopTransportInput(BuildContext context) {
    final tokens = StarsDesktopTokens.of(context);
    final shadTheme = ShadTheme.of(context);
    final inputTextStyle = shadTheme.textTheme.muted
        .copyWith(color: shadTheme.colorScheme.foreground)
        .merge(shadTheme.inputTheme.style);
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-transport'),
      id: 'transport',
      controller: _transportController,
      readOnly: true,
      label: Text(S.of(context).mcpTransport),
      leading: _desktopInputLeading(Icons.swap_horiz_rounded),
      constraints: _desktopInputConstraints,
      trailing: MenuAnchor(
        crossAxisUnconstrained: false,
        alignmentOffset: const Offset(
          _desktopDropdownButtonSize - _desktopTransportMenuWidth,
          4,
        ),
        style: _desktopMenuStyle(tokens, width: _desktopTransportMenuWidth),
        menuChildren: [
          for (final transportType in McpTransportType.values)
            MenuItemButton(
              trailingIcon:
                  transportType == _transportType
                      ? Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: tokens.accent,
                      )
                      : const SizedBox.square(dimension: 16),
              onPressed: () => _setTransportType(transportType),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 180),
                child: Text(
                  _transportLabel(transportType),
                  style: inputTextStyle,
                ),
              ),
            ),
        ],
        builder:
            (context, controller, child) => ShadIconButton.ghost(
              key: const ValueKey<String>('mcp-server-transport-menu'),
              onPressed: () => _toggleMenu(controller),
              icon: const Icon(Icons.expand_more_rounded),
              iconSize: 16,
              width: _desktopDropdownButtonSize,
              height: _desktopDropdownButtonSize,
              padding: EdgeInsets.zero,
            ),
      ),
    );
  }

  Widget _buildDesktopEndpointInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-endpoint'),
      id: 'endpoint',
      controller: _endpointController,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      keyboardType: TextInputType.url,
      label: Text(S.of(context).mcpEndpoint),
      placeholder: const Text('https://example.com/mcp'),
      leading: _desktopInputLeading(LucideIcons.link),
      constraints: _desktopInputConstraints,
      validator:
          (value) =>
              value.trim().isEmpty ? S.of(context).fillRequiredFields : null,
    );
  }

  Widget _buildDesktopCommandInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-command'),
      id: 'command',
      controller: _commandController,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      label: Text(S.of(context).mcpCommand),
      description: Text(S.of(context).mcpCommandDescription),
      placeholder: const Text('npx'),
      leading: _desktopInputLeading(Icons.terminal_rounded),
      constraints: _desktopInputConstraints,
      validator:
          (value) =>
              value.trim().isEmpty ? S.of(context).fillRequiredFields : null,
    );
  }

  Widget _buildDesktopArgumentsInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-arguments'),
      id: 'arguments',
      controller: _argumentsController,
      autocorrect: false,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: 4,
      label: Text(S.of(context).mcpArguments),
      description: Text(S.of(context).mcpArgumentsDescription),
      placeholder: const Text('-y\n@modelcontextprotocol/server-filesystem'),
      leading: _desktopInputLeading(Icons.format_list_bulleted_rounded),
      constraints: const BoxConstraints(minHeight: 104),
    );
  }

  Widget _buildDesktopEnvironmentInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-environment'),
      id: 'environment',
      controller: _environmentController,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: 4,
      label: Text(S.of(context).mcpEnvironment),
      description: Text(S.of(context).mcpEnvironmentDescription),
      placeholder: const Text('API_KEY=secret'),
      leading: _desktopInputLeading(Icons.password_rounded),
      constraints: const BoxConstraints(minHeight: 104),
    );
  }

  Widget _buildDesktopAuthInput(BuildContext context) {
    final tokens = StarsDesktopTokens.of(context);
    final shadTheme = ShadTheme.of(context);
    final inputTextStyle = shadTheme.textTheme.muted
        .copyWith(color: shadTheme.colorScheme.foreground)
        .merge(shadTheme.inputTheme.style);
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      style: _desktopMenuStyle(tokens),
      menuChildren: [
        for (final authType in McpAuthType.values)
          MenuItemButton(
            trailingIcon:
                authType == _authType
                    ? Icon(Icons.check_rounded, size: 16, color: tokens.accent)
                    : const SizedBox.square(dimension: 16),
            onPressed: () => _setAuthType(authType),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180),
              child: Text(_authLabel(authType), style: inputTextStyle),
            ),
          ),
      ],
      builder:
          (context, controller, child) => ShadInputFormField(
            key: const ValueKey<String>('mcp-server-authentication'),
            id: 'authentication',
            controller: _authController,
            readOnly: true,
            label: Text(S.of(context).mcpAuthentication),
            leading: _desktopInputLeading(LucideIcons.keyRound),
            constraints: _desktopInputConstraints,
            onPressed: () => _toggleMenu(controller),
            trailing: ShadIconButton.ghost(
              key: const ValueKey<String>('mcp-server-authentication-menu'),
              onPressed: () => _toggleMenu(controller),
              icon: const Icon(Icons.expand_more_rounded),
              iconSize: 16,
              width: _desktopDropdownButtonSize,
              height: _desktopDropdownButtonSize,
              padding: EdgeInsets.zero,
            ),
          ),
    );
  }

  MenuStyle _desktopMenuStyle(StarsDesktopTokens tokens, {double? width}) {
    return MenuStyle(
      backgroundColor: WidgetStatePropertyAll(tokens.raisedSurface),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      shadowColor: WidgetStatePropertyAll(
        Colors.black.withValues(alpha: tokens.highContrast ? 0 : 0.18),
      ),
      elevation: WidgetStatePropertyAll(tokens.highContrast ? 0 : 6),
      visualDensity: width == null ? null : VisualDensity.standard,
      minimumSize:
          width == null ? null : WidgetStatePropertyAll(Size(width, 0)),
      maximumSize: WidgetStatePropertyAll(Size(width ?? 420, 240)),
      side: WidgetStatePropertyAll(
        BorderSide(color: tokens.separator, width: 0),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: DesktopThemeTokens.containerRadius,
        ),
      ),
    );
  }

  Widget _buildDesktopTokenInput(BuildContext context) {
    return ShadInputFormField(
      key: const ValueKey<String>('mcp-server-access-token'),
      id: 'accessToken',
      controller: _tokenController,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      label: Text(S.of(context).mcpAccessToken),
      description: Text(
        widget.server == null
            ? S.of(context).mcpTokenStoredSecurely
            : S.of(context).mcpTokenLeaveBlank,
      ),
      leading: _desktopInputLeading(LucideIcons.lockKeyhole),
      constraints: _desktopInputConstraints,
    );
  }

  Widget _desktopInputLeading(IconData icon) {
    return SizedBox(
      width: 17,
      height: 30,
      child: Center(child: Icon(icon, size: 17)),
    );
  }

  void _toggleMenu(MenuController controller) {
    controller.isOpen ? controller.close() : controller.open();
  }

  void _setAuthType(McpAuthType value) {
    setState(() {
      _authType = value;
      _syncAuthController();
    });
  }

  void _setTransportType(McpTransportType value) {
    setState(() {
      _transportType = value;
      if (value == McpTransportType.stdio) {
        _authType = McpAuthType.none;
      }
      _syncTransportController();
      _syncAuthController();
    });
  }

  void _syncTransportController() {
    final label = _transportLabel(_transportType);
    if (_transportController.text != label) {
      _transportController.text = label;
    }
  }

  void _syncAuthController() {
    final label = _authLabel(_authType);
    if (_authController.text != label) {
      _authController.text = label;
    }
  }

  String _authLabel(McpAuthType value) => switch (value) {
    McpAuthType.none => S.of(context).mcpNoAuthentication,
    McpAuthType.oauthAccessToken => S.of(context).mcpAccessToken,
  };

  String _transportLabel(McpTransportType value) => switch (value) {
    McpTransportType.streamableHttp => S.of(context).mcpTransportStreamableHttp,
    McpTransportType.stdio => S.of(context).mcpTransportStdio,
  };

  void _save() {
    if (widget.desktop &&
        !(_desktopFormKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }
    final name = _nameController.text.trim();
    final endpoint = _endpointController.text.trim();
    final command = _commandController.text.trim();
    if (name.isEmpty ||
        (_transportType == McpTransportType.streamableHttp &&
            endpoint.isEmpty) ||
        (_transportType == McpTransportType.stdio && command.isEmpty)) {
      return;
    }
    Navigator.of(context).pop(
      McpServerDraft(
        id: widget.server?.id,
        name: name,
        transportType: _transportType,
        endpoint: endpoint,
        command: command,
        arguments: _argumentsController.text,
        environment: _environmentController.text,
        authType:
            _transportType == McpTransportType.stdio
                ? McpAuthType.none
                : _authType,
        accessToken: _tokenController.text,
      ),
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: ListTile(
        leading: const Icon(Icons.security_outlined),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: const Icon(Icons.error_outline_rounded),
        title: Text(message),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Column(
        children: [
          const Icon(Icons.hub_outlined, size: 56),
          const SizedBox(height: 16),
          Text(
            S.of(context).noMcpServers,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).noMcpServersDescription,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: Text(S.of(context).addMcpServer),
          ),
        ],
      ),
    );
  }
}
