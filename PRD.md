<!--
SPDX-License-Identifier: Apache-2.0
Copyright 2026 Andexor Network, Inc.
Author: Ed Jenkins <ed@andexor.net>
-->

# PRD: Contact Us submission service

Status: approved 2026-10-28 by Ed Jenkins
Date: 2026-10-28

## 1. Goal

Accept submissions from the Contact Us dialog on https://andexor.net/ (opened by the Contact Us
CTA button on any page) and store each one as a row in a Cloudflare D1 table. Nothing else.

## 2. Context (verified 2026-10-28)

- The site is a Next.js app served by the Worker `andexor-net-website` on the custom domain
  `andexor.net` (zone id `2826c1aa23954fa65dd22d0aefca885a`, account id
  `89df54b7a586cd4489e7a8bc6cd5145d`).
- The dialog's submit handler builds a request object with keys `name`, `email`, `phone`,
  `website`, `help`, `sourcePath`, then sets the "Request received" state. It makes no network
  request today. Wiring the site to call this service is a separate change in the website repo.
- The account has no D1 database yet.
- Cloudflare routes take precedence over a custom domain on the same hostname, so a route for
  `andexor.net/api/contact*` can target a second Worker without changing the site Worker.
- Python Workers support FastAPI. They are built, run locally, and deployed with `pywrangler`
  (package `workers-py`, run through `uv`), which wraps Wrangler and reads `wrangler.jsonc`.
  Dependencies are bundled from `pyproject.toml` on deploy.

## 3. Form fields observed

| Form field   | Input type | Required | Notes                                      |
|--------------|------------|----------|--------------------------------------------|
| `name`       | text       | yes      | autocomplete name                          |
| `email`      | email      | yes      |                                            |
| `phone`      | tel        | no       | autocomplete tel-national                  |
| `website`    | text       | no       | autocomplete url                           |
| `help`       | textarea   | no       | maxLength 250                              |
| `sourcePath` | hidden     | auto     | path of the page where the CTA was clicked |

"Required" is enforced by the browser only. The service performs no validation.

## 4. Data model

Database: D1 `andexor-net-website-contact-us`. Table: `contact_us`.

| Column        | Type    | Source                                   |
|---------------|---------|------------------------------------------|
| `id`          | INTEGER | primary key, autoincrement               |
| `name`        | TEXT    | form `name`                              |
| `email`       | TEXT    | form `email`                             |
| `phone`       | TEXT    | form `phone`                             |
| `website`     | TEXT    | form `website`                           |
| `help`        | TEXT    | form `help`                              |
| `source_path` | TEXT    | form `sourcePath`                        |
| `received_at` | TEXT    | UTC ISO 8601, set by the Worker          |
| `client_ip`   | TEXT    | request header `CF-Connecting-IP`        |
| `country`     | TEXT    | request header `CF-IPCountry`            |
| `user_agent`  | TEXT    | request header `User-Agent`              |
| `referer`     | TEXT    | request header `Referer`                 |
| `ray_id`      | TEXT    | request header `CF-Ray`                  |

Every column except `id` and `received_at` is nullable. Missing form keys are stored as NULL.
The DDL lives in `schema.sql` and uses `CREATE TABLE IF NOT EXISTS`.

## 5. Service

- Language and framework: Python on Cloudflare Workers, FastAPI mounted through the Workers
  `asgi` module (`asgi.fetch(app, request.js_object, self.env)`). D1 is reached through the
  `DB` binding on `request.scope["env"]`.
- Worker name: `andexor-net-website-contact-us`.
- Route: `andexor.net/api/contact*` on zone `andexor.net`, declared in `wrangler.jsonc`.
- Endpoints:
  - `POST /api/contact`: reads the body as JSON when `Content-Type` is `application/json`,
    otherwise as form data (`application/x-www-form-urlencoded` or `multipart/form-data`).
    Picks the six form keys by name, adds the metadata columns, inserts one row, and returns
    HTTP 200 with body `{"ok": true, "id": <row id>}`.
  - `OPTIONS /api/contact`: CORS preflight, HTTP 204.
  - `GET /api/contact/health`: HTTP 200 with `{"ok": true}`, for smoke tests.
- CORS: `Access-Control-Allow-Origin` echoes the request's `Origin` when it is in the
  comma-separated `ALLOWED_ORIGINS` var in `wrangler.jsonc` (`https://andexor.net`,
  `http://localhost:3000`, `http://localhost:8787`), otherwise the first entry. Methods POST
  and OPTIONS, header Content-Type, `Vary: Origin`.
- Errors: a failed insert returns HTTP 500 with `{"ok": false}`. No other handling.
- No validation, no authentication, no rate limiting, no bot check, no notification email.

## 6. Scripts (run locally with uv, authenticated through the cf CLI)

- `scripts/create_db.py`: creates the D1 database if it does not exist, creates the table if it
  does not exist (from `schema.sql`), and writes the resulting `database_id` into the
  `d1_databases` binding in `wrangler.jsonc`. Idempotent. Uses the `cf d1` commands through
  `subprocess`, so no API token is stored in the repo.
- `scripts/query_db.py`: selects every row from `contact_us` ordered by `id` and prints them as
  one JSON array to stdout. For manual testing.

## 7. Repository layout

```
PRD.md                 this document
pyproject.toml         uv project: fastapi dependency, workers-py and workers-runtime-sdk dev deps,
                       [tool.uv] exclude-newer = "1 week"
wrangler.jsonc         Worker name, main, python_workers flag, route, D1 binding, ALLOWED_ORIGINS var
schema.sql             CREATE TABLE IF NOT EXISTS contact_us (...)
src/worker.py          FastAPI app plus the WorkerEntrypoint Default class
scripts/create_db.py   section 6
scripts/query_db.py    section 6
.mcp.json              Cloudflare MCP server for this project (already added)
README.md              how to set up, run locally, deploy, and test
```

## 8. Tooling rules

- `uv` for all Python package management. No pip, npm, or npx for Python.
- `uv run pywrangler dev` for local development and `uv run pywrangler deploy` to deploy.
  Because the project has a `wrangler.jsonc`, Wrangler (through pywrangler) owns dev and deploy.
- `cf` CLI for Cloudflare resources outside the Worker (D1 create and query, zone lookups).
- Straight quotes only in every file.

## 9. Deployment and verification

1. `uv sync`
2. `uv run scripts/create_db.py`
3. `uv run pywrangler deploy`
4. `curl -X POST https://andexor.net/api/contact` once with a JSON body and once with a
   form-encoded body, each containing the six form keys. Both return HTTP 200.
5. `uv run scripts/query_db.py` prints both rows with the metadata columns populated.

## 10. Out of scope

- Changing the website to call the endpoint.
- Validation, spam protection, email or chat notifications, admin UI, data retention.
- Unit tests and functional tests.
- Docker packaging. The Worker runs on Cloudflare; the existing build.sh, run.sh, and debug.sh
  Docker scripts do not apply to this project and are left untouched.
