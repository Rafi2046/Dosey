import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/reminder_text.dart';
import '../../domain/reminder_with_details.dart';
import '../../../../core/localization/l10n.dart';

/// Reminder row: type label, title, schedule, next ring time and an on/off
/// switch. Card color follows the design's rotating palette.
class ReminderTile extends StatelessWidget {
  const ReminderTile({
    super.key,
    required this.details,
    required this.color,
    required this.onTap,
    required this.onToggle,
  });

  final ReminderWithDetails details;
  final Color color;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final r = details.reminder;
    final light = SurfaceCard.isLight(color);
    final muted = light ? AppColors.inkMuted : AppColors.textOnDarkMuted;
    final next = r.nextTriggerAt;
    final status = !r.isEnabled
        ? context.l10n.paused
        : next == null
        ? context.l10n.ended
        : AppDateFormat.dateTime(next);

    return SurfaceCard(
      color: color,
      elevated: true,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(r.type.icon, size: AppSpacing.iconSm, color: muted),
                    AppSpacing.gapXs,
                    Text(
                      r.type.label(context.l10n),
                      style: AppTextStyles.overline.copyWith(color: muted),
                    ),
                  ],
                ),
                AppSpacing.gapSm,
                Text(
                  r.title,
                  style: light
                      ? AppTextStyles.cardTitleOnLight
                      : AppTextStyles.cardTitle,
                ),
                AppSpacing.gapXs,
                Text(
                  ReminderText.schedule(r),
                  style: AppTextStyles.caption.copyWith(color: muted),
                ),
                AppSpacing.gapMd,
                StatusChip(
                  label: status,
                  icon: r.isEnabled ? Icons.alarm_rounded : Icons.pause_rounded,
                  background: light ? AppColors.moss : AppColors.creamLight,
                  foreground: light ? AppColors.textOnDark : AppColors.ink,
                ),
              ],
            ),
          ),
          Switch(value: r.isEnabled, onChanged: onToggle),
        ],
      ),
    );
  }
}
