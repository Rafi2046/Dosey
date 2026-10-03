import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';
import 'back_arrow_button.dart';

/// Light (cream) page used for details and forms, like the design's
/// "Medicine" screen: back arrow + small title, content below and an
/// optional pinned bottom bar for primary actions. [onDark] puts it on the
/// sage background of the main tabs instead (Settings and its pages).
class CreamScaffold extends StatelessWidget {
  const CreamScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.bottomBar,
    this.onDark = false,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? bottomBar;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    // Cream screens are light in light mode: dark status-bar icons there.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColors.isDark || onDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: onDark ? AppColors.sage : AppColors.cream,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: AppSpacing.screenPadding.copyWith(
                  top: AppSpacing.md,
                  bottom: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    BackArrowButton(
                      color: onDark ? AppColors.textOnDark : AppColors.ink,
                    ),
                    AppSpacing.gapSm,
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.subtitle.copyWith(
                          color: onDark ? AppColors.textOnDark : AppColors.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...actions,
                  ],
                ),
              ),
              Expanded(child: body),
              if (bottomBar != null)
                Padding(padding: AppSpacing.bottomBarPadding, child: bottomBar),
            ],
          ),
        ),
      ),
    );
  }
}
