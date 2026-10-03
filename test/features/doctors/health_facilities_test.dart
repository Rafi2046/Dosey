import 'package:dosey/features/doctors/data/health_facilities.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final index = HealthFacilityIndex(const [
    HealthFacility(name: 'Popular Diagnostic Centre, Dhanmondi'),
    HealthFacility(name: 'Square Hospital', otherName: 'স্কয়ার হাসপাতাল'),
    HealthFacility(name: 'Ibn Sina Hospital Square'),
    HealthFacility(name: 'Squarepoint Clinic'),
  ]);

  List<String> names(String q) => [for (final f in index.search(q)) f.name];

  test('ranks name prefixes, then word starts, then anywhere', () {
    expect(names('square'), [
      'Square Hospital',
      'Squarepoint Clinic',
      'Ibn Sina Hospital Square',
    ]);
    expect(names('diag'), ['Popular Diagnostic Centre, Dhanmondi']);
  });

  test('matches the Bengali name, ignores case and very short queries', () {
    expect(names('স্কয়ার'), ['Square Hospital']);
    expect(names('SQUAREPOINT'), ['Squarepoint Clinic']);
    expect(names('s'), isEmpty);
  });

  test('respects the limit', () {
    expect(index.search('a', limit: 2), isEmpty);
    expect(index.search('hospital', limit: 1), hasLength(1));
  });

  test('the bundled list loads and finds real hospitals', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final loaded = await HealthFacilityIndex.load(rootBundle);
    expect(loaded.facilities.length, greaterThan(1000));
    expect(loaded.search('square'), isNotEmpty);
  });
}
