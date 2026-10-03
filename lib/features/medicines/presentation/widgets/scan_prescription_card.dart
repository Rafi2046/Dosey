import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/localization/l10n.dart';

/// Mint call-to-action at the top of "Add medicine": photograph a
/// prescription to auto-fill the form. Shows a spinner while reading.
class ScanPrescriptionCard extends StatelessWidget {
  const ScanPrescriptionCard({
    super.key,
    required this.scanning,
    required this.onTap,
  });

  final bool scanning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: SurfaceCard(
        color: AppColors.mint,
        elevated: true,
        onTap: scanning ? null : onTap,
        child: Row(
          children: [
            Container(
              width: AppSpacing.avatarMd,
              height: AppSpacing.avatarMd,
              decoration: const BoxDecoration(
                color: AppColors.creamLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: AppColors.mint,
                size: AppSpacing.iconLg,
              ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scanning
                        ? context.l10n.scanReading
                        : context.l10n.scanTitle,
                    style: AppTextStyles.cardTitle,
                  ),
                  AppSpacing.gapXs,
                  Text(context.l10n.scanSubtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            AppSpacing.gapSm,
            if (scanning)
              const SizedBox.square(
                dimension: AppSpacing.iconMd,
                child: CircularProgressIndicator(color: AppColors.textOnDark),
              )
            else
              const Icon(
                Icons.photo_camera_rounded,
                color: AppColors.textOnDark,
              ),
          ],
        ),
      ),
    );
  }
}
