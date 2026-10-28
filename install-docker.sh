#!/bin/bash

# Adapted from https://docs.docker.com/engine/install/ubuntu/

# Uninstall default system packages.
sudo apt remove $(dpkg --get-selections docker docker-engine docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc > /dev/null 2>&1)

# Add Docker's GPG key.
sudo apt update
sudo apt upgrade -y
sudo apt install -y ca-certificates curl
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod 644 /etc/apt/keyrings/docker.asc

# Add the repository.
TMP_DOCKER_SOURCES=/tmp/docker.sources
DOCKER_SOURCES=/etc/apt/sources.list.d/docker.sources
sudo rm -f ${TMP_DOCKER_SOURCES}
sudo rm -f ${DOCKER_SOURCES}
cat > ${TMP_DOCKER_SOURCES} <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo mv ${TMP_DOCKER_SOURCES} ${DOCKER_SOURCES}
sudo chmod 644 ${DOCKER_SOURCES}
sudo chown root:root ${DOCKER_SOURCES}
sudo apt update

# Install Docker.
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Make sure it is running.
systemctl --quiet is-active docker || sudo systemctl start docker

# Let me use it.
sudo usermod -aG docker ${USER}

# Reboot.
sudo reboot
