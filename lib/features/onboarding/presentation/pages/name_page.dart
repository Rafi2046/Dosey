import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';

/// Page 2: the user's name, optional (the button below says "Skip" while
/// it's empty).
class NamePage extends StatelessWidget {
  const NamePage({super.key, required this.controller, required this.onDone});

  final TextEditingController controller;

  /// Keyboard "done": same as the button below.
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding.copyWith(
        top: AppSpacing.xl,
        bottom: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboardingNameTitle, style: AppTextStyles.display),
          AppSpacing.gapMd,
          Text(l10n.onboardingNameBody, style: AppTextStyles.bodyMuted),
          AppSpacing.gapXl,
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onDone(),
            style: AppTextStyles.inputOnLight,
            cursorColor: AppColors.ink,
            decoration: InputDecoration(
              hintText: l10n.yourName,
              prefixIcon: Icon(Icons.person_rounded, color: AppColors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
