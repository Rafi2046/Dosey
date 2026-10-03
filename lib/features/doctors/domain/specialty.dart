import '../../../core/localization/l10n.dart';

/// Common specialties in Bangladesh, for the doctor form's suggestions and
/// for recognising the specialty printed on a prescription.
///
/// Doctors store the English label, so a doctor saved in Bengali still
/// shows correctly after switching language; free text (anything else the
/// user typed) is kept and shown as-is.
enum Specialty {
  medicine(['medicine', 'internal medicine', 'মেডিসিন']),
  generalPhysician(['general physician', 'family physician', 'gp']),
  cardiology(['cardio', 'heart', 'হৃদরোগ']),
  endocrinology(['diabet', 'endocrin', 'hormone', 'ডায়াবেটিস']),
  paediatrics(['child', 'paediatric', 'pediatric', 'neonat', 'শিশু']),
  gynaecology(['gyn', 'obstet', 'স্ত্রীরোগ']),
  surgery(['surgery', 'surgeon', 'laparoscop', 'সার্জারি']),
  orthopaedics(['ortho', 'bone', 'joint', 'trauma', 'হাড়']),
  neurology(['neuro', 'brain', 'stroke', 'স্নায়ু']),
  nephrology(['nephro', 'kidney', 'কিডনি']),
  gastroenterology(['gastro', 'liver', 'hepato', 'লিভার']),
  pulmonology(['chest', 'pulmo', 'asthma', 'respiratory', 'বক্ষ']),
  ent(['ent', 'ear', 'throat', 'otolaryng', 'নাক']),
  eye(['eye', 'ophthal', 'চক্ষু']),
  dermatology(['skin', 'derma', 'venereo', 'চর্ম']),
  psychiatry(['psychiat', 'mental', 'মানসিক']),
  urology(['urolog', 'ইউরোলজি']),
  oncology(['cancer', 'oncolog', 'ক্যান্সার']),
  rheumatology(['rheumat', 'arthritis', 'বাত']),
  dentistry(['dental', 'dentist', 'bds', 'দন্ত']),
  physicalMedicine(['physical medicine', 'physiotherap', 'rehab']),
  nutrition(['nutrition', 'dietitian', 'পুষ্টি']);

  const Specialty(this._keywords);

  /// Lower-case fragments that identify this specialty in free text.
  final List<String> _keywords;

  String label(AppLocalizations l) => switch (this) {
    medicine => l.specMedicine,
    generalPhysician => l.specGeneralPhysician,
    cardiology => l.specCardiology,
    endocrinology => l.specEndocrinology,
    paediatrics => l.specPaediatrics,
    gynaecology => l.specGynaecology,
    surgery => l.specSurgery,
    orthopaedics => l.specOrthopaedics,
    neurology => l.specNeurology,
    nephrology => l.specNephrology,
    gastroenterology => l.specGastroenterology,
    pulmonology => l.specPulmonology,
    ent => l.specEnt,
    eye => l.specEye,
    dermatology => l.specDermatology,
    psychiatry => l.specPsychiatry,
    urology => l.specUrology,
    oncology => l.specOncology,
    rheumatology => l.specRheumatology,
    dentistry => l.specDentistry,
    physicalMedicine => l.specPhysicalMedicine,
    nutrition => l.specNutrition,
  };

  /// What gets saved: the English label.
  String get stored => label(lookupAppLocalizations(AppLocale.english));

  /// The specialty a saved value or free text refers to, if any: an exact
  /// label in either language, else the first keyword match (so "Medicine
  /// Specialist" or "Child Specialist" on a prescription are recognised).
  static Specialty? match(String? text) {
    final t = text?.trim().toLowerCase();
    if (t == null || t.isEmpty) return null;
    final exactMatch = exact(t);
    if (exactMatch != null) return exactMatch;
    // The keyword appearing earliest wins: "ENT Surgeon" is ENT, not
    // surgery; ties go to the longer (more specific) keyword.
    Specialty? best;
    var bestAt = t.length;
    var bestLength = 0;
    for (final s in values) {
      for (final k in s._keywords) {
        final at = k.length <= 3
            ? RegExp(
                '(^|[^a-z])${RegExp.escape(k)}([^a-z]|\$)',
              ).firstMatch(t)?.start
            : _indexOf(t, k);
        if (at == null) continue;
        if (at < bestAt || (at == bestAt && k.length > bestLength)) {
          best = s;
          bestAt = at;
          bestLength = k.length;
        }
      }
    }
    return best;
  }

  static int? _indexOf(String text, String keyword) {
    final at = text.indexOf(keyword);
    return at < 0 ? null : at;
  }

  /// The specialty whose label (English or Bengali) is exactly [text].
  static Specialty? exact(String text) {
    final t = text.trim().toLowerCase();
    final bn = lookupAppLocalizations(AppLocale.bangla);
    return values
        .where(
          (s) => t == s.stored.toLowerCase() || t == s.label(bn).toLowerCase(),
        )
        .firstOrNull;
  }

  /// What to save for the specialty field: the English label when it's one
  /// of ours (in either language), else the text as typed.
  static String? toStored(String text) {
    final t = text.trim();
    if (t.isEmpty) return null;
    return exact(t)?.stored ?? t;
  }

  /// List suggestions for what's typed so far (all of them when empty).
  static List<Specialty> suggest(String text, AppLocalizations l) {
    final t = text.trim().toLowerCase();
    if (t.isEmpty) return values;
    return [
      for (final s in values)
        if (s.label(l).toLowerCase().contains(t) ||
            s.stored.toLowerCase().contains(t) ||
            s._keywords.any((k) => k.startsWith(t)))
          s,
    ];
  }

  /// A saved specialty in the current language (free text unchanged).
  static String display(String stored, AppLocalizations l) =>
      switch (values.where((s) => s.stored == stored).firstOrNull) {
        final s? => s.label(l),
        null => stored,
      };
}
