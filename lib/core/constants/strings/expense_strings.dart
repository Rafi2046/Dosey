/// Expense tracker text.
abstract final class ExpenseStrings {
  static const String expenses = 'Expenses';
  static const String addExpense = 'Add expense';
  static const String expenseTitle = 'Description';
  static const String expenseAmount = 'Amount';
  static const String expenseQuantity = 'Quantity';
  static const String expenseCategory = 'Category';
  static const String expenseDate = 'Date';
  static const String expenseNotes = 'Notes';
  static const String noExpenses = 'No expenses recorded';
  static const String projectedMonthly = 'Projected monthly medicine cost';
  static const String categoryMedicine = 'Medicine';
  static const String categoryConsultation = 'Consultation';
  static const String categoryTest = 'Test';
  static const String categoryVaccine = 'Vaccine';
  static const String categoryOther = 'Other';
  static const String expensesTitle = 'Your\nExpenses';
  static const String byCategory = 'By category';
  static const String medicineCosts = 'Projected medicine costs';
  static const String projectedHint =
      'Based on your active medicines, their price and reminder times.';
  static const String noProjection =
      'Add a price per unit to a medicine to see projected costs.';
  static const String expenseTitleHint = 'e.g. Napa 500mg strip';
  static const String expenseMedicine = 'Medicine';
  static const String expenseDoctor = 'Doctor';
  static const String deleteExpenseBody = 'This expense will be removed.';
  static String perDay(String amount) => '$amount / day';
  static String dosesPerDayLabel(double n) =>
      '${n == n.roundToDouble() ? n.toInt() : n.toStringAsFixed(1)} / day';
}
