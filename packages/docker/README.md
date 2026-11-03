# uae-gold-calculator (Docker image)

A tiny gold value API plus an Arabic/English calculator page, built on the `uae-gold-calculator` npm library. No dependencies, no outbound requests, runs as the unprivileged `node` user on port 8080.

```
docker run --rm -p 8080:8080 iamnazzal/uae-gold-calculator
```

Open http://localhost:8080/ for the calculator page, or call the API:

| Endpoint | Example | Returns |
|---|---|---|
| `/api/table` | `/api/table?price=461.11` | 24/22/21/18/14K per gram, tola and ounce |
| `/api/item` | `/api/item?price=461.11&weight=10&karat=21&making=30` | metal, making, VAT, total (`making_type=per_gram\|percent\|fixed`, `unit=g\|kg\|oz\|tola\|mithqal`, `vat=0` for investment bars) |
| `/api/convert` | `/api/convert?value=2&from=tola&to=g` | `{ "value": 23.3276 }` |
| `/api/zakat` | `/api/zakat?price=461.11&items=100:21,25:18` | pure grams, nisab value, due, zakat (items are `weight:karat[:unit]`) |
| `/healthz` | | `{ "ok": true }` |

`price` is today's 24K price per gram in AED. Example:

```
$ curl -s 'localhost:8080/api/item?price=461.11&weight=10&karat=21&making=30'
{ "grams": 10, "karat": 21, "pricePerGram": 403.41, "metal": 4034.14, "making": 300,
  "subtotal": 4334.71, "vatRate": 0.05, "vat": 216.71, "total": 4550.84 }
```

Build from the repo (context is `packages/`):

```
cd packages && docker build -f docker/Dockerfile -t uae-gold-calculator .
```

## Links

- Live UAE gold rates: [سعر الذهب اليوم في الامارات](https://uaegoldprices.ae/)
- Source: https://github.com/nbkdevs/uae-gold-prices

## License

MIT © UAE Gold Prices
