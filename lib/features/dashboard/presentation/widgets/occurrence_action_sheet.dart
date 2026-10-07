import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/notifications/reminder_alarm_engine.dart';
import '../../../../core/utils/clock_providers.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/utils/numbers.dart';
import '../../../../core/utils/pickers.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../medicines/domain/course_progress.dart';
import '../../../medicines/presentation/medicine_detail_screen.dart';
import '../../../reminders/domain/reminder_text.dart';
import '../../../reminders/domain/scheduled_occurrence.dart';
import '../../../reminders/presentation/reminder_form_screen.dart';
import '../../../reminders/providers/reminders_providers.dart';

/// Animated pop-up card showing compact reminder/medicine details, with direct
/// time modification, side-by-side quick actions (Taken / Skip), and
/// navigation to full medicine details.
Future<void> showOccurrenceActions(
  BuildContext context,
  ScheduledOccurrence occurrence, {
  Color? color,
}) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'Dismiss',
  barrierColor: Colors.black.withValues(alpha: 0.65),
  transitionDuration: const Duration(milliseconds: 280),
  pageBuilder: (context, anim1, anim2) =>
      _OccurrenceDetailPopup(occurrence: occurrence, color: color),
  transitionBuilder: (context, anim1, anim2, child) {
    final curve = CurvedAnimation(
      parent: anim1,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    return ScaleTransition(
      scale: Tween<double>(begin: 0.88, end: 1.0).animate(curve),
      child: FadeTransition(
        opacity: anim1,
        child: child,
      ),
    );
  },
);

class _OccurrenceDetailPopup extends ConsumerStatefulWidget {
  const _OccurrenceDetailPopup({required this.occurrence, this.color});

  final ScheduledOccurrence occurrence;
  final Color? color;

  @override
  ConsumerState<_OccurrenceDetailPopup> createState() =>
      _OccurrenceDetailPopupState();
}

class _OccurrenceDetailPopupState
    extends ConsumerState<_OccurrenceDetailPopup> {
  late DateTime _currentTime;
  bool _savingTime = false;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.occurrence.at;
  }

  Future<void> _act(AlarmAction action) async {
    final status = widget.occurrence.status;
    final now = ref.read(minuteTickerProvider).value ?? DateTime.now();
    final late =
        status == ReminderLogStatus.missed ||
        (!(status?.isTaken ?? false) &&
            now.difference(_currentTime) > AppConstants.missedThreshold);
    await ref.read(alarmEngineProvider).handleAction(
          reminderIds: [widget.occurrence.details.reminder.id],
          scheduledFor: _currentTime,
          action: action == AlarmAction.taken && late
              ? AlarmAction.takenLate
              : action,
        );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _edit() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ReminderFormScreen(existing: widget.occurrence.details.reminder),
      ),
    );
  }

  Future<void> _delete() async {
    final r = widget.occurrence.details.reminder;
    final l10n = context.l10n;
    if (!await confirmDelete(
      context,
      body: l10n.deleteThisTimeBody(AppDateFormat.time(r.startAt), r.title),
    )) {
      return;
    }
    await ref.read(alarmEngineProvider).cancel(r.id);
    await ref.read(remindersRepositoryProvider).delete(r.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _changeTime() async {
    final initial = TimeOfDay.fromDateTime(_currentTime);
    final picked = await AppPickers.time(context, initial: initial);
    if (picked == null ||
        (picked.hour == initial.hour && picked.minute == initial.minute)) {
      return;
    }

    setState(() => _savingTime = true);
    try {
      final r = widget.occurrence.details.reminder;
      final newStartAt = DateTime(
        r.startAt.year,
        r.startAt.month,
        r.startAt.day,
        picked.hour,
        picked.minute,
      );

      await ref.read(remindersRepositoryProvider).update(
            r.id,
            RemindersCompanion(startAt: drift.Value(newStartAt)),
          );

      if (mounted) {
        setState(() {
          _currentTime = DateTime(
            _currentTime.year,
            _currentTime.month,
            _currentTime.day,
            picked.hour,
            picked.minute,
          );
        });
        showAppSnack(context, context.l10n.saved);
      }
    } finally {
      if (mounted) setState(() => _savingTime = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.occurrence.details;
    final r = details.reminder;
    final med = details.medicine;
    final doc = details.doctor;
    final isMedicine = r.type == ReminderType.medicine;
    final status = widget.occurrence.status;
    final l10n = context.l10n;
    final now = ref.watch(minuteTickerProvider).value ?? DateTime.now();

    final slot = ReminderText.slotLabel(l10n, r, _currentTime);
    final dosage = ReminderText.body(l10n, details);

    final cardColor = widget.color ??
        (AppColors.isDark ? AppColors.olive : AppColors.cream);
    final isLight = SurfaceCard.isLight(cardColor);
    final textColor = isLight ? AppColors.ink : AppColors.textOnDark;
    final mutedColor =
        isLight ? AppColors.inkMuted : AppColors.textOnDarkMuted;

    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.shortestSide >= 600 || screenSize.width >= 600;

    final dialogWidth = isTablet
        ? (screenSize.width * 0.60).clamp(480.0, 560.0)
        : (screenSize.width - 32).clamp(330.0, 420.0);
    final maxDialogHeight = isTablet ? 780.0 : 680.0;

    final courseProgress = med != null ? CourseProgress.of(med, now) : null;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(
            maxWidth: isTablet ? 560 : 420,
            maxHeight: maxDialogHeight,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(
              isTablet ? AppSpacing.radiusXl + 6 : 26,
            ),
            border: Border.all(
              color: isLight
                  ? AppColors.divider.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.14),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppColors.isDark ? 0.55 : 0.28,
                ),
                blurRadius: isTablet ? 36 : 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              isTablet ? AppSpacing.radiusXl + 6 : 26,
            ),
            child: SingleChildScrollView(
              padding: isTablet
                  ? const EdgeInsets.fromLTRB(26, 24, 26, 22)
                  : const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Row: Avatar + Title + Slot + Close button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (med != null)
                        Container(
                          width: isTablet ? 52 : 46,
                          height: isTablet ? 52 : 46,
                          padding: EdgeInsets.all(isTablet ? 7 : 6),
                          decoration: BoxDecoration(
                            color: isLight
                                ? AppColors.creamLight
                                : Colors.white.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isLight
                                  ? AppColors.divider
                                  : Colors.white.withValues(alpha: 0.20),
                              width: 1,
                            ),
                          ),
                          child: Image.asset(med.form.image),
                        )
                      else
                        Container(
                          width: isTablet ? 48 : 44,
                          height: isTablet ? 48 : 44,
                          decoration: BoxDecoration(
                            color: isLight
                                ? AppColors.tileMint.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            r.type.icon,
                            color: isLight
                                ? AppColors.tileMint
                                : AppColors.textOnDark,
                            size: isTablet ? 24 : 20,
                          ),
                        ),
                      SizedBox(width: isTablet ? 14 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dosage.isNotEmpty
                                  ? '$slot • $dosage'
                                  : slot,
                              style: (isLight
                                      ? AppTextStyles.captionOnLight
                                      : AppTextStyles.caption)
                                  .copyWith(
                                fontSize: isTablet ? 13 : 11.5,
                                fontWeight: FontWeight.w600,
                                color: mutedColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r.title,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: isTablet ? 22 : 20,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: isLight
                            ? Colors.black.withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.12),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: EdgeInsets.all(isTablet ? 8 : 7),
                            child: Icon(
                              Icons.close_rounded,
                              size: isTablet ? 22 : 18,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isTablet ? 18 : 15),

                  // Hero Interactive Time Card (1-Tap Change Time)
                  Material(
                    color: isLight
                        ? AppColors.sand
                        : (AppColors.isDark
                            ? Colors.black.withValues(alpha: 0.22)
                            : Colors.white.withValues(alpha: 0.10)),
                    borderRadius: BorderRadius.circular(
                      isTablet ? AppSpacing.radiusLg : 18,
                    ),
                    child: InkWell(
                      onTap: _savingTime ? null : _changeTime,
                      borderRadius: BorderRadius.circular(
                        isTablet ? AppSpacing.radiusLg : 18,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            isTablet ? AppSpacing.radiusLg : 18,
                          ),
                          border: Border.all(
                            color: isLight
                                ? AppColors.divider.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16 : 14,
                          vertical: isTablet ? 14 : 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isTablet ? 9 : 8),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.access_time_filled_rounded,
                                color: AppColors.accent,
                                size: isTablet ? 22 : 18,
                              ),
                            ),
                            SizedBox(width: isTablet ? 14 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.scheduledTime,
                                    style: (isLight
                                            ? AppTextStyles.captionOnLight
                                            : AppTextStyles.caption)
                                        .copyWith(
                                      fontSize: isTablet ? 12 : 11,
                                      fontWeight: FontWeight.w600,
                                      color: mutedColor,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    AppDateFormat.time(_currentTime),
                                    style: TextStyle(
                                      fontFamily: 'NDot',
                                      fontSize: isTablet ? 23 : 20,
                                      fontWeight: FontWeight.w400,
                                      color: textColor,
                                      letterSpacing: 0.9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 14 : 11,
                                vertical: isTablet ? 8 : 6.5,
                              ),
                              decoration: BoxDecoration(
                                color: isLight
                                    ? AppColors.moss
                                    : (AppColors.isDark
                                        ? AppColors.selected
                                        : AppColors.moss),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _savingTime
                                      ? SizedBox(
                                          width: isTablet ? 13 : 11,
                                          height: isTablet ? 13 : 11,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isLight
                                                ? Colors.white
                                                : (AppColors.isDark
                                                    ? AppColors.onSelected
                                                    : Colors.white),
                                          ),
                                        )
                                      : Icon(
                                          Icons.edit_rounded,
                                          size: isTablet ? 15 : 13,
                                          color: isLight
                                              ? Colors.white
                                              : (AppColors.isDark
                                                  ? AppColors.onSelected
                                                  : Colors.white),
                                        ),
                                  SizedBox(width: isTablet ? 6 : 4),
                                  Text(
                                    l10n.changeTime,
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      color: isLight
                                          ? Colors.white
                                          : (AppColors.isDark
                                              ? AppColors.onSelected
                                              : Colors.white),
                                      fontSize: isTablet ? 13 : 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Full-Width Course Progress Bar (When Course Exists)
                  if (courseProgress != null) ...[
                    SizedBox(height: isTablet ? 14 : 11),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 14,
                        vertical: isTablet ? 12 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: isLight
                            ? AppColors.sand.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isLight
                              ? AppColors.divider.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.10),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              SizedBox.square(
                                dimension: isTablet ? 17 : 15,
                                child: CircularProgressIndicator(
                                  value: courseProgress.fraction,
                                  strokeWidth: 2.5,
                                  color: isLight
                                      ? AppColors.moss
                                      : AppColors.tileMint,
                                  backgroundColor: (isLight
                                          ? AppColors.moss
                                          : AppColors.tileMint)
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              SizedBox(width: isTablet ? 10 : 8),
                              Text(
                                courseProgress.isComplete
                                    ? l10n.courseComplete
                                    : courseProgress.notStarted
                                        ? l10n.courseStarts(
                                            AppDateFormat.shortDate(
                                              med!.startDate,
                                            ),
                                          )
                                        : l10n.courseDayOf(
                                            courseProgress.day,
                                            courseProgress.totalDays,
                                          ),
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: isTablet ? 13.5 : 12,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const Spacer(),
                              if (!courseProgress.isComplete &&
                                  !courseProgress.notStarted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLight
                                        ? AppColors.creamLight
                                        : Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusPill,
                                    ),
                                  ),
                                  child: Text(
                                    l10n.courseDaysLeft(
                                      courseProgress.daysLeft,
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: isTablet ? 12 : 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: isLight
                                          ? AppColors.inkMuted
                                          : AppColors.textOnDarkMuted,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: courseProgress.fraction,
                              minHeight: 4.5,
                              color: isLight
                                  ? AppColors.moss
                                  : AppColors.tileMint,
                              backgroundColor: isLight
                                  ? AppColors.divider.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Secondary Metadata Badges (Stock / Doctor / Status)
                  if ((med != null && med.stockQuantity != null) ||
                      doc != null ||
                      status != null) ...[
                    SizedBox(height: isTablet ? 12 : 10),
                    Wrap(
                      spacing: isTablet ? 8 : 6,
                      runSpacing: isTablet ? 8 : 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (med != null && med.stockQuantity != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 11 : 9,
                              vertical: isTablet ? 6 : 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? AppColors.sand.withValues(alpha: 0.7)
                                  : Colors.white.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                              border: Border.all(
                                color: isLight
                                    ? AppColors.divider.withValues(alpha: 0.4)
                                    : Colors.white.withValues(alpha: 0.10),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_rounded,
                                  size: isTablet ? 14 : 12,
                                  color: mutedColor,
                                ),
                                SizedBox(width: isTablet ? 4 : 3),
                                Text(
                                  l10n.unitsLeft(
                                    AppNumber.format(med.stockQuantity!),
                                  ),
                                  style: (isLight
                                          ? AppTextStyles.captionOnLight
                                          : AppTextStyles.caption)
                                      .copyWith(
                                    fontSize: isTablet ? 12.5 : 11,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (doc != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 11 : 9,
                              vertical: isTablet ? 6 : 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? AppColors.sand.withValues(alpha: 0.7)
                                  : Colors.white.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                              border: Border.all(
                                color: isLight
                                    ? AppColors.divider.withValues(alpha: 0.4)
                                    : Colors.white.withValues(alpha: 0.10),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.medical_services_rounded,
                                  size: isTablet ? 14 : 12,
                                  color: isLight
                                      ? AppColors.tileMint
                                      : AppColors.mint,
                                ),
                                SizedBox(width: isTablet ? 4 : 3),
                                Text(
                                  doc.name,
                                  style: (isLight
                                          ? AppTextStyles.captionOnLight
                                          : AppTextStyles.caption)
                                      .copyWith(
                                    fontSize: isTablet ? 12.5 : 11,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (status != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 11 : 9,
                              vertical: isTablet ? 6 : 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? AppColors.sand
                                  : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                            ),
                            child: Text(
                              status.label(l10n),
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: isTablet ? 12.5 : 11,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],

                  SizedBox(height: isTablet ? 18 : 14),

                  // Side-by-Side Action Buttons (Taken / Skip)
                  Row(
                    children: [
                      Expanded(
                        child: _PopupActionButton(
                          label: isMedicine
                              ? l10n.alarmMarkTaken
                              : l10n.alarmDone,
                          icon: Icons.check_rounded,
                          height: isTablet ? 54 : 48,
                          fontSize: isTablet ? 15 : 13.5,
                          iconSize: isTablet ? 20 : 17,
                          backgroundColor: isLight
                              ? AppColors.moss
                              : (AppColors.isDark
                                  ? AppColors.selected
                                  : AppColors.moss),
                          foregroundColor: isLight
                              ? AppColors.textOnDark
                              : (AppColors.isDark
                                  ? AppColors.onSelected
                                  : AppColors.textOnDark),
                          onPressed: () => _act(AlarmAction.taken),
                        ),
                      ),
                      SizedBox(width: isTablet ? 12 : 9),
                      Expanded(
                        child: _PopupActionButton(
                          label: l10n.skipDose,
                          icon: Icons.redo_rounded,
                          height: isTablet ? 54 : 48,
                          fontSize: isTablet ? 15 : 13.5,
                          iconSize: isTablet ? 20 : 17,
                          backgroundColor: isLight
                              ? AppColors.sand
                              : Colors.white.withValues(alpha: 0.10),
                          foregroundColor: textColor,
                          borderColor: isLight
                              ? AppColors.divider
                              : Colors.white.withValues(alpha: 0.18),
                          onPressed: () => _act(AlarmAction.skip),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isTablet ? 14 : 10),

                  // Divider Line for Utilities
                  Divider(
                    color: isLight
                        ? AppColors.divider.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.12),
                    height: 1,
                    thickness: 1,
                  ),

                  SizedBox(height: isTablet ? 10 : 6),

                  // Bottom Utilities: Full Edit & Delete
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: Icon(
                          Icons.tune_rounded,
                          size: isTablet ? 17 : 15,
                        ),
                        label: Text(
                          l10n.editReminder,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: isTablet ? 13.5 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: mutedColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 6,
                            vertical: isTablet ? 6 : 4,
                          ),
                          visualDensity: VisualDensity.compact,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _edit,
                      ),
                      TextButton.icon(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: isTablet ? 17 : 15,
                        ),
                        label: Text(
                          l10n.deleteThisTime,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: isTablet ? 13.5 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 6,
                            vertical: isTablet ? 6 : 4,
                          ),
                          visualDensity: VisualDensity.compact,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _delete,
                      ),
                    ],
                  ),

                  // Medicine Details Full-Width Action Card
                  if (med != null) ...[
                    SizedBox(height: isTablet ? 10 : 8),
                    Material(
                      color: isLight
                          ? AppColors.creamLight
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  MedicineDetailScreen(medicineId: med.id),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isLight
                                  ? AppColors.divider.withValues(alpha: 0.6)
                                  : Colors.white.withValues(alpha: 0.12),
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 14 : 12,
                            vertical: isTablet ? 10 : 8.5,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.medication_outlined,
                                size: isTablet ? 18 : 16,
                                color: isLight
                                    ? AppColors.tileMint
                                    : (AppColors.isDark
                                        ? AppColors.selected
                                        : AppColors.mint),
                              ),
                              SizedBox(width: isTablet ? 10 : 8),
                              Expanded(
                                child: Text(
                                  l10n.viewMedicineDetails,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: isTablet ? 13 : 12,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: isTablet ? 13 : 11,
                                color: mutedColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopupActionButton extends StatelessWidget {
  const _PopupActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.borderColor,
    this.height = 48,
    this.fontSize = 13.5,
    this.iconSize = 17,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final Color? borderColor;
  final double height;
  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: StadiumBorder(
        side: borderColor != null
            ? BorderSide(color: borderColor!, width: 1)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: foregroundColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  icon,
                  size: iconSize,
                  color: foregroundColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

