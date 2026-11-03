"""Command line: uae-gold-calculator table|item|convert|zakat."""
from __future__ import annotations

import argparse
import json
import sys

from . import LABELS, __version__, convert, item_price, price_table, round_money, zakat


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="uae-gold-calculator",
                                description="Gold karat prices, making charges, VAT and zakat. "
                                            "Today's 24K price: https://uaegoldprices.ae/")
    p.add_argument("--version", action="version", version=__version__)
    sub = p.add_subparsers(dest="cmd", required=True)
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--lang", choices=["ar", "en"], default="en")
    common.add_argument("--json", action="store_true")
    t = sub.add_parser("table", parents=[common]); t.add_argument("--price", required=True)
    i = sub.add_parser("item", parents=[common])
    i.add_argument("--price", required=True); i.add_argument("--weight", required=True)
    i.add_argument("--unit", default="g"); i.add_argument("--karat", type=float, default=24)
    i.add_argument("--making", default="0")
    i.add_argument("--making-type", default="per_gram", choices=["per_gram", "percent", "fixed"])
    i.add_argument("--vat", default="0.05")
    c = sub.add_parser("convert"); c.add_argument("value"); c.add_argument("from_unit"); c.add_argument("to_unit")
    z = sub.add_parser("zakat", parents=[common])
    z.add_argument("--price", required=True); z.add_argument("--weight", required=True)
    z.add_argument("--unit", default="g"); z.add_argument("--karat", type=float, default=24)
    return p


def _k(v: float):
    return int(v) if float(v).is_integer() else v


def main(argv: list[str] | None = None) -> int:
    a = build_parser().parse_args(argv)
    if a.cmd == "convert":
        print(round_money(convert(a.value, a.from_unit, a.to_unit), 4))
        return 0
    L = LABELS[a.lang]
    if a.cmd == "table":
        rows = price_table(a.price)
        if a.json:
            print(json.dumps(rows, ensure_ascii=False, indent=2)); return 0
        print("\t".join([L["karat"], L["per_gram"], L["per_tola"], L["per_ounce"]]))
        for r in rows:
            print(f"{r['karat']}K ({r['hallmark']})\t{r['per_gram']:.2f}\t{r['per_tola']:.2f}\t{r['per_ounce']:.2f}")
        return 0
    if a.cmd == "item":
        r = item_price(a.price, a.weight, a.unit, _k(a.karat), a.making, a.making_type, a.vat)
        if a.json:
            print(json.dumps(r, ensure_ascii=False, indent=2)); return 0
        cur = L["currency"]
        print(f"{L['metal']}: {r['metal']:.2f} {cur}")
        print(f"{L['making']}: {r['making']:.2f} {cur}")
        print(f"{L['vat']} ({r['vat_rate'] * 100:.0f}%): {r['vat']:.2f} {cur}")
        print(f"{L['total']}: {r['total']:.2f} {cur}")
        return 0
    r = zakat(a.price, [{"weight": a.weight, "unit": a.unit, "karat": _k(a.karat)}])
    if a.json:
        print(json.dumps(r, ensure_ascii=False, indent=2)); return 0
    print(f"{L['zakat_due']}: {r['zakat']:.2f} {L['currency']}" if r["due"] else L["not_due"])
    return 0


if __name__ == "__main__":
    sys.exit(main())
