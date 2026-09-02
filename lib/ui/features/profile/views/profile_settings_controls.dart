part of 'profile.dart';

// State mutations remain owned by the host State object in this library part.
// ignore_for_file: invalid_use_of_protected_member

extension _ProfileSettingsControls on _ProfilePageState {
  Widget _buildDesktopSettingsSection(
    BuildContext context, {
    required GlobalKey sectionKey,
    required String title,
    String? description,
    required List<Widget> children,
  }) {
    return KeyedSubtree(
      key: sectionKey,
      child: ShadCard(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        title: Text(
          title,
          style: HyveDesktopThemeSpec.sectionTitleStyle(context)?.copyWith(
            fontSize: HyveDesktopThemeSpec.botFormSectionTitleFontSize,
          ),
        ),
        description: description == null ? null : Text(description),
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1)
                  const ShadSeparator.horizontal(
                    margin: HyveDesktopThemeSpec.settingsRowSeparatorMargin,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopProfileRow(BuildContext context) {
    return _buildDesktopSettingRow(
      context,
      key: const ValueKey<String>('profile-name-setting'),
      leading: ShadTooltip(
        builder: (context) => Text(S.of(context).changeAvatar),
        child: ShadButton.ghost(
          width: 56,
          height: 56,
          padding: EdgeInsets.zero,
          onPressed: _pickImage,
          child: Semantics(
            label: S.of(context).changeAvatar,
            image: true,
            child: CircleAvatar(
              radius: 28,
              backgroundColor: HyveDesktopThemeSpec.secondarySurface(context),
              backgroundImage: _buildAvatarImageProvider(),
            ),
          ),
        ),
      ),
      title: S.of(context).name,
      value: _name,
      onTap: _showEditNameDialog,
    );
  }

  Widget _buildDesktopSettingRow(
    BuildContext context, {
    Key? key,
    IconData? icon,
    Widget? leading,
    required String title,
    String? subtitle,
    String? value,
    required VoidCallback onTap,
  }) {
    assert(icon != null || leading != null);
    return Semantics(
      button: true,
      label: title,
      value: value ?? subtitle,
      child: ShadButton.ghost(
        key: key,
        width: double.infinity,
        height: 0,
        expands: true,
        padding: HyveDesktopThemeSpec.settingsRowPadding,
        mainAxisAlignment: MainAxisAlignment.start,
        onPressed: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: HyveDesktopThemeSpec.settingsRowMinHeight,
          ),
          child: Row(
            children: [
              SizedBox(
                width:
                    leading == null
                        ? HyveDesktopThemeSpec.settingsRowIconSlotWidth
                        : 56,
                child:
                    leading ??
                    Icon(
                      icon,
                      size: HyveDesktopThemeSpec.settingsRowIconSize,
                      color: HyveDesktopThemeSpec.mutedText(context),
                    ),
              ),
              const SizedBox(width: HyveDesktopThemeSpec.settingsRowIconGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: HyveDesktopThemeSpec.bodyStyle(context)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: HyveDesktopThemeSpec.metaStyle(context),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: HyveDesktopThemeSpec.settingsRowValueGap),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: HyveDesktopThemeSpec.settingsRowValueMaxWidth,
                  ),
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HyveDesktopThemeSpec.metaStyle(context),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: HyveDesktopThemeSpec.softText(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopFontSizeControl(BuildContext context) {
    final isDefault =
        (_fontSize - _ProfilePageState._defaultFontSize).abs() < 0.01;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                child: Icon(
                  Icons.text_fields_outlined,
                  size: 18,
                  color: HyveDesktopThemeSpec.mutedText(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.of(context).fontSizeSettings,
                  style: HyveDesktopThemeSpec.bodyStyle(context),
                ),
              ),
              Text(
                '${_fontSize.round()} px',
                style: HyveDesktopThemeSpec.metaStyle(
                  context,
                )?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              ShadButton.ghost(
                enabled: !isDefault,
                size: ShadButtonSize.sm,
                onPressed:
                    () => _commitFontSize(_ProfilePageState._defaultFontSize),
                leading: const Icon(Icons.restart_alt_rounded, size: 16),
                child: Text(S.of(context).resetToDefault),
              ),
            ],
          ),
          Slider(
            value: _fontSize,
            min: 12,
            max: 24,
            divisions: 12,
            label: _fontSize.round().toString(),
            onChanged: _previewFontSize,
            onChangeEnd: _commitFontSize,
            semanticFormatterCallback:
                (value) => '${value.round()} ${S.of(context).fontSizeSettings}',
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: HyveDesktopThemeSpec.statusDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).previewText,
                  style: HyveDesktopThemeSpec.metaStyle(context),
                ),
                const SizedBox(height: 6),
                Text(
                  desktopProjectText(context, S.of(context).appDescription),
                  style: TextStyle(
                    color: HyveDesktopThemeSpec.text(context),
                    fontSize: _fontSize,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionStatusControl(
    BuildContext context, {
    required bool desktop,
  }) {
    final strings = S.of(context);
    final shadTheme = ShadTheme.of(context);
    final titleStyle =
        desktop
            ? HyveDesktopThemeSpec.bodyStyle(context)
            : shadTheme.textTheme.small.copyWith(
              color: shadTheme.colorScheme.foreground,
              fontSize: _fontSize,
              fontWeight: FontWeight.w500,
            );
    final descriptionStyle =
        desktop
            ? HyveDesktopThemeSpec.metaStyle(context)
            : shadTheme.textTheme.muted.copyWith(fontSize: _fontSize - 2);

    return Semantics(
      key: const ValueKey<String>('profile-execution-status-setting'),
      container: true,
      enabled: true,
      toggled: _showExecutionStatus,
      label: strings.executionStatus,
      hint: strings.showExecutionStatusDescription,
      onTap: () => _updateShowExecutionStatus(!_showExecutionStatus),
      child: ExcludeSemantics(
        child: Padding(
          padding:
              desktop
                  ? const EdgeInsets.symmetric(vertical: 14, horizontal: 8)
                  : const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width:
                    desktop
                        ? HyveDesktopThemeSpec.settingsRowIconSlotWidth
                        : 24,
                child: Icon(
                  LucideIcons.activity,
                  size: desktop ? HyveDesktopThemeSpec.settingsRowIconSize : 20,
                  color: shadTheme.colorScheme.mutedForeground,
                ),
              ),
              SizedBox(
                width: desktop ? HyveDesktopThemeSpec.settingsRowIconGap : 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.executionStatus, style: titleStyle),
                    const SizedBox(height: 3),
                    Text(
                      strings.showExecutionStatusDescription,
                      style: descriptionStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ShadSwitch(
                key: const ValueKey<String>(
                  'profile-show-execution-status-switch',
                ),
                value: _showExecutionStatus,
                onChanged: _updateShowExecutionStatus,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _previewFontSize(double value) {
    if (_profile == null || (_fontSize - value).abs() < 0.01) return;

    setState(() {
      _profile = Profile(
        name: _name,
        avatar: _avatar,
        fontSize: value,
        themeMode: themeModeToInt(_themeMode),
        language: _language,
        showExecutionStatus: _showExecutionStatus,
        createTimestamp: _profile!.createTimestamp,
        modifyTimestamp: DateTime.now(),
      );
    });
  }

  Future<void> _commitFontSize(double value) async {
    _previewFontSize(value);
    await _saveProfile();
  }

  Future<void> _updateShowExecutionStatus(bool value) async {
    if (_profile == null || _showExecutionStatus == value) return;
    setState(() {
      _profile = Profile(
        name: _name,
        avatar: _avatar,
        fontSize: _fontSize,
        themeMode: themeModeToInt(_themeMode),
        language: _language,
        showExecutionStatus: value,
        createTimestamp: _profile!.createTimestamp,
        modifyTimestamp: DateTime.now(),
      );
    });
    await _saveProfile();
  }

  Widget _buildFontSizeSlider(BuildContext context) {
    final slider = Slider(
      value: _fontSize,
      min: 12.0,
      max: 24.0,
      divisions: 12,
      activeColor: Theme.of(context).colorScheme.onSurface,
      inactiveColor: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.3),
      label: _fontSize.round().toString(),
      onChanged: _previewFontSize,
      onChangeEnd: _commitFontSize,
    );

    if (isDesktopPlatform(context)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: HyveDesktopThemeSpec.statusDecoration(context),
        child: slider,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
      child: slider,
    );
  }

  String _themeLabel(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return S.of(context).followSystem;
    }
    if (_themeMode == ThemeMode.light) {
      return S.of(context).lightMode;
    }
    return S.of(context).darkMode;
  }

  List<({String title, ThemeMode mode, IconData icon})> _themeChoices(
    BuildContext context,
  ) => [
    (
      title: S.of(context).followSystem,
      mode: ThemeMode.system,
      icon: Icons.brightness_6_rounded,
    ),
    (
      title: S.of(context).lightMode,
      mode: ThemeMode.light,
      icon: Icons.brightness_5_rounded,
    ),
    (
      title: S.of(context).darkMode,
      mode: ThemeMode.dark,
      icon: Icons.brightness_2_rounded,
    ),
  ];

  ImageProvider _buildAvatarImageProvider() {
    if (_avatar.isNotEmpty) {
      return FileImage(File(_avatar));
    }
    return const ResizeImage(
      AssetImage(defaultProfileAvatarAsset),
      width: 256,
      height: 256,
    );
  }
}
