final class ConversationDraft {
  const ConversationDraft({
    this.text = '',
    this.imagePaths = const [],
    this.filePaths = const [],
  });

  final String text;
  final List<String> imagePaths;
  final List<String> filePaths;

  bool get isEmpty => text.isEmpty && imagePaths.isEmpty && filePaths.isEmpty;
}
