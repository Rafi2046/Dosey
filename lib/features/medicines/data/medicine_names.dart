import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/database/app_database.dart';

/// A medicine name to suggest while typing: a common Bangladeshi brand
/// (assets/data/bd_medicines.json) or one the user has saved before.
class MedicineName {
  const MedicineName({
    required this.name,
    this.generic = '',
    this.strength = '',
    this.form,
  });

  final String name;

  /// Active ingredient(s), shown under the name ("Paracetamol").
  final String generic;
  final String strength;
  final MedicineForm? form;

  /// "Paracetamol · 500 mg", or null when there's nothing to add.
  String? get subtitle {
    final parts = [generic, strength].where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

/// Offline name search. Suggestions only fill the name and strength: the
/// user still checks them against the prescription.
class MedicineNameIndex {
  MedicineNameIndex(this.names);

  static const String asset = 'assets/data/bd_medicines.json';
  static const int defaultLimit = 6;

  final List<MedicineName> names;

  static Future<MedicineNameIndex> load(AssetBundle bundle) async {
    final json =
        jsonDecode(await bundle.loadString(asset)) as Map<String, dynamic>;
    return MedicineNameIndex([
      for (final row in json['medicines'] as List<dynamic>)
        MedicineName(
          name: row[0] as String,
          generic: row[1] as String,
          strength: row[2] as String,
          form: MedicineForm.values.asNameMap()[row[3] as String],
        ),
    ]);
  }

  /// [saved] medicines first (the user's own spelling), then the built-in
  /// list, without repeating a name.
  MedicineNameIndex withSaved(Iterable<Medicine> saved) {
    final seen = <String>{};
    return MedicineNameIndex([
      for (final m in saved)
        if (seen.add(m.name.toLowerCase()))
          MedicineName(name: m.name, strength: m.strength ?? '', form: m.form),
      for (final n in names)
        if (seen.add(n.name.toLowerCase())) n,
    ]);
  }

  /// Best matches for [query] by brand or generic name: starting with it
  /// first, then a word starting with it, then anywhere.
  List<MedicineName> search(String query, {int limit = defaultLimit}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final ranked = <(int, int)>[];
    for (var i = 0; i < names.length; i++) {
      final key = '${names[i].name} ${names[i].generic}'.toLowerCase();
      final at = key.indexOf(q);
      if (at < 0) continue;
      final rank = at == 0
          ? 0
          : ' +-('.contains(key[at - 1])
          ? 1
          : 2;
      ranked.add((rank, i));
    }
    // Stable: equal ranks keep the list's order (saved names first).
    ranked.sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
    return [for (final (_, i) in ranked.take(limit)) names[i]];
  }
}
