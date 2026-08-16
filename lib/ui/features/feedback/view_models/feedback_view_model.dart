import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/feedback_repository.dart';
import 'package:hyve/ui/core/view_models/disposable_change_notifier.dart';

class FeedbackViewModel extends DisposableChangeNotifier {
  FeedbackViewModel({required FeedbackRepository feedbackRepository})
    : _feedbackRepository = feedbackRepository;

  final FeedbackRepository _feedbackRepository;
  bool _isSubmitting = false;
  AppFailure? _error;

  bool get isSubmitting => _isSubmitting;
  AppFailure? get error => _error;

  Future<bool> submit({required String content, String? contact}) async {
    final normalizedContent = content.trim();
    if (isDisposed || normalizedContent.isEmpty || _isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await _feedbackRepository.submit(
        content: normalizedContent,
        contact: contact?.trim(),
      );
      return true;
    } catch (error) {
      if (!isDisposed) {
        _error = AppFailure.from(error, code: 'feedback_submit_failed');
      }
      return false;
    } finally {
      if (!isDisposed) {
        _isSubmitting = false;
        notifyListeners();
      }
    }
  }
}
