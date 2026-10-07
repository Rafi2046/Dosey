import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utils/clock_providers.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/tab_scroll_view.dart';
import '../providers/blood_pressure_providers.dart';
import 'blood_pressure_form_screen.dart';
import 'widgets/bp_latest_card.dart';
import 'widgets/bp_reading_tile.dart';
import 'widgets/bp_trend_chart.dart';

/// Blood pressure log: the latest reading and 7-day average, a trend of the
/// last two weeks of readings, and the full history. Readings are typed in
/// from any home monitor.
class BloodPressureScreen extends ConsumerWidget {
  const BloodPressureScreen({super.key});

  static void _openForm(BuildContext context, [BloodPressureReading? r]) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BloodPressureFormScreen(existing: r),
        ),
      );

  /// Average of the readings from the 7 days before [now]; null under 2.
  static (int, int)? weekAverage(List<BloodPressureReading> all, DateTime now) {
    final since = now.subtract(const Duration(days: 7));
    final week = [
      for (final r in all)
        if (r.measuredAt.isAfter(since) && !r.measuredAt.isAfter(now)) r,
    ];
    if (week.length < 2) return null;
    int avg(int Function(BloodPressureReading) f) =>
        (week.map(f).reduce((a, b) => a + b) / week.length).round();
    return (avg((r) => r.systolic), avg((r) => r.diastolic));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final readings = ref.watch(bloodPressureReadingsProvider);
    final now = ref.watch(minuteTickerProvider).value ?? DateTime.now();
    final list = readings.value;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: TabScrollView(
              bottomPadding: const EdgeInsets.only(bottom: AppSpacing.lg),
              centerLast: list?.isEmpty ?? false,
              onRefresh: () async =>
                  ref.invalidate(bloodPressureReadingsProvider),
              children: [
                ScreenHeader(
                  title: l10n.bpTitle,
                  showBack: false,
                  // Empty: the empty state below already says so.
                  subtitle: list == null || list.isEmpty
                      ? null
                      : l10n.bpCount(list.length),
                ),
                AsyncValueView(
                  value: readings,
                  data: (all) => all.isEmpty
                      ? EmptyState(
                          title: l10n.bpEmpty,
                          message: l10n.bpEmptyHint,
                          image: null,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BpLatestCard(
                              latest: all.first,
                              average: weekAverage(all, now),
                            ),
                            if (all.length > 1) ...[
                              SectionHeader(title: l10n.bpTrend),
                              BpTrendChart(readings: all),
                            ],
                            SectionHeader(title: l10n.bpHistory),
                            for (final r in all)
                              BpReadingTile(
                                reading: r,
                                onTap: () => _openForm(context, r),
                              ),
                            AppSpacing.gapSm,
                            Text(
                              l10n.bpDisclaimer,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: AppSpacing.bottomBarPadding,
              child: PillButton(
                label: l10n.bpAdd,
                showForwardArrow: true,
                onPressed: () => _openForm(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
