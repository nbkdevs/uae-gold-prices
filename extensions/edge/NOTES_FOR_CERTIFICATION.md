# Notes for certification (Edge Add-ons)

- Single purpose: an offline gold value calculator shown in the toolbar popup.
- Permissions: none (`"permissions": []`, no host permissions, no content scripts, no background worker).
- Network: the popup makes no network requests. All maths runs locally in `js/gold.js`.
- Storage: `localStorage` keeps the last price the user typed and the language choice. Nothing leaves the device.
- No remote code, no eval, no inline script (MV3 default CSP).
- How to test: open the popup, type `461.11` as the 24K price per gram, open "Item price", enter 10 g, 21K, making 30 per gram, VAT on. Total shows 4,550.84.
