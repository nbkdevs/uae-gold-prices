# Privacy

Applies to the UAE Gold Calculator Android app, the "Karat Gold Value Calculator" browser extension, the "Gilded Dune" theme, the packages, the Docker image and the Hugging Face Space in this repository.

- **No personal data is collected.** There is no account, no analytics, no ads SDK and no tracking.
- **No network use.** The app and the extension make no network requests; you type the gold price yourself. The Docker image only answers requests sent to it.
- **On-device storage only.** The last price you entered, its unit and your language choice are saved on your device (Android `shared_preferences`, browser `localStorage`). Uninstalling or clearing site data removes them.
- **Permissions.** The Android release build requests no permissions. The extension's manifest has `"permissions": []`.
- **Links.** The app's About screen opens our website in your browser when you tap the link. That site has its own policy: https://uaegoldprices.ae/privacy-policy/

Questions: https://uaegoldprices.ae/contact-us/

Last updated 3 Nov 2026.
