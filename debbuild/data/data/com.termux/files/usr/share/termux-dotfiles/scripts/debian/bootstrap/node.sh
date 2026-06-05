#!/bin/bash

set -euo pipefail

echo "[debian] Installing Node.js runtime..."

########################################
# NODEJS
########################################

apt install -y nodejs npm

########################################
# CLEAN PREVIOUS PNPM
########################################

rm -f /usr/local/bin/pnpm
rm -f /usr/local/bin/pnpx

########################################
# PNPM
########################################

npm install -g pnpm@9

########################################
# VERIFY
########################################

echo
echo "[debian] Runtime versions:"
echo

node -v
npm -v
pnpm -v

echo
echo "[debian] Node runtime installed"

