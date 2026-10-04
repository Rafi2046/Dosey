import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/specialty.dart';
import 'contact_actions.dart';

/// Unified premium profile card showing avatar, name, specialty, quick action
/// chips, and detailed clinic/address/phone/fee rows with soft drop shadow.
class DoctorProfileCard extends StatelessWidget {
  const DoctorProfileCard({super.key, required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final details = <_InfoItem>[
      if (doctor.clinic case final c?)
        _InfoItem(
          icon: Icons.local_hospital_rounded,
          label: l10n.doctorClinic,
          value: c,
        ),
      if (doctor.address case final a?)
        _InfoItem(
          icon: Icons.location_on_rounded,
          label: l10n.doctorAddress,
          value: a,
        ),
      if (doctor.phone case final p?)
        _InfoItem(
          icon: Icons.phone_rounded,
          label: l10n.doctorPhone,
          value: p,
          onTap: () => ContactActions.call(p),
        ),
      if (doctor.email case final e?)
        _InfoItem(
          icon: Icons.mail_rounded,
          label: l10n.doctorEmail,
          value: e,
          onTap: () => ContactActions.email(e),
        ),
      if (doctor.consultationFeeMinor case final fee?)
        _InfoItem(
          icon: Icons.payments_rounded,
          label: l10n.doctorFee,
          value: Money.format(fee),
        ),
      if (doctor.notes case final n?)
        _InfoItem(icon: Icons.notes_rounded, label: l10n.doctorNotes, value: n),
    ];

    return SurfaceCard(
      color: AppColors.creamLight,
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialsAvatar(name: doctor.name, size: AppSpacing.avatarLg),
              AppSpacing.gapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name, style: AppTextStyles.titleOnLight),
                    if (doctor.specialty != null) ...[
                      AppSpacing.gapXs,
                      Text(
                        Specialty.display(doctor.specialty!, l10n),
                        style: AppTextStyles.bodyOnLight,
                      ),
                    ],
                    if (doctor.phone != null || doctor.email != null) ...[
                      AppSpacing.gapMd,
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          if (doctor.phone != null)
                            StatusChip(
                              label: l10n.call,
                              icon: Icons.call_rounded,
                              onTap: () => ContactActions.call(doctor.phone!),
                            ),
                          if (doctor.email != null)
                            StatusChip(
                              label: l10n.email,
                              icon: Icons.mail_rounded,
                              background: AppColors.sand,
                              foreground: AppColors.ink,
                              onTap: () => ContactActions.email(doctor.email!),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            AppSpacing.gapLg,
            Divider(
              height: AppSpacing.borderThin,
              thickness: AppSpacing.borderThin,
              color: AppColors.divider,
            ),
            AppSpacing.gapLg,
            for (final (index, item) in details.indexed) ...[
              if (index > 0) AppSpacing.gapMd,
              _buildDetailRow(item),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(_InfoItem item) {
    // Icon and arrow centred on the label + value (top-aligned, the arrow
    // sat level with the label instead).
    final content = Row(
      children: [
        Container(
          width: AppSpacing.settingsIcon,
          height: AppSpacing.settingsIcon,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.sand,
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, size: AppSpacing.iconSm, color: AppColors.ink),
        ),
        AppSpacing.gapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label.toUpperCase(), style: AppTextStyles.labelOnLight),
              AppSpacing.gapXs,
              Text(
                item.value,
                style: AppTextStyles.body.copyWith(
                  color: item.onTap != null ? AppColors.accent : AppColors.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (item.onTap != null) ...[
          AppSpacing.gapSm,
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: AppSpacing.iconSm * 0.75,
            color: AppColors.inkMuted,
          ),
        ],
      ],
    );

    if (item.onTap != null) {
      return InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: content,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: content,
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
}

/// Backwards compatibility alias for [DoctorProfileCard].
typedef DoctorProfileHeader = DoctorProfileCard;
