"""Builds assets/data/bd_health_facilities.json from OpenStreetMap.

Hospitals, clinics, doctors' practices and dentists in Bangladesh, for the
offline "Clinic / hospital" search in the doctor form. Run from the repo root:

    python3 tool/osm/build_health_facilities.py

Data © OpenStreetMap contributors, available under the Open Database License
(ODbL). The app credits this in Settings › Open-source licences.
"""
import json
import urllib.parse
import urllib.request

OUT = 'assets/data/bd_health_facilities.json'
QUERY = '''[out:json][timeout:170];
area["ISO3166-1"="BD"][admin_level=2]->.bd;
(nwr["amenity"~"^(hospital|clinic|doctors|dentist)$"]["name"](area.bd);
 nwr["healthcare"~"^(hospital|clinic|doctor|centre|dentist)$"]["name"](area.bd););
out tags center;'''


def fetch():
    req = urllib.request.Request(
        'https://overpass-api.de/api/interpreter',
        data=urllib.parse.urlencode({'data': QUERY}).encode(),
        headers={'User-Agent': 'DoseyAppDataBuild/1.0', 'Accept': 'application/json'},
    )
    with urllib.request.urlopen(req, timeout=200) as r:
        return json.load(r)['elements']


def address(t):
    if t.get('addr:full'):
        return t['addr:full']
    parts = [t.get('addr:housenumber'), t.get('addr:street'),
             t.get('addr:suburb'), t.get('addr:city') or t.get('addr:district')]
    return ', '.join(p for p in parts if p)


def build(elements):
    seen, rows = set(), []
    for e in elements:
        t = e['tags']
        name = (t.get('name:en') or t['name']).strip()
        other = t['name'] if t.get('name:en') and t['name'] != t['name:en'] else t.get('name:bn', '')
        addr = address(t)
        phone = t.get('phone') or t.get('contact:phone') or ''
        key = (name.lower(), addr.lower())
        if key in seen:
            continue
        seen.add(key)
        # [name, other-language name, address, phone] — compact on purpose.
        rows.append([name, other.strip(), addr.strip(), phone.strip()])
    rows.sort(key=lambda r: r[0].lower())
    return rows


if __name__ == '__main__':
    rows = build(fetch())
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump({'attribution': '© OpenStreetMap contributors, ODbL',
                   'facilities': rows}, f, ensure_ascii=False, separators=(',', ':'))
    print(f'wrote {len(rows)} facilities to {OUT}')
