import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:video_player/video_player.dart';

/// Renders a local generated video with platform playback controls.
class VideoPlayerWidget extends StatefulWidget {
  final String videoFilePath;
  final bool expand;

  const VideoPlayerWidget({
    super.key,
    required this.videoFilePath,
    this.expand = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final videoPlayerController = VideoPlayerController.file(
        File(widget.videoFilePath),
      );
      _videoPlayerController = videoPlayerController;

      await videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: false,
        placeholder: Container(color: Colors.black),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              S.of(context).videoPlaybackError(errorMessage),
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _sizedPlayer(
        context,
        child: Center(
          child: Text(
            S.of(context).videoLoadFailed,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return _sizedPlayer(
        context,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return _sizedPlayer(context, child: Chewie(controller: _chewieController!));
  }

  Widget _sizedPlayer(BuildContext context, {required Widget child}) {
    final player = ColoredBox(
      color: Theme.of(context).colorScheme.secondary,
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
    );
    if (widget.expand) {
      return SizedBox.expand(child: player);
    }
    return Container(
      width: double.infinity,
      height: _hasError ? 50 : 200,
      margin: const EdgeInsets.only(top: 8),
      child: player,
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
