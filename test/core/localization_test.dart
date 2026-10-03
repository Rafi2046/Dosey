import 'dart:convert';
import 'dart:io';

import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/core/utils/date_format.dart';
import 'package:dosey/core/utils/money.dart';
import 'package:dosey/core/utils/numbers.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String code) =>
    jsonDecode(
          File('lib/core/localization/arb/app_$code.arb').readAsStringSync(),
        )
        as Map<String, dynamic>;

Set<String> _placeholders(String message) => {
  for (final m in RegExp(r'\{(\w+)').allMatches(message)) m.group(1)!,
};

void main() {
  setUpAll(AppLocale.ensureInitialized);
  tearDown(() => AppLocale.apply(AppLocale.english));

  test('Bengali translates every English message, same placeholders', () {
    final en = _arb('en');
    final bn = _arb('bn');
    final keys = en.keys.where((k) => !k.startsWith('@'));
    for (final key in keys) {
      expect(bn, contains(key), reason: 'app_bn.arb is missing "$key"');
      // Plural keywords (other, =1) aren't placeholders; compare names that
      // look like arguments only.
      final metadata = en['@$key'] as Map<String, dynamic>?;
      final args =
          (metadata?['placeholders'] as Map<String, dynamic>?)?.keys.toSet() ??
          <String>{};
      expect(
        _placeholders(bn[key] as String).intersection(args),
        args,
        reason: '"$key" must use the same placeholders in Bengali',
      );
    }
    expect(bn.keys.where((k) => !k.startsWith('@')), hasLength(keys.length));
  });

  test('resolve: saved choice wins, else phone language, else English', () {
    expect(AppLocale.resolve('bn', const Locale('en')), AppLocale.bangla);
    expect(AppLocale.resolve('en', const Locale('bn')), AppLocale.english);
    expect(AppLocale.resolve(null, const Locale('bn', 'BD')), AppLocale.bangla);
    expect(AppLocale.resolve(null, const Locale('fr')), AppLocale.english);
  });

  test('Bengali uses Bengali digits for numbers, money, dates', () {
    final at = DateTime(2026, 10, 5, 9, 30);
    AppLocale.apply(AppLocale.english);
    expect(AppNumber.format(2.5), '2.5');
    expect(AppDateFormat.date(at), '5 Oct 2026');

    AppLocale.apply(AppLocale.bangla);
    expect(AppNumber.format(2.5), '২.৫');
    expect(AppNumber.format(2), '২');
    expect(AppDateFormat.date(at), contains('২০২৬'));
    expect(Money.format(125050), contains('১,২৫০.৫০'));
    // Inputs keep Latin digits so they can be parsed back.
    expect(Money.formatPlain(125050), '1,250.50');
    expect(AppLocale.l10n.daysCount(3), '৩ দিন');
    expect(AppLocale.l10n.inHoursMinutes(2, 10), '২ ঘণ্টা ১০ মিনিট');
  });
}
