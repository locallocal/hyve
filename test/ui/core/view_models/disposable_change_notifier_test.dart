import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/legal_document.dart';
import 'package:stars/domain/repositories/feedback_repository.dart';
import 'package:stars/domain/repositories/legal_document_repository.dart';
import 'package:stars/ui/features/feedback/view_models/feedback_view_model.dart';
import 'package:stars/ui/features/profile/view_models/legal_document_view_model.dart';

void main() {
  group('async ChangeNotifier disposal guard', () {
    test('ignores a successful load completed after disposal', () async {
      final completion = Completer<String>();
      final viewModel = LegalDocumentViewModel(
        type: LegalDocumentType.privacyPolicy,
        repository: _DeferredLegalDocumentRepository(completion.future),
      );
      var notifications = 0;
      viewModel.addListener(() => notifications += 1);

      final load = viewModel.load(
        localeName: 'zh_CN',
        fallbackContent: 'fallback',
      );
      expect(viewModel.isLoading, isTrue);
      expect(notifications, 1);

      viewModel.dispose();
      completion.complete('late policy');
      await load;

      expect(viewModel.content, isEmpty);
      expect(viewModel.error, isNull);
      expect(viewModel.isLoading, isTrue);
      expect(notifications, 1);
      viewModel.dispose();
    });

    test('ignores a failed load completed after disposal', () async {
      final completion = Completer<String>();
      final viewModel = LegalDocumentViewModel(
        type: LegalDocumentType.userAgreement,
        repository: _DeferredLegalDocumentRepository(completion.future),
      );
      var notifications = 0;
      viewModel.addListener(() => notifications += 1);

      final load = viewModel.load(
        localeName: 'zh_CN',
        fallbackContent: 'fallback',
      );
      viewModel.dispose();
      completion.completeError(StateError('late asset failure'));
      await load;

      expect(viewModel.content, isEmpty);
      expect(viewModel.error, isNull);
      expect(viewModel.isLoading, isTrue);
      expect(notifications, 1);
    });

    test(
      'does not publish submit catch or finally state after disposal',
      () async {
        final completion = Completer<void>();
        final viewModel = FeedbackViewModel(
          feedbackRepository: _DeferredFeedbackRepository(completion.future),
        );
        var notifications = 0;
        viewModel.addListener(() => notifications += 1);

        final submit = viewModel.submit(content: 'feedback');
        expect(viewModel.isSubmitting, isTrue);
        expect(notifications, 1);

        viewModel.dispose();
        completion.completeError(StateError('late network failure'));

        expect(await submit, isFalse);
        expect(viewModel.isSubmitting, isTrue);
        expect(viewModel.error, isNull);
        expect(notifications, 1);
      },
    );
  });
}

final class _DeferredLegalDocumentRepository
    implements LegalDocumentRepository {
  const _DeferredLegalDocumentRepository(this.result);

  final Future<String> result;

  @override
  Future<String> getDocument({
    required LegalDocumentType type,
    required String localeName,
  }) => result;
}

final class _DeferredFeedbackRepository implements FeedbackRepository {
  const _DeferredFeedbackRepository(this.result);

  final Future<void> result;

  @override
  Future<void> submit({required String content, String? contact}) => result;
}
