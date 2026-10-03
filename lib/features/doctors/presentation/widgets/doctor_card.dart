import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/doctor_with_stats.dart';
import 'contact_actions.dart';
import '../../../../core/localization/l10n.dart';
import '../../domain/specialty.dart';

/// Doctor summary: initials avatar, name, specialty, clinic, active
/// medicine count and a one-tap call button.
class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.item,
    required this.color,
    required this.onTap,
  });

  final DoctorWithStats item;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = item.doctor;
    final light = SurfaceCard.isLight(color);
    final muted = light ? AppColors.inkMuted : AppColors.textOnDarkMuted;
    final subtitle = [
      if (d.specialty case final s?) Specialty.display(s, context.l10n),
      ?d.clinic,
    ].join(context.l10n.notifDoseSeparator);

    return SurfaceCard(
      color: color,
      elevated: true,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialsAvatar(name: d.name),
          AppSpacing.gapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.name,
                  style: light
                      ? AppTextStyles.cardTitleOnLight
                      : AppTextStyles.cardTitle,
                ),
                if (subtitle.isNotEmpty) ...[
                  AppSpacing.gapXs,
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(color: muted),
                  ),
                ],
                AppSpacing.gapSm,
                StatusChip(
                  label: context.l10n.activeMedicines(item.activeMedicineCount),
                  icon: Icons.medication_rounded,
                  background: light ? AppColors.moss : AppColors.creamLight,
                  foreground: light ? AppColors.textOnDark : AppColors.ink,
                ),
              ],
            ),
          ),
          if (d.phone != null)
            IconButton(
              tooltip: context.l10n.call,
              icon: Icon(Icons.call_rounded, color: muted),
              onPressed: () => ContactActions.call(d.phone!),
            ),
        ],
      ),
    );
  }
}
