import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../blood_pressure/providers/blood_pressure_providers.dart';
import '../../blood_sugar/providers/blood_sugar_providers.dart';
import '../../expenses/providers/expenses_providers.dart';
import '../../medicines/providers/medicines_providers.dart';
import '../../records/providers/records_providers.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../data/profiles_repository.dart';

final profilesRepositoryProvider = Provider<ProfilesRepository>(
  (ref) => ProfilesRepository(ref.watch(appDatabaseProvider)),
);

final profilesProvider = StreamProvider<List<Profile>>(
  (ref) => ref.watch(profilesRepositoryProvider).watchAll(),
);

/// Settings key of the profile open on screen.
const activeProfileKey = 'active_profile';

/// The profile whose medicines, reminders, records and readings the screens
/// show (and new entries go to). Read at startup (see main.dart) so the
/// first frame is already the right person's.
final activeProfileIdProvider = NotifierProvider<ActiveProfile, int>(
  ActiveProfile.new,
);

class ActiveProfile extends Notifier<int> {
  ActiveProfile([this._initial = ProfilesRepository.mainProfileId]);

  final int _initial;

  @override
  int build() => _initial;

  Future<void> select(int id) async {
    state = id;

    // Eagerly flush every provider chain that watches activeProfileIdProvider.
    // This forces Riverpod to rebuild/settle them RIGHT NOW — outside any
    // widget build phase — so that by the time the framework builds the next
    // frame, no provider is dirty and no cascading invalidation can trigger
    // "setState during build" on the UncontrolledProviderScope.
    ref.read(bloodPressureRepositoryProvider);
    ref.read(bloodPressureReadingsProvider);
    ref.read(bloodSugarRepositoryProvider);
    ref.read(bloodSugarReadingsProvider);
    ref.read(remindersRepositoryProvider);
    ref.read(remindersProvider);
    ref.read(expensesRepositoryProvider);
    ref.read(medicinesRepositoryProvider);
    ref.read(recordsRepositoryProvider);

    await ref.read(settingsRepositoryProvider).set(activeProfileKey, '$id');
  }
}

/// The open profile's row (null only while loading).
final activeProfileProvider = Provider<Profile?>((ref) {
  final id = ref.watch(activeProfileIdProvider);
  final all = ref.watch(profilesProvider).value ?? const [];
  return all.where((p) => p.id == id).firstOrNull ?? all.firstOrNull;
});
