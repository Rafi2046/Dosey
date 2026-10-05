import 'package:flutter/foundation.dart';

@immutable
class FamilyShare {
  const FamilyShare({
    required this.id,
    required this.patientUid,
    required this.shareCode,
    this.patientName,
    this.caregiverUid,
    this.caregiverName,
    this.isActive = true,
    this.createdAt,
    this.expiresAt,
  });

  factory FamilyShare.fromJson(Map<String, dynamic> json) {
    return FamilyShare(
      id: json['id'] as String,
      patientUid: json['patient_uid'] as String,
      shareCode: json['share_code'] as String,
      patientName: json['patient_name'] as String?,
      caregiverUid: json['caregiver_uid'] as String?,
      caregiverName: json['caregiver_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
    );
  }

  final String id;
  final String patientUid;
  final String shareCode;
  final String? patientName;
  final String? caregiverUid;
  final String? caregiverName;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  bool get isClaimed => caregiverUid != null && caregiverUid!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_uid': patientUid,
      'share_code': shareCode,
      if (patientName != null) 'patient_name': patientName,
      if (caregiverUid != null) 'caregiver_uid': caregiverUid,
      if (caregiverName != null) 'caregiver_name': caregiverName,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }

  FamilyShare copyWith({
    String? id,
    String? patientUid,
    String? shareCode,
    String? patientName,
    String? caregiverUid,
    String? caregiverName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return FamilyShare(
      id: id ?? this.id,
      patientUid: patientUid ?? this.patientUid,
      shareCode: shareCode ?? this.shareCode,
      patientName: patientName ?? this.patientName,
      caregiverUid: caregiverUid ?? this.caregiverUid,
      caregiverName: caregiverName ?? this.caregiverName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
