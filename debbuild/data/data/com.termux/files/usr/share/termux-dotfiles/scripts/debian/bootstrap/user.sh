#!/bin/bash

set -euo pipefail

USERNAME="dev"

echo "[debian] Configuring developer user..."

########################################
# CREATE USER
########################################

if ! id "$USERNAME" >/dev/null 2>&1; then
  useradd -m -s /usr/bin/zsh "$USERNAME"
fi

########################################
# SUDO
########################################

apt install -y sudo

usermod -aG sudo "$USERNAME"

########################################
# PASSWORDLESS SUDO
########################################

echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" \
> "/etc/sudoers.d/$USERNAME"

chmod 440 "/etc/sudoers.d/$USERNAME"

########################################
# CREATE DIRECTORIES
########################################

mkdir -p "/home/$USERNAME/.config"

########################################
# FIX OWNERSHIP
########################################

chown -R "$USERNAME:$USERNAME" \
"/home/$USERNAME"

########################################
# VERIFY
########################################

echo
echo "[debian] User configured:"
echo

id "$USERNAME"

echo
echo "[debian] Developer user ready"

