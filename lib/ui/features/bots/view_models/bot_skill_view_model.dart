import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/bot_skill_binding_repository.dart';
import 'package:stars/domain/repositories/skill_repository.dart';

final class BotSkillViewModel extends ChangeNotifier {
  static const int defaultPageSize = 5;

  BotSkillViewModel({
    required this.botId,
    required SkillRepository skillRepository,
    required BotSkillBindingRepository bindingRepository,
    this.pageSize = defaultPageSize,
  }) : _skillRepository = skillRepository,
       _bindingRepository = bindingRepository,
       assert(pageSize > 0) {
    _skillChanges = _skillRepository.changes.listen((_) => _reload());
    _bindingChanges = _bindingRepository.changes.listen((_) => _reload());
  }

  final String botId;
  final SkillRepository _skillRepository;
  final BotSkillBindingRepository _bindingRepository;
  final int pageSize;
  late final StreamSubscription<List<SkillDescriptor>> _skillChanges;
  late final StreamSubscription<void> _bindingChanges;

  List<SkillDescriptor> _skills = const [];
  Map<String, BotSkillBinding> _bindings = const {};
  int _addedPageIndex = 0;
  int _availablePageIndex = 0;
  bool _isLoading = false;
  Object? _error;

  List<SkillDescriptor> get skills => _skills;
  List<SkillDescriptor> get addedSkills => List<SkillDescriptor>.unmodifiable(
    _skills.where((skill) => _bindings.containsKey(skill.id)),
  );
  List<SkillDescriptor> get availableSkills =>
      List<SkillDescriptor>.unmodifiable(
        _skills.where(
          (skill) => skill.isUsable && !_bindings.containsKey(skill.id),
        ),
      );
  List<SkillDescriptor> get paginatedAddedSkills =>
      _paginate(addedSkills, _addedPageIndex);
  List<SkillDescriptor> get paginatedAvailableSkills =>
      _paginate(availableSkills, _availablePageIndex);
  int get currentAddedPage => totalAddedPages == 0 ? 0 : _addedPageIndex + 1;
  int get totalAddedPages => _pageCount(addedSkills.length);
  bool get hasPreviousAddedPage => _addedPageIndex > 0;
  bool get hasNextAddedPage => _addedPageIndex + 1 < totalAddedPages;
  int get currentAvailablePage =>
      totalAvailablePages == 0 ? 0 : _availablePageIndex + 1;
  int get totalAvailablePages => _pageCount(availableSkills.length);
  bool get hasPreviousAvailablePage => _availablePageIndex > 0;
  bool get hasNextAvailablePage =>
      _availablePageIndex + 1 < totalAvailablePages;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  BotSkillBinding? bindingFor(String skillId) => _bindings[skillId];

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _reload();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSkill(String skillId) async {
    if (_bindings.containsKey(skillId)) return;
    final now = DateTime.now();
    await _saveBinding(
      BotSkillBinding(
        botId: botId,
        skillId: skillId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> removeSkill(String skillId) async {
    if (!_bindings.containsKey(skillId)) return;
    try {
      await _bindingRepository.remove(botId, skillId);
      _bindings = Map<String, BotSkillBinding>.unmodifiable(
        Map<String, BotSkillBinding>.of(_bindings)..remove(skillId),
      );
      _normalizePages();
      notifyListeners();
    } catch (error) {
      _error = error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setEnabled(String skillId, bool enabled) async {
    final existing = _bindings[skillId];
    if (existing == null) {
      if (enabled) await addSkill(skillId);
      return;
    }
    await _saveBinding(
      existing.copyWith(enabled: enabled, updatedAt: DateTime.now()),
    );
  }

  Future<void> setActivationMode(
    String skillId,
    SkillActivationMode mode,
  ) async {
    if (mode == SkillActivationMode.auto) {
      throw UnsupportedError('自动激活将在结构化 Tool Calling 阶段开放。');
    }
    final existing = _bindings[skillId];
    if (existing == null) return;
    await _saveBinding(
      existing.copyWith(activationMode: mode, updatedAt: DateTime.now()),
    );
  }

  void previousAddedPage() {
    if (!hasPreviousAddedPage) return;
    _addedPageIndex -= 1;
    notifyListeners();
  }

  void nextAddedPage() {
    if (!hasNextAddedPage) return;
    _addedPageIndex += 1;
    notifyListeners();
  }

  void resetAvailablePage() {
    if (_availablePageIndex == 0) return;
    _availablePageIndex = 0;
    notifyListeners();
  }

  void previousAvailablePage() {
    if (!hasPreviousAvailablePage) return;
    _availablePageIndex -= 1;
    notifyListeners();
  }

  void nextAvailablePage() {
    if (!hasNextAvailablePage) return;
    _availablePageIndex += 1;
    notifyListeners();
  }

  Future<void> _saveBinding(BotSkillBinding binding) async {
    try {
      await _bindingRepository.save(binding);
      _bindings = Map<String, BotSkillBinding>.unmodifiable({
        ..._bindings,
        binding.skillId: binding,
      });
      _normalizePages();
      notifyListeners();
    } catch (error) {
      _error = error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _reload() async {
    try {
      final results = await Future.wait<Object>([
        _skillRepository.getInstalled(forceRefresh: true),
        _bindingRepository.getForBot(botId),
      ]);
      _skills = results[0] as List<SkillDescriptor>;
      final bindings = results[1] as List<BotSkillBinding>;
      _bindings = Map<String, BotSkillBinding>.unmodifiable({
        for (final binding in bindings) binding.skillId: binding,
      });
      _normalizePages();
      _error = null;
      notifyListeners();
    } catch (error) {
      _error = error;
      notifyListeners();
    }
  }

  int _pageCount(int itemCount) =>
      itemCount == 0 ? 0 : (itemCount + pageSize - 1) ~/ pageSize;

  List<SkillDescriptor> _paginate(List<SkillDescriptor> source, int pageIndex) {
    if (source.isEmpty) return const [];
    final start = pageIndex * pageSize;
    final proposedEnd = start + pageSize;
    final end = proposedEnd < source.length ? proposedEnd : source.length;
    return List<SkillDescriptor>.unmodifiable(source.getRange(start, end));
  }

  void _normalizePages() {
    final addedPages = totalAddedPages;
    _addedPageIndex =
        addedPages == 0 ? 0 : _addedPageIndex.clamp(0, addedPages - 1);
    final availablePages = totalAvailablePages;
    _availablePageIndex =
        availablePages == 0
            ? 0
            : _availablePageIndex.clamp(0, availablePages - 1);
  }

  @override
  void dispose() {
    unawaited(_skillChanges.cancel());
    unawaited(_bindingChanges.cancel());
    super.dispose();
  }
}
