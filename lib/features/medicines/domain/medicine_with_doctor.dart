import '../../../core/database/app_database.dart';

class MedicineWithDoctor {
  const MedicineWithDoctor({required this.medicine, this.doctor});

  final Medicine medicine;
  final Doctor? doctor;
}
