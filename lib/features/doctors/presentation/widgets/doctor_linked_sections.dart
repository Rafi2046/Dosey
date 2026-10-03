import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/link_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../medicines/presentation/medicine_detail_screen.dart';
import '../../../medicines/providers/medicines_providers.dart';
import '../../../records/presentation/record_detail_screen.dart';
import '../../../records/providers/records_providers.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/presentation/reminder_form_screen.dart';
import '../../../reminders/providers/reminders_providers.dart';

/// Medicines, appointments and records linked to one doctor.
class DoctorLinkedSections extends ConsumerWidget {
  const DoctorLinkedSections({super.key, required this.doctorId});

  final int doctorId;

  void _push(BuildContext context, Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines =
        ref.watch(medicinesByDoctorProvider(doctorId)).value ?? const [];
    final reminders =
        ref.watch(remindersByDoctorProvider(doctorId)).value ?? const [];
    final records =
        ref.watch(recordsByDoctorProvider(doctorId)).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (medicines.isNotEmpty) ...[
          const SectionHeader(
            title: DoctorStrings.prescribedMedicines,
            onLight: true,
          ),
          for (final m in medicines)
            LinkTile(
              icon: Icons.medication_rounded,
              title: m.medicine.name,
              subtitle: m.medicine.isActive ? null : MedicineStrings.stopped,
              onTap: () => _push(
                context,
                MedicineDetailScreen(medicineId: m.medicine.id),
              ),
            ),
        ],
        if (reminders.isNotEmpty) ...[
          const SectionHeader(
            title: DoctorStrings.doctorAppointments,
            onLight: true,
          ),
          for (final d in reminders)
            LinkTile(
              icon: d.reminder.type.icon,
              title: d.reminder.title,
              subtitle: ReminderText.schedule(d.reminder),
              onTap: () =>
                  _push(context, ReminderFormScreen(existing: d.reminder)),
            ),
        ],
        if (records.isNotEmpty) ...[
          const SectionHeader(
            title: DoctorStrings.doctorRecords,
            onLight: true,
          ),
          for (final r in records)
            LinkTile(
              icon: r.record.type.icon,
              title: r.record.title,
              subtitle: AppDateFormat.date(r.record.recordDate),
              onTap: () =>
                  _push(context, RecordDetailScreen(recordId: r.record.id)),
            ),
        ],
      ],
    );
  }
}
