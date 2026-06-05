#!/data/data/com.termux/files/usr/bin/bash

echo "================================="
echo "Installing Termux packages..."
echo "================================="

source "$(dirname "$0")/../utils/logger.sh"

pkg update -y
pkg upgrade -y

packages=(
  git
  zsh
  tmux
  neovim
  curl
  wget
  openssh
  gh
  fzf
  fd
  ripgrep
  bat
  eza
  lsd
  zoxide
  lazygit
)

for pkg_name in "${packages[@]}"; do
    if pkg list-installed | grep -q "^${pkg_name}/"; then
        echo "[✓] $pkg_name already installed"
    else
        echo "[+] Installing $pkg_name..."
        pkg install -y "$pkg_name"
    fi
done

echo
echo "================================="
echo "Packages installation completed"
echo "================================="

