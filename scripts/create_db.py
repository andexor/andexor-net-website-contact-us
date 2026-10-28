# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins <ed@andexor.net>
"""Create the D1 database, apply schema.sql, and record database_id in wrangler.jsonc.

Idempotent: safe to run repeatedly. Uses the cf CLI, which must be logged in.
"""

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WRANGLER_FILE = ROOT / "wrangler.jsonc"
SCHEMA_FILE = ROOT / "schema.sql"
DB_NAME = "andexor-net-website-contact-us"


def run_cf(*args):
    """Run a cf command and return its parsed JSON stdout."""
    cmd = ["cf", *args]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        sys.exit(
            f"command failed: {' '.join(cmd)}\n"
            f"stdout:\n{proc.stdout}\nstderr:\n{proc.stderr}"
        )
    try:
        return json.loads(proc.stdout)
    except json.JSONDecodeError:
        sys.exit(f"command did not print JSON: {' '.join(cmd)}\n{proc.stdout}")


def find_database():
    """Return the database record whose name matches DB_NAME, or None."""
    databases = run_cf("d1", "list", "--name", DB_NAME)
    for db in databases:
        if db.get("name") == DB_NAME:
            return db
    return None


def schema_statements():
    """Split schema.sql into single statements, dropping -- comment lines."""
    lines = [
        line
        for line in SCHEMA_FILE.read_text().splitlines()
        if not line.lstrip().startswith("--")
    ]
    parts = "\n".join(lines).split(";")
    return [part.strip() for part in parts if part.strip()]


def write_database_id(database_id):
    """Set the DB binding's database_id in wrangler.jsonc. Returns True if changed."""
    config = json.loads(WRANGLER_FILE.read_text())
    bindings = [b for b in config.get("d1_databases", []) if b.get("binding") == "DB"]
    if not bindings:
        sys.exit("wrangler.jsonc has no d1_databases binding named DB")
    if bindings[0].get("database_id") == database_id:
        return False
    bindings[0]["database_id"] = database_id
    WRANGLER_FILE.write_text(json.dumps(config, indent=2) + "\n")
    return True


def main():
    db = find_database()
    if db is None:
        print(f"database {DB_NAME} not found, creating it")
        db = run_cf("d1", "create", "--name", DB_NAME)
        print(f"created database {DB_NAME}")
    else:
        print(f"database {DB_NAME} already exists")

    database_id = db["uuid"]

    statements = schema_statements()
    for statement in statements:
        run_cf("d1", "query", database_id, "--sql", statement)
    print(f"applied {len(statements)} schema statement(s) from schema.sql")

    if write_database_id(database_id):
        print(f"wrote database_id {database_id} to wrangler.jsonc")
    else:
        print("wrangler.jsonc already has this database_id")


if __name__ == "__main__":
    main()
