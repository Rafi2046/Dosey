import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/date_format.dart';

/// Mini bar chart of monthly spending; the last (selected) month is solid,
/// earlier ones translucent. Drawn on the dark expenses card.
class SpendingTrendBars extends StatelessWidget {
  const SpendingTrendBars({super.key, required this.months});

  /// (month, total in minor units), oldest first.
  final List<(DateTime, int)> months;

  static const double _height = 56;

  /// Nothing spent in the whole period: just a flat baseline, no tall gap.
  static const double _emptyHeight = 8;
  static const double _minBar = 4;
  static const double _faded = 0.35;

  @override
  Widget build(BuildContext context) {
    final max = months.fold(0, (m, e) => e.$2 > m ? e.$2 : m);
    final height = max == 0 ? _emptyHeight : _height;
    return Semantics(
      label: context.l10n.lastMonthsTrend(months.length),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, (month, total)) in months.indexed) ...[
            if (i > 0) AppSpacing.gapSm,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: height,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: AppSpacing.animSlow,
                        curve: Curves.easeOutCubic,
                        height: max == 0
                            ? _minBar
                            : (_height * total / max).clamp(_minBar, _height),
                        decoration: BoxDecoration(
                          color: AppColors.creamLight.withValues(
                            alpha: i == months.length - 1 ? 1 : _faded,
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapXs,
                  Text(
                    AppDateFormat.monthShort(month),
                    style: AppTextStyles.navLabel.copyWith(
                      color: i == months.length - 1
                          ? AppColors.textOnDark
                          : AppColors.textOnDarkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
