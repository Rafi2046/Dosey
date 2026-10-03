/// App-wide text: name, navigation, shared actions and labels.
abstract final class AppStrings {
  static const String appName = 'Dosey';
  static const String navHome = 'Home';
  static const String navReminders = 'Reminders';
  static const String navMedicines = 'Medicines';
  static const String navRecords = 'Records';
  static const String navDoctors = 'Doctors';
  static const String navExpenses = 'Expenses';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String archive = 'Archive';
  static const String none = 'None';
  static const String deleteConfirmTitle = 'Delete this item?';
  static const String deleteConfirmBody = 'This cannot be undone.';
  static const String seeAll = 'See all';
  static const String all = 'All';
  static const String active = 'Active';
  static const String optional = 'Optional';
  static const String saveChanges = 'Save changes';
  static const String saved = 'Saved';
  static const String next = 'Next';
  static const String ongoing = 'Ongoing';
  static const String call = 'Call';
  static const String email = 'Email';
  static const String details = 'Details';
  static const String choose = 'Choose';
  static const String clear = 'Clear';
  static const String addTime = 'Add time';
  static const String done = 'Done';
  static const String daysUnit = 'days';
  static String daysCount(int n) => n == 1 ? '1 day' : '$n days';
  static String pagesCount(int n) => n == 1 ? '1 page' : '$n pages';
  static const String addSheetTitle = 'What would you like to add?';
}
