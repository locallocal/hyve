import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/bot_skill_binding_repository.dart';
import 'package:stars/domain/repositories/skill_repository.dart';
import 'package:stars/ui/features/bots/view_models/bot_skill_view_model.dart';
import 'package:stars/ui/features/chat/view_models/chat_skill_view_model.dart';
import 'package:stars/ui/features/skills/view_models/skill_library_view_model.dart';

void main() {
  test(
    'library imports the selected source and publishes installed Skills',
    () async {
      final repository = _FakeSkillRepository([_skill('one')]);
      final picker = _FakeSkillPickerRepository(
        const SkillImportSource(
          kind: SkillImportKind.directory,
          path: '/picked/two',
        ),
      );
      final viewModel = SkillLibraryViewModel(
        skillRepository: repository,
        pickerRepository: picker,
      );
      addTearDown(viewModel.dispose);
      await viewModel.load();

      expect(viewModel.skills.map((skill) => skill.name), ['one']);

      final imported = await viewModel.importDirectory();

      expect(repository.installedSources.single.path, '/picked/two');
      expect(imported?.name, 'two');
      expect(viewModel.lastImported?.id, 'user:two');
      expect(viewModel.isImporting, isFalse);
    },
  );

  test('library searches Skill names and descriptions', () async {
    final repository = _FakeSkillRepository([
      _skill('Release Notes', description: 'Create polished changelogs'),
      _skill('Code Review', description: 'Find concise improvements'),
    ]);
    final viewModel = SkillLibraryViewModel(
      skillRepository: repository,
      pickerRepository: const _FakeSkillPickerRepository(null),
    );
    addTearDown(viewModel.dispose);
    await viewModel.load();

    viewModel.search('  release  ');
    expect(viewModel.filteredSkills.map((skill) => skill.name), [
      'Release Notes',
    ]);

    viewModel.search('CONCISE');
    expect(viewModel.filteredSkills.map((skill) => skill.name), [
      'Code Review',
    ]);

    viewModel.search('missing');
    expect(viewModel.filteredSkills, isEmpty);

    viewModel.clearSearch();
    expect(viewModel.query, isEmpty);
    expect(viewModel.filteredSkills, hasLength(2));
  });

  test(
    'library paginates, resets on search, and corrects removed pages',
    () async {
      final repository = _FakeSkillRepository([
        for (var index = 1; index <= 12; index += 1)
          _skill(
            'Skill $index',
            description: index <= 6 ? 'Alpha group' : 'Beta group',
          ),
      ]);
      final viewModel = SkillLibraryViewModel(
        skillRepository: repository,
        pickerRepository: const _FakeSkillPickerRepository(null),
        pageSize: 5,
      );
      addTearDown(viewModel.dispose);
      await viewModel.load();

      expect(viewModel.currentPage, 1);
      expect(viewModel.totalPages, 3);
      expect(viewModel.paginatedSkills.map((skill) => skill.name), [
        'Skill 1',
        'Skill 2',
        'Skill 3',
        'Skill 4',
        'Skill 5',
      ]);
      expect(viewModel.hasPreviousPage, isFalse);
      expect(viewModel.hasNextPage, isTrue);

      viewModel.nextPage();
      viewModel.nextPage();
      expect(viewModel.currentPage, 3);
      expect(viewModel.paginatedSkills.map((skill) => skill.name), [
        'Skill 11',
        'Skill 12',
      ]);
      expect(viewModel.hasNextPage, isFalse);

      viewModel.search('beta');
      expect(viewModel.currentPage, 1);
      expect(viewModel.totalPages, 2);
      expect(viewModel.paginatedSkills.map((skill) => skill.name), [
        'Skill 7',
        'Skill 8',
        'Skill 9',
        'Skill 10',
        'Skill 11',
      ]);

      viewModel.clearSearch();
      viewModel.nextPage();
      viewModel.nextPage();
      await viewModel.uninstall('user:Skill 12');
      await Future<void>.delayed(Duration.zero);
      await viewModel.uninstall('user:Skill 11');
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.currentPage, 2);
      expect(viewModel.totalPages, 2);
      expect(viewModel.paginatedSkills.map((skill) => skill.name), [
        'Skill 6',
        'Skill 7',
        'Skill 8',
        'Skill 9',
        'Skill 10',
      ]);
    },
  );

  test('bot binding enables manual or always modes but rejects auto', () async {
    final skillRepository = _FakeSkillRepository([_skill('one')]);
    final bindingRepository = _FakeBindingRepository();
    final viewModel = BotSkillViewModel(
      botId: 'bot-1',
      skillRepository: skillRepository,
      bindingRepository: bindingRepository,
    );
    addTearDown(viewModel.dispose);
    await viewModel.load();

    await viewModel.setEnabled('user:one', true);
    await Future<void>.delayed(Duration.zero);
    expect(
      bindingRepository.bindings.single.activationMode,
      SkillActivationMode.manual,
    );

    await viewModel.setActivationMode('user:one', SkillActivationMode.always);
    expect(
      bindingRepository.bindings.single.activationMode,
      SkillActivationMode.always,
    );
    await expectLater(
      viewModel.setActivationMode('user:one', SkillActivationMode.auto),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test(
    'chat selector exposes enabled bindings and keeps always-on selected',
    () async {
      final skillRepository = _FakeSkillRepository([
        _skill('manual'),
        _skill('always'),
        _skill('unbound'),
      ]);
      final timestamp = DateTime(2026, 7, 26);
      final bindingRepository = _FakeBindingRepository([
        BotSkillBinding(
          botId: 'bot-1',
          skillId: 'user:manual',
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
        BotSkillBinding(
          botId: 'bot-1',
          skillId: 'user:always',
          activationMode: SkillActivationMode.always,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      ]);
      final viewModel = ChatSkillViewModel(
        botId: 'bot-1',
        skillRepository: skillRepository,
        bindingRepository: bindingRepository,
      );
      addTearDown(viewModel.dispose);
      await viewModel.load();

      expect(viewModel.availableSkills.map((skill) => skill.id), [
        'user:manual',
        'user:always',
      ]);
      expect(viewModel.isSelected('user:always'), isTrue);

      viewModel.toggleManual('user:always');
      expect(viewModel.manuallySelectedSkillIds, isEmpty);

      viewModel.toggleManual('user:manual');
      expect(viewModel.isSelected('user:manual'), isTrue);
      viewModel.clearManualSelection();
      expect(viewModel.isSelected('user:manual'), isFalse);
      expect(viewModel.isSelected('user:always'), isTrue);
    },
  );
}

SkillDescriptor _skill(String name, {String? description}) {
  final timestamp = DateTime(2026, 7, 26);
  return SkillDescriptor(
    id: 'user:$name',
    name: name,
    description: description ?? '$name description',
    version: '1.0.0',
    scope: SkillScope.user,
    sourceUri: 'file:///$name',
    rootPath: '/skills/$name',
    contentDigest: 'digest-$name',
    trustState: SkillTrustState.userReviewed,
    validationStatus: SkillValidationStatus.valid,
    compatibility: '',
    installedAt: timestamp,
    updatedAt: timestamp,
  );
}

final class _FakeSkillRepository implements SkillRepository {
  _FakeSkillRepository(List<SkillDescriptor> initial)
    : _skills = List<SkillDescriptor>.of(initial);

  final StreamController<List<SkillDescriptor>> _changes =
      StreamController<List<SkillDescriptor>>.broadcast();
  final List<SkillImportSource> installedSources = [];
  List<SkillDescriptor> _skills;

  @override
  Stream<List<SkillDescriptor>> get changes => _changes.stream;

  @override
  Future<SkillDescriptor?> getById(String id) async =>
      _skills.where((skill) => skill.id == id).firstOrNull;

  @override
  Future<List<SkillDescriptor>> getInstalled({
    bool forceRefresh = false,
  }) async => List<SkillDescriptor>.unmodifiable(_skills);

  @override
  Future<SkillDescriptor> install(SkillImportSource source) async {
    installedSources.add(source);
    final name = source.path.split('/').last;
    final skill = _skill(name);
    _skills = [..._skills, skill];
    _changes.add(List<SkillDescriptor>.unmodifiable(_skills));
    return skill;
  }

  @override
  Future<SkillContent> load(String skillId, {String? contentDigest}) async {
    return SkillContent(
      descriptor: (await getById(skillId))!,
      instructions: 'Instructions.',
    );
  }

  @override
  Future<void> uninstall(String skillId) async {
    _skills = _skills.where((skill) => skill.id != skillId).toList();
    _changes.add(List<SkillDescriptor>.unmodifiable(_skills));
  }
}

final class _FakeSkillPickerRepository implements SkillPickerRepository {
  const _FakeSkillPickerRepository(this.source);

  final SkillImportSource? source;

  @override
  Future<SkillImportSource?> pickDirectory() async => source;

  @override
  Future<SkillImportSource?> pickZipArchive() async => source;
}

final class _FakeBindingRepository implements BotSkillBindingRepository {
  _FakeBindingRepository([List<BotSkillBinding> initial = const []])
    : bindings = List<BotSkillBinding>.of(initial);

  final StreamController<void> _changes = StreamController<void>.broadcast();
  List<BotSkillBinding> bindings;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<BotSkillBinding>> getForBot(String botId) async =>
      List<BotSkillBinding>.unmodifiable(
        bindings.where((binding) => binding.botId == botId),
      );

  @override
  Future<void> remove(String botId, String skillId) async {
    bindings =
        bindings
            .where(
              (binding) => binding.botId != botId || binding.skillId != skillId,
            )
            .toList();
    _changes.add(null);
  }

  @override
  Future<void> save(BotSkillBinding binding) async {
    bindings = [
      ...bindings.where(
        (item) =>
            item.botId != binding.botId || item.skillId != binding.skillId,
      ),
      binding,
    ];
    _changes.add(null);
  }
}
