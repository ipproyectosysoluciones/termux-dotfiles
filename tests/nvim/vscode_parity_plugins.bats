#!/usr/bin/env bats
# T4.1 / T4.2 / T4.3 / T4.4 / T4.5 — VSCode Parity plugin group stubs (Phase 4)
#
# Verifies that the Phase 4 (VSCode Parity) plugin surface is wired
# into the consolidated lazy.nvim tree:
#
#   T4.1 — pwntester/octo.nvim  →  plugins/integrations/init.lua (new)
#         Gated by `require("user").has_octo()` (T1.5 chokepoint).
#         Keymaps <leader>op/oi/or live in nvim/lua/mappings.lua.
#
#   T4.2 — lewis6991/gitsigns.nvim  →  plugins/git/init.lua (extended)
#         Adds VSCode-style aliases <leader>gb/gp/gd alongside the
#         pre-existing <leader>hb/hp/hr/hs gitsigns bindings.
#
#   T4.3 — rmagatti/auto-session  →  plugins/session/init.lua (new)
#         Autostart session on DirChange pre; autosave on BufWritePost;
#         restore on SessionLoadPost.
#
#   T4.4 — folke/which-key.nvim  →  plugins/ui/init.lua (extended)
#         `vim.opt.timeoutlen = 500`; registers <leader> group labels.
#
#   T4.5 — folke/lazydev.nvim  →  plugins/lsp/init.lua (extended)
#         Adds :lua LSP for runtime files; sets
#         `Lib = require("lazy.core.util")` completions.
#
# All 5 plugin groups are wired into plugins/init.lua so lazy.nvim
# loads them at boot.

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    NVIM_DIR="$PROJECT_ROOT/nvim"
    PLUGINS_DIR="$NVIM_DIR/lua/plugins"
    PLUGINS_INIT="$PLUGINS_DIR/init.lua"
    INTEGRATIONS_INIT="$PLUGINS_DIR/integrations/init.lua"
    GIT_INIT="$PLUGINS_DIR/git/init.lua"
    SESSION_INIT="$PLUGINS_DIR/session/init.lua"
    UI_INIT="$PLUGINS_DIR/ui/init.lua"
    LSP_INIT="$PLUGINS_DIR/lsp/init.lua"
    MAPPINGS_FILE="$NVIM_DIR/lua/mappings.lua"
}

########################################
# T4.1 — octo.nvim (gated by has_octo)
########################################

@test "T4.1: plugins/integrations/init.lua exists (new group for octo)" {
    [ -f "$INTEGRATIONS_INIT" ]
}

@test "T4.1: integrations/init.lua declares the pwntester/octo.nvim spec" {
    [ -f "$INTEGRATIONS_INIT" ]
    grep -q 'pwntester/octo.nvim' "$INTEGRATIONS_INIT"
}

@test "T4.1: integrations/init.lua gates octo on require('user').has_octo()" {
    [ -f "$INTEGRATIONS_INIT" ]
    # The spec MUST be gated by has_octo() (T1.5 chokepoint).
    # Acceptable patterns: `enabled = function() return require("user").has_octo() end`
    grep -Eq 'has_octo\(\)' "$INTEGRATIONS_INIT"
}

@test "T4.1: integrations/init.lua is wired into plugins/init.lua" {
    [ -f "$PLUGINS_INIT" ]
    grep -Eq 'import[[:space:]]*=[[:space:]]*"plugins\.integrations"' "$PLUGINS_INIT"
}

@test "T4.1: octo keymaps (op/oi/or) are registered in normal mode" {
    [ -f "$MAPPINGS_FILE" ]
    # <leader>op → :Octo pr list
    # <leader>oi → :Octo issue list
    # <leader>or → :Octo review start
    for k in op oi or; do
        grep -qE "map\(\"n\"?, *\"<leader>${k}\"" "$MAPPINGS_FILE" || {
            echo "Octo keymap <leader>${k} is not declared in mappings.lua"
            return 1
        }
    done
}

########################################
# T4.2 — gitsigns.nvim (extended)
########################################

@test "T4.2: plugins/git/init.lua declares the lewis6991/gitsigns.nvim spec" {
    [ -f "$GIT_INIT" ]
    grep -q 'lewis6991/gitsigns.nvim' "$GIT_INIT"
}

@test "T4.2: git/init.lua adds VSCode-style <leader>gb/gp/gd aliases" {
    [ -f "$GIT_INIT" ]
    # T4.2: VSCode-style aliases on top of the existing
    # <leader>hb/hp/hr/hs gitsigns bindings.
    #   <leader>gb → blame line
    #   <leader>gp → preview hunk
    #   <leader>gd → diff this
    for k in gb gp gd; do
        grep -qE "<leader>${k}" "$GIT_INIT" || {
            echo "Gitsigns keymap <leader>${k} is not declared in git/init.lua"
            return 1
        }
    done
}

@test "T4.2: git/init.lua preserves the pre-existing <leader>hb/hp/hr/hs bindings" {
    [ -f "$GIT_INIT" ]
    for k in hb hp hr hs; do
        grep -qE "<leader>${k}" "$GIT_INIT" || {
            echo "Pre-existing gitsigns keymap <leader>${k} is missing from git/init.lua"
            return 1
        }
    done
}

########################################
# T4.3 — auto-session
########################################

@test "T4.3: plugins/session/init.lua exists (new group for auto-session)" {
    [ -f "$SESSION_INIT" ]
}

@test "T4.3: session/init.lua declares the rmagatti/auto-session spec" {
    [ -f "$SESSION_INIT" ]
    grep -q 'rmagatti/auto-session' "$SESSION_INIT"
}

@test "T4.3: session/init.lua wires DirChange pre + BufWritePost autocmds" {
    [ -f "$SESSION_INIT" ]
    # The autocmds for autostart (DirChange pre) and autosave
    # (BufWritePost) MUST be present in the file.
    grep -Eq 'DirChange' "$SESSION_INIT"
    grep -Eq 'BufWritePost' "$SESSION_INIT"
}

@test "T4.3: session/init.lua is wired into plugins/init.lua" {
    [ -f "$PLUGINS_INIT" ]
    grep -Eq 'import[[:space:]]*=[[:space:]]*"plugins\.session"' "$PLUGINS_INIT"
}

########################################
# T4.4 — which-key.nvim (extend existing ui/init.lua)
########################################

@test "T4.4: plugins/ui/init.lua declares the folke/which-key.nvim spec" {
    [ -f "$UI_INIT" ]
    grep -q 'folke/which-key.nvim' "$UI_INIT"
}

@test "T4.4: ui/init.lua sets vim.opt.timeoutlen = 500 (which-key default)" {
    [ -f "$UI_INIT" ]
    # which-key needs a longer timeoutlen so the popup stays open
    # while the user mulls over the next key.
    grep -Eq 'timeoutlen[[:space:]]*=[[:space:]]*500' "$UI_INIT"
}

@test "T4.4: ui/init.lua registers <leader> group labels for which-key" {
    [ -f "$UI_INIT" ]
    # which-key uses add({...}) calls to register group labels; the
    # call MUST include at least one <leader> group definition.
    grep -Eq '<leader>' "$UI_INIT"
}

@test "T4.4: ui/init.lua preserves the pre-existing nvim-tree + dashboard specs" {
    [ -f "$UI_INIT" ]
    # Don't break T3.4 / T3.5 work — both specs MUST still be there.
    grep -q 'nvim-tree/nvim-tree.lua' "$UI_INIT"
    grep -q 'nvimdev/dashboard-nvim' "$UI_INIT"
}

########################################
# T4.5 — lazydev.nvim (extend existing lsp/init.lua)
########################################

@test "T4.5: plugins/lsp/init.lua declares the folke/lazydev.nvim spec" {
    [ -f "$LSP_INIT" ]
    grep -q 'folke/lazydev.nvim' "$LSP_INIT"
}

@test "T4.5: lsp/init.lua sets Lib = require('lazy.core.util') (lazydev completion helper)" {
    [ -f "$LSP_INIT" ]
    grep -Eq "Lib[[:space:]]*=[[:space:]]*require\(\"lazy\.core\.util\"\)" "$LSP_INIT"
}

@test "T4.5: lsp/init.lua preserves the pre-existing mason-lspconfig + lspconfig specs" {
    [ -f "$LSP_INIT" ]
    grep -q 'williamboman/mason-lspconfig.nvim' "$LSP_INIT"
    grep -q 'neovim/nvim-lspconfig' "$LSP_INIT"
}
