# UAE Gold Calculator (Flutter, Material 3)

Offline Android app: karat prices, jewellery price with making charge and 5% VAT, zakat on gold and a unit converter, in Arabic (RTL, default) and English. The user types today's 24K price; the app makes no network calls and requests no permissions.

The About screen links our site: [سعر الذهب اليوم في الامارات](https://uaegoldprices.ae/).

| | |
|---|---|
| Application ID | `com.uaegoldprices.uae_gold_calculator` |
| Version | 1.0.0 (versionCode 1), min SDK 24, target SDK 36 |
| Launcher label | Gold Calculator |
| Maths | `lib/core/gold.dart`, a copy of `packages/pub` (same test vectors as every package) |

## Develop

```bash
flutter pub get
flutter analyze            # No issues found
flutter test test/         # 6 tests pass
flutter test screenshots/  # writes ../store-assets/app/raw/*.png (1080x1920 and 800x1280, AR + EN)
```

## Release

```bash
flutter build apk --release        # Amazon Appstore / sideload
flutter build appbundle --release  # Google Play
```

Signing reads `android/key.properties` (gitignored) pointing at the upload keystore kept outside the repo (`~/keystores/uae-gold-calculator-upload.jks`, alias `upload`). Without it the release build falls back to the debug key. See `STORE.md` for the store steps and `APP_STORE_LISTING.md` for the listing copy.
