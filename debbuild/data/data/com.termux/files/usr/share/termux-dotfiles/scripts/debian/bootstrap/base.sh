#!/bin/bash

set -euo pipefail

echo "[debian] Updating repositories..."

apt update && apt upgrade -y

echo "[debian] Installing base packages..."

apt install -y \
  bash \
  zsh \
  git \
  curl \
  wget \
  sudo \
  nano \
  vim \
  tmux \
  unzip \
  zip \
  ca-certificates \
  build-essential \
  ripgrep \
  fd-find \
  fzf \
  bat \
  btop \
  tree

echo "[debian] Base packages installed"

