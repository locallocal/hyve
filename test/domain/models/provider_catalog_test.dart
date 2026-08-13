import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/models/provider_catalog.dart';

void main() {
  test(
    'new provider choices hide retired services and use current endpoints',
    () {
      expect(providersInfo, isNot(contains('Kluster')));
      expect(providersInfo, isNot(contains('Lambda')));
      expect(providersInfo, isNot(contains('Search1Api')));
      expect(
        providersInfo['Nebius']?['base_url'],
        'https://api.tokenfactory.nebius.com/v1/',
      );
      expect(
        providersInfo['Tencent']?['base_url'],
        'https://tokenhub.tencentmaas.com/v1/',
      );
    },
  );

  test('historical providers expose migration metadata', () {
    final kluster = providerMigrationFor(_bot(Bot.apiTypeKluster, ''));
    final lambda = providerMigrationFor(_bot(Bot.apiTypeLambda, ''));
    final search1Api = providerMigrationFor(_bot(Bot.apiTypeSearch1Api, ''));
    final nebius = providerMigrationFor(
      _bot(Bot.apiTypeNebius, 'https://api.studio.nebius.com/v1/'),
    );

    expect(kluster?.lifecycle, ProviderLifecycle.retired);
    expect(kluster?.replacementApiType, Bot.apiTypeOpenAI);
    expect(lambda?.lifecycle, ProviderLifecycle.retired);
    expect(search1Api?.lifecycle, ProviderLifecycle.retired);
    expect(nebius?.lifecycle, ProviderLifecycle.migrated);
    expect(
      nebius?.replacementBaseUrl,
      'https://api.tokenfactory.nebius.com/v1/',
    );
  });

  test(
    'migrated providers using their current default do not show a notice',
    () {
      expect(providerMigrationFor(_bot(Bot.apiTypeNebius, '')), isNull);
      expect(
        providerMigrationFor(
          _bot(Bot.apiTypeTencent, 'https://tokenhub.tencentmaas.com/v1/'),
        ),
        isNull,
      );
    },
  );
}

Bot _bot(String apiType, String baseUrl) => Bot(
  id: 'bot',
  name: 'Historical',
  avatar: '',
  provider: 'Historical',
  baseURL: baseUrl,
  apiKey: '',
  apiType: apiType,
  model: '',
  systemPrompt: '',
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);
