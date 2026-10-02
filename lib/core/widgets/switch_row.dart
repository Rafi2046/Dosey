import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Title + hint + switch, for settings-style toggles on cream screens.
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
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
