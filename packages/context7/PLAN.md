# Context7 plan

Status: Pending (not submitted). Context7 is not in the tracking sheet; this is an optional extra.

The site has no `/llms.txt` (https://uaegoldprices.ae/llms.txt returned 404 on 3 Nov 2026), so there are two ways in:

1. **Library entry from GitHub (no site access needed).** Copy `context7.json` to the repo root, then submit https://github.com/nbkdevs/uae-gold-prices at https://context7.com/add-library. Context7 indexes the package READMEs, `packages/SPEC.md` and the skill; every README carries the anchor [سعر الذهب اليوم في الامارات](https://uaegoldprices.ae/).
2. **Site entry via llms.txt.** Upload `llms.txt` (this folder) to the site root as https://uaegoldprices.ae/llms.txt (WordPress: a static file in the web root, or a plugin such as "LLMs.txt Generator"), then submit that URL at https://context7.com/add-library as an llms.txt source. This needs access to the WordPress host.

Decision for the owner: option 1, option 2, both, or skip. Nothing has been submitted.
