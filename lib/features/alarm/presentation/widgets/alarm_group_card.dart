import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/domain/reminder_with_details.dart';
import 'alarm_dose_context.dart';

/// Cream card for several medicines due at the same minute: how many, the
/// time, then each medicine with that time's dose, course progress and any
/// earlier missed dose.
class AlarmGroupCard extends StatelessWidget {
  const AlarmGroupCard({
    super.key,
    required this.group,
    required this.scheduledFor,
  });

  final List<ReminderWithDetails> group;
  final DateTime scheduledFor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = group.first.reminder.type;
    return SurfaceCard(
      color: AppColors.cream,
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                type.icon,
                size: AppSpacing.iconSm,
                color: AppColors.inkMuted,
              ),
              AppSpacing.gapXs,
              Text(
                type.label(l10n),
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
              const Spacer(),
              StatusChip(label: AppDateFormat.time(scheduledFor)),
            ],
          ),
          AppSpacing.gapMd,
          Text(
            l10n.alarmGroupCount(group.length),
            style: AppTextStyles.headlineOnLight,
          ),
          for (final (i, d) in group.indexed) ...[
            if (i > 0)
              Divider(
                height: AppSpacing.lg,
                thickness: AppSpacing.borderThin,
                color: AppColors.divider,
              )
            else
              AppSpacing.gapMd,
            Text(d.reminder.title, style: AppTextStyles.cardTitleOnLight),
            Text(ReminderText.body(l10n, d), style: AppTextStyles.bodyOnLight),
            AlarmDoseContext(details: d, scheduledFor: scheduledFor),
          ],
        ],
      ),
    );
  }
}
