abstract interface class AttachmentRepository {
  Future<String?> captureImage();

  Future<String?> selectImage();

  Future<String?> selectFile();

  Future<List<String>> selectFiles();
}

/// Persists picker results into a conversation-owned directory. The operation
/// is all-or-nothing: no returned path is visible until every source copied.
abstract interface class ConversationAssetRepository
    implements AttachmentRepository {
  Future<List<String>> persistAssets({
    required String chatId,
    required Iterable<String> sourcePaths,
  });

  Future<String> getOutputDirectory(String chatId);
}
