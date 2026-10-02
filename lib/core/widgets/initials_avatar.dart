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
    final words = name
        .replaceAll(RegExp(r'^(dr\.?|prof\.?)\s+', caseSensitive: false), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
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
          color: light ? AppColors.ink : AppColors.textOnDark,
        ),
      ),
    );
  }
}
