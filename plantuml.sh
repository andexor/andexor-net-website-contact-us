#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 Andexor Network, Inc.
# Author: Ed Jenkins<ed@andexor.net>

PLANTUML_VERSION=1.2026.8

rm -r -f dist/uml
mkdir -p dist/uml/images
cp -p doc/uml/*.puml dist/uml/
java -jar .tools/plantuml-mit-${PLANTUML_VERSION}.jar -tsvg -o images dist/uml/*.puml
