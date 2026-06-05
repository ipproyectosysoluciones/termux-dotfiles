#!/data/data/com.termux/files/usr/bin/bash

# Doctor script - Basic environment diagnostics
# Runs health checks on the Debian environment

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "Debian Environment Diagnostics"
echo "========================================"

issues=0

# Check if we're in Debian (proot-distro)
if command -v proot-distro &> /dev/null; then
    echo -e "${GREEN}[✓]${NC} proot-distro is installed"
else
    echo -e "${RED}[✗]${NC} proot-distro not found"
    issues=$((issues + 1))
fi

# Check for required binaries
required_commands=("bash" "zsh" "git" "curl" "nvim")
for cmd in "${required_commands[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}[✓]${NC} $cmd is available"
    else
        echo -e "${YELLOW}[!]${NC} $cmd not found (may be optional)"
    fi
done

# Check dotfiles directory
if [[ -d "$HOME/dotfiles" ]]; then
    echo -e "${GREEN}[✓]${NC} dotfiles directory exists at $HOME/dotfiles"
else
    echo -e "${YELLOW}[!]${NC} dotfiles directory not found at $HOME/dotfiles"
fi

# Check for common config directories
config_dirs=(".config/zsh" ".config/nvim" ".tmux")
for dir in "${config_dirs[@]}"; do
    if [[ -d "$HOME/$dir" ]]; then
        echo -e "${GREEN}[✓]${NC} $dir exists"
    else
        echo -e "${YELLOW}[!]${NC} $dir not found"
    fi
done

echo ""
echo "========================================"
if [[ $issues -eq 0 ]]; then
    echo -e "${GREEN}Diagnostics completed - No critical issues${NC}"
else
    echo -e "${YELLOW}Diagnostics completed - $issues issues found${NC}"
fi
echo "========================================"

exit $issues