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
    BundledSkillLoader? bundledSkillLoader,
    this.supportsAutoActivation = false,
  }) : _skillRepository = skillRepository,
       _bindingRepository = bindingRepository,
       _bundledSkillLoader = bundledSkillLoader {
    _skillChanges = _skillRepository.changes.listen((_) => _reload());
    _bindingChanges = _bindingRepository.changes.listen((_) => _reload());
  }

  final String botId;
  final SkillRepository _skillRepository;
  final BotSkillBindingRepository _bindingRepository;
  final BundledSkillLoader? _bundledSkillLoader;
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
    final results = await Future.wait<Object>([
      _skillRepository.getInstalled(forceRefresh: true),
      _bindingRepository.getForBot(botId),
      _bundledSkillLoader?.call() ?? Future.value(const <SkillContent>[]),
    ]);
    final installed = results[0] as List<SkillDescriptor>;
    final bindings = results[1] as List<BotSkillBinding>;
    final bundled = results[2] as List<SkillContent>;
    final merged = <String, SkillDescriptor>{
      for (final content in bundled) content.descriptor.id: content.descriptor,
    };
    for (final skill in installed) {
      merged.putIfAbsent(skill.id, () => skill);
    }
    final bindingsBySkillId = <String, BotSkillBinding>{
      for (final binding in bindings) binding.skillId: binding,
    };
    _availableSkills = List<SkillDescriptor>.unmodifiable(
      supportsAutoActivation
          ? merged.values.where((skill) {
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
