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
def alarm_clock(size=720):
    img = canvas(size)
    S = size * SS
    cx, cy, R = S // 2, int(S * 0.47), int(S * 0.30)

    soft_shadow(img, (cx - R, cy + R * 0.95, cx + R, cy + R * 1.25), opacity=110, blur=26)

    d = ImageDraw.Draw(img)
    # Legs
    for sx in (-1, 1):
        x_top, y_top = cx + sx * R * 0.55, cy + R * 0.75
        x_bot, y_bot = cx + sx * R * 0.85, cy + R * 1.18
        d.line([x_top, y_top, x_bot, y_bot], fill=MOSS, width=int(R * 0.14))
        d.ellipse([x_bot - R * 0.07, y_bot - R * 0.07, x_bot + R * 0.07, y_bot + R * 0.07], fill=MOSS)

    # Bells (behind body)
    for sx, ang in ((-1, 35), (1, -35)):
        bx, by = cx + sx * R * 0.72, cy - R * 0.88
        br = R * 0.42
        shaded_ellipse(img, (bx - br, by - br * 0.85, bx + br, by + br * 0.95), ORANGE, ORANGE_LIGHT)
        d.ellipse([bx - br * 0.18, by - br * 1.05, bx + br * 0.18, by - br * 0.7], fill=ORANGE)
    # Hammer bar
    d.rounded_rectangle([cx - R * 0.09, cy - R * 1.25, cx + R * 0.09, cy - R * 0.9], radius=R * 0.05, fill=CREAM)
    d.rounded_rectangle([cx - R * 0.35, cy - R * 1.3, cx + R * 0.35, cy - R * 1.18], radius=R * 0.06, fill=CREAM)

    # Body + face
    shaded_ellipse(img, (cx - R, cy - R, cx + R, cy + R), MOSS, MOSS_LIGHT)
    fr = R * 0.82
    face = radial((int(2 * fr), int(2 * fr)), (fr * 0.7, fr * 0.6), fr * 1.4, (225, 255, 238), MINT_FACE)
    mask = Image.new('L', face.size, 0)
    ImageDraw.Draw(mask).ellipse([0, 0, face.width - 1, face.height - 1], fill=255)
    img.paste(face, (int(cx - fr), int(cy - fr)), mask)
    # Inner rim shadow
    rim = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(rim).ellipse([cx - fr, cy - fr, cx + fr, cy + fr], outline=(30, 70, 50, 90), width=int(R * 0.06))
    img.alpha_composite(rim.filter(ImageFilter.GaussianBlur(4 * SS)))

    # Numbers
    font = ImageFont.truetype('assets/fonts/Bitter-800.ttf', int(R * 0.2))
    d = ImageDraw.Draw(img)
    for n in range(1, 13):
        a = math.radians(n * 30 - 90)
        tx, ty = cx + math.cos(a) * fr * 0.78, cy + math.sin(a) * fr * 0.78
        d.text((tx, ty), str(n), font=font, fill=ORANGE, anchor='mm')

    # Hands (10:10): angle = position * 30° - 90° (0° = 3 o'clock)
    for deg, length, width in ((10 * 30 - 90, 0.42, 0.075), (2 * 30 - 90, 0.62, 0.05)):
        a = math.radians(deg)
        d.line([cx, cy, cx + math.cos(a) * fr * length, cy + math.sin(a) * fr * length],
               fill=ORANGE, width=int(R * width))
    d.ellipse([cx - R * 0.07, cy - R * 0.07, cx + R * 0.07, cy + R * 0.07], fill=ORANGE)
    d.ellipse([cx - R * 0.03, cy - R * 0.03, cx + R * 0.03, cy + R * 0.03], fill=CREAM)

    # Glass gloss
    gloss(img, (cx - fr * 0.55, cy - fr * 0.62, cx - fr * 0.15, cy - fr * 0.42), opacity=45)

    # Pills around
    capsule(img, int(S * 0.13), int(S * 0.80), int(R * 0.6), int(R * 0.22), 25, WHITE, CREAM, WHITE, WHITE)
    capsule(img, int(S * 0.88), int(S * 0.70), int(R * 0.6), int(R * 0.22), 40, WHITE, CREAM, WHITE, WHITE)
    for px, py, pr, base, light in ((0.22, 0.88, 0.09, PEACH, (250, 210, 190)), (0.30, 0.92, 0.07, MINT, (180, 230, 210))):
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


if __name__ == '__main__':
    alarm_clock()
    tablet()
    capsule_art()
    injection()
    first_aid()
    logo()
