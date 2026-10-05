import 'package:flutter/foundation.dart';

@immutable
class SharedAdherenceDose {
  const SharedAdherenceDose({
    required this.id,
    required this.patientUid,
    required this.date,
    required this.medicineName,
    required this.time,
    this.patientName,
    this.dosage,
    this.form,
    this.mealRelation,
    this.status = 'pending',
    this.takenAt,
    this.updatedAt,
  });

  factory SharedAdherenceDose.fromJson(Map<String, dynamic> json) {
    return SharedAdherenceDose(
      id: json['id']?.toString() ?? '',
      patientUid: json['patient_uid'] as String? ?? '',
      patientName: json['patient_name'] as String?,
      date: json['date'] as String? ?? '',
      medicineName: json['medicine_name'] as String? ?? '',
      dosage: json['dosage'] as String?,
      time: json['time'] as String? ?? '',
      form: json['form'] as String?,
      mealRelation: json['meal_relation'] as String?,
      status: json['status'] as String? ?? 'pending',
      takenAt: json['taken_at'] != null
          ? DateTime.tryParse(json['taken_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String patientUid;
  final String? patientName;
  final String date;
  final String medicineName;
  final String? dosage;
  final String time;
  final String? form;
  final String? mealRelation;
  final String status;
  final DateTime? takenAt;
  final DateTime? updatedAt;

  bool get isTaken => status == 'taken';
  bool get isSkipped => status == 'skipped';
  bool get isMissed => status == 'missed';
  bool get isPending => status == 'pending';

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'patient_uid': patientUid,
      if (patientName != null) 'patient_name': patientName,
      'date': date,
      'medicine_name': medicineName,
      if (dosage != null) 'dosage': dosage,
      'time': time,
      if (form != null) 'form': form,
      if (mealRelation != null) 'meal_relation': mealRelation,
      'status': status,
      if (takenAt != null) 'taken_at': takenAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
