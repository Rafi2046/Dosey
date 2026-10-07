import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../medicines/data/medicine_schedule_service.dart';
import '../../medicines/data/medicines_repository.dart';
import '../../medicines/domain/dose_time.dart';
import '../../reminders/data/reminders_repository.dart';
import '../data/remote_prescription_repository.dart';
import 'remote_prescription.dart';

final remotePrescriptionRepositoryProvider =
    Provider<RemotePrescriptionRepository>((ref) {
  return const RemotePrescriptionRepository();
});

final remotePrescriptionSyncServiceProvider =
    Provider<RemotePrescriptionSyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final repo = ref.watch(remotePrescriptionRepositoryProvider);
  return RemotePrescriptionSyncService(db, repo);
});

final patientRemotePrescriptionsProvider = FutureProvider.autoDispose
    .family<List<RemotePrescription>, String>((ref, patientUid) async {
  final repo = ref.watch(remotePrescriptionRepositoryProvider);
  return repo.fetchPatientPrescriptions(patientUid);
});

class RemotePrescriptionSyncService {
  RemotePrescriptionSyncService(this._db, this._repo);

  final AppDatabase _db;
  final RemotePrescriptionRepository _repo;

  /// Syncs remote prescriptions from Supabase into the local Drift database
  /// on the patient's device and updates all reminder alarms.
  Future<void> syncPatientFromCloud({
    required String patientUid,
    int profileId = 1,
  }) async {
    if (!_repo.isAvailable) return;

    try {
      // Inactive ones too: those are medicines the caregiver removed.
      final remoteList = await _repo.fetchPatientPrescriptions(
        patientUid,
        includeInactive: true,
      );
      if (remoteList.isEmpty) return;

      final localMedicines = await (_db.select(_db.medicines)
            ..where((tbl) => tbl.profileId.equals(profileId)))
          .get();

      final localReminders = await (_db.select(_db.reminders)
            ..where((tbl) => tbl.profileId.equals(profileId)))
          .get();

      final medRepo = MedicinesRepository(_db, profileId: profileId);
      final remRepo = RemindersRepository(_db, profileId: profileId);
      final scheduleService = MedicineScheduleService(_db, medRepo, remRepo);

      for (final remote in remoteList) {
        // Find existing local medicine by cloudId or by name
        Medicine? existing = localMedicines
            .where((m) => m.cloudId == remote.id || (m.cloudId == null && m.name.toLowerCase() == remote.name.toLowerCase()))
            .firstOrNull;

        final form = _parseForm(remote.form);
        final meal = _parseMeal(remote.mealRelation);

        if (!remote.isActive) {
          // Deactivated in cloud: delete the local copy, but never the
          // patient's own medicine that merely shares its name.
          if (existing != null && existing.cloudId == remote.id) {
            await medRepo.delete(existing.id);
          }
          continue;
        }

        final doseTimes = remote.times.map((tStr) {
          final parts = tStr.split(':');
          final hour = int.tryParse(parts.first) ?? 9;
          final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
          return DoseTime(
            TimeOfDay(hour: hour, minute: minute),
            remote.doseAmount,
          );
        }).toList();

        if (existing == null) {
          // Create new local medicine + reminders
          final companion = MedicinesCompanion(
            name: drift.Value(remote.name),
            form: drift.Value(form),
            doseUnit: drift.Value(remote.doseUnit),
            mealRelation: drift.Value(meal),
            stockQuantity: drift.Value(remote.stockQuantity),
            notes: drift.Value(remote.notes),
            startDate: drift.Value(remote.startDate),
            endDate: drift.Value(remote.endDate),
            cloudId: drift.Value(remote.id),
            firebaseUid: drift.Value(remote.patientUid),
            profileId: drift.Value(profileId),
          );

          await scheduleService.createWithTimes(
            companion,
            doseTimes.isEmpty
                ? [DoseTime(const TimeOfDay(hour: 9, minute: 0), remote.doseAmount)]
                : doseTimes,
            startDate: remote.startDate,
            endDate: remote.endDate,
            critical: true,
          );
        } else {
          // Update existing local medicine if remote is newer
          if (existing.cloudId != remote.id || remote.updatedAt.isAfter(existing.updatedAt)) {
            await medRepo.update(
              existing.id,
              MedicinesCompanion(
                name: drift.Value(remote.name),
                form: drift.Value(form),
                doseUnit: drift.Value(remote.doseUnit),
                mealRelation: drift.Value(meal),
                stockQuantity: drift.Value(remote.stockQuantity),
                notes: drift.Value(remote.notes),
                startDate: drift.Value(remote.startDate),
                endDate: drift.Value(remote.endDate),
                cloudId: drift.Value(remote.id),
                updatedAt: drift.Value(remote.updatedAt),
              ),
            );

            // Re-sync reminders when the times or amounts changed, not only
            // their number (8:00 → 9:00 must move the alarm too).
            final currentReminders = localReminders.where((r) => r.medicineId == existing.id).toList();
            String key(int hour, int minute, double? amount) =>
                '$hour:$minute@${amount ?? 1}';
            final current = [
              for (final r in currentReminders)
                key(r.startAt.hour, r.startAt.minute, r.doseAmount),
            ]..sort();
            final wanted = [
              for (final dt in doseTimes)
                key(dt.time.hour, dt.time.minute, dt.amount),
            ]..sort();
            if (current.join(',') != wanted.join(',')) {
              // Delete old and recreate times
              for (final r in currentReminders) {
                await remRepo.delete(r.id);
              }
              for (final dt in doseTimes) {
                final startAt = DateTime(
                  remote.startDate.year,
                  remote.startDate.month,
                  remote.startDate.day,
                  dt.time.hour,
                  dt.time.minute,
                );
                await remRepo.create(
                  RemindersCompanion(
                    type: const drift.Value(ReminderType.medicine),
                    title: drift.Value(remote.name),
                    medicineId: drift.Value(existing.id),
                    doseAmount: drift.Value(dt.amount),
                    startAt: drift.Value(startAt),
                    repeatRule: const drift.Value(RepeatRule.daily),
                    isCritical: const drift.Value(true),
                    profileId: drift.Value(profileId),
                    cloudId: drift.Value(remote.id),
                  ),
                );
              }
            }
          }
        }
      }

      debugPrint('[RemotePrescriptionSyncService] Local patient medicines synced from cloud.');
    } catch (e) {
      debugPrint('[RemotePrescriptionSyncService] Error during sync: $e');
    }
  }

  MedicineForm _parseForm(String str) {
    for (final f in MedicineForm.values) {
      if (f.name.toLowerCase() == str.toLowerCase()) return f;
    }
    return MedicineForm.tablet;
  }

  MealRelation _parseMeal(String str) {
    for (final m in MealRelation.values) {
      if (m.name.toLowerCase() == str.toLowerCase()) return m;
    }
    return MealRelation.afterMeal;
  }
}
