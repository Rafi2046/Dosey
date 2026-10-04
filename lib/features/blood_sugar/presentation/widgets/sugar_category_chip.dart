import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/sugar_category.dart';

/// "In range", "High"… in the category's colour.
class SugarCategoryChip extends StatelessWidget {
  const SugarCategoryChip(this.category, {super.key});

  final SugarCategory category;

  @override
  Widget build(BuildContext context) => StatusChip(
    label: category.label(context.l10n),
    background: category.color,
    foreground: category.onColor,
  );
}
