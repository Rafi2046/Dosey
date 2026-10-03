import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/doctors/presentation/doctors_screen.dart';
import '../features/expenses/presentation/expenses_screen.dart';
import '../features/medicines/presentation/medicines_screen.dart';
import '../features/records/presentation/records_screen.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import '../core/constants/constants.dart';
import 'home_tab.dart';
import 'widgets/add_action_sheet.dart';
import 'widgets/app_nav_bar.dart';
import 'widgets/more_sheet.dart';

/// Main app frame: tab content (state kept alive) under the nav bar.
/// The nav bar slides away while scrolling down and comes back on scrolling
/// up or once scrolling stops.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  bool _navVisible = true;
  Timer? _showAgain;

  @override
  void dispose() {
    _showAgain?.cancel();
    super.dispose();
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

    // Back on any other tab returns to Home before leaving the app.
    return PopScope(
      canPop: tab == HomeTab.dashboard,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) tabs.select(HomeTab.dashboard);
      },
      child: Scaffold(
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: IndexedStack(
                index: tab.index,
                children: [
                  DashboardScreen(
                    onOpenReminders: () => tabs.select(HomeTab.reminders),
                    onOpenExpenses: () => tabs.select(HomeTab.expenses),
                  ),
                  const RemindersScreen(),
                  const MedicinesScreen(),
                  const DoctorsScreen(),
                  const RecordsScreen(),
                  const ExpensesScreen(),
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
                      onSelected: (t) {
                        _setNav(true);
                        tabs.select(t);
                      },
                      onAdd: () => showAddActionSheet(context),
                      onMore: () => showMoreSheet(
                        context,
                        current: tab,
                        onSelected: tabs.select,
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
