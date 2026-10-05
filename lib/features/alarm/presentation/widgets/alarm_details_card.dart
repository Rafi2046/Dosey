import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../medicines/presentation/widgets/course_progress_pill.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/domain/reminder_with_details.dart';
import '../../../../core/localization/l10n.dart';
import '../../../profiles/presentation/profile_widgets.dart';
import 'alarm_dose_context.dart';

/// Cream card with what to do: type label, title, dose/details, and time.
/// For a medicine, also a warning when an earlier dose was missed (above
/// the name) and how far into its course this dose is (under the dose).
class AlarmDetailsCard extends ConsumerWidget {
  const AlarmDetailsCard({
    super.key,
    required this.details,
    required this.scheduledFor,
  });

  final ReminderWithDetails details;
  final DateTime scheduledFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = details.reminder;
    final medicine = details.medicine;
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
                reminder.type.label(context.l10n),
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
              const Spacer(),
              StatusChip(label: AppDateFormat.time(scheduledFor)),
            ],
          ),
          AppSpacing.gapMd,
          // Whose dose, when it's a family member's.
          if (familyMemberName(context.l10n, details.profile)
              case final name?) ...[
            ForProfileLabel(name),
            AppSpacing.gapSm,
          ],
          if (PreviousMissedChip.appliesTo(ref, details, scheduledFor)) ...[
            PreviousMissedChip(details: details, scheduledFor: scheduledFor),
            AppSpacing.gapSm,
          ],
          Text(reminder.title, style: AppTextStyles.displayOnLight),
          AppSpacing.gapSm,
          Text(
            ReminderText.body(context.l10n, details),
            style: AppTextStyles.bodyOnLight,
          ),
          if (medicine != null && medicine.endDate != null) ...[
            AppSpacing.gapMd,
            CourseProgressPill(
              medicine: medicine,
              // The course day of the dose ringing, not the wall clock.
              today: DateUtils.dateOnly(scheduledFor),
              onLight: true,
              muted: true,
            ),
          ],
        ],
      ),
    );
  }
}
