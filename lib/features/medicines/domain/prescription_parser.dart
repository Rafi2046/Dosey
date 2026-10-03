import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/enums.dart';
import 'scanned_medicine.dart';

/// Turns OCR'd prescription lines into medicine suggestions with regexes and
/// heuristics. Tuned for typed/printed prescriptions in the common South
/// Asian format ("Tab. Napa 500mg  1+0+1  after meal  x 7 days") and for
/// Latin abbreviations (OD, BD, TDS, QID, HS). Handwriting OCRs poorly, so
/// every result is only a suggestion for the user to review.
abstract final class PrescriptionParser {
  /// Lines after a medicine that may hold its instructions.
  static const int _maxInstructionLines = 2;
  static const int _maxNameWords = 4;
  static const int _maxDurationDays = 365;

  static List<ScannedMedicine> parse(List<String> rawLines) {
    final lines = [
      for (final l in rawLines) l.replaceAll(RegExp(r'\s+'), ' ').trim(),
    ]..removeWhere((l) => l.isEmpty);

    final found = <ScannedMedicine>[];
    final seen = <String>{};
    for (var i = 0; i < lines.length; i++) {
      final head = _head(lines[i]);
      if (head == null) continue;
      // Instructions often sit on the line(s) below, up to the next medicine.
      final extra = <String>[];
      for (
        var j = i + 1;
        j < lines.length && j <= i + _maxInstructionLines;
        j++
      ) {
        if (_head(lines[j]) != null || _noise.hasMatch(lines[j])) break;
        extra.add(lines[j]);
      }
      final med = _build(head, extra);
      if (med != null && seen.add(med.name.toLowerCase())) found.add(med);
    }
    return found;
  }

  // ── Medicine lines ────────────────────────────────────────────────────────

  static final _numbering = RegExp(
    r'^(?:rx\s*[:.]?\s*)?(?:\d{1,2}\s*[.)]\s*)?',
    caseSensitive: false,
  );

  static final _formPrefix = RegExp(
    r'^(tablets?|tabs?|capsules?|caps?|syrup|syp|syr|suspension|susp|'
    r'injection|inj|drops?|gtt|inhaler|inh|cream|ointment|oint|gel)\b\.?\s*',
    caseSensitive: false,
  );

  static MedicineForm _formFor(String prefix) {
    final p = prefix.toLowerCase();
    if (p.startsWith('tab')) return MedicineForm.tablet;
    if (p.startsWith('cap')) return MedicineForm.capsule;
    if (p.startsWith('sy') || p.startsWith('sus')) return MedicineForm.syrup;
    if (p.startsWith('inj')) return MedicineForm.injection;
    if (p.startsWith('drop') || p == 'gtt') return MedicineForm.drops;
    if (p.startsWith('inh')) return MedicineForm.inhaler;
    return MedicineForm.cream;
  }

  /// 500mg · 0.5 mg · 120mg/5ml · 1% · 1000 IU (not lab values like mg/dl).
  static final _strength = RegExp(
    r'(?<![\w.])\d+(?:\.\d+)?\s?(?:mg|mcg|µg|gm|g|ml|iu|%)'
    r'(?:\s?/\s?\d*(?:\.\d+)?\s?(?:mg|ml|g)\b)?(?!\s?/\s?dl)(?![a-z])',
    caseSensitive: false,
  );

  /// Header/footer/vitals lines that are never medicines.
  static final _noise = RegExp(
    r'\b(?:dr|doctor|mbbs|fcps|frcs|bcs|md|consultant|professor|hospital|'
    r'clinic|college|phone|mobile|cell|tel|email|age|sex|date|patient|pt|reg|'
    r'bmdc|address|weight|wt|bp|pulse|diagnosis|dx|c/c|o/e|investigations?|'
    r'advice|adv|cbc|x-ray|follow[- ]?up|signature|chamber|visit)\b',
    caseSensitive: false,
  );

  static final _leadingWord = RegExp(r'^[A-Za-z][A-Za-z]{2,}');

  static _Head? _head(String line) {
    final body = line.replaceFirst(_numbering, '');
    final prefix = _formPrefix.firstMatch(body);
    if (prefix != null) {
      final rest = body.substring(prefix.end);
      return RegExp('^[A-Za-z]').hasMatch(rest)
          ? _Head(_formFor(prefix.group(1)!), rest)
          : null;
    }
    // No "Tab."/"Cap." prefix: accept "Name 500mg …" lines only.
    if (_strength.hasMatch(body) &&
        _leadingWord.hasMatch(body) &&
        !_noise.hasMatch(body)) {
      return _Head(null, body);
    }
    return null;
  }

  // ── Building a suggestion ─────────────────────────────────────────────────

  static final _nameRun = RegExp(r"^[A-Za-z][\w'\-]*(?:\s+[A-Za-z][\w'\-]*)*");
  static final _bareNumber = RegExp(
    r'^\s*(\d{1,4}(?:\.\d+)?)(?![\d.]|\s*[+\-–/])',
  );

  /// Words that end a name: schedule, meal and unit words.
  static const _nameStop = {
    'od', 'qd', 'bd', 'bid', 'tds', 'tid', 'qid', 'qds', 'hs', 'daily', //
    'once', 'twice', 'thrice', 'morning', 'noon', 'afternoon', 'evening',
    'night', 'bedtime', 'before', 'after', 'with', 'empty', 'for', 'x',
    'every', 'at', 'tab', 'tabs', 'tablet', 'tablets', 'cap', 'caps',
    'capsule', 'capsules', 'ml', 'mg', 'drop', 'drops', 'puff', 'puffs',
    'spoon', 'tsf', 'days', 'day', 'weeks', 'week', 'months', 'month',
  };

  static ScannedMedicine? _build(_Head head, List<String> extra) {
    final run = _nameRun.firstMatch(head.body)?.group(0) ?? '';
    final words = <String>[];
    for (final w in run.split(' ')) {
      if (_nameStop.contains(w.toLowerCase()) ||
          words.length == _maxNameWords) {
        break;
      }
      words.add(w);
    }
    if (words.isEmpty) return null;
    final name = words.map(_titleCase).join(' ');
    final afterName = head.body.substring(words.join(' ').length);

    final strengthMatch = _strength.firstMatch(head.body);
    final strength =
        strengthMatch?.group(0)?.replaceAll(' ', '') ??
        _bareNumber.firstMatch(afterName)?.group(1);

    var text = [afterName, ...extra].join(' ');
    if (strengthMatch != null) {
      text = text.replaceFirst(strengthMatch.group(0)!, ' ');
    }
    final lower = text.toLowerCase();
    final schedule = _schedule(lower);

    return ScannedMedicine(
      name: name,
      strength: strength,
      form: head.form,
      doseAmount: schedule?.amount ?? _amount(lower),
      times: schedule?.times ?? const [],
      meal: _meal(lower),
      durationDays: _duration(lower),
      dosePattern: schedule?.label,
    );
  }

  /// "NAPA" → "Napa"; mixed case and words with digits stay as written.
  static String _titleCase(String w) =>
      w.length > 1 && w == w.toUpperCase() && !RegExp(r'\d').hasMatch(w)
      ? w[0] + w.substring(1).toLowerCase()
      : w;

  // ── Schedule ──────────────────────────────────────────────────────────────

  static const _m = AppConstants.doseMorningHour;
  static const _n = AppConstants.doseNoonHour;
  static const _e = AppConstants.doseEveningHour;
  static const _h = AppConstants.doseNightHour;

  static const _part = r'([0-4](?:\.5)?|½|1/2)';
  static const _sep = r'\s*[+\-–]\s*';

  /// 1+0+1 · 1-0-1 · ½+0+½ · 1+1+1+1 (morning, noon, [evening,] night).
  static final _numericPattern = RegExp(
    '(?<![\\d./])$_part$_sep$_part$_sep$_part(?:$_sep$_part)?'
    r'(?![\d./]|\s*(?:days?|weeks?|wks?|months?|mo)\b)',
  );

  /// Checked in order; the first match wins.
  static final _frequencyWords = <(RegExp, List<int>)>[
    (RegExp(r'\b(qid|qds|four times)\b'), [_m, _n, _e, _h]),
    (RegExp(r'\b(tds|tid|thrice|three times)\b'), [_m, _n, _h]),
    (RegExp(r'\b(bd|bid|twice)\b'), [_m, _h]),
    (RegExp(r'\b(od|qd|once|daily)\b'), [_m]),
  ];

  static final _slotWords = <(RegExp, int)>[
    (RegExp(r'\b(morning|breakfast)\b'), _m),
    (RegExp(r'\b(noon|afternoon|lunch)\b'), _n),
    (RegExp(r'\b(evening)\b'), _e),
    (RegExp(r'\b(night|bedtime|hs|before sleep|dinner)\b'), _h),
  ];

  static final _interval = RegExp(
    r'\bevery\s*(\d{1,2})\s*(?:h|hrs?|hours?)\b|\b(\d{1,2})\s*(?:-\s*)?(?:hourly|hrly)\b|\bq(\d{1,2})h\b',
  );

  static _Schedule? _schedule(String text) {
    final numeric = _numericPattern.firstMatch(text);
    if (numeric != null) {
      final values = [
        for (var g = 1; g <= 4; g++)
          if (numeric.group(g) case final v?) _number(v),
      ];
      final slots = values.length == 4 ? [_m, _n, _e, _h] : [_m, _n, _h];
      final hours = [
        for (var i = 0; i < values.length; i++)
          if (values[i] > 0) slots[i],
      ];
      if (hours.isEmpty) return null;
      return _Schedule(
        _times(hours),
        values.firstWhere((v) => v > 0),
        numeric.group(0)!.replaceAll(' ', ''),
      );
    }

    final interval = _interval.firstMatch(text);
    if (interval != null) {
      final every = int.parse(
        interval.group(1) ?? interval.group(2) ?? interval.group(3)!,
      );
      if (every > 0 && every <= Duration.hoursPerDay) {
        return _Schedule(
          _times([
            for (var k = 0; k < Duration.hoursPerDay ~/ every; k++)
              (AppConstants.doseIntervalStartHour + k * every) %
                  Duration.hoursPerDay,
          ]),
          null,
          interval.group(0)!,
        );
      }
    }

    final slotHours = [
      for (final (re, hour) in _slotWords)
        if (re.hasMatch(text)) hour,
    ];
    for (final (re, hours) in _frequencyWords) {
      final match = re.firstMatch(text);
      if (match == null) continue;
      // "once at night": the slot words say when, if the count agrees.
      final useSlots = slotHours.length == hours.length;
      return _Schedule(
        _times(useSlots ? slotHours : hours),
        null,
        match.group(0)!.toUpperCase(),
      );
    }
    if (slotHours.isNotEmpty) {
      return _Schedule(_times(slotHours), null, null);
    }
    return null;
  }

  static List<TimeOfDay> _times(List<int> hours) =>
      (hours.toSet().toList()..sort())
          .map((h) => TimeOfDay(hour: h, minute: 0))
          .toList();

  static double _number(String v) =>
      v == '½' || v == '1/2' ? 0.5 : double.parse(v);

  // ── Amount, meal, duration ────────────────────────────────────────────────

  static final _amountRe = RegExp(
    r'(?<![\d.])(\d+(?:\.\d+)?|½)\s*(?:tablets?|tabs?|capsules?|caps?|ml|'
    r'drops?|puffs?|spoons?|tsf)\b',
  );

  static double? _amount(String text) {
    final m = _amountRe.firstMatch(text);
    return m == null ? null : _number(m.group(1)!);
  }

  static final _before = RegExp(
    r'\bbefore\s+(?:meals?|food|eating|breakfast|lunch|dinner)\b|'
    r'\bempty stomach\b|\bac\b',
  );
  static final _after = RegExp(
    r'\bafter\s+(?:meals?|food|eating|breakfast|lunch|dinner)\b|\bpc\b',
  );
  static final _with = RegExp(r'\bwith\s+(?:meals?|food)\b');

  static MealRelation? _meal(String text) {
    if (_before.hasMatch(text)) return MealRelation.beforeMeal;
    if (_after.hasMatch(text)) return MealRelation.afterMeal;
    if (_with.hasMatch(text)) return MealRelation.withMeal;
    return null;
  }

  static final _durationRe = RegExp(
    r'(?<![\d.])(\d{1,3})\s*(days?|weeks?|wks?|months?|mo)\b',
  );

  static int? _duration(String text) {
    final m = _durationRe.firstMatch(text);
    if (m == null) return null;
    final n = int.parse(m.group(1)!);
    final unit = m.group(2)!;
    final days = unit.startsWith('d')
        ? n
        : unit.startsWith('w')
        ? n * AppConstants.daysPerWeek
        : n * AppConstants.daysPerMonth;
    return days > 0 && days <= _maxDurationDays ? days : null;
  }
}

class _Head {
  const _Head(this.form, this.body);
  final MedicineForm? form;

  /// The line after numbering and the form prefix: "Napa 500mg 1+0+1".
  final String body;
}

class _Schedule {
  const _Schedule(this.times, this.amount, this.label);
  final List<TimeOfDay> times;
  final double? amount;
  final String? label;
}
