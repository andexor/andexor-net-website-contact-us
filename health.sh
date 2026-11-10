#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins <ed@andexor.net>

NAME=preview

# Health Check For Preview
echo "Health Check For Preview..."
curl -si -X GET https://${NAME}-andexor-net-website-contact-us.andexor.workers.dev/api/contact/health
echo ""
echo ""

# Health Check For Production
echo "Health Check For Production..."
curl -si -X GET https://andexor.net/api/contact/health
echo ""
echo ""
