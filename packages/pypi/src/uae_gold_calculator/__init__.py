"""uae-gold-calculator: gold karat prices, unit conversion, making charges, VAT and zakat.

Pure functions, no dependencies, no network. Pass today's 24K price per gram
(for example from https://uaegoldprices.ae/).
"""
from __future__ import annotations

import math
import re
from typing import Iterable, Mapping

__version__ = "1.0.0"
__all__ = [
    "KARATS", "HALLMARKS", "UNITS", "UAE_VAT_RATE", "NISAB_GRAMS", "ZAKAT_RATE", "LABELS",
    "round_money", "parse_number", "normalize_unit", "purity", "convert", "karat_price",
    "price_table", "item_price", "zakat",
]

KARATS = (24, 22, 21, 18, 14)
# Fineness per mille used by UAE gold price boards (and uaegoldprices.ae).
# A karat's price = 24K price x fineness / 999; other karats fall back to karat / 24.
HALLMARKS = {24: 999, 22: 914, 21: 874, 18: 749, 16: 666, 14: 583}
UNITS = {"g": 1.0, "kg": 1000.0, "oz": 31.1034768, "tola": 11.6638038, "mithqal": 4.25}
_ALIASES = {
    "gram": "g", "grams": "g", "gr": "g", "جرام": "g", "غرام": "g",
    "kilogram": "kg", "kilo": "kg", "كيلو": "kg",
    "ounce": "oz", "troy-ounce": "oz", "troy_ounce": "oz", "ozt": "oz", "أونصة": "oz", "اونصة": "oz",
    "tolas": "tola", "تولة": "tola",
    "mithqals": "mithqal", "misqal": "mithqal", "مثقال": "mithqal",
}
UAE_VAT_RATE = 0.05
NISAB_GRAMS = 85.0
ZAKAT_RATE = 0.025

LABELS = {
    "en": {"karat": "Karat", "per_gram": "Per gram", "per_tola": "Per tola", "per_ounce": "Per ounce",
           "metal": "Gold value", "making": "Making charge", "vat": "VAT", "total": "Total",
           "zakat_due": "Zakat due", "not_due": "Below nisab: no zakat due", "currency": "AED"},
    "ar": {"karat": "العيار", "per_gram": "سعر الجرام", "per_tola": "سعر التولة", "per_ounce": "سعر الأونصة",
           "metal": "قيمة الذهب", "making": "المصنعية", "vat": "ضريبة القيمة المضافة", "total": "الإجمالي",
           "zakat_due": "الزكاة المستحقة", "not_due": "أقل من النصاب: لا زكاة", "currency": "د.إ"},
}


def round_money(x: float, dp: int = 2) -> float:
    """Round half away from zero."""
    f = 10 ** dp
    v = math.floor(abs(x) * f + 0.5 + 1e-9) / f
    return -v if x < 0 else v


_AR_DIGITS = {ord(c): str(i) for i, c in enumerate("٠١٢٣٤٥٦٧٨٩")}
_AR_DIGITS.update({ord(c): str(i) for i, c in enumerate("۰۱۲۳۴۵۶۷۸۹")})
_AR_DIGITS.update({0x066B: ".", 0x066C: ""})


def parse_number(value) -> float:
    """Parse numbers with comma decimals, thousands separators or Arabic-Indic digits."""
    if isinstance(value, (int, float)):
        return float(value)
    if value is None:
        raise ValueError("number required")
    s = re.sub(r"\s", "", str(value).translate(_AR_DIGITS))
    if re.fullmatch(r"\d{1,3}(,\d{3})+(\.\d+)?", s):
        s = s.replace(",", "")
    else:
        s = s.replace(",", ".", 1)
    return float(s)


def normalize_unit(unit: str | None) -> str:
    u = (unit or "g").strip().lower()
    key = _ALIASES.get(u, u)
    if key not in UNITS:
        raise ValueError(f"Unknown unit: {unit}. Use one of {', '.join(UNITS)}")
    return key


def _check(name: str, v: float, allow_zero: bool = False) -> float:
    if not math.isfinite(v) or v < 0 or (v == 0 and not allow_zero):
        raise ValueError(f"{name} must be {'non-negative' if allow_zero else 'positive'}")
    return v


def purity(karat: float) -> float:
    k = float(karat)
    if not (0 < k <= 24):
        raise ValueError("karat must be between 0 and 24")
    if k == 24:
        return 1.0
    f = HALLMARKS.get(int(k)) if k.is_integer() else None
    return k / 24 if f is None else f / 999


def convert(value, from_unit: str, to_unit: str) -> float:
    v = _check("value", parse_number(value), True)
    return v * UNITS[normalize_unit(from_unit)] / UNITS[normalize_unit(to_unit)]


def karat_price(price24, karat: float) -> float:
    return _check("price24", parse_number(price24)) * purity(karat)


def price_table(price24, karats: Iterable[float] = KARATS) -> list[dict]:
    rows = []
    for k in karats:
        g = karat_price(price24, k)
        rows.append({
            "karat": k,
            "hallmark": HALLMARKS.get(k, round(k / 24 * 1000)),
            "per_gram": round_money(g),
            "per_tola": round_money(g * UNITS["tola"]),
            "per_ounce": round_money(g * UNITS["oz"]),
        })
    return rows


def item_price(price24, weight, unit: str = "g", karat: float = 24, making=0,
               making_type: str = "per_gram", vat_rate=UAE_VAT_RATE) -> dict:
    """Price a piece: metal + making charge + VAT (default 5 %)."""
    grams = _check("weight", parse_number(weight)) * UNITS[normalize_unit(unit)]
    per_gram = karat_price(price24, karat)
    metal = grams * per_gram
    amount = _check("making", parse_number(making), True)
    if making_type == "per_gram":
        mk = amount * grams
    elif making_type == "percent":
        mk = metal * amount / 100
    elif making_type == "fixed":
        mk = amount
    else:
        raise ValueError("making_type must be per_gram, percent or fixed")
    rate = _check("vat_rate", parse_number(vat_rate), True)
    subtotal = metal + mk
    vat = subtotal * rate
    return {
        "grams": round_money(grams, 4), "karat": karat, "price_per_gram": round_money(per_gram),
        "metal": round_money(metal), "making": round_money(mk), "subtotal": round_money(subtotal),
        "vat_rate": rate, "vat": round_money(vat), "total": round_money(subtotal + vat),
    }


def zakat(price24, items: Iterable[Mapping], nisab_grams: float = NISAB_GRAMS) -> dict:
    """Zakat on gold items [{'weight': 100, 'karat': 21, 'unit': 'g'}]."""
    p = _check("price24", parse_number(price24))
    pure = 0.0
    for it in items:
        w = _check("weight", parse_number(it["weight"]), True)
        pure += w * UNITS[normalize_unit(it.get("unit"))] * purity(it.get("karat", 24))
    value = pure * p
    due = pure + 1e-9 >= nisab_grams
    return {
        "pure_grams": round_money(pure, 4), "value": round_money(value), "nisab_grams": nisab_grams,
        "nisab_value": round_money(nisab_grams * p), "due": due,
        "zakat": round_money(value * ZAKAT_RATE) if due else 0.0,
    }
