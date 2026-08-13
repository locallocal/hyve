import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/profile_repository.dart';

class StartupViewModel extends ChangeNotifier {
  StartupViewModel({
    required ProfileRepository profileRepository,
    Future<StartupCapabilitiesReport> Function()? capabilityInitializer,
  }) : _profileRepository = profileRepository,
       _capabilityInitializer = capabilityInitializer;

  final ProfileRepository _profileRepository;
  final Future<StartupCapabilitiesReport> Function()? _capabilityInitializer;
  Profile? _profile;
  AppFailure? _error;
  StartupCapabilitiesReport _capabilitiesReport =
      StartupCapabilitiesReport.empty;
  bool _isLoading = false;
  int _loadGeneration = 0;

  Profile? get profile => _profile;
  AppFailure? get error => _error;
  StartupCapabilitiesReport get capabilitiesReport => _capabilitiesReport;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;

  Future<void> load() async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final profile = await _profileRepository.getProfile();
      try {
        _capabilitiesReport =
            await _capabilityInitializer?.call() ??
            StartupCapabilitiesReport.empty;
      } on Object catch (error) {
        final failure = AppFailure.from(
          error,
          code: 'startup_capability_initialization_failed',
        );
        _capabilitiesReport = StartupCapabilitiesReport([
          StartupCapabilityStatus(
            id: 'capability_initializer',
            required: false,
            state: StartupCapabilityState.degraded,
            diagnosticCode: failure.code,
            retryable: failure.retryable,
          ),
        ]);
      }
      if (generation != _loadGeneration) return;
      _profile = profile;
    } catch (error) {
      if (generation != _loadGeneration) return;
      _error = AppFailure.from(error, code: 'startup_required_failed');
    } finally {
      if (generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> retryCapabilities() async {
    final initializer = _capabilityInitializer;
    if (initializer == null) return;
    try {
      _capabilitiesReport = await initializer();
    } on Object catch (error) {
      final failure = AppFailure.from(
        error,
        code: 'startup_capability_initialization_failed',
      );
      _capabilitiesReport = StartupCapabilitiesReport([
        StartupCapabilityStatus(
          id: 'capability_initializer',
          required: false,
          state: StartupCapabilityState.degraded,
          diagnosticCode: failure.code,
          retryable: failure.retryable,
        ),
      ]);
    }
    notifyListeners();
  }
}
