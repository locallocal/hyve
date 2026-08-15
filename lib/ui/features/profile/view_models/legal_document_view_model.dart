import 'package:stars/domain/models/legal_document.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/legal_document_repository.dart';
import 'package:stars/ui/core/view_models/disposable_change_notifier.dart';

class LegalDocumentViewModel extends DisposableChangeNotifier {
  LegalDocumentViewModel({
    required LegalDocumentType type,
    required LegalDocumentRepository repository,
  }) : _type = type,
       _repository = repository;

  final LegalDocumentType _type;
  final LegalDocumentRepository _repository;

  String _content = '';
  AppFailure? _error;
  bool _isLoading = false;
  bool _hasLoaded = false;

  String get content => _content;
  AppFailure? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> load({
    required String localeName,
    required String fallbackContent,
  }) async {
    if (isDisposed || _hasLoaded || _isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final content = await _repository.getDocument(
        type: _type,
        localeName: localeName,
      );
      if (isDisposed) return;
      _content = content;
    } catch (error) {
      if (isDisposed) return;
      _error = AppFailure.from(error, code: 'legal_document_load_failed');
      _content = fallbackContent;
    } finally {
      if (!isDisposed) {
        _hasLoaded = true;
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}
