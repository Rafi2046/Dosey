import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../data/shared_adherence_repository.dart';
import '../domain/shared_adherence_dose.dart';

final sharedAdherenceRepositoryProvider =
    Provider<SharedAdherenceRepository>((ref) {
  return const SharedAdherenceRepository();
});

/// Caregiver watches a patient's today schedule from cloud with auto-refresh.
final patientAdherenceScheduleProvider = FutureProvider.autoDispose
    .family<List<SharedAdherenceDose>, String>((ref, patientUid) async {
  final repo = ref.watch(sharedAdherenceRepositoryProvider);
  
  // Refresh schedule periodically while caregiver is viewing the screen
  final timer = Timer.periodic(const Duration(seconds: 6), (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  return repo.getPatientTodaySchedule(patientUid);
});

/// Automatically syncs the patient's local schedule to Supabase and delivers incoming reminders.
final sharedAdherenceAutoSyncProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final repo = ref.read(sharedAdherenceRepositoryProvider);

  // 1. Initial check on startup / login
  repo.checkAndDeliverNudges(user.uid);

  // 2. Realtime subscription to receive caregiver nudges instantly
  final channel = repo.subscribeToNudges(user.uid, () {
    repo.checkAndDeliverNudges(user.uid);
  });

  // 3. Fallback periodic timer (every 8 seconds) to guarantee delivery
  final pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
    repo.checkAndDeliverNudges(user.uid);
  });

  ref.onDispose(() {
    pollTimer.cancel();
    channel?.unsubscribe();
  });

  // 4. Push local changes to cloud
  final scheduleAsync = ref.watch(todayScheduleProvider);
  scheduleAsync.whenData((occurrences) {
    if (occurrences.isNotEmpty) {
      repo.syncTodaySchedule(
        patientUid: user.uid,
        patientName: user.displayName ?? user.email?.split('@').first,
        occurrences: occurrences,
      );
    }
  });
});

