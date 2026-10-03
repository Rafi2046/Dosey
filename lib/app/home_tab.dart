import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/l10n.dart';

/// Bottom-navigation destinations, in display order.
enum HomeTab {
  dashboard(Icons.space_dashboard_rounded),
  reminders(Icons.alarm_rounded),
  medicines(Icons.medication_rounded),
  doctors(Icons.medical_services_rounded),
  records(Icons.folder_copy_rounded),
  expenses(Icons.account_balance_wallet_rounded);

  const HomeTab(this.icon);

  final IconData icon;

  String label(AppLocalizations l) => switch (this) {
    dashboard => l.navHome,
    reminders => l.navReminders,
    medicines => l.navMedicines,
    doctors => l.navDoctors,
    records => l.navRecords,
    expenses => l.navExpenses,
  };
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
