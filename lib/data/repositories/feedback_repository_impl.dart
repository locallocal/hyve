import 'package:hyve/data/services/feedback_service.dart';
import 'package:hyve/domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  const FeedbackRepositoryImpl({required FeedbackService service})
    : _service = service;

  final FeedbackService _service;

  @override
  Future<void> submit({required String content, String? contact}) =>
      _service.submit(content: content, contact: contact);
}
