# Agent skill listing: gold-value-calculator (Smithery + ClawHub)

| Field | Value |
|---|---|
| Platforms | Smithery (skills) and ClawHub |
| Name | `gold-value-calculator` |
| Version | 1.0.0 |
| Licence | MIT |
| Homepage (frontmatter `metadata.openclaw.homepage`) | https://uaegoldprices.ae/ |
| Repository | https://github.com/nbkdevs/uae-gold-prices (directory `skills/gold-value-calculator`) |
| Planned URLs | https://smithery.ai/skills/nbkdevs/gold-value-calculator (exact path depends on Smithery's namespace), https://clawhub.ai/nbkdevs/gold-value-calculator |
| Anchor used | [سعر الذهب اليوم في الامارات](https://uaegoldprices.ae/) (Reference section) |

**Type:** instruction-only (no scripts, installs or network access), so there is nothing to execute or review for security.

**Check:** frontmatter parses as YAML; worked example matches the shared test vectors in `packages/SPEC.md`.

**Publish (not run, needs the owner's OK):** ClawHub: `clawhub publish skills/gold-value-calculator --slug gold-value-calculator --version 1.0.0`. Smithery: add the skill from the GitHub repo path in the Smithery dashboard.

**Blocker (Smithery):** the imc-calculadora notes recorded that the Smithery API/CLI shuts down on 31 Oct 2026; that date has passed, so check whether Smithery still accepts skills before planning it. ClawHub is unaffected.
