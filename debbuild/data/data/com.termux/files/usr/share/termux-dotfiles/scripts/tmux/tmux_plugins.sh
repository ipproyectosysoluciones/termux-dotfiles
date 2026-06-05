#!/data/data/com.termux/files/usr/bin/bash

source "$(dirname "$0")/../utils/logger.sh"

echo "================================="
echo "Installing TPM..."
echo "================================="

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [[ -d "$TPM_DIR" ]]; then
    echo "[✓] TPM already installed"
else
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"

    echo "[+] TPM installed"
fi

echo
echo "================================="
echo "TPM installation completed"
echo "================================="

