import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utils/clock_providers.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/utils/numbers.dart';
import '../../../core/utils/share_providers.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/pill_button.dart';
import '../../blood_pressure/domain/bp_category.dart';
import '../../blood_pressure/providers/blood_pressure_providers.dart';
import '../../blood_sugar/domain/sugar_category.dart';
import '../../blood_sugar/presentation/widgets/sugar_value_text.dart';
import '../../blood_sugar/providers/blood_sugar_providers.dart';
import '../../medicines/domain/course_progress.dart';
import '../../medicines/presentation/widgets/course_progress_pill.dart';
import '../../medicines/providers/medicines_providers.dart';
import '../../reminders/domain/dose_history.dart';
import '../../reminders/domain/reminder_text.dart';
import '../../reminders/providers/reminders_providers.dart';
import '../../settings/providers/settings_providers.dart';

/// A one-page health summary to show a doctor: current medicines, doses
/// taken over the last [days], and blood pressure and sugar. Shown as a
/// paper-like page and shared as an image, which keeps Bengali text exactly
/// as on screen.
class DoctorReportScreen extends ConsumerStatefulWidget {
  const DoctorReportScreen({super.key});

  /// Period the report covers.
  static const int days = 30;

  @override
  ConsumerState<DoctorReportScreen> createState() => _DoctorReportScreenState();
}

class _DoctorReportScreenState extends ConsumerState<DoctorReportScreen> {
  final _paper = GlobalKey();
  bool _sharing = false;

  /// Renders the page to a PNG (at 3× for sharp text) and shares it.
  Future<void> _share() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sharing = true);
    try {
      final boundary =
          _paper.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory.systemTemp.createTempSync('dosey_report');
      final file = File(
        p.join(
          dir.path,
          'Dosey-report-${AppDateFormat.date(DateTime.now()).replaceAll(' ', '-')}.png',
        ),
      )..writeAsBytesSync(png!.buffer.asUint8List(), flush: true);
      await ref.read(fileSharerProvider)(file, l10n.reportTitle);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.reportShareFailed)));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sage,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: AppSpacing.screenPadding.copyWith(
                  bottom: AppSpacing.xl,
                ),
                children: [
                  ScreenHeader(title: context.l10n.reportHeader),
                  RepaintBoundary(key: _paper, child: const _ReportPaper()),
                ],
              ),
            ),
            Padding(
              padding: AppSpacing.bottomBarPadding,
              child: PillButton(
                label: context.l10n.reportShare,
                trailingIcon: Icons.ios_share_rounded,
                loading: _sharing,
                onPressed: _share,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The page itself, always in the light palette: it's a document, and the
/// shared image should read like paper whatever the app's theme.
class _ReportPaper extends ConsumerWidget {
  const _ReportPaper();

  static const _paper = AppPalette.light;

  static TextStyle _ink(TextStyle s) => s.copyWith(color: _paper.ink);
  static TextStyle _muted(TextStyle s) => s.copyWith(color: _paper.inkMuted);

  /// "128/84 mmHg", the mean of [readings] (rounded).
  static String _bpAverage(
    AppLocalizations l10n,
    List<BloodPressureReading> readings,
  ) {
    int mean(int Function(BloodPressureReading) f) =>
        (readings.map(f).reduce((a, b) => a + b) / readings.length).round();
    return '${l10n.bpValue(AppNumber.format(mean((r) => r.systolic)), AppNumber.format(mean((r) => r.diastolic)))} '
        '${AppConstants.bpUnit}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final today =
        ref.watch(currentDayProvider).value ??
        DateUtils.dateOnly(DateTime.now());
    final from = today.subtract(
      const Duration(days: DoctorReportScreen.days - 1),
    );
    final name = ref.watch(userNameProvider).value;
    final medicines = ref.watch(activeMedicinesProvider).value ?? const [];
    final reminders = [
      for (final d in ref.watch(enabledRemindersProvider).value ?? const [])
        d.reminder,
    ];
    final history = ref
        .watch(
          doseHistoryProvider((
            days: DoctorReportScreen.days,
            medicineId: null,
          )),
        )
        .value;
    bool inPeriod(DateTime at) => !at.isBefore(from);
    final bp = <BloodPressureReading>[
      for (final r
          in ref.watch(bloodPressureReadingsProvider).value ?? const [])
        if (inPeriod(r.measuredAt)) r,
    ];
    final sugar = <BloodSugarReading>[
      for (final r in ref.watch(bloodSugarReadingsProvider).value ?? const [])
        if (inPeriod(r.measuredAt)) r,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _paper.creamLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: AppSpacing.cardPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appName.toUpperCase(),
              style: AppTextStyles.overline.copyWith(color: AppColors.accent),
            ),
            AppSpacing.gapXs,
            Text(l10n.reportTitle, style: _ink(AppTextStyles.headline)),
            if (name != null && name.isNotEmpty)
              Text(name, style: _ink(AppTextStyles.subtitle)),
            AppSpacing.gapXs,
            Text(
              l10n.reportPeriod(
                AppDateFormat.date(from),
                AppDateFormat.date(today),
              ),
              style: _muted(AppTextStyles.caption),
            ),
            _Section(l10n.reportMedicines),
            if (medicines.isEmpty)
              Text(l10n.reportNoMedicines, style: _muted(AppTextStyles.body))
            else
              for (final item in medicines)
                _MedicineLine(
                  medicine: item.medicine,
                  doctor: item.doctor,
                  reminders: [
                    for (final r in reminders)
                      if (r.medicineId == item.medicine.id) r,
                  ],
                  today: today,
                ),
            _Section(l10n.reportAdherence(DoctorReportScreen.days)),
            _Adherence(history: history),
            _Section(l10n.bpShortTitle),
            if (bp.isEmpty)
              Text(l10n.reportNoReadings, style: _muted(AppTextStyles.body))
            else ...[
              Text(
                l10n.reportLatest(
                  '${l10n.bpValue(AppNumber.format(bp.first.systolic), AppNumber.format(bp.first.diastolic))} '
                  '${AppConstants.bpUnit} · '
                  '${BpCategory.of(bp.first.systolic, bp.first.diastolic).label(l10n)}',
                ),
                style: _ink(AppTextStyles.body),
              ),
              Text(
                AppDateFormat.dateTime(bp.first.measuredAt),
                style: _muted(AppTextStyles.caption),
              ),
              Text(
                l10n.reportAverage(
                  DoctorReportScreen.days,
                  _bpAverage(l10n, bp),
                ),
                style: _ink(AppTextStyles.body),
              ),
            ],
            _Section(l10n.sugarShortTitle),
            if (sugar.isEmpty)
              Text(l10n.reportNoReadings, style: _muted(AppTextStyles.body))
            else ...[
              Text(
                l10n.reportLatest(
                  '${SugarText.mmol(sugar.first.mmol)} · '
                  '${sugar.first.context.label(l10n)} · '
                  '${SugarCategory.of(sugar.first.mmol, sugar.first.context).label(l10n)}',
                ),
                style: _ink(AppTextStyles.body),
              ),
              Text(
                AppDateFormat.dateTime(sugar.first.measuredAt),
                style: _muted(AppTextStyles.caption),
              ),
              Text(
                l10n.reportAverage(
                  DoctorReportScreen.days,
                  SugarText.mmol(
                    sugar.map((r) => r.mmol).reduce((a, b) => a + b) /
                        sugar.length,
                  ),
                ),
                style: _ink(AppTextStyles.body),
              ),
            ],
            AppSpacing.gapXl,
            Divider(color: _paper.divider, height: AppSpacing.borderThin),
            AppSpacing.gapMd,
            Text(
              l10n.reportMadeOn(AppDateFormat.date(DateTime.now())),
              style: _muted(AppTextStyles.caption),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section heading with the accent tick, like the app's headers.
class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
    child: Row(
      children: [
        Container(
          width: AppSpacing.headerTickWidth,
          height: AppSpacing.headerTickHeight,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
        ),
        AppSpacing.gapSm,
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.cardTitle.copyWith(
              color: _ReportPaper._paper.ink,
            ),
          ),
        ),
      ],
    ),
  );
}

/// "Napa 500 mg — 2 tablets · After meal · 08:00 am, 09:00 pm · Day 3 of 7".
class _MedicineLine extends StatelessWidget {
  const _MedicineLine({
    required this.medicine,
    required this.doctor,
    required this.reminders,
    required this.today,
  });

  final Medicine medicine;
  final Doctor? doctor;
  final List<Reminder> reminders;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final m = medicine;
    final times = [
      for (final r
          in reminders..sort(
            (a, b) => (a.startAt.hour * 60 + a.startAt.minute).compareTo(
              b.startAt.hour * 60 + b.startAt.minute,
            ),
          ))
        AppDateFormat.time(r.startAt),
    ];
    final course = CourseProgress.of(m, today);
    final details = [
      '${ReminderText.doseSummary(l10n, reminders, m.doseUnit)}'
          '${l10n.notifDoseSeparator}${m.mealRelation.label(l10n)}',
      if (times.isNotEmpty) times.join(', '),
      if (course != null && !course.notStarted && !course.isComplete)
        CourseProgressPill.dayLabel(l10n, course),
      ?doctor?.name,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [m.name, ?m.strength].join(' '),
            style: _ReportPaper._ink(AppTextStyles.cardTitle),
          ),
          for (final line in details)
            Text(line, style: _ReportPaper._muted(AppTextStyles.caption)),
        ],
      ),
    );
  }
}

/// "75%" and the breakdown behind it.
class _Adherence extends StatelessWidget {
  const _Adherence({required this.history});

  final DoseHistory? history;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final h = history;
    if (h == null || h.entries.isEmpty) {
      return Text(
        l10n.historyEmpty,
        style: _ReportPaper._muted(AppTextStyles.body),
      );
    }
    final taken = h.entries.where((e) => e.status.isTaken).length;
    return Row(
      children: [
        Text(
          '${AppNumber.format(((h.adherence ?? 0) * 100).round())}%',
          style: _ReportPaper._ink(AppTextStyles.amount),
        ),
        AppSpacing.gapLg,
        Expanded(
          child: Text(
            l10n.reportAdherenceDetail(
              taken,
              h.entries.length,
              h.count(ReminderLogStatus.missed),
              h.count(ReminderLogStatus.skipped),
            ),
            style: _ReportPaper._muted(AppTextStyles.body),
          ),
        ),
      ],
    );
  }
}
