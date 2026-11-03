# Browser store listings: Karat Gold Value Calculator (Firefox AMO, Edge) and Gilded Dune (Chrome Web Store theme)

Written 3 Nov 2026 (PKT). Browser-store items carry no brand, trademark or place names. The listing copy has no site link or site name.
The site goes ONLY in the URL fields below. (The Android app copy lives in `app/APP_STORE_LISTING.md`.)

## URL fields (the only place the site appears)

| Field | AMO (Firefox) | Edge Add-ons | Chrome Web Store (theme) |
|---|---|---|---|
| Homepage / website | https://uaegoldprices.ae/ | https://uaegoldprices.ae/ | https://uaegoldprices.ae/ |
| Support | https://uaegoldprices.ae/contact-us/ | https://uaegoldprices.ae/contact-us/ | https://uaegoldprices.ae/contact-us/ |
| Privacy policy | https://uaegoldprices.ae/privacy-policy/ | https://uaegoldprices.ae/privacy-policy/ | https://uaegoldprices.ae/privacy-policy/ |

All three pages were checked on 3 Nov 2026 and return 200 (`/contact/` redirects to `/contact-us/`).

## Packages

| Store | Zip | Name in manifest |
|---|---|---|
| Firefox AMO | `dist/karat-gold-calculator-firefox-1.0.0.zip` (gecko id `karat-gold-calculator@nbkdevs`, data collection `none`) | Karat Gold Value Calculator |
| Edge Add-ons | `dist/karat-gold-calculator-edge-1.0.0.zip` | Karat Gold Value Calculator |
| Chrome Web Store (theme only) | `dist/gilded-dune-chrome-theme-1.0.0.zip` | Gilded Dune |

Rebuild with `python3 ../web/build.py && python3 package.py`. `package.py` fails if a manifest asks for any permission, if the popup links anywhere, or if a manifest names the brand or a place.

## Images (../store-assets/)

| Store | Asset | File |
|---|---|---|
| AMO | Screenshots 1280x800 | `store-assets/extension/screenshot-{1-table,2-item,3-zakat,4-conv}-{en,ar}-1280x800.png` |
| AMO | Icon 128 | `store-assets/extension/amo-icon-128x128.png` |
| Edge | Screenshots 1280x800 or 640x400 | `store-assets/extension/screenshot-*-{en,ar}-{1280x800,640x400}.png` |
| Edge | Logo 300x300 | `store-assets/extension/edge-logo-300x300.png` |
| Edge | Small promotional tile 440x280 | `store-assets/extension/promo-small-440x280.png` |
| CWS theme | Screenshot 1280x800 or 640x400 | `store-assets/theme/gilded-dune-screenshot-{1280x800,640x400}.png` |
| CWS theme | Small promo tile 440x280 | `store-assets/theme/gilded-dune-small-promo-440x280.png` |
| CWS theme | Icon 128 | `store-assets/theme/gilded-dune-icon-128x128.png` |

---

## Karat Gold Value Calculator (AMO + Edge)

**Category:** AMO: Other / Shopping. Edge: Productivity.
**Support email:** the owner's support address (to fill when submitting).

### English

**Name:** Karat Gold Value Calculator

**Summary (≤ 132 chars, same as manifest):**
Offline gold calculator: karat prices per gram, tola and ounce, item price with making charge and VAT, zakat and units. AR/EN.

**Description:**
A small, private calculator for anyone who buys, sells or owns gold jewellery.

Type today's 24K price once (per gram or per troy ounce) and the popup works out the rest:

- Karat table: 24K, 22K, 21K, 18K and 14K prices per gram, per tola and per ounce, with hallmarks (999, 916, 875, 750, 585).
- Item price: weight, karat and making charge (per gram, a percentage of the gold value, or a fixed amount), plus optional 5% VAT, with a line-by-line breakdown.
- Zakat on gold: add several pieces of different karats; it converts them to pure gold, compares the total with the 85 g nisab and shows the 2.5% due.
- Unit converter: gram, kilogram, troy ounce, tola and mithqal, with the value at your price.
- Arabic (right-to-left) and English, switch with one tap.

Private by design: no account, no ads, no tracking and no network requests. The extension asks for no permissions. Your last price and language are kept in this browser only.

Results are estimates. Shop prices, making charges and VAT treatment vary; check with your jeweller and a scholar for zakat rulings.

### العربية

**الاسم:** حاسبة قيمة الذهب بالعيار (Karat Gold Value Calculator)

**الملخص:**
حاسبة ذهب بدون إنترنت: أسعار العيارات للجرام والتولة والأونصة، سعر القطعة مع المصنعية والضريبة، الزكاة والوحدات.

**الوصف:**
حاسبة صغيرة وخاصة لكل من يشتري الذهب أو يبيعه أو يملكه.

أدخل سعر عيار 24 اليوم مرة واحدة (للجرام أو للأونصة) وتتولى الإضافة الباقي:

- جدول العيارات: أسعار 24 و22 و21 و18 و14 للجرام والتولة والأونصة مع الدمغة (999، 916، 875، 750، 585).
- سعر القطعة: الوزن والعيار والمصنعية (للجرام أو نسبة من قيمة الذهب أو مبلغ ثابت) مع ضريبة القيمة المضافة 5% اختياريًا، وتفصيل كل بند.
- زكاة الذهب: أضف عدة قطع بعيارات مختلفة، فتحوّلها إلى ذهب خالص وتقارنه بنصاب 85 جرامًا وتحسب 2.5% المستحقة.
- محوّل الوحدات: الجرام والكيلوجرام والأونصة والتولة والمثقال، مع القيمة بسعرك.
- العربية والإنجليزية بلمسة واحدة.

خصوصية تامة: بلا حساب ولا إعلانات ولا تتبع ولا اتصال بالإنترنت. لا تطلب الإضافة أي أذونات، ويُحفظ آخر سعر ولغة في هذا المتصفح فقط.

النتائج تقديرية؛ تختلف أسعار المحلات والمصنعية والضريبة، ويُرجع إلى أهل العلم في أحكام الزكاة.

### Single purpose (Edge / CWS field)
EN: Calculate the value of gold by karat, the price of a jewellery piece with making charge and VAT, and zakat on gold, offline in a toolbar popup.
AR: حساب قيمة الذهب حسب العيار وسعر قطعة المجوهرات مع المصنعية والضريبة وزكاة الذهب، دون إنترنت في نافذة شريط الأدوات.

### Permission justification
EN: None requested. The manifest has `"permissions": []`, no host permissions, no content scripts and no background script. The popup uses the page's own `localStorage` to remember the last price and language; no data leaves the device.
AR: لا تطلب الإضافة أي أذونات. لا توجد أذونات مواقع ولا نصوص محتوى ولا خدمة خلفية. تستخدم النافذة `localStorage` لتذكّر آخر سعر واللغة فقط، ولا تغادر أي بيانات الجهاز.

### Data usage / privacy answers
- Collects personal data: **No** (AMO `data_collection_permissions.required: ["none"]`).
- Remote code: **No**.
- Sold or transferred to third parties: **No**.

### Notes for reviewers
See `edge/NOTES_FOR_CERTIFICATION.md` (test steps: price 461.11, 10 g 21K, making 30/g, VAT on → 4,551.45).

---

## Gilded Dune (Chrome Web Store theme)

**Category:** Themes. **Language:** English (Arabic text below for the localized listing).

### English
**Name:** Gilded Dune
**Summary (manifest):** A warm gold theme: sunlit desert dunes at dusk, a bronze frame and a soft sand toolbar.
**Description:**
Gilded Dune wraps your browser in warm gold. The new tab shows layered dunes under a low evening sun, the frame is deep bronze, and the toolbar is a soft sand tone that keeps text easy to read. Tabs, icons and the address bar use matching gold and cream colours. No permissions, no extras, just colour.

### العربية
**الاسم:** Gilded Dune (الكثبان الذهبية)
**الوصف:**
ثيم ذهبي دافئ لمتصفحك: كثبان رملية متتالية تحت شمس الغروب في صفحة علامة التبويب الجديدة، وإطار برونزي، وشريط أدوات بلون الرمل الفاتح يسهل القراءة. الألوان متناسقة في التبويبات والأيقونات وشريط العنوان. بلا أذونات، فقط ألوان.

**Permission justification:** none (themes cannot request permissions).
