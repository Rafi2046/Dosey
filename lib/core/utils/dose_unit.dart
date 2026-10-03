import '../database/enums.dart';
import '../localization/l10n.dart';
import 'enum_labels.dart';

/// The built-in dose units ("tablet", "ml"…) are saved language-neutral
/// (in English) and shown in the app's current language, so switching
/// language also switches "2 ট্যাবলেট" ↔ "2 tablet". Units the user typed
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
        final unit = form.defaultUnit(l).toLowerCase();
        if (t == unit || t == '${unit}s') return form;
      }
    }
    return null;
  }

  /// [stored] in the current language of [l].
  static String display(String stored, AppLocalizations l) =>
      _match(stored)?.defaultUnit(l) ?? stored;

  /// What to save for the unit the user sees as [text].
  static String toStored(String text) {
    final form = _match(text);
    return form == null
        ? text.trim()
        : form.defaultUnit(lookupAppLocalizations(AppLocale.english));
  }
}
