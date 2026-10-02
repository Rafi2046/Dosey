import 'package:flutter/material.dart';

import '../core/constants/constants.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_background.dart';
import 'placeholder_home.dart';

class DoseyApp extends StatelessWidget {
  const DoseyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      builder: (context, child) =>
          AppBackground(child: child ?? const SizedBox.shrink()),
      home: const PlaceholderHome(),
    );
  }
}
