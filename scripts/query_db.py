# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins <ed@andexor.net>
"""Print every row of the contact_us table as one JSON array on stdout.

Reads database_id from wrangler.jsonc and runs the query through the cf CLI.
"""

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WRANGLER_FILE = ROOT / "wrangler.jsonc"
SQL = "SELECT * FROM contact_us ORDER BY id"


def database_id():
    config = json.loads(WRANGLER_FILE.read_text())
    bindings = [b for b in config.get("d1_databases", []) if b.get("binding") == "DB"]
    if not bindings or not bindings[0].get("database_id"):
        sys.exit("wrangler.jsonc has no database_id for the DB binding; run create_db.py first")
    return bindings[0]["database_id"]


def rows_from_output(stdout):
    """cf d1 query prints a list with one entry per statement, each with a results list."""
    payload = json.loads(stdout)
    if isinstance(payload, dict):
        payload = [payload]
    rows = []
    for statement in payload:
        rows.extend(statement.get("results", []))
    return rows


def main():
    cmd = ["cf", "d1", "query", database_id(), "--sql", SQL]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        sys.exit(f"command failed: {' '.join(cmd)}\nstdout:\n{proc.stdout}\nstderr:\n{proc.stderr}")
    print(json.dumps(rows_from_output(proc.stdout), indent=2))


if __name__ == "__main__":
    main()
