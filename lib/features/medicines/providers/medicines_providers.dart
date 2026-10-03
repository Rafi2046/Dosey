import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../data/medicine_schedule_service.dart';
import '../data/medicines_repository.dart';
import '../data/prescription_scanner_service.dart';
import '../../records/presentation/widgets/image_source_sheet.dart';
import '../domain/medicine_with_doctor.dart';

final medicinesRepositoryProvider = Provider<MedicinesRepository>(
  (ref) => MedicinesRepository(ref.watch(appDatabaseProvider)),
);

final medicinesProvider = StreamProvider<List<MedicineWithDoctor>>(
  (ref) => ref.watch(medicinesRepositoryProvider).watchAll(),
);

final activeMedicinesProvider = StreamProvider<List<MedicineWithDoctor>>(
  (ref) => ref.watch(medicinesRepositoryProvider).watchAll(activeOnly: true),
);

final lowStockMedicinesProvider =
    Provider<AsyncValue<List<MedicineWithDoctor>>>(
      (ref) => ref
          .watch(activeMedicinesProvider)
          .whenData((list) => list.where((m) => m.isLowStock).toList()),
    );

final medicinesByDoctorProvider = StreamProvider.autoDispose
    .family<List<MedicineWithDoctor>, int>(
      (ref, doctorId) =>
          ref.watch(medicinesRepositoryProvider).watchByDoctor(doctorId),
    );

final medicineByIdProvider = StreamProvider.autoDispose
    .family<MedicineWithDoctor?, int>(
      (ref, id) => ref.watch(medicinesRepositoryProvider).watchById(id),
    );

final medicineScheduleServiceProvider = Provider<MedicineScheduleService>(
  (ref) => MedicineScheduleService(
    ref.watch(appDatabaseProvider),
    ref.watch(medicinesRepositoryProvider),
    ref.watch(remindersRepositoryProvider),
  ),
);

/// Active vs stopped tab on the medicines screen.
final showStoppedMedicinesProvider =
    NotifierProvider<ShowStoppedMedicines, bool>(ShowStoppedMedicines.new);

class ShowStoppedMedicines extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final prescriptionScannerProvider = Provider<PrescriptionScannerService>(
  (ref) => PrescriptionScannerService(),
);

/// Camera/gallery picker for prescription scans (overridable in tests).
final prescriptionImagePickerProvider =
    Provider<Future<String?> Function(BuildContext)>((ref) => pickSingleImage);
