import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/doctors_repository.dart';
import '../domain/doctor_with_stats.dart';
import '../data/health_facilities.dart';

final doctorsRepositoryProvider = Provider<DoctorsRepository>(
  (ref) => DoctorsRepository(ref.watch(appDatabaseProvider)),
);

/// Active (non-archived) doctors, for pickers.
final doctorsProvider = StreamProvider<List<Doctor>>(
  (ref) => ref.watch(doctorsRepositoryProvider).watchAll(),
);

final doctorsWithStatsProvider = StreamProvider<List<DoctorWithStats>>(
  (ref) => ref.watch(doctorsRepositoryProvider).watchWithStats(),
);

final doctorByIdProvider = StreamProvider.autoDispose.family<Doctor?, int>(
  (ref, id) => ref.watch(doctorsRepositoryProvider).watchById(id),
);

/// Bangladesh hospitals and clinics (OpenStreetMap), loaded once from the
/// bundled asset; overridden in tests.
final healthFacilitiesProvider = FutureProvider<HealthFacilityIndex>(
  (ref) => HealthFacilityIndex.load(rootBundle),
);
