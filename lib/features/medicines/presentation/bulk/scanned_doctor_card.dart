import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/widgets/switch_row.dart';
import '../../domain/scanned_doctor.dart';

/// The doctor read off the prescription header. Either says they match a
/// saved doctor, or offers to save them (when no doctor is picked yet).
class ScannedDoctorCard extends StatelessWidget {
  const ScannedDoctorCard({
    super.key,
    required this.doctor,
    required this.matchesSaved,
    required this.save,
    required this.onSaveChanged,
  });

  final ScannedDoctor doctor;
  final bool matchesSaved;

  /// Current "Save this doctor" value; null hides the switch (another
  /// doctor was picked, so there's nothing to save).
  final bool? save;
  final ValueChanged<bool> onSaveChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final details = [
      doctor.degrees,
      if (doctor.specialty case final s?) s.label(l),
      doctor.clinic,
      doctor.phone,
    ].whereType<String>().where((s) => s.isNotEmpty);

    final showSwitch = !matchesSaved && save != null;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      // SwitchRow brings its own space below.
      padding: showSwitch
          ? AppSpacing.cardPaddingLg.copyWith(bottom: 0)
          : AppSpacing.cardPaddingLg,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.sand, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.scanDoctorTitle, style: AppTextStyles.labelOnLight),
          AppSpacing.gapSm,
          Row(
            children: [
              Icon(
                Icons.medical_services_rounded,
                size: AppSpacing.iconMd,
                color: AppColors.ink,
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Text(doctor.name, style: AppTextStyles.cardTitleOnLight),
              ),
            ],
          ),
          for (final d in details) ...[
            AppSpacing.gapXs,
            Text(d, style: AppTextStyles.captionOnLight),
          ],
          AppSpacing.gapMd,
          if (matchesSaved)
            Text(l.scanDoctorLinked, style: AppTextStyles.bodyOnLight)
          else if (save case final value?)
            SwitchRow(
              title: l.scanDoctorSave,
              subtitle: l.scanDoctorSaveHint,
              value: value,
              onChanged: onSaveChanged,
            ),
        ],
      ),
    );
  }
}
