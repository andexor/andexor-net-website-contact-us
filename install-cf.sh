#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins <ed@andexor.net>

# Installs or upgrades the Cloudflare CLI (cf) with Bun, then repairs its launchers.
#
# The package's bin script starts with "#!/usr/bin/env node", and a Bun global
# install links ~/.bun/bin/cf and ~/.bun/bin/cloudflare straight to that script.
# With no Node on the machine they fail with "env: 'node': No such file or
# directory". Bun runs the script fine, so this replaces the two links with
# wrappers that exec bun. Every install or upgrade of the package recreates the
# links, so run this script again instead of "bun install -g cf" by itself.
# ("bun upgrade" only replaces Bun itself and does not undo the wrappers.)

set -euo pipefail

bun install -g cf@latest

bin_dir="$(bun pm bin -g)"
global_dir="${BUN_INSTALL_GLOBAL_DIR:-$HOME/.bun/install/global}"
script="$global_dir/node_modules/cf/bin/cf"

if [ ! -f "$script" ]; then
    echo "install-cf.sh: cf bin script not found at $script" >&2
    exit 1
fi

for name in cf cloudflare; do
    launcher="$bin_dir/$name"
    rm -f "$launcher"
    printf '#!/bin/sh\nexec "%s" "%s" "$@"\n' "$(command -v bun)" "$script" > "$launcher"
    chmod +x "$launcher"
done

echo "cf $(cf --version) installed; launchers in $bin_dir run it with bun"
