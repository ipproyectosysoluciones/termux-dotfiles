# Neovim Plugins / Plugins de Neovim

## ES

### Cómo leer esta guía

Los plugins están organizados por grupo funcional. Cada entrada incluye: **qué hace**, **por qué está instalado**, y **puntos de configuración clave**. Los plugins marcados como "gated" solo se cargan si se cumple su condición (definida en `nvim/lua/user/init.lua`).

### Convenciones de fuente

| Fuente | Significado |
|---|---|
| Lazy loaded (cmd) | Se carga solo cuando se invoca el comando |
| Lazy loaded (event) | Se carga en un evento específico (VimEnter, BufReadPre, etc.) |
| Gated | Solo se carga si `has_*()` retorna true |
| Always | Siempre presente al inicio |

---

### AI — CodeCompanion.nvim

| Atributo | Valor |
|---|---|
| Repo | `olimorris/codecompanion.nvim` |
| Carga | Lazy, cmd-triggered (`CodeCompanion`, `CodeCompanionChat`, etc.) |
| Gated | Sí (`has_ai_keys()` — alguna de `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`) |
| Keymaps | `<leader>aa`, `<leader>ai`, `<leader>at`, `<leader>am`, `<leader>as` |

**Qué hace**: Chat e inline AI assistance dentro de Neovim. Chat paralelo con adapters para Gemini, Claude, OpenAI, Ollama. Fallback chain: `gemini → claude → openai → ollama`.

**Configuración clave**: Los adapters se configuran en `nvim/lua/plugins/ai/init.lua`. Cada adapter usa su variable de API correspondiente. El adapter activo se puede cambiar con `<leader>as`.

---

### LSP — Mason + LSPConfig + LazyDev

| Plugin | Repo | Carga | Notas |
|---|---|---|---|
| Mason | `williamboman/mason.nvim` | Always | Instala LSP servers, DAP servers, linters, formatters |
| mason-lspconfig | `williamboman/mason-lspconfig.nvim` | Always | Bridge Mason ↔ LSPConfig |
| lspconfig | `neovim/nvim-lspconfig` | Always | Configura servers LSP |
| angularls | `AngularLS` via Mason | Gated (siempre instalado) | TypeScript Angular language server |
| biome | `biomejs/biome` via Mason | Gated (`has_biome()` — `BIOME_ENABLED=1`) |Formatter/linter para JS/TS |
| lazydev.nvim | `folke/lazydev.nvim` | Always (extiende lsp/init.lua) | Completions para runtime Lua (`_G.Lib`) |

**Keymaps LSP**: `[d` / `]d` (diagnósticos), `<leader>de` (float), `<leader>q` (loclist).

**Mason commands**:
```
:Mason               — UI de Mason
:MasonInstall <pkg>   — Instalar un package
:MasonInstallAll      — Instalar todos los ensure_installed
:LspInfo              — Info del server LSP activo
```

---

### Git — Gitsigns + Octo

| Plugin | Repo | Carga | Notas |
|---|---|---|---|
| gitsigns.nvim | `lewis6991/gitsigns.nvim` | Always | Git signs en gutter, blame, preview, diff |
| octo.nvim | `pwntester/octo.nvim` | Lazy, cmd-triggered (`Octo`) | GitHub PR/issue/review (requiere `gh` en PATH) |

**gitsigns keymaps**: `<leader>gb` (blame), `<leader>gp` (preview), `<leader>gd` (diff).

**octo keymaps**: `<leader>op` (PR list), `<leader>oi` (issue list), `<leader>or` (review start). Si `gh` no está en PATH, muestra warn en vez de error (`has_octo()` guard).

---

### Search — Telescope + Harpoon

| Plugin | Repo | Carga | Notas |
|---|---|---|---|
| telescope.nvim | `nvim-telescope/telescope.nvim` | Lazy, cmd-triggered | Find files, live grep, buffers, help |
| plenary.nvim | `nvim-lua/plenary.nvim` | Dependency | Dep de telescope |

**telescope keymaps**: `<leader>ff` (files), `<leader>fg` (grep), `<leader>fb` (buffers), `<leader>fh` (help).

---

### UI — NvimTree + Dashboard + Which-Key + Toggleterm

| Plugin | Repo | Carga | Notas |
|---|---|---|---|
| nvim-tree.lua | `nvim-tree/nvim-tree.lua` | VimEnter | File tree explorer |
| dashboard-nvim | `dashboard-nvim/dashboard-nvim` | VimEnter | Startup screen |
| which-key.nvim | `folke/which-key.nvim` | VeryLazy | Popup hints para keymap groups |
| toggleterm.nvim | `akinsho/toggleterm.nvim` | VeryLazy | Terminal emulador integrado |

**keymaps**:
- `<leader>e` → NvimTreeToggle
- `<leader>tt` → ToggleTerm (toggleterm, split horizontal)

**which-key**: `vim.opt.timeoutlen = 500`. Registra labels para `<leader>a/b/c/d/e/f/g/h/o/s/t/q`.

---

### Editor — Treesitter + Autopairs + Indent

| Plugin | Repo | Carga | Notas |
|---|---|---|---|
| nvim-treesitter | `nvim-treesitter/nvim-treesitter` | Always (en lock) | Parser para syntax highlighting |
| nvim-treesitter-textobjects | `nvim-treesitter/nvim-treesitter-textobjects` | VeryLazy | Select textobjects (af/if/ac/ic/aa/ia/ab/ib) |
| nvim-autopairs | `windwp/nvim-autopairs` | InsertEnter | Auto-close brackets, quotes, etc. |
| indent-blankline.nvim | `lukas-reineke/indent-blankline.nvim` | Always | Indent guides |

**treesitter textobjects** (VSCode-style select):
- `af`/`if` — function around/inside
- `ac`/`ic` — class around/inside
- `aa`/`ia` — parameter around/inside
- `ab`/`ib` — block around/inside

---

### Snippets — Luasnip + VSCode Snippet Packs

| Plugin | Repo | Carga | Notas |
|---|---|---|---|
| LuaSnip | `Luasnip` via lazy | Always | Snippet engine |
| cmp_luasnip | `cmp_luasnip` (cmp source) | Always | CMP source for luasnip |
| friendly-snippets | `friendly-snippets` | Always | Pre-built VSCode snippets |

**Custom snippet packs** (en `nvim/snippets/`):
- `snippets/react/rfc.json` — `rfc` → React Functional Component
- `snippets/angular/component.json` — `ngc` → Angular @Component
- `snippets/express/route.json` — `expr` → Express route
- `snippets/mongoose/schema.json` — `mgs` → Mongoose schema

Cargados via `require("luasnip.loaders.from_vscode").lazy_load({ paths = { "nvim/snippets" } })` en `nvim/lua/plugins/snippets/init.lua`.

---

### Testing — Neotest + Jest + Playwright

| Plugin | Repo | Carga | Notas |
|---|---|---|---|
| neotest | `nvim-neotest/neotest` | Always | Test runner framework |
| neotest-jest | `neotest-jest` | Always | Jest adapter para neotest |
| neotest-playwright | `thenbe/neotest-playwright` | Always | Playwright adapter para neotest |

**Configuración**: `event = "BufReadPre *.test.*"` para no cargar en archivos normales.

---

### Database — Vim-Dadbod

| Plugin | Repo | Carga | Notas |
|---|---|---|---|
| vim-dadbod | `tpope/vim-dadbod` | Always | DB client core |
| vim-dadbod-ui | `kristijanhusak/vim-dadbod-ui` | Lazy, cmd-triggered | UI para vim-dadbod |

**keymap**: `<leader>db` → `:DBUIToggle`. Soporta MongoDB, Postgres, MySQL, SQLite.

---

### Session — Auto-Session

| Plugin | Repo | Carga | Notas |
|---|---|---|---|
| auto-session | `rmagatti/auto-session` | VimEnter | Auto save/restore sessions |

**Configuración**: `DirChange` pre-hook para autosave, `BufWritePost` para guardar cambios, `SessionLoadPost` para restaurar.

---

### Completion — nvim-cmp

| Plugin | Repo | Notas |
|---|---|---|
| nvim-cmp | `hrsh7th/nvim-cmp` | Completion engine |
| cmp-lsp | `hrsh7th/cmp-nvim-lsp` | LSP source for cmp |
| cmp-lua | `hrsh7th/cmp-nvim-lua` | Lua source for cmp |
| cmp-path | `hrsh7th/cmp-path` | Path source for cmp |
| cmp-buffer | `hrsh7th/cmp-buffer` | Buffer source for cmp |
| cmp-cmdline | `hrsh7th/cmp-cmdline` | Cmdline source for cmp |
| cmp-async-path | `as教学内容/cmp-async-path` | Async path source |

---

## EN

### How to read this guide

Plugins are organized by functional group. Each entry includes: **what it does**, **why it's installed**, and **key configuration points**. Plugins marked as "gated" only load if their condition is met (defined in `nvim/lua/user/init.lua`).

### Source conventions

| Source | Meaning |
|---|---|
| Lazy loaded (cmd) | Loads only when the command is invoked |
| Lazy loaded (event) | Loads on a specific event (VimEnter, BufReadPre, etc.) |
| Gated | Only loads if `has_*()` returns true |
| Always | Always present at startup |

---

### AI — CodeCompanion.nvim

| Attribute | Value |
|---|---|
| Repo | `olimorris/codecompanion.nvim` |
| Load | Lazy, cmd-triggered (`CodeCompanion`, `CodeCompanionChat`, etc.) |
| Gated | Yes (`has_ai_keys()` — any of `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`) |
| Keymaps | `<leader>aa`, `<leader>ai`, `<leader>at`, `<leader>am`, `<leader>as` |

**What it does**: Chat and inline AI assistance inside Neovim. Parallel chat with adapters for Gemini, Claude, OpenAI, Ollama. Fallback chain: `gemini → claude → openai → ollama`.

**Key config**: Adapters are configured in `nvim/lua/plugins/ai/init.lua`. Each adapter uses its corresponding API variable. The active adapter can be changed with `<leader>as`.

---

### LSP — Mason + LSPConfig + LazyDev

| Plugin | Repo | Load | Notes |
|---|---|---|---|
| Mason | `williamboman/mason.nvim` | Always | Installs LSP servers, DAP servers, linters, formatters |
| mason-lspconfig | `williamboman/mason-lspconfig.nvim` | Always | Bridge Mason ↔ LSPConfig |
| lspconfig | `neovim/nvim-lspconfig` | Always | Configures LSP servers |
| angularls | `AngularLS` via Mason | Gated (always installed) | TypeScript Angular language server |
| biome | `biomejs/biome` via Mason | Gated (`has_biome()` — `BIOME_ENABLED=1`) | Formatter/linter for JS/TS |
| lazydev.nvim | `folke/lazydev.nvim` | Always (extends lsp/init.lua) | Completions for runtime Lua (`_G.Lib`) |

**LSP keymaps**: `[d` / `]d` (diagnostics), `<leader>de` (float), `<leader>q` (loclist).

**Mason commands**:
```
:Mason               — Mason UI
:MasonInstall <pkg>   — Install a package
:MasonInstallAll      — Install all ensure_installed
:LspInfo              — Info on active LSP server
```

---

### Git — Gitsigns + Octo

| Plugin | Repo | Load | Notes |
|---|---|---|---|
| gitsigns.nvim | `lewis6991/gitsigns.nvim` | Always | Git signs in gutter, blame, preview, diff |
| octo.nvim | `pwntester/octo.nvim` | Lazy, cmd-triggered (`Octo`) | GitHub PR/issue/review (requires `gh` on PATH) |

**gitsigns keymaps**: `<leader>gb` (blame), `<leader>gp` (preview), `<leader>gd` (diff).

**octo keymaps**: `<leader>op` (PR list), `<leader>oi` (issue list), `<leader>or` (review start). If `gh` is not on PATH, shows warn instead of error (`has_octo()` guard).

---

### Search — Telescope + Harpoon

| Plugin | Repo | Load | Notes |
|---|---|---|---|
| telescope.nvim | `nvim-telescope/telescope.nvim` | Lazy, cmd-triggered | Find files, live grep, buffers, help |
| plenary.nvim | `nvim-lua/plenary.nvim` | Dependency | Telescope dependency |

**telescope keymaps**: `<leader>ff` (files), `<leader>fg` (grep), `<leader>fb` (buffers), `<leader>fh` (help).

---

### UI — NvimTree + Dashboard + Which-Key + Toggleterm

| Plugin | Repo | Load | Notes |
|---|---|---|---|
| nvim-tree.lua | `nvim-tree/nvim-tree.lua` | VimEnter | File tree explorer |
| dashboard-nvim | `dashboard-nvim/dashboard-nvim` | VimEnter | Startup screen |
| which-key.nvim | `folke/which-key.nvim` | VeryLazy | Popup hints for keymap groups |
| toggleterm.nvim | `akinsho/toggleterm.nvim` | VeryLazy | Integrated terminal emulator |

**keymaps**:
- `<leader>e` → NvimTreeToggle
- `<leader>tt` → ToggleTerm (toggleterm, horizontal split)

**which-key**: `vim.opt.timeoutlen = 500`. Registers labels for `<leader>a/b/c/d/e/f/g/h/o/s/t/q`.

---

### Editor — Treesitter + Autopairs + Indent

| Plugin | Repo | Load | Notes |
|---|---|---|---|
| nvim-treesitter | `nvim-treesitter/nvim-treesitter` | Always (in lock) | Parser for syntax highlighting |
| nvim-treesitter-textobjects | `nvim-treesitter/nvim-treesitter-textobjects` | VeryLazy | Select textobjects (af/if/ac/ic/aa/ia/ab/ib) |
| nvim-autopairs | `windwp/nvim-autopairs` | InsertEnter | Auto-close brackets, quotes, etc. |
| indent-blankline.nvim | `lukas-reineke/indent-blankline.nvim` | Always | Indent guides |

**treesitter textobjects** (VSCode-style select):
- `af`/`if` — function around/inside
- `ac`/`ic` — class around/inside
- `aa`/`ia` — parameter around/inside
- `ab`/`ib` — block around/inside

---

### Snippets — Luasnip + VSCode Snippet Packs

| Plugin | Repo | Load | Notes |
|---|---|---|---|
| LuaSnip | `Luasnip` via lazy | Always | Snippet engine |
| cmp_luasnip | `cmp_luasnip` (cmp source) | Always | CMP source for luasnip |
| friendly-snippets | `friendly-snippets` | Always | Pre-built VSCode snippets |

**Custom snippet packs** (in `nvim/snippets/`):
- `snippets/react/rfc.json` — `rfc` → React Functional Component
- `snippets/angular/component.json` — `ngc` → Angular @Component
- `snippets/express/route.json` — `expr` → Express route
- `snippets/mongoose/schema.json` — `mgs` → Mongoose schema

Loaded via `require("luasnip.loaders.from_vscode").lazy_load({ paths = { "nvim/snippets" } })` in `nvim/lua/plugins/snippets/init.lua`.

---

### Testing — Neotest + Jest + Playwright

| Plugin | Repo | Load | Notes |
|---|---|---|---|
| neotest | `nvim-neotest/neotest` | Always | Test runner framework |
| neotest-jest | `neotest-jest` | Always | Jest adapter for neotest |
| neotest-playwright | `thenbe/neotest-playwright` | Always | Playwright adapter for neotest |

**Config**: `event = "BufReadPre *.test.*"` to avoid loading on normal files.

---

### Database — Vim-Dadbod

| Plugin | Repo | Load | Notes |
|---|---|---|---|
| vim-dadbod | `tpope/vim-dadbod` | Always | DB client core |
| vim-dadbod-ui | `kristijanhusak/vim-dadbod-ui` | Lazy, cmd-triggered | UI for vim-dadbod |

**keymap**: `<leader>db` → `:DBUIToggle`. Supports MongoDB, Postgres, MySQL, SQLite.

---

### Session — Auto-Session

| Plugin | Repo | Load | Notes |
|---|---|---|---|
| auto-session | `rmagatti/auto-session` | VimEnter | Auto save/restore sessions |

**Config**: `DirChange` pre-hook for autosave, `BufWritePost` for saving changes, `SessionLoadPost` for restore.

---

### Completion — nvim-cmp

| Plugin | Repo | Notes |
|---|---|---|
| nvim-cmp | `hrsh7th/nvim-cmp` | Completion engine |
| cmp-lsp | `hrsh7th/cmp-nvim-lsp` | LSP source for cmp |
| cmp-lua | `hrsh7th/cmp-nvim-lua` | Lua source for cmp |
| cmp-path | `hrsh7th/cmp-path` | Path source for cmp |
| cmp-buffer | `hrsh7th/cmp-buffer` | Buffer source for cmp |
| cmp-cmdline | `hrsh7th/cmp-cmdline` | Cmdline source for cmp |
| cmp-async-path | `as教学内容/cmp-async-path` | Async path source |