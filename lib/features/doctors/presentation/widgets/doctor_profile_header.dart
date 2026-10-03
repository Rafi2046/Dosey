import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/status_chip.dart';
import 'contact_actions.dart';
import '../../../../core/localization/l10n.dart';

/// Avatar, name, specialty and Call / Email pills.
class DoctorProfileHeader extends StatelessWidget {
  const DoctorProfileHeader({super.key, required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Row(
        children: [
          InitialsAvatar(name: doctor.name, size: AppSpacing.avatarLg),
          AppSpacing.gapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: AppTextStyles.headlineOnLight),
                if (doctor.specialty != null)
                  Text(doctor.specialty!, style: AppTextStyles.bodyOnLight),
                AppSpacing.gapMd,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (doctor.phone != null)
                      StatusChip(
                        label: context.l10n.call,
                        icon: Icons.call_rounded,
                        onTap: () => ContactActions.call(doctor.phone!),
                      ),
                    if (doctor.email != null)
                      StatusChip(
                        label: context.l10n.email,
                        icon: Icons.mail_rounded,
                        background: AppColors.sand,
                        foreground: AppColors.ink,
                        onTap: () => ContactActions.email(doctor.email!),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
