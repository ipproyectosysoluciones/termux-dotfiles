# Neovim Configuration

This document describes the Neovim setup within the termux-dotfiles environment.

## Overview

Neovim is configured as the primary text editor, with a modular configuration structure using lazy.nvim for plugin management. The configuration lives in `nvim/` directory and is symlinked to `~/.config/nvim`.

## Directory Structure

```
nvim/
├── init.lua              # Main configuration entry
├── lua/
│   └── config/           # Configuration modules
│       ├── keymaps.lua   # Keybindings
│       ├── options.lua   # Neovim options
│       └── plugins.lua   # Plugin list
├── plugin/                # Auto-loaded plugins (lazy.nvim)
└── .cache/               # Cache directory (gitignored)
```

## Plugins

### Lazy.nvim (Plugin Manager)

Lazy.nvim is used for plugin management with lazy loading for performance.

Location: `nvim/lua/config/plugins.lua`

### Core Plugins

| Plugin | Purpose |
|--------|---------|
| `folke/lazy.nvim` | Plugin manager |
| `nvim-lualine/lualine.nvim` | Status line |
| `nvim-tree/nvim-tree.lua` | File explorer |
| `hrsh7th/nvim-cmp` | Autocomplete |
| `neovim/nvim-lspconfig` | Language Server Protocol |

### Plugin Installation

Run the plugin installation script:
```bash
bash scripts/nvim/plugins.sh
```

This script installs plugins to `~/.zsh-plugins` directory and links them to Neovim's plugin directory.

## Configuration Files

### init.lua

Main entry point that loads all configuration modules.

### lua/config/options.lua

Sets Neovim options like:
- `number` (line numbers)
- `relativenumber` (relative line numbers)
- `expandtab` (spaces instead of tabs)
- `shiftwidth=2` (indentation width)
- `cursorline` (highlight current line)
- `signcolumn=yes` (always show sign column)

### lua/config/keymaps.lua

Defines keybindings including:
- `jk` or `kj` → `<Esc>` (exit insert mode)
- `H`/`L` → beginning/end of line
- `<Leader>e` → toggle NvimTree
- `gcc` → toggle comment

### lua/config/plugins.lua

Configures lazy.nvim with plugin specifications and lazy-loading settings.

## Installation

### Automated

Run the main install script:
```bash
bash scripts/install.sh
```

This calls `scripts/nvim/plugins.sh` which installs all configured plugins.

### Manual

```bash
# Clone plugins
bash scripts/nvim/plugins.sh

# Open Neovim (plugins auto-install via lazy)
nvim
```

## Keybindings

| Key | Mode | Action |
|-----|------|--------|
| `jk` / `kj` | Insert | Exit to normal mode |
| `H` | Normal | Go to line start |
| `L` | Normal | Go to line end |
| `<Space>e` | Normal | Toggle NvimTree |
| `gcc` | Normal | Toggle line comment |
| `gc` | Visual | Block comment |

## Troubleshooting

### Plugins not loading

Check that plugins.sh ran successfully and `~/.zsh-plugins` exists:
```bash
ls ~/.zsh-plugins
```

### Lazy.nvim errors

Remove lock file and reload:
```bash
rm nvim/lazy-lock.json
nvim +Lazy sync
```

### Slow startup

Check lazy-loading configuration in `lua/config/plugins.lua` and ensure large plugins use proper event triggers.