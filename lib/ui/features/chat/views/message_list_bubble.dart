part of 'message_list.dart';

class _MessageBubble extends StatelessWidget {
  final bool isCurrentUser;
  final bool isDesktop;
  final bool isStreaming;
  final String reasoning;
  final MessageProcessInfo processInfo;
  final ModelTokenUsage tokenUsage;
  final bool showExecutionStatus;
  final String content;
  final List<String> images;
  final List<String> files;
  final String audio;
  final String music;
  final String video;
  final MessageTerminalOutcome? terminalOutcome;
  final bool hasPartialContent;
  final MessageActionViewModel? actionViewModel;

  const _MessageBubble({
    required this.isCurrentUser,
    required this.isDesktop,
    this.isStreaming = false,
    required this.reasoning,
    this.processInfo = const MessageProcessInfo(),
    this.tokenUsage = ModelTokenUsage.empty,
    this.showExecutionStatus = true,
    required this.content,
    this.images = const [],
    this.files = const [],
    this.audio = '',
    this.music = '',
    this.video = '',
    this.terminalOutcome,
    this.hasPartialContent = false,
    this.actionViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.bodyLarge?.fontSize ?? 14;
    final useBubbleShell = !isDesktop || isCurrentUser;
    final backgroundColor =
        isCurrentUser
            ? StarsDesktopTheme.userBubble(context)
            : StarsDesktopTheme.assistantBubble(context);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reasoning.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              bottom:
                  content.isNotEmpty ||
                          _showProcessInfo ||
                          _hasStructuredMedia ||
                          _showTerminalStatus
                      ? 14
                      : 0,
            ),
            child: ReasoningSection(
              reasoning: reasoning,
              isDesktop: isDesktop,
              isStreaming: isStreaming,
              durationMs: processInfo.durationMs,
              actionViewModel: actionViewModel,
            ),
          ),
        if (content.isNotEmpty)
          MarkdownBody(
            data: content,
            selectable: true,
            builders:
                isCurrentUser
                    ? const <String, MarkdownElementBuilder>{}
                    : <String, MarkdownElementBuilder>{
                      'pre': _CopyableCodeBlockBuilder(
                        isDesktop: isDesktop,
                        textStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'monospace',
                          fontSize: fontSize - 1,
                          height: 1.55,
                        ),
                      ),
                    },
            onTapLink:
                (text, href, title) => unawaited(
                  _openMarkdownLink(context, href, actionViewModel),
                ),
            styleSheet: _buildMarkdownStyleSheet(context, fontSize),
          ),
        if (_showsProcessInfoBeforeMedia)
          Padding(
            padding: EdgeInsets.only(top: content.isNotEmpty ? 14 : 0),
            child: ProcessInfoSection(
              processInfo: processInfo,
              tokenUsage: tokenUsage,
              isDesktop: isDesktop,
              isStreaming: isStreaming,
              hasReasoningContent: reasoning.isNotEmpty,
            ),
          ),
        if (images.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: content.isNotEmpty || _showsProcessInfoBeforeMedia ? 14 : 0,
            ),
            child: _StatusCardSection(
              isDesktop: isDesktop,
              icon: isDesktop ? LucideIcons.image : Icons.image_outlined,
              title:
                  isCurrentUser
                      ? S.of(context).imageAttachment
                      : S.of(context).imageResult,
              subtitle: S.of(context).itemCount(images.length.toString()),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    images
                        .map(
                          (imagePath) => _buildImagePreview(context, imagePath),
                        )
                        .toList(),
              ),
            ),
          ),
        if (files.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top:
                  content.isNotEmpty ||
                          _showsProcessInfoBeforeMedia ||
                          images.isNotEmpty
                      ? 12
                      : 0,
            ),
            child: _StatusCardSection(
              isDesktop: isDesktop,
              icon:
                  isDesktop ? LucideIcons.paperclip : Icons.attach_file_rounded,
              title:
                  isCurrentUser
                      ? S.of(context).fileAttachment
                      : S.of(context).fileResult,
              subtitle: S.of(context).fileCount(files.length.toString()),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    files
                        .map(
                          (filePath) => _buildFilePreview(
                            context,
                            filePath,
                            isCurrentUser,
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        if (audio.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: _hasMediaAbove ? 12 : 0),
            child: _StatusCardSection(
              isDesktop: isDesktop,
              icon:
                  isDesktop ? LucideIcons.audioLines : Icons.graphic_eq_rounded,
              title: S.of(context).speechResult,
              subtitle: S.of(context).directPlayback,
              child: AudioPlayerWidget(audioFilePath: audio),
            ),
          ),
        if (music.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: _hasMediaAbove || audio.isNotEmpty ? 12 : 0,
            ),
            child: _StatusCardSection(
              isDesktop: isDesktop,
              icon: isDesktop ? LucideIcons.music : Icons.music_note_rounded,
              title: S.of(context).musicResult,
              subtitle: S.of(context).directPlayback,
              child: AudioPlayerWidget(audioFilePath: music),
            ),
          ),
        if (video.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top:
                  _hasMediaAbove || audio.isNotEmpty || music.isNotEmpty
                      ? 12
                      : 0,
            ),
            child: _StatusCardSection(
              isDesktop: isDesktop,
              icon:
                  isDesktop
                      ? LucideIcons.video
                      : Icons.video_camera_back_outlined,
              title: S.of(context).videoResult,
              subtitle: S.of(context).directPreview,
              child: VideoPlayerWidget(videoFilePath: video),
            ),
          ),
        if (_showTerminalStatus)
          Padding(
            padding: EdgeInsets.only(
              top:
                  content.isNotEmpty ||
                          _hasStructuredMedia ||
                          _showsProcessInfoBeforeMedia
                      ? 10
                      : 0,
            ),
            child: _MessageTerminalStatus(
              outcome: terminalOutcome!,
              hasPartialContent: hasPartialContent,
            ),
          ),
        if (_showsProcessInfoAfterMessage)
          Padding(
            padding: EdgeInsets.only(
              top:
                  content.isNotEmpty ||
                          _hasStructuredMedia ||
                          _showTerminalStatus
                      ? 14
                      : 0,
            ),
            child: ProcessInfoSection(
              processInfo: processInfo,
              tokenUsage: tokenUsage,
              isDesktop: isDesktop,
              isStreaming: isStreaming,
              hasReasoningContent: reasoning.isNotEmpty,
            ),
          ),
      ],
    );

    if (!useBubbleShell) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 8),
        child: body,
      );
    }

    if (isDesktop) {
      return Padding(
        padding: EdgeInsets.zero,
        child: ShadCard(
          padding: const EdgeInsets.all(16),
          backgroundColor: backgroundColor,
          radius: BorderRadius.circular(StarsDesktopTheme.bubbleRadius),
          border: ShadBorder.all(color: StarsDesktopTheme.borderColor(context)),
          child: body,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: body,
    );
  }

  bool get _hasMediaAbove =>
      content.isNotEmpty ||
      _showsProcessInfoBeforeMedia ||
      images.isNotEmpty ||
      files.isNotEmpty;

  bool get _showProcessInfo =>
      showExecutionStatus &&
      (processInfo.hasData ||
          tokenUsage.inputTokens > 0 ||
          tokenUsage.outputTokens > 0);

  bool get _showsProcessInfoBeforeMedia => _showProcessInfo && !isDesktop;

  bool get _showsProcessInfoAfterMessage => _showProcessInfo && isDesktop;

  bool get _showTerminalStatus =>
      terminalOutcome != null &&
      (terminalOutcome != MessageTerminalOutcome.completed ||
          hasPartialContent);

  bool get _hasStructuredMedia =>
      images.isNotEmpty ||
      files.isNotEmpty ||
      audio.isNotEmpty ||
      music.isNotEmpty ||
      video.isNotEmpty;

  Widget _buildImagePreview(BuildContext context, String imagePath) {
    return GestureDetector(
      key: ValueKey<String>('message-image-preview-$imagePath'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _showImageDialog(context, imagePath, actionViewModel);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 96,
            minHeight: 96,
            maxWidth: isDesktop ? 220 : 150,
            maxHeight: isDesktop ? 240 : 200,
          ),
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 96,
                height: 96,
                color: StarsDesktopTheme.elevatedSurface(context),
                child: Center(
                  child: Icon(
                    isDesktop ? LucideIcons.imageOff : Icons.broken_image,
                    color: StarsDesktopTheme.mutedText(context),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(
    BuildContext context,
    String filePath,
    bool isCurrentUser,
  ) {
    final fileName = filePath.split(Platform.pathSeparator).last;

    return Container(
      width: isDesktop ? 220 : 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isCurrentUser
                ? Colors.white.withValues(alpha: 0.28)
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 14),
        border: Border.all(color: StarsDesktopTheme.borderColor(context)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDesktop ? LucideIcons.file : Icons.insert_drive_file_rounded,
            size: 24,
            color: StarsDesktopTheme.mutedText(context),
          ),
          const SizedBox(height: 8),
          Text(
            fileName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(
    BuildContext context,
    double fontSize,
  ) {
    return MarkdownStyleSheet(
      p: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: fontSize,
        height: 1.55,
      ),
      code: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        backgroundColor: StarsDesktopTheme.elevatedSurface(context),
        fontFamily: 'monospace',
        fontSize: fontSize - 1,
      ),
      a: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: Theme.of(context).colorScheme.primary,
      ),
      h1: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: fontSize + 6,
        fontWeight: FontWeight.w700,
      ),
      h2: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: fontSize + 3,
        fontWeight: FontWeight.w700,
      ),
      h3: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: fontSize + 1,
        fontWeight: FontWeight.w600,
      ),
      blockquote: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        fontStyle: FontStyle.italic,
      ),
      codeblockDecoration: BoxDecoration(
        color: StarsDesktopTheme.elevatedSurface(context),
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 14),
        border: Border.all(color: StarsDesktopTheme.borderColor(context)),
      ),
      blockSpacing: 10,
      listBullet: TextStyle(
        color: StarsDesktopTheme.mutedText(context),
        fontSize: fontSize,
      ),
    );
  }
}

class _MessageTerminalStatus extends StatelessWidget {
  const _MessageTerminalStatus({
    required this.outcome,
    required this.hasPartialContent,
  });

  final MessageTerminalOutcome outcome;
  final bool hasPartialContent;

  @override
  Widget build(BuildContext context) {
    final (icon, label, variant) = switch (outcome) {
      MessageTerminalOutcome.cancelled => (
        LucideIcons.square,
        hasPartialContent
            ? S.of(context).replyStoppedPartial
            : S.of(context).replyCancelled,
        ShadBadgeVariant.outline,
      ),
      MessageTerminalOutcome.failed => (
        LucideIcons.triangleAlert,
        hasPartialContent
            ? S.of(context).generationFailedPartial
            : S.of(context).generationFailed,
        ShadBadgeVariant.destructive,
      ),
      MessageTerminalOutcome.emptyResponse => (
        LucideIcons.circleSlash,
        S.of(context).noContentReturned,
        ShadBadgeVariant.outline,
      ),
      MessageTerminalOutcome.completed => (
        LucideIcons.check,
        hasPartialContent
            ? S.of(context).partialResponse
            : S.of(context).statusCompleted,
        ShadBadgeVariant.secondary,
      ),
    };

    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: ShadBadge.raw(
          variant: variant,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14),
              const SizedBox(width: 6),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCardSection extends StatelessWidget {
  final bool isDesktop;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? subtitleContent;
  final Widget? child;

  const _StatusCardSection({
    required this.isDesktop,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleContent,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final radius = isDesktop ? StarsDesktopTheme.cardRadius : 14.0;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusCardHeader(
          isDesktop: isDesktop,
          icon: icon,
          title: title,
          subtitle: subtitle,
          subtitleContent: subtitleContent,
        ),
        if (child != null) ...[const SizedBox(height: 12), child!],
      ],
    );

    if (isDesktop) {
      return ShadCard(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        backgroundColor: StarsDesktopTheme.statusCardBackground(context),
        radius: BorderRadius.circular(radius),
        border: ShadBorder.all(color: StarsDesktopTheme.borderColor(context)),
        child: content,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StarsDesktopTheme.statusCardBackground(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: StarsDesktopTheme.borderColor(context)),
      ),
      child: content,
    );
  }
}

class _StatusCardHeader extends StatelessWidget {
  final bool isDesktop;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? subtitleContent;

  const _StatusCardHeader({
    required this.isDesktop,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleContent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(isDesktop ? 6 : 10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize:
                      (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 14) -
                      1,
                ),
              ),
              const SizedBox(height: 2),
              subtitleContent ??
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: StarsDesktopTheme.mutedText(context),
                      fontSize:
                          (Theme.of(context).textTheme.bodyMedium?.fontSize ??
                              12) -
                          1,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showImageDialog(
  BuildContext context,
  String imagePath,
  MessageActionViewModel? actions,
) {
  final isDesktop = isDesktopPlatform(context);

  Future<void> saveImage(BuildContext dialogContext) async {
    final strings = S.of(dialogContext);
    try {
      final result = await actions?.saveImage(
        sourcePath: imagePath,
        dialogTitle: strings.saveImage,
      );
      if (result != MediaExportResult.saved || !dialogContext.mounted) return;
      showDialog<void>(
        context: dialogContext,
        barrierColor: Colors.transparent,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.black.withValues(alpha: 0.7),
              content: Text(
                strings.imageSavedToGallery,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
      );
      Future<void>.delayed(const Duration(milliseconds: 1500), () {
        if (dialogContext.mounted) Navigator.of(dialogContext).pop();
      });
    } catch (error) {
      if (dialogContext.mounted) {
        showSnackBar(
          dialogContext,
          strings.saveImageFailed(safeFailureMessage(dialogContext, error)),
        );
      }
    }
  }

  Future<void> shareImage(BuildContext dialogContext) async {
    try {
      await actions?.shareImage(
        sourcePath: imagePath,
        text: S.of(dialogContext).sharedImageFromStars,
      );
    } catch (error) {
      if (dialogContext.mounted) {
        showSnackBar(
          dialogContext,
          S
              .of(dialogContext)
              .shareImageFailed(safeFailureMessage(dialogContext, error)),
        );
      }
    }
  }

  Widget actionButton({
    required BuildContext dialogContext,
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    if (!isDesktop) {
      return FloatingActionButton(
        mini: true,
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        onPressed: onPressed,
        tooltip: tooltip,
        child: Icon(icon, color: Colors.white),
      );
    }

    return StarsDesktopIconAction(
      icon: icon,
      label: tooltip,
      variant: ShadButtonVariant.secondary,
      onPressed: onPressed,
    );
  }

  Widget preview(BuildContext dialogContext) {
    return Stack(
      key: const ValueKey<String>('message-image-dialog-preview'),
      children: [
        if (isDesktop)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ),
          )
        else
          Image.file(File(imagePath), fit: BoxFit.contain),
        Positioned(
          right: 12,
          bottom: 12,
          child: Row(
            children: [
              actionButton(
                dialogContext: dialogContext,
                tooltip: S.of(dialogContext).saveImage,
                icon: isDesktop ? LucideIcons.download : Icons.save_alt_rounded,
                onPressed: () => saveImage(dialogContext),
              ),
              const SizedBox(width: 8),
              actionButton(
                dialogContext: dialogContext,
                tooltip: S.of(dialogContext).shareImage,
                icon: isDesktop ? LucideIcons.share2 : Icons.share_rounded,
                onPressed: () => shareImage(dialogContext),
              ),
              const SizedBox(width: 8),
              actionButton(
                dialogContext: dialogContext,
                tooltip:
                    MaterialLocalizations.of(dialogContext).closeButtonTooltip,
                icon: isDesktop ? LucideIcons.x : Icons.close_rounded,
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  if (isDesktop) {
    final windowSize = MediaQuery.sizeOf(context);
    final width = (windowSize.width - 32).clamp(0.0, 960.0).toDouble();
    final height = (windowSize.height - 32).clamp(0.0, 720.0).toDouble();
    showChatShadDialog<void>(
      context: context,
      builder:
          (dialogContext) => ShadDialog(
            key: const ValueKey<String>('message-image-dialog'),
            constraints: BoxConstraints.tightFor(width: width, height: height),
            scrollable: false,
            padding: EdgeInsets.zero,
            gap: 0,
            closeIcon: const SizedBox.shrink(),
            child: preview(dialogContext),
          ),
    );
    return;
  }

  showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(child: preview(dialogContext)),
  );
}
