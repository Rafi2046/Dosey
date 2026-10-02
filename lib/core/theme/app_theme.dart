import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Dark glassmorphism theme with cyan neon accents.
abstract final class AppTheme {
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _colorScheme,
    // Screens sit on [AppBackground]'s gradient, so scaffolds are transparent.
    scaffoldBackgroundColor: AppColors.transparent,
    canvasColor: AppColors.surface,
    textTheme: _textTheme,
    dividerColor: AppColors.divider,
    splashColor: AppColors.neonGlowFaint,
    highlightColor: AppColors.neonGlowFaint,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.transparent,
      surfaceTintColor: AppColors.transparent,
      elevation: AppSpacing.elevationNone,
      centerTitle: false,
      titleTextStyle: AppTextStyles.title,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.glassFill,
      elevation: AppSpacing.elevationNone,
      margin: EdgeInsets.zero,
      shape: _roundedBorder(AppSpacing.radiusLg, AppColors.glassBorder),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.glassFill,
      contentPadding: AppSpacing.inputPadding,
      labelStyle: AppTextStyles.bodySecondary,
      hintStyle: AppTextStyles.caption,
      floatingLabelStyle: AppTextStyles.neonLabel,
      border: _inputBorder(AppColors.glassBorder),
      enabledBorder: _inputBorder(AppColors.glassBorder),
      focusedBorder: _inputBorder(AppColors.neonCyan, AppSpacing.borderThick),
      errorBorder: _inputBorder(AppColors.error),
      focusedErrorBorder: _inputBorder(AppColors.error, AppSpacing.borderThick),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.neonCyan,
        foregroundColor: AppColors.textOnNeon,
        minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
        padding: AppSpacing.buttonPadding,
        textStyle: AppTextStyles.button,
        shape: _roundedBorder(AppSpacing.radiusMd),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.neonCyan,
        minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
        padding: AppSpacing.buttonPadding,
        textStyle: AppTextStyles.button,
        side: const BorderSide(color: AppColors.neonCyan),
        shape: _roundedBorder(AppSpacing.radiusMd),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.neonCyan,
        textStyle: AppTextStyles.button,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.neonCyan,
      foregroundColor: AppColors.textOnNeon,
      shape: _roundedBorder(AppSpacing.radiusLg),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.transparent,
      surfaceTintColor: AppColors.transparent,
      indicatorColor: AppColors.neonGlowFaint,
      height: AppSpacing.navBarHeight,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppTextStyles.neonLabel
            : AppTextStyles.caption,
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.neonCyan
              : AppColors.textSecondary,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.glassFill,
      selectedColor: AppColors.neonGlowFaint,
      labelStyle: AppTextStyles.caption,
      padding: AppSpacing.chipPadding,
      side: const BorderSide(color: AppColors.glassBorder),
      shape: _roundedBorder(AppSpacing.radiusPill),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.neonCyan
            : AppColors.textMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.neonGlow
            : AppColors.glassFill,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceElevated,
      titleTextStyle: AppTextStyles.title,
      contentTextStyle: AppTextStyles.bodySecondary,
      shape: _roundedBorder(AppSpacing.radiusXl, AppColors.glassBorder),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceElevated,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceElevated,
      contentTextStyle: AppTextStyles.body,
      shape: _roundedBorder(AppSpacing.radiusMd, AppColors.glassBorder),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.neonCyan,
    ),
  );

  static const ColorScheme _colorScheme = ColorScheme.dark(
    primary: AppColors.neonCyan,
    onPrimary: AppColors.textOnNeon,
    primaryContainer: AppColors.neonCyanDeep,
    secondary: AppColors.neonCyanSoft,
    onSecondary: AppColors.textOnNeon,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    error: AppColors.error,
    errorContainer: AppColors.errorContainer,
    outline: AppColors.glassBorder,
    shadow: AppColors.shadow,
  );

  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTextStyles.display,
    headlineMedium: AppTextStyles.headline,
    titleLarge: AppTextStyles.title,
    titleMedium: AppTextStyles.subtitle,
    bodyLarge: AppTextStyles.body,
    bodyMedium: AppTextStyles.bodySecondary,
    bodySmall: AppTextStyles.caption,
    labelLarge: AppTextStyles.button,
    labelSmall: AppTextStyles.overline,
  );

  static RoundedRectangleBorder _roundedBorder(double radius, [Color? side]) =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: side == null ? BorderSide.none : BorderSide(color: side),
      );

  static OutlineInputBorder _inputBorder(
    Color color, [
    double width = AppSpacing.borderThin,
  ]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    borderSide: BorderSide(color: color, width: width),
  );
}
