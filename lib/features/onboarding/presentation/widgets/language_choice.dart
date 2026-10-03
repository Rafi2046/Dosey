import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/surface_card.dart';

/// Two big tappable cards, "English" and "বাংলা"; the selected one is cream
/// with a check. Each name is written in its own language so anyone can
/// find theirs.
class LanguageChoice extends StatelessWidget {
  const LanguageChoice({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// "en" or "bn".
  final String selected;
  final ValueChanged<String> onChanged;

  static const _options = [('en', 'English', 'EN'), ('bn', 'বাংলা', 'বাং')];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, (code, name, short)) in _options.indexed) ...[
          if (i > 0) AppSpacing.gapMd,
          Expanded(
            child: _LanguageCard(
              name: name,
              short: short,
              selected: code == selected,
              onTap: () => onChanged(code),
            ),
          ),
        ],
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.name,
    required this.short,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String short;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.ink : AppColors.textOnDark;
    return Semantics(
      selected: selected,
      button: true,
      child: SurfaceCard(
        color: selected ? AppColors.cream : AppColors.olive,
        elevated: selected,
        padding: AppSpacing.cardPadding,
        onTap: onTap,
        child: Row(
          children: [
            Text(
              short,
              style: AppTextStyles.overline.copyWith(
                color: selected
                    ? AppColors.inkMuted
                    : AppColors.textOnDarkMuted,
              ),
            ),
            AppSpacing.gapSm,
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.cardTitle.copyWith(color: foreground),
              ),
            ),
            AnimatedSwitcher(
              duration: AppSpacing.animFast,
              child: selected
                  ? Icon(
                      Icons.check_circle_rounded,
                      key: ValueKey(true),
                      color: AppColors.mint,
                    )
                  : Icon(
                      Icons.circle_outlined,
                      key: ValueKey(false),
                      color: AppColors.outlineOnDark,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
