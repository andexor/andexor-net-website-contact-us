-- SPDX-License-Identifier: Apache-2.0
-- Copyright 2026 Andexor Network, Inc.
-- Author: Ed Jenkins <ed@andexor.net>

CREATE TABLE IF NOT EXISTS contact_us (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  email TEXT,
  phone TEXT,
  website TEXT,
  help TEXT,
  source_path TEXT,
  received_at TEXT NOT NULL,
  client_ip TEXT,
  country TEXT,
  user_agent TEXT,
  referer TEXT,
  ray_id TEXT
);
