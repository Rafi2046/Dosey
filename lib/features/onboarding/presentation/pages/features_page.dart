import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../widgets/feature_row.dart';

/// Page 2: what Dosey does, in four short rows.
class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final features = [
      (Icons.alarm_on_rounded, l10n.featureAlarmTitle, l10n.featureAlarmBody),
      (
        Icons.document_scanner_rounded,
        l10n.featureScanTitle,
        l10n.featureScanBody,
      ),
      (
        Icons.inventory_2_rounded,
        l10n.featureStockTitle,
        l10n.featureStockBody,
      ),
      (Icons.lock_rounded, l10n.featurePrivateTitle, l10n.featurePrivateBody),
    ];
    const colors = [
      AppColors.accent,
      AppColors.mint,
      AppColors.olive,
      AppColors.moss,
    ];
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding.copyWith(
        top: AppSpacing.xl,
        bottom: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboardingFeaturesTitle, style: AppTextStyles.display),
          AppSpacing.gapXxl,
          for (final (i, (icon, title, body)) in features.indexed)
            FeatureRow(icon: icon, color: colors[i], title: title, body: body),
        ],
      ),
    );
  }
}
