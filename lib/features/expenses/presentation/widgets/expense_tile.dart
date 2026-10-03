import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/surface_card.dart';

/// One expense row: category icon, title, date and amount.
class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense, required this.onTap});

  final Expense expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = expense.category;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: c.color,
        foregroundColor: SurfaceCard.foregroundFor(c.color),
        child: Icon(c.icon, size: AppSpacing.iconMd),
      ),
      title: Text(expense.title, style: AppTextStyles.subtitle),
      subtitle: Text(
        '${c.label}${NotificationStrings.notifDoseSeparator}'
        '${AppDateFormat.shortDate(expense.spentOn)}',
        style: AppTextStyles.caption,
      ),
      trailing: Text(
        Money.format(expense.amountMinor),
        style: AppTextStyles.subtitle,
      ),
    );
  }
}
