part of 'chat.dart';

extension ChatPageSendCommands on ChatPageState {
  // 从相机获取图片
  Future<void> getAttachImageFromCamera() async {
    final imagePath = await _chatViewModel.captureImage();
    if (imagePath != null && mounted) {
      _updateState(() {
        _selectedImages.add(File(imagePath));
      });
      unawaited(_persistDraft());
    }
  }

  // 从相册获取图片
  Future<void> getAttachImageFromGallery() async {
    final imagePath = await _chatViewModel.selectImage();
    if (imagePath != null && mounted) {
      _updateState(() {
        _selectedImages.add(File(imagePath));
      });
      unawaited(_persistDraft());
    }
  }

  // 获取文件
  Future<void> getAttacheFile() async {
    final filePath = await _chatViewModel.selectFile();
    if (filePath != null && mounted) {
      _updateState(() {
        _selectedFiles.add(File(filePath));
      });
      unawaited(_persistDraft());
    }
  }

  Future<void> _sendMessage() async {
    if (_isTyping) {
      return;
    }
    if (_generationError != null) {
      _updateState(() {
        _generationError = null;
      });
    }
    final targets =
        _chatViewModel
            .resolveMentionedBots(_messageController.text, _projectBots)
            .bots;
    if (targets.isEmpty) {
      _updateState(() {
        _generationError = S.of(context).mentionAgentToSend;
      });
      return;
    }
    _chatViewModel.updateBot(targets.first);
    _showBotForRun(targets.first);
    if (targets.length == 1 &&
        _provider.getOutputModalites().contains(OutputModality.image) &&
        _selectedImageSize.isNotEmpty) {
      await _generateImage();
      return;
    } else if (targets.length == 1 &&
        _provider.getOutputModalites().contains(OutputModality.speech)) {
      await _generateSpeech();
      return;
    } else if (targets.length == 1 &&
        _provider.getOutputModalites().contains(OutputModality.music)) {
      await _generateMusic();
      return;
    } else if (targets.length == 1 &&
        _provider.getOutputModalites().contains(OutputModality.video)) {
      await _generateVideo();
      return;
    }
    await _generateText(targets);
  }

  Future<void> _generateText(List<Bot> targets) async {
    final bool hasText = _messageController.text.trim().isNotEmpty;
    final bool hasImages = _selectedImages.isNotEmpty;
    final bool hasFiles = _selectedFiles.isNotEmpty;
    if (!hasText && !hasImages && !hasFiles) return;

    final messageText = _messageController.text;
    final imageAttachmentDetail = S.of(context).imageAttachment;
    final fileAttachmentDetail = S.of(context).fileAttachment;
    final history = List<Message>.of(_messages);
    _pendingDraftText = messageText;
    _pendingDraftImages = List<File>.of(_selectedImages);
    _pendingDraftFiles = List<File>.of(_selectedFiles);
    await _persistDraft();
    String? optimisticMessageId;
    var userPersisted = false;
    try {
      final (imagePaths, filePaths) = await _persistSelectedAttachments();

      final userMessage = _chatViewModel.createUserMessage(
        currentUserId: _currentUserId,
        targetBotIds: targets.map((bot) => bot.id),
        content: messageText,
        imagePaths: imagePaths,
        filePaths: filePaths,
        imageDetail: imageAttachmentDetail,
        fileDetail: fileAttachmentDetail,
      );
      optimisticMessageId = userMessage.messageId;
      await _chatViewModel.upsertMessage(userMessage);
      await _chatViewModel.updateLastMessage(userMessage.content);
      userPersisted = true;

      if (mounted) {
        _updateState(() {
          _messages.add(userMessage);
          _messageRevision += 1;
          _messageController.clear();
          _generationError = null;
          _streamingResponse = '';
          _selectedImages.clear();
          _selectedFiles.clear();
          _followLatest = true;
          _showJumpToLatest = false;
        });
        _scheduleScrollToLatest(force: true, animate: true);
      }
      _clearPendingDraft();

      await _chatViewModel.generateMentionedReplies(
        userMessage: userMessage,
        targets: targets,
        history: history,
        currentUserId: _currentUserId,
        restoreBot: widget.bot,
        onBotStarted: (bot) {
          if (mounted) _showBotForRun(bot);
        },
      );
    } catch (error) {
      if (mounted) {
        _updateState(() {
          if (!userPersisted && optimisticMessageId != null) {
            final previousLength = _messages.length;
            _messages.removeWhere(
              (message) => message.messageId == optimisticMessageId,
            );
            if (_messages.length != previousLength) _messageRevision += 1;
          }
          if (!userPersisted) _restorePendingDraft();
          _generationError = safeFailureMessage(context, error);
        });
      }
    } finally {
      if (mounted && !_generationViewModel.snapshot.lifecycle.isRunning) {
        _updateState(() {
          _isTyping = false;
          _isCancellable = false;
          _isStopping = false;
        });
      }
    }
  }
}
