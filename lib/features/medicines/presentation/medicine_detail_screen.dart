import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/cream_scaffold.dart';
import '../../../core/widgets/info_block.dart';
import '../../../core/widgets/labeled_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../../doctors/presentation/doctor_detail_screen.dart';
import '../../expenses/providers/expenses_providers.dart';
import '../../reminders/domain/reminder_text.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../domain/medicine_with_doctor.dart';
import '../providers/medicines_providers.dart';
import 'medicine_form_screen.dart';
import 'widgets/medicine_times_section.dart';
import 'widgets/refill_sheet.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utils/numbers.dart';
import '../../../core/widgets/skeleton.dart';

enum _MenuAction { toggleActive, delete }

/// The design's "Medicine" screen: everything about one medicine on cream.
class MedicineDetailScreen extends ConsumerWidget {
  const MedicineDetailScreen({super.key, required this.medicineId});

  final int medicineId;

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    MedicineWithDoctor item,
    _MenuAction action,
  ) async {
    final repo = ref.read(medicinesRepositoryProvider);
    switch (action) {
      case _MenuAction.toggleActive:
        await repo.setActive(item.medicine.id, active: !item.medicine.isActive);
      case _MenuAction.delete:
        if (!await confirmDelete(
          context,
          body: context.l10n.deleteMedicineBody,
        )) {
          return;
        }
        if (context.mounted) Navigator.pop(context);
        await repo.delete(item.medicine.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(medicineByIdProvider(medicineId));
    final item = value.value;

    return CreamScaffold(
      title: context.l10n.medicineDetails,
      actions: [
        if (item != null)
          PopupMenuButton<_MenuAction>(
            iconColor: AppColors.ink,
            onSelected: (a) => _onMenu(context, ref, item, a),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _MenuAction.toggleActive,
                child: Text(
                  item.medicine.isActive
                      ? context.l10n.stopMedicine
                      : context.l10n.resumeMedicine,
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.delete,
                child: Text(context.l10n.delete),
              ),
            ],
          ),
      ],
      bottomBar: item == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PillButton(
                  label: context.l10n.refill,
                  tone: PillButtonTone.moss,
                  trailingIcon: Icons.add_shopping_cart_rounded,
                  onPressed: () => showRefillSheet(context, item.medicine),
                ),
                AppSpacing.gapMd,
                PillButton(
                  label: context.l10n.changeSetting,
                  trailingIcon: Icons.settings_rounded,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          MedicineFormScreen(existing: item.medicine),
                    ),
                  ),
                ),
              ],
            ),
      body: AsyncValueView(
        skeleton: const Skeleton.detail(),
        value: value,
        data: (item) =>
            item == null ? const SizedBox.shrink() : _DetailBody(item: item),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.item});

  final MedicineWithDoctor item;

  static Widget _chip(String label, {IconData? icon, VoidCallback? onTap}) =>
      StatusChip(
        label: label,
        icon: icon,
        background: AppColors.sand,
        foreground: AppColors.ink,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = item.medicine;
    final reminders = <Reminder>[
      for (final d
          in ref.watch(remindersByMedicineProvider(m.id)).value ?? const [])
        d.reminder,
    ];
    final end = m.endDate;
    final duration = end == null
        ? context.l10n.ongoing
        : context.l10n.daysCount(end.difference(m.startDate).inDays + 1);
    final monthly = ref
        .watch(medicineCostProjectionProvider)
        .value
        ?.lines
        .where((l) => l.medicine.id == m.id)
        .firstOrNull
        ?.monthlyMinor;
    final doctor = item.doctor;

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        InfoBlock(
          label: context.l10n.medicineName,
          value: [m.name, ?m.strength].join(' '),
          large: true,
        ),
        if (m.notes != null)
          InfoBlock(label: context.l10n.medicineDescription, value: m.notes!),
        LabeledField(
          label: context.l10n.timeDuration,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _chip(duration, icon: Icons.date_range_rounded),
          ),
        ),
        MedicineTimesSection(medicine: m),
        InfoBlock(
          label: context.l10n.doses,
          value:
              '${ReminderText.doseSummary(reminders, m.doseUnit)}'
              '${context.l10n.notifDoseSeparator}${m.mealRelation.label}',
        ),
        if (doctor != null)
          LabeledField(
            label: context.l10n.medicineDoctor,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _chip(
                doctor.name,
                icon: Icons.person_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DoctorDetailScreen(doctorId: doctor.id),
                  ),
                ),
              ),
            ),
          ),
        if (m.stockQuantity != null)
          InfoBlock(
            label: item.isLowStock
                ? context.l10n.lowStock
                : context.l10n.inStock,
            value: '${AppNumber.format(m.stockQuantity!)} ${m.doseUnit}',
          ),
        if ((monthly ?? 0) > 0)
          InfoBlock(
            label: context.l10n.costPerMonth,
            value: Money.format(monthly!),
          ),
      ],
    );
  }
}
