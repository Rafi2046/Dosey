/// Home / dashboard text.
abstract final class DashboardStrings {
  static const String nothingScheduled = 'Nothing scheduled. Enjoy your day!';
  static const String goodMorning = 'Good morning';
  static const String goodAfternoon = 'Good afternoon';
  static const String goodEvening = 'Good evening';
  static const String dashboardTitle = "Today's Medicine\nReminders";
  static const String missed = 'Missed';
  static const String skipped = 'Skipped';
  static const String snoozed = 'Snoozed';
  static String nextTypeIn(String type, String duration) =>
      'Next $type in $duration';
  static const String skipDose = 'Skip';
  static String inHoursMinutes(int h, int m) =>
      h == 0 ? '$m min' : (m == 0 ? '$h h' : '$h h $m min');
  static const String morning = 'Morning';
  static const String afternoon = 'Afternoon';
  static const String evening = 'Evening';
  static const String bedtime = 'Bedtime';
  static const String upcoming = 'Coming up';
  static const String medicineCost = 'Medicine cost';
  static const String perMonth = '/ month';
  static const String spentThisMonth = 'Spent this month';
  static const String runningLow = 'Running low';
  static String unitsLeft(String amount) => '$amount left';
}
