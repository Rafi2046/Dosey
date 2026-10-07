import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/cloud/cloud_initializer.dart';
import '../domain/family_share.dart';

class FamilyShareRepository {
  const FamilyShareRepository();

  bool get isAvailable => CloudInitializer.isSupabaseInitialized;

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Generates an unambiguous 6-character alphanumeric code (e.g. 7X8K2P).
  static String generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Creates a new 6-character Family Share Code for the patient.
  /// If an unredeemed active code exists for this patient, returns that code.
  Future<FamilyShare> createOrGetShareCode({
    required String patientUid,
    String? patientName,
  }) async {
    if (!isAvailable) {
      throw const FamilyShareException('Cloud services are not connected.');
    }

    try {
      // Check for existing unclaimed active share that hasn't expired (an
      // expired one would only be refused when the caregiver enters it).
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final existing = await _supabase
          .from('family_shares')
          .select()
          .eq('patient_uid', patientUid)
          .eq('is_active', true)
          .isFilter('caregiver_uid', null)
          .or('expires_at.is.null,expires_at.gt.$nowIso')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existing != null) {
        return FamilyShare.fromJson(existing);
      }

      // Generate a new unique code
      final code = generateCode();
      final now = DateTime.now().toUtc();
      final expiresAt = now.add(const Duration(days: 7));

      final insertPayload = <String, dynamic>{
        'patient_uid': patientUid,
        'share_code': code,
        'patient_name': patientName,
        'is_active': true,
        'status': 'unclaimed',
        'created_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      };

      Map<String, dynamic> data;
      try {
        data = await _supabase
            .from('family_shares')
            .insert(insertPayload)
            .select()
            .single();
      } catch (insertError) {
        if (insertError.toString().contains('status') ||
            (insertError is PostgrestException &&
                insertError.message.contains('status'))) {
          // Graceful fallback if status column is not yet migrated in Supabase
          insertPayload.remove('status');
          data = await _supabase
              .from('family_shares')
              .insert(insertPayload)
              .select()
              .single();
        } else {
          rethrow;
        }
      }

      return FamilyShare.fromJson(data);
    } catch (e) {
      debugPrint('[FamilyShareRepository] Error creating share code: $e');
      throw FamilyShareException(
        'Failed to generate share code: ${e is PostgrestException ? e.message : e.toString()}',
      );
    }
  }

  /// Caregiver redeems a 6-character code to link with a patient (sets status to pending).
  Future<FamilyShare> redeemShareCode({
    required String shareCode,
    required String caregiverUid,
    String? caregiverName,
  }) async {
    if (!isAvailable) {
      throw const FamilyShareException('Cloud services are not connected.');
    }

    final sanitizedCode = shareCode.trim().toUpperCase();
    if (sanitizedCode.length != 6) {
      throw const FamilyShareException('Share code must be exactly 6 characters.');
    }

    try {
      // The server checks the code (it alone can see unclaimed shares) and
      // links this caregiver, pending the patient's approval.
      final data = await _supabase.rpc(
        'redeem_share_code',
        params: {'p_code': sanitizedCode, 'p_caregiver_name': caregiverName},
      );
      return FamilyShare.fromJson(Map<String, dynamic>.from(data as Map));
    } on PostgrestException catch (e) {
      debugPrint('[FamilyShareRepository] Error redeeming share code: $e');
      // The function's own messages ("This share code has expired.") are
      // already written for the user.
      throw FamilyShareException(e.message);
    } catch (e) {
      debugPrint('[FamilyShareRepository] Error redeeming share code: $e');
      throw FamilyShareException('Failed to link: $e');
    }
  }

  /// Patient accepts a caregiver's link request.
  Future<void> acceptShare(String shareId) async {
    if (!isAvailable) return;
    try {
      await _supabase
          .from('family_shares')
          .update({'status': 'accepted'})
          .eq('id', shareId);
    } catch (e) {
      if (e.toString().contains('status') ||
          (e is PostgrestException && e.message.contains('status'))) {
        return;
      }
      debugPrint('[FamilyShareRepository] Error accepting share: $e');
      throw FamilyShareException('Failed to accept link request.');
    }
  }

  /// Patient declines a caregiver's link request, resetting the share code.
  Future<void> declineShare(String shareId) async {
    if (!isAvailable) return;
    try {
      await _supabase
          .from('family_shares')
          .update({
            'caregiver_uid': null,
            'caregiver_name': null,
            'status': 'unclaimed',
          })
          .eq('id', shareId);
    } catch (e) {
      if (e.toString().contains('status') ||
          (e is PostgrestException && e.message.contains('status'))) {
        await _supabase
            .from('family_shares')
            .update({
              'caregiver_uid': null,
              'caregiver_name': null,
            })
            .eq('id', shareId);
        return;
      }
      debugPrint('[FamilyShareRepository] Error declining share: $e');
      throw FamilyShareException('Failed to decline link request.');
    }
  }

  /// Listens to real-time changes for patient shares (shows linked caregivers & requests).
  Stream<List<FamilyShare>> watchPatientShares(String patientUid) {
    if (!isAvailable) return const Stream.empty();
    try {
      return _supabase
          .from('family_shares')
          .stream(primaryKey: ['id'])
          .eq('patient_uid', patientUid)
          .order('created_at', ascending: false)
          .map((rows) => rows
              .where((json) => json['is_active'] == true)
              .map((json) => FamilyShare.fromJson(json))
              .toList());
    } catch (e) {
      debugPrint('[FamilyShareRepository] Error streaming patient shares: $e');
      return const Stream.empty();
    }
  }

  /// Listens to real-time changes for caregiver shares (shows monitored patients).
  Stream<List<FamilyShare>> watchCaregiverShares(String caregiverUid) {
    if (!isAvailable) return const Stream.empty();
    try {
      return _supabase
          .from('family_shares')
          .stream(primaryKey: ['id'])
          .eq('caregiver_uid', caregiverUid)
          .order('created_at', ascending: false)
          .map((rows) => rows
              .where((json) => json['is_active'] == true)
              .map((json) => FamilyShare.fromJson(json))
              .toList());
    } catch (e) {
      debugPrint('[FamilyShareRepository] Error streaming caregiver shares: $e');
      return const Stream.empty();
    }
  }

  /// Fetches all shares where current user is the patient (shows linked caregivers & requests).
  Future<List<FamilyShare>> getPatientShares(String patientUid) async {
    if (!isAvailable) return [];
    try {
      final response = await _supabase
          .from('family_shares')
          .select()
          .eq('patient_uid', patientUid)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => FamilyShare.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[FamilyShareRepository] Error fetching patient shares: $e');
      return [];
    }
  }

  /// Fetches all shares where current user is the caregiver (shows monitored patients).
  Future<List<FamilyShare>> getCaregiverShares(String caregiverUid) async {
    if (!isAvailable) return [];
    try {
      final response = await _supabase
          .from('family_shares')
          .select()
          .eq('caregiver_uid', caregiverUid)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => FamilyShare.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[FamilyShareRepository] Error fetching caregiver shares: $e');
      return [];
    }
  }

  /// Revokes / deactivates a family share link.
  Future<void> revokeShare(String shareId) async {
    if (!isAvailable) return;
    try {
      await _supabase
          .from('family_shares')
          .update({'is_active': false})
          .eq('id', shareId);
    } catch (e) {
      debugPrint('[FamilyShareRepository] Error revoking share: $e');
      throw FamilyShareException('Failed to revoke share link.');
    }
  }

  /// Updates the patient display name across family share records and adherence records.
  Future<void> updatePatientName({
    required String patientUid,
    required String newName,
  }) async {
    if (!isAvailable) return;
    try {
      final sanitized = newName.trim();
      await _supabase
          .from('family_shares')
          .update({'patient_name': sanitized})
          .eq('patient_uid', patientUid);

      try {
        await _supabase
            .from('patient_shared_adherence')
            .update({'patient_name': sanitized})
            .eq('patient_uid', patientUid);
      } catch (_) {
        // Optional best effort
      }
    } catch (e) {
      debugPrint('[FamilyShareRepository] Error updating patient name: $e');
      throw FamilyShareException(
        'Failed to update name: ${e is PostgrestException ? e.message : e.toString()}',
      );
    }
  }
}

class FamilyShareException implements Exception {
  const FamilyShareException(this.message);
  final String message;

  @override
  String toString() => message;
}
