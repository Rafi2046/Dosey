import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/bp_category.dart';

/// "Normal", "High · stage 1"… in the category's colour.
class BpCategoryChip extends StatelessWidget {
  const BpCategoryChip(this.category, {super.key});

  final BpCategory category;

  @override
  Widget build(BuildContext context) => StatusChip(
    label: category.label(context.l10n),
    background: category.color,
    foreground: category.onColor,
  );
}
