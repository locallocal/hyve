import 'package:hyve/domain/models/message.dart';

abstract interface class ModelUsageRepository {
  Future<void> upsert(ModelTokenUsageRecord record);

  Future<List<ModelTokenUsageRecord>> getForProject(String projectId);
}
