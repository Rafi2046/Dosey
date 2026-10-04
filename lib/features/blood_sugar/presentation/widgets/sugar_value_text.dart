import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/numbers.dart';
import '../../domain/sugar_category.dart';

/// "7.8 mmol/L" and "≈ 140 mg/dL" in the current language's digits.
abstract final class SugarText {
  static const String unit = 'mmol/L';

  static String mmol(double v) => '${AppNumber.format(v)} $unit';

  static String mgDl(AppLocalizations l, double v) =>
      l.sugarMgDl(AppNumber.format((v * SugarCategory.mgPerMmol).round()));
}
