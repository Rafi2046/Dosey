import 'package:flutter/foundation.dart';

/// Represents a remote prescription / medicine regimen shared between a patient
/// and their caregivers in the cloud (Supabase).
@immutable
class RemotePrescription {
  const RemotePrescription({
    required this.id,
    required this.patientUid,
    required this.name,
    this.form = 'tablet',
    this.mealRelation = 'afterMeal',
    this.doseAmount = 1.0,
    this.doseUnit = 'tablet',
    this.times = const ['09:00'],
    required this.startDate,
    this.endDate,
    this.stockQuantity,
    this.notes,
    this.updatedBy,
    required this.updatedAt,
    this.isActive = true,
  });

  final String id;
  final String patientUid;
  final String name;
  final String form;
  final String mealRelation;
  final double doseAmount;
  final String doseUnit;
  final List<String> times;
  final DateTime startDate;
  final DateTime? endDate;
  final double? stockQuantity;
  final String? notes;
  final String? updatedBy;
  final DateTime updatedAt;
  final bool isActive;

  factory RemotePrescription.fromJson(Map<String, dynamic> json) {
    List<String> parsedTimes = const ['09:00'];
    if (json['times'] is List) {
      parsedTimes = (json['times'] as List).map((t) => t.toString()).toList();
    } else if (json['times'] is String) {
      parsedTimes = (json['times'] as String)
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
    }

    return RemotePrescription(
      id: json['id'] as String? ?? '',
      patientUid: json['patient_uid'] as String? ?? '',
      name: json['name'] as String? ?? 'Medicine',
      form: json['form'] as String? ?? 'tablet',
      mealRelation: json['meal_relation'] as String? ?? 'afterMeal',
      doseAmount: (json['dose_amount'] as num?)?.toDouble() ?? 1.0,
      doseUnit: json['dose_unit'] as String? ?? 'tablet',
      times: parsedTimes,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      stockQuantity: (json['stock_quantity'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      updatedBy: json['updated_by'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_uid': patientUid,
        'name': name,
        'form': form,
        'meal_relation': mealRelation,
        'dose_amount': doseAmount,
        'dose_unit': doseUnit,
        'times': times,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate?.toIso8601String().split('T').first,
        'stock_quantity': stockQuantity,
        'notes': notes,
        'updated_by': updatedBy,
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'is_active': isActive,
      };

  RemotePrescription copyWith({
    String? id,
    String? patientUid,
    String? name,
    String? form,
    String? mealRelation,
    double? doseAmount,
    String? doseUnit,
    List<String>? times,
    DateTime? startDate,
    DateTime? endDate,
    double? stockQuantity,
    String? notes,
    String? updatedBy,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return RemotePrescription(
      id: id ?? this.id,
      patientUid: patientUid ?? this.patientUid,
      name: name ?? this.name,
      form: form ?? this.form,
      mealRelation: mealRelation ?? this.mealRelation,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      times: times ?? this.times,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      notes: notes ?? this.notes,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
