import pytest

import uae_gold_calculator as g
from uae_gold_calculator.cli import main


def test_table():
    t = g.price_table(461.11)
    assert [r["per_gram"] for r in t] == [461.11, 422.68, 403.47, 345.83, 268.98]
    assert t[0]["per_ounce"] == 14342.12
    assert t[1]["hallmark"] == 916


def test_convert():
    assert g.round_money(g.convert(1, "tola", "g"), 7) == 11.6638038
    assert g.round_money(g.convert(1, "oz", "g"), 7) == 31.1034768
    assert g.round_money(g.convert(10, "مثقال", "g"), 2) == 42.5
    with pytest.raises(ValueError):
        g.convert(1, "stone", "g")


def test_item():
    r = g.item_price(461.11, 10, karat=21, making=30)
    assert (r["metal"], r["making"], r["vat"], r["total"]) == (4034.71, 300.0, 216.74, 4551.45)
    assert g.item_price(400, 1, unit="oz", vat_rate=0)["total"] == 12441.39
    assert g.item_price(400, 5, karat=18, making=10, making_type="percent", vat_rate=0)["total"] == 1650.0
    assert g.item_price(400, 5, karat=18, making=99, making_type="fixed", vat_rate=0)["total"] == 1599.0


def test_zakat():
    due = g.zakat(461.11, [{"weight": 100, "karat": 21}])
    assert due["pure_grams"] == 87.5 and due["due"] and due["zakat"] == 1008.68
    nd = g.zakat(461.11, [{"weight": 90, "karat": 18}])
    assert not nd["due"] and nd["zakat"] == 0


def test_parse():
    assert g.parse_number("٤٦١٫١١") == 461.11
    assert g.parse_number("461,11") == 461.11
    assert g.parse_number("14,342.21") == 14342.21
    with pytest.raises(ValueError):
        g.karat_price(-1, 22)


def test_cli(capsys):
    assert main(["item", "--price", "461.11", "--weight", "10", "--karat", "21", "--making", "30"]) == 0
    assert "4551.45" in capsys.readouterr().out
    assert main(["zakat", "--price", "461.11", "--weight", "90", "--karat", "18", "--lang", "ar"]) == 0
    assert "النصاب" in capsys.readouterr().out
