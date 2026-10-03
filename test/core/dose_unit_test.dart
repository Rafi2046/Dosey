import 'package:dosey/core/localization/l10n.dart';
import 'package:dosey/core/utils/dose_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final en = lookupAppLocalizations(AppLocale.english);
  final bn = lookupAppLocalizations(AppLocale.bangla);

  test('built-in units follow the current language', () {
    // Saved while the app was in Bengali, shown in English (and back).
    expect(DoseUnit.display('ট্যাবলেট', en), 'tablet');
    expect(DoseUnit.display('মি.লি.', en), 'ml');
    expect(DoseUnit.display('tablet', bn), 'ট্যাবলেট');
    expect(DoseUnit.display('Tablets', bn), 'ট্যাবলেট');
    expect(DoseUnit.display('capsule', en), 'capsule');
  });

  test('English units are plural above one', () {
    expect(DoseUnit.withAmount(1, 'tablet', en), '1 tablet');
    expect(DoseUnit.withAmount(0.5, 'tablet', en), '0.5 tablet');
    expect(DoseUnit.withAmount(2, 'ট্যাবলেট', en), '2 tablets');
    expect(DoseUnit.withAmount(1.5, 'capsule', en), '1.5 capsules');
    expect(DoseUnit.withAmount(5, 'ml', en), '5 ml');
    expect(DoseUnit.withAmount(3, 'drop', en), '3 drops');
    // Typed units are left alone; "tablets" is still recognised.
    expect(DoseUnit.withAmount(2, 'mg', en), '2 mg');
    expect(DoseUnit.toStored('Tablets'), 'tablet');
  });

  test('typed units are kept as written', () {
    expect(DoseUnit.display('mg', bn), 'mg');
    expect(DoseUnit.display('স্যাশে', en), 'স্যাশে');
  });

  test('built-in units are saved in English, typed ones trimmed', () {
    expect(DoseUnit.toStored('ট্যাবলেট'), 'tablet');
    expect(DoseUnit.toStored(' ফোঁটা '), 'drop');
    expect(DoseUnit.toStored('ml'), 'ml');
    expect(DoseUnit.toStored(' mg '), 'mg');
  });
}
