# nvim-mean-mern-tooling Specification

## Purpose

Equip Neovim for MEAN (Mongo/Express/Angular/Node) and MERN (Mongo/Express/React/Node) development: per-stack LSPs (`angularls`, `biome`), test runner (`neotest` + jest/playwright), integrated terminal, file explorer (`nvim-tree`), database client (`vim-dadbod` + UI), and per-stack snippet packs via `luasnip.loaders.from_vscode`. Covers Phase 3.

## Requirements

### Requirement: Mason LSP Augmentation

The system MUST add `angularls` and `biome` to `ensure_installed` in `nvim/lua/plugins/lsp/init.lua`. `angularls` is required for MEAN; `biome` is optional, gated by a feature flag. The system MUST set `install_lsp_on_demand = true` to mitigate Termux disk usage.

#### Scenario: angularls attaches to .html templates

- GIVEN a `.ts` file inside an Angular project
- WHEN `:MasonInstall angularls` triggers
- THEN `angularls` SHALL register with `nvim-lspconfig`
- AND `:LspInfo` on a `.component.html` file SHALL show `angularls` active
- AND if the biome feature flag is `false` (default), `biome` SHALL NOT auto-install and no `biome` LSP SHALL attach

### Requirement: Neotest Integration

The system MUST add `nvim-neotest/neotest` plus `neotest-jest` and `thenbe/neotest-playwright` to `nvim/lua/plugins/testing/init.lua` (currently empty). The system MUST register keymaps for nearest test, file's tests, full suite.

#### Scenario: Jest tests discovered + nearest runs

- GIVEN a MERN project with `__tests__/*.test.ts`
- WHEN `:Neotest summary` runs
- THEN neotest MUST list at least one discovered test
- AND the test file MUST be highlighted
- AND when the cursor is inside a Jest test case and `<leader>tn` is pressed, neotest SHALL execute the nearest test and the result SHALL appear in the summary panel

### Requirement: Integrated Terminal

The system MUST add `toggleterm.nvim` (preferred for NvChad v2.5) OR `snacks.terminal` to `nvim/lua/plugins/terminal/init.lua` and MUST register `<leader>tt` to toggle it.

#### Scenario: Terminal toggles + loads lazily

- WHEN `<leader>tt` is pressed
- THEN a terminal split MUST open at the bottom
- AND pressing it again MUST close it
- AND the terminal SHALL have full shell access (`$SHELL`)
- AND `nvim --startuptime /tmp/startup.log +q` with the terminal closed MUST NOT include the terminal plugin in the log

### Requirement: File Explorer (nvim-tree)

The system MUST add `nvim-tree/nvim-tree.lua` (in `lazy-lock.json` but not loaded) to `nvim/lua/plugins/ui/init.lua` and MUST register `<leader>e` to toggle it. The collision with the existing diagnostic-float binding SHALL be resolved in Phase 4.

#### Scenario: nvim-tree toggles + respects .gitignore

- WHEN `<leader>e` is pressed
- THEN the file tree panel SHALL open on the left
- AND pressing it again SHALL close it
- AND the project root MUST be expanded automatically
- AND `node_modules/` and `.git/` entries MUST NOT appear

### Requirement: Database Client (vim-dadbod)

The system MUST add `tpope/vim-dadbod` and `kristijanhusak/vim-dadbod-ui` to `nvim/lua/plugins/`. The system MUST register a keymap to open the database UI.

#### Scenario: vim-dadbod connects to MongoDB and SQL

- GIVEN a buffer contains `mongodb://localhost:27017/mydb`
- WHEN `:DBUIToggle` runs
- THEN the UI MUST list available databases and a query buffer MUST be available
- AND given `postgresql://user:pass@localhost/db`, `:DB postgresql://...` SHALL register the connection and `:DBUI` SHALL list schemas and tables

### Requirement: Per-Stack Snippet Packs

The system MUST add per-stack snippet packs (React, Angular, Express, Mongoose) via `require("luasnip.loaders.from_vscode")` from `nvim/snippets/`. Packs SHOULD be VSCode-format `.json` files (one per stack). The existing `friendly-snippets` pack remains the base.

#### Scenario: React + Mongoose snippets expand

- GIVEN the React pack is loaded
- WHEN `rfc<Tab>` is typed in a `.tsx` file
- THEN the snippet MUST expand to a React Functional Component skeleton
- AND SHALL include `import React from "react"`
- AND when `ms<Tab>` is typed in a `.js` file, a `mongoose.Schema` skeleton MUST be inserted with a sample field, timestamps, and `module.exports`

### Requirement: DAP Node Adapter Path

The system MUST add `node-debug2-adapter` to Mason's `ensure_installed` in `nvim/lua/plugins/dap/init.lua` and MUST resolve the path at runtime via `require("mason-registry").get_package("node-debug2-adapter"):get_install_path()` (not a hardcoded path).

#### Scenario: DAP path resolves at runtime

- GIVEN `node-debug2-adapter` is installed
- WHEN the runtime path lookup runs
- THEN the path SHALL be non-empty and exist on disk
- AND SHALL be used by `dap.adapters.node2`
