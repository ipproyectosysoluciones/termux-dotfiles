#!/usr/bin/env bats
# T6.1 / T1.1 — Neovim boot smoke test
#
# Verifies that:
#   1. `nvim --headless` boots the project config without E5108 / E5113
#      (Lua require / call errors).
#   2. None of the 7 dead CodeCompanion keymaps
#      (<leader>aa n+v, <leader>ai n+v, <leader>at, <leader>am, <leader>as)
#      are bound in `nvim/lua/mappings.lua`.
#   3. None of the 4 dead GitHub Copilot keymaps
#      (<C-l>, <C-j>, <C-k>, <C-h> in insert mode)
#      are bound in `nvim/lua/mappings.lua`.
#   4. The script under `scripts/nvim/` is named `zsh-plugins.sh`
#      (T1.4 rename acceptance).
#   5. The dead `nvim/lua/configs/_legacy_*/` soak directory exists
#      (T1.1 acceptance — files moved, not deleted).

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    NVIM_DIR="$PROJECT_ROOT/nvim"
    MAPPINGS_FILE="$NVIM_DIR/lua/mappings.lua"
    SCRIPTS_NVIM_DIR="$PROJECT_ROOT/scripts/nvim"
    LEGACY_DIR_GLOB="$NVIM_DIR/lua/configs/_legacy_*"
}

########################################
# Test 1 — headless boot has no Lua errors
########################################

@test "nvim --headless boots the project config without E5108 / E5113 / E492" {
    # Use a clean XDG_CONFIG_HOME so nvim does not pick up the user's personal
    # config. Force-load mappings (the project's init.lua schedules them via
    # vim.schedule, which does not run before :q in headless mode).
    # Mock the NvChad module that mappings.lua requires, since NvChad is
    # installed by the user, not vendored in this repo.
    run env -i \
        PATH="$PATH" \
        HOME="$BATS_TEST_TMPDIR" \
        XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/.config" \
        XDG_DATA_HOME="$BATS_TEST_TMPDIR/.local/share" \
        XDG_STATE_HOME="$BATS_TEST_TMPDIR/.local/state" \
        XDG_CACHE_HOME="$BATS_TEST_TMPDIR/.cache" \
        timeout 60 nvim --headless \
            --cmd "set rtp+=$NVIM_DIR" \
            --cmd "set nomore" \
            --cmd "lua package.preload['nvchad.mappings'] = function() return {} end" \
            -c "lua require('mappings')" \
            -c "messages" \
            -c "q!" 2>&1

    [ "$status" -eq 0 ]
    [[ ! "$output" =~ E5108 ]]   # Error in lua require
    [[ ! "$output" =~ E5113 ]]   # Error in lua call
    [[ ! "$output" =~ E492 ]]    # Not an editor command
}

########################################
# Test 2 — CodeCompanion keymaps ARE bound (T2.3 acceptance)
#
# PR #1's T1.2 (cleanup) had this test as a NEGATIVE assertion: after
# removing the dead keymaps, NO <leader>a* should map to CodeCompanion.
# After PR #2's T2.3, the same keymaps are INTENTIONALLY bound to live
# :CodeCompanion* commands. The full positive coverage lives in
# tests/nvim/ai_keymaps.bats (T6.3 stub); this test asserts the boot
# path does not regress by showing at least one CodeCompanion binding.
########################################

@test "CodeCompanion keymaps (<leader>aa/ai/at/am/as) are bound (T2.3 acceptance)" {
    run env -i \
        PATH="$PATH" \
        HOME="$BATS_TEST_TMPDIR" \
        XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/.config" \
        XDG_DATA_HOME="$BATS_TEST_TMPDIR/.local/share" \
        XDG_STATE_HOME="$BATS_TEST_TMPDIR/.local/state" \
        XDG_CACHE_HOME="$BATS_TEST_TMPDIR/.cache" \
        timeout 60 nvim --headless \
            --cmd "set rtp+=$NVIM_DIR" \
            --cmd "lua package.preload['nvchad.mappings'] = function() return {} end" \
            -c "lua require('mappings')" \
            -c "nmap <leader>aa" \
            -c "nmap <leader>ai" \
            -c "nmap <leader>at" \
            -c "nmap <leader>am" \
            -c "nmap <leader>as" \
            -c "vmap <leader>aa" \
            -c "vmap <leader>ai" \
            -c "q!" 2>&1

    if [[ ! "$output" =~ CodeCompanion ]]; then
        echo "Expected at least one CodeCompanion keymap after T2.3; got:"
        echo "$output"
        return 1
    fi
}

########################################
# Test 3 — no Copilot keymap is bound
########################################

@test "Copilot keymaps (<C-l>/<C-j>/<C-k>/<C-h> in insert mode) are NOT bound" {
    run env -i \
        PATH="$PATH" \
        HOME="$BATS_TEST_TMPDIR" \
        XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/.config" \
        XDG_DATA_HOME="$BATS_TEST_TMPDIR/.local/share" \
        XDG_STATE_HOME="$BATS_TEST_TMPDIR/.local/state" \
        XDG_CACHE_HOME="$BATS_TEST_TMPDIR/.cache" \
        timeout 60 nvim --headless \
            --cmd "set rtp+=$NVIM_DIR" \
            --cmd "lua package.preload['nvchad.mappings'] = function() return {} end" \
            -c "lua require('mappings')" \
            -c "imap <C-l>" \
            -c "imap <C-j>" \
            -c "imap <C-k>" \
            -c "imap <C-h>" \
            -c "q!" 2>&1

    if [[ "$output" =~ [Cc]opilot ]]; then
        echo "Dead Copilot keymap still bound:"
        echo "$output"
        return 1
    fi
}

########################################
# Test 4 — script renamed to zsh-plugins.sh
########################################

@test "scripts/nvim/zsh-plugins.sh exists and scripts/nvim/plugins.sh does not" {
    [ -f "$SCRIPTS_NVIM_DIR/zsh-plugins.sh" ]
    [ ! -f "$SCRIPTS_NVIM_DIR/plugins.sh" ]
}

########################################
# Test 5 — soak directory exists
########################################

@test "nvim/lua/configs/_legacy_*/ soak directory exists" {
    # Shopt nullglob so the glob returns empty (and the count is 0) if no match.
    shopt -s nullglob
    local matches=($LEGACY_DIR_GLOB)
    shopt -u nullglob

    [ "${#matches[@]}" -ge 1 ] || {
        echo "Expected at least one _legacy_* directory under nvim/lua/configs/"
        return 1
    }
}
