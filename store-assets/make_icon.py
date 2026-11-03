#!/usr/bin/env python3
"""Draw the gold-ingot calculator icon (generic, no brand) and write every icon size."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent
BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
G1, G2, G3 = (255, 228, 140), (214, 162, 52), (140, 96, 20)
BG1, BG2 = (58, 42, 22), (24, 18, 12)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def vgrad(w, h, stops):
    im = Image.new("RGB", (w, h))
    d = ImageDraw.Draw(im)
    for y in range(h):
        t = y / max(1, h - 1)
        n = len(stops) - 1
        i = min(int(t * n), n - 1)
        d.line([(0, y), (w, y)], fill=lerp(stops[i], stops[i + 1], t * n - i))
    return im


def icon(s=1024, rounded=True):
    base = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    bg = vgrad(s, s, [BG1, BG2])
    mask = Image.new("L", (s, s), 0)
    if rounded:
        ImageDraw.Draw(mask).rounded_rectangle([0, 0, s - 1, s - 1], radius=int(s * .22), fill=255)
    else:
        mask.paste(255, (0, 0, s, s))
    base.paste(bg, (0, 0), mask)
    # glow
    glow = Image.new("L", (s, s), 0)
    ImageDraw.Draw(glow).ellipse([s * .18, s * .25, s * .82, s * .85], fill=110)
    glow = glow.filter(ImageFilter.GaussianBlur(s * .09))
    gl = Image.new("RGBA", (s, s), G2 + (0,))
    gl.putalpha(Image.composite(glow, Image.new("L", (s, s), 0), mask))
    base.alpha_composite(gl)
    # ingot: top face + front face
    x0, x1, y_top, y_mid, y_bot = s * .12, s * .88, s * .36, s * .50, s * .76
    a, b = s * .07, s * .06
    front = [(x0 + a, y_mid), (x1 - a, y_mid), (x1, y_bot), (x0, y_bot)]
    top = [(x0 + a + b, y_top), (x1 - a - b, y_top), (x1 - a, y_mid), (x0 + a, y_mid)]
    shadow = Image.new("L", (s, s), 0)
    ImageDraw.Draw(shadow).polygon([(p[0], p[1] + s * .03) for p in front], fill=140)
    shadow = shadow.filter(ImageFilter.GaussianBlur(s * .03))
    sh = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    sh.putalpha(shadow)
    base.alpha_composite(sh)
    for poly, stops in ((front, [G2, G3]), (top, [G1, G2])):
        m = Image.new("L", (s, s), 0)
        ImageDraw.Draw(m).polygon(poly, fill=255)
        g = vgrad(s, s, stops).convert("RGBA")
        g.putalpha(m)
        base.alpha_composite(g)
    d0 = ImageDraw.Draw(base)
    d = d0
    d.line([(x0 + a, y_mid), (x1 - a, y_mid)], fill=(255, 244, 200), width=max(1, int(s * .008)))
    hl = Image.new("L", (s, s), 0)
    ImageDraw.Draw(hl).polygon([(x0 + a + b + s * .08, y_top), (x0 + a + b + s * .16, y_top),
                                (x0 + a + s * .10, y_mid), (x0 + a + s * .02, y_mid)], fill=120)
    hi = Image.new("RGBA", (s, s), (255, 255, 255, 0))
    hi.putalpha(hl.filter(ImageFilter.GaussianBlur(s * .006)))
    base.alpha_composite(hi)
    d = ImageDraw.Draw(base)
    f = ImageFont.truetype(BOLD, int(s * .15))
    d.text((s / 2, (y_mid + y_bot) / 2 + s * .005), "24K", font=f, fill=(92, 60, 8), anchor="mm")
    d.text((s / 2, (y_mid + y_bot) / 2 - s * .004), "24K", font=f, fill=(255, 236, 170), anchor="mm")
    # sparkle
    cx, cy, r = s * .76, s * .27, s * .07
    d.polygon([(cx, cy - r), (cx + r * .25, cy - r * .25), (cx + r, cy), (cx + r * .25, cy + r * .25),
               (cx, cy + r), (cx - r * .25, cy + r * .25), (cx - r, cy), (cx - r * .25, cy - r * .25)], fill=G1)
    return base


def main():
    big = icon(1024)
    flat = icon(1024, rounded=False)
    out = ROOT / "icons"
    out.mkdir(exist_ok=True)
    big.save(out / "icon-1024.png")
    for n in (512, 114):
        big.resize((n, n), Image.LANCZOS).save(out / f"icon-{n}x{n}.png")
    # Android launcher (legacy square-ish rounded icons)
    res = REPO / "app/android/app/src/main/res"
    for d, n in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        big.resize((n, n), Image.LANCZOS).save(res / f"mipmap-{d}" / "ic_launcher.png")
    flat.resize((512, 512), Image.LANCZOS).convert("RGB").save(out / "icon-512-square.png")
    # extension icons
    ext = REPO / "extensions/shared/icons"
    ext.mkdir(parents=True, exist_ok=True)
    for n in (16, 32, 48, 128):
        big.resize((n, n), Image.LANCZOS).save(ext / f"icon{n}.png")
    return big


if __name__ == "__main__":
    main()
