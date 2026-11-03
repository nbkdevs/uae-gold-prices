#!/usr/bin/env python3
"""Draw the Gilded Dune theme images (gold dunes at dusk) with PIL and write manifest.json."""
import json
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent
IMG = ROOT / "images"
IMG.mkdir(exist_ok=True)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def grad(w, h, stops):
    im = Image.new("RGB", (w, h))
    d = ImageDraw.Draw(im)
    n = len(stops) - 1
    for y in range(h):
        t = y / max(1, h - 1)
        i = min(int(t * n), n - 1)
        d.line([(0, y), (w, y)], fill=lerp(stops[i], stops[i + 1], t * n - i))
    return im


def dune_layer(w, h, base_y, amp, waves, phase, col_top, col_bot, ridge):
    pts = []
    for x in range(0, w + 8, 8):
        t = x / w
        y = base_y + sum(a * math.sin(2 * math.pi * (f * t) + p) for a, f, p in zip(amp, waves, phase))
        pts.append((x, y))
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).polygon(pts + [(w, h), (0, h)], fill=255)
    top = int(min(p[1] for p in pts))
    fill = Image.new("RGB", (w, h), col_bot)
    fill.paste(grad(w, h - top, [col_top, col_bot]), (0, top))
    layer = fill.convert("RGBA")
    layer.putalpha(mask)
    rl = Image.new("L", (w, h), 0)
    ImageDraw.Draw(rl).line(pts, fill=200, width=max(2, h // 400))
    rl = rl.filter(ImageFilter.GaussianBlur(h / 700))
    r = Image.new("RGBA", (w, h), ridge + (0,))
    r.putalpha(rl)
    layer.alpha_composite(r)
    return layer


def ntp(w=2560, h=1440):
    im = grad(w, h, [(52, 34, 30), (142, 82, 46), (226, 160, 82), (247, 210, 140)]).convert("RGBA")
    sun = Image.new("L", (w, h), 0)
    cx, cy, r = w * .66, h * .50, h * .11
    ImageDraw.Draw(sun).ellipse([cx - r, cy - r, cx + r, cy + r], fill=255)
    halo = sun.filter(ImageFilter.GaussianBlur(h * .08))
    for m, c in ((halo, (255, 222, 150)), (sun, (255, 238, 190))):
        s = Image.new("RGBA", (w, h), c + (0,))
        s.putalpha(m)
        im.alpha_composite(s)
    layers = [
        (h * .60, (h * .035, h * .02), (1.3, 3.1), (0.4, 1.9), (196, 128, 58), (150, 90, 38), (250, 214, 140)),
        (h * .70, (h * .045, h * .015), (0.9, 2.4), (2.2, 0.3), (214, 150, 62), (160, 98, 34), (255, 226, 150)),
        (h * .80, (h * .05, h * .02), (0.7, 1.8), (4.0, 1.1), (232, 176, 82), (176, 112, 38), (255, 236, 170)),
        (h * .90, (h * .04, h * .015), (0.5, 1.4), (1.0, 2.8), (204, 140, 52), (120, 74, 26), (255, 226, 150)),
    ]
    for by, amp, wv, ph, ct, cb, rg in layers:
        im.alpha_composite(dune_layer(w, h, by, amp, wv, ph, ct, cb, rg))
    return im.convert("RGB")


def main():
    ntp().save(IMG / "theme_ntp_background.png", optimize=True)
    grad(1600, 120, [(92, 62, 24), (64, 42, 18)]).save(IMG / "theme_frame.png")
    grad(1600, 120, [(250, 238, 212), (243, 228, 196)]).save(IMG / "theme_toolbar.png")
    grad(1600, 120, [(132, 92, 40), (108, 74, 30)]).save(IMG / "theme_tab_background.png")
    manifest = {
        "manifest_version": 3,
        "name": "Gilded Dune",
        "version": "1.0.0",
        "description": "A warm gold theme: sunlit desert dunes at dusk, a bronze frame and a soft sand toolbar.",
        "theme": {
            "images": {
                "theme_frame": "images/theme_frame.png",
                "theme_toolbar": "images/theme_toolbar.png",
                "theme_ntp_background": "images/theme_ntp_background.png",
                "theme_tab_background": "images/theme_tab_background.png",
            },
            "colors": {
                "frame": [86, 58, 22], "frame_inactive": [110, 84, 50], "toolbar": [250, 238, 212],
                "tab_text": [58, 38, 14], "tab_background_text": [250, 232, 196], "bookmark_text": [74, 50, 20],
                "ntp_background": [64, 42, 30], "ntp_text": [255, 244, 222], "ntp_link": [255, 222, 150],
                "ntp_header": [86, 58, 22], "ntp_section": [250, 238, 212], "button_background": [184, 134, 11],
                "toolbar_button_icon": [120, 82, 20], "omnibox_background": [255, 250, 238], "omnibox_text": [58, 38, 14],
            },
            "tints": {"buttons": [0.11, 0.6, 0.35], "frame": [-1.0, -1.0, -1.0],
                      "frame_inactive": [-1.0, -1.0, -1.0], "background_tab": [-1.0, -1.0, -1.0]},
            "properties": {"ntp_background_alignment": "bottom", "ntp_background_repeat": "no-repeat",
                           "ntp_logo_alternate": 1},
        },
    }
    (ROOT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
