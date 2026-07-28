import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/ai_models.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/bot_skill_binding_repository.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/domain/repositories/skill_repository.dart';
import 'package:stars/domain/use_cases/compose_chat_turn.dart';

void main() {
  test(
    'loads only manually selected and always-on Skill instructions',
    () async {
      final skills = <String, SkillContent>{
        'user:always': _skill('user:always', 'always', 'Always instructions.'),
        'user:selected': _skill(
          'user:selected',
          'selected',
          'Selected instructions.',
        ),
        'user:ignored': _skill('user:ignored', 'ignored', 'Ignored secret.'),
      };
      final skillRepository = _FakeSkillRepository(skills);
      final bindingRepository = _FakeBindingRepository([
        _binding('user:always', SkillActivationMode.always, priority: 10),
        _binding('user:selected', SkillActivationMode.manual, priority: 5),
        _binding('user:ignored', SkillActivationMode.manual),
      ]);
      final compose = ComposeChatTurn(
        skillRepository: skillRepository,
        bindingRepository: bindingRepository,
      );

      final result = await compose(
        bot: _bot(systemPrompt: 'You are a helpful assistant.'),
        history: [
          _message(senderId: 'user-1', content: 'Earlier question'),
          _message(senderId: 'bot-1', content: 'Earlier answer'),
        ],
        userMessage: _message(senderId: 'user-1', content: 'Current question'),
        currentUserId: 'user-1',
        manuallySelectedSkillIds: {'user:selected'},
      );

      expect(skillRepository.loadedIds, ['user:always', 'user:selected']);
      expect(result.messages.map((message) => message.role), [
        'system',
        'user',
        'assistant',
        'user',
      ]);
      final systemPrompt = result.messages.first.content;
      expect(systemPrompt, contains('You are a helpful assistant.'));
      expect(systemPrompt, contains('Always instructions.'));
      expect(systemPrompt, contains('Selected instructions.'));
      expect(systemPrompt, isNot(contains('Ignored secret.')));
      expect(systemPrompt, contains('Scripts and commands'));
      expect(result.activatedSkills.map((skill) => skill.id), [
        'user:always',
        'user:selected',
      ]);
      expect(result.activatedSkills.map((skill) => skill.trigger), [
        SkillActivationTrigger.always,
        SkillActivationTrigger.manual,
      ]);
    },
  );

  test(
    'auto activation uses structured tools and injects requested references',
    () async {
      final auto = _skill(
        'user:release-notes',
        'release-notes',
        'Prepare concise release notes.',
        files: const ['SKILL.md', 'references/style.md'],
      );
      final repository = _FakeSkillRepository(
        {'user:release-notes': auto},
        resources: {
          'user:release-notes:references/style.md': 'Use short headings.',
        },
      );
      final provider = _FakeSkillProvider([
        SkillToolTurn(
          calls: [
            SkillToolCall(
              callId: 'activate-1',
              name: 'activate_skill',
              arguments: const {'name': 'release-notes'},
            ),
          ],
          tokenUsage: const ModelTokenUsage(
            model: 'test-model',
            inputTokens: 20,
            outputTokens: 2,
            totalTokens: 22,
          ),
        ),
        SkillToolTurn(
          calls: [
            SkillToolCall(
              callId: 'read-1',
              name: 'read_skill_resource',
              arguments: const {
                'name': 'release-notes',
                'path': 'references/style.md',
              },
            ),
          ],
          tokenUsage: const ModelTokenUsage(
            model: 'test-model',
            inputTokens: 25,
            outputTokens: 3,
            totalTokens: 28,
          ),
        ),
        SkillToolTurn(isComplete: true),
      ]);
      final compose = ComposeChatTurn(
        skillRepository: repository,
        bindingRepository: _FakeBindingRepository([
          _binding('user:release-notes', SkillActivationMode.auto),
        ]),
      );

      final result = await compose(
        bot: _bot(),
        history: const [],
        userMessage: _message(
          senderId: 'user-1',
          content: 'Draft release notes for this version.',
        ),
        currentUserId: 'user-1',
        skillToolProvider: provider,
      );

      expect(result.activatedSkills, hasLength(1));
      expect(
        result.activatedSkills.single.trigger,
        SkillActivationTrigger.model,
      );
      expect(result.messages.first.content, contains(auto.instructions));
      expect(result.messages.first.content, contains('Use short headings.'));
      expect(
        result.messages.first.content,
        isNot(contains('<available_skills>')),
      );
      expect(repository.readResourcePaths, ['references/style.md']);
      expect(result.skillToolCalls.map((call) => call.name), [
        'activate_skill',
        'read_skill_resource',
      ]);
      expect(
        result.activationAttempts.single.status,
        SkillActivationStatus.activated,
      );
      expect(result.preflightTokenUsage.inputTokens, 45);
      expect(result.preflightTokenUsage.outputTokens, 5);
      expect(provider.session.results, hasLength(2));
      expect(provider.session.closed, isTrue);
    },
  );

  test('legacy provider does not receive or activate auto Skills', () async {
    final auto = _skill(
      'user:auto',
      'auto',
      'Auto instructions must remain undisclosed.',
    );
    final compose = ComposeChatTurn(
      skillRepository: _FakeSkillRepository({'user:auto': auto}),
      bindingRepository: _FakeBindingRepository([
        _binding('user:auto', SkillActivationMode.auto),
      ]),
    );

    final result = await compose(
      bot: _bot(),
      history: const [],
      userMessage: _message(senderId: 'user-1', content: 'Use auto'),
      currentUserId: 'user-1',
      skillToolProvider: _LegacySkillProvider(),
    );

    expect(result.activatedSkills, isEmpty);
    expect(result.messages.single.role, 'user');
    expect(result.messages.single.content, 'Use auto');
  });

  test(
    'reuses an activated reference without spending its budget twice',
    () async {
      final auto = _skill(
        'user:reference-reader',
        'reference-reader',
        'Read relevant reference material.',
        files: const ['SKILL.md', 'references/guide.md'],
      );
      final repository = _FakeSkillRepository(
        {'user:reference-reader': auto},
        resources: {
          'user:reference-reader:references/guide.md': '1234567890123456',
        },
      );
      final provider = _FakeSkillProvider([
        SkillToolTurn(
          calls: [
            SkillToolCall(
              callId: 'activate-1',
              name: 'activate_skill',
              arguments: const {'name': 'reference-reader'},
            ),
          ],
        ),
        SkillToolTurn(
          calls: [
            SkillToolCall(
              callId: 'read-1',
              name: 'read_skill_resource',
              arguments: const {
                'name': 'reference-reader',
                'path': 'references/guide.md',
              },
            ),
          ],
        ),
        SkillToolTurn(
          calls: [
            SkillToolCall(
              callId: 'read-2',
              name: 'read_skill_resource',
              arguments: const {
                'name': 'reference-reader',
                'path': 'references/guide.md',
              },
            ),
          ],
        ),
        SkillToolTurn(isComplete: true),
      ]);
      final compose = ComposeChatTurn(
        skillRepository: repository,
        bindingRepository: _FakeBindingRepository([
          _binding('user:reference-reader', SkillActivationMode.auto),
        ]),
        budget: const SkillContextBudget(maxResourceTokens: 3),
      );

      final result = await compose(
        bot: _bot(),
        history: const [],
        userMessage: _message(
          senderId: 'user-1',
          content: 'Use the reference guide.',
        ),
        currentUserId: 'user-1',
        skillToolProvider: provider,
      );

      expect(repository.readResourcePaths, ['references/guide.md']);
      expect(result.estimatedSkillContextTokens, lessThanOrEqualTo(13));
      expect(
        provider.session.results
            .expand((results) => results)
            .where((result) => result.name == 'read_skill_resource')
            .map((result) => result.content),
        everyElement(contains('[truncated]')),
      );
    },
  );

  test('pinned Skills activate with a distinct audit trigger', () async {
    final pinned = _skill('user:pinned', 'pinned', 'Pinned instructions.');
    final compose = ComposeChatTurn(
      skillRepository: _FakeSkillRepository({'user:pinned': pinned}),
      bindingRepository: _FakeBindingRepository([
        _binding('user:pinned', SkillActivationMode.manual),
      ]),
    );

    final result = await compose(
      bot: _bot(),
      history: const [],
      userMessage: _message(senderId: 'user-1', content: 'Question'),
      currentUserId: 'user-1',
      pinnedSkillIds: const {'user:pinned'},
    );

    expect(
      result.activatedSkills.single.trigger,
      SkillActivationTrigger.pinned,
    );
    expect(
      result.activationAttempts.single.status,
      SkillActivationStatus.activated,
    );
  });

  test('limits activation to three usable Skills', () async {
    final skills = <String, SkillContent>{
      for (var index = 0; index < 5; index++)
        'user:skill-$index': _skill(
          'user:skill-$index',
          'skill-$index',
          'Instructions $index',
        ),
    };
    final compose = ComposeChatTurn(
      skillRepository: _FakeSkillRepository(skills),
      bindingRepository: _FakeBindingRepository([
        for (var index = 0; index < 5; index++)
          _binding(
            'user:skill-$index',
            SkillActivationMode.always,
            priority: index,
          ),
      ]),
    );

    final result = await compose(
      bot: _bot(),
      history: const [],
      userMessage: _message(senderId: 'user-1', content: 'Question'),
      currentUserId: 'user-1',
    );

    expect(result.activatedSkills, hasLength(3));
    expect(result.activatedSkills.map((skill) => skill.id), [
      'user:skill-4',
      'user:skill-3',
      'user:skill-2',
    ]);
  });

  test('records Skills skipped by the context Token budget', () async {
    final oversized = _skill(
      'user:oversized',
      'oversized',
      'This instruction is intentionally longer than a four-token budget.',
    );
    final compose = ComposeChatTurn(
      skillRepository: _FakeSkillRepository({'user:oversized': oversized}),
      bindingRepository: _FakeBindingRepository([
        _binding('user:oversized', SkillActivationMode.always),
      ]),
      budget: const SkillContextBudget(maxTokensPerSkill: 4),
    );

    final result = await compose(
      bot: _bot(),
      history: const [],
      userMessage: _message(senderId: 'user-1', content: 'Question'),
      currentUserId: 'user-1',
    );

    expect(result.activatedSkills, isEmpty);
    expect(
      result.activationAttempts.single.status,
      SkillActivationStatus.skipped,
    );
    expect(result.activationAttempts.single.errorCode, 'per_skill_token_limit');
  });

  test(
    'skips unusable candidates before applying the activation limit',
    () async {
      final blocked = _skill(
        'user:blocked',
        'blocked',
        'Blocked instructions.',
      );
      final usable = _skill('user:usable', 'usable', 'Usable instructions.');
      final blockedDescriptor = SkillDescriptor(
        id: blocked.descriptor.id,
        name: blocked.descriptor.name,
        description: blocked.descriptor.description,
        version: blocked.descriptor.version,
        scope: blocked.descriptor.scope,
        sourceUri: blocked.descriptor.sourceUri,
        rootPath: blocked.descriptor.rootPath,
        contentDigest: blocked.descriptor.contentDigest,
        trustState: SkillTrustState.blocked,
        validationStatus: blocked.descriptor.validationStatus,
        compatibility: blocked.descriptor.compatibility,
        installedAt: blocked.descriptor.installedAt,
        updatedAt: blocked.descriptor.updatedAt,
      );
      final compose = ComposeChatTurn(
        skillRepository: _FakeSkillRepository({
          'user:blocked': SkillContent(
            descriptor: blockedDescriptor,
            instructions: blocked.instructions,
          ),
          'user:usable': usable,
        }),
        bindingRepository: _FakeBindingRepository([
          _binding('user:blocked', SkillActivationMode.always, priority: 100),
          _binding('user:usable', SkillActivationMode.always, priority: 1),
        ]),
      );

      final result = await compose(
        bot: _bot(),
        history: const [],
        userMessage: _message(senderId: 'user-1', content: 'Question'),
        currentUserId: 'user-1',
      );

      expect(result.activatedSkills.map((skill) => skill.id), ['user:usable']);
      expect(result.messages.first.content, contains('Usable instructions.'));
      expect(
        result.messages.first.content,
        isNot(contains('Blocked instructions.')),
      );
    },
  );
}

SkillContent _skill(
  String id,
  String name,
  String instructions, {
  List<String> files = const [],
}) {
  final now = DateTime(2026, 7, 26);
  return SkillContent(
    descriptor: SkillDescriptor(
      id: id,
      name: name,
      description: '$name description',
      version: '1.0.0',
      scope: SkillScope.user,
      sourceUri: 'file:///$name',
      rootPath: '/skills/$name',
      contentDigest: 'digest-$name',
      trustState: SkillTrustState.userReviewed,
      validationStatus: SkillValidationStatus.valid,
      compatibility: '',
      installedAt: now,
      updatedAt: now,
    ),
    instructions: instructions,
    files: files,
  );
}

BotSkillBinding _binding(
  String skillId,
  SkillActivationMode mode, {
  int priority = 0,
}) {
  final now = DateTime(2026, 7, 26);
  return BotSkillBinding(
    botId: 'bot-1',
    skillId: skillId,
    activationMode: mode,
    priority: priority,
    createdAt: now,
    updatedAt: now,
  );
}

Bot _bot({String systemPrompt = ''}) => Bot(
  id: 'bot-1',
  name: 'Assistant',
  avatar: '',
  provider: 'OpenAI',
  baseURL: 'https://example.test',
  apiKey: 'secret',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: systemPrompt,
  parameters: const {},
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);

Message _message({required String senderId, required String content}) =>
    Message(
      chatId: 'chat-1',
      botId: 'bot-1',
      senderId: senderId,
      content: content,
      timestamp: DateTime(2026, 7, 26),
    );

final class _FakeSkillRepository implements SkillRepository {
  _FakeSkillRepository(this.contents, {this.resources = const {}});

  final Map<String, SkillContent> contents;
  final Map<String, String> resources;
  final List<String> loadedIds = [];
  final List<String> readResourcePaths = [];

  @override
  Stream<List<SkillDescriptor>> get changes => const Stream.empty();

  @override
  Future<SkillDescriptor?> getById(String id) async => contents[id]?.descriptor;

  @override
  Future<List<SkillDescriptor>> getInstalled({
    bool forceRefresh = false,
  }) async => contents.values.map((content) => content.descriptor).toList();

  @override
  Future<SkillDescriptor> install(SkillImportSource source) =>
      throw UnimplementedError();

  @override
  Future<SkillContent> load(String skillId, {String? contentDigest}) async {
    loadedIds.add(skillId);
    return contents[skillId]!;
  }

  @override
  Future<SkillResourceContent> readResource(
    String skillId,
    String relativePath, {
    String? contentDigest,
  }) async {
    readResourcePaths.add(relativePath);
    return SkillResourceContent(
      skillId: skillId,
      path: relativePath,
      content: resources['$skillId:$relativePath']!,
    );
  }

  @override
  Future<void> uninstall(String skillId) => throw UnimplementedError();
}

final class _FakeSkillProvider extends AiProvider {
  _FakeSkillProvider(List<SkillToolTurn> turns)
    : session = _FakeSkillSession(turns),
      super(_bot());

  final _FakeSkillSession session;

  @override
  AiProviderCapabilities get capabilities => const AiProviderCapabilities(
    supportsStructuredToolCalls: true,
    supportsToolResults: true,
  );

  @override
  SkillToolSession openSkillToolSession(SkillToolSessionRequest request) {
    session.request = request;
    return session;
  }

  @override
  Future<void> generateText(List<ChatMessage> messages) async {}
}

final class _LegacySkillProvider extends AiProvider {
  _LegacySkillProvider() : super(_bot());

  @override
  Future<void> generateText(List<ChatMessage> messages) async {}
}

final class _FakeSkillSession implements SkillToolSession {
  _FakeSkillSession(this.turns);

  final List<SkillToolTurn> turns;
  final List<List<SkillToolResult>> results = [];
  SkillToolSessionRequest? request;
  var _index = 0;
  var closed = false;

  @override
  Future<SkillToolTurn> start() async => turns[_index++];

  @override
  Future<SkillToolTurn> continueWith(List<SkillToolResult> toolResults) async {
    results.add(toolResults);
    return turns[_index++];
  }

  @override
  void close() => closed = true;
}

final class _FakeBindingRepository implements BotSkillBindingRepository {
  _FakeBindingRepository(this.bindings);

  final List<BotSkillBinding> bindings;

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<List<BotSkillBinding>> getForBot(String botId) async => bindings;

  @override
  Future<void> remove(String botId, String skillId) =>
      throw UnimplementedError();

  @override
  Future<void> save(BotSkillBinding binding) => throw UnimplementedError();
}
