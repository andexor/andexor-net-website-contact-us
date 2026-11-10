#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins <ed@andexor.net>

# Decommissions the pull request preview environment made by preview-create.sh:
#
#   1. Deletes every Worker Preview of this Worker.
#   2. Deletes the preview D1 database, including all of its data.
#   3. Removes the "previews" block and "preview_urls" from wrangler.jsonc.
#
# It never touches the production Worker, the production database, or the production route.
# Safe to run again: steps whose target is already gone are skipped.
#
# Limitation: Cloudflare has no command that lists every preview. The previews found are the
# ones Workers Builds knows about (the pull request previews built by CI). A preview you
# deployed by hand with "pywrangler preview --name X" is deleted with: --preview X
#
# Usage: ./preview-delete.sh [--yes] [--preview NAME ...]
#
#   --yes           Do not ask for confirmation.
#   --preview NAME  Delete only the named Preview(s) and stop. The database and the
#                   wrangler.jsonc block are kept. NAME is a preview id or branch name.
#
# Requires: cf (logged in), jq. wrangler.jsonc must be plain JSON, with no comments.

set -euo pipefail

cd "$(dirname "$0")"

WRANGLER_FILE=wrangler.jsonc
ASSUME_YES=false
ONLY_PREVIEWS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --yes) ASSUME_YES=true; shift ;;
        --preview) ONLY_PREVIEWS+=("${2:?--preview needs a name}"); shift 2 ;;
        -h|--help) sed -n '/^# Usage/,/^# Requires/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "error: unknown argument $1" >&2; exit 1 ;;
    esac
done

for tool in cf jq; do
    command -v "${tool}" > /dev/null || { echo "error: ${tool} is not installed" >&2; exit 1; }
done

jq -e . "${WRANGLER_FILE}" > /dev/null 2>&1 || {
    echo "error: ${WRANGLER_FILE} is not plain JSON (comments are not supported by this script)" >&2
    exit 1
}

WORKER_NAME=$(jq -r '.name' "${WRANGLER_FILE}")
PROD_DB_NAME=$(jq -r '.d1_databases[0].database_name' "${WRANGLER_FILE}")
PROD_DB_ID=$(jq -r '.d1_databases[0].database_id' "${WRANGLER_FILE}")
PREVIEW_DB_NAME="${PROD_DB_NAME}-preview"

WORKER_ID=$(cf workers list 2> /dev/null \
    | jq -r --arg n "${WORKER_NAME}" '[.[] | select(.name == $n)][0].id // empty')

delete_preview() {
    local ident="$1"
    echo "Deleting preview ${ident}"
    cf previews delete "${ident}" --worker "${WORKER_NAME}" --force > /dev/null 2>&1 \
        || echo "  warning: could not delete preview ${ident} (already gone?)"
}

# Partial mode: only the named previews.
if [[ ${#ONLY_PREVIEWS[@]} -gt 0 ]]; then
    for name in "${ONLY_PREVIEWS[@]}"; do
        delete_preview "${name}"
    done
    exit 0
fi

# Find what exists, so the confirmation can say exactly what will go.
PREVIEW_IDS=()
if [[ -n "${WORKER_ID}" ]]; then
    while IFS= read -r id; do
        [[ -n "${id}" ]] && PREVIEW_IDS+=("${id}")
    done < <(cf workers-builds workers previews list --script-tag "${WORKER_ID}" 2> /dev/null | jq -r '.[].preview_id')
fi

DB_ID=$(cf d1 list --name "${PREVIEW_DB_NAME}" 2> /dev/null \
    | jq -r --arg n "${PREVIEW_DB_NAME}" '[.[] | select(.name == $n)][0].uuid // empty')

# Hard stop: never delete the production database.
if [[ -n "${DB_ID}" && "${DB_ID}" == "${PROD_DB_ID}" ]]; then
    echo "error: refusing to delete ${PREVIEW_DB_NAME}, its id matches the production database" >&2
    exit 1
fi

echo "This will delete:"
echo "  previews of ${WORKER_NAME}: ${#PREVIEW_IDS[@]}"
echo "  D1 database ${PREVIEW_DB_NAME}: ${DB_ID:-not found}, including all its data"
echo "  the previews block in ${WRANGLER_FILE}"
echo "Production is not touched."

if [[ "${ASSUME_YES}" != true ]]; then
    read -r -p "Type yes to continue: " answer
    [[ "${answer}" == "yes" ]] || { echo "Cancelled."; exit 1; }
fi

# 1. Previews first, because they are bound to the database.
for id in "${PREVIEW_IDS[@]}"; do
    delete_preview "${id}"
done

# 2. The preview database.
if [[ -n "${DB_ID}" ]]; then
    echo "Deleting D1 database ${PREVIEW_DB_NAME}"
    cf d1 delete "${DB_ID}" --force > /dev/null 2>&1 \
        || echo "  warning: could not delete ${PREVIEW_DB_NAME}"
fi

# 3. The config block.
if jq -e 'has("previews") or has("preview_urls")' "${WRANGLER_FILE}" > /dev/null; then
    NEW_CONFIG=$(jq --indent 4 'del(.previews, .preview_urls)' "${WRANGLER_FILE}")
    echo "${NEW_CONFIG}" > "${WRANGLER_FILE}"
    echo "Removed the previews block from ${WRANGLER_FILE}"
fi

echo "Preview environment removed."
