import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'circle_icon_button.dart';

/// Light (cream) page used for details and forms, like the design's
/// "Medicine" screen: outlined back button + small title, content below and
/// an optional pinned bottom bar for primary actions.
class CreamScaffold extends StatelessWidget {
  const CreamScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.bottomBar,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
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
                  CircleIconButton.back(context, color: AppColors.ink),
                  AppSpacing.gapMd,
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.ink,
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
    );
  }
}
