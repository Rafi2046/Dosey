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
import '../providers/blood_sugar_providers.dart';
import 'blood_sugar_form_screen.dart';
import 'widgets/sugar_latest_card.dart';
import 'widgets/sugar_reading_tile.dart';
import 'widgets/sugar_trend_chart.dart';

/// Blood sugar log: the latest reading and 7-day average, a trend of the
/// last two weeks, and the full history. Readings are typed in from any
/// glucometer.
class BloodSugarScreen extends ConsumerWidget {
  const BloodSugarScreen({super.key});

  static void _openForm(BuildContext context, [BloodSugarReading? r]) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BloodSugarFormScreen(existing: r),
        ),
      );

  /// Average (mmol/L) of the last 7 days before [now]; null under 2.
  static double? weekAverage(List<BloodSugarReading> all, DateTime now) {
    final since = now.subtract(const Duration(days: 7));
    final week = [
      for (final r in all)
        if (r.measuredAt.isAfter(since) && !r.measuredAt.isAfter(now)) r.mmol,
    ];
    if (week.length < 2) return null;
    final avg = week.reduce((a, b) => a + b) / week.length;
    return (avg * 10).round() / 10;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final readings = ref.watch(bloodSugarReadingsProvider);
    final now = ref.watch(minuteTickerProvider).value ?? DateTime.now();
    final list = readings.value;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: TabScrollView(
              bottomPadding: const EdgeInsets.only(bottom: AppSpacing.lg),
              centerLast: list?.isEmpty ?? false,
              onRefresh: () async => ref.invalidate(bloodSugarReadingsProvider),
              children: [
                ScreenHeader(
                  title: l10n.sugarTitle,
                  showBack: false,
                  // Empty: the empty state below already says so.
                  subtitle: list == null || list.isEmpty
                      ? null
                      : l10n.sugarCount(list.length),
                ),
                AsyncValueView(
                  value: readings,
                  data: (all) => all.isEmpty
                      ? EmptyState(
                          title: l10n.sugarEmpty,
                          message: l10n.sugarEmptyHint,
                          image: null,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SugarLatestCard(
                              latest: all.first,
                              average: weekAverage(all, now),
                            ),
                            if (all.length > 1) ...[
                              SectionHeader(title: l10n.bpTrend),
                              SugarTrendChart(readings: all),
                            ],
                            SectionHeader(title: l10n.bpHistory),
                            for (final r in all)
                              SugarReadingTile(
                                reading: r,
                                onTap: () => _openForm(context, r),
                              ),
                            AppSpacing.gapSm,
                            Text(
                              l10n.sugarDisclaimer,
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
                label: l10n.sugarAdd,
                showRingChevron: true,
                onPressed: () => _openForm(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
