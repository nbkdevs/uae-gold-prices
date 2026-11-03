# Brand: UAE Gold Prices

| | |
|---|---|
| Brand / author | UAE Gold Prices |
| Site | https://uaegoldprices.ae/ (Arabic, WordPress; live 24/22/21/18/14K prices in AED per gram and ounce, per-emirate prices, silver/platinum/palladium, history) |
| Tagline (GitHub description) | سعر الذهب اليوم في الإمارات مع أسعار الذهب حسب الجرام والأونصة. |
| Main keyword / anchor | **سعر الذهب اليوم في الامارات** → https://uaegoldprices.ae/ (exact text, every in-text link) |
| Pages used | `/privacy-policy/`, `/contact-us/` (`/contact/` redirects), `/about-us/` (all 200 on 3 Nov 2026) |
| GitHub | https://github.com/nbkdevs/uae-gold-prices |
| Publisher accounts (planned) | GitHub/ClawHub/Smithery `nbkdevs`, Docker Hub/HF `iamnazzal` (imc precedent) |
| Licence | MIT © UAE Gold Prices, version 1.0.0 |

## Slugs

| Form | Value |
|---|---|
| kebab | `uae-gold-calculator` |
| snake | `uae_gold_calculator` |
| Pascal / .NET | `UaeGoldPrices.GoldCalculator` |
| PHP vendor/package | `uaegoldprices/gold-calculator` |
| Android app id | `com.uaegoldprices.uae_gold_calculator` |
| Extension (no brand) | `karat-gold-calculator`, gecko id `karat-gold-calculator@nbkdevs` |
| Theme (no brand) | `gilded-dune` |
| Skill | `gold-value-calculator` |

## Naming rules

- Packages, Docker, HF Space, skill, app and Product Hunt may use the brand ("UAE Gold …").
- Browser extension and theme: **no brand, trademark or place names** in the store name, and the description does not mention or link the site. The site goes only in the homepage / support / privacy URL fields. `extensions/package.py` enforces this and the popup carries no link.

## Short description

Gold value calculator: karat prices per gram, tola and ounce, jewellery price with making charge and 5% VAT, and zakat on gold. Arabic and English, offline.

## Long blurb (README)

Type today's 24K gold price once and get every karat per gram, tola and ounce, the price of a jewellery piece with its making charge (per gram, percentage or fixed) and 5% VAT, zakat on gold against the 85 g nisab, and a unit converter. The same tested maths ships as libraries for seven languages, a Docker API, a static web page, an Android app and a browser extension. For the live rate, see [سعر الذهب اليوم في الامارات](https://uaegoldprices.ae/).

## Asset → link field map

| Asset | Link fields carrying https://uaegoldprices.ae/ |
|---|---|
| GitHub repo | About → Website (`--homepage`), README Links (anchor) |
| npm | `homepage`, README Links |
| PyPI | `project.urls` Homepage, README Links |
| crates.io | `homepage`, README Links |
| pub.dev | `homepage`, README Links |
| NuGet | `PackageProjectUrl`, README Links |
| RubyGems | `homepage`, `metadata.homepage_uri`, README Links |
| Packagist | `homepage`, `authors.homepage`, README Links |
| Docker Hub | OCI `image.url` + `image.documentation` labels, README Links, page footer |
| HF Space | README Links, page footer anchor |
| Context7 | `llms.txt` links |
| Skill (ClawHub/Smithery) | `metadata.openclaw.homepage`, Reference section anchor |
| Android app (Amazon/Play) | About screen anchor (`lib/app_info.dart`), developer website, privacy URL, description |
| Firefox / Edge extension | homepage, support, privacy URL fields only |
| Chrome theme | homepage / support URL fields only |
| Product Hunt | Website field, maker comment |
| SourceForge | project homepage, description |

## Graphics (store-assets/)

| Use | File |
|---|---|
| Icon 512 / 114 / 1024 | `icons/icon-512x512.png`, `icons/icon-512-square.png`, `icons/icon-114x114.png`, `icons/icon-1024.png` |
| Play feature graphic 1024x500 | `app/feature-graphic-1024x500.png` |
| Phone screenshots 1080x1920 / 800x1280 (AR + EN) | `app/phone-1080x1920/`, `app/phone-800x1280/` |
| Extension 1280x800, 640x400 (AR + EN), promo 440x280, Edge 300x300, AMO 128 | `extension/` |
| Theme 1280x800, 640x400, 440x280, 128 | `theme/` |
| Product Hunt gallery 1270x760, thumbnail 240x240 | `producthunt/` |

Regenerate: `python3 store-assets/make_icon.py && python3 store-assets/make_assets.py`.
