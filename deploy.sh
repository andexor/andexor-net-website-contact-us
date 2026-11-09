#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins <ed@andexor.net>

# Deploy
uv run pywrangler deploy

# Warm up the database connection
uv run scripts/query_db.py
