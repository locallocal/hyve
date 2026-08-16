part of 'profile.dart';

extension _ProfileAboutSection on _ProfilePageState {
  Widget _buildAboutContent(
    BuildContext dialogContext, {
    required bool embedded,
  }) {
    final strings = S.of(dialogContext);
    final tokens = HyveDesktopTokens.of(dialogContext);
    final titleStyle =
        embedded
            ? ShadTheme.of(dialogContext).textTheme.h4
            : Theme.of(
              dialogContext,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    final bodyStyle =
        embedded
            ? HyveDesktopThemeSpec.bodyStyle(dialogContext)
            : Theme.of(dialogContext).textTheme.bodyMedium;
    final mutedStyle =
        embedded
            ? ShadTheme.of(dialogContext).textTheme.muted
            : Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
              color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
            );

    void openLegalPage(VoidCallback openPage) {
      Navigator.pop(dialogContext);
      openPage();
    }

    return SizedBox(
      width: 440,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              key: const ValueKey<String>('profile-about-brand-card'),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: tokens.controlFill,
                border: Border.all(color: tokens.separator),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const HyveLogo(size: 60),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          desktopConversationText(
                            dialogContext,
                            strings.appTitle,
                          ),
                          style: titleStyle,
                        ),
                        const SizedBox(height: 8),
                        ShadBadge.outline(
                          key: const ValueKey<String>('profile-about-version'),
                          child: Text(strings.version),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              desktopConversationText(dialogContext, strings.appDescription),
              key: const ValueKey<String>('profile-about-description'),
              style: bodyStyle,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: tokens.separator),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                if (embedded)
                  ShadButton.link(
                    key: const ValueKey<String>('profile-about-user-agreement'),
                    onPressed: () => openLegalPage(_openUserAgreementPage),
                    leading: const Icon(Icons.description_outlined, size: 16),
                    child: Text(strings.userAgreement),
                  )
                else
                  TextButton.icon(
                    key: const ValueKey<String>('profile-about-user-agreement'),
                    onPressed: () => openLegalPage(_openUserAgreementPage),
                    icon: const Icon(Icons.description_outlined, size: 17),
                    label: Text(strings.userAgreement),
                  ),
                if (embedded)
                  ShadButton.link(
                    key: const ValueKey<String>('profile-about-privacy-policy'),
                    onPressed: () => openLegalPage(_openPrivacyPolicyPage),
                    leading: const Icon(Icons.privacy_tip_outlined, size: 16),
                    child: Text(strings.privacyPolicy),
                  )
                else
                  TextButton.icon(
                    key: const ValueKey<String>('profile-about-privacy-policy'),
                    onPressed: () => openLegalPage(_openPrivacyPolicyPage),
                    icon: const Icon(Icons.privacy_tip_outlined, size: 17),
                    label: Text(strings.privacyPolicy),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              strings.copyright(DateTime.now().year),
              key: const ValueKey<String>('profile-about-copyright'),
              style: mutedStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomAboutDialog() {
    if (isDesktopPlatform(context)) {
      showShadDialog<void>(
        context: context,
        builder:
            (dialogContext) => ShadDialog(
              key: const ValueKey<String>('profile-about-dialog'),
              closeIcon: _buildDesktopDialogClose(
                dialogContext,
                key: const ValueKey<String>('profile-about-close'),
              ),
              closeIconPosition: _desktopDialogClosePosition(dialogContext),
              title: Text(S.of(dialogContext).aboutApp),
              actions: [
                ShadButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(S.of(dialogContext).confirm),
                ),
              ],
              child: _buildAboutContent(dialogContext, embedded: true),
            ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            key: const ValueKey<String>('profile-about-dialog'),
            title: Center(
              child: Text(
                S.of(context).aboutApp,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: SingleChildScrollView(
              child: _buildAboutContent(context, embedded: false),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  S.of(context).confirm,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: _fontSize,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // 显示语言选项
  void _showLanguageOptions() {
    const languages = [
      (code: 'zh_CN', name: '简体中文'),
      (code: 'en_US', name: 'English'),
      (code: 'zh_TW', name: '繁體中文'),
      (code: 'ja_JP', name: '日本語'),
      (code: 'fr_FR', name: 'Français'),
      (code: 'de_DE', name: 'Deutsch'),
      (code: 'ko_KR', name: '한국어'),
      (code: 'ru_RU', name: 'Русский'),
      (code: 'es_ES', name: 'Español'),
      (code: 'hi_IN', name: 'हिन्दी'),
      (code: 'pt_BR', name: 'Português'),
      (code: 'it_IT', name: 'Italiano'),
    ];
    if (isDesktopPlatform(context)) {
      showShadDialog<void>(
        context: context,
        builder: (dialogContext) {
          final tokens = HyveDesktopTokens.of(dialogContext);
          return ShadDialog(
            key: const ValueKey<String>('profile-language-dialog'),
            closeIcon: _buildDesktopDialogClose(
              dialogContext,
              key: const ValueKey<String>('profile-language-close'),
            ),
            closeIconPosition: _desktopDialogClosePosition(dialogContext),
            title: Text(S.of(dialogContext).selectLanguage),
            description: Text(
              S.of(dialogContext).desktopSavedImmediatelyDescription,
            ),
            child: SizedBox(
              width: 380,
              height: 440,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  key: const ValueKey<String>('profile-language-options'),
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: tokens.raisedSurface,
                    borderRadius: HyveDesktopThemeSpec.containerRadius,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final language in languages)
                          Semantics(
                            selected: language.code == _language,
                            child: ShadButton.raw(
                              key: ValueKey<String>(
                                'profile-language-option-${language.code}',
                              ),
                              variant:
                                  language.code == _language
                                      ? ShadButtonVariant.secondary
                                      : ShadButtonVariant.ghost,
                              height: 44,
                              expands: true,
                              mainAxisAlignment: MainAxisAlignment.start,
                              trailing:
                                  language.code == _language
                                      ? Icon(
                                        LucideIcons.check,
                                        size: 16,
                                        color: tokens.accent,
                                      )
                                      : const SizedBox.square(dimension: 16),
                              onPressed: () {
                                _updateState(() => _language = language.code);
                                _saveProfile();
                                Navigator.pop(dialogContext);
                              },
                              child: Text(
                                language.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        S.of(context).selectLanguage,
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: RadioGroup<String>(
                      groupValue: _language,
                      onChanged: (value) {
                        if (value == null) return;
                        _updateState(() {
                          _language = value;
                        });
                        _saveProfile();
                        Navigator.pop(context);
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLanguageOption('zh_CN', '简体中文'),
                            _buildLanguageOption('en_US', 'English'),
                            _buildLanguageOption('zh_TW', '繁體中文'),
                            _buildLanguageOption('ja_JP', '日本語'),
                            _buildLanguageOption('fr_FR', 'Français'),
                            _buildLanguageOption('de_DE', 'Deutsch'),
                            _buildLanguageOption('ko_KR', '한국어'),
                            _buildLanguageOption('ru_RU', 'Русский'),
                            _buildLanguageOption('es_ES', 'Español'),
                            _buildLanguageOption('hi_IN', 'हिन्दी'),
                            _buildLanguageOption('pt_BR', 'Português'),
                            _buildLanguageOption('it_IT', 'Italiano'),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // 构建语言选项
  Widget _buildLanguageOption(String code, String name) {
    return RadioListTile<String>(
      title: Text(name),
      activeColor: Theme.of(context).colorScheme.onSurface,
      value: code,
    );
  }

  // 构建设置项目
  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Key? key,
    bool showSlider = false,
  }) {
    final isDesktop = isDesktopPlatform(context);
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius:
          isDesktop
              ? HyveDesktopThemeSpec.itemRadius
              : BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 12.0 : 8.0,
          horizontal: isDesktop ? 12.0 : 0.0,
        ),
        child: Row(
          children: [
            Container(
              width: isDesktop ? 36.0 : 24.0,
              height: isDesktop ? 36.0 : 24.0,
              decoration:
                  isDesktop
                      ? BoxDecoration(
                        color: HyveDesktopThemeSpec.selectedFill(context),
                        borderRadius: HyveDesktopThemeSpec.controlRadius,
                      )
                      : null,
              child: Icon(
                icon,
                size: 20.0,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        isDesktop
                            ? HyveDesktopThemeSpec.bodyStyle(context)?.copyWith(
                              fontSize: _fontSize,
                              fontWeight: FontWeight.w600,
                            )
                            : TextStyle(
                              fontSize: _fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                  ),
                  Text(
                    subtitle,
                    style:
                        isDesktop
                            ? HyveDesktopThemeSpec.metaStyle(
                              context,
                            )?.copyWith(fontSize: _fontSize - 2)
                            : TextStyle(
                              fontSize: _fontSize - 2,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                  ),
                ],
              ),
            ),
            if (!showSlider)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.0,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
          ],
        ),
      ),
    );
  }
}
