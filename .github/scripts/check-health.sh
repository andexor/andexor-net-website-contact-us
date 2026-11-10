#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins <ed@andexor.net>

# Waits for a health URL to answer 200 with {"ok": true}.
# Every attempt prints its status. A bad attempt also prints the response headers that say who
# answered (server, cf-mitigated, cf-ray) and the start of the body, so a failure explains itself.
#
# Usage: check-health.sh URL [ATTEMPTS] [DELAY_SECONDS]

set -uo pipefail

URL="${1:?usage: check-health.sh URL [ATTEMPTS] [DELAY_SECONDS]}"
ATTEMPTS="${2:-10}"
DELAY="${3:-3}"

BODY_FILE=$(mktemp)
HEADER_FILE=$(mktemp)
trap 'rm -f "${BODY_FILE}" "${HEADER_FILE}"' EXIT

for ((i = 1; i <= ATTEMPTS; i++)); do
    STATUS=$(curl --silent --show-error --output "${BODY_FILE}" --dump-header "${HEADER_FILE}" \
        --write-out '%{http_code}' "${URL}") || STATUS="000"

    if [[ "${STATUS}" == "200" ]] && jq -e '.ok == true' "${BODY_FILE}" > /dev/null 2>&1; then
        echo "attempt ${i}/${ATTEMPTS}: HTTP ${STATUS} $(cat "${BODY_FILE}")"
        exit 0
    fi

    echo "attempt ${i}/${ATTEMPTS}: HTTP ${STATUS}"
    grep -iE '^(server|cf-mitigated|cf-ray|content-type):' "${HEADER_FILE}" | sed 's/^/    /'
    head -c 300 "${BODY_FILE}" | sed 's/^/    body: /'
    echo

    if ((i < ATTEMPTS)); then
        sleep "${DELAY}"
    fi
done

echo "::error::${URL} did not become healthy after ${ATTEMPTS} attempts"
exit 1
