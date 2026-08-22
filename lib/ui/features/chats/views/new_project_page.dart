import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/ui/core/widgets/common.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/ui/core/widgets/logo.dart';
import 'package:hyve/ui/features/chats/view_models/new_project_view_model.dart';
import 'package:hyve/utils/theme.dart';
import 'package:hyve/utils/utils.dart';

part 'new_project_page_widgets.dart';

class NewProjectPage extends StatefulWidget {
  const NewProjectPage({super.key, required this.viewModel});

  final NewProjectViewModel viewModel;

  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  static const double _desktopFieldWidth =
      HyveDesktopThemeSpec.addBotFormFieldWidth;
  static const double _desktopSectionPadding =
      HyveDesktopThemeSpec.botFormSectionPadding;
  static const double _desktopSectionBorderWidth =
      HyveDesktopThemeSpec.botFormSectionBorderWidth;
  static const double _desktopFormWidth =
      _desktopFieldWidth +
      _desktopSectionPadding * 2 +
      _desktopSectionBorderWidth * 2;
  static const BoxConstraints _desktopInputConstraints = BoxConstraints(
    minHeight: HyveDesktopThemeSpec.botFormFieldHeight,
  );

  final GlobalKey<ShadFormState> _desktopFormKey = GlobalKey<ShadFormState>();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode(debugLabel: 'project-name');
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _scrollController.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final desktop = isDesktopPlatform(context);
        return desktop
            ? _buildDesktopDialog(context)
            : _buildMobileDialog(context);
      },
    );
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
        key: const ValueKey<String>('new-project-dialog-content'),
        width: dialogWidth,
        height: dialogHeight,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              _buildDesktopHeader(context),
              const ShadSeparator.horizontal(),
              Expanded(child: _buildContent(context, desktop: true)),
              _buildDesktopFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDialog(BuildContext context) {
    final windowHeight = MediaQuery.sizeOf(context).height;
    final contentHeight = (windowHeight * 0.62).clamp(280.0, 560.0);
    return AlertDialog(
      title: Text(S.of(context).newProject),
      content: SizedBox(
        width: 520,
        height: contentHeight,
        child: _buildContent(context, desktop: false),
      ),
      actions: [
        TextButton(
          onPressed:
              widget.viewModel.isSaving
                  ? null
                  : () => Navigator.of(context).pop(),
          child: Text(S.of(context).cancel),
        ),
        FilledButton(
          key: const ValueKey<String>('create-project-submit'),
          onPressed: widget.viewModel.isSaving ? null : _submit,
          child: Text(S.of(context).createProject),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    final tokens = HyveDesktopTokens.of(context);
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
              LucideIcons.folderKanban,
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
                  S.of(context).newProject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HyveDesktopThemeSpec.pageTitleStyle(context),
                ),
                const SizedBox(height: 2),
                Text(
                  S.of(context).newProjectDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HyveDesktopThemeSpec.metaStyle(context),
                ),
              ],
            ),
          ),
          HyveDesktopIconAction(
            key: const ValueKey<String>('new-project-close'),
            icon: LucideIcons.x,
            label: MaterialLocalizations.of(context).closeButtonTooltip,
            enabled: !widget.viewModel.isSaving,
            onPressed:
                widget.viewModel.isSaving
                    ? null
                    : () => Navigator.of(context).pop(),
            iconSize: 17,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool desktop}) {
    if (widget.viewModel.isLoading) {
      return Center(
        child:
            desktop
                ? const SizedBox(width: 160, child: ShadProgress())
                : const CircularProgressIndicator(),
      );
    }
    if (widget.viewModel.error case final error?
        when widget.viewModel.bots.isEmpty) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HyveInlineErrorAlert(
                  error: safeFailureMessage(context, error),
                  isDesktop: desktop,
                  onDismiss: widget.viewModel.clearError,
                ),
                const SizedBox(height: 16),
                if (desktop)
                  ShadButton.outline(
                    onPressed: widget.viewModel.load,
                    child: Text(S.of(context).retry),
                  )
                else
                  OutlinedButton(
                    onPressed: widget.viewModel.load,
                    child: Text(S.of(context).retry),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          desktop ? 24 : 0,
          desktop ? 20 : 0,
          desktop ? 24 : 0,
          desktop ? 28 : 8,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: desktop ? _desktopFormWidth : 720,
            ),
            child:
                desktop
                    ? ShadForm(
                      key: _desktopFormKey,
                      autovalidateMode:
                          ShadAutovalidateMode.alwaysAfterFirstValidation,
                      child: _buildFormFields(context, desktop: true),
                    )
                    : _buildFormFields(context, desktop: false),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context, {required bool desktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          title: S.of(context).projectName,
          child:
              desktop
                  ? ShadInputFormField(
                    key: const ValueKey<String>('project-name-input'),
                    id: 'projectName',
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    enabled: !widget.viewModel.isSaving,
                    maxLength: 80,
                    inputFormatters: [LengthLimitingTextInputFormatter(80)],
                    padding: HyveDesktopThemeSpec.formFieldPadding,
                    textInputAction: TextInputAction.next,
                    label: Text(S.of(context).projectName),
                    placeholder: Text(S.of(context).projectNameHint),
                    leading: const SizedBox(
                      width: 17,
                      height: 44,
                      child: Center(
                        child: Icon(LucideIcons.folderKanban, size: 17),
                      ),
                    ),
                    constraints: _desktopInputConstraints,
                    onChanged: widget.viewModel.setName,
                    validator:
                        (value) =>
                            value.trim().isEmpty
                                ? S.of(context).projectNameRequired
                                : null,
                  )
                  : TextField(
                    key: const ValueKey<String>('project-name-input'),
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    enabled: !widget.viewModel.isSaving,
                    maxLength: 80,
                    inputFormatters: [LengthLimitingTextInputFormatter(80)],
                    textInputAction: TextInputAction.next,
                    onChanged: widget.viewModel.setName,
                    decoration: InputDecoration(
                      labelText: S.of(context).projectName,
                      hintText: S.of(context).projectNameHint,
                      errorText:
                          widget.viewModel.validationErrors.contains(
                                NewProjectValidationError.nameRequired,
                              )
                              ? S.of(context).projectNameRequired
                              : null,
                    ),
                  ),
        ),
        const SizedBox(height: 20),
        _Section(
          title: S.of(context).selectProjectBots,
          trailing: Text(
            S
                .of(context)
                .selectedBotCount(widget.viewModel.selectedBotIds.length),
            style:
                desktop
                    ? HyveDesktopThemeSpec.metaStyle(context)
                    : Theme.of(context).textTheme.bodySmall,
          ),
          child: _buildBotPicker(context, desktop: desktop),
        ),
        if (widget.viewModel.error case final error?) ...[
          const SizedBox(height: 16),
          HyveInlineErrorAlert(
            key: const ValueKey<String>('new-project-error'),
            error: S
                .of(context)
                .createProjectFailed(safeFailureMessage(context, error)),
            isDesktop: desktop,
            onDismiss: widget.viewModel.clearError,
          ),
        ],
      ],
    );
  }

  Widget _buildBotPicker(BuildContext context, {required bool desktop}) {
    final bots = widget.viewModel.bots;
    if (bots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(child: Text(S.of(context).noBotsAvailable)),
      );
    }
    return Column(
      children: [
        for (var index = 0; index < bots.length; index++) ...[
          _ProjectBotChoice(
            bot: bots[index],
            desktop: desktop,
            selected: widget.viewModel.selectedBotIds.contains(bots[index].id),
            enabled: !widget.viewModel.isSaving,
            onChanged: () => widget.viewModel.toggleBot(bots[index].id),
          ),
          if (index != bots.length - 1) const SizedBox(height: 6),
        ],
      ],
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
                        enabled: !widget.viewModel.isSaving,
                        onPressed:
                            widget.viewModel.isSaving
                                ? null
                                : () => Navigator.of(context).pop(),
                        child: Text(S.of(context).cancel),
                      ),
                      const SizedBox(width: 8),
                      ShadButton(
                        key: const ValueKey<String>('create-project-submit'),
                        enabled: !widget.viewModel.isSaving,
                        onPressed: widget.viewModel.isSaving ? null : _submit,
                        leading:
                            widget.viewModel.isSaving
                                ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(LucideIcons.plus, size: 17),
                        child: Text(S.of(context).createProject),
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

  Future<void> _submit() async {
    if (isDesktopPlatform(context)) {
      _desktopFormKey.currentState?.saveAndValidate();
    }
    final result = await widget.viewModel.submit();
    if (!mounted || result == null) return;
    Navigator.of(context).pop(result);
  }
}
