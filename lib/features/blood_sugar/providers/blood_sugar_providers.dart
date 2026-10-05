import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../profiles/providers/profiles_providers.dart';
import '../data/blood_sugar_repository.dart';

final bloodSugarRepositoryProvider = Provider<BloodSugarRepository>(
  (ref) => BloodSugarRepository(
    ref.watch(appDatabaseProvider),
    profileId: ref.watch(activeProfileIdProvider),
  ),
);

/// Every reading, newest first.
final bloodSugarReadingsProvider = StreamProvider<List<BloodSugarReading>>(
  (ref) => ref.watch(bloodSugarRepositoryProvider).watchAll(),
);

/// The most recent reading only; uses [select] to avoid the
/// "setState during build" race on profile switches.
final latestBloodSugarProvider =
    Provider<AsyncValue<BloodSugarReading?>>((ref) {
  return ref.watch(
    bloodSugarReadingsProvider
        .select((async) => async.whenData((list) => list.firstOrNull)),
  );
});

