import 'package:dosey/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats poisha as taka with lakh grouping', () {
    expect(Money.format(125050), '৳1,250.50');
    expect(Money.format(0), '৳0.00');
    expect(Money.format(1234567800), '৳1,23,45,678.00');
  });

  test('parses user input to poisha', () {
    expect(Money.parse('1,250.5'), 125050);
    expect(Money.parse('৳ 12'), 1200);
    expect(Money.parse('0.1'), 10);
    expect(Money.parse('-5'), isNull);
    expect(Money.parse('abc'), isNull);
  });
}
