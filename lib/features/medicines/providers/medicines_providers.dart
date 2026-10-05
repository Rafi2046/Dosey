import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../../profiles/providers/profiles_providers.dart';
import '../data/medicine_names.dart';
import '../data/medicine_schedule_service.dart';
import '../data/medicines_repository.dart';
import '../data/prescription_scanner_service.dart';
import '../../records/presentation/widgets/image_source_sheet.dart';
import '../../../core/database/app_database.dart';
import '../domain/medicine_with_doctor.dart';
import '../domain/stock_status.dart';

final medicinesRepositoryProvider = Provider<MedicinesRepository>(
  (ref) => MedicinesRepository(
    ref.watch(appDatabaseProvider),
    profileId: ref.watch(activeProfileIdProvider),
  ),
);

final medicinesProvider = StreamProvider<List<MedicineWithDoctor>>(
  (ref) => ref.watch(medicinesRepositoryProvider).watchAll(),
);

final activeMedicinesProvider = StreamProvider<List<MedicineWithDoctor>>(
  (ref) => ref.watch(medicinesRepositoryProvider).watchAll(activeOnly: true),
);

/// Units each medicine uses per day (from its enabled reminders).
final unitsPerDayProvider = Provider<Map<int, double>>(
  (ref) => unitsPerDayByMedicine([
    for (final d in ref.watch(enabledRemindersProvider).value ?? const [])
      d.reminder,
  ]),
);

/// Days left / low-stock state of one medicine at its current dose.
final stockStatusProvider = Provider.family<StockStatus, Medicine>(
  (ref, m) => StockStatus(m, ref.watch(unitsPerDayProvider)[m.id] ?? 0),
);

final lowStockMedicinesProvider =
    Provider<AsyncValue<List<MedicineWithDoctor>>>((ref) {
      final units = ref.watch(unitsPerDayProvider);
      return ref
          .watch(activeMedicinesProvider)
          .whenData(
            (list) => list
                .where(
                  (m) =>
                      StockStatus(m.medicine, units[m.medicine.id] ?? 0).isLow,
                )
                .toList(),
          );
    });

final medicinesByDoctorProvider = StreamProvider.autoDispose
    .family<List<MedicineWithDoctor>, int>(
      (ref, doctorId) =>
          ref.watch(medicinesRepositoryProvider).watchByDoctor(doctorId),
    );

final medicineByIdProvider = StreamProvider.autoDispose
    .family<MedicineWithDoctor?, int>(
      (ref, id) => ref.watch(medicinesRepositoryProvider).watchById(id),
    );

/// Names to suggest on the medicine form: the user's saved medicines, then
/// common Bangladeshi brands.
final medicineNamesProvider = FutureProvider<MedicineNameIndex>((ref) async {
  final builtIn = await MedicineNameIndex.load(rootBundle);
  final saved = ref.watch(medicinesProvider).value ?? const [];
  return builtIn.withSaved([for (final m in saved) m.medicine]);
});

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
