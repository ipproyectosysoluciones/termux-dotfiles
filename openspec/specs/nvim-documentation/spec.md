# nvim-documentation Specification

## Purpose

Ship bilingual (ES + EN) documentation covering the consolidated Neovim setup, AI integration, MEAN/MERN workflows, keymap cheatsheet, and troubleshooting. Rewrite `docs/neovim.md` to match the post-Phase 1-4 filesystem layout. Covers Phase 5.

## Requirements

### Requirement: Bilingual Section Convention

The system MUST adopt a bilingual (ES + EN) convention: every user-facing doc file MUST contain both a `## ES` and a `## EN` section. The convention MUST be defined in `docs/i18n.md`. Technical reference material MAY be single-language if content is identical.

#### Scenario: docs/i18n.md defines the convention

- GIVEN `docs/i18n.md` is created
- WHEN the file is read
- THEN it MUST contain `## ES` and `## EN` sections
- AND both SHALL explain the heading syntax and the ES-first order

### Requirement: docs/neovim.md Rewrite

The system MUST rewrite `docs/neovim.md` to reflect the post-Phase 1 layout: `nvim/lua/plugins/*/init.lua` (NOT `lua/config/plugins.lua`), `nvim/lua/mappings.lua` (NOT `lua/config/keymaps.lua`), the full 33-plugin list, the Mason workflow, and the dead `lua/configs/` removal.

#### Scenario: paths + keymap table match reality

- GIVEN the rewrite is applied
- WHEN every path in `docs/neovim.md` is checked against the actual layout
- THEN zero broken references SHALL remain
- AND `lua/configs/` MUST NOT be mentioned as a config path
- AND every active `<leader>*` mapping MUST appear in the keymap table with no removed-dead-keymap entries

### Requirement: nvim/README.md Quickstart

The system MUST expand `nvim/README.md` (currently 9 lines) to include: prerequisites, quickstart, Mason first-run, links to `docs/neovim.md` and `docs/nvim-ai.md`. The file MUST follow the bilingual convention.

#### Scenario: new user can bootstrap from README only

- WHEN a new user follows the README top-to-bottom on fresh Termux
- THEN the user SHALL be able to clone, symlink, launch, run `:Lazy sync`, run `:MasonInstall`, and confirm `:LspInfo` shows `ts_ls` active on `.ts` — using no other document

### Requirement: docs/nvim-ai.md — CodeCompanion Setup

The system MUST add `docs/nvim-ai.md` covering: CodeCompanion install status, the four (optional five) adapters, env vars, the six in-editor keymaps (`<leader>aa/ai/at/am/as`), the four terminal-split keymaps (`<leader>ag/ac/ao/am`), the fallback chain, MCP hooks, and a disable feature flag.

#### Scenario: env-var table

- WHEN the adapter section is read
- THEN the table MUST list Gemini (`GEMINI_API_KEY`), Claude (`ANTHROPIC_API_KEY`), OpenAI (`OPENAI_API_KEY`, `OPENAI_BASE_URL`), Ollama (none)
- AND Copilot, if mentioned, MUST be marked optional

#### Scenario: advanced user can configure from nvim-ai.md

- WHEN an advanced user reads the file end-to-end
- THEN the user SHALL be able to set `GEMINI_API_KEY`, add a Claude adapter, configure a custom OpenAI base URL, and confirm the fallback order — using no other file

### Requirement: docs/nvim-mean-mern.md — Per-Stack Setup

The system MUST add `docs/nvim-mean-mern.md` covering, per stack (MEAN, MERN), the required LSPs, snippet packs, DAP adapter, and formatter. It MUST document `install_lsp_on_demand` for Termux and MUST link out to `skills/STACK-MEAN-MERN/*` (not duplicate).

#### Scenario: per-stack sections + Termux warning

- WHEN a MEAN dev searches "Angular"
- THEN the file MUST name `angularls`, the Angular snippet pack, and `node2` DAP
- AND a similar block MUST exist for MERN (React + `ts_ls` + neotest-jest)
- AND the Termux section MUST warn that `angularls` adds ~500MB and `ts_ls` ~200MB, recommending `install_lsp_on_demand = true`

### Requirement: docs/nvim-troubleshooting.md

The system MUST add `docs/nvim-troubleshooting.md` covering: Termux `/tmp` shim, Mason download failures, DAP node adapter path, clipboard fallback (Termux:API detection), Telescope 0.1.x → 0.2+ migration notes, and the `E492` symptom from unloaded-plugin keymaps. The file MUST be organized as symptom → cause → fix.

#### Scenario: E492 + telescope entries present

- WHEN a reader searches "E492"
- THEN an entry MUST explain the cause and direct the reader to Phase 2 setup
- AND the Telescope section MUST state the current pin is 0.1.x and the upgrade is deferred, listing the breaking changes
- AND entries for Termux `/tmp`, Mason, and clipboard MUST also be present

### Requirement: docs/nvim-keymaps.md Cheatsheet

The system MUST add `docs/nvim-keymaps.md` as a single-page cheatsheet grouped by prefix (`<leader>a*` AI, `<leader>f*` files, `<leader>t*` tools, `<leader>s*` splits) covering every keymap in `nvim/lua/mappings.lua` after Phase 1+2. The cheatsheet MAY be single-language but MUST be linked from `docs/neovim.md` and `nvim/README.md`.

#### Scenario: every live keymap appears

- WHEN a script greps `:nmap` output against the cheatsheet
- THEN every active mapping SHALL appear with its key, command, and description
- AND no removed-dead-keymap entry SHALL appear

### Requirement: Documentation Acceptance

A new user MUST be able to install, first-launch `nvim`, run `:Lazy sync`, run `:MasonInstall`, open a `.ts` file, and confirm `:LspInfo` shows an active client using only `docs/neovim.md` + `nvim/README.md`. An advanced user MUST configure AI adapters using only `docs/nvim-ai.md`. A MEAN/MERN dev MUST find per-stack setup in `docs/nvim-mean-mern.md`.

#### Scenario: clean-room bootstrap path

- GIVEN all six doc files exist and follow the convention
- WHEN a clean-room user follows README → docs/neovim.md → `:Lazy sync` → `:MasonInstall`
- THEN a working LSP MUST attach to a `.ts` file within one cycle of each
- AND no step SHALL require a doc outside the set {`nvim/README.md`, `docs/neovim.md`, `docs/nvim-ai.md`, `docs/nvim-mean-mern.md`, `docs/nvim-troubleshooting.md`, `docs/nvim-keymaps.md`, `docs/i18n.md`}
