import 'package:hyve/domain/models/app_failure.dart';
import 'package:hyve/domain/repositories/attachment_repository.dart';

final class PersistConversationAssets {
  const PersistConversationAssets({required AttachmentRepository repository})
    : _repository = repository;

  final AttachmentRepository _repository;

  Future<List<String>> call({
    required String chatId,
    required Iterable<String> sourcePaths,
  }) {
    final repository = _repository;
    if (repository is! ConversationAssetRepository) {
      throw const AppFailure.storage('conversation_asset_store_unavailable');
    }
    return repository.persistAssets(chatId: chatId, sourcePaths: sourcePaths);
  }
}
