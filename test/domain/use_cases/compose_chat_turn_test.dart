import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/bot_skill_binding_repository.dart';
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

SkillContent _skill(String id, String name, String instructions) {
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
  _FakeSkillRepository(this.contents);

  final Map<String, SkillContent> contents;
  final List<String> loadedIds = [];

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
  Future<void> uninstall(String skillId) => throw UnimplementedError();
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
