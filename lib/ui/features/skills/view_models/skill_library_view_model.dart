import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/skill_repository.dart';

final class SkillLibraryViewModel extends ChangeNotifier {
  static const int defaultPageSize = 10;

  SkillLibraryViewModel({
    required SkillRepository skillRepository,
    required SkillPickerRepository pickerRepository,
    this.pageSize = defaultPageSize,
  }) : _skillRepository = skillRepository,
       _pickerRepository = pickerRepository,
       assert(pageSize > 0) {
    _changesSubscription = _skillRepository.changes.listen((skills) {
      _applySkills(skills);
    });
  }

  final SkillRepository _skillRepository;
  final SkillPickerRepository _pickerRepository;
  final int pageSize;
  late final StreamSubscription<List<SkillDescriptor>> _changesSubscription;

  List<SkillDescriptor> _skills = const [];
  List<SkillDescriptor> _filteredSkills = const [];
  String _query = '';
  int _pageIndex = 0;
  bool _isLoading = false;
  bool _isImporting = false;
  Object? _error;
  SkillDescriptor? _lastImported;

  List<SkillDescriptor> get skills => _skills;
  List<SkillDescriptor> get filteredSkills => _filteredSkills;
  List<SkillDescriptor> get paginatedSkills {
    if (_filteredSkills.isEmpty) return const [];
    final start = _pageIndex * pageSize;
    final proposedEnd = start + pageSize;
    final end =
        proposedEnd < _filteredSkills.length
            ? proposedEnd
            : _filteredSkills.length;
    return List<SkillDescriptor>.unmodifiable(
      _filteredSkills.getRange(start, end),
    );
  }

  String get query => _query;
  int get currentPage => totalPages == 0 ? 0 : _pageIndex + 1;
  int get totalPages =>
      _filteredSkills.isEmpty
          ? 0
          : (_filteredSkills.length + pageSize - 1) ~/ pageSize;
  bool get hasPreviousPage => _pageIndex > 0;
  bool get hasNextPage => _pageIndex + 1 < totalPages;
  bool get isLoading => _isLoading;
  bool get isImporting => _isImporting;
  Object? get error => _error;
  SkillDescriptor? get lastImported => _lastImported;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _applySkills(
        await _skillRepository.getInstalled(forceRefresh: true),
        notify: false,
      );
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    if (_query == query) return;
    _query = query;
    _pageIndex = 0;
    _applyFilter();
    notifyListeners();
  }

  void clearSearch() => search('');

  void previousPage() {
    if (!hasPreviousPage) return;
    _pageIndex -= 1;
    notifyListeners();
  }

  void nextPage() {
    if (!hasNextPage) return;
    _pageIndex += 1;
    notifyListeners();
  }

  Future<SkillDescriptor?> importDirectory() async {
    final source = await _pickerRepository.pickDirectory();
    return source == null ? null : _install(source);
  }

  Future<SkillDescriptor?> importZipArchive() async {
    final source = await _pickerRepository.pickZipArchive();
    return source == null ? null : _install(source);
  }

  Future<SkillContent> loadContent(String skillId) =>
      _skillRepository.load(skillId);

  Future<void> uninstall(String skillId) async {
    _error = null;
    notifyListeners();
    try {
      await _skillRepository.uninstall(skillId);
    } catch (error) {
      _error = error;
      notifyListeners();
      rethrow;
    }
  }

  Future<SkillDescriptor?> _install(SkillImportSource source) async {
    if (_isImporting) return null;
    _isImporting = true;
    _error = null;
    _lastImported = null;
    notifyListeners();
    try {
      final skill = await _skillRepository.install(source);
      _lastImported = skill;
      return skill;
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  void _applySkills(List<SkillDescriptor> skills, {bool notify = true}) {
    _skills = List<SkillDescriptor>.unmodifiable(skills);
    _applyFilter();
    if (notify) notifyListeners();
  }

  void _applyFilter() {
    final normalized = _query.trim().toLowerCase();
    _filteredSkills =
        normalized.isEmpty
            ? _skills
            : List<SkillDescriptor>.unmodifiable(
              _skills.where((skill) {
                return skill.name.toLowerCase().contains(normalized) ||
                    skill.description.toLowerCase().contains(normalized);
              }),
            );
    _normalizePage();
  }

  void _normalizePage() {
    final pageCount = totalPages;
    if (pageCount == 0) {
      _pageIndex = 0;
    } else if (_pageIndex >= pageCount) {
      _pageIndex = pageCount - 1;
    }
  }

  @override
  void dispose() {
    unawaited(_changesSubscription.cancel());
    super.dispose();
  }
}
