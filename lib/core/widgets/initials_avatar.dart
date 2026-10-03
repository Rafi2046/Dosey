import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Circle with up to two initials, tinted from the card palette by name.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = AppSpacing.avatarMd,
  });

  final String name;
  final double size;

  String get _initials {
    final clean = name.replaceAll(RegExp(r'[\(\)\[\]\{\}\.,]'), ' ');
    final words = clean
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .where(
          (w) => !RegExp(r'^(dr|prof|retd)$', caseSensitive: false).hasMatch(w),
        )
        .toList();
    if (words.isEmpty)
      return name.isNotEmpty ? name.trim()[0].toUpperCase() : '';
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.cardCycle[name.hashCode.abs() % AppColors.cardCycle.length];
    final light =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.outlineOnDark,
          width: AppSpacing.borderThin,
        ),
      ),
      child: Text(
        _initials,
        style: AppTextStyles.cardTitle.copyWith(
          fontSize: size >= AppSpacing.avatarLg
              ? AppSpacing.fontXl
              : AppSpacing.fontLg,
          color: light ? AppColors.ink : AppColors.textOnDark,
        ),
      ),
    );
  }
}
