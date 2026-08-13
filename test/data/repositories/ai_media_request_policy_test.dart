import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stars/data/repositories/ai_provider_repository_impl.dart';
import 'package:stars/domain/models/ai_models.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';

void main() {
  test(
    'media generation has an overall timeout and cancels provider',
    () async {
      final provider = _PendingMediaProvider(_bot('timeout'));
      final repository = AiProviderRepositoryImpl(
        mediaTimeout: const Duration(milliseconds: 20),
        mediaProviderFactory: (_) => provider,
      );

      await expectLater(
        repository.generateImage(
          bot: provider.bot,
          prompt: 'image',
          size: '1024x1024',
          outputDirectory: '/tmp',
          referenceImages: const [],
          style: '',
        ),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.code,
            'code',
            'media_request_timeout',
          ),
        ),
      );
      expect(provider.isCancelled, isTrue);
    },
  );

  test('an active media request can be cancelled', () async {
    final provider = _PendingMediaProvider(_bot('cancel'));
    final repository = AiProviderRepositoryImpl(
      mediaTimeout: const Duration(seconds: 5),
      mediaProviderFactory: (_) => provider,
    );
    final request = repository.generateImage(
      bot: provider.bot,
      prompt: 'image',
      size: '1024x1024',
      outputDirectory: '/tmp',
      referenceImages: const [],
      style: '',
    );
    await provider.started.future;

    final cancellationExpectation = expectLater(
      request,
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.kind,
          'kind',
          AppFailureKind.cancelled,
        ),
      ),
    );
    expect(await repository.cancelMedia(provider.bot.id), isTrue);
    await cancellationExpectation;
    expect(provider.isCancelled, isTrue);
  });
}

final class _PendingMediaProvider extends AiProvider {
  _PendingMediaProvider(super.bot);

  final Completer<void> started = Completer<void>();
  final Completer<List<String>> result = Completer<List<String>>();

  @override
  Future<List<String>> generateImage(
    String prompt,
    String size,
    String imageDirPath, {
    List<String> referenceImages = const [],
    String style = '',
  }) {
    if (!started.isCompleted) started.complete();
    return result.future;
  }

  @override
  Future<void> generateText(List<ChatMessage> messages) async {}
}

Bot _bot(String id) => Bot(
  id: id,
  name: 'Media',
  avatar: '',
  provider: 'OpenAI',
  baseURL: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'gpt-image-1',
  systemPrompt: '',
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);
