import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/localization/l10n.dart';

/// Headline numbers: spent in the selected month, and the projected monthly
/// cost of the medicines currently being taken.
class ExpenseSummaryWidget extends StatelessWidget {
  const ExpenseSummaryWidget({
    super.key,
    required this.spentMinor,
    required this.projectedMonthlyMinor,
    required this.projectedDailyMinor,
    this.onTap,
  });

  final int spentMinor;
  final int projectedMonthlyMinor;
  final int projectedDailyMinor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: AppColors.mint,
      elevated: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(
            icon: Icons.account_balance_wallet_rounded,
            text: context.l10n.spentThisMonth,
          ),
          AppSpacing.gapSm,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(Money.format(spentMinor), style: AppTextStyles.amount),
          ),
          Divider(height: AppSpacing.xxl, color: AppColors.outlineOnDark),
          _Label(
            icon: Icons.medication_rounded,
            text: context.l10n.projectedMonthly,
          ),
          AppSpacing.gapSm,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  Money.format(projectedMonthlyMinor),
                  style: AppTextStyles.title,
                ),
              ),
              AppSpacing.gapSm,
              Text(
                context.l10n.perDay(Money.format(projectedDailyMinor)),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: AppSpacing.iconSm, color: AppColors.textOnDark),
      AppSpacing.gapXs,
      Flexible(
        child: Text(
          text,
          style: AppTextStyles.overline.copyWith(color: AppColors.textOnDark),
        ),
      ),
    ],
  );
}
