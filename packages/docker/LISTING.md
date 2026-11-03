# Docker Hub listing: iamnazzal/uae-gold-calculator

| Field | Value |
|---|---|
| Registry | Docker Hub |
| Name | `iamnazzal/uae-gold-calculator` (checked free via hub.docker.com v2 API on 2026-11-03) |
| Version | 1.0.0 (+ latest) |
| Licence | MIT |
| Homepage | https://uaegoldprices.ae/ |
| Repository | https://github.com/nbkdevs/uae-gold-prices (directory `packages/docker`) |
| Planned URL | https://hub.docker.com/r/iamnazzal/uae-gold-calculator |
| OCI labels | image.url and image.documentation = https://uaegoldprices.ae/ |
| Anchor used | [سعر الذهب اليوم في الامارات](https://uaegoldprices.ae/) (README Links section; paste the README as the Hub overview) |

**Short description (≤100 chars):** Gold value API + Arabic/English calculator: karat prices, making charge, 5% VAT, zakat

**Publish (not run, needs the owner's OK):** `cd packages && docker build -f docker/Dockerfile -t iamnazzal/uae-gold-calculator:1.0.0 -t iamnazzal/uae-gold-calculator:latest . && docker push --all-tags iamnazzal/uae-gold-calculator`

**Dry-run:** `node --test` pass (API, static files, path traversal). The box has no Docker daemon, so the image was built daemonless with go-containerregistry (3 Nov 2026, 14:41 PKT; not pushed): base `node:22-alpine` + one app layer with the same config as the Dockerfile (USER node, WORKDIR /app, port 8080, HEALTHCHECK, OCI labels incl. image.url = https://uaegoldprices.ae/). amd64 `sha256:202e69fcbad4e81b0043b8eb48531132ee68d9172b16597627bf21d1cd31b06a`, arm64 `sha256:e917e9b69b77db79ef3a1d66bb98a7a4447b362153c41015613ba6c2c7dc4a14` (about 61 MB tar each, box-only at /tmp/ocib/uae-out/). Smoke test of the app layer with node: `/api/item?price=461,11&weight=10&karat=21&making=30` → total 4550.84, `/` → 200, `/healthz` → ok. A real `docker build` was not run.
