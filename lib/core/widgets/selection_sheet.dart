import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../localization/l10n.dart';
import 'pill_button.dart';
import 'sheet_title.dart';

/// Result wrapper so "None" (null) can be told apart from a dismissed sheet.
class Selection<T> {
  const Selection(this.value);
  final T? value;
}

/// Bottom-sheet list picker. Returns null when dismissed, or a [Selection]
/// (whose value is null when [allowNone] and "None" was chosen).
///
/// With no [items], shows [emptyTitle]/[emptyMessage] instead of a blank
/// sheet. [onAdd] adds an "[addLabel]" button at the end; the sheet closes
/// (returning null) and then calls it.
Future<Selection<T>?> showSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  String? Function(T)? subtitleOf,
  IconData? icon,
  T? selected,
  bool allowNone = false,
  String? emptyTitle,
  String? emptyMessage,
  String? addLabel,
  VoidCallback? onAdd,
}) {
  return showModalBottomSheet<Selection<T>>(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: AppSpacing.sheetInitialSize,
      maxChildSize: AppSpacing.sheetMaxSize,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.xl),
        children: [
          SheetTitle(title),
          AppSpacing.gapMd,
          if (allowNone)
            _SheetTile(
              label: context.l10n.none,
              icon: Icons.block_rounded,
              selected: selected == null,
              onTap: () => Navigator.pop(context, Selection<T>(null)),
            ),
          for (final item in items)
            _SheetTile(
              label: labelOf(item),
              subtitle: subtitleOf?.call(item),
              icon: icon,
              selected: item == selected,
              onTap: () => Navigator.pop(context, Selection<T>(item)),
            ),
          if (items.isEmpty && emptyTitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Column(
                children: [
                  Icon(
                    icon ?? Icons.inbox_rounded,
                    size: AppSpacing.avatarMd,
                    color: AppColors.inkMuted,
                  ),
                  AppSpacing.gapMd,
                  Text(
                    emptyTitle,
                    style: AppTextStyles.cardTitleOnLight,
                    textAlign: TextAlign.center,
                  ),
                  if (emptyMessage != null) ...[
                    AppSpacing.gapSm,
                    Text(
                      emptyMessage,
                      style: AppTextStyles.bodyOnLight,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          if (onAdd != null) ...[
            AppSpacing.gapMd,
            PillButton(
              label: addLabel ?? context.l10n.add,
              trailingIcon: Icons.add_rounded,
              onPressed: () {
                Navigator.pop(context);
                onAdd();
              },
            ),
          ],
        ],
      ),
    ),
  );
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: icon == null ? null : Icon(icon, color: AppColors.inkMuted),
      title: Text(label, style: AppTextStyles.inputOnLight),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: AppTextStyles.captionOnLight),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: AppColors.moss)
          : null,
    );
  }
}
