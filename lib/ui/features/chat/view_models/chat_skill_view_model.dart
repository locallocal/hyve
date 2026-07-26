import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/bot_skill_binding_repository.dart';
import 'package:stars/domain/repositories/skill_repository.dart';

final class ChatSkillViewModel extends ChangeNotifier {
  ChatSkillViewModel({
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

  List<SkillDescriptor> _availableSkills = const [];
  Map<String, BotSkillBinding> _bindings = const {};
  Set<String> _manualSelection = const {};
  bool _isLoading = false;

  List<SkillDescriptor> get availableSkills => _availableSkills;
  Set<String> get manuallySelectedSkillIds => _manualSelection;
  bool get isLoading => _isLoading;

  bool isAlways(String skillId) =>
      _bindings[skillId]?.activationMode == SkillActivationMode.always;

  bool isSelected(String skillId) =>
      isAlways(skillId) || _manualSelection.contains(skillId);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    await _reload();
    _isLoading = false;
    notifyListeners();
  }

  void toggleManual(String skillId) {
    final binding = _bindings[skillId];
    if (binding == null ||
        !binding.enabled ||
        binding.activationMode == SkillActivationMode.always) {
      return;
    }
    final next = Set<String>.of(_manualSelection);
    if (!next.add(skillId)) next.remove(skillId);
    _manualSelection = Set<String>.unmodifiable(next);
    notifyListeners();
  }

  void clearManualSelection() {
    if (_manualSelection.isEmpty) return;
    _manualSelection = const {};
    notifyListeners();
  }

  Future<void> _reload() async {
    final skills = await _skillRepository.getInstalled(forceRefresh: true);
    final bindings = await _bindingRepository.getForBot(botId);
    _bindings = Map<String, BotSkillBinding>.unmodifiable({
      for (final binding in bindings) binding.skillId: binding,
    });
    _availableSkills = List<SkillDescriptor>.unmodifiable(
      skills.where((skill) {
        final binding = _bindings[skill.id];
        return skill.isUsable && binding != null && binding.enabled;
      }),
    );
    final availableIds = _availableSkills.map((skill) => skill.id).toSet();
    _manualSelection = Set<String>.unmodifiable(
      _manualSelection.where(availableIds.contains),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_skillChanges.cancel());
    unawaited(_bindingChanges.cancel());
    super.dispose();
  }
}
