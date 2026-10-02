import '../../../core/database/app_database.dart';

class DoctorWithStats {
  const DoctorWithStats({required this.doctor, required this.activeMedicineCount});

  final Doctor doctor;
  final int activeMedicineCount;
}
