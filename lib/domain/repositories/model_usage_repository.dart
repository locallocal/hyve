import 'package:stars/domain/models/message.dart';

abstract interface class ModelUsageRepository {
  Future<void> upsert(ModelTokenUsageRecord record);
}
