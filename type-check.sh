#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins <ed@andexor.net>

# Strict type check with Pyright, which is what Pylance runs in the editor.
# The rules are in pyrightconfig.json. Run `uv sync` first: Pyright reads the packages in .venv.

set -euo pipefail
cd "$(dirname "$0")"

echo "Type check..."
npx --yes pyright@1.1.414
