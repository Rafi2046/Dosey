import '../../../core/database/app_database.dart';

class MedicineWithDoctor {
  const MedicineWithDoctor({required this.medicine, this.doctor});

  final Medicine medicine;
  final Doctor? doctor;

  bool get isLowStock {
    final stock = medicine.stockQuantity;
    final threshold = medicine.refillThreshold;
    return stock != null && threshold != null && stock <= threshold;
  }
}
