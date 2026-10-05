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
      // Check for existing unclaimed active share
      final existing = await _supabase
          .from('family_shares')
          .select()
          .eq('patient_uid', patientUid)
          .eq('is_active', true)
          .isFilter('caregiver_uid', null)
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

      final data = await _supabase
          .from('family_shares')
          .insert({
            'patient_uid': patientUid,
            'share_code': code,
            'patient_name': patientName,
            'is_active': true,
            'status': 'unclaimed',
            'created_at': now.toIso8601String(),
            'expires_at': expiresAt.toIso8601String(),
          })
          .select()
          .single();

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
      final record = await _supabase
          .from('family_shares')
          .select()
          .eq('share_code', sanitizedCode)
          .eq('is_active', true)
          .maybeSingle();

      if (record == null) {
        throw const FamilyShareException(
          'Invalid or expired share code. Please ask your family member for a new code.',
        );
      }

      final share = FamilyShare.fromJson(record);

      if (share.patientUid == caregiverUid) {
        throw const FamilyShareException('You cannot link to your own profile.');
      }

      if (share.isClaimed && share.caregiverUid != caregiverUid) {
        throw const FamilyShareException(
          'This share code has already been requested by another caregiver.',
        );
      }

      if (share.expiresAt != null && DateTime.now().toUtc().isAfter(share.expiresAt!)) {
        throw const FamilyShareException('This share code has expired.');
      }

      // Update the record with caregiver info and set status to pending approval
      final updated = await _supabase
          .from('family_shares')
          .update({
            'caregiver_uid': caregiverUid,
            'caregiver_name': caregiverName,
            'status': 'pending',
          })
          .eq('id', share.id)
          .select()
          .single();

      return FamilyShare.fromJson(updated);
    } catch (e) {
      if (e is FamilyShareException) rethrow;
      debugPrint('[FamilyShareRepository] Error redeeming share code: $e');
      throw FamilyShareException(
        'Failed to link: ${e is PostgrestException ? e.message : e.toString()}',
      );
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
      debugPrint('[FamilyShareRepository] Error declining share: $e');
      throw FamilyShareException('Failed to decline link request.');
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
}

class FamilyShareException implements Exception {
  const FamilyShareException(this.message);
  final String message;

  @override
  String toString() => message;
}
