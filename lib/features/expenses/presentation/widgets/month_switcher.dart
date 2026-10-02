import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/circle_icon_button.dart';

/// "‹  October 2026  ›" — next is disabled for the current month.
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrent = month.year == now.year && month.month == now.month;
    return Row(
      children: [
        CircleIconButton(
          icon: Icons.chevron_left_rounded,
          onPressed: onPrevious,
        ),
        Expanded(
          child: Text(
            AppDateFormat.month(month),
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
        ),
        Opacity(
          opacity: isCurrent ? AppSpacing.disabledOpacity : 1,
          child: CircleIconButton(
            icon: Icons.chevron_right_rounded,
            onPressed: isCurrent ? null : onNext,
          ),
        ),
      ],
    );
  }
}
