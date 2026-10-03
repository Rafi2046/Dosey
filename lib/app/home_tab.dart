import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/constants.dart';
import '../core/localization/l10n.dart';

/// Bottom-navigation destinations, in display order.
enum HomeTab {
  dashboard(Icons.space_dashboard_rounded, context.l10n.navHome),
  reminders(Icons.alarm_rounded, context.l10n.navReminders),
  medicines(Icons.medication_rounded, context.l10n.navMedicines),
  doctors(Icons.medical_services_rounded, context.l10n.navDoctors),
  records(Icons.folder_copy_rounded, context.l10n.navRecords),
  expenses(Icons.account_balance_wallet_rounded, context.l10n.navExpenses);

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
