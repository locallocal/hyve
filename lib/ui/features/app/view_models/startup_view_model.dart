import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/profile_repository.dart';
import 'package:hyve/ui/core/view_models/disposable_change_notifier.dart';

class StartupViewModel extends DisposableChangeNotifier {
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
    if (isDisposed) return;
    final generation = ++_loadGeneration;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final profile = await _profileRepository.getProfile();
      if (isDisposed || generation != _loadGeneration) return;
      StartupCapabilitiesReport capabilitiesReport;
      try {
        capabilitiesReport =
            await _capabilityInitializer?.call() ??
            StartupCapabilitiesReport.empty;
      } on Object catch (error) {
        final failure = AppFailure.from(
          error,
          code: 'startup_capability_initialization_failed',
        );
        capabilitiesReport = StartupCapabilitiesReport([
          StartupCapabilityStatus(
            id: 'capability_initializer',
            required: false,
            state: StartupCapabilityState.degraded,
            diagnosticCode: failure.code,
            retryable: failure.retryable,
          ),
        ]);
      }
      if (isDisposed || generation != _loadGeneration) return;
      _profile = profile;
      _capabilitiesReport = capabilitiesReport;
    } catch (error) {
      if (isDisposed || generation != _loadGeneration) return;
      _error = AppFailure.from(error, code: 'startup_required_failed');
    } finally {
      if (!isDisposed && generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> retryCapabilities() async {
    final initializer = _capabilityInitializer;
    if (initializer == null || isDisposed) return;
    late final StartupCapabilitiesReport capabilitiesReport;
    try {
      capabilitiesReport = await initializer();
    } on Object catch (error) {
      final failure = AppFailure.from(
        error,
        code: 'startup_capability_initialization_failed',
      );
      capabilitiesReport = StartupCapabilitiesReport([
        StartupCapabilityStatus(
          id: 'capability_initializer',
          required: false,
          state: StartupCapabilityState.degraded,
          diagnosticCode: failure.code,
          retryable: failure.retryable,
        ),
      ]);
    }
    if (isDisposed) return;
    _capabilitiesReport = capabilitiesReport;
    notifyListeners();
  }
}
