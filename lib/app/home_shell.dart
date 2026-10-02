import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/doctors/presentation/doctors_screen.dart';
import '../features/expenses/presentation/expenses_screen.dart';
import '../features/medicines/presentation/medicines_screen.dart';
import '../features/records/presentation/records_screen.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import 'home_tab.dart';
import 'widgets/add_action_sheet.dart';
import 'widgets/floating_nav_bar.dart';

/// Main app frame: tab content (state kept alive) under a floating nav bar.
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
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: FloatingNavBar(
                  current: tab,
                  onSelected: tabs.select,
                  onAdd: () => showAddActionSheet(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
