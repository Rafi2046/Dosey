import 'package:dosey/core/database/app_database.dart';
import 'package:dosey/features/medicines/domain/stock_status.dart';
import 'package:flutter_test/flutter_test.dart';

Medicine _medicine({double? stock, int? alertDays, double? threshold}) =>
    Medicine(
      profileId: 1,
      id: 1,
      name: 'Zulfidin',
      form: MedicineForm.tablet,
      doseUnit: 'tablet',
      mealRelation: MealRelation.afterMeal,
      unitPriceMinor: 0,
      stockQuantity: stock,
      refillThreshold: threshold,
      refillAlertDays: alertDays,
      startDate: DateTime(2026),
      isActive: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  test('days left from the daily dose (6 tablets a day)', () {
    expect(StockStatus(_medicine(stock: 100), 6).daysLeft, 16);
    expect(StockStatus(_medicine(stock: 5), 6).daysLeft, 0);
    // Untracked stock, or nothing scheduled: can't run out.
    expect(StockStatus(_medicine(), 6).daysLeft, isNull);
    expect(StockStatus(_medicine(stock: 30), 0).daysLeft, isNull);
  });

  test('low once within the alert window', () {
    expect(StockStatus(_medicine(stock: 24, alertDays: 3), 6).isLow, isFalse);
    expect(StockStatus(_medicine(stock: 18, alertDays: 3), 6).isLow, isTrue);
    expect(StockStatus(_medicine(alertDays: 3), 6).isLow, isFalse);
  });

  test('medicines saved before v4 keep their tablet-count alert', () {
    expect(StockStatus(_medicine(stock: 12, threshold: 12), 6).isLow, isTrue);
    expect(StockStatus(_medicine(stock: 13, threshold: 12), 6).isLow, isFalse);
  });
}
