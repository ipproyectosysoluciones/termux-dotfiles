#!/data/data/com.termux/files/usr/bin/bash

clear

echo "================================="
echo "        AI WORKSPACE MENU"
echo "================================="
echo
echo "[1] NeoVim"
echo "[2] OpenCode"
echo "[3] Gentle AI"
echo "[4] Engram"
echo "[5] Full Workspace"
echo "[6] Sessions"
echo "[0] Exit"
echo

read -p "Select option: " option

case $option in
    1)
        bash ~/dotfiles/scripts/ai/nvim.sh
        ;;
    2)
        bash ~/dotfiles/scripts/ai/opencode.sh
        ;;
    3)
        bash ~/dotfiles/scripts/ai/gentle.sh
        ;;
    4)
        bash ~/dotfiles/scripts/ai/engram.sh
        ;;
    5)
        bash ~/dotfiles/scripts/ai/workspace.sh
        ;;
    6)
        bash ~/dotfiles/scripts/ai/sessions.sh
        ;;
    0)
        exit 0
        ;;
    *)
        echo "Invalid option"
        ;;
esac
