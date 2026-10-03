import 'package:flutter/material.dart';
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
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            IndexedStack(
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
            // Content scrolling under the nav bar fades out instead of
            // peeking around it.
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
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
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: AppNavBar(
                  current: tab,
                  onSelected: tabs.select,
                  onAdd: () => showAddActionSheet(context),
                  onMore: () => showMoreSheet(
                    context,
                    current: tab,
                    onSelected: tabs.select,
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
