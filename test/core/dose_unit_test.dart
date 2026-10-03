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
