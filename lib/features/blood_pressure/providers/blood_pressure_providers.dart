import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../profiles/providers/profiles_providers.dart';
import '../data/blood_pressure_repository.dart';

final bloodPressureRepositoryProvider = Provider<BloodPressureRepository>(
  (ref) => BloodPressureRepository(
    ref.watch(appDatabaseProvider),
    profileId: ref.watch(activeProfileIdProvider),
  ),
);

/// Every reading, newest first.
final bloodPressureReadingsProvider =
    StreamProvider<List<BloodPressureReading>>(
      (ref) => ref.watch(bloodPressureRepositoryProvider).watchAll(),
    );

/// The most recent reading only; uses [select] so the widget rebuilds only
/// when the actual first element changes — not whenever the provider chain
/// invalidates (which avoids "setState during build" on profile switches).
final latestBloodPressureProvider =
    Provider<AsyncValue<BloodPressureReading?>>((ref) {
  return ref.watch(
    bloodPressureReadingsProvider
        .select((async) => async.whenData((list) => list.firstOrNull)),
  );
});
