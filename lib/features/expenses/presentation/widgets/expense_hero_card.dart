import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import 'spending_trend_bars.dart';

/// The expenses screen's headline card: what was spent in the selected
/// month, how that compares with the month before, a six-month trend, and
/// the projected monthly cost of the medicines being taken.
class ExpenseHeroCard extends StatelessWidget {
  const ExpenseHeroCard({
    super.key,
    required this.month,
    required this.trend,
    required this.projectedMonthlyMinor,
    required this.projectedDailyMinor,
  });

  final DateTime month;

  /// (month, total) oldest first; the last entry is [month].
  final List<(DateTime, int)> trend;
  final int projectedMonthlyMinor;
  final int projectedDailyMinor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spent = trend.isEmpty ? 0 : trend.last.$2;
    final previous = trend.length < 2 ? null : trend[trend.length - 2].$2;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mint, AppColors.moss],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSpacing.shadowBlur,
            offset: AppSpacing.shadowOffset,
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.cardPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: AppSpacing.iconSm,
                  color: AppColors.textOnDark,
                ),
                AppSpacing.gapXs,
                Expanded(
                  child: Text(
                    l10n.spentIn(AppDateFormat.monthName(month)),
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapSm,
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(Money.format(spent), style: AppTextStyles.amount),
            ),
            if (previous != null && (spent > 0 || previous > 0)) ...[
              AppSpacing.gapSm,
              _ChangeBadge(current: spent, previous: previous),
            ],
            AppSpacing.gapLg,
            SpendingTrendBars(months: trend),
            AppSpacing.gapLg,
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.creamLight.withValues(
                  alpha: AppSpacing.glassOpacity,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.medication_rounded,
                    color: AppColors.textOnDark,
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.medicineCost, style: AppTextStyles.caption),
                        Text.rich(
                          TextSpan(
                            text: Money.format(projectedMonthlyMinor),
                            style: AppTextStyles.subtitle,
                            children: [
                              TextSpan(
                                text: ' ${l10n.perMonth}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.perDay(Money.format(projectedDailyMinor)),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "↑ ৳200 vs last month" pill.
class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.current, required this.previous});

  final int current;
  final int previous;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final diff = current - previous;
    final label = diff == 0
        ? l10n.sameAsLastMonth
        : '${Money.format(diff.abs())} ${l10n.vsLastMonth}';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamLight.withValues(alpha: AppSpacing.badgeOpacity),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (diff != 0)
            Icon(
              diff > 0
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: AppSpacing.iconSm,
              color: AppColors.textOnDark,
            ),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.navLabel.copyWith(
                color: AppColors.textOnDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
