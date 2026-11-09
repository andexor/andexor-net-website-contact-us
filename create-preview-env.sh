#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins <ed@andexor.net>

# Creates the shared, persistent infrastructure that pull request previews need:
#
#   1. A preview D1 database named "<production database name>-preview".
#   2. The table(s) in schema.sql, applied to that database.
#   3. A "previews" block in wrangler.jsonc that binds previews to that database,
#      so a preview never touches production data, plus "preview_urls": true.
#
# Safe to run again: every step checks what already exists. Undo it with
# delete-preview-env.sh.
#
# Preview URLs are a setting of the production Worker, so the script only checks it and
# reports. Pass --enable-preview-urls to apply it. That runs "wrangler triggers deploy",
# which re-applies the Worker's routes and URL settings and uploads no code.
#
# Usage: ./create-preview-env.sh [--enable-preview-urls]
#
# Requires: cf (logged in), jq, uv (only for --enable-preview-urls).
# wrangler.jsonc must be plain JSON, with no comments.

set -euo pipefail

cd "$(dirname "$0")"

WRANGLER_FILE=wrangler.jsonc
SCHEMA_FILE=schema.sql
ENABLE_PREVIEW_URLS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --enable-preview-urls) ENABLE_PREVIEW_URLS=true; shift ;;
        -h|--help) sed -n '/^# Usage/,/^# wrangler.jsonc/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
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

# Names come from the project config, so this script works unchanged in other projects.
BINDING=$(jq -r '.d1_databases[0].binding' "${WRANGLER_FILE}")
PROD_DB_NAME=$(jq -r '.d1_databases[0].database_name' "${WRANGLER_FILE}")
PREVIEW_DB_NAME="${PROD_DB_NAME}-preview"

if [[ -z "${PROD_DB_NAME}" || "${PROD_DB_NAME}" == "null" ]]; then
    echo "error: no d1_databases entry in ${WRANGLER_FILE}" >&2
    exit 1
fi

# 1. Find or create the preview database.
DB_ID=$(cf d1 list --name "${PREVIEW_DB_NAME}" 2> /dev/null \
    | jq -r --arg n "${PREVIEW_DB_NAME}" '[.[] | select(.name == $n)][0].uuid // empty')

if [[ -z "${DB_ID}" ]]; then
    echo "Creating D1 database ${PREVIEW_DB_NAME}"
    DB_ID=$(cf d1 create --name "${PREVIEW_DB_NAME}" 2> /dev/null | jq -r '.uuid')
else
    echo "D1 database ${PREVIEW_DB_NAME} already exists"
fi

if [[ -z "${DB_ID}" || "${DB_ID}" == "null" ]]; then
    echo "error: could not determine the id of ${PREVIEW_DB_NAME}" >&2
    exit 1
fi

# Never let the preview environment point at production data.
PROD_DB_ID=$(jq -r '.d1_databases[0].database_id' "${WRANGLER_FILE}")
if [[ "${DB_ID}" == "${PROD_DB_ID}" ]]; then
    echo "error: the preview database id matches the production database id" >&2
    exit 1
fi

# 2. Apply the schema. The statements use IF NOT EXISTS, so this is repeatable.
if [[ -f "${SCHEMA_FILE}" ]]; then
    SQL=$(grep -v '^[[:space:]]*--' "${SCHEMA_FILE}" | tr '\n' ' ')
    cf d1 query "${DB_ID}" --sql "${SQL}" > /dev/null 2>&1 || {
        echo "error: applying ${SCHEMA_FILE} to ${PREVIEW_DB_NAME} failed" >&2
        exit 1
    }
    echo "Applied ${SCHEMA_FILE} to ${PREVIEW_DB_NAME}"
fi

# 3. Add the previews block. Preview vars start as a copy of the production vars.
NEW_CONFIG=$(jq --indent 4 --arg binding "${BINDING}" --arg name "${PREVIEW_DB_NAME}" --arg id "${DB_ID}" '
    .preview_urls = true
    | .previews = {
        vars: (.vars // {}),
        d1_databases: [{binding: $binding, database_name: $name, database_id: $id}]
    }' "${WRANGLER_FILE}")

if [[ "${NEW_CONFIG}" == "$(jq --indent 4 . "${WRANGLER_FILE}")" ]]; then
    echo "${WRANGLER_FILE} already has the previews block"
else
    echo "${NEW_CONFIG}" > "${WRANGLER_FILE}"
    echo "Wrote the previews block to ${WRANGLER_FILE}"
fi

# 4. Preview URLs. Without them a preview deploys but has no address to open.
WORKER_NAME=$(jq -r '.name' "${WRANGLER_FILE}")
WORKER_ID=$(cf workers list 2> /dev/null \
    | jq -r --arg n "${WORKER_NAME}" '[.[] | select(.name == $n)][0].id // empty')
URLS_ON=false
if [[ -n "${WORKER_ID}" ]]; then
    [[ "$(cf workers get "${WORKER_ID}" 2> /dev/null | jq -r '.subdomain.previews_enabled')" == "true" ]] && URLS_ON=true
fi

if [[ "${URLS_ON}" != true && "${ENABLE_PREVIEW_URLS}" == true ]]; then
    echo "Enabling preview URLs with: uv run pywrangler triggers deploy"
    uv run pywrangler triggers deploy > /dev/null 2>&1 || {
        echo "error: wrangler triggers deploy failed" >&2
        exit 1
    }
    URLS_ON=true
fi

echo
echo "Preview environment is ready."
echo "  database: ${PREVIEW_DB_NAME} (${DB_ID})"
if [[ "${URLS_ON}" == true ]]; then
    echo "  preview URLs: enabled"
else
    echo "  preview URLs: OFF, so previews deploy but have no address."
    echo "  Turn them on once with: ./create-preview-env.sh --enable-preview-urls"
fi
echo "Commit ${WRANGLER_FILE}. Previews deploy with: uv run pywrangler preview"
echo "Remove everything with: ./delete-preview-env.sh"
