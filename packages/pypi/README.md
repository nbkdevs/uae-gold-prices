# uae-gold-calculator

Gold value calculator for the UAE market. Give it today's 24K price per gram and it works out every karat, any weight unit, the making charge, 5% VAT and zakat, in Arabic or English. No network calls, no dependencies.

- **Karat table**: 24K, 22K, 21K, 18K and 14K per gram, per tola and per troy ounce (purity = karat / 24; hallmarks 999 / 916 / 875 / 750 / 585 shown for reference).
- **Units**: gram, kilogram, troy ounce (31.1034768 g), tola (11.6638038 g) and mithqal (4.25 g). Arabic unit names such as `جرام`, `أونصة`, `تولة`, `مثقال` work too.
- **Jewellery price**: metal value + making charge (AED per gram, percent of metal, or a fixed amount) + VAT on both, the way UAE shops bill it.
- **Zakat**: adds up pure gold across items, compares it with the 85 g nisab and returns 2.5% of the value when due.
- **Friendly input**: `461.11`, `461,11`, `14,342.21` and Arabic-Indic `٤٦١٫١١` all parse.
- **Arabic and English** CLI output (`--lang ar`).

## Install

```
pip install uae-gold-calculator
```

## Library

```python
import uae_gold_calculator as gold

gold.price_table(461.11)[2]
# {'karat': 21, 'hallmark': 875, 'per_gram': 403.47, 'per_tola': 4706.01, 'per_ounce': 12549.36}

gold.item_price(461.11, 10, karat=21, making=30)['total']          # 4551.45
gold.item_price(400, 5, karat=18, making=10, making_type='percent', vat_rate=0)['total']  # 1650.0
gold.convert(1, 'أونصة', 'g')                                        # 31.1034768
gold.zakat(461.11, [{'weight': 100, 'karat': 21}])['zakat']         # 1008.68
gold.parse_number('٤٦١٫١١')                                          # 461.11
```

## CLI

```
$ uae-gold-calculator table --price 461.11
Karat	Per gram	Per tola	Per ounce
24K (999)	461.11	5378.30	14342.12
22K (916)	422.68	4930.11	13146.95
21K (875)	403.47	4706.01	12549.36
18K (750)	345.83	4033.72	10756.59
14K (585)	268.98	3137.34	8366.24

$ uae-gold-calculator item --price 461.11 --weight 10 --karat 21 --making 30 --lang ar
قيمة الذهب: 4034.71 د.إ
المصنعية: 300.00 د.إ
ضريبة القيمة المضافة (5%): 216.74 د.إ
الإجمالي: 4551.45 د.إ

$ uae-gold-calculator convert 2 tola g
23.3276

$ uae-gold-calculator zakat --price 461.11 --weight 100 --karat 21
Zakat due: 1008.68 AED
```

Options for `item`: `--unit g|kg|oz|tola|mithqal`, `--karat`, `--making`, `--making-type per_gram|percent|fixed`, `--vat 0.05` (use `--vat 0` for investment bars, which are zero-rated in the UAE).

## How it calculates

| Step | Formula |
|---|---|
| Karat price per gram | `price24 × karat / 24` |
| Metal value | `grams × karat price` |
| Making charge | `rate × grams`, or `metal × rate / 100`, or a fixed amount |
| VAT | `(metal + making) × 5%` |
| Zakat | `pure grams = Σ grams × karat / 24`; due when ≥ 85 g; `2.5% × pure grams × price24` |

Amounts are rounded half away from zero to 2 decimals on output only. Results are estimates: shop prices, VAT treatment of investment gold and zakat rulings vary, so check with your jeweller or scholar.

## بالعربية

حاسبة لقيمة الذهب في الإمارات: أدخل سعر جرام الذهب عيار 24 اليوم لتحصل على أسعار عيارات 24 و22 و21 و18 و14 بالجرام والتولة والأونصة، وسعر قطعة المجوهرات مع المصنعية وضريبة القيمة المضافة 5%، وحساب زكاة الذهب حسب نصاب 85 جرامًا. تقبل الأرقام العربية مثل ٤٦١٫١١ وأسماء الوحدات بالعربية، وتعمل دون اتصال بالإنترنت.

## Links

- Live UAE gold rates: [سعر الذهب اليوم في الامارات](https://uaegoldprices.ae/)
- Source code: https://github.com/nbkdevs/uae-gold-prices

## License

MIT © UAE Gold Prices
