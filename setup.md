<!--
SPDX-License-Identifier: Apache-2.0
Copyright 2026 Andexor Network, Inc.
Author: Ed Jenkins<ed@andexor.net>
-->

# Install Pre-requisites

Most projects have certain pre-requisites that are required for development, testing, or running in production. Install the ones that are needed.

## Python

Follow these instructions to setup a development environment for projects that are written in Python. The latest Python interpreter should already be installed on your system.

For projects written in Python, you need to use the uv package manager to install the third-party modules they depend on. uv is not available in a standard OS package format. It needs to be installed via this script.

> Run `install-uv.sh`

Do not use npm, npx, pip, pnpm, or other legacy tools like them. They have fundamental vulnerabilities that have been addressed by uv.

In order to protect against using malicious code, a 1 week delay is suggested between when a package is published and when it is used. Most security issues are resolved within this time frame.

Add this to the `pyproject.toml` file in your project:

> [tool.uv]<br/>
> exclude-newer = "1 week"

Install the Python packages that this project uses.

> Run `setup.sh`<br/>
> Run `uv sync`

## PlantUML

Some of the documentation is built with PlantUML.
This is only needed for development,
not for production.

This requires the following steps to be taken
in a development environment.

**Step 1**: Install SDKMan.

> `curl -s "https://get.sdkman.io" | bash`

Close the terminal window and open a new one.

> `exit`

**Step 2**: Install Java.

First, find the latest Temurin release,
not including beta releases.

> `sdk list java`

Once you find a good candidate, install it.
This example is the latest version available at the time of this writing.
You might find a newer release.

> `sdk install java 26.0.2+1.1-tem`

**Step 3**: Install graphviz.

> `sudo apt install -y graphviz graphviz-doc graphviz-tools`

**Step 4**: Install the PlantUML CLI.

See [PlantUML Downloads and Source Code](https://plantuml.com/en-dark/download)
to find the latest version.

NOTE: Select the one with the MIT license. Do not use GPL or GPL v2.

Add .tools to .gitignore like this:

> `# .tools`<br/>
> `.tools/`

> Run `install-plantuml.sh`

Run `plantuml.sh` whenever you want
to generate or update UML diagrams
from the `.puml` source files.

The source files are in doc/uml.

The generated images are in dist/uml.

**Step 4**: Install the PlantUML plugin for VS Code.

> Ctrl+Shift+P<br/>
> ext install well-ar.plantuml

Close the window.

Re-open the project.

Now you will be able to preview
rendered UML diagrams in the IDE.

**Step 5**: Configure the PlantUML plugin for VS Code.

By default, VS Code will use its own copy of PlantUML for rendering images in a preview tab. But this version is old and not 100% compatible with the JAR file we downloaded earlier. We need to use the JAR file we downloaded in order to render images at build time. Unless you use the downloaded JAR for both development previews and builds, you may encounter syntax errors in one place or the other. Make the following configuration changes to make VS Code use the JAR file you downloaded for builds.

1. Go to Settings and search for "@ext:well-ar.plantuml".
1. Set "Plantuml: Jar" to ".tools/plantuml-mit-1.2026.8.jar". If a newer version is available and you updated install-plantuml.sh to get it, use the newer filename.
1. Change "Plantuml: Render" from "LocalServer" to "Local".

Now the images should be rendered identically in the IDE and the build process. And there should be no errors using one method that don't also happen with the other method.

## TypeScript

For projects written in TypeScript, you need to use Bun for package management, builds, and execution. It needs to be installed from this script.

> Run `install-bun.sh`

## Docker

For projects that are built in Docker or run in Docker, you need to have Docker properly installed.

> Run `install-docker.sh`

This script requires a reboot, so the system will be rebooted automatically.
After rebooting, run this to verify that it is working:

> Run `docker run hello-world`

## RabbitMQ

If you want to run RabbitMQ for local testing,

> Run `install-rabbitmq-server.sh`

## Spec Kit

Spec Kit is used to manage feature requirements and development.

If you have not installed uv yet, install it first.

> Run `install-uv.sh`

> Run `install-spec-kit.sh`
