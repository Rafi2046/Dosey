import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'skeleton.dart';

/// Scrolling body of a tab page (clear of the floating nav bar).
///
/// With [centerLast], the last child (an empty state) gets all the space
/// left below the others and sits in its middle instead of under the header.
///
/// With [onRefresh], pulling down refreshes the page: the children from
/// [refreshFrom] on (default: the last one, the list) turn into a shimmer
/// skeleton until [onRefresh] is done, and at least
/// [AppSpacing.refreshMinDuration] so it doesn't just flash.
class TabScrollView extends StatefulWidget {
  const TabScrollView({
    super.key,
    required this.children,
    this.centerLast = false,
    this.onRefresh,
    this.refreshFrom,
  });

  final List<Widget> children;
  final bool centerLast;
  final Future<void> Function()? onRefresh;
  final int? refreshFrom;

  @override
  State<TabScrollView> createState() => _TabScrollViewState();
}

class _TabScrollViewState extends State<TabScrollView> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      await Future.wait([
        widget.onRefresh!(),
        Future<void>.delayed(AppSpacing.refreshMinDuration),
      ]);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.children;
    final from = widget.refreshFrom ?? all.length - 1;
    final children = _refreshing
        ? [...all.take(from), const Skeleton.cards()]
        : all;
    final fill = widget.centerLast && !_refreshing && children.isNotEmpty
        ? children.last
        : null;
    final top = fill == null
        ? children
        : children.sublist(0, children.length - 1);

    final scroll = CustomScrollView(
      // Pull-to-refresh works even when everything fits on screen.
      physics: widget.onRefresh == null
          ? null
          : const AlwaysScrollableScrollPhysics(),
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
    );

    return SafeArea(
      bottom: false,
      child: widget.onRefresh == null
          ? scroll
          : RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.accent,
              backgroundColor: AppColors.cream,
              child: scroll,
            ),
    );
  }
}
