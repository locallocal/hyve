part of 'chat.dart';

extension ChatPageSessionCommands on ChatPageState {
  Future<void> _cancelRequest() async {
    if (!_isCancellable) return;
    _updateState(() => _isStopping = true);
    final cancelled = await _chatViewModel.stopActiveRun();
    if (!mounted) return;
    if (cancelled) {
      showHyveNotice(context, S.of(context).replyCancelled);
    }
  }

  Future<bool> stopActiveRunForNavigation() => _chatViewModel.stopActiveRun();

  void _beginMediaRun(String _) {
    _updateState(() {
      _isTyping = true;
      _isCancellable = true;
      _isStopping = false;
    });
  }

  void _finishMediaRun(String _) {
    if (!mounted) return;
    _updateState(() {
      _isTyping = false;
      _isCancellable = false;
      _isStopping = false;
    });
  }
}
