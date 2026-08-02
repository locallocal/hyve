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
    this.supportsAutoActivation = false,
  }) : _skillRepository = skillRepository,
       _bindingRepository = bindingRepository {
    _skillChanges = _skillRepository.changes.listen((_) => _reload());
    _bindingChanges = _bindingRepository.changes.listen((_) => _reload());
  }

  final String botId;
  final SkillRepository _skillRepository;
  final BotSkillBindingRepository _bindingRepository;
  final bool supportsAutoActivation;
  late final StreamSubscription<List<SkillDescriptor>> _skillChanges;
  late final StreamSubscription<void> _bindingChanges;

  List<SkillDescriptor> _availableSkills = const [];
  bool _isLoading = false;

  List<SkillDescriptor> get availableSkills => _availableSkills;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    await _reload();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _reload() async {
    final skills = await _skillRepository.getInstalled(forceRefresh: true);
    final bindings = await _bindingRepository.getForBot(botId);
    final bindingsBySkillId = <String, BotSkillBinding>{
      for (final binding in bindings) binding.skillId: binding,
    };
    _availableSkills = List<SkillDescriptor>.unmodifiable(
      supportsAutoActivation
          ? skills.where((skill) {
            final binding = bindingsBySkillId[skill.id];
            return skill.isUsable && binding != null && binding.enabled;
          })
          : const [],
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
