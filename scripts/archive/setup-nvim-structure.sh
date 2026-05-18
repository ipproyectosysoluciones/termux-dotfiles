#!/data/data/com.termux/files/usr/bin/bash

set -e

NVIM_DIR="$HOME/dotfiles/nvim/lua"
PLUGINS_DIR="$NVIM_DIR/plugins"

echo "========================================="
echo "NVIM MODULAR STRUCTURE SETUP"
echo "========================================="

# =========================================
# MODULES
# =========================================

MODULES=(
  ai
  completion
  formatting
  git
  lsp
  testing
  terminal
  ui
  editor
  dap
)

# =========================================
# CREATE DIRECTORIES
# =========================================

mkdir -p "$NVIM_DIR/configs"
mkdir -p "$NVIM_DIR/utils"
mkdir -p "$PLUGINS_DIR"

for module in "${MODULES[@]}"; do
  mkdir -p "$PLUGINS_DIR/$module"
done

# =========================================
# CREATE MAIN plugins/init.lua
# =========================================

cat > "$PLUGINS_DIR/init.lua" <<'EOF'
return {
  { import = "plugins.ui" },
  { import = "plugins.lsp" },
  { import = "plugins.completion" },
  { import = "plugins.formatting" },
  { import = "plugins.git" },
  { import = "plugins.testing" },
  { import = "plugins.terminal" },
  { import = "plugins.editor" },
  { import = "plugins.dap" },
  { import = "plugins.ai" },
}
EOF

# =========================================
# CREATE MODULE INIT FILES
# =========================================

for module in "${MODULES[@]}"; do

cat > "$PLUGINS_DIR/$module/init.lua" <<'EOF'
return {

}
EOF

done

echo ""
echo "========================================="
echo "NVIM STRUCTURE CREATED"
echo "========================================="
echo ""

tree "$PLUGINS_DIR"

