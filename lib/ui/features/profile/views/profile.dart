import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/utils/utils.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/services/stars_system_prompt.dart';
import 'package:stars/l10n/app_localizations.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/core/dependency_injection/app_scope.dart';
import 'package:stars/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:stars/ui/features/feedback/views/feedback_page.dart';
import 'package:stars/ui/features/profile/view_models/profile_view_model.dart';
import 'package:stars/ui/features/profile/views/privacy_policy.dart';
import 'package:stars/ui/features/profile/views/user_agreement.dart';
import 'package:stars/utils/theme.dart';

part 'profile_settings_controls.dart';
part 'profile_dialogs.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.selectedSection = 0,
    this.initialProfile,
    this.onProfileSaved,
    this.viewModel,
    this.avatarPicker,
    this.applicationPromptProvider,
    required this.onOpenSkillLibrary,
    required this.onOpenMcpServers,
  });

  final int selectedSection;
  final Profile? initialProfile;
  final Future<void> Function(Profile profile)? onProfileSaved;
  final ProfileViewModel? viewModel;
  final Future<String?> Function()? avatarPicker;
  final String Function()? applicationPromptProvider;
  final VoidCallback onOpenSkillLibrary;
  final VoidCallback onOpenMcpServers;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const double _defaultFontSize = 16.0;

  Profile? _profile;
  bool _isLoading = true;
  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'zh_CN'; // 语言设置
  ProfileViewModel? _resolvedViewModel;
  bool _loadStarted = false;
  final List<GlobalKey> _desktopSectionKeys = List<GlobalKey>.generate(
    5,
    (_) => GlobalKey(),
  );

  // 随机英文名称列表
  final List<String> _randomNames = [
    'Alex',
    'Blake',
    'Casey',
    'Dana',
    'Eden',
    'Finley',
    'Gray',
    'Harper',
    'Jordan',
    'Kelly',
    'Logan',
    'Morgan',
    'Noah',
    'Parker',
    'Quinn',
    'Riley',
    'Skyler',
    'Taylor',
    'Avery',
    'Bailey',
  ];

  // 获取随机英文名称
  String get _randomName => _randomNames[Random().nextInt(_randomNames.length)];
  // 获取用户名
  String get _name => _profile?.name ?? _randomName;
  // 获取头像路径
  String get _avatar => _profile?.avatar ?? "";
  // 获取字体大小
  double get _fontSize => _profile?.fontSize ?? 16.0;
  bool get _showExecutionStatus => _profile?.showExecutionStatus ?? true;
  String get _applicationInjectedPrompt =>
      (widget.applicationPromptProvider?.call() ?? currentStarsSystemPrompt())
          .trim();

  @override
  void initState() {
    super.initState();
    final initialProfile = widget.initialProfile;
    if (initialProfile == null) {
      if (widget.viewModel != null) _loadProfileInfo();
    } else {
      _profile = initialProfile;
      _themeMode = intToThemeMode(initialProfile.themeMode);
      _language = initialProfile.language;
      _isLoading = false;
      _scheduleSelectedSectionScroll();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profile != null || _loadStarted) return;
    _resolvedViewModel ??= AppScope.of(context).createProfileViewModel();
    _loadProfileInfo();
  }

  @override
  void dispose() {
    _resolvedViewModel?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSection != widget.selectedSection) {
      _scheduleSelectedSectionScroll();
    }
  }

  Future<void> _loadProfileInfo() async {
    if (_loadStarted) return;
    _loadStarted = true;
    setState(() {
      _isLoading = true;
    });

    final viewModel = widget.viewModel ?? _resolvedViewModel!;
    if (viewModel.profile == null) await viewModel.load();
    final loadedProfile = viewModel.profile;

    if (!mounted) return;
    if (loadedProfile == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _profile = loadedProfile;
      _themeMode = intToThemeMode(loadedProfile.themeMode);
      _language = loadedProfile.language; // 加载语言设置
      _isLoading = false;
    });
    _scheduleSelectedSectionScroll();
  }

  void _scheduleSelectedSectionScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !isDesktopPlatform(context)) return;

      final index = widget.selectedSection.clamp(
        0,
        _desktopSectionKeys.length - 1,
      );
      final sectionContext = _desktopSectionKeys[index].currentContext;
      if (sectionContext == null) return;

      final disableAnimations = MediaQuery.disableAnimationsOf(context);
      Scrollable.ensureVisible(
        sectionContext,
        alignment: 0.08,
        duration:
            disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _pickImage() async {
    final pickAvatar =
        widget.avatarPicker ??
        widget.viewModel?.pickAvatar ??
        _resolvedViewModel?.pickAvatar;
    final imagePath = await pickAvatar?.call();

    if (imagePath != null && mounted) {
      setState(() {
        if (_profile != null) {
          _profile = Profile(
            name: _name,
            avatar: imagePath,
            fontSize: _fontSize,
            language: _language,
            themeMode: themeModeToInt(_themeMode),
            showExecutionStatus: _showExecutionStatus,
            createTimestamp: _profile!.createTimestamp,
            modifyTimestamp: DateTime.now(),
          );
          _saveProfile(); // 保存头像设置
        }
      });
    }
  }

  // 保存设置
  Future<void> _saveProfile() async {
    if (_profile == null) return;

    final profile = Profile(
      name: _name,
      avatar: _avatar,
      fontSize: _fontSize,
      themeMode: themeModeToInt(_themeMode),
      language: _language, // 添加语言设置
      showExecutionStatus: _showExecutionStatus,
      createTimestamp: _profile!.createTimestamp,
      modifyTimestamp: DateTime.now(),
    );
    final onProfileSaved = widget.onProfileSaved;
    if (onProfileSaved != null) {
      await onProfileSaved(profile);
    } else {
      await (widget.viewModel ?? _resolvedViewModel!).save(profile);
    }
    _profile = profile; // 更新本地缓存
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDesktopPlatform(context);

    if (_isLoading) {
      if (isDesktop) {
        return const Center(child: CircularProgressIndicator());
      }
      return Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.surface),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (isDesktop) {
      return _buildDesktopBody(context);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          S.of(context).profile,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0, // 防止滚动时背景色变化
        elevation: 0, // 移除阴影
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildMobileBody(context),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
              child: Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        backgroundImage: _buildAvatarImageProvider(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            _buildSettingsSection(
              context,
              title: S.of(context).desktopPersonalInformation,
              children: [
                _buildSettingItem(
                  context,
                  Icons.person_rounded,
                  S.of(context).name,
                  _name,
                  _showEditNameDialog,
                ),
              ],
            ),
            _buildSettingsSection(
              context,
              title: S.of(context).desktopAppearanceAndLanguage,
              children: [
                _buildSettingItem(
                  context,
                  Icons.brightness_6_rounded,
                  S.of(context).themeSettings,
                  _themeLabel(context),
                  _showThemeOptions,
                ),
                const SizedBox(height: 8),
                _buildSettingItem(
                  context,
                  Icons.language_rounded,
                  S.of(context).languageSettings,
                  getLanguageName(_language),
                  _showLanguageOptions,
                ),
                const SizedBox(height: 8),
                _buildSettingItem(
                  context,
                  Icons.text_fields_rounded,
                  S.of(context).fontSizeSettings,
                  S.of(context).adjustAppFontSize,
                  _showFontSizeDialog,
                ),
                _buildFontSizeSlider(context),
              ],
            ),
            _buildSettingsSection(
              context,
              title: S.of(context).desktopGeneral,
              children: [
                _buildSettingItem(
                  context,
                  Icons.build_rounded,
                  S.of(context).skillLibrary,
                  S.of(context).skillLibraryDescription,
                  widget.onOpenSkillLibrary,
                  key: const ValueKey<String>('profile-skill-library'),
                ),
                const SizedBox(height: 8),
                _buildSettingItem(
                  context,
                  Icons.hub_outlined,
                  S.of(context).mcpServers,
                  S.of(context).mcpServersDescription,
                  widget.onOpenMcpServers,
                  key: const ValueKey<String>('profile-mcp-servers'),
                ),
                const SizedBox(height: 12),
                _buildApplicationInjectedPrompt(context, desktop: false),
              ],
            ),
            _buildSettingsSection(
              context,
              title: S.of(context).desktopHelpAndSupport,
              children: [
                _buildSettingItem(
                  context,
                  Icons.help_rounded,
                  S.of(context).helpAndFeedback,
                  S.of(context).provideFeedback,
                  _openFeedbackPage,
                ),
                const SizedBox(height: 8),
                _buildSettingItem(
                  context,
                  Icons.info_rounded,
                  S.of(context).about,
                  S.of(context).version,
                  _showCustomAboutDialog,
                  key: const ValueKey<String>('profile-about'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return ColoredBox(
      color: StarsDesktopThemeSpec.workspaceSurface(context),
      child: SingleChildScrollView(
        padding: StarsDesktopThemeSpec.formPagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: StarsDesktopThemeSpec.formContentMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).profile,
                  style: StarsDesktopThemeSpec.pageTitleStyle(context),
                ),
                const SizedBox(height: 6),
                Text(
                  S.of(context).desktopSettingsDescription,
                  style: StarsDesktopThemeSpec.bodyStyle(
                    context,
                  )?.copyWith(color: StarsDesktopThemeSpec.mutedText(context)),
                ),
                const SizedBox(height: 32),
                _buildDesktopSettingsSection(
                  context,
                  sectionKey: _desktopSectionKeys[0],
                  title: S.of(context).desktopPersonalInformation,
                  description: S.of(context).desktopEditProfileDescription,
                  children: [_buildDesktopProfileRow(context)],
                ),
                const SizedBox(height: 32),
                _buildDesktopSettingsSection(
                  context,
                  sectionKey: _desktopSectionKeys[1],
                  title: S.of(context).desktopAppearanceAndLanguage,
                  description: S.of(context).desktopSavedImmediatelyDescription,
                  children: [
                    _buildDesktopSettingRow(
                      context,
                      icon: Icons.brightness_6_outlined,
                      title: S.of(context).themeSettings,
                      value: _themeLabel(context),
                      onTap: _showThemeOptions,
                    ),
                    _buildDesktopSettingRow(
                      context,
                      icon: Icons.language_outlined,
                      title: S.of(context).languageSettings,
                      value: getLanguageName(_language),
                      onTap: _showLanguageOptions,
                    ),
                    _buildDesktopFontSizeControl(context),
                  ],
                ),
                const SizedBox(height: 32),
                _buildDesktopSettingsSection(
                  context,
                  sectionKey: _desktopSectionKeys[2],
                  title: S.of(context).desktopGeneral,
                  description: S.of(context).desktopSavedImmediatelyDescription,
                  children: [
                    _buildDesktopSettingRow(
                      context,
                      key: const ValueKey<String>('profile-skill-library'),
                      icon: LucideIcons.wrench,
                      title: S.of(context).skillLibrary,
                      subtitle: S.of(context).skillLibraryDescription,
                      onTap: widget.onOpenSkillLibrary,
                    ),
                    _buildDesktopSettingRow(
                      context,
                      key: const ValueKey<String>('profile-mcp-servers'),
                      icon: Icons.hub_outlined,
                      title: S.of(context).mcpServers,
                      subtitle: S.of(context).mcpServersDescription,
                      onTap: widget.onOpenMcpServers,
                    ),
                    _buildDesktopExecutionStatusControl(context),
                    _buildApplicationInjectedPrompt(context, desktop: true),
                  ],
                ),
                const SizedBox(height: 32),
                _buildDesktopSettingsSection(
                  context,
                  sectionKey: _desktopSectionKeys[3],
                  title: S.of(context).desktopHelpAndSupport,
                  children: [
                    _buildDesktopSettingRow(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: S.of(context).helpAndFeedback,
                      subtitle: S.of(context).provideFeedback,
                      onTap: _openFeedbackPage,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildDesktopSettingsSection(
                  context,
                  sectionKey: _desktopSectionKeys[4],
                  title: S.of(context).desktopAboutAndLegal,
                  children: [
                    _buildDesktopSettingRow(
                      context,
                      key: const ValueKey<String>('profile-about'),
                      icon: Icons.info_outline_rounded,
                      title: S.of(context).about,
                      subtitle: S.of(context).version,
                      onTap: _showCustomAboutDialog,
                    ),
                    _buildDesktopSettingRow(
                      context,
                      icon: Icons.description_outlined,
                      title: S.of(context).userAgreement,
                      onTap: _openUserAgreementPage,
                    ),
                    _buildDesktopSettingRow(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: S.of(context).privacyPolicy,
                      onTap: _openPrivacyPolicyPage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutContent(
    BuildContext dialogContext, {
    required bool embedded,
  }) {
    final strings = S.of(dialogContext);
    final tokens = StarsDesktopTokens.of(dialogContext);
    final titleStyle =
        embedded
            ? ShadTheme.of(dialogContext).textTheme.h4
            : Theme.of(
              dialogContext,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    final bodyStyle =
        embedded
            ? StarsDesktopThemeSpec.bodyStyle(dialogContext)
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
                  const StarsLogo(size: 60),
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
          final tokens = StarsDesktopTokens.of(dialogContext);
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
                    borderRadius: StarsDesktopThemeSpec.containerRadius,
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
                                setState(() => _language = language.code);
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
                        setState(() {
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
      borderRadius: BorderRadius.circular(isDesktop ? 14.0 : 16.0),
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
                        color: StarsDesktopThemeSpec.selectedFill(context),
                        borderRadius: BorderRadius.circular(12),
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
                            ? StarsDesktopThemeSpec.bodyStyle(
                              context,
                            )?.copyWith(
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
                            ? StarsDesktopThemeSpec.metaStyle(
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

// 自定义Logo组件
class StarsLogo extends StatelessWidget {
  final double size;

  const StarsLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Image.asset(
        'assets/icon/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
