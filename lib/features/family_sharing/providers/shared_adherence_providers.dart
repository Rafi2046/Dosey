import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cloud/push_messaging_service.dart';
import '../../auth/providers/auth_providers.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../data/shared_adherence_repository.dart';
import '../domain/shared_adherence_dose.dart';

import '../domain/remote_prescription_sync_service.dart';

final sharedAdherenceRepositoryProvider = Provider<SharedAdherenceRepository>((
  ref,
) {
  return const SharedAdherenceRepository();
});

/// Caregiver watches a patient's today schedule from cloud with auto-refresh.
final patientAdherenceScheduleProvider = StreamProvider.autoDispose
    .family<List<SharedAdherenceDose>, String>((ref, patientUid) async* {
      final repo = ref.watch(sharedAdherenceRepositoryProvider);

      yield await repo.getPatientTodaySchedule(patientUid);

      yield* Stream.periodic(const Duration(seconds: 8)).asyncMap((_) {
        return repo.getPatientTodaySchedule(patientUid);
      });
    });

/// Patient side: listens for remote prescriptions added/updated by caregivers,
/// downloads them to local Drift database and configures alarms.
final remotePrescriptionAutoSyncProvider = Provider<void>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return;

  final syncService = ref.read(remotePrescriptionSyncServiceProvider);
  final repo = ref.read(remotePrescriptionRepositoryProvider);

  void doSync() {
    Future.microtask(() => syncService.syncPatientFromCloud(patientUid: uid));
  }

  doSync();
  final channel = repo.subscribeToRemotePrescriptions(uid, doSync);
  final pollTimer = Timer.periodic(const Duration(seconds: 20), (_) => doSync());
  final lifecycle = AppLifecycleListener(onResume: doSync);

  ref.onDispose(() {
    pollTimer.cancel();
    lifecycle.dispose();
    channel?.unsubscribe();
  });
});

/// Patient side: turns caregiver nudges into local notifications.
///
/// Watches only the signed-in uid, so the realtime channel and poll timer
/// live as long as the session instead of being torn down on every schedule
/// change. These cover the app being open; FCM push (registered here too)
/// covers it being in the background or closed.
final caregiverNudgeListenerProvider = Provider<void>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return;

  final repo = ref.read(sharedAdherenceRepositoryProvider);
  void check() {
    Future.microtask(() => repo.checkAndDeliverNudges(uid));
  }

  Future.microtask(() => PushMessagingService.register(uid));
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
/// monitor it, and syncs remote prescriptions from caregivers.
final sharedAdherenceAutoSyncProvider = Provider<void>((ref) {
  ref.watch(caregiverNudgeListenerProvider);
  ref.watch(remotePrescriptionAutoSyncProvider);

  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final occurrences = ref.watch(todayScheduleProvider).value;
  if (occurrences == null || occurrences.isEmpty) return;

  Future.microtask(() {
    final localName = ref.read(userNameProvider).value;
    final patientName = (localName != null && localName.trim().isNotEmpty)
        ? localName.trim()
        : (user.displayName ?? user.email?.split('@').first);
    ref.read(sharedAdherenceRepositoryProvider).syncTodaySchedule(
          patientUid: user.uid,
          patientName: patientName,
          occurrences: occurrences,
        );
  });
});

