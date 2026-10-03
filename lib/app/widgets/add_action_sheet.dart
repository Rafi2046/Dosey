import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/widgets/surface_card.dart';
import '../../features/doctors/presentation/doctor_form_screen.dart';
import '../../features/expenses/presentation/expense_form_screen.dart';
import '../../features/medicines/presentation/medicine_type_screen.dart';
import '../../features/records/presentation/record_form_screen.dart';
import '../../features/reminders/presentation/reminder_form_screen.dart';
import '../debug/debug_demo_data_button.dart';
import '../debug/debug_test_alarm_button.dart';
import '../../core/localization/l10n.dart';

/// "+" menu: create anything from anywhere.
Future<void> showAddActionSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddActionSheet(),
    );

class _AddActionSheet extends StatelessWidget {
  const _AddActionSheet();

  static List<(IconData, String, Widget Function())> _actions(
    AppLocalizations l,
  ) => [
    (Icons.alarm_add_rounded, l.addReminder, ReminderFormScreen.new),
    (Icons.medication_rounded, l.addMedicine, MedicineTypeScreen.new),
    (Icons.person_add_alt_1_rounded, l.addDoctor, DoctorFormScreen.new),
    (Icons.add_a_photo_rounded, l.addRecord, RecordFormScreen.new),
    (Icons.payments_rounded, l.addExpense, ExpenseFormScreen.new),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.addSheetTitle, style: AppTextStyles.titleOnLight),
            AppSpacing.gapLg,
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: AppSpacing.addTileAspect,
              children: [
                for (final (i, (icon, label, builder)) in _actions(
                  context.l10n,
                ).indexed)
                  _AddTile(
                    icon: icon,
                    label: label,
                    color:
                        AppColors.cardCycleOnLight[i %
                            AppColors.cardCycleOnLight.length],
                    onTap: () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      navigator.push(
                        MaterialPageRoute<void>(builder: (_) => builder()),
                      );
                    },
                  ),
              ],
            ),
            if (kDebugMode) ...[
              AppSpacing.gapLg,
              const DebugTestAlarmButton(),
              AppSpacing.gapSm,
              const DebugDemoDataButton(),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = SurfaceCard.foregroundFor(color);
    return SurfaceCard(
      color: color,
      padding: AppSpacing.cardPadding,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: fg),
          Text(label, style: AppTextStyles.chip.copyWith(color: fg)),
        ],
      ),
    );
  }
}
