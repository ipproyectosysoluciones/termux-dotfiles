# Neovim Configuration / Configuración de Neovim

## ES

### Visión General

Esta configuración de Neovim usa **NvChad v2.5** como base, con **lazy.nvim** como gestor de plugins. El objetivo es tener un editor powerful pero rápido, con AI integrado (CodeCompanion.nvim) y tooling MEAN/MERN.

**Prerrequisitos:**
- Termux + proot-debian (Debian 12)
- Neovim ≥0.10
- `gh` CLI (para octo.nvim, opcional)
- Variables de entorno para AI: `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`, y/o `OPENAI_API_KEY`

### Estructura de Directorios

```
nvim/
├── init.lua                      # Bootstrap: carga NvChad + plugins + mappings
├── lazy-lock.json                # Pin de commits de plugins (regenerar con :Lazy sync)
├── lua/
│   ├── config.lazy.lua          # Configuración de lazy.nvim
│   ├── user/init.lua             # Feature flags: has_ai_keys, has_biome, has_octo
│   ├── mappings.lua              # Todos los keymaps (origen de verdad para docs)
│   ├── options.lua               # Opciones de Neovim (NvChad base)
│   └── plugins/
│       ├── init.lua              # Importa todos los grupos de plugins
│       ├── ai/init.lua           # CodeCompanion.nvim (lazy, cmd-triggered)
│       ├── completion/init.lua   # nvim-cmp + luasnip
│       ├── db/init.lua           # vim-dadbod + vim-dadbod-ui
│       ├── editor/init.lua       # telescope + treesitter-textobjects
│       ├── git/init.lua          # gitsigns.nvim (blame, preview, diff)
│       ├── integrations/init.lua # octo.nvim (GitHub PR/issue, lazy, gated by has_octo)
│       ├── lsp/init.lua          # Mason + lspconfig + angularls + lazydev
│       ├── session/init.lua      # auto-session (restore on VimEnter)
│       ├── terminal/init.lua     # toggleterm.nvim
│       ├── testing/init.lua      # neotest + jest + playwright
│       └── ui/init.lua           # nvim-tree + dashboard + which-key
└── snippets/                     # Snippet packs (VSCode format)
    ├── package.json              # Discoverability surface para luasnip
    ├── react/
    ├── angular/
    ├── express/
    └── mongoose/
```

### Instalación Rápida

```bash
# 1. Instalar plugins
nvim --headless +'Lazy! sync' +q

# 2. Instalar LSP servers (requiere red)
nvim --headless +'MasonInstallAll' +q

# 3. Verificar que todo funciona
nvim
# :Lazy sync  (si hay drift en el lockfile)
# :Octo pr list  (si gh está en PATH)
```

### Feature Flags (user/init.lua)

El archivo `nvim/lua/user/init.lua` actúa como chokepoint para plugins opcionales:

| Función | Condición | Plugin |
|---|---|---|
| `has_ai_keys()` | `GEMINI_API_KEY` o `ANTHROPIC_API_KEY` o `OPENAI_API_KEY` | CodeCompanion.nvim |
| `has_biome()` | `BIOME_ENABLED=1` | biome formatter (opt-in) |
| `has_octo()` | `gh` está en PATH | octo.nvim |

Si una variable no está seteada, el plugin correspondiente no se carga — no hay errores, solo un fallback.

### Testing

```bash
# Tests de la config (bats)
bats --recursive tests/nvim/

# Tests completos (incluye install, brew, etc.)
bats --recursive tests/
```

Hay 5 tests pre-existentes fallando (#14, #17, #132, #369, #372) que no son parte de este cambio.

---

## EN

### Overview

This Neovim config uses **NvChad v2.5** as the base with **lazy.nvim** for plugin management. The goal is a powerful but fast editor with integrated AI (CodeCompanion.nvim) and MEAN/MERN tooling.

**Prerequisites:**
- Termux + proot-debian (Debian 12)
- Neovim ≥0.10
- `gh` CLI (for octo.nvim, optional)
- AI environment variables: `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`, and/or `OPENAI_API_KEY`

### Directory Structure

```
nvim/
├── init.lua                      # Bootstrap: loads NvChad + plugins + mappings
├── lazy-lock.json                # Plugin commit pins (regen with :Lazy sync)
├── lua/
│   ├── config.lazy.lua           # lazy.nvim configuration
│   ├── user/init.lua             # Feature flags: has_ai_keys, has_biome, has_octo
│   ├── mappings.lua              # All keymaps (source of truth for docs)
│   ├── options.lua               # Neovim options (NvChad base)
│   └── plugins/
│       ├── init.lua              # Imports all plugin groups
│       ├── ai/init.lua           # CodeCompanion.nvim (lazy, cmd-triggered)
│       ├── completion/init.lua   # nvim-cmp + luasnip
│       ├── db/init.lua           # vim-dadbod + vim-dadbod-ui
│       ├── editor/init.lua       # telescope + treesitter-textobjects
│       ├── git/init.lua          # gitsigns.nvim (blame, preview, diff)
│       ├── integrations/init.lua # octo.nvim (GitHub PR/issue, lazy, gated by has_octo)
│       ├── lsp/init.lua          # Mason + lspconfig + angularls + lazydev
│       ├── session/init.lua      # auto-session (restore on VimEnter)
│       ├── terminal/init.lua     # toggleterm.nvim
│       ├── testing/init.lua      # neotest + jest + playwright
│       └── ui/init.lua           # nvim-tree + dashboard + which-key
└── snippets/                     # Snippet packs (VSCode format)
    ├── package.json              # Discoverability surface for luasnip
    ├── react/
    ├── angular/
    ├── express/
    └── mongoose/
```

### Quick Install

```bash
# 1. Install plugins
nvim --headless +'Lazy! sync' +q

# 2. Install LSP servers (requires network)
nvim --headless +'MasonInstallAll' +q

# 3. Verify everything works
nvim
# :Lazy sync  (if lockfile has drift)
# :Octo pr list  (if gh is on PATH)
```

### Feature Flags (user/init.lua)

The file `nvim/lua/user/init.lua` acts as a chokepoint for optional plugins:

| Function | Condition | Plugin |
|---|---|---|
| `has_ai_keys()` | `GEMINI_API_KEY` or `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` | CodeCompanion.nvim |
| `has_biome()` | `BIOME_ENABLED=1` | biome formatter (opt-in) |
| `has_octo()` | `gh` is on PATH | octo.nvim |

If a variable is not set, the corresponding plugin does not load — no errors, just a fallback.

### Testing

```bash
# Config tests (bats)
bats --recursive tests/nvim/

# Full test suite (includes install, brew, etc.)
bats --recursive tests/
```

There are 5 pre-existing failing tests (#14, #17, #132, #369, #372) that are not part of this change.