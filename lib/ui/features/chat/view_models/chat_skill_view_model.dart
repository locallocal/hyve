import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/bot_skill_binding_repository.dart';
import 'package:stars/domain/repositories/conversation_skill_pin_repository.dart';
import 'package:stars/domain/repositories/skill_repository.dart';

final class ChatSkillViewModel extends ChangeNotifier {
  ChatSkillViewModel({
    required this.chatId,
    required this.botId,
    required SkillRepository skillRepository,
    required BotSkillBindingRepository bindingRepository,
    required ConversationSkillPinRepository pinRepository,
    this.supportsAutoActivation = false,
  }) : _skillRepository = skillRepository,
       _bindingRepository = bindingRepository,
       _pinRepository = pinRepository {
    _skillChanges = _skillRepository.changes.listen((_) => _reload());
    _bindingChanges = _bindingRepository.changes.listen((_) => _reload());
    _pinChanges = _pinRepository.changes.listen((_) => _reloadPins());
  }

  final String chatId;
  final String botId;
  final SkillRepository _skillRepository;
  final BotSkillBindingRepository _bindingRepository;
  final ConversationSkillPinRepository _pinRepository;
  final bool supportsAutoActivation;
  late final StreamSubscription<List<SkillDescriptor>> _skillChanges;
  late final StreamSubscription<void> _bindingChanges;
  late final StreamSubscription<void> _pinChanges;

  List<SkillDescriptor> _availableSkills = const [];
  Map<String, BotSkillBinding> _bindings = const {};
  Set<String> _manualSelection = const {};
  Set<String> _pinnedSkillIds = const {};
  bool _isLoading = false;

  List<SkillDescriptor> get availableSkills => _availableSkills;
  Set<String> get manuallySelectedSkillIds => _manualSelection;
  Set<String> get pinnedSkillIds => _pinnedSkillIds;
  bool get isLoading => _isLoading;

  bool isAlways(String skillId) =>
      _bindings[skillId]?.activationMode == SkillActivationMode.always;

  bool isPinned(String skillId) => _pinnedSkillIds.contains(skillId);

  bool isAuto(String skillId) =>
      _bindings[skillId]?.activationMode == SkillActivationMode.auto;

  bool get hasUnsupportedAutoSkills =>
      !supportsAutoActivation &&
      _bindings.values.any(
        (binding) =>
            binding.enabled &&
            binding.activationMode == SkillActivationMode.auto,
      );

  bool isSelected(String skillId) =>
      isAlways(skillId) ||
      isPinned(skillId) ||
      _manualSelection.contains(skillId);

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
        binding.activationMode == SkillActivationMode.always ||
        isPinned(skillId)) {
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

  Future<void> pinManualSelection() async {
    final now = DateTime.now();
    for (final skillId in _manualSelection) {
      await _pinRepository.save(
        ConversationSkillPin(chatId: chatId, skillId: skillId, createdAt: now),
      );
    }
    _manualSelection = const {};
    await _reloadPins();
  }

  Future<void> togglePin(String skillId) async {
    if (isPinned(skillId)) {
      await _pinRepository.remove(chatId, skillId);
    } else if (_bindings[skillId]?.enabled ?? false) {
      await _pinRepository.save(
        ConversationSkillPin(
          chatId: chatId,
          skillId: skillId,
          createdAt: DateTime.now(),
        ),
      );
    }
    await _reloadPins();
  }

  Future<void> clearPins() async {
    if (_pinnedSkillIds.isEmpty) return;
    await _pinRepository.clear(chatId);
    await _reloadPins();
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
    await _reloadPins(notify: false);
    notifyListeners();
  }

  Future<void> _reloadPins({bool notify = true}) async {
    final pins = await _pinRepository.getForChat(chatId);
    final availableIds = _availableSkills.map((skill) => skill.id).toSet();
    _pinnedSkillIds = Set<String>.unmodifiable(
      pins.map((pin) => pin.skillId).where(availableIds.contains),
    );
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_skillChanges.cancel());
    unawaited(_bindingChanges.cancel());
    unawaited(_pinChanges.cancel());
    super.dispose();
  }
}
