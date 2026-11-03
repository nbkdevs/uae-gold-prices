# UAE Gold Prices · حاسبة قيمة الذهب

**العربية** · [English](#english)

أدوات مفتوحة المصدر لحساب قيمة الذهب: أسعار العيارات (24، 22، 21، 18، 14) للجرام والتولة والأونصة، وسعر قطعة المجوهرات مع المصنعية وضريبة القيمة المضافة 5%، وزكاة الذهب بنصاب 85 جرامًا، ومحوّل الوحدات. يُدخل المستخدم سعر عيار 24 اليوم، وتعمل الحسابات كلها على الجهاز بدون إنترنت.

لمعرفة السعر المباشر: [سعر الذهب اليوم في الامارات](https://uaegoldprices.ae/).

## المحتويات

| المجلد | الوصف |
|---|---|
| `app/` | تطبيق أندرويد (Flutter، Material 3) بالعربية والإنجليزية، بلا أذونات |
| `extensions/` | إضافة Firefox وEdge (MV3، بلا أذونات) وثيم Chrome ذهبي |
| `packages/` | مكتبات وأدوات سطر أوامر: npm وPyPI وcrates وpub وNuGet وRubyGems وPackagist، وصورة Docker، وHugging Face Space، وContext7 |
| `skills/` | مهارة وكيل ذكاء اصطناعي (SKILL.md) لـ ClawHub وSmithery |
| `web/` | مصدر واجهة الويب الموحدة |
| `store-assets/` | الأيقونات ولقطات الشاشة وصور المتاجر |

جميع الحزم تتبع المواصفات نفسها في `packages/SPEC.md` ونفس قيم الاختبار.

> النتائج تقديرية. تختلف أسعار المحلات والمصنعية والضريبة، ويُرجع إلى أهل العلم في أحكام الزكاة.

---

## English

Open-source gold value tools: karat prices (24K, 22K, 21K, 18K, 14K) per gram, tola and ounce; jewellery price with making charge and 5% UAE VAT; zakat on gold against the 85 g nisab; and a unit converter (g, kg, troy oz, tola, mithqal). You enter today's 24K price; everything runs locally and offline.

| Folder | What | Test |
|---|---|---|
| `app/` | Flutter Material 3 Android app, Arabic RTL + English, no permissions | `flutter test test/` |
| `extensions/` | Firefox + Edge MV3 popup (`permissions: []`) and the "Gilded Dune" Chrome theme | `python3 extensions/package.py`, `web-ext lint` |
| `packages/npm` | `uae-gold-calculator` (JS lib + CLI) | `npm test` |
| `packages/pypi` | `uae-gold-calculator` (Python lib + CLI) | `pytest` |
| `packages/crates` | `uae-gold-calculator` (Rust lib + CLI) | `cargo test` |
| `packages/pub` | `uae_gold_calculator` (Dart lib + CLI) | `dart test` |
| `packages/nuget` | `UaeGoldPrices.GoldCalculator` (.NET lib + tool) | `dotnet test tests` |
| `packages/rubygems` | `uae-gold-calculator` (Ruby gem + CLI) | `ruby -Ilib test/test_uae_gold_calculator.rb` |
| `packages/packagist` | `uaegoldprices/gold-calculator` (PHP, root `composer.json`) | `vendor/bin/phpunit -c packages/packagist/phpunit.xml` |
| `packages/docker` | JSON API + calculator page (Node, no deps) | `npm test` |
| `packages/hf-space` | Static Hugging Face Space, Arabic RTL | open `index.html` |
| `packages/context7` | `llms.txt` and the Context7 plan | — |
| `skills/gold-value-calculator` | Agent skill for ClawHub / Smithery | — |

`web/build.py` builds the one browser UI into the HF Space, the Docker image and the extension popup. Publishing status for every platform is in [`STATUS.md`](STATUS.md); naming rules and the link map are in [`BRAND.md`](BRAND.md).

Results are estimates. Shop prices, making charges and VAT treatment vary.

## Links

- [سعر الذهب اليوم في الامارات](https://uaegoldprices.ae/)
- Privacy: [PRIVACY.md](PRIVACY.md) · https://uaegoldprices.ae/privacy-policy/
- Contact: https://uaegoldprices.ae/contact-us/

## Elsewhere

- npm: https://www.npmjs.com/package/uae-gold-calculator
- PyPI: https://pypi.org/project/uae-gold-calculator/
- crates.io: https://crates.io/crates/uae-gold-calculator
- pub.dev: https://pub.dev/packages/uae_gold_calculator
- NuGet: https://www.nuget.org/packages/UaeGoldPrices.GoldCalculator/
- RubyGems: https://rubygems.org/gems/uae-gold-calculator
- Docker Hub: https://hub.docker.com/r/iamnazzal/uae-gold-calculator
- Hugging Face Space: https://huggingface.co/spaces/iamnazzal/uae-gold-calculator
- ClawHub skill: https://clawhub.ai/nbkdevs/gold-value-calculator

## License

MIT © UAE Gold Prices
