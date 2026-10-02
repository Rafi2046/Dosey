import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/domain/reminder_with_details.dart';

/// Cream card with what to do: type label, title, dose/details, and time.
class AlarmDetailsCard extends StatelessWidget {
  const AlarmDetailsCard({
    super.key,
    required this.details,
    required this.scheduledFor,
  });

  final ReminderWithDetails details;
  final DateTime scheduledFor;

  @override
  Widget build(BuildContext context) {
    final reminder = details.reminder;
    return SurfaceCard(
      color: AppColors.cream,
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                reminder.type.icon,
                size: AppSpacing.iconSm,
                color: AppColors.inkMuted,
              ),
              AppSpacing.gapXs,
              Text(
                reminder.type.label,
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
              const Spacer(),
              StatusChip(label: AppDateFormat.time(scheduledFor)),
            ],
          ),
          AppSpacing.gapMd,
          Text(reminder.title, style: AppTextStyles.displayOnLight),
          AppSpacing.gapSm,
          Text(ReminderText.body(details), style: AppTextStyles.bodyOnLight),
        ],
      ),
    );
  }
}
