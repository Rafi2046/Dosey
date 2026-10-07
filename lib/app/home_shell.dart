import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/doctors/presentation/doctors_screen.dart';
import '../features/expenses/presentation/expenses_screen.dart';
import '../features/medicines/presentation/medicines_screen.dart';
import '../features/records/presentation/records_screen.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import '../core/constants/constants.dart';
import '../core/widgets/confirm_dialog.dart';
import 'home_tab.dart';
import 'widgets/add_action_sheet.dart';
import 'widgets/app_nav_bar.dart';
import 'widgets/more_sheet.dart';

/// Main app frame: tab content (state kept alive) under the nav bar.
/// The nav bar slides away while scrolling down and comes back on scrolling
/// up or once scrolling stops. Tapping the tab already open scrolls it back
/// to the top.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  bool _navVisible = true;
  Timer? _showAgain;

  /// Each tab's list, handed down as its primary scroll controller.
  final _scrollers = {for (final t in HomeTab.values) t: ScrollController()};

  @override
  void dispose() {
    _showAgain?.cancel();
    for (final c in _scrollers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _select(HomeTab tab) {
    _setNav(true);
    if (ref.read(homeTabProvider) != tab) {
      ref.read(homeTabProvider.notifier).select(tab);
      return;
    }
    final list = _scrollers[tab]!;
    if (list.hasClients && list.offset > 0) {
      list.animateTo(
        0,
        duration: AppSpacing.animMedium,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _setNav(bool visible) {
    if (_navVisible != visible) setState(() => _navVisible = visible);
  }

  bool _onScroll(ScrollNotification n) {
    // Only the tab's own vertical list, not nested carousels / pills.
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    if (n is UserScrollNotification) {
      switch (n.direction) {
        case ScrollDirection.reverse:
          _showAgain?.cancel();
          _setNav(false);
        case ScrollDirection.forward:
          _setNav(true);
        case ScrollDirection.idle:
          break;
      }
    } else if (n is ScrollEndNotification) {
      _showAgain?.cancel();
      _showAgain = Timer(AppSpacing.navShowDelay, () {
        if (mounted) _setNav(true);
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(homeTabProvider);
    final tabs = ref.read(homeTabProvider.notifier);

    // Back on any other tab returns to Home; on Home it asks before
    // leaving the app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (tab != HomeTab.dashboard) return tabs.select(HomeTab.dashboard);
        if (await confirmExit(context)) await SystemNavigator.pop();
      },
      child: Scaffold(
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: IndexedStack(
                index: tab.index,
                children: [
                  for (final t in HomeTab.values)
                    PrimaryScrollController(
                      controller: _scrollers[t]!,
                      // Desktop too: by default only mobile lists pick it up.
                      automaticallyInheritForPlatforms: TargetPlatform.values
                          .toSet(),
                      child: switch (t) {
                        HomeTab.dashboard => DashboardScreen(
                          onOpenReminders: () => tabs.select(HomeTab.reminders),
                          onOpenExpenses: () => tabs.select(HomeTab.expenses),
                        ),
                        HomeTab.reminders => const RemindersScreen(),
                        HomeTab.medicines => const MedicinesScreen(),
                        HomeTab.doctors => const DoctorsScreen(),
                        HomeTab.records => const RecordsScreen(),
                        HomeTab.expenses => const ExpensesScreen(),
                      },
                    ),
                ],
              ),
            ),
            // Content scrolling under the nav bar fades out instead of
            // peeking around it.
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _navVisible ? 1 : 0,
                  duration: AppSpacing.animMedium,
                  child: SizedBox(
                    height: AppSpacing.navFadeHeight,
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.sageTransparent, AppColors.sage],
                          stops: [0, 0.55],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                ignoring: !_navVisible,
                child: AnimatedSlide(
                  offset: _navVisible ? Offset.zero : const Offset(0, 1.5),
                  duration: AppSpacing.animMedium,
                  curve: Curves.easeOutCubic,
                  child: SafeArea(
                    top: false,
                    child: AppNavBar(
                      current: tab,
                      onSelected: _select,
                      onAdd: () => showAddActionSheet(context),
                      onMore: () => showMoreSheet(
                        context,
                        current: tab,
                        onSelected: _select,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
