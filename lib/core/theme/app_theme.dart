import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Calm teal-blue theme with misty light panels and a soft coral accent,
/// in light or dark depending on the active [AppPalette].
abstract final class AppTheme {
  /// Built from the active palette (light or dark), see [AppColors.apply].
  static ThemeData get current => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _colorScheme,
    fontFamily: AppTextStyles.body.fontFamily,
    scaffoldBackgroundColor: AppColors.sage,
    canvasColor: AppColors.sage,
    textTheme: _textTheme,
    dividerColor: AppColors.divider,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.transparent,
      surfaceTintColor: AppColors.transparent,
      elevation: AppSpacing.elevationNone,
      centerTitle: false,
      titleTextStyle: AppTextStyles.subtitle,
      iconTheme: IconThemeData(color: AppColors.textOnDark),
    ),
    cardTheme: CardThemeData(
      color: AppColors.olive,
      elevation: AppSpacing.elevationNone,
      margin: EdgeInsets.zero,
      shape: _rounded(AppSpacing.radiusLg),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.creamLight,
      contentPadding: AppSpacing.inputPadding,
      labelStyle: AppTextStyles.captionOnLight,
      hintStyle: AppTextStyles.captionOnLight,
      border: _inputBorder(AppColors.transparent),
      enabledBorder: _inputBorder(AppColors.transparent),
      focusedBorder: _inputBorder(AppColors.moss, AppSpacing.borderThick),
      errorBorder: _inputBorder(AppColors.error),
      focusedErrorBorder: _inputBorder(AppColors.error, AppSpacing.borderThick),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnAccent,
        minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
        textStyle: AppTextStyles.button,
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textOnDark,
        textStyle: AppTextStyles.button,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.textOnAccent,
      shape: CircleBorder(),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.sand,
      selectedColor: AppColors.selected,
      labelStyle: AppTextStyles.chip.copyWith(color: AppColors.ink),
      padding: AppSpacing.chipPadding,
      side: BorderSide.none,
      shape: const StadiumBorder(),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.creamLight
            : AppColors.textOnDarkMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.moss,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cream,
      titleTextStyle: AppTextStyles.titleOnLight,
      contentTextStyle: AppTextStyles.bodyOnLight,
      shape: _rounded(AppSpacing.radiusLg),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.cream,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.moss,
      contentTextStyle: AppTextStyles.body,
      shape: _rounded(AppSpacing.radiusMd),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
    ),
  );

  static ColorScheme get _colorScheme => ColorScheme.dark(
    primary: AppColors.accent,
    onPrimary: AppColors.textOnAccent,
    secondary: AppColors.mint,
    onSecondary: AppColors.ink,
    surface: AppColors.sage,
    onSurface: AppColors.textOnDark,
    onSurfaceVariant: AppColors.textOnDarkMuted,
    surfaceContainer: AppColors.olive,
    error: AppColors.error,
    outline: AppColors.outlineOnDark,
    shadow: AppColors.shadow,
  );

  static TextTheme get _textTheme => TextTheme(
    displayLarge: AppTextStyles.display,
    headlineMedium: AppTextStyles.headline,
    titleLarge: AppTextStyles.title,
    titleMedium: AppTextStyles.subtitle,
    bodyLarge: AppTextStyles.body,
    bodyMedium: AppTextStyles.bodyMuted,
    bodySmall: AppTextStyles.caption,
    labelLarge: AppTextStyles.button,
    labelSmall: AppTextStyles.overline,
  );

  static RoundedRectangleBorder _rounded(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  static OutlineInputBorder _inputBorder(
    Color color, [
    double width = AppSpacing.borderThin,
  ]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    borderSide: BorderSide(color: color, width: width),
  );
}
