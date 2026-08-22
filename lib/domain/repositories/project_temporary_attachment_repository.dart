abstract interface class ProjectTemporaryAttachmentRepository {
  Future<List<String>> persist({
    required String projectId,
    required Iterable<String> sourcePaths,
  });

  Future<void> clear(String projectId);
}
