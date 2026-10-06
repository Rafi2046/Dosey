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
import '../../../medicines/presentation/medicine_detail_screen.dart';
import '../../../medicines/presentation/widgets/course_progress_pill.dart';
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

  void _edit() {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
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
        ? (screenSize.width * 0.62).clamp(480.0, 560.0)
        : screenSize.width * 0.90;
    final maxDialogHeight = isTablet ? 740.0 : 620.0;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(
            maxWidth: isTablet ? 560 : 380,
            maxHeight: maxDialogHeight,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(
              isTablet ? AppSpacing.radiusXl + 4 : AppSpacing.radiusXl,
            ),
            border: Border.all(
              color: isLight
                  ? AppColors.divider
                  : Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppColors.isDark ? 0.55 : 0.35,
                ),
                blurRadius: isTablet ? 36 : 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              isTablet ? AppSpacing.radiusXl + 4 : AppSpacing.radiusXl,
            ),
            child: SingleChildScrollView(
              padding: isTablet
                  ? const EdgeInsets.fromLTRB(26, 22, 26, 22)
                  : const EdgeInsets.fromLTRB(18, 16, 18, 16),
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
                          width: isTablet ? 52 : 42,
                          height: isTablet ? 52 : 42,
                          padding: EdgeInsets.all(isTablet ? 7 : 5),
                          decoration: BoxDecoration(
                            color: isLight
                                ? AppColors.creamLight
                                : Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isLight
                                  ? AppColors.divider
                                  : Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Image.asset(med.form.image),
                        )
                      else
                        Container(
                          width: isTablet ? 48 : 40,
                          height: isTablet ? 48 : 40,
                          decoration: BoxDecoration(
                            color: isLight
                                ? AppColors.tileMint.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.15),
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
                      SizedBox(width: isTablet ? 14 : 10),
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
                                fontSize: isTablet ? 13 : 11,
                                fontWeight: FontWeight.w600,
                                color: mutedColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              r.title,
                              style: (isLight
                                      ? AppTextStyles.headlineOnLight
                                      : AppTextStyles.headline)
                                  .copyWith(
                                fontSize: isTablet ? 22 : 18.5,
                                fontWeight: FontWeight.w800,
                                color: textColor,
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
                            padding: EdgeInsets.all(isTablet ? 8 : 6),
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

                  SizedBox(height: isTablet ? 16 : 12),

                  // Hero Interactive Time Card (1-Tap Change Time)
                  Material(
                    color: isLight
                        ? AppColors.sand
                        : (AppColors.isDark
                            ? AppColors.creamLight.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.22)),
                    borderRadius: BorderRadius.circular(
                      isTablet ? AppSpacing.radiusLg : AppSpacing.radiusMd,
                    ),
                    child: InkWell(
                      onTap: _savingTime ? null : _changeTime,
                      borderRadius: BorderRadius.circular(
                        isTablet ? AppSpacing.radiusLg : AppSpacing.radiusMd,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            isTablet ? AppSpacing.radiusLg : AppSpacing.radiusMd,
                          ),
                          border: Border.all(
                            color: isLight
                                ? AppColors.divider.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.12),
                            width: 0.8,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16 : 12,
                          vertical: isTablet ? 14 : 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isTablet ? 9 : 7),
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
                            SizedBox(width: isTablet ? 14 : 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'নির্ধারিত সময়',
                                    style: (isLight
                                            ? AppTextStyles.captionOnLight
                                            : AppTextStyles.caption)
                                        .copyWith(
                                      fontSize: isTablet ? 12 : 10.5,
                                      color: mutedColor,
                                    ),
                                  ),
                                  Text(
                                    AppDateFormat.time(_currentTime),
                                    style: (isLight
                                            ? AppTextStyles.cardTitleOnLight
                                            : AppTextStyles.cardTitle)
                                        .copyWith(
                                      fontSize: isTablet ? 19 : 16.5,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 13 : 9,
                                vertical: isTablet ? 7 : 5,
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
                                          size: isTablet ? 15 : 12,
                                          color: isLight
                                              ? Colors.white
                                              : (AppColors.isDark
                                                  ? AppColors.onSelected
                                                  : Colors.white),
                                        ),
                                  SizedBox(width: isTablet ? 6 : 4),
                                  Text(
                                    'পরিবর্তন',
                                    style: TextStyle(
                                      color: isLight
                                          ? Colors.white
                                          : (AppColors.isDark
                                              ? AppColors.onSelected
                                              : Colors.white),
                                      fontSize: isTablet ? 13 : 11,
                                      fontWeight: FontWeight.bold,
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

                  // Metadata Badges (Course / Stock / Doctor / Status)
                  if (med != null || doc != null || status != null) ...[
                    SizedBox(height: isTablet ? 14 : 10),
                    Wrap(
                      spacing: isTablet ? 8 : 6,
                      runSpacing: isTablet ? 8 : 6,
                      children: [
                        if (med != null && med.endDate != null)
                          CourseProgressPill(
                            medicine: med,
                            today: DateUtils.dateOnly(now),
                            onLight: isLight,
                            compact: true,
                          ),
                        if (med != null && med.stockQuantity != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 11 : 8,
                              vertical: isTablet ? 6 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? AppColors.creamLight
                                  : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                              border: Border.all(
                                color: isLight
                                    ? AppColors.divider
                                    : Colors.white.withValues(alpha: 0.15),
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
                              horizontal: isTablet ? 11 : 8,
                              vertical: isTablet ? 6 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? AppColors.creamLight
                                  : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                              border: Border.all(
                                color: isLight
                                    ? AppColors.divider
                                    : Colors.white.withValues(alpha: 0.15),
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
                              horizontal: isTablet ? 11 : 8,
                              vertical: isTablet ? 6 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? AppColors.sand
                                  : Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                            ),
                            child: Text(
                              status.label(l10n),
                              style: TextStyle(
                                fontFamily: 'DMSans',
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
                        flex: 11,
                        child: _PopupActionButton(
                          label: isMedicine
                              ? l10n.alarmMarkTaken
                              : l10n.alarmDone,
                          icon: Icons.check_rounded,
                          height: isTablet ? 52 : 42,
                          fontSize: isTablet ? 15.5 : 13.5,
                          iconSize: isTablet ? 19 : 16,
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
                      SizedBox(width: isTablet ? 12 : 8),
                      Expanded(
                        flex: 9,
                        child: _PopupActionButton(
                          label: l10n.skipDose,
                          icon: Icons.redo_rounded,
                          height: isTablet ? 52 : 42,
                          fontSize: isTablet ? 15.5 : 13.5,
                          iconSize: isTablet ? 19 : 16,
                          backgroundColor: isLight
                              ? AppColors.creamLight
                              : Colors.white.withValues(alpha: 0.12),
                          foregroundColor: textColor,
                          borderColor: isLight
                              ? AppColors.divider
                              : Colors.white.withValues(alpha: 0.2),
                          onPressed: () => _act(AlarmAction.skip),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isTablet ? 10 : 6),

                  // Bottom Utilities: Full Edit, Delete & Medicine details link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: Icon(
                          Icons.tune_rounded,
                          size: isTablet ? 16 : 14,
                        ),
                        label: Text(
                          l10n.editReminder,
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: mutedColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 6,
                            vertical: isTablet ? 4 : 2,
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
                          size: isTablet ? 16 : 14,
                        ),
                        label: Text(
                          l10n.deleteThisTime,
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 6,
                            vertical: isTablet ? 4 : 2,
                          ),
                          visualDensity: VisualDensity.compact,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _delete,
                      ),
                    ],
                  ),

                  if (med != null) ...[
                    SizedBox(height: isTablet ? 4 : 2),
                    Center(
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          size: isTablet ? 16 : 14,
                          color: isLight
                              ? AppColors.tileMint
                              : (AppColors.isDark
                                  ? AppColors.selected
                                  : AppColors.textOnDark),
                        ),
                        label: Text(
                          'ওষুধের সম্পূর্ণ বিবরণ দেখুন',
                          style: TextStyle(
                            color: isLight
                                ? AppColors.tileMint
                                : (AppColors.isDark
                                    ? AppColors.selected
                                    : AppColors.textOnDark),
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 12 : 8,
                            vertical: isTablet ? 4 : 2,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  MedicineDetailScreen(medicineId: med.id),
                            ),
                          );
                        },
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
    this.height = 42,
    this.fontSize = 13.5,
    this.iconSize = 16,
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
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: foregroundColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
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

