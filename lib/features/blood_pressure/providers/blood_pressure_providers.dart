import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/blood_pressure_repository.dart';

final bloodPressureRepositoryProvider = Provider<BloodPressureRepository>(
  (ref) => BloodPressureRepository(ref.watch(appDatabaseProvider)),
);

/// Every reading, newest first.
final bloodPressureReadingsProvider =
    StreamProvider<List<BloodPressureReading>>(
      (ref) => ref.watch(bloodPressureRepositoryProvider).watchAll(),
    );
