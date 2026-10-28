#!/bin/bash

# Adapted from https://plantuml.com/en-dark/download

# NOTE: If you have not done so already, install Java first.
# See setup.md for details.

# NOTE: You should periodically check the website mentioned above for updates.
# Once per year should be often enough.
# If a newer version is available,
# you may want to update the PLANTUML_VERSION variable
# and run this script to download it.
# Then be sure to update plantuml.sh and VS Code to match.

mkdir -p .tools
PLANTUML_VERSION=1.2026.8

curl -L -o ./.tools/plantuml-mit-${PLANTUML_VERSION}.jar "https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-mit-${PLANTUML_VERSION}.jar"
