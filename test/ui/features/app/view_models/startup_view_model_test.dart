import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/profile_repository.dart';
import 'package:stars/ui/features/app/view_models/startup_view_model.dart';

void main() {
  test(
    'publishes optional capability degradation without blocking startup',
    () async {
      var attempts = 0;
      final viewModel = StartupViewModel(
        profileRepository: _ProfileRepository(),
        capabilityInitializer: () async {
          attempts += 1;
          return StartupCapabilitiesReport([
            StartupCapabilityStatus(
              id: 'online_skill_catalog',
              required: false,
              state:
                  attempts == 1
                      ? StartupCapabilityState.degraded
                      : StartupCapabilityState.available,
              diagnosticCode:
                  attempts == 1
                      ? 'online_skill_catalog_initialization_failed'
                      : '',
              retryable: attempts == 1,
            ),
          ]);
        },
      );
      addTearDown(viewModel.dispose);

      await viewModel.load();

      expect(viewModel.profile, isNotNull);
      expect(viewModel.error, isNull);
      expect(viewModel.capabilitiesReport.isDegraded, isTrue);
      expect(viewModel.capabilitiesReport.issues.single.retryable, isTrue);

      await viewModel.retryCapabilities();
      expect(viewModel.capabilitiesReport.isDegraded, isFalse);
    },
  );
}

final class _ProfileRepository implements ProfileRepository {
  @override
  Stream<Profile> get changes => const Stream.empty();

  @override
  Future<Profile> getProfile() async => Profile(
    name: 'Tester',
    avatar: '',
    fontSize: 16,
    themeMode: 0,
    language: 'en',
    createTimestamp: DateTime(2026),
    modifyTimestamp: DateTime(2026),
  );

  @override
  Future<void> updateProfile(Profile profile) async {}
}
