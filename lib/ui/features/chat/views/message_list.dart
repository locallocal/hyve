import 'dart:async';
import 'dart:io';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/core/widgets/common.dart';
import 'package:stars/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:stars/ui/features/chat/views/audio_player_widget.dart';
import 'package:stars/ui/features/chat/views/video_player_widget.dart';
import 'package:stars/utils/theme.dart';
import 'package:stars/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageList extends StatelessWidget {
  final List<Message> messages;
  final ScrollController scrollController;
  final bool isStreaming;
  final String streamingResponse;
  final MessageProcessInfo streamingProcessInfo;
  final ModelTokenUsage streamingTokenUsage;
  final String currentUserId;
  final bool? deepThinking;
  final String? reasoningResponse;
  final bool isDesktop;
  final bool showExecutionStatus;

  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.isStreaming,
    required this.streamingResponse,
    this.streamingProcessInfo = const MessageProcessInfo(),
    this.streamingTokenUsage = ModelTokenUsage.empty,
    required this.currentUserId,
    this.deepThinking = false,
    this.reasoningResponse = '',
    this.isDesktop = false,
    this.showExecutionStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayedProcessInfo = <MessageProcessInfo>[
      for (final message in messages) message.processInfo,
    ];
    var streamingSkillActivations = const <MessageSkillActivation>[];

    if (isDesktop) {
      Message? pendingUserMessage;
      var pendingSkillActivations = const <MessageSkillActivation>[];

      for (var index = 0; index < messages.length; index++) {
        final message = messages[index];
        final isCurrentUser = message.senderId == currentUserId;

        if (isCurrentUser) {
          pendingUserMessage = message;
          pendingSkillActivations = message.processInfo.skillActivations;
          displayedProcessInfo[index] = _replaceSkillActivations(
            message.processInfo,
            const [],
          );
          continue;
        }

        if (pendingUserMessage != null &&
            _messagesBelongToSameTurn(pendingUserMessage, message)) {
          displayedProcessInfo[index] = _replaceSkillActivations(
            message.processInfo,
            _mergeSkillActivations(
              message.processInfo.skillActivations,
              pendingSkillActivations,
            ),
          );
          pendingUserMessage = null;
          pendingSkillActivations = const [];
        }
      }

      streamingSkillActivations = pendingSkillActivations;
    }

    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length + (isStreaming ? 1 : 0),
        padding: EdgeInsets.fromLTRB(
          0,
          isDesktop ? 12 : 8,
          0,
          isDesktop ? 36 : 8,
        ),
        itemBuilder: (context, index) {
          if (isStreaming && index == messages.length) {
            return RepaintBoundary(
              key: const ValueKey<String>('streaming-message'),
              child: _buildMessageRow(
                context,
                bubble: _MessageBubble(
                  isCurrentUser: false,
                  isDesktop: isDesktop,
                  isStreaming: true,
                  reasoning:
                      deepThinking == true ? reasoningResponse ?? '' : '',
                  processInfo:
                      isDesktop
                          ? _replaceSkillActivations(
                            streamingProcessInfo,
                            _mergeSkillActivations(
                              streamingProcessInfo.skillActivations,
                              streamingSkillActivations,
                            ),
                          )
                          : streamingProcessInfo,
                  tokenUsage: streamingTokenUsage,
                  showExecutionStatus: showExecutionStatus,
                  content: streamingResponse,
                ),
              ),
            );
          }

          final message = messages[index];
          final isMe = message.senderId == currentUserId;
          final bubble = _MessageBubble(
            isCurrentUser: isMe,
            isDesktop: isDesktop,
            reasoning: message.reasoning,
            processInfo: displayedProcessInfo[index],
            tokenUsage: message.tokenUsage,
            showExecutionStatus: showExecutionStatus,
            content: message.content,
            images: message.images,
            files: message.files,
            audio: message.audio,
            music: message.music,
            video: message.video,
            terminalOutcome: message.terminalOutcome,
            hasPartialContent: message.hasPartialContent,
          );
          return RepaintBoundary(
            key: ValueKey<String>(
              message.messageId.isEmpty
                  ? 'legacy-${message.timestamp.microsecondsSinceEpoch}-$index'
                  : message.messageId,
            ),
            child: _buildMessageRow(
              context,
              isCurrentUser: isMe,
              bubble:
                  isDesktop
                      ? _DesktopMessageActions(
                        content: message.content,
                        isCurrentUser: isMe,
                        child: bubble,
                      )
                      : GestureDetector(
                        onLongPress:
                            message.content.isEmpty
                                ? null
                                : () {
                                  Clipboard.setData(
                                    ClipboardData(text: message.content),
                                  );
                                },
                        child: bubble,
                      ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageRow(
    BuildContext context, {
    required Widget bubble,
    bool isCurrentUser = false,
  }) {
    final viewportMaxWidth =
        isDesktop ? StarsDesktopTheme.contentMaxWidth : double.infinity;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 10 : 4),
      child: Center(
        child: ConstrainedBox(
          key:
              isDesktop
                  ? const ValueKey<String>('desktop-message-viewport')
                  : null,
          constraints: BoxConstraints(maxWidth: viewportMaxWidth),
          child: Align(
            alignment:
                isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    isDesktop
                        ? (isCurrentUser
                            ? StarsDesktopTheme.messageBubbleMaxWidth
                            : StarsDesktopTheme.contentMaxWidth)
                        : MediaQuery.of(context).size.width * 0.8,
              ),
              child: bubble,
            ),
          ),
        ),
      ),
    );
  }
}

MessageProcessInfo _replaceSkillActivations(
  MessageProcessInfo processInfo,
  List<MessageSkillActivation> skillActivations,
) {
  if (identical(processInfo.skillActivations, skillActivations)) {
    return processInfo;
  }
  return MessageProcessInfo(
    reasoningStatus: processInfo.reasoningStatus,
    durationMs: processInfo.durationMs,
    toolCalls: processInfo.toolCalls,
    commandExecutions: processInfo.commandExecutions,
    fileEdits: processInfo.fileEdits,
    skillActivations: skillActivations,
  );
}

List<MessageSkillActivation> _mergeSkillActivations(
  List<MessageSkillActivation> responseActivations,
  List<MessageSkillActivation> userActivations,
) {
  if (userActivations.isEmpty) return responseActivations;
  if (responseActivations.isEmpty) return userActivations;

  final merged = <MessageSkillActivation>[...responseActivations];
  for (final activation in userActivations) {
    final alreadyIncluded = merged.any(
      (item) =>
          item.name == activation.name &&
          item.contentDigest == activation.contentDigest &&
          item.trigger == activation.trigger,
    );
    if (!alreadyIncluded) merged.add(activation);
  }
  return List<MessageSkillActivation>.unmodifiable(merged);
}

bool _messagesBelongToSameTurn(Message userMessage, Message responseMessage) {
  if (userMessage.turnId.isNotEmpty && responseMessage.turnId.isNotEmpty) {
    return userMessage.turnId == responseMessage.turnId;
  }
  if (userMessage.runId.isNotEmpty && responseMessage.runId.isNotEmpty) {
    return userMessage.runId == responseMessage.runId;
  }
  return true;
}

class _DesktopMessageActions extends StatefulWidget {
  const _DesktopMessageActions({
    required this.content,
    required this.isCurrentUser,
    required this.child,
  });

  final String content;
  final bool isCurrentUser;
  final Widget child;

  @override
  State<_DesktopMessageActions> createState() => _DesktopMessageActionsState();
}

class _DesktopMessageActionsState extends State<_DesktopMessageActions> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'desktop-message');
  bool _hovered = false;

  bool get _canCopy => widget.content.isNotEmpty;
  bool get _showActions => _canCopy && (_hovered || _focusNode.hasFocus);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _copyMessage() async {
    if (!_canCopy) return;
    await Clipboard.setData(ClipboardData(text: widget.content));
    if (!mounted) return;
    ShadSonner.maybeOf(context)?.show(
      ShadToast(
        title: Text(S.of(context).messageCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copyLabel = MaterialLocalizations.of(context).copyButtonLabel;
    final actions = <Widget>[
      ShadContextMenuItem(
        leading: const Icon(LucideIcons.copy, size: 16),
        onPressed: _copyMessage,
        child: Text(copyLabel),
      ),
    ];

    return StarsContextMenu(
      focusNode: _focusNode,
      enabled: _canCopy,
      items: actions,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Column(
          crossAxisAlignment:
              widget.isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.child,
            if (_canCopy)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AnimatedOpacity(
                  opacity: _showActions ? 1 : 0,
                  duration:
                      MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 100),
                  child: ExcludeFocus(
                    excluding: !_showActions,
                    child: IgnorePointer(
                      ignoring: !_showActions,
                      child: StarsDesktopIconAction(
                        key: const ValueKey<String>(
                          'desktop-message-copy-action',
                        ),
                        icon: LucideIcons.copy,
                        label: copyLabel,
                        onPressed: _copyMessage,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
            ),
          ),
        if (content.isNotEmpty)
          MarkdownBody(
            data: content,
            selectable: true,
            onTapLink:
                (text, href, title) =>
                    unawaited(_openMarkdownLink(context, href)),
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
      onTap: () {
        _showImageDialog(context, imagePath);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
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

void _showImageDialog(BuildContext context, String imagePath) {
  final isDesktop = isDesktopPlatform(context);

  Future<void> saveImage(BuildContext dialogContext) async {
    final strings = S.of(dialogContext);
    try {
      final file = File(imagePath);
      final fileName = imagePath.split(Platform.pathSeparator).last;

      if (Platform.isAndroid || Platform.isIOS) {
        final result = await GallerySaver.saveImage(
          imagePath,
          albumName: 'Stars',
        );
        if (result != true) {
          throw Exception(strings.saveToGalleryFailed);
        }
        if (!dialogContext.mounted) return;
        showDialog<void>(
          context: dialogContext,
          barrierColor: Colors.transparent,
          builder:
              (context) => AlertDialog(
                backgroundColor: Colors.black.withValues(alpha: 0.7),
                content: Text(
                  strings.imageSavedToGallery,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
        );
        Future<void>.delayed(const Duration(milliseconds: 1500), () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });
        return;
      }

      final result = await FilePicker.platform.saveFile(
        dialogTitle: strings.saveImage,
        fileName: fileName,
        type: FileType.image,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );
      if (result != null) {
        await file.copy(result);
      }
    } catch (error) {
      if (dialogContext.mounted) {
        showSnackBar(dialogContext, strings.saveImageFailed(error.toString()));
      }
    }
  }

  Future<void> shareImage(BuildContext dialogContext) async {
    try {
      await Share.shareXFiles([
        XFile(imagePath),
      ], text: S.of(dialogContext).sharedImageFromStars);
    } catch (error) {
      if (dialogContext.mounted) {
        showSnackBar(
          dialogContext,
          S.of(dialogContext).shareImageFailed(error.toString()),
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
            constraints: BoxConstraints.tightFor(width: width, height: height),
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

class ReasoningSection extends StatefulWidget {
  final String reasoning;
  final bool isDesktop;
  final bool isStreaming;
  final int? durationMs;

  const ReasoningSection({
    super.key,
    required this.reasoning,
    this.isDesktop = false,
    this.isStreaming = false,
    this.durationMs,
  });

  @override
  State<ReasoningSection> createState() => _ReasoningSectionState();
}

class ProcessInfoSection extends StatefulWidget {
  final MessageProcessInfo processInfo;
  final ModelTokenUsage tokenUsage;
  final bool isDesktop;
  final bool isStreaming;
  final bool hasReasoningContent;

  const ProcessInfoSection({
    super.key,
    required this.processInfo,
    this.tokenUsage = ModelTokenUsage.empty,
    this.isDesktop = false,
    this.isStreaming = false,
    this.hasReasoningContent = false,
  });

  static const desktopDetailsMaxHeight = 320.0;

  @override
  State<ProcessInfoSection> createState() => _ProcessInfoSectionState();
}

class _ProcessInfoSectionState extends State<ProcessInfoSection> {
  static const _itemValue = 'execution-status';

  late final ShadAccordionController<String> _desktopController;
  late final ScrollController _detailsScrollController;

  @override
  void initState() {
    super.initState();
    _desktopController = ShadAccordionController<String>(
      widget.isDesktop && widget.isStreaming ? _itemValue : null,
    );
    _detailsScrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant ProcessInfoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isDesktop || oldWidget.isStreaming == widget.isStreaming) {
      return;
    }
    final isOpen = _desktopController.value.contains(_itemValue);
    if (widget.isStreaming != isOpen) {
      _desktopController.toggle(_itemValue);
    }
  }

  @override
  void dispose() {
    _desktopController.dispose();
    _detailsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final headerMetrics = <Widget>[];
    final summaryChips = <Widget>[];

    if (!widget.hasReasoningContent &&
        widget.processInfo.reasoningStatus.isNotEmpty) {
      summaryChips.add(
        _ProcessChip(
          icon: LucideIcons.brain,
          label: _reasoningStatusLabel(
            strings,
            widget.processInfo.reasoningStatus,
          ),
        ),
      );
    }

    if (widget.processInfo.durationMs != null) {
      headerMetrics.add(
        _ProcessHeaderMetric(
          icon: LucideIcons.clock3,
          label: strings.processDuration(
            _formatDuration(widget.processInfo.durationMs!),
          ),
        ),
      );
    }

    if (widget.tokenUsage.inputTokens > 0 ||
        widget.tokenUsage.outputTokens > 0) {
      headerMetrics
        ..add(
          _ProcessHeaderMetric(
            icon: Icons.login_rounded,
            label: '${strings.inputTokens} ${widget.tokenUsage.inputTokens}',
          ),
        )
        ..add(
          _ProcessHeaderMetric(
            icon: Icons.logout_rounded,
            label: '${strings.outputTokens} ${widget.tokenUsage.outputTokens}',
          ),
        );
    }

    if (widget.processInfo.toolCalls.isNotEmpty) {
      summaryChips.add(
        _ProcessChip(
          icon: LucideIcons.wrench,
          label: strings.processToolCount(
            widget.processInfo.toolCalls.length.toString(),
          ),
        ),
      );
    }

    final mcpToolCallCount =
        widget.processInfo.toolCalls
            .where((call) => call.source == ToolSource.mcp.name)
            .length;
    if (mcpToolCallCount > 0) {
      summaryChips.add(
        _ProcessChip(
          icon: LucideIcons.plug,
          label: '${strings.toolSourceMcp} $mcpToolCallCount',
        ),
      );
    }

    if (widget.processInfo.commandExecutions.isNotEmpty) {
      summaryChips.add(
        _ProcessChip(
          icon: LucideIcons.terminal,
          label: strings.processCommandCount(
            widget.processInfo.commandExecutions.length.toString(),
          ),
        ),
      );
    }

    if (widget.processInfo.fileEdits.isNotEmpty) {
      summaryChips.add(
        _ProcessChip(
          icon: LucideIcons.filePenLine,
          label: strings.processFileCount(
            widget.processInfo.fileEdits.length.toString(),
          ),
        ),
      );
    }

    if (widget.processInfo.skillActivations.isNotEmpty) {
      summaryChips.add(
        _ProcessChip(
          icon: LucideIcons.wrench,
          label:
              '${strings.messageSkills} '
              '${widget.processInfo.skillActivations.length}',
        ),
      );
    }

    final details =
        summaryChips.isEmpty &&
                widget.processInfo.toolCalls.isEmpty &&
                widget.processInfo.commandExecutions.isEmpty &&
                widget.processInfo.fileEdits.isEmpty &&
                widget.processInfo.skillActivations.isEmpty
            ? null
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (summaryChips.isNotEmpty)
                  Wrap(spacing: 8, runSpacing: 8, children: summaryChips),
                if (widget.processInfo.toolCalls.isNotEmpty) ...[
                  SizedBox(height: summaryChips.isNotEmpty ? 12 : 0),
                  _ProcessListCard<MessageToolCall>(
                    title: strings.toolCalls,
                    icon: LucideIcons.wrench,
                    items: widget.processInfo.toolCalls,
                    titleBuilder: (item) => item.name,
                    subtitleBuilder: (item) => _toolCallSubtitle(strings, item),
                    statusBuilder: (item) => item.status,
                  ),
                ],
                if (widget.processInfo.commandExecutions.isNotEmpty) ...[
                  SizedBox(height: summaryChips.isNotEmpty ? 12 : 0),
                  _ProcessListCard<MessageCommandExecution>(
                    title: strings.commandExecutions,
                    icon: LucideIcons.terminal,
                    items: widget.processInfo.commandExecutions,
                    titleBuilder: (item) => item.command,
                    subtitleBuilder:
                        (item) => _joinMeta([
                          if (item.detail.isNotEmpty)
                            _processDetailLabel(strings, item.detail),
                          if (item.durationMs != null)
                            strings.processDuration(
                              _formatDuration(item.durationMs!),
                            ),
                        ]),
                    statusBuilder: (item) => item.status,
                  ),
                ],
                if (widget.processInfo.fileEdits.isNotEmpty) ...[
                  SizedBox(height: summaryChips.isNotEmpty ? 12 : 0),
                  _ProcessListCard<MessageFileEdit>(
                    title: strings.fileStatus,
                    icon: LucideIcons.fileText,
                    items: widget.processInfo.fileEdits,
                    titleBuilder:
                        (item) => item.path.split(Platform.pathSeparator).last,
                    subtitleBuilder:
                        (item) => _joinMeta([
                          if (item.detail.isNotEmpty)
                            _processDetailLabel(strings, item.detail),
                          if (item.type.isNotEmpty)
                            _fileTypeLabel(strings, item.type),
                        ]),
                    statusBuilder: (item) => item.status,
                  ),
                ],
                if (widget.processInfo.skillActivations.isNotEmpty) ...[
                  SizedBox(height: summaryChips.isNotEmpty ? 12 : 0),
                  _ProcessListCard<MessageSkillActivation>(
                    title: strings.messageSkills,
                    icon: LucideIcons.wrench,
                    items: widget.processInfo.skillActivations,
                    titleBuilder: (item) => item.name,
                    subtitleBuilder:
                        (item) => _joinMeta([
                          _skillActivationTriggerLabel(strings, item.trigger),
                          if (item.contentDigest.isNotEmpty)
                            item.contentDigest.substring(
                              0,
                              item.contentDigest.length.clamp(0, 12),
                            ),
                        ]),
                    statusBuilder: (item) => item.status,
                  ),
                ],
              ],
            );

    final subtitleContent =
        headerMetrics.isEmpty
            ? null
            : Wrap(
              key: const ValueKey<String>('execution-header-metrics'),
              spacing: 16,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: headerMetrics,
            );

    if (!widget.isDesktop || details == null) {
      return _StatusCardSection(
        isDesktop: widget.isDesktop,
        icon:
            widget.isDesktop
                ? LucideIcons.sparkles
                : Icons.auto_awesome_motion_rounded,
        title: strings.executionStatus,
        subtitle: _buildSubtitle(strings),
        subtitleContent: subtitleContent,
        child: details,
      );
    }

    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return ShadCard(
      key: const ValueKey<String>('desktop-execution-status'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      backgroundColor: StarsDesktopTheme.statusCardBackground(context),
      radius: BorderRadius.circular(StarsDesktopTheme.cardRadius),
      border: ShadBorder.all(color: StarsDesktopTheme.borderColor(context)),
      child: ShadAccordion<String>(
        controller: _desktopController,
        maintainState: true,
        children: [
          ShadAccordionItem<String>(
            value: _itemValue,
            separator: const SizedBox.shrink(),
            padding: const EdgeInsets.symmetric(vertical: 12),
            duration:
                disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
            underlineTitleOnHover: false,
            iconData: LucideIcons.chevronDown,
            title: ListenableBuilder(
              listenable: _desktopController,
              builder:
                  (context, child) => Semantics(
                    expanded: _desktopController.value.contains(_itemValue),
                    child: child,
                  ),
              child: _StatusCardHeader(
                isDesktop: true,
                icon: LucideIcons.sparkles,
                title: strings.executionStatus,
                subtitle: _buildSubtitle(strings),
                subtitleContent: subtitleContent,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: ProcessInfoSection.desktopDetailsMaxHeight,
                ),
                child: Scrollbar(
                  controller: _detailsScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    key: const ValueKey<String>('execution-details-scroll'),
                    controller: _detailsScrollController,
                    primary: false,
                    padding: const EdgeInsets.only(right: 8),
                    child: details,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle(S strings) {
    final parts = <String>[];
    if (widget.processInfo.toolCalls.isNotEmpty) {
      parts.add(
        strings.processToolCount(
          widget.processInfo.toolCalls.length.toString(),
        ),
      );
    }
    if (widget.processInfo.commandExecutions.isNotEmpty) {
      parts.add(
        strings.processCommandCount(
          widget.processInfo.commandExecutions.length.toString(),
        ),
      );
    }
    if (widget.processInfo.fileEdits.isNotEmpty) {
      parts.add(
        strings.processFileCount(
          widget.processInfo.fileEdits.length.toString(),
        ),
      );
    }
    if (widget.processInfo.skillActivations.isNotEmpty) {
      parts.add(
        '${strings.messageSkills} '
        '${widget.processInfo.skillActivations.length}',
      );
    }
    return parts.isEmpty ? strings.structuredProcessInfo : parts.join(' · ');
  }
}

const _processMetricTextStyle = TextStyle(
  fontSize: 12,
  height: 1.2,
  fontWeight: FontWeight.w400,
  leadingDistribution: TextLeadingDistribution.even,
);

class _ProcessHeaderMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProcessHeaderMetric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = StarsDesktopTheme.mutedText(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 14,
          child: Center(child: Icon(icon, size: 14, color: color)),
        ),
        const SizedBox(width: 6),
        Text(label, style: _processMetricTextStyle.copyWith(color: color)),
      ],
    );
  }
}

class _ProcessChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProcessChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ShadBadge.outline(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 14,
            child: Center(
              child: Icon(
                icon,
                size: 14,
                color: StarsDesktopTheme.mutedText(context),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: _processMetricTextStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessListCard<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<T> items;
  final String Function(T item) titleBuilder;
  final String Function(T item) subtitleBuilder;
  final String Function(T item) statusBuilder;

  const _ProcessListCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.statusBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: StarsDesktopTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: StarsDesktopTheme.mutedText(context)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            final subtitle = subtitleBuilder(item);
            final hasSubtitle = subtitle.isNotEmpty;
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == items.length - 1 ? 0 : 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleBuilder(item),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (hasSubtitle) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: StarsDesktopTheme.mutedText(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(status: statusBuilder(item)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.isEmpty ? 'unknown' : status;
    final variant = switch (normalized) {
      'completed' ||
      'created' ||
      'attached' ||
      'succeeded' ||
      'activated' => ShadBadgeVariant.secondary,
      'failed' ||
      'error' ||
      'denied' ||
      'timedOut' => ShadBadgeVariant.destructive,
      _ => ShadBadgeVariant.outline,
    };

    return ShadBadge.raw(
      variant: variant,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Text(
        _statusLabel(S.of(context), normalized),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _statusLabel(S strings, String status) {
  switch (status) {
    case 'completed':
      return strings.statusCompleted;
    case 'created':
      return strings.statusGenerated;
    case 'attached':
      return strings.statusAttached;
    case 'streaming':
      return strings.statusInProgress;
    case 'running':
      return strings.statusRunning;
    case 'requested':
      return strings.statusRequested;
    case 'awaitingApproval':
      return strings.statusAwaitingApproval;
    case 'cancelled':
      return strings.statusCancelled;
    case 'denied':
      return strings.statusDenied;
    case 'timedOut':
      return strings.statusTimedOut;
    case 'duplicate':
      return strings.statusDuplicate;
    case 'skipped':
      return strings.statusSkipped;
    case 'activated':
      return strings.statusActivated;
    case 'unknown':
      return strings.statusUnknown;
    case 'succeeded':
      return strings.statusCompleted;
    case 'failed':
    case 'error':
      return strings.statusFailed;
    case 'recorded':
      return strings.statusRecorded;
    default:
      return strings.statusUnknown;
  }
}

String _reasoningStatusLabel(S strings, String status) {
  switch (status) {
    case 'completed':
      return strings.reasoningCompleted;
    case 'cancelled':
      return strings.reasoningInterrupted;
    case 'streaming':
      return strings.reasoningInProgress;
    default:
      return strings.processInformation;
  }
}

String _fileTypeLabel(S strings, String type) {
  switch (type) {
    case 'image':
      return strings.uploadImage;
    case 'audio':
      return strings.fileTypeSpeech;
    case 'music':
      return strings.fileTypeMusic;
    case 'video':
      return strings.fileTypeVideo;
    default:
      return strings.uploadFile;
  }
}

String _joinMeta(List<String> parts) {
  final filtered = parts.where((item) => item.isNotEmpty).toSet().toList();
  return filtered.join(' · ');
}

String _toolCallSubtitle(S strings, MessageToolCall item) => _joinMeta([
  if (item.source.isNotEmpty || item.riskLevel.isNotEmpty)
    _joinMeta([
      _toolSourceLabel(strings, item.source),
      _toolRiskLabel(strings, item.riskLevel),
    ]),
  if (item.argumentsSummary.isNotEmpty) item.argumentsSummary,
  if (item.detail.isNotEmpty) _processDetailLabel(strings, item.detail),
  if (item.resultSummary.isNotEmpty && item.errorCode.isEmpty)
    _processDetailLabel(strings, item.resultSummary),
  if (item.approvalStatus.isNotEmpty)
    _toolApprovalLabel(strings, item.approvalStatus),
  if (item.durationMs != null)
    strings.processDuration(_formatDuration(item.durationMs!)),
]);

String _toolSourceLabel(S strings, String source) {
  switch (source) {
    case 'builtIn':
      return strings.toolSourceBuiltIn;
    case 'mcp':
      return strings.toolSourceMcp;
    case 'skillScript':
      return strings.toolSourceSkillScript;
    case '':
      return '';
    default:
      return strings.statusUnknown;
  }
}

String _toolRiskLabel(S strings, String riskLevel) {
  switch (riskLevel) {
    case 'readOnly':
      return strings.toolRiskReadOnly;
    case 'write':
      return strings.toolRiskWrite;
    case 'destructive':
      return strings.toolRiskDestructive;
    case '':
      return '';
    default:
      return strings.statusUnknown;
  }
}

String _toolApprovalLabel(S strings, String approvalStatus) {
  switch (approvalStatus) {
    case 'allowOnce':
      return strings.toolApprovalAllowOnce;
    case 'deny':
      return strings.toolApprovalDenied;
    case '':
      return '';
    default:
      return strings.statusUnknown;
  }
}

String _skillActivationTriggerLabel(S strings, String trigger) {
  switch (trigger) {
    case 'model':
      return strings.autoActivation;
    case 'manual':
      return strings.manualActivation;
    case 'always':
      return strings.alwaysActivation;
    case '':
      return '';
    default:
      return strings.statusUnknown;
  }
}

String _processDetailLabel(S strings, String detail) {
  switch (detail) {
    case 'completed':
    case 'succeeded':
      return strings.statusCompleted;
    case 'created':
      return strings.statusGenerated;
    case 'attached':
      return strings.statusAttached;
    case 'streaming':
      return strings.statusInProgress;
    case 'requested':
      return strings.statusRequested;
    case 'awaitingApproval':
      return strings.statusAwaitingApproval;
    case 'running':
      return strings.statusRunning;
    case 'cancelled':
      return strings.statusCancelled;
    case 'denied':
      return strings.statusDenied;
    case 'timedOut':
      return strings.statusTimedOut;
    case 'duplicate':
      return strings.statusDuplicate;
    case 'skipped':
      return strings.statusSkipped;
    case 'activated':
      return strings.statusActivated;
    case 'recorded':
      return strings.statusRecorded;
    case 'failed':
    case 'error':
      return strings.statusFailed;
    case 'unknown':
      return strings.statusUnknown;
    case 'skill_provider_timeout':
    case 'provider_timeout':
    case 'tool_approval_timeout':
    case 'tool_execution_timeout':
    case 'Tool approval timed out.':
    case 'Tool execution timed out.':
      return strings.statusTimedOut;
    case 'tool_approval_denied':
    case 'tool_policy_denied':
    case 'tool_not_requested_by_active_skill':
    case 'process_execution_disabled':
    case 'destructive_tools_disabled':
    case 'The tool call was blocked by application policy.':
    case 'The user denied the tool call.':
      return strings.statusDenied;
    case 'agent_run_cancelled':
      return strings.statusCancelled;
    case 'duplicate_call_id_conflict':
    case 'duplicate_call_reused':
    case 'The call id was already used with different arguments.':
      return strings.statusDuplicate;
    case 'skill_provider_error':
    case 'provider_error':
    case 'invalid_candidate':
    case 'tool_retry_limit_reached':
    case 'tool_not_available':
    case 'invalid_tool_arguments':
    case 'tool_execution_failed':
    case 'invalid_tool_output':
    case 'unsupported':
    case 'The requested tool is not available for this run.':
    case 'Tool arguments failed schema validation.':
    case 'Tool execution failed.':
    case 'Tool output failed schema validation.':
      return strings.statusFailed;
  }

  final looksLikeInternalCode = RegExp(
    r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)+$',
  ).hasMatch(detail);
  return looksLikeInternalCode ? strings.statusFailed : detail;
}

String _formatDuration(int durationMs) {
  if (durationMs < 1000) {
    return '${durationMs}ms';
  }
  final seconds = durationMs / 1000;
  return '${seconds.toStringAsFixed(seconds >= 10 ? 0 : 1)}s';
}

class _ReasoningSectionState extends State<ReasoningSection>
    with SingleTickerProviderStateMixin {
  static const _itemValue = 'reasoning';

  late bool _mobileExpanded;
  late final ShadAccordionController<String> _desktopController;
  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool? _shouldRotate;

  @override
  void initState() {
    super.initState();
    _mobileExpanded = true;
    _desktopController = ShadAccordionController<String>(
      widget.isDesktop && widget.isStreaming ? _itemValue : null,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRotation();
  }

  @override
  void didUpdateWidget(covariant ReasoningSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDesktop != widget.isDesktop ||
        oldWidget.isStreaming != widget.isStreaming) {
      _updateRotation();
    }
    if (!widget.isDesktop || oldWidget.isStreaming == widget.isStreaming) {
      return;
    }
    final isOpen = _desktopController.value.contains(_itemValue);
    if (widget.isStreaming != isOpen) {
      _desktopController.toggle(_itemValue);
    }
  }

  void _updateRotation() {
    final shouldRotate =
        widget.isDesktop &&
        widget.isStreaming &&
        !MediaQuery.disableAnimationsOf(context);
    if (_shouldRotate == shouldRotate) return;
    _shouldRotate = shouldRotate;
    if (shouldRotate) {
      _rotationController.repeat();
    } else {
      _rotationController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _desktopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.bodyLarge?.fontSize ?? 14;
    final strings = S.of(context);

    if (widget.isDesktop) {
      final disableAnimations = MediaQuery.disableAnimationsOf(context);
      final title =
          widget.isStreaming
              ? strings.thinkingInProgress
              : widget.durationMs == null
              ? strings.thinkingCompleted
              : strings.thinkingCompletedWithDuration(
                _formatDuration(widget.durationMs!),
              );

      return ShadCard(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        backgroundColor: StarsDesktopTheme.statusCardBackground(context),
        radius: BorderRadius.circular(StarsDesktopTheme.cardRadius),
        border: ShadBorder.all(color: StarsDesktopTheme.borderColor(context)),
        child: ShadAccordion<String>(
          controller: _desktopController,
          maintainState: true,
          children: [
            ShadAccordionItem<String>(
              value: _itemValue,
              separator: const SizedBox.shrink(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              duration:
                  disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
              underlineTitleOnHover: false,
              iconData: LucideIcons.chevronDown,
              title: ListenableBuilder(
                listenable: _desktopController,
                builder:
                    (context, child) => Semantics(
                      expanded: _desktopController.value.contains(_itemValue),
                      child: child,
                    ),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child:
                          widget.isStreaming
                              ? RotationTransition(
                                key: const ValueKey<String>(
                                  'reasoning-streaming-spinner',
                                ),
                                turns: _rotationController,
                                child: Icon(
                                  LucideIcons.loaderCircle,
                                  size: 16,
                                  color: StarsDesktopTheme.mutedText(context),
                                ),
                              )
                              : Icon(
                                LucideIcons.brain,
                                size: 16,
                                color: StarsDesktopTheme.mutedText(context),
                              ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: fontSize - 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReasoningMarkdown(context, fontSize),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: StarsDesktopTheme.statusCardBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StarsDesktopTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _mobileExpanded = !_mobileExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.psychology_alt_rounded,
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
                          strings.processInformation,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: fontSize - 1,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          strings.deepThinking,
                          style: TextStyle(
                            fontSize: fontSize - 3,
                            color: StarsDesktopTheme.mutedText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 180),
                    turns: _mobileExpanded ? 0 : 0.5,
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: StarsDesktopTheme.mutedText(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_mobileExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildReasoningMarkdown(context, fontSize),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReasoningMarkdown(BuildContext context, double fontSize) {
    return MarkdownBody(
      data: widget.reasoning,
      selectable: true,
      onTapLink:
          (text, href, title) => unawaited(_openMarkdownLink(context, href)),
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: StarsDesktopTheme.mutedText(context),
          fontSize: fontSize - 1,
          height: 1.5,
        ),
        code: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          backgroundColor: StarsDesktopTheme.elevatedSurface(context),
          fontSize: fontSize - 2,
        ),
        a: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
          decorationColor: Theme.of(context).colorScheme.primary,
        ),
        codeblockDecoration: BoxDecoration(
          color: StarsDesktopTheme.elevatedSurface(context),
          borderRadius: BorderRadius.circular(widget.isDesktop ? 8 : 12),
          border: Border.all(color: StarsDesktopTheme.borderColor(context)),
        ),
        blockSpacing: 8,
      ),
    );
  }
}

Future<void> _openMarkdownLink(BuildContext context, String? href) async {
  if (href == null || href.trim().isEmpty) return;
  final normalized = href.trim();
  final uri = Uri.tryParse(normalized);
  final isWebLink =
      uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
  final isHandledMailLink =
      uri != null && uri.scheme == 'mailto' && await canLaunchUrl(uri);

  if (uri != null && (isWebLink || isHandledMailLink)) {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      // The same recoverable toast is used for handler and launch failures.
    }
  }
  if (!context.mounted) return;

  final sonner = ShadSonner.maybeOf(context);
  if (sonner == null) {
    showSnackBar(context, S.of(context).linkOpenFailed);
    return;
  }
  sonner.show(
    ShadToast.destructive(
      title: Text(S.of(context).linkOpenFailed),
      action: ShadButton.outline(
        size: ShadButtonSize.sm,
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: normalized));
        },
        leading: const Icon(LucideIcons.copy, size: 16),
        child: Text(MaterialLocalizations.of(context).copyButtonLabel),
      ),
    ),
  );
}
