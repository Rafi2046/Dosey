import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'app_switch.dart';

/// Title + hint + switch, for settings-style toggles on cream screens.
/// Tapping anywhere on the row toggles it.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      // The whole row toggles, not just the small switch.
      child: MergeSemantics(
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.subtitleOnLight),
                    if (subtitle != null) ...[
                      AppSpacing.gapXs,
                      Text(subtitle!, style: AppTextStyles.captionOnLight),
                    ],
                  ],
                ),
              ),
              AppSpacing.gapMd,
              AppSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
