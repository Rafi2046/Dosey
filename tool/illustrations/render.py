"""Renders Dosey's soft-3D illustrations into assets/images/.

Run from the repo root:  python3 tool/illustrations/render.py
Requires Pillow + numpy. Colors mirror lib/core/constants/app_colors.dart.
"""
import math
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = 'assets/images'
SS = 2  # supersampling factor

ORANGE = (253, 87, 47)
ORANGE_LIGHT = (255, 150, 110)
MOSS = (60, 109, 82)
MOSS_LIGHT = (98, 150, 118)
MINT_FACE = (190, 242, 214)
MINT = (100, 170, 147)
CREAM = (246, 243, 230)
WHITE = (255, 255, 255)
PEACH = (232, 168, 140)
INK = (40, 44, 38)
STEEL = (200, 205, 210)
RED = (225, 60, 55)


def canvas(size):
    return Image.new('RGBA', (size * SS, size * SS), (0, 0, 0, 0))


def radial(size, center, radius, inner, outer):
    """RGBA radial gradient image of `size` (w, h)."""
    w, h = size
    y, x = np.mgrid[0:h, 0:w]
    d = np.sqrt((x - center[0]) ** 2 + (y - center[1]) ** 2) / radius
    d = np.clip(d, 0, 1)[..., None]
    rgb = np.array(inner) * (1 - d) + np.array(outer) * d
    alpha = np.full((h, w, 1), 255)
    return Image.fromarray(np.concatenate([rgb, alpha], -1).astype('uint8'))


def shaded_ellipse(img, box, base, light, highlight=0.32):
    """Ellipse with a top-left light source."""
    x0, y0, x1, y1 = [int(v) for v in box]
    w, h = x1 - x0, y1 - y0
    grad = radial((w, h), (w * highlight, h * highlight), max(w, h) * 0.95, light, base)
    mask = Image.new('L', (w, h), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, w - 1, h - 1], fill=255)
    img.paste(grad, (x0, y0), mask)


def shaded_rounded(img, box, radius, base, light, angle=0):
    x0, y0, x1, y1 = [int(v) for v in box]
    w, h = x1 - x0, y1 - y0
    grad = radial((w, h), (w * 0.3, h * 0.25), max(w, h) * 0.9, light, base)
    mask = Image.new('L', (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w - 1, h - 1], radius=radius, fill=255)
    layer = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    layer.paste(grad, (0, 0), mask)
    if angle:
        layer = layer.rotate(angle, resample=Image.BICUBIC, expand=True)
        cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
        img.alpha_composite(layer, (int(cx - layer.width / 2), int(cy - layer.height / 2)))
    else:
        img.alpha_composite(layer, (x0, y0))


def soft_shadow(img, box, opacity=90, blur=30):
    layer = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).ellipse(box, fill=(20, 30, 20, opacity))
    img.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur * SS)))


def gloss(img, box, opacity=110):
    layer = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).ellipse(box, fill=(255, 255, 255, opacity))
    img.alpha_composite(layer.filter(ImageFilter.GaussianBlur(6 * SS)))


def capsule(img, cx, cy, length, thickness, angle, left, right, left_light, right_light):
    """Two-tone capsule pill."""
    layer = Image.new('RGBA', (length + 4, thickness + 4), (0, 0, 0, 0))
    half = length // 2
    shaded_rounded(layer, (2, 2, half + thickness // 2, thickness + 2), thickness // 2, left, left_light)
    shaded_rounded(layer, (half - thickness // 2, 2, length + 2, thickness + 2), thickness // 2, right, right_light)
    ImageDraw.Draw(layer).line([half, 4, half, thickness], fill=(255, 255, 255, 120), width=max(2, thickness // 18))
    layer = layer.rotate(angle, resample=Image.BICUBIC, expand=True)
    img.alpha_composite(layer, (int(cx - layer.width / 2), int(cy - layer.height / 2)))


def save(img, name, size):
    img.resize((size, size), Image.LANCZOS).save(os.path.join(OUT, name))
    print('wrote', name)


# ── Alarm clock hero ──────────────────────────────────────────────────────────
ORANGE_DARK = (176, 52, 22)
STEEL_LIGHT = (240, 242, 244)
STEEL_DARK = (140, 146, 152)


def _bell(width, angle):
    """Glossy dome bell, opening facing down, rotated by `angle` degrees."""
    w = int(width)
    dome_h = int(w * 0.62)
    rim_h = int(w * 0.24)
    pad = int(w * 0.25)
    layer = Image.new('RGBA', (w + 2 * pad, dome_h + rim_h + 2 * pad), (0, 0, 0, 0))
    x0, y0 = pad, pad
    # Dome = top half of an ellipse, lit from the top-left.
    grad = radial((w, 2 * dome_h), (w * 0.3, dome_h * 0.45), w * 0.95, ORANGE_LIGHT, ORANGE)
    mask = Image.new('L', (w, 2 * dome_h), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, w - 1, 2 * dome_h - 1], fill=255)
    ImageDraw.Draw(mask).rectangle([0, dome_h, w, 2 * dome_h], fill=0)
    layer.paste(grad, (x0, y0), mask)
    d = ImageDraw.Draw(layer)
    # Open rim: dark inside with a lighter lip.
    rim_box = [x0, y0 + dome_h - rim_h // 2, x0 + w, y0 + dome_h + rim_h // 2]
    d.ellipse(rim_box, fill=ORANGE)
    inset = int(w * 0.07)
    d.ellipse([rim_box[0] + inset, rim_box[1] + inset // 2, rim_box[2] - inset, rim_box[3] - inset // 3],
              fill=ORANGE_DARK)
    # Knob on top.
    k = int(w * 0.09)
    d.ellipse([x0 + w // 2 - k, y0 - k, x0 + w // 2 + k, y0 + k], fill=STEEL)
    layer = layer.rotate(angle, resample=Image.BICUBIC, expand=True)
    return layer


def alarm_clock(size=720):
    img = canvas(size)
    S = size * SS
    cx, cy, R = S // 2, int(S * 0.52), int(S * 0.29)
    fr = R * 0.80  # face radius

    soft_shadow(img, (cx - R * 1.05, cy + R * 0.98, cx + R * 1.05, cy + R * 1.22), opacity=120, blur=22)

    d = ImageDraw.Draw(img)
    # Feet: short white legs splayed outwards.
    for sx in (-1, 1):
        x_top, y_top = cx + sx * R * 0.52, cy + R * 0.78
        x_bot, y_bot = cx + sx * R * 0.74, cy + R * 1.02
        d.line([x_top, y_top, x_bot, y_bot], fill=CREAM, width=int(R * 0.15))
        fr_ = R * 0.08
        d.ellipse([x_bot - fr_, y_bot - fr_, x_bot + fr_, y_bot + fr_], fill=CREAM)
        d.line([x_top + sx * R * 0.02, y_top, x_bot + sx * R * 0.02, y_bot],
               fill=(215, 212, 200), width=int(R * 0.04))

    # Silver arch handle joining the bells (behind them).
    arch = [cx - R * 0.66, cy - R * 1.42, cx + R * 0.66, cy - R * 0.70]
    d.arc(arch, 200, 340, fill=STEEL_DARK, width=int(R * 0.085))
    d.arc([v + (R * 0.012 if i % 2 == 0 else R * 0.012) for i, v in enumerate(arch)], 205, 335,
          fill=STEEL_LIGHT, width=int(R * 0.03))
    # Hammer striker between the bells.
    d.rounded_rectangle([cx - R * 0.05, cy - R * 1.16, cx + R * 0.05, cy - R * 0.92], radius=R * 0.03, fill=STEEL)
    d.rounded_rectangle([cx - R * 0.13, cy - R * 1.22, cx + R * 0.13, cy - R * 1.10], radius=R * 0.05, fill=STEEL_LIGHT)

    # Bells tilted outward, sitting on the shoulders of the body.
    for sx, ang in ((-1, -28), (1, 28)):
        bell = _bell(R * 0.84, ang)
        bx, by = cx + sx * R * 0.66, cy - R * 0.84
        img.alpha_composite(bell, (int(bx - bell.width / 2), int(by - bell.height / 2)))

    # Body ring: deep green, lit from the top-left, with a glossy rim.
    shaded_ellipse(img, (cx - R, cy - R, cx + R, cy + R), MOSS, MOSS_LIGHT, highlight=0.28)
    ring = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(ring).arc([cx - R * 0.96, cy - R * 0.96, cx + R * 0.96, cy + R * 0.96], 190, 280,
                             fill=(255, 255, 255, 90), width=int(R * 0.05))
    img.alpha_composite(ring.filter(ImageFilter.GaussianBlur(3 * SS)))

    # Face.
    face = radial((int(2 * fr), int(2 * fr)), (fr * 0.65, fr * 0.55), fr * 1.4, (232, 255, 242), MINT_FACE)
    mask = Image.new('L', face.size, 0)
    ImageDraw.Draw(mask).ellipse([0, 0, face.width - 1, face.height - 1], fill=255)
    img.paste(face, (int(cx - fr), int(cy - fr)), mask)
    rim = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(rim).ellipse([cx - fr, cy - fr, cx + fr, cy + fr], outline=(25, 60, 42, 110), width=int(R * 0.05))
    img.alpha_composite(rim.filter(ImageFilter.GaussianBlur(4 * SS)))

    d = ImageDraw.Draw(img)
    # Minute ticks (longer at the hours).
    for i in range(60):
        a = math.radians(i * 6 - 90)
        major = i % 5 == 0
        r0 = fr * (0.86 if major else 0.90)
        r1 = fr * 0.95
        d.line([cx + math.cos(a) * r0, cy + math.sin(a) * r0, cx + math.cos(a) * r1, cy + math.sin(a) * r1],
               fill=(40, 70, 55) if major else (95, 130, 110), width=int(R * (0.022 if major else 0.01)))

    # Numbers.
    font = ImageFont.truetype('assets/fonts/DMSans-700.ttf', int(R * 0.21))
    for n in range(1, 13):
        a = math.radians(n * 30 - 90)
        tx, ty = cx + math.cos(a) * fr * 0.70, cy + math.sin(a) * fr * 0.70
        d.text((tx, ty), str(n), font=font, fill=ORANGE, anchor='mm')

    # Maker's mark.
    mark = ImageFont.truetype('assets/fonts/DMSans-600.ttf', int(R * 0.075))
    d.text((cx, cy + fr * 0.36), 'DOSEY', font=mark, fill=(55, 95, 72), anchor='mm')

    # Hands at 10:10, with a soft drop shadow.
    hands = Image.new('RGBA', img.size, (0, 0, 0, 0))
    hd = ImageDraw.Draw(hands)
    for deg, length, width in ((10 * 30 - 90 + 5, 0.46, 0.08), (2 * 30 - 90, 0.66, 0.05)):
        a = math.radians(deg)
        hd.line([cx, cy, cx + math.cos(a) * fr * length, cy + math.sin(a) * fr * length],
                fill=ORANGE, width=int(R * width))
    shadow = Image.new('RGBA', img.size, (0, 0, 0, 0))
    shadow.paste((20, 50, 35, 70), (0, 0), hands.split()[3])
    img.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(3 * SS)), (int(R * 0.02), int(R * 0.03)))
    img.alpha_composite(hands)
    d = ImageDraw.Draw(img)
    d.ellipse([cx - R * 0.075, cy - R * 0.075, cx + R * 0.075, cy + R * 0.075], fill=ORANGE)
    d.ellipse([cx - R * 0.03, cy - R * 0.03, cx + R * 0.03, cy + R * 0.03], fill=CREAM)

    # Glass glint.
    gloss(img, (cx - fr * 0.80, cy - fr * 0.55, cx - fr * 0.50, cy - fr * 0.25), opacity=40)

    # Pills scattered at the base.
    capsule(img, int(S * 0.12), int(S * 0.84), int(R * 0.62), int(R * 0.22), 22, WHITE, CREAM, WHITE, WHITE)
    capsule(img, int(S * 0.89), int(S * 0.80), int(R * 0.62), int(R * 0.22), 38, WHITE, CREAM, WHITE, WHITE)
    for px, py, pr, base, light in ((0.21, 0.93, 0.09, PEACH, (250, 210, 190)), (0.29, 0.955, 0.075, MINT, (180, 230, 210))):
        shaded_ellipse(img, (S * px - R * pr, S * py - R * pr * 0.8, S * px + R * pr, S * py + R * pr * 0.8), base, light)

    save(img, 'alarm_clock.png', size)


# ── Medicine type art ─────────────────────────────────────────────────────────
def tablet(size=320):
    img = canvas(size)
    S = size * SS
    soft_shadow(img, (S * 0.18, S * 0.62, S * 0.82, S * 0.80), blur=14)
    shaded_ellipse(img, (S * 0.16, S * 0.36, S * 0.84, S * 0.70), (215, 215, 210), WHITE, highlight=0.3)
    shaded_ellipse(img, (S * 0.16, S * 0.26, S * 0.84, S * 0.62), (235, 235, 230), WHITE, highlight=0.35)
    d = ImageDraw.Draw(img)
    d.line([S * 0.3, S * 0.44, S * 0.7, S * 0.44], fill=(205, 205, 200), width=int(S * 0.015))
    save(img, 'med_tablet.png', size)


def capsule_art(size=320):
    img = canvas(size)
    S = size * SS
    soft_shadow(img, (S * 0.15, S * 0.68, S * 0.85, S * 0.84), blur=14)
    capsule(img, S // 2, int(S * 0.47), int(S * 0.78), int(S * 0.28), 35, WHITE, ORANGE, WHITE, ORANGE_LIGHT)
    save(img, 'med_capsule.png', size)


def injection(size=320):
    img = canvas(size)
    S = size * SS
    soft_shadow(img, (S * 0.2, S * 0.72, S * 0.8, S * 0.86), blur=14)
    layer = canvas(size)
    d = ImageDraw.Draw(layer)
    bx0, bx1, by0, by1 = S * 0.22, S * 0.70, S * 0.42, S * 0.58
    # Plunger
    d.rectangle([S * 0.08, S * 0.48, bx0, S * 0.52], fill=STEEL)
    d.rounded_rectangle([S * 0.05, S * 0.40, S * 0.10, S * 0.60], radius=S * 0.02, fill=STEEL)
    # Barrel + liquid
    shaded_rounded(layer, (bx0, by0, bx1, by1), S * 0.03, (225, 240, 245), WHITE)
    shaded_rounded(layer, (bx0 + S * 0.18, by0 + S * 0.02, bx1 - S * 0.01, by1 - S * 0.02), S * 0.02, RED, (255, 130, 120))
    d = ImageDraw.Draw(layer)
    for i in range(6):
        x = bx0 + S * 0.05 + i * S * 0.07
        d.line([x, by0, x, by0 + S * 0.05], fill=(150, 160, 165), width=int(S * 0.008))
    d.rectangle([bx1, S * 0.47, bx1 + S * 0.06, S * 0.53], fill=STEEL)
    d.line([bx1 + S * 0.06, S * 0.5, S * 0.95, S * 0.5], fill=(170, 175, 180), width=int(S * 0.012))
    layer = layer.rotate(40, resample=Image.BICUBIC)
    img.alpha_composite(layer)
    save(img, 'med_injection.png', size)


def first_aid(size=320):
    img = canvas(size)
    S = size * SS
    soft_shadow(img, (S * 0.15, S * 0.72, S * 0.85, S * 0.88), blur=14)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([S * 0.36, S * 0.18, S * 0.64, S * 0.32], radius=S * 0.05, outline=(210, 210, 205), width=int(S * 0.04))
    shaded_rounded(img, (S * 0.16, S * 0.28, S * 0.84, S * 0.78), S * 0.08, (225, 225, 220), WHITE)
    shaded_ellipse(img, (S * 0.36, S * 0.37, S * 0.64, S * 0.65), RED, (255, 120, 110))
    d = ImageDraw.Draw(img)
    t = S * 0.04
    d.rectangle([S * 0.5 - t, S * 0.43, S * 0.5 + t, S * 0.59], fill=WHITE)
    d.rectangle([S * 0.42, S * 0.51 - t, S * 0.58, S * 0.51 + t], fill=WHITE)
    save(img, 'med_other.png', size)


def logo(size=512):
    img = canvas(size)
    S = size * SS
    shaded_rounded(img, (S * 0.06, S * 0.06, S * 0.94, S * 0.94), S * 0.24, (104, 113, 99), (130, 140, 124))
    capsule(img, S // 2, S // 2, int(S * 0.66), int(S * 0.25), 35, CREAM, ORANGE, WHITE, ORANGE_LIGHT)
    save(img, 'logo.png', size)


# ── Launcher icon & splash sources (assets/branding, not bundled) ────────────
SAGE = (104, 113, 99)
BRANDING = 'assets/branding'


def _capsule_mark(size, scale):
    """Transparent canvas with the cream/orange capsule at [scale] of width."""
    img = canvas(size)
    S = size * SS
    capsule(img, S // 2, S // 2, int(S * scale), int(S * scale * 0.38), 35,
            CREAM, ORANGE, WHITE, ORANGE_LIGHT)
    return img


def branding():
    os.makedirs(BRANDING, exist_ok=True)
    # Full-bleed icon (iOS forbids transparency; launchers apply the mask).
    icon = Image.new('RGBA', (1024 * SS, 1024 * SS), SAGE + (255,))
    icon.alpha_composite(_capsule_mark(1024, 0.62))
    icon.resize((1024, 1024), Image.LANCZOS).convert('RGB').save(f'{BRANDING}/app_icon.png')
    # Adaptive foreground: keep within the 66% safe zone.
    _capsule_mark(1024, 0.48).resize((1024, 1024), Image.LANCZOS).save(
        f'{BRANDING}/app_icon_foreground.png')
    # Splash: Android 12 shows a 1152px image masked to a 768px circle.
    _capsule_mark(1152, 0.42).resize((1152, 1152), Image.LANCZOS).save(
        f'{BRANDING}/splash_logo.png')
    print('wrote branding assets')


if __name__ == '__main__':
    branding()
    alarm_clock()
    tablet()
    capsule_art()
    injection()
    first_aid()
    logo()
