// TODO(2027-02-14): Remove the legacy `isUserFirstTime` migration in
// hasCompletedOnboarding() below. By this date, v3.0 (which introduced
// hasCompletedOnboarding) will have been out long enough that any install
// still reading the old key hasn't been opened in 6+ months.
import 'package:eClassify/core/storage/hive_keys.dart';
import 'package:eClassify/core/storage/hive_storage.dart';

class OnboardingStorage {
  OnboardingStorage._();

  static Future<void> completeOnboarding() => HiveStorage.write(
    HiveKeys.authBox,
    HiveKeys.hasCompletedOnboarding,
    true,
  );

  /// Pre-v3.0 installs never wrote [HiveKeys.hasCompletedOnboarding] — they
  /// tracked the same fact as `isUserFirstTime` (inverted) instead. Without
  /// this fallback every upgrading user reads a missing new key as `false`
  /// and gets sent back through onboarding despite having finished it long
  /// ago. Fall back to the legacy key so upgraders aren't affected, and
  /// migrate them onto the new key so this only runs once.
  static bool hasCompletedOnboarding() {
    final value = HiveStorage.read<bool>(
      HiveKeys.authBox,
      HiveKeys.hasCompletedOnboarding,
    );
    if (value != null) return value;

    final legacyIsFirstTime = HiveStorage.read<bool>(
      HiveKeys.authBox,
      'isUserFirstTime',
    );
    if (legacyIsFirstTime == null) return false; // genuinely new install

    final completed = !legacyIsFirstTime;
    HiveStorage.write(
      HiveKeys.authBox,
      HiveKeys.hasCompletedOnboarding,
      completed,
    );
    return completed;
  }
}
