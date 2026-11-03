# NuGet listing: UaeGoldPrices.GoldCalculator

| Field | Value |
|---|---|
| Registry | NuGet |
| Name | `UaeGoldPrices.GoldCalculator` (checked free on NuGet on 2026-11-03) |
| Version | 1.0.0 |
| Licence | MIT |
| Author | UAE Gold Prices |
| Homepage | https://uaegoldprices.ae/ |
| Repository | https://github.com/nbkdevs/uae-gold-prices (directory `packages/nuget`) |
| Planned URL | https://www.nuget.org/packages/UaeGoldPrices.GoldCalculator |
| Anchor used | [سعر الذهب اليوم في الامارات](https://uaegoldprices.ae/) (README Links section) |

**Short description:** Gold value calculator for the UAE: karat prices per gram, tola and ounce, making charges, 5% VAT and zakat. No dependencies.

**Long description:** see `README.md`.

**Dry-run:** `dotnet test tests; dotnet pack src -c Release`: 5/5 tests pass (net10.0); `UaeGoldPrices.GoldCalculator.1.0.0.nupkg` created (3 Nov 2026, 14:55 PKT).

**Publish (not run, needs the owner's OK):** `cd packages/nuget && dotnet nuget push src/bin/Release/UaeGoldPrices.GoldCalculator.1.0.0.nupkg --source https://api.nuget.org/v3/index.json --api-key $NUGET_API_KEY`
