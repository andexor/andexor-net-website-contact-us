#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins<ed@andexor.net>

# variables
CWD=$(basename "$PWD")
IMAGE=andexor/${CWD}
VERSION=1

# debug
docker run -it --rm ${IMAGE}:${VERSION} /bin/bash
