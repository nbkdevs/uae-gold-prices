# Browser extensions

| Folder | Store | Notes |
|---|---|---|
| `shared/` | — | Popup built by `../web/build.py` (same UI as the HF Space and Docker app, without the site footer). Icons from `../store-assets/make_icon.py`. |
| `firefox/` | Firefox AMO | MV3, gecko id `karat-gold-calculator@nbkdevs`, `strict_min_version` 142.0, data collection `none`, `permissions: []`. |
| `edge/` | Edge Add-ons | MV3, `permissions: []`. `NOTES_FOR_CERTIFICATION.md` for reviewers (not zipped). |
| `chrome-theme/` | Chrome Web Store | "Gilded Dune" gold theme. `make_theme.py` draws the images and writes the manifest. |

Build:

```bash
python3 ../web/build.py          # refresh shared/popup.html, css, js
python3 chrome-theme/make_theme.py
python3 package.py               # copies shared/ in, checks manifests, writes dist/*.zip
(cd firefox && npx web-ext lint) # 0 errors, 0 warnings, 0 notices on 3 Nov 2026
```

Rules kept by `package.py`: no permissions or host permissions, no links or inline script in the popup, and no brand, site or place names in any manifest. The site appears only in the store URL fields (see `STORE_LISTINGS.md`).
