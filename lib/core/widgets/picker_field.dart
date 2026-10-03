import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'labeled_field.dart';
import '../localization/l10n.dart';

/// Read-only field that opens a picker (date, time, doctor...). Shows
/// [placeholder] when [value] is null and an optional clear button.
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder = context.l10n.choose,
    this.icon = Icons.expand_more_rounded,
    this.onClear,
    this.errorText,
  });

  final String label;
  final String? value;
  final String placeholder;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return LabeledField(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: AppColors.creamLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: AppSpacing.inputPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value ?? placeholder,
                        style: hasValue
                            ? AppTextStyles.inputOnLight
                            : AppTextStyles.captionOnLight,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasValue && onClear != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: context.l10n.clear,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.inkMuted,
                        ),
                        onPressed: onClear,
                      )
                    else
                      Icon(icon, color: AppColors.inkMuted),
                  ],
                ),
              ),
            ),
          ),
          if (errorText != null) ...[
            AppSpacing.gapXs,
            Text(errorText!, style: AppTextStyles.errorText),
          ],
        ],
      ),
    );
  }
}
