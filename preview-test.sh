#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins <ed@andexor.net>

NAME=preview

# Deploy
echo "Deploying preview..."
uv run pywrangler preview --name ${NAME}
echo ""
echo ""

# Health check
echo "Health check..."
curl -si -X GET https://${NAME}-andexor-net-website-contact-us.andexor.workers.dev/api/contact/health
echo ""
echo ""

# Test database connection
echo "Testing database connection..."
# The Worker sets received_at itself from the current UTC time, so it is not sent.
RND=$(printf '%05d' $((RANDOM * 3 % 100000)))
curl -si -X POST https://${NAME}-andexor-net-website-contact-us.andexor.workers.dev/api/contact \
    -H 'Content-Type: application/json' \
    -d '{
"name": "TEST '${RND}'",
"email": "test-'${RND}'@example.com",
"phone": "+1-555-01'${RND:0:2}'",
"website": "https://test-'${RND}'.example.com",
"help": "TEST '${RND}' at '$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
"sourcePath": "/preview-test/'${RND}'"
}'
echo ""
echo ""
