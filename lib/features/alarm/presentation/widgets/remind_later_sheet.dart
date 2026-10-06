import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/widgets/sheet_title.dart';

/// "When should I remind you?" for a dose that can't be taken right now:
/// one pill per [AppConstants.remindLaterOptions]. Null when dismissed.
Future<Duration?> showRemindLaterSheet(BuildContext context) =>
    showModalBottomSheet<Duration>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final l10n = context.l10n;
        return SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SheetTitle(l10n.remindLaterTitle),
                AppSpacing.gapSm,
                Text(l10n.remindLaterHint, style: AppTextStyles.bodyOnLight),
                AppSpacing.gapLg,
                for (final (i, wait)
                    in AppConstants.remindLaterOptions.indexed) ...[
                  if (i > 0) AppSpacing.gapSm,
                  PillButton(
                    label: l10n.remindLaterIn(
                      l10n.inHoursMinutes(wait.inHours, wait.inMinutes % 60),
                    ),
                    tone: PillButtonTone.cream,
                    trailingIcon: Icons.schedule_rounded,
                    onPressed: () => Navigator.pop(context, wait),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
