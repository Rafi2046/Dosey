import 'dart:convert';

import 'package:flutter/services.dart';

/// A hospital / clinic / practice from OpenStreetMap
/// (assets/data/bd_health_facilities.json, built by
/// tool/osm/build_health_facilities.py).
class HealthFacility {
  const HealthFacility({
    required this.name,
    this.otherName = '',
    this.address = '',
    this.phone = '',
  });

  /// English name when OSM has one, else the local name.
  final String name;

  /// The name in the other script (usually Bengali), for search.
  final String otherName;
  final String address;
  final String phone;
}

/// Offline search over Bangladesh's health facilities. Nothing leaves the
/// phone: the list ships with the app.
class HealthFacilityIndex {
  HealthFacilityIndex(this.facilities)
    : _keys = [
        for (final f in facilities) '${f.name} ${f.otherName}'.toLowerCase(),
      ];

  static const String asset = 'assets/data/bd_health_facilities.json';
  static const int defaultLimit = 8;

  final List<HealthFacility> facilities;
  final List<String> _keys;

  static Future<HealthFacilityIndex> load(AssetBundle bundle) async {
    final json =
        jsonDecode(await bundle.loadString(asset)) as Map<String, dynamic>;
    return HealthFacilityIndex([
      for (final row in json['facilities'] as List<dynamic>)
        HealthFacility(
          name: row[0] as String,
          otherName: row[1] as String,
          address: row[2] as String,
          phone: row[3] as String,
        ),
    ]);
  }

  /// Best matches for [query]: names starting with it first, then a word
  /// starting with it, then anywhere. Case-insensitive, English or Bengali.
  List<HealthFacility> search(String query, {int limit = defaultLimit}) {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return const [];
    final ranked = <(int, int)>[];
    for (var i = 0; i < _keys.length; i++) {
      final key = _keys[i];
      final at = key.indexOf(q);
      if (at < 0) continue;
      final rank = at == 0
          ? 0
          : key[at - 1] == ' '
          ? 1
          : 2;
      ranked.add((rank, i));
    }
    ranked.sort((a, b) {
      final byRank = a.$1.compareTo(b.$1);
      return byRank != 0
          ? byRank
          : facilities[a.$2].name.length.compareTo(
              facilities[b.$2].name.length,
            );
    });
    return [for (final (_, i) in ranked.take(limit)) facilities[i]];
  }
}
