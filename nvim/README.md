# NvChad + lazy.nvim — termux-dotfiles

This directory is the **Neovim user config** for `termux-dotfiles`. It layers on
top of [NvChad v2.5](https://github.com/NvChad/NvChad) and uses
[lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager.

> **How to consume it.** This repo is a *user config*, not a standalone Neovim
> distribution. The main NvChad repo is loaded as a plugin by `init.lua`
> (`require "nvchad.options"`, `require "nvchad.mappings"`, etc.), so you point
> Neovim at this directory via `~/.config/nvim` and the bootstrap script pulls
> in everything else.

## Prerequisites

- **Neovim 0.10+** (tested with 0.12.x). Some lazy.nvim features and the
  `vim.lsp.config` API used by the live LSP spec require 0.10 or newer.
- A C toolchain (`gcc`, `make`, `unzip`) for Mason to build some LSP servers.
- `git` for the lazy.nvim bootstrap and `:Lazy sync`.
- Network access on first boot so `lazy.nvim` can clone the plugin set and
  Mason can pull the LSP/DAP/formatter binaries.

## Quickstart

1. **Symlink the config.** From the repo root:

   ```bash
   ln -sfn "$(pwd)/nvim" "$HOME/.config/nvim"
   ```

2. **Launch Neovim once.** `init.lua` auto-bootstraps `lazy.nvim` (if missing)
   and triggers the first `:Lazy sync`. Watch the UI for plugin installs.

   ```bash
   nvim
   ```

3. **Install language servers with Mason.** Inside Neovim:

   ```vim
   :MasonInstall ts_ls eslint cssls html jsonls lua_ls bashls
   ```

   The list mirrors the `ensure_installed` block in
   `nvim/lua/plugins/lsp/init.lua`. Re-run `:MasonInstall` any time you add
   a server there.

4. **Smoke-test the LSP.** Open a TypeScript file and confirm the server
   attached:

   ```bash
   echo 'const x: number = 1' > /tmp/smoke.ts
   ```

   ```vim
   :e /tmp/smoke.ts
   :LspInfo
   ```

   You should see `ts_ls` listed as the active client.

## Plugin layout

All plugin specs live in `nvim/lua/plugins/*/init.lua` and are auto-imported
by `nvim/lua/plugins/init.lua`. The 11 groups in this change are:

| Group        | Purpose                                  | Spec file                  |
|--------------|------------------------------------------|----------------------------|
| `ai`         | CodeCompanion adapters (Phase 2)         | `plugins/ai/init.lua`      |
| `completion` | nvim-cmp + LuaSnip                       | `plugins/completion/init.lua` |
| `dap`        | Debug Adapter Protocol (Node)            | `plugins/dap/init.lua`     |
| `editor`     | autopairs, treesitter, textobjects       | `plugins/editor/init.lua`  |
| `formatting` | conform.nvim (prettier, stylua, shfmt)   | `plugins/formatting/init.lua` |
| `git`        | gitsigns, octo.nvim                      | `plugins/git/init.lua`     |
| `lsp`        | mason, mason-lspconfig, nvim-lspconfig   | `plugins/lsp/init.lua`     |
| `terminal`   | toggleterm                               | `plugins/terminal/init.lua` |
| `testing`    | neotest (Jest + Playwright)              | `plugins/testing/init.lua` |
| `ui`         | dashboard, bufferline, theme             | `plugins/ui/init.lua`      |

The dead `nvim/lua/configs/*` tree (now moved to
`nvim/lua/configs/_legacy_20260607/` for a 48h soak) is **not** part of the
active config; the spec is the single source of truth. Only `lazy.lua` is
load-bearing there — it sets the lazy.nvim defaults (icons, performance).

## Keymap cheatsheet (live mappings)

| Key                | Mode | Action                                  |
|--------------------|------|-----------------------------------------|
| `;`                | n    | Enter command mode                      |
| `jk`               | i    | Escape insert mode                      |
| `<A-j>` / `<A-k>`  | n/v/i| Move line / selection up/down           |
| `<S-h/j/k/l>`      | n    | Move to adjacent window                 |
| `<leader>ff`       | n    | Telescope find files                    |
| `<leader>fg`       | n    | Telescope live grep                     |
| `<leader>fb`       | n    | Telescope buffers                       |
| `<leader>fh`       | n    | Telescope help tags                     |
| `<leader>fm`       | n    | conform.format (prettier / stylua)      |
| `<leader>fs`       | n    | shfmt (bash)                            |
| `<leader>fq`       | n    | psqlformat (sql)                        |
| `<leader>sv` / `sh`| n    | Split vertically / horizontally         |
| `<leader>sq` / `so`| n    | Close split / close others              |
| `[d` / `]d`        | n    | Previous / next diagnostic              |
| `<leader>e`        | n    | Diagnostic float                        |
| `<leader>q`        | n    | Diagnostic location list                |
| `<leader>y`        | n    | Yank whole file                         |
| `<leader>sr`       | n    | Source `$MYVIMRC`                       |
| `<leader>ch`       | n    | Clear hlsearch                          |
| `<leader>tw`       | n    | Toggle wrap                             |
| `<leader>tn`       | n    | Toggle relative numbers                 |
| `<leader>rn`       | n    | LSP rename                              |
| `<leader>ca`       | n    | LSP code action                         |
| `gd`               | n    | LSP go-to definition                    |
| `K`                | n    | LSP hover                               |

The 11 dead keymaps that previously pointed to uninstalled plugins
(CodeCompanion `<leader>aa/ai/at/am/as` and Copilot `<C-l>/<C-j>/<C-k>/<C-h>`)
have been removed. Pressing them now is a no-op, not an `E492`.

## AI setup (Phase 2 — coming)

Phase 2 of the `Neovim-review-update` change wires in-editor AI through
`olimorris/codecompanion.nvim` plus four tmux-split keymaps that reuse
`scripts/ai/providers/{gemini,claude,opencode,mistral}.sh`. The AI section of
this README will be expanded when PR #2 lands.

For now, the AI CLIs are usable directly from the shell — see
`scripts/ai/README.md` (if present) or run `ai` from a Termux session.

## Troubleshooting

- **`E492: Not an editor command`** on a key — you are pressing a key that was
  removed in Phase 1 (CodeCompanion / Copilot). This is expected; no fix
  needed. See the cheatsheet above for live mappings.
- **`E5108` / `E5113` on boot** — a plugin spec is broken. Run `:Lazy sync`
  and read the error buffer; the failing spec is the one in
  `nvim/lua/plugins/<group>/init.lua`.
- **Mason download failures** — usually DNS or rate limit. Re-run
  `:MasonInstall` after a few minutes, or `nc -z 8.8.8.8 53` to check
  connectivity.
- **LSP not attaching** — confirm the server is installed (`:Mason`) and
  `:LspInfo` lists it for the buffer. Some servers (`ts_ls`, `angularls`)
  require a full Mason reinstall on first use.

See `docs/neovim.md` for the full reference and `docs/nvim-troubleshooting.md`
(deferred to Phase 5) for the symptom→cause→fix index.

## Credits

This config is inspired by the [LazyVim starter](https://github.com/LazyVim/starter)
and built on top of [NvChad v2.5](https://github.com/NvChad/NvChad).
