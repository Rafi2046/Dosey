import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../data/shared_adherence_repository.dart';
import '../domain/shared_adherence_dose.dart';

final sharedAdherenceRepositoryProvider =
    Provider<SharedAdherenceRepository>((ref) {
  return const SharedAdherenceRepository();
});

/// Caregiver watches a patient's today schedule from cloud.
final patientAdherenceScheduleProvider = FutureProvider.autoDispose
    .family<List<SharedAdherenceDose>, String>((ref, patientUid) async {
  final repo = ref.watch(sharedAdherenceRepositoryProvider);
  return repo.getPatientTodaySchedule(patientUid);
});

/// Automatically syncs the patient's local schedule to Supabase whenever logged in and schedule updates.
final sharedAdherenceAutoSyncProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final scheduleAsync = ref.watch(todayScheduleProvider);
  scheduleAsync.whenData((occurrences) {
    if (occurrences.isNotEmpty) {
      final repo = ref.read(sharedAdherenceRepositoryProvider);
      repo.syncTodaySchedule(
        patientUid: user.uid,
        patientName: user.displayName ?? user.email?.split('@').first,
        occurrences: occurrences,
      );
    }
  });
});
