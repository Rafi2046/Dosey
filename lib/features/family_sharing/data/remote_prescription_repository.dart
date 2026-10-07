import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/cloud/cloud_initializer.dart';
import '../domain/remote_prescription.dart';
import 'family_share_repository.dart';

class RemotePrescriptionRepository {
  const RemotePrescriptionRepository();

  bool get isAvailable => CloudInitializer.isSupabaseInitialized;

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Fetches all active remote prescriptions for a given patient; with
  /// [includeInactive] also the removed ones (so a sync can delete them).
  Future<List<RemotePrescription>> fetchPatientPrescriptions(
    String patientUid, {
    bool includeInactive = false,
  }) async {
    if (!isAvailable) return [];

    try {
      var query = _supabase
          .from('patient_prescriptions')
          .select()
          .eq('patient_uid', patientUid);
      if (!includeInactive) query = query.eq('is_active', true);
      final response = await query.order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (json) =>
                RemotePrescription.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('[RemotePrescriptionRepository] Error fetching prescriptions: $e');
      return [];
    }
  }

  /// Upserts a remote prescription (created or edited by caregiver or patient).
  Future<RemotePrescription> upsertRemotePrescription(
    RemotePrescription prescription,
  ) async {
    if (!isAvailable) {
      throw const FamilyShareException('Cloud services are not connected.');
    }

    try {
      final payload = prescription.toJson();
      if (prescription.id.isEmpty) {
        payload.remove('id'); // let Supabase generate UUID
      }

      final data = await _supabase
          .from('patient_prescriptions')
          .upsert(payload)
          .select()
          .single();

      return RemotePrescription.fromJson(data);
    } catch (e) {
      debugPrint('[RemotePrescriptionRepository] Error saving prescription: $e');
      if (e is PostgrestException) {
        if (e.message.contains('does not exist') ||
            e.message.contains('Could not find the table') ||
            e.code == '42P01' ||
            e.code == 'PGRST205') {
          throw const FamilyShareException(
            'The patient_prescriptions table is not migrated in Supabase. Please run the SQL schema in your Supabase SQL Editor.',
          );
        }
        throw FamilyShareException('Failed to save prescription: ${e.message}');
      }
      throw FamilyShareException('Failed to save prescription: $e');
    }
  }

  /// Deactivates / deletes a remote prescription.
  Future<void> deleteRemotePrescription(String prescriptionId) async {
    if (!isAvailable) return;

    try {
      await _supabase
          .from('patient_prescriptions')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', prescriptionId);
    } catch (e) {
      debugPrint('[RemotePrescriptionRepository] Error deleting prescription: $e');
    }
  }

  /// Sends a targeted gentle reminder (nudge) for a specific medicine & time.
  Future<void> sendTargetedDoseNudge({
    required String patientUid,
    required String caregiverUid,
    String? caregiverName,
    required String medicineName,
    required String scheduledTime,
  }) async {
    if (!isAvailable) {
      throw const FamilyShareException('Cloud services are not connected.');
    }

    try {
      final senderName = caregiverName ?? 'Your Caregiver';
      final message =
          '$senderName sent a reminder to take your $scheduledTime dose of $medicineName 💊';

      await _supabase.from('family_nudges').insert({
        'patient_uid': patientUid,
        'caregiver_uid': caregiverUid,
        'caregiver_name': senderName,
        // The medicine and time are in the message: family_nudges has no
        // columns for them, and sending any made every insert fail.
        'message': message,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'is_read': false,
      });
    } catch (e) {
      debugPrint('[RemotePrescriptionRepository] Error sending dose nudge: $e');
      if (e is PostgrestException) {
        throw FamilyShareException('Failed to send reminder: ${e.message}');
      }
      throw FamilyShareException('Failed to send reminder: $e');
    }
  }

  /// Subscribes to Realtime remote prescription changes for a patient.
  RealtimeChannel? subscribeToRemotePrescriptions(
    String patientUid,
    void Function() onPrescriptionsChanged,
  ) {
    if (!isAvailable) return null;
    try {
      final channel =
          _supabase.channel('public:patient_prescriptions:$patientUid');
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'patient_prescriptions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'patient_uid',
              value: patientUid,
            ),
            callback: (payload) {
              onPrescriptionsChanged();
            },
          )
          .subscribe();
      return channel;
    } catch (e) {
      debugPrint('[RemotePrescriptionRepository] Realtime subscribe error: $e');
      return null;
    }
  }
}
