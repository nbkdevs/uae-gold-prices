# Core spec (same in every package)

All packages implement the same pure, offline maths. No package fetches prices: the user passes today's 24K price per gram (for example from [سعر الذهب اليوم في الامارات](https://uaegoldprices.ae/)).

| Function | Rule |
|---|---|
| purity(karat) | 24K → 1; 22/21/18/16/14K → fineness / 999; any other karat → karat / 24 (0 < karat ≤ 24) |
| karat price | price24 × purity(karat) |
| fineness (hallmark) | 24K 999, 22K 914, 21K 874, 18K 749, 16K 666, 14K 583 (the per-mille values UAE price boards and uaegoldprices.ae use) |
| units (grams) | g 1, kg 1000, troy oz 31.1034768, tola 11.6638038, mithqal 4.25 |
| item price | grams × karat price = metal; making = per_gram × grams, or percent of metal, or fixed; VAT (default 5 %, UAE) on metal + making; total = metal + making + VAT |
| zakat | 24K-equivalent grams = Σ grams × purity(karat); due when pure grams ≥ 85 (nisab); zakat = 2.5 % of pure grams × price24 |
| rounding | money to 2 decimals, half away from zero, only on output |
| input | accepts comma decimals ("461,11"), thousands separators ("14,342.21") and Arabic-Indic digits ("٤٦١٫١١") |

## Shared test vectors (price24 = 461.11 AED/g)

| Case | Expected |
|---|---|
| table per gram 24/22/21/18/14 | 461.11 / 421.88 / 403.41 / 345.72 / 269.10 |
| 24K per troy ounce | 14342.12 |
| 1 tola, 1 oz in grams | 11.6638038, 31.1034768 |
| 10 g 21K, making 30 AED/g, VAT 5 % | metal 4034.14, making 300.00, VAT 216.71, total 4550.84 |
| 1 oz 24K at 400, VAT 0 | 12441.39 |
| 5 g 18K at 400, making 10 %, VAT 0 | 1649.45 |
| 5 g 18K at 400, making 99 fixed, VAT 0 | 1598.50 |
| zakat 100 g 21K | pure 87.4875 g, due, zakat 1008.53 |
| zakat 90 g 18K | pure 67.4775 g, not due, zakat 0 |
| table at 461.74 (uaegoldprices.ae board, 3 Nov 2026) | 461.74 / 422.45 / 403.96 / 346.19 / 269.46 |
| purity(16), purity(9) | 666 / 999, 9 / 24 |

Disclaimer: results are estimates. Shops quote their own karat rates, making charges and VAT treatment (investment bars and coins of 99 %+ purity are zero-rated for VAT in the UAE; jewellery is standard-rated). Zakat rulings vary; ask a scholar for your case.
