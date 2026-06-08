# nvim-configuration Specification

## Purpose

Consolidate the NvChad v2.5 + lazy.nvim Neovim configuration into a single source of truth, eliminate dead code, and bring the editor to feature parity with VSCode for portable development on Termux/Linux. Covers Phase 1 (cleanup) and Phase 4 (VSCode-parity additions).

## Requirements

### Requirement: Dead Code Removal

The system MUST remove all files under `nvim/lua/configs/*.lua` and `nvim/lua/configs/servers/*.lua` that are never `require()`d by `nvim/lua/plugins/*`. The active path `nvim/lua/plugins/*/init.lua` SHALL be the single source of truth. Files move to `nvim/lua/configs/_legacy_$(date)/` for a 48h soak before final deletion.

#### Scenario: Clean boot after removal

- GIVEN the 6 `configs/*.lua` and 5 `configs/servers/*.lua` files are removed
- WHEN `nvim --headless +q` runs
- THEN `:messages` MUST NOT contain E5108 / E5113 referencing removed modules
- AND `:lua print(vim.inspect(package.loaded))` MUST NOT contain keys for removed modules

### Requirement: Dead Keymap Removal

The system MUST remove all keymaps in `nvim/lua/mappings.lua` that reference plugins not in `nvim/lazy-lock.json` (6 CodeCompanion, 4 Copilot). All keymaps that remain MUST resolve to a real command on first boot.

#### Scenario: No E492 on any keymap press

- GIVEN dead keymaps are removed
- WHEN `nvim --headless -c "execute 'normal \\<leader>aa'" -c "messages" -c "q"` runs
- THEN `:messages` MUST NOT contain `E492: Not an editor command`
- AND the same passes for the other 9 previously-dead keymaps

#### Scenario: Active keymaps still work

- WHEN `<leader>fm` is pressed on a `.ts` file
- THEN `conform.format` SHALL execute without error
- AND `<leader>ff` SHALL open Telescope file finder

### Requirement: scripts/nvim Rename

The system MUST rename `scripts/nvim/plugins.sh` to `scripts/nvim/zsh-plugins.sh` because the script installs ZSH plugins (powerlevel10k, autosuggestions, etc.), not Neovim plugins (managed by `lazy.nvim`). The renamed script SHALL preserve all behavior.

#### Scenario: Renamed script behaves identically

- WHEN `bash scripts/nvim/zsh-plugins.sh` runs
- THEN output MUST be identical to the pre-rename `plugins.sh`
- AND a repo-wide grep for `scripts/nvim/plugins.sh` MUST return zero references outside git history

### Requirement: nvim/README.md Expansion

The system MUST expand `nvim/README.md` (currently 9 lines) to a minimum 50 lines covering: Neovim 0.10+ prerequisite, `lazy.nvim` bootstrap, `:Lazy sync` workflow, Mason first-run, plugin overview, and a link to `docs/neovim.md`.

#### Scenario: Quickstart is self-sufficient

- WHEN a new user follows the README top-to-bottom
- THEN the user SHALL be able to clone, symlink, launch, run `:Lazy sync`, run `:MasonInstall`, and confirm `:LspInfo` shows `ts_ls` active on `.ts` — using no other document

### Requirement: VSCode-Parity Plugins

The system MUST add these plugins via lazy.nvim specs in `nvim/lua/plugins/{git,editor,completion}/init.lua` and declare each in `lazy-lock.json`: `octo.nvim` (or `gh.nvim`), gitsigns blame line + current line blame, `auto-session`, which-key VSCode-style hints, `lazydev.nvim`, `nvim-treesitter-textobjects`, and `refactoring.nvim`.

#### Scenario: octo opens a PR view

- WHEN `:Octo issue list` runs in a git repo
- THEN no E492 SHALL appear
- AND a list of issues SHALL be fetched via `gh`

#### Scenario: gitsigns blame inline

- WHEN the cursor is on a committed line
- THEN virtual text MUST show the commit hash, author, and date

#### Scenario: auto-session restore

- GIVEN a session was saved on previous exit
- WHEN `nvim .` opens the same directory
- THEN prior buffers, splits, and cwd SHALL be restored

### Requirement: Live Configuration Audit

The system MUST keep live plugin specs in `nvim/lua/plugins/*` consistent with `lazy-lock.json`. No keymap, LSP, formatter, or DAP adapter SHALL be referenced that is not actually installed.

#### Scenario: Clean boot + consistent scripts dir

- WHEN `nvim --headless +q` runs after the change
- THEN exit code MUST be 0
- AND `ls scripts/nvim/` MUST contain `zsh-plugins.sh` (not `plugins.sh`)
