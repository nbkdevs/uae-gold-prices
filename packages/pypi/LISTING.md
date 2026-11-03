# PyPI listing: uae-gold-calculator

| Field | Value |
|---|---|
| Registry | PyPI |
| Name | `uae-gold-calculator` (checked free on PyPI on 2026-11-03) |
| Version | 1.0.0 |
| Licence | MIT |
| Author | UAE Gold Prices |
| Homepage | https://uaegoldprices.ae/ |
| Repository | https://github.com/nbkdevs/uae-gold-prices (directory `packages/pypi`) |
| Planned URL | https://pypi.org/project/uae-gold-calculator/ |
| Anchor used | [سعر الذهب اليوم في الامارات](https://uaegoldprices.ae/) (README Links section) |

**Short description:** Gold value calculator for the UAE: karat prices per gram, tola and ounce, making charges, 5% VAT and zakat. Arabic + English CLI, no dependencies.

**Long description:** see `README.md`.

**Dry-run:** `pytest; python -m build; twine check dist/*`: 6 passed (pytest, `PYTHONPATH=src`); sdist + wheel built; `twine check` PASSED for both (3 Nov 2026, 14:55 PKT).

**Publish (not run, needs the owner's OK):** `cd packages/pypi && python -m build && twine upload dist/*`
