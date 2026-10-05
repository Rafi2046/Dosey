import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/cloud/cloud_initializer.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/enums.dart';
import '../../reminders/domain/scheduled_occurrence.dart';
import '../domain/shared_adherence_dose.dart';

class SharedAdherenceRepository {
  const SharedAdherenceRepository();

  bool get isAvailable => CloudInitializer.isSupabaseInitialized;

  SupabaseClient get _supabase => Supabase.instance.client;

  static String formatDateKey(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static String formatTimeKey(DateTime date) =>
      DateFormat('hh:mm a').format(date);

  /// Patient syncs their today's schedule to Supabase for caregivers to monitor.
  Future<void> syncTodaySchedule({
    required String patientUid,
    String? patientName,
    required List<ScheduledOccurrence> occurrences,
  }) async {
    if (!isAvailable || occurrences.isEmpty) return;

    try {
      final now = DateTime.now().toUtc();
      final dateKey = formatDateKey(DateTime.now());

      final rows = occurrences.map((occ) {
        final med = occ.details.medicine;
        final reminder = occ.details.reminder;
        final timeKey = formatTimeKey(occ.at);

        String statusStr = 'pending';
        if (occ.status == ReminderLogStatus.taken ||
            occ.status == ReminderLogStatus.takenLate) {
          statusStr = 'taken';
        } else if (occ.status == ReminderLogStatus.skipped) {
          statusStr = 'skipped';
        } else if (occ.status == ReminderLogStatus.missed) {
          statusStr = 'missed';
        }

        final medicineName = med?.name ?? reminder.title;
        final dosage = med != null
            ? '${reminder.doseAmount?.toStringAsFixed(0) ?? "1"} ${med.form.name}'
            : '1 Dose';
        final formStr = med?.form.name ?? 'tablet';
        final mealRelationStr = med?.mealRelation.name ?? 'anytime';

        return {
          'patient_uid': patientUid,
          if (patientName != null) 'patient_name': patientName,
          'date': dateKey,
          'medicine_name': medicineName,
          'dosage': dosage,
          'time': timeKey,
          'form': formStr,
          'meal_relation': mealRelationStr,
          'status': statusStr,
          'updated_at': now.toIso8601String(),
        };
      }).toList();

      await _supabase.from('patient_shared_adherence').upsert(
            rows,
            onConflict: 'patient_uid,date,medicine_name,time',
          );
    } catch (e) {
      debugPrint('[SharedAdherenceRepository] Error syncing schedule: $e');
      // Non-fatal if table not migrated yet
    }
  }

  /// Caregiver fetches a patient's adherence schedule for a specific day.
  Future<List<SharedAdherenceDose>> getPatientTodaySchedule(
    String patientUid, {
    DateTime? date,
  }) async {
    if (!isAvailable) return [];

    try {
      final targetDate = date ?? DateTime.now();
      final dateKey = formatDateKey(targetDate);

      var response = await _supabase
          .from('patient_shared_adherence')
          .select()
          .eq('patient_uid', patientUid)
          .eq('date', dateKey)
          .order('time', ascending: true);

      if ((response as List<dynamic>).isEmpty) {
        // Fallback: fetch most recent shared doses for this patient if exact date is empty
        response = await _supabase
            .from('patient_shared_adherence')
            .select()
            .eq('patient_uid', patientUid)
            .order('updated_at', ascending: false)
            .limit(20);
      }

      return (response as List<dynamic>)
          .map((json) =>
              SharedAdherenceDose.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[SharedAdherenceRepository] Error fetching schedule: $e');
      return [];
    }
  }

  /// Caregiver sends a gentle reminder (nudge) to the patient.
  Future<void> sendGentleReminder({
    required String patientUid,
    required String caregiverUid,
    String? caregiverName,
    String? message,
  }) async {
    if (!isAvailable) return;

    try {
      await _supabase.from('family_nudges').insert({
        'patient_uid': patientUid,
        'caregiver_uid': caregiverUid,
        'caregiver_name': caregiverName,
        'message': message ??
            '${caregiverName ?? "Your caregiver"} reminded you to take your pending medicines! 💊',
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'is_read': false,
      });
    } catch (e) {
      debugPrint('[SharedAdherenceRepository] Error sending reminder nudge: $e');
      // Non-fatal if table not migrated yet
    }
  }

  /// Patient checks for incoming unread reminders from caregivers and triggers local notifications.
  Future<void> checkAndDeliverNudges(String patientUid) async {
    if (!isAvailable) return;

    try {
      final nudges = await _supabase
          .from('family_nudges')
          .select()
          .eq('patient_uid', patientUid)
          .eq('is_read', false);

      for (final raw in (nudges as List<dynamic>)) {
        final id = raw['id'] as String;
        final caregiverName = raw['caregiver_name'] as String? ?? 'Your Caregiver';
        final message = raw['message'] as String? ?? 'It is time to take your scheduled medicines!';

        // Create high priority local notification
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: Random().nextInt(100000),
            channelKey: AppConstants.channelMedicine,
            title: '🔔 Reminder from $caregiverName',
            body: message,
            notificationLayout: NotificationLayout.Default,
            wakeUpScreen: true,
          ),
        );

        // Mark as read
        await _supabase
            .from('family_nudges')
            .update({'is_read': true})
            .eq('id', id);
      }
    } catch (e) {
      debugPrint('[SharedAdherenceRepository] Error checking nudges: $e');
    }
  }
}
