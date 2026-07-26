import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/bot_skill_binding_repository.dart';
import 'package:stars/domain/repositories/skill_repository.dart';

final class BotSkillViewModel extends ChangeNotifier {
  BotSkillViewModel({
    required this.botId,
    required SkillRepository skillRepository,
    required BotSkillBindingRepository bindingRepository,
  }) : _skillRepository = skillRepository,
       _bindingRepository = bindingRepository {
    _skillChanges = _skillRepository.changes.listen((_) => _reload());
    _bindingChanges = _bindingRepository.changes.listen((_) => _reload());
  }

  final String botId;
  final SkillRepository _skillRepository;
  final BotSkillBindingRepository _bindingRepository;
  late final StreamSubscription<List<SkillDescriptor>> _skillChanges;
  late final StreamSubscription<void> _bindingChanges;

  List<SkillDescriptor> _skills = const [];
  Map<String, BotSkillBinding> _bindings = const {};
  bool _isLoading = false;
  Object? _error;

  List<SkillDescriptor> get skills => _skills;
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

  Future<void> setEnabled(String skillId, bool enabled) async {
    final existing = _bindings[skillId];
    final now = DateTime.now();
    try {
      if (!enabled) {
        await _bindingRepository.remove(botId, skillId);
        return;
      }
      await _bindingRepository.save(
        existing?.copyWith(enabled: true, updatedAt: now) ??
            BotSkillBinding(
              botId: botId,
              skillId: skillId,
              createdAt: now,
              updatedAt: now,
            ),
      );
    } catch (error) {
      _error = error;
      notifyListeners();
      rethrow;
    }
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
    try {
      await _bindingRepository.save(
        existing.copyWith(activationMode: mode, updatedAt: DateTime.now()),
      );
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
      _error = null;
      notifyListeners();
    } catch (error) {
      _error = error;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_skillChanges.cancel());
    unawaited(_bindingChanges.cancel());
    super.dispose();
  }
}
