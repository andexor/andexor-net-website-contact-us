# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins <ed@andexor.net>

from datetime import datetime, timezone

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, Response
from workers import WorkerEntrypoint

FORM_KEYS = ("name", "email", "phone", "website", "help", "sourcePath")
DEFAULT_ORIGINS = "https://andexor.net"

app = FastAPI()


def _env(request):
    return request.scope["env"]


def _text(value):
    if isinstance(value, str):
        return value
    if isinstance(value, (bool, int, float)):
        return str(value)
    return None


def _allowed_origins(request):
    """Comma-separated ALLOWED_ORIGINS var, as a list with the first entry as default."""
    raw = getattr(_env(request), "ALLOWED_ORIGINS", None) or DEFAULT_ORIGINS
    return [origin.strip() for origin in raw.split(",") if origin.strip()]


@app.middleware("http")
async def cors(request: Request, call_next):
    response = await call_next(request)
    allowed = _allowed_origins(request)
    origin = request.headers.get("origin")
    response.headers["Access-Control-Allow-Origin"] = origin if origin in allowed else allowed[0]
    response.headers["Access-Control-Allow-Methods"] = "POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    response.headers["Vary"] = "Origin"
    return response


@app.options("/api/contact")
async def contact_preflight():
    return Response(status_code=204)


@app.get("/api/contact/health")
async def health():
    return {"ok": True}


@app.post("/api/contact")
async def create_contact(request: Request):
    content_type = request.headers.get("content-type", "")
    if content_type.startswith("application/json"):
        body = await request.json()
        if not isinstance(body, dict):
            body = {}
    else:
        form = await request.form()
        body = dict(form)

    fields = {key: _text(body.get(key)) for key in FORM_KEYS}
    headers = request.headers

    row = {
        "name": fields["name"],
        "email": fields["email"],
        "phone": fields["phone"],
        "website": fields["website"],
        "help": fields["help"],
        "source_path": fields["sourcePath"],
        "received_at": datetime.now(timezone.utc).isoformat(),
        "client_ip": headers.get("cf-connecting-ip"),
        "country": headers.get("cf-ipcountry"),
        "user_agent": headers.get("user-agent"),
        "referer": headers.get("referer"),
        "ray_id": headers.get("cf-ray"),
    }
    columns = ", ".join(row)
    placeholders = ", ".join("?" for _ in row)
    sql = f"INSERT INTO contact_us ({columns}) VALUES ({placeholders})"

    try:
        result = await _env(request).DB.prepare(sql).bind(*row.values()).run()
        row_id = int(result.meta.last_row_id)
    except Exception as exc:
        print(f"contact insert failed: {exc}")
        return JSONResponse({"ok": False}, status_code=500)

    return {"ok": True, "id": row_id}


class Default(WorkerEntrypoint):
    async def fetch(self, request):
        import asgi

        return await asgi.fetch(app, request.js_object, self.env)
