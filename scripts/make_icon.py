"""Generate the Gotham Pocket app icon (1024x1024, no alpha)."""
from __future__ import annotations

import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "GothamPocket" / "Resources" / "Assets.xcassets" / "AppIcon.appiconset" / "AppIcon.png"

S = 3072
U = S / 1024.0


def p(x: float, y: float) -> tuple[int, int]:
    return (round(x * U), round(y * U))


def box(x0: float, y0: float, x1: float, y1: float) -> tuple[int, int, int, int]:
    return (round(x0 * U), round(y0 * U), round(x1 * U), round(y1 * U))


def quad(p0, p1, p2, steps=48):
    points = []
    for i in range(steps + 1):
        t = i / steps
        x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0]
        y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]
        points.append(p(x, y))
    return points


def background() -> Image.Image:
    yy, xx = np.mgrid[0:S, 0:S].astype(np.float32) / S
    top = np.array([5, 15, 26], dtype=np.float32)
    bottom = np.array([10, 5, 17], dtype=np.float32)
    mix = np.clip(yy * 0.9 + xx * 0.1, 0, 1)[..., None]
    arr = top * (1 - mix) + bottom * mix

    # Magenta side glow.
    purple = np.array([55, 18, 74], dtype=np.float32)
    glow = np.exp(-(((xx - 0.78) ** 2 + (yy - 0.46) ** 2) / 0.16))[..., None] * 0.55
    arr = arr * (1 - glow) + purple * glow

    # Warm spotlight behind the left side.
    warm = np.array([120, 84, 24], dtype=np.float32)
    glow = np.exp(-(((xx - 0.30) ** 2 + (yy - 0.27) ** 2) / 0.12))[..., None] * 0.38
    arr = arr * (1 - glow) + warm * glow

    # Vignette.
    radius = np.sqrt((xx - 0.5) ** 2 + (yy - 0.5) ** 2)
    vignette = np.clip((radius - 0.38) / 0.42, 0, 1)[..., None] * 0.55
    arr = arr * (1 - vignette)

    img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGB")

    # Halftone dots and stars, composited once.
    overlay = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    for gy in range(28, 1024, 30):
        for gx in range(24, 1024, 30):
            if (gx // 30 + gy // 30) % 2:
                continue
            alpha = 14 if (gx < 250 or gx > 760) else 7
            draw.ellipse(box(gx - 2, gy - 2, gx + 2, gy + 2), fill=(255, 244, 215, alpha))

    for i, (sx, sy) in enumerate([(110, 160), (860, 120), (920, 320), (140, 820), (880, 860), (80, 480)]):
        radius = 2.4 if i % 2 == 0 else 1.5
        draw.ellipse(
            box(sx - radius, sy - radius, sx + radius, sy + radius),
            fill=(255, 245, 215, 150),
        )

    return Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")


def add_glow_layer(base: Image.Image, ellipse, color, blur):
    layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse(ellipse, fill=color)
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    return Image.alpha_composite(base.convert("RGBA"), layer).convert("RGB")


def build_icon() -> Image.Image:
    img = background()
    draw = ImageDraw.Draw(img)
    cx, cy, radius = 512, 540, 318

    # Halo and ring.
    img = add_glow_layer(
        img,
        box(cx - radius - 55, cy - radius - 55, cx + radius + 55, cy + radius + 55),
        (244, 200, 75, 48),
        38 * U,
    )
    draw = ImageDraw.Draw(img)
    draw.ellipse(
        box(cx - radius - 18, cy - radius - 18, cx + radius + 18, cy + radius + 18),
        outline=(224, 184, 72),
        width=max(1, round(8 * U)),
    )

    # Face base.
    draw.ellipse(
        box(cx - radius, cy - radius, cx + radius, cy + radius),
        fill=(243, 232, 211),
        outline=(6, 8, 15),
        width=max(1, round(13 * U)),
    )

    # Batman's cowl: the left half, clipped to the face circle.
    cowl = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    cd = ImageDraw.Draw(cowl)
    cd.ellipse(box(cx - radius, cy - radius, cx + radius, cy + radius), fill=(20, 28, 43, 255))
    cowl_mask = Image.new("L", (S, S), 0)
    md = ImageDraw.Draw(cowl_mask)
    md.ellipse(box(cx - radius, cy - radius, cx + radius, cy + radius), fill=255)
    left_half = Image.new("L", (S, S), 0)
    lh = ImageDraw.Draw(left_half)
    lh.polygon(
        [p(180, 200), p(cx, 200), p(cx, 880), p(180, 880)],
        fill=255,
    )
    cowl_mask = ImageChops.multiply(cowl_mask, left_half)
    img = Image.composite(cowl.convert("RGB"), img, cowl_mask)
    draw = ImageDraw.Draw(img)

    # Exposed jaw on the left, clipped to the face circle.
    jaw_mask = Image.new("L", (S, S), 0)
    jd = ImageDraw.Draw(jaw_mask)
    jd.ellipse(box(cx - radius, cy - radius, cx + radius, cy + radius), fill=255)
    jaw_shape = Image.new("L", (S, S), 0)
    js = ImageDraw.Draw(jaw_shape)
    js.ellipse(box(250, 680, 535, 905), fill=255)
    jaw_mask = ImageChops.multiply(jaw_mask, jaw_shape)
    jaw = Image.new("RGB", (S, S), (224, 166, 132))
    img = Image.composite(jaw, img, jaw_mask)
    draw = ImageDraw.Draw(img)

    # Cowl edge above the jaw.
    seam = quad((245, 700), (380, 655), (525, 708), 50)
    draw.line(seam, fill=(7, 9, 15), width=round(10 * U), joint="curve")

    # A quietly unimpressed bat-mouth.
    draw.line(
        quad((330, 786), (390, 806), (452, 782), 28),
        fill=(112, 63, 47),
        width=round(5 * U),
        joint="curve",
    )

    # Batman ear.
    ear = [p(310, 330), p(356, 152), p(486, 350)]
    draw.polygon(ear, fill=(20, 28, 43))
    draw.line(ear + [ear[0]], fill=(5, 7, 12), width=round(11 * U), joint="curve")

    # Cowl brow and nose.
    brow = quad((225, 500), (365, 452), (505, 520), 44)
    draw.line(brow, fill=(7, 9, 15), width=round(11 * U), joint="curve")
    draw.line([p(cx, 540), p(500, 620), p(525, 625)], fill=(100, 64, 50), width=round(4 * U))
    draw.line(quad((455, 705), (512, 730), (555, 700), 24), fill=(95, 58, 47), width=round(5 * U))

    # Batman eye.
    eye_glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    eg = ImageDraw.Draw(eye_glow)
    eg.polygon([p(324, 416), p(474, 396), p(462, 492), p(336, 488)], fill=(190, 235, 255, 150))
    eye_glow = eye_glow.filter(ImageFilter.GaussianBlur(13 * U))
    img = Image.alpha_composite(img.convert("RGBA"), eye_glow).convert("RGB")
    draw = ImageDraw.Draw(img)
    bat_eye = [p(330, 420), p(468, 402), p(459, 481), p(338, 477)]
    draw.polygon(bat_eye, fill=(228, 246, 255))
    draw.line(bat_eye + [bat_eye[0]], fill=(6, 8, 15), width=round(7 * U), joint="curve")

    # Joker hair, drawn over the right side of the face.
    hair = [
        p(cx, 235), p(472, 72), p(558, 196), p(604, 42), p(674, 178),
        p(760, 84), p(746, 232), p(868, 155), p(816, 334), p(570, 360),
    ]
    draw.polygon(hair, fill=(106, 206, 64))
    draw.line(hair + [hair[0]], fill=(18, 41, 18), width=round(11 * U), joint="curve")

    # A couple of hair strands.
    for strand in [
        [p(550, 180), p(590, 96), p(610, 182)],
        [p(690, 160), p(748, 118), p(728, 235)],
    ]:
        draw.line(strand, fill=(169, 242, 113), width=round(6 * U), joint="curve")

    # Joker eye.
    draw.ellipse(box(600, 400, 734, 490), fill=(248, 240, 204), outline=(18, 31, 20), width=round(6 * U))
    draw.ellipse(box(646, 418, 692, 472), fill=(89, 185, 53))
    draw.ellipse(box(660, 433, 678, 457), fill=(9, 12, 12))
    draw.ellipse(box(652, 420, 663, 432), fill=(255, 255, 246))
    draw.line([p(596, 386), p(650, 365), p(724, 386)], fill=(29, 76, 28), width=round(7 * U), joint="curve")
    draw.line([p(592, 398), p(594, 470)], fill=(18, 31, 20), width=round(3 * U))

    # Joker grin.
    outer = quad((548, 610), (692, 850), (838, 600), 70)
    inner = quad((838, 600), (692, 682), (548, 610), 70)
    mouth = outer + inner
    draw.polygon(mouth, fill=(94, 16, 34))
    draw.line(outer, fill=(196, 45, 68), width=round(10 * U), joint="curve")
    draw.line(inner, fill=(196, 45, 68), width=round(7 * U), joint="curve")

    teeth_top = quad((570, 606), (692, 716), (816, 601), 44)
    teeth_bottom = quad((570, 606), (692, 661), (816, 601), 44)
    draw.polygon(teeth_top + list(reversed(teeth_bottom)), fill=(245, 235, 214))
    for x in (620, 668, 716, 764):
        draw.line([p(x, 612), p(x + 2, 650)], fill=(158, 128, 105), width=round(2.5 * U))

    # Smile stitches.
    for x0, y0, x1, y1 in [
        (548, 608, 512, 588), (548, 626, 510, 630),
        (838, 600, 872, 580), (836, 618, 874, 622),
    ]:
        draw.line([p(x0, y0), p(x1, y1)], fill=(210, 54, 76), width=round(4 * U))

    # Split seam between the two faces.
    seam_points = [p(512, 218), p(498, 330), p(524, 442), p(503, 558), p(528, 682), p(512, 868)]
    draw.line(seam_points, fill=(5, 7, 12), width=round(10 * U), joint="curve")

    # Canvas outline and inner highlight.
    draw.ellipse(
        box(cx - radius, cy - radius, cx + radius, cy + radius),
        outline=(6, 8, 15),
        width=round(13 * U),
    )
    draw.arc(
        box(cx - radius + 16, cy - radius + 16, cx + radius - 16, cy + radius - 16),
        start=200,
        end=265,
        fill=(100, 110, 130),
        width=round(5 * U),
    )

    # Small bat badge at the bottom-right corner of the frame.
    badge_center = p(862, 862)
    badge_r = 45 * U
    draw.ellipse(
        [badge_center[0] - badge_r, badge_center[1] - badge_r, badge_center[0] + badge_r, badge_center[1] + badge_r],
        fill=(7, 10, 18),
        outline=(244, 200, 75),
        width=round(4 * U),
    )
    bx, by, bw, bh = 830, 844, 64, 34
    bat = [
        p(bx + bw * 0.5, by + bh * 0.02),
        p(bx + bw * 0.70, by + bh * 0.22),
        p(bx + bw * 0.98, by + bh * 0.30),
        p(bx + bw * 0.84, by + bh * 0.58),
        p(bx + bw * 0.72, by + bh * 0.47),
        p(bx + bw * 0.62, by + bh * 0.82),
        p(bx + bw * 0.50, by + bh * 0.65),
        p(bx + bw * 0.38, by + bh * 0.82),
        p(bx + bw * 0.28, by + bh * 0.47),
        p(bx + bw * 0.16, by + bh * 0.58),
        p(bx + bw * 0.02, by + bh * 0.30),
        p(bx + bw * 0.30, by + bh * 0.22),
    ]
    draw.polygon(bat, fill=(244, 200, 75))

    return img


def main() -> None:
    icon = build_icon()
    icon = icon.resize((1024, 1024), Image.Resampling.LANCZOS)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    icon.convert("RGB").save(OUT, "PNG", optimize=True)
    print(f"wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
