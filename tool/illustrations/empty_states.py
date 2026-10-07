"""Renders Dosey's empty-state illustrations into assets/images/.

Run from the repo root:  python3 tool/illustrations/empty_states.py [--preview]
Requires resvg-py (pip install resvg-py). Colors mirror
lib/core/constants/app_colors.dart, same palette as render.py.
--preview also writes a contact sheet on the app's dark background.
"""
import os
import sys

import resvg_py

OUT = 'assets/images'
DEFS = '''
<defs>
 <linearGradient id="white" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#DCE3E5"/></linearGradient>
 <linearGradient id="paper" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#E8EDEE"/></linearGradient>
 <linearGradient id="teal" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#5C8E9C"/><stop offset="1" stop-color="#366270"/></linearGradient>
 <linearGradient id="tealLight" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#6E9DAB"/><stop offset="1" stop-color="#4A7787"/></linearGradient>
 <linearGradient id="coral" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#EE9A9E"/><stop offset="1" stop-color="#DA6B71"/></linearGradient>
 <linearGradient id="aqua" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#ECF4F6"/><stop offset="1" stop-color="#C6ECF0"/></linearGradient>
 <linearGradient id="mint" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#8CC8C5"/><stop offset="1" stop-color="#62A8A5"/></linearGradient>
 <linearGradient id="peach" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F4C6B2"/><stop offset="1" stop-color="#E8A88C"/></linearGradient>
 <filter id="soft" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="7"/></filter>
 <filter id="lift" x="-20%" y="-20%" width="140%" height="140%"><feDropShadow dx="0" dy="4" stdDeviation="5" flood-color="#0B1E24" flood-opacity="0.22"/></filter>
</defs>'''
SHADOW = '<ellipse cx="160" cy="284" rx="{rx}" ry="11" fill="#06161B" opacity="0.28" filter="url(#soft)"/>'
def sparkle(x,y,c,s=1):
    return f'<circle cx="{x}" cy="{y}" r="{5*s}" fill="{c}" opacity="0.85"/>'

ILL = {}

# Blood pressure monitor with cuff
ILL['empty_blood_pressure'] = SHADOW.format(rx=120) + '''
<g filter="url(#lift)">
 <path d="M44 128 q36 -22 86 0 v118 q-50 -22 -86 0z" fill="url(#teal)"/>
 <path d="M44 128 q36 -22 86 0 v30 q-50 -22 -86 0z" fill="url(#tealLight)"/>
 <path d="M58 168 q30 -14 58 0" stroke="#A9C7D0" stroke-width="3" fill="none" stroke-dasharray="5 5" opacity="0.7"/>
 <path d="M58 226 q30 -14 58 0" stroke="#A9C7D0" stroke-width="3" fill="none" stroke-dasharray="5 5" opacity="0.7"/>
 <rect x="72" y="182" width="30" height="26" rx="6" fill="url(#coral)"/>
</g>
<path d="M118 240 C 132 286, 160 280, 168 250" stroke="#A9C7D0" stroke-width="7" fill="none" stroke-linecap="round"/>
<g filter="url(#lift)">
 <rect x="160" y="78" width="128" height="190" rx="30" fill="url(#white)"/>
 <rect x="176" y="96" width="96" height="80" rx="16" fill="url(#aqua)"/>
 <path d="M224 150 c-14 -10 -24 -18 -24 -28 c0 -8 6 -13 13 -13 c5 0 9 3 11 7 c2 -4 6 -7 11 -7 c7 0 13 5 13 13 c0 10 -10 18 -24 28z" fill="url(#coral)"/>
 <path d="M184 164 h18 l6 -8 l7 14 l6 -6 h45" stroke="#4F8292" stroke-width="3.5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
 <circle cx="224" cy="218" r="22" fill="url(#coral)"/>
 <circle cx="224" cy="218" r="13" fill="#FFFFFF" opacity="0.25"/>
 <rect x="182" y="246" width="26" height="8" rx="4" fill="#B9C7CB"/>
 <rect x="240" y="246" width="26" height="8" rx="4" fill="#B9C7CB"/>
</g>
''' + sparkle(40,84,'#E8A88C') + sparkle(300,60,'#62A8A5',0.8)

# Glucometer, strip and blood drop
ILL['empty_blood_sugar'] = SHADOW.format(rx=110) + '''
<g filter="url(#lift)">
 <rect x="128" y="36" width="34" height="70" rx="6" fill="url(#teal)"/>
 <rect x="138" y="44" width="14" height="22" rx="3" fill="#F4D58A"/>
 <rect x="138" y="72" width="14" height="5" rx="2" fill="#A9C7D0"/>
 <rect x="138" y="82" width="14" height="5" rx="2" fill="#A9C7D0"/>
</g>
<g filter="url(#lift)">
 <rect x="82" y="92" width="130" height="182" rx="40" fill="url(#white)"/>
 <rect x="102" y="116" width="90" height="74" rx="16" fill="url(#aqua)"/>
 <rect x="116" y="134" width="36" height="12" rx="6" fill="#4F8292"/>
 <rect x="116" y="154" width="58" height="8" rx="4" fill="#4F8292" opacity="0.45"/>
 <rect x="116" y="168" width="44" height="8" rx="4" fill="#4F8292" opacity="0.3"/>
 <circle cx="147" cy="226" r="20" fill="url(#teal)"/>
 <circle cx="147" cy="226" r="11" fill="#FFFFFF" opacity="0.2"/>
</g>
<g filter="url(#lift)">
 <path d="M248 122 C 248 122, 286 168, 286 196 a38 38 0 0 1 -76 0 C 210 168, 248 122, 248 122z" fill="url(#coral)"/>
 <path d="M232 186 a18 18 0 0 0 10 22" stroke="#FFFFFF" stroke-width="7" stroke-linecap="round" fill="none" opacity="0.55"/>
</g>
''' + sparkle(52,120,'#62A8A5') + sparkle(288,96,'#E8A88C',0.8)

# Calendar with checks + clock badge (dose history)
def cal_cells():
    s=''
    marks = ['c','c','m','c','e','c','c','c','e','e','e','e']
    for i,m in enumerate(marks):
        cx = 90 + (i%4)*46; cy = 142 + (i//4)*42
        if m=='c': s+=f'<circle cx="{cx}" cy="{cy}" r="14" fill="url(#mint)"/><path d="M{cx-6} {cy} l4 5 l8 -9" stroke="#fff" stroke-width="3.5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
        elif m=='m': s+=f'<circle cx="{cx}" cy="{cy}" r="14" fill="url(#coral)"/><path d="M{cx-5} {cy-5} l10 10 M{cx+5} {cy-5} l-10 10" stroke="#fff" stroke-width="3.5" stroke-linecap="round"/>'
        else: s+=f'<circle cx="{cx}" cy="{cy}" r="12" fill="none" stroke="#C5D1D4" stroke-width="3" stroke-dasharray="4 5"/>'
    return s
ILL['empty_history'] = SHADOW.format(rx=125) + '''
<g filter="url(#lift)">
 <rect x="54" y="66" width="212" height="210" rx="28" fill="url(#white)"/>
 <path d="M54 94 a28 28 0 0 1 28 -28 h156 a28 28 0 0 1 28 28 v14 h-212z" fill="url(#coral)"/>
 <rect x="94" y="50" width="12" height="34" rx="6" fill="url(#teal)"/>
 <rect x="214" y="50" width="12" height="34" rx="6" fill="url(#teal)"/>
''' + cal_cells() + '''
</g>
<g filter="url(#lift)">
 <circle cx="258" cy="250" r="38" fill="url(#teal)"/>
 <circle cx="258" cy="250" r="29" fill="url(#aqua)"/>
 <path d="M258 232 v19 l12 8" stroke="#DA6B71" stroke-width="5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
 <circle cx="258" cy="251" r="4" fill="#335C69"/>
</g>
''' + sparkle(36,140,'#E8A88C')

# Wallet, receipt, coins (expenses)
ILL['empty_expenses'] = SHADOW.format(rx=120) + '''
<g filter="url(#lift)" transform="rotate(-8 170 110)">
 <path d="M120 50 h96 v120 l-12 -8 l-12 8 l-12 -8 l-12 8 l-12 -8 l-12 8 l-12 -8 l-12 8z" fill="url(#paper)"/>
 <rect x="136" y="72" width="46" height="8" rx="4" fill="#4F8292"/>
 <rect x="136" y="92" width="64" height="6" rx="3" fill="#B9C7CB"/>
 <rect x="136" y="106" width="56" height="6" rx="3" fill="#B9C7CB"/>
 <rect x="136" y="120" width="64" height="6" rx="3" fill="#B9C7CB"/>
 <rect x="160" y="140" width="40" height="8" rx="4" fill="#DA6B71"/>
</g>
<g filter="url(#lift)">
 <rect x="56" y="132" width="210" height="140" rx="30" fill="url(#teal)"/>
 <rect x="56" y="132" width="210" height="34" rx="17" fill="#5C8E9D" opacity="0.6"/>
 <path d="M196 182 h80 a14 14 0 0 1 14 14 v28 a14 14 0 0 1 -14 14 h-80 a28 28 0 0 1 0 -56z" fill="url(#coral)"/>
 <circle cx="206" cy="210" r="10" fill="#FFFFFF" opacity="0.85"/>
</g>
<g filter="url(#lift)">
 <ellipse cx="78" cy="262" rx="30" ry="10" fill="#CF8C70"/>
 <ellipse cx="78" cy="254" rx="30" ry="10" fill="url(#peach)"/>
 <ellipse cx="78" cy="240" rx="30" ry="10" fill="#CF8C70"/>
 <ellipse cx="78" cy="232" rx="30" ry="10" fill="url(#peach)"/>
 <ellipse cx="78" cy="232" rx="16" ry="4.5" fill="#FFFFFF" opacity="0.35"/>
</g>
''' + sparkle(286,90,'#62A8A5') + sparkle(40,110,'#E8A88C',0.8)

# Doctor profile card with stethoscope
ILL['empty_doctors'] = SHADOW.format(rx=115) + '''
<g filter="url(#lift)">
 <rect x="70" y="52" width="180" height="222" rx="30" fill="url(#white)"/>
 <rect x="138" y="40" width="44" height="22" rx="11" fill="url(#teal)"/>
 <circle cx="160" cy="124" r="44" fill="url(#aqua)"/>
 <clipPath id="av"><circle cx="160" cy="124" r="44"/></clipPath>
 <g clip-path="url(#av)">
  <circle cx="160" cy="112" r="18" fill="url(#teal)"/>
  <path d="M118 172 a42 36 0 0 1 84 0z" fill="url(#teal)"/>
  <path d="M150 140 l10 16 l10 -16" fill="#FFFFFF"/>
 </g>
 <rect x="112" y="186" width="96" height="12" rx="6" fill="#4F8292"/>
 <rect x="124" y="208" width="72" height="8" rx="4" fill="#B9C7CB"/>
 <rect x="132" y="226" width="56" height="8" rx="4" fill="#B9C7CB"/>
</g>
<g filter="url(#lift)">
 <circle cx="240" cy="80" r="26" fill="url(#coral)"/>
 <path d="M240 66 v28 M226 80 h28" stroke="#fff" stroke-width="8" stroke-linecap="round"/>
</g>
<path d="M52 150 C 40 210, 70 262, 112 262" stroke="#335C69" stroke-width="7" fill="none" stroke-linecap="round"/>
<g filter="url(#lift)">
 <circle cx="120" cy="262" r="17" fill="#8FA6AD"/>
 <circle cx="120" cy="262" r="10" fill="url(#white)"/>
 <circle cx="52" cy="146" r="8" fill="url(#coral)"/>
</g>
''' + sparkle(286,190,'#62A8A5') + sparkle(36,90,'#E8A88C',0.8)

# Folder with documents (records)
ILL['empty_records'] = SHADOW.format(rx=125) + '''
<path d="M50 104 a20 20 0 0 1 20 -20 h52 l18 18 h110 a20 20 0 0 1 20 20 v140 h-220z" fill="url(#teal)" filter="url(#lift)"/>
<g filter="url(#lift)" transform="rotate(-6 150 120)">
 <rect x="86" y="62" width="128" height="150" rx="14" fill="url(#paper)"/>
 <rect x="104" y="84" width="54" height="9" rx="4.5" fill="#4F8292"/>
 <rect x="104" y="104" width="90" height="6" rx="3" fill="#B9C7CB"/>
 <rect x="104" y="118" width="76" height="6" rx="3" fill="#B9C7CB"/>
</g>
<g filter="url(#lift)" transform="rotate(5 190 120)">
 <rect x="138" y="74" width="122" height="146" rx="14" fill="url(#paper)"/>
 <circle cx="166" cy="104" r="14" fill="url(#coral)"/>
 <path d="M166 97 v14 M159 104 h14" stroke="#fff" stroke-width="4" stroke-linecap="round"/>
 <rect x="188" y="98" width="52" height="8" rx="4" fill="#4F8292"/>
 <rect x="156" y="130" width="86" height="6" rx="3" fill="#B9C7CB"/>
 <rect x="156" y="144" width="72" height="6" rx="3" fill="#B9C7CB"/>
</g>
<path d="M40 164 a20 20 0 0 1 20 -20 h200 a20 20 0 0 1 20 20 l-10 92 a20 20 0 0 1 -20 18 h-180 a20 20 0 0 1 -20 -18z" fill="url(#tealLight)" filter="url(#lift)"/>
<rect x="128" y="196" width="64" height="12" rx="6" fill="#FFFFFF" opacity="0.4"/>
''' + sparkle(290,70,'#E8A88C') + sparkle(30,110,'#62A8A5',0.8)

# Pill bottle with a capsule and tablets beside it (medicines)
ILL['empty_medicines'] = SHADOW.format(rx=125) + '''
<g filter="url(#lift)">
 <rect x="96" y="62" width="112" height="40" rx="12" fill="url(#teal)"/>
 <path d="M108 70 v24 M124 70 v24 M140 70 v24 M156 70 v24 M172 70 v24 M188 70 v24" stroke="#2C515D" stroke-width="3" opacity="0.45"/>
 <rect x="90" y="98" width="124" height="176" rx="28" fill="url(#white)"/>
 <rect x="90" y="140" width="124" height="88" fill="url(#coral)"/>
 <rect x="138" y="160" width="28" height="48" rx="6" fill="#FFFFFF"/>
 <rect x="128" y="170" width="48" height="28" rx="6" fill="#FFFFFF"/>
 <rect x="104" y="112" width="14" height="150" rx="7" fill="#FFFFFF" opacity="0.55"/>
</g>
<g filter="url(#lift)" transform="rotate(-35 254 236)">
 <path d="M254 214 h-22 a22 22 0 0 0 0 44 h22z" fill="url(#white)"/>
 <path d="M254 214 h22 a22 22 0 0 1 0 44 h-22z" fill="url(#teal)"/>
 <rect x="222" y="221" width="22" height="6" rx="3" fill="#FFFFFF" opacity="0.8"/>
</g>
<g filter="url(#lift)">
 <circle cx="62" cy="252" r="22" fill="url(#mint)"/>
 <path d="M48 252 h28" stroke="#3F7F7C" stroke-width="3" stroke-linecap="round" opacity="0.6"/>
 <ellipse cx="244" cy="154" rx="17" ry="17" fill="url(#peach)"/>
 <path d="M234 154 h20" stroke="#CF8C70" stroke-width="3" stroke-linecap="round"/>
</g>
''' + sparkle(58,96,'#E8A88C') + sparkle(272,96,'#62A8A5',0.8)

# Bell over stacked reminder cards (reminders)
ILL['empty_reminders'] = SHADOW.format(rx=120) + '''
<g filter="url(#lift)">
 <rect x="74" y="200" width="196" height="64" rx="20" fill="url(#white)" opacity="0.75"/>
 <rect x="56" y="176" width="208" height="76" rx="22" fill="url(#white)"/>
 <circle cx="94" cy="214" r="18" fill="url(#mint)"/>
 <path d="M94 204 v11 l7 5" stroke="#FFFFFF" stroke-width="4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
 <rect x="124" y="200" width="84" height="10" rx="5" fill="#366270"/>
 <rect x="124" y="218" width="112" height="7" rx="3.5" fill="#B9C7CB"/>
</g>
<g filter="url(#lift)">
 <path d="M160 44 c-36 0 -58 28 -58 64 v34 l-16 22 h148 l-16 -22 v-34 c0 -36 -22 -64 -58 -64z" fill="url(#coral)"/>
 <rect x="150" y="30" width="20" height="18" rx="9" fill="url(#teal)"/>
 <path d="M140 164 a20 20 0 0 0 40 0z" fill="url(#teal)"/>
 <path d="M122 104 c0 -20 10 -34 26 -40" stroke="#FFFFFF" stroke-width="8" stroke-linecap="round" fill="none" opacity="0.45"/>
</g>
<path d="M240 66 q16 18 0 40 M260 54 q26 30 0 64" stroke="#E8A88C" stroke-width="6" fill="none" stroke-linecap="round"/>
<path d="M80 66 q-16 18 0 40 M60 54 q-26 30 0 64" stroke="#E8A88C" stroke-width="6" fill="none" stroke-linecap="round"/>
'''

# Tea cup under a sun (today: nothing scheduled, enjoy your day)
ILL['empty_today'] = SHADOW.format(rx=110) + '''
<g filter="url(#lift)">
 <circle cx="236" cy="80" r="34" fill="url(#peach)"/>
 <circle cx="226" cy="70" r="12" fill="#FFFFFF" opacity="0.3"/>
</g>
<g stroke="#E8A88C" stroke-width="6" stroke-linecap="round" opacity="0.8">
 <path d="M236 30 v-10"/><path d="M286 80 h10"/><path d="M272 44 l7 -7"/><path d="M272 116 l7 7"/><path d="M186 80 h-10"/><path d="M200 44 l-7 -7"/>
</g>
<path d="M126 92 q-14 -16 0 -32 q14 -16 0 -32" stroke="#C6D3D6" stroke-width="7" fill="none" stroke-linecap="round" opacity="0.8"/>
<path d="M160 104 q-14 -16 0 -32 q14 -16 0 -32" stroke="#C6D3D6" stroke-width="7" fill="none" stroke-linecap="round" opacity="0.8"/>
<g filter="url(#lift)">
 <ellipse cx="150" cy="266" rx="104" ry="16" fill="url(#white)"/>
 <path d="M226 160 h14 a32 32 0 0 1 0 64 h-18" stroke="url(#teal)" stroke-width="14" fill="none"/>
 <path d="M70 130 h160 v70 a62 62 0 0 1 -62 62 h-36 a62 62 0 0 1 -62 -62z" fill="url(#teal)"/>
 <ellipse cx="150" cy="130" rx="80" ry="14" fill="#2C515D"/>
 <ellipse cx="150" cy="133" rx="70" ry="9" fill="#C69277"/>
 <path d="M150 230 c-12 -9 -22 -16 -22 -25 c0 -7 5 -12 12 -12 c4 0 8 2 10 6 c2 -4 6 -6 10 -6 c7 0 12 5 12 12 c0 9 -10 16 -22 25z" fill="url(#coral)"/>
 <path d="M86 156 v40" stroke="#FFFFFF" stroke-width="8" stroke-linecap="round" opacity="0.3"/>
</g>
''' + sparkle(40,200,'#62A8A5') + sparkle(60,110,'#E8A88C',0.8)

def svg(body, bg=None, size=320):
    b = f'<rect width="320" height="320" fill="{bg}"/>' if bg else ''
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 320 320">{DEFS}{b}{body}</svg>'

os.makedirs(OUT, exist_ok=True)
for name, body in ILL.items():
    png = resvg_py.svg_to_bytes(svg_string=svg(body), width=480, height=480)
    open(os.path.join(OUT, name + '.png'), 'wb').write(bytes(png))
if '--preview' in sys.argv:
    names = list(ILL)
    cells = ''.join(f'<g transform="translate({(i%4)*320},{(i//4)*320})">{ILL[n]}</g>' for i,n in enumerate(names))
    h = -(-len(names) // 4) * 320
    sheet = f'<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="{h}" viewBox="0 0 1280 {h}">{DEFS}<rect width="1280" height="{h}" fill="#141616"/>{cells}</svg>'
    open('empty_states_preview.png','wb').write(bytes(resvg_py.svg_to_bytes(svg_string=sheet, width=1280, height=h)))

