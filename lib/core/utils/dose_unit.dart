import '../database/enums.dart';
import '../localization/l10n.dart';
import 'enum_labels.dart';
import 'numbers.dart';

/// The built-in dose units ("tablet", "ml"…) are saved language-neutral
/// (in English) and shown in the app's current language, so switching
/// language also switches "2 ট্যাবলেট" ↔ "2 tablets". Units the user typed
/// themselves ("mg", "sachet") are kept and shown as written.
abstract final class DoseUnit {
  static final List<AppLocalizations> _all = [
    for (final locale in AppLocalizations.supportedLocales)
      lookupAppLocalizations(locale),
  ];

  /// The form whose unit [text] is, in any language ("Tablets" counts).
  static MedicineForm? _match(String text) {
    final t = text.trim().toLowerCase();
    if (t.isEmpty) return null;
    for (final form in MedicineForm.values) {
      for (final l in _all) {
        if (t == form.defaultUnit(l).toLowerCase() ||
            t == form.defaultUnitPlural(l).toLowerCase()) {
          return form;
        }
      }
    }
    return null;
  }

  /// [stored] in the current language of [l], plural when [amount] is more
  /// than one ("1 tablet", "0.5 tablet", "2 tablets").
  static String display(String stored, AppLocalizations l, {num amount = 1}) {
    final form = _match(stored);
    if (form == null) return stored;
    return amount > 1 ? form.defaultUnitPlural(l) : form.defaultUnit(l);
  }

  /// "2 tablets", "1 tablet", "5 ml".
  static String withAmount(num amount, String stored, AppLocalizations l) =>
      '${AppNumber.format(amount)} ${display(stored, l, amount: amount)}';

  /// What to save for the unit the user sees as [text].
  static String toStored(String text) {
    final form = _match(text);
    return form == null
        ? text.trim()
        : form.defaultUnit(lookupAppLocalizations(AppLocale.english));
  }
}
