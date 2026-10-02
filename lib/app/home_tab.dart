import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/constants.dart';

/// Bottom-navigation destinations, in display order.
enum HomeTab {
  dashboard(Icons.space_dashboard_rounded, AppStrings.navHome),
  reminders(Icons.alarm_rounded, AppStrings.navReminders),
  medicines(Icons.medication_rounded, AppStrings.navMedicines),
  doctors(Icons.medical_services_rounded, AppStrings.navDoctors),
  records(Icons.folder_copy_rounded, AppStrings.navRecords),
  expenses(Icons.account_balance_wallet_rounded, AppStrings.navExpenses);

  const HomeTab(this.icon, this.label);

  final IconData icon;
  final String label;
}

/// Selected tab; any screen can switch tabs (e.g. dashboard → expenses).
final homeTabProvider = NotifierProvider<HomeTabNotifier, HomeTab>(
  HomeTabNotifier.new,
);

class HomeTabNotifier extends Notifier<HomeTab> {
  @override
  HomeTab build() => HomeTab.dashboard;

  void select(HomeTab tab) => state = tab;
}
