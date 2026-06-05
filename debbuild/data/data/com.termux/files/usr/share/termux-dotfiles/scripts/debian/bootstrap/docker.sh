#!/bin/bash

set -euo pipefail

echo "[debian] Installing Docker..."

########################################
# DEPENDENCIES
########################################

apt update

apt install -y \
  curl \
  ca-certificates \
  gnupg

########################################
# DOCKER
########################################

# Add Docker GPG key and repository for aarch64
install -m 0755 -d /etc/apt/keyrings

curl -fsSL "https://download.docker.com/linux/debian/gpg" \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt update

apt install -y docker.io

########################################
# VERIFY
########################################

echo
echo "[debian] Docker version:"
echo

docker --version

echo
echo "[debian] Docker installed"