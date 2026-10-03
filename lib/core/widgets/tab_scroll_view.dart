import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Scrolling body of a tab page (clear of the floating nav bar). With
/// [centerLast], the last child (an empty state) gets all the space left
/// below the others and sits in its middle instead of under the header.
class TabScrollView extends StatelessWidget {
  const TabScrollView({
    super.key,
    required this.children,
    this.centerLast = false,
  });

  final List<Widget> children;
  final bool centerLast;

  @override
  Widget build(BuildContext context) {
    final fill = centerLast && children.isNotEmpty ? children.last : null;
    final top = fill == null
        ? children
        : children.sublist(0, children.length - 1);
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: fill == null
                ? AppSpacing.screenPadding.add(AppSpacing.listBottomPadding)
                : AppSpacing.screenPadding,
            sliver: SliverList.list(children: top),
          ),
          if (fill != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: AppSpacing.screenPadding.add(
                  AppSpacing.listBottomPadding,
                ),
                child: Center(child: fill),
              ),
            ),
        ],
      ),
    );
  }
}
