#!/usr/bin/env python3
"""Compose every store image from the raw screenshots and the icon.

Inputs:  extension/raw/{table,item,zakat,conv}-{ar,en}.png  (popup, headless Chrome, 2x)
         app/raw/{1-karats,...}-{ar,en}-1080x1920.png       (flutter test screenshots/)
         ../extensions/chrome-theme/images/*                 (make_theme.py)
Outputs: extension/, theme/, app/, producthunt/ (see BRAND.md for the map).
Extension and theme images carry no brand, place or site name.
"""
from pathlib import Path
import shutil
from PIL import Image, ImageDraw, ImageFont, ImageFilter
from make_icon import icon

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent
CAIRO = "/usr/share/fonts/truetype/sand-box/google/Cairo/Cairo-VariableFont_slnt,wght.ttf"
BG, INK, GOLD_D, GOLD = (250, 243, 228), (52, 38, 18), (122, 84, 14), (184, 134, 11)


def font(size, bold=True):
    f = ImageFont.truetype(CAIRO, size, layout_engine=ImageFont.Layout.RAQM)
    try:
        f.set_variation_by_axes([800 if bold else 450, 0])
    except Exception:
        pass
    return f


def card(path, h, radius=18):
    im = Image.open(path).convert("RGBA")
    im = im.resize((int(im.width * h / im.height), h), Image.LANCZOS)
    m = Image.new("L", im.size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, im.width - 1, im.height - 1], radius=radius, fill=255)
    im.putalpha(m)
    return im


def shadowed(can, c, x, y, k=1.0):
    sh = Image.new("RGBA", can.size, (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle([x + 8, y + 14, x + c.width + 8, y + c.height + 14], radius=22, fill=(0, 0, 0, 80))
    can.alpha_composite(sh.filter(ImageFilter.GaussianBlur(14 * k)))
    can.alpha_composite(c, (x, y))


def text_block(d, x, y, lines, f, fill, gap, rtl=False, right=None):
    for line in lines.split("\n"):
        if rtl:
            d.text((right, y), line, font=f, fill=fill, anchor="ra", direction="rtl", language="ar")
        else:
            d.text((x, y), line, font=f, fill=fill)
        y += gap
    return y


def compose(shot, title, sub, out, size=(1280, 800), rtl=False):
    W, H = size
    k = W / 1280
    can = Image.new("RGBA", size, BG + (255,))
    d = ImageDraw.Draw(can)
    for yy in range(H):  # soft gold band at the bottom
        t = max(0, (yy / H - .6) / .4)
        d.line([(0, yy), (W, yy)], fill=tuple(int(BG[i] * (1 - t * .25) + (230, 190, 110)[i] * t * .25) for i in range(3)) + (255,))
    c = card(shot, int(H * .9))
    x = int(110 * k) if rtl else int(W - c.width - 110 * k)
    shadowed(can, c, x, int((H - c.height) / 2), k)
    ic = icon(256).resize((int(90 * k), int(90 * k)), Image.LANCZOS)
    tx, right = int(80 * k), int(W - 80 * k)
    can.alpha_composite(ic, (right - ic.width if rtl else tx, int(140 * k)))
    ty = text_block(d, tx, int(260 * k), title, font(int(50 * k)), GOLD_D, int(72 * k), rtl, right)
    text_block(d, tx, ty + int(16 * k), sub, font(int(25 * k), False), INK, int(42 * k), rtl, right)
    can.convert("RGB").save(out, optimize=True)


def promo(out, size=(440, 280), lines=("Karat Gold", "Calculator"), tag="Offline · private · no account"):
    W, H = size
    can = Image.new("RGBA", size)
    d = ImageDraw.Draw(can)
    for yy in range(H):
        t = yy / H
        d.line([(0, yy), (W, yy)], fill=tuple(int((70, 50, 24)[i] * (1 - t) + (26, 19, 12)[i] * t) for i in range(3)) + (255,))
    can.alpha_composite(icon(256).resize((130, 130), Image.LANCZOS), (24, 72))
    d.text((170, 76), lines[0], font=font(34), fill=(255, 226, 150))
    d.text((170, 122), lines[1], font=font(34), fill=(255, 226, 150))
    d.text((170, 182), tag, font=font(15, False), fill=(240, 226, 196))
    can.convert("RGB").save(out, optimize=True)


EXT_ITEMS = {
    "en": [("table", "Every karat,\nper gram", "Type today's 24K price once and\nsee 24, 22, 21, 18 and 14K per\ngram, tola and ounce."),
           ("item", "Price a piece\nof jewellery", "Weight, karat and making charge\n(per gram, percent or fixed),\nwith optional 5% VAT."),
           ("zakat", "Zakat on gold,\nitem by item", "Adds pure gold across karats,\nchecks the 85 g nisab and\nshows the 2.5% due."),
           ("conv", "Unit converter", "Gram, kilogram, troy ounce,\ntola and mithqal, plus the\nvalue at your price.")],
    "ar": [("table", "كل العيارات\nبسعر الجرام", "أدخل سعر عيار 24 مرة واحدة\nواعرف أسعار 22 و21 و18 و14\nللجرام والتولة والأونصة."),
           ("item", "سعر قطعة\nالمجوهرات", "الوزن والعيار والمصنعية\n(للجرام أو نسبة أو مبلغ ثابت)\nمع ضريبة 5% اختيارية."),
           ("zakat", "زكاة الذهب\nقطعة بقطعة", "يجمع الذهب الخالص من كل العيارات\nويقارنه بنصاب 85 جرامًا\nويحسب 2.5% المستحقة."),
           ("conv", "محوّل الوحدات", "الجرام والكيلو والأونصة\nوالتولة والمثقال، مع القيمة\nبالسعر الذي أدخلته.")],
}


def extension():
    out = ROOT / "extension"
    big = icon(1024)
    big.resize((300, 300), Image.LANCZOS).save(out / "edge-logo-300x300.png")
    big.resize((128, 128), Image.LANCZOS).save(out / "amo-icon-128x128.png")
    for lang, items in EXT_ITEMS.items():
        for i, (n, t, s) in enumerate(items, 1):
            for size in ((1280, 800), (640, 400)):
                compose(out / "raw" / f"{n}-{lang}.png", t, s, out / f"screenshot-{i}-{n}-{lang}-{size[0]}x{size[1]}.png", size, lang == "ar")
    promo(out / "promo-small-440x280.png")


def browser_mock(size=(1280, 800)):
    """A browser window drawn with the theme's own images and colours."""
    W, H = size
    img = REPO / "extensions/chrome-theme/images"
    can = Image.new("RGBA", size)
    can.paste(Image.open(img / "theme_frame.png").resize((W, 46)), (0, 0))
    d = ImageDraw.Draw(can)
    tab_bg = Image.open(img / "theme_tab_background.png").resize((220, 34))
    can.paste(tab_bg, (262, 10))
    tb = Image.open(img / "theme_toolbar.png").resize((W, 46))
    d.rounded_rectangle([20, 8, 250, 46], radius=10, fill=tb.getpixel((0, 0)))
    f = font(15, False)
    d.text((48, 16), "New Tab", font=f, fill=(58, 38, 14))
    d.text((290, 16), "Notes", font=f, fill=(250, 232, 196))
    can.paste(tb, (0, 46))
    d.rounded_rectangle([110, 54, W - 110, 84], radius=15, fill=(255, 250, 238))
    for i, cx in enumerate((24, 52, 80)):
        d.ellipse([cx - 7, 62, cx + 7, 76], outline=(120, 82, 20), width=2)
    ntp = Image.open(img / "theme_ntp_background.png").convert("RGBA")
    area = (W, H - 92)
    sc = max(area[0] / ntp.width, area[1] / ntp.height)
    ntp = ntp.resize((int(ntp.width * sc) + 1, int(ntp.height * sc) + 1), Image.LANCZOS)
    ntp = ntp.crop((0, ntp.height - area[1], area[0], ntp.height))
    can.alpha_composite(ntp, (0, 92))
    d.rounded_rectangle([W * .28, H * .3, W * .72, H * .3 + 46], radius=23, fill=(255, 250, 238))
    d.text((W * .28 + 24, H * .3 + 10), "Search or type a URL", font=f, fill=(140, 112, 72))
    return can


def theme():
    out = ROOT / "theme"
    out.mkdir(exist_ok=True)
    m = browser_mock()
    m.convert("RGB").save(out / "gilded-dune-screenshot-1280x800.png", optimize=True)
    m.resize((640, 400), Image.LANCZOS).convert("RGB").save(out / "gilded-dune-screenshot-640x400.png", optimize=True)
    ntp = Image.open(REPO / "extensions/chrome-theme/images/theme_ntp_background.png").convert("RGBA")
    p = ntp.resize((440, 248), Image.LANCZOS).crop((0, 0, 440, 248))
    can = Image.new("RGBA", (440, 280))
    can.alpha_composite(ntp.resize((497, 280), Image.LANCZOS).crop((28, 0, 468, 280)))
    d = ImageDraw.Draw(can)
    d.text((24, 22), "Gilded Dune", font=font(38), fill=(255, 244, 222))
    d.text((26, 78), "Warm gold dunes at dusk", font=font(16, False), fill=(255, 236, 200))
    can.convert("RGB").save(out / "gilded-dune-small-promo-440x280.png", optimize=True)
    sq = ntp.crop((ntp.width // 2 - ntp.height // 2, 0, ntp.width // 2 + ntp.height // 2, ntp.height)).resize((128, 128), Image.LANCZOS)
    mk = Image.new("L", (128, 128), 0)
    ImageDraw.Draw(mk).rounded_rectangle([0, 0, 127, 127], radius=26, fill=255)
    ic = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    ic.paste(sq, (0, 0), mk)
    ic.save(out / "gilded-dune-icon-128x128.png")
    del p


def app():
    out = ROOT / "app"
    raw = out / "raw"
    for size in ("1080x1920", "800x1280"):
        dest = out / f"phone-{size}"
        dest.mkdir(exist_ok=True)
        for f in sorted(raw.glob(f"*-{size}.png")):
            shutil.copy(f, dest / f.name.replace(f"-{size}", ""))
    # Feature graphic 1024x500
    W, H = 1024, 500
    can = Image.new("RGBA", (W, H))
    d = ImageDraw.Draw(can)
    for x in range(W):
        t = x / W
        d.line([(x, 0), (x, H)], fill=tuple(int((70, 50, 24)[i] * (1 - t) + (24, 18, 12)[i] * t) for i in range(3)) + (255,))
    for i, n in enumerate(("2-item-ar", "1-karats-ar")):
        c = card(raw / f"{n}-1080x1920.png", 440, 22)
        shadowed(can, c, 60 + i * 200, 40 + i * 10 - 10)
    ic = icon(256).resize((110, 110), Image.LANCZOS)
    can.alpha_composite(ic, (W - 60 - 110, 70))
    d.text((W - 60, 200), "حاسبة قيمة الذهب", font=font(46), fill=(255, 226, 150), anchor="ra", direction="rtl", language="ar")
    d.text((W - 60, 282), "Gold Value Calculator", font=font(32), fill=(255, 236, 196), anchor="ra")
    d.text((W - 60, 340), "العيارات · المصنعية · الضريبة · الزكاة", font=font(22, False), fill=(240, 226, 196), anchor="ra", direction="rtl", language="ar")
    can.convert("RGB").save(out / "feature-graphic-1024x500.png", optimize=True)


def producthunt():
    out = ROOT / "producthunt"
    out.mkdir(exist_ok=True)
    W, H = 1270, 760
    shots = [("1-karats", "2-item", "3-zakat"), ("4-units", "5-about", "2-item")]
    heads = [("Gold value in AED, every karat", "سعر الذهب اليوم في الامارات لكل العيارات"),
             ("Jewellery price, VAT and zakat", "المصنعية والضريبة والزكاة في تطبيق واحد")]
    for gi, (names, (en, ar)) in enumerate(zip(shots, heads), 1):
        for lang in ("en", "ar"):
            can = Image.new("RGBA", (W, H), BG + (255,))
            d = ImageDraw.Draw(can)
            if lang == "ar":
                d.text((W / 2, 40), ar, font=font(44), fill=GOLD_D, anchor="ma", direction="rtl", language="ar")
            else:
                d.text((W / 2, 40), en, font=font(44), fill=GOLD_D, anchor="ma")
            for i, n in enumerate(names):
                c = card(raw_app(f"{n}-{lang}"), 600, 26)
                shadowed(can, c, int(W / 2 - 1.5 * c.width - 40 + i * (c.width + 40)), 135)
            can.convert("RGB").save(out / f"gallery-{gi}-{lang}-1270x760.png", optimize=True)
    icon(1024).resize((240, 240), Image.LANCZOS).save(out / "thumbnail-240x240.png")


def raw_app(n):
    return ROOT / "app" / "raw" / f"{n}-1080x1920.png"


if __name__ == "__main__":
    extension()
    theme()
    app()
    producthunt()
    print("ok")
