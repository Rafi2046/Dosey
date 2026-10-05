import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../settings/providers/settings_providers.dart';

/// Settings key: '1' when the app asks for the phone's lock to open.
const appLockKey = 'app_lock';

/// Asks the phone to confirm it's the owner (fingerprint, face, or the
/// screen-lock PIN/pattern as a fallback). False if cancelled, failed or the
/// phone has no screen lock. Replaced in tests.
final appLockAuthProvider = Provider<Future<bool> Function(String reason)>(
  (ref) => (reason) async {
    final auth = LocalAuthentication();
    try {
      if (!await auth.isDeviceSupported()) return false;
      return await auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } on Object {
      return false;
    }
  },
);

/// Wall clock for "away long enough to lock again". Replaced in tests.
final appLockClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// Whether App lock is switched on.
final appLockEnabledProvider = AsyncNotifierProvider<AppLockEnabled, bool>(
  AppLockEnabled.new,
);

class AppLockEnabled extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async =>
      await ref.watch(settingsRepositoryProvider).get(appLockKey) == '1';

  Future<void> set(bool enabled) async {
    await ref
        .read(settingsRepositoryProvider)
        .set(appLockKey, enabled ? '1' : null);
    state = AsyncData(enabled);
  }
}

/// Whether the app is locked right now (only matters while App lock is
/// on). Starts locked, so a cold start asks first.
final appLockedProvider = NotifierProvider<AppLocked, bool>(AppLocked.new);

class AppLocked extends Notifier<bool> {
  @override
  bool build() => true;

  void lock() => state = true;
  void unlock() => state = false;
}
