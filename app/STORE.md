# UAE Gold Calculator: Android store builds

## Release artifacts (built 3 Nov 2026, 14:53–14:55 PKT; not committed, attach to a GitHub release or upload by hand)

| File | Use | SHA-256 |
|---|---|---|
| `releases/uae-gold-calculator-1.0.0.aab` (53.8 MB) | Google Play Console | `425ccb274db1e192390e6614f2699677d955c4d7d2f5548843a5c778eb7ef6a7` |
| `releases/uae-gold-calculator-1.0.0.apk` (55.5 MB) | Amazon Appstore, sideload | `52a03fb595f3cb3deea29874329ff16c1ff918cebb5bc0e41969ea6fa64a9e9d` |

Checks: `aapt dump badging` shows no `uses-permission` except androidx's own signature-level `…DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (added by androidx.core, not a user permission). `apksigner verify` / `jarsigner -verify` pass, signer `CN=UAE Gold Prices, O=UAE Gold Prices, C=AE`, cert SHA-256 `1f4fc37254a74e74ed422bb0a6d087c881f2602aa41b96056fd7d0383a768e0a`.

Application ID `com.uaegoldprices.uae_gold_calculator`, version 1.0.0 (1), min SDK 24, target SDK 36.

## Signing (keep private)

- Upload keystore: `~/keystores/uae-gold-calculator-upload.jks` on the build box, alias `upload` (never committed).
- Passwords: `~/keystores/uae-gold-calculator-key.properties`, copied to `android/key.properties` (gitignored).
- Back up both offline. Use Play App Signing; this is the upload key.

## Google Play (not done; needs Nazzal's console)

1. Create app, package `com.uaegoldprices.uae_gold_calculator`, default language Arabic (ar), add English (en-US).
2. Upload the AAB to Internal testing, then Production.
3. Listing: copy from `APP_STORE_LISTING.md`; icon `store-assets/icons/icon-512x512.png`; feature graphic `store-assets/app/feature-graphic-1024x500.png`; phone screenshots `store-assets/app/phone-1080x1920/*-{ar,en}.png`; 7" tablet `store-assets/app/phone-800x1280/`.
4. Privacy policy: https://uaegoldprices.ae/privacy-policy/ · Website: https://uaegoldprices.ae/ · Contact page https://uaegoldprices.ae/contact-us/.
5. Data safety: no data collected or shared; the price and language stay on the device (`shared_preferences`). No ads. Category Finance (or Tools). Content rating: Everyone.

## Amazon Appstore (not done; needs Nazzal's developer account)

1. New Android app; upload the APK.
2. Same listing; small icon `store-assets/icons/icon-114x114.png`, large icon `icon-512x512.png`, screenshots 1080x1920 or 800x1280.
3. Category Finance › Personal Finance (or Utilities). No in-app purchases, no ads.
