import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cloud/push_messaging_service.dart';
import '../../auth/providers/auth_providers.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../data/shared_adherence_repository.dart';
import '../domain/shared_adherence_dose.dart';

final sharedAdherenceRepositoryProvider = Provider<SharedAdherenceRepository>((
  ref,
) {
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

/// Patient side: turns caregiver nudges into local notifications.
///
/// Watches only the signed-in uid, so the realtime channel and poll timer
/// live as long as the session instead of being torn down on every schedule
/// change. These cover the app being open; FCM push (registered here too)
/// covers it being in the background or closed.
final caregiverNudgeListenerProvider = Provider<void>((ref) {
  final uid = ref.watch(currentUserProvider.select((u) => u?.uid));
  if (uid == null) return;

  final repo = ref.read(sharedAdherenceRepositoryProvider);
  void check() => repo.checkAndDeliverNudges(uid);

  PushMessagingService.register(uid);
  check();
  final channel = repo.subscribeToNudges(uid, check);
  // Fallback for when realtime isn't enabled on the table or drops.
  final pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => check());
  final lifecycle = AppLifecycleListener(onResume: check);

  ref.onDispose(() {
    pollTimer.cancel();
    lifecycle.dispose();
    channel?.unsubscribe();
  });
});

/// Patient side: pushes today's local schedule to Supabase so caregivers can
/// monitor it.
final sharedAdherenceAutoSyncProvider = Provider<void>((ref) {
  ref.watch(caregiverNudgeListenerProvider);

  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final occurrences = ref.watch(todayScheduleProvider).value;
  if (occurrences == null || occurrences.isEmpty) return;
  ref
      .read(sharedAdherenceRepositoryProvider)
      .syncTodaySchedule(
        patientUid: user.uid,
        patientName: user.displayName ?? user.email?.split('@').first,
        occurrences: occurrences,
      );
});
