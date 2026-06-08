# Neovim Keymaps / Mapeos de Teclas de Neovim

## ES

### Cómo usar esta guía

Todos los keymaps están definidos en `nvim/lua/mappings.lua`. Esta guía los organiza por función. Los keymaps de AI tienen dos grupos: **in-editor** (CodeCompanion.nvim) y **terminal-spawn CLI** (tmux splits con scripts de `scripts/ai/providers/`).

### Convenciones

| Prefijo | Significado |
|---|---|
| `<leader>a*` | AI in-editor (CodeCompanion) |
| `<leader>g*` | AI CLI splits (tmux, scripts de providers) |
| `<leader>d*` | Diagnósticos LSP |
| `<leader>e` | File tree (NvimTreeToggle) |
| `<leader>o*` | GitHub (octo.nvim, requiere `gh` en PATH) |

---

### Navegación General

| Keymap | Modo | Acción | Notas |
|---|---|---|---|
| `jk` | Insert | Salir a modo normal | Alternative a `<Esc>` |
| `kj` | Insert | Salir a modo normal | Alternative a `<Esc>` |
| `H` | Normal | Ir al inicio de la línea | |
| `L` | Normal | Ir al fin de la línea | |
| `<S-h>` | Normal | Ir al split izquierdo | |
| `<S-l>` | Normal | Ir al split derecho | |
| `<S-j>` | Normal | Ir al split inferior | |
| `<S-k>` | Normal | Ir al split superior | |
| `<S-l>` | Normal | Siguiente buffer | (redefine H/L cuando no hay split) |
| `<S-h>` | Normal | Buffer anterior | |

### AI — In-Editor (CodeCompanion.nvim)

Gatillado por cmd, lazy-loaded. Solo funciona si alguna variable de API está seteada (`has_ai_keys()`).

| Keymap | Modo | Acción |
|---|---|---|
| `<leader>aa` | Normal+Visual | Abrir CodeCompanion Chat |
| `<leader>ai` | Normal+Visual | CodeCompanion inline (bufline) |
| `<leader>at` | Normal | Toggle chat window |
| `<leader>am` | Normal | Abrir Actions panel |
| `<leader>as` | Normal | Switch adapter (gemini→claude→openai→ollama) |

### AI — CLI Splits (tmux splits)

Abre un split horizontal y ejecuta el script del provider via `vim.fn.termopen`. Cada script vive en `scripts/ai/providers/`. Las variables de entorno (`AI_WORKSPACE`, `AI_PROJECT`, `AI_AGENT`, `AI_SKILL`) se pasan automáticamente.

| Keymap | Provider | Script |
|---|---|---|
| `<leader>ag` | Gemini | `scripts/ai/providers/gemini.sh` |
| `<leader>ac` | Claude | `scripts/ai/providers/claude.sh` |
| `<leader>ao` | OpenCode | `scripts/ai/providers/opencode.sh` |
| `<leader>gm` | Mistral | `scripts/ai/providers/mistral.sh` |
| `<leader>gg` | Gentle | `scripts/ai/providers/gentle.sh` |

### Git/GitHub

**gitsigns.nvim** (siempre activo):

| Keymap | Acción |
|---|---|
| `<leader>gb` | Blame de la línea actual |
| `<leader>gp` | Preview hunk |
| `<leader>gd` | Diff del hunk actual |

**octo.nvim** (requiere `gh` en PATH; si no está, muestra un notify):

| Keymap | Acción |
|---|---|
| `<leader>op` | Listar PRs |
| `<leader>oi` | Listar Issues |
| `<leader>or` | Iniciar review |

### LSP y Diagnósticos

| Keymap | Acción |
|---|---|
| `[d` | Diagnóstico anterior |
| `]d` | Diagnóstico siguiente |
| `<leader>de` | Mostrar diagnóstico en floating window |
| `<leader>q` | Abrir loclist de diagnósticos |

### Búsqueda (Telescope)

| Keymap | Acción |
|---|---|
| `<leader>ff` | Buscar archivos |
| `<leader>fg` | Buscar texto (live grep) |
| `<leader>fb` | Buscar buffers abiertos |
| `<leader>fh` | Buscar help tags |

### Terminal

| Keymap | Acción |
|---|---|
| `<leader>tt` | Toggle terminal (toggleterm, split horizontal con $SHELL) |

### Base de Datos (vim-dadbod)

| Keymap | Acción |
|---|---|
| `<leader>db` | Abrir DBUIToggle (MongoDB, Postgres, MySQL, SQLite) |

### UI y Ventanas

| Keymap | Acción |
|---|---|
| `<leader>e` | Toggle NvimTree (file tree) |
| `<leader>sv` | Crear split vertical |
| `<leader>sh` | Crear split horizontal |
| `<leader>sq` | Cerrar split actual |
| `<leader>so` | Cerrar otros splits |
| `<leader>tw` | Toggle wrap |
| `<leader>tn` | Toggle números relativos |
| `<leader>ch` | Limpiar highlight de búsqueda |
| `<leader>sr` | Recargar $MYVIMRC |

### Formateo

| Keymap | Acción |
|---|---|---|
| `<leader>fm` | Formatear con conform.nvim (Prettier) |
| `<leader>fs` | Formatear script Bash con shfmt |
| `<leader>fq` | Formatear SQL con psqlformat |

### Portapapeles y Utilidades

| Keymap | Acción |
|---|---|---|
| `<leader>y` | Copiar todo el archivo al portapapeles |
| `;` | Entrar en modo comando (desde modo normal) |

### Treesitter Textobjects (VSCode-style select)

| Keymap | Modo | Textobject |
|---|---|---|
| `af` | Normal+Visual | Function (around) |
| `if` | Normal+Visual | Function (inside) |
| `ac` | Normal+Visual | Class (around) |
| `ic` | Normal+Visual | Class (inside) |
| `aa` | Normal+Visual | Parameter (around) |
| `ia` | Normal+Visual | Parameter (inside) |
| `ab` | Normal+Visual | Block (around) |
| `ib` | Normal+Visual | Block (inside) |

---

## EN

### How to use this guide

All keymaps are defined in `nvim/lua/mappings.lua`. This guide organizes them by function. AI keymaps have two groups: **in-editor** (CodeCompanion.nvim) and **terminal-spawn CLI** (tmux splits with scripts from `scripts/ai/providers/`).

### Conventions

| Prefix | Meaning |
|---|---|
| `<leader>a*` | AI in-editor (CodeCompanion) |
| `<leader>g*` | AI CLI splits (tmux, provider scripts) |
| `<leader>d*` | LSP diagnostics |
| `<leader>e` | File tree (NvimTreeToggle) |
| `<leader>o*` | GitHub (octo.nvim, requires `gh` on PATH) |

---

### General Navigation

| Keymap | Mode | Action | Notes |
|---|---|---|---|
| `jk` | Insert | Exit to normal mode | Alternative to `<Esc>` |
| `kj` | Insert | Exit to normal mode | Alternative to `<Esc>` |
| `H` | Normal | Go to line start | |
| `L` | Normal | Go to line end | |
| `<S-h>` | Normal | Go to left split | |
| `<S-l>` | Normal | Go to right split | |
| `<S-j>` | Normal | Go to bottom split | |
| `<S-k>` | Normal | Go to top split | |
| `<S-l>` | Normal | Next buffer | (redefines H/L when no split) |
| `<S-h>` | Normal | Previous buffer | |

### AI — In-Editor (CodeCompanion.nvim)

Cmd-triggered, lazy-loaded. Only works if any API variable is set (`has_ai_keys()`).

| Keymap | Mode | Action |
|---|---|---|
| `<leader>aa` | Normal+Visual | Open CodeCompanion Chat |
| `<leader>ai` | Normal+Visual | CodeCompanion inline (bufline) |
| `<leader>at` | Normal | Toggle chat window |
| `<leader>am` | Normal | Open Actions panel |
| `<leader>as` | Normal | Switch adapter (gemini→claude→openai→ollama) |

### AI — CLI Splits (tmux splits)

Opens a horizontal split and runs the provider script via `vim.fn.termopen`. Each script lives in `scripts/ai/providers/`. Environment variables (`AI_WORKSPACE`, `AI_PROJECT`, `AI_AGENT`, `AI_SKILL`) are passed automatically.

| Keymap | Provider | Script |
|---|---|---|
| `<leader>ag` | Gemini | `scripts/ai/providers/gemini.sh` |
| `<leader>ac` | Claude | `scripts/ai/providers/claude.sh` |
| `<leader>ao` | OpenCode | `scripts/ai/providers/opencode.sh` |
| `<leader>gm` | Mistral | `scripts/ai/providers/mistral.sh` |
| `<leader>gg` | Gentle | `scripts/ai/providers/gentle.sh` |

### Git/GitHub

**gitsigns.nvim** (always active):

| Keymap | Action |
|---|---|
| `<leader>gb` | Blame current line |
| `<leader>gp` | Preview hunk |
| `<leader>gd` | Diff current hunk |

**octo.nvim** (requires `gh` on PATH; if not available, shows a notify):

| Keymap | Action |
|---|---|
| `<leader>op` | List PRs |
| `<leader>oi` | List Issues |
| `<leader>or` | Start review |

### LSP and Diagnostics

| Keymap | Action |
|---|---|
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>de` | Show diagnostic in floating window |
| `<leader>q` | Open diagnostics loclist |

### Search (Telescope)

| Keymap | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Find text (live grep) |
| `<leader>fb` | Find open buffers |
| `<leader>fh` | Find help tags |

### Terminal

| Keymap | Action |
|---|---|
| `<leader>tt` | Toggle terminal (toggleterm, horizontal split with $SHELL) |

### Database (vim-dadbod)

| Keymap | Action |
|---|---|
| `<leader>db` | Open DBUIToggle (MongoDB, Postgres, MySQL, SQLite) |

### UI and Windows

| Keymap | Action |
|---|---|
| `<leader>e` | Toggle NvimTree (file tree) |
| `<leader>sv` | Create vertical split |
| `<leader>sh` | Create horizontal split |
| `<leader>sq` | Close current split |
| `<leader>so` | Close other splits |
| `<leader>tw` | Toggle wrap |
| `<leader>tn` | Toggle relative numbers |
| `<leader>ch` | Clear search highlight |
| `<leader>sr` | Reload $MYVIMRC |

### Formatting

| Keymap | Action |
|---|---|---|
| `<leader>fm` | Format with conform.nvim (Prettier) |
| `<leader>fs` | Format Bash script with shfmt |
| `<leader>fq` | Format SQL with psqlformat |

### Clipboard and Utilities

| Keymap | Action |
|---|---|---|
| `<leader>y` | Yank entire file to clipboard |
| `;` | Enter command mode (from normal mode) |

### Treesitter Textobjects (VSCode-style select)

| Keymap | Mode | Textobject |
|---|---|---|
| `af` | Normal+Visual | Function (around) |
| `if` | Normal+Visual | Function (inside) |
| `ac` | Normal+Visual | Class (around) |
| `ic` | Normal+Visual | Class (inside) |
| `aa` | Normal+Visual | Parameter (around) |
| `ia` | Normal+Visual | Parameter (inside) |
| `ab` | Normal+Visual | Block (around) |
| `ib` | Normal+Visual | Block (inside) |