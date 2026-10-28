# Andexor Base Template

This project is the skeleton of all other projects created by Andexor Network, Inc, providing starter files necessary for licensing, attribution, etc.

# Contact Us submission service

A Python FastAPI Worker on Cloudflare that accepts submissions from the Contact Us dialog on
https://andexor.net/ and stores each one as a row in the D1 table `contact_us`. Served at
`andexor.net/api/contact*`. See `PRD.md` for the requirements.

## Endpoints

- `POST /api/contact`: accepts a JSON body (`Content-Type: application/json`) or a form body
  (anything else). Stores the keys `name`, `email`, `phone`, `website`, `help`, `sourcePath`
  plus request metadata. Returns `{"ok": true, "id": <row id>}`. Returns HTTP 500
  `{"ok": false}` if the insert fails.
- `OPTIONS /api/contact`: CORS preflight, HTTP 204.
- `GET /api/contact/health`: returns `{"ok": true}`.

CORS: the `Access-Control-Allow-Origin` header echoes the request's `Origin` when it is listed
in the `ALLOWED_ORIGINS` var in `wrangler.jsonc` (comma-separated). It currently allows
`https://andexor.net`, `http://localhost:3000`, and `http://localhost:8787` for local testing.

## Prerequisites

- `uv` for Python packages (`install-uv.sh`).
- `cf` CLI, logged in to the Cloudflare account (`install-cf.sh`, then `cf` login).
- Node.js on PATH (`pywrangler` needs it).

Do not use pip, npm, or npx for Python packages in this project.

## Setup

```sh
uv sync
uv run scripts/create_db.py
```

`create_db.py` creates the D1 database `andexor-net-website-contact-us` if it does not exist,
applies `schema.sql`, and writes the database id into the `DB` binding in `wrangler.jsonc`.
It is safe to run again.

## Run locally

```sh
uv run pywrangler dev
```

Then, in another terminal:

```sh
curl -X POST http://localhost:8787/api/contact -H 'Content-Type: application/json' \
  -d '{"name":"Test JSON","email":"test-json@example.com"}'
curl http://localhost:8787/api/contact/health
```

`scripts/query_db.py` always reads the remote (production) database through the cf CLI.

## Deploy

```sh
uv run pywrangler deploy
```

Dependencies are bundled from `pyproject.toml`. The Worker is reachable only through the
`andexor.net/api/contact*` route (`workers_dev` is false).

## Test

There are no unit or functional tests. Smoke test the deployed service:

```sh
curl -i -X POST https://andexor.net/api/contact -H 'Content-Type: application/json' \
  -d '{"name":"Test JSON","email":"test-json@example.com","phone":"","website":"","help":"test","sourcePath":"/"}'
curl -i -X POST https://andexor.net/api/contact \
  -d 'name=Test+Form&email=test-form%40example.com&phone=&website=&help=test&sourcePath=%2F'
curl -i https://andexor.net/api/contact/health
```

Then print the stored rows:

```sh
uv run scripts/query_db.py
```

## Files

- `pyproject.toml`: uv project, FastAPI and python-multipart dependencies, workers-py dev tools.
- `uv.lock`: locked dependency versions. Keep it in the repo.
- `wrangler.jsonc`: Worker name, entry point, route, `ALLOWED_ORIGINS` var, D1 binding.
- `schema.sql`: `contact_us` table DDL.
- `src/worker.py`: FastAPI app and the Worker entrypoint.
- `scripts/create_db.py`: create the database and table, record `database_id`.
- `scripts/query_db.py`: print all rows as one JSON array.
