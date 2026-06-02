#!/usr/bin/env bats
# tests/phase4/tmux_var_expansion.bats
# Verify tmux commands in ai.sh expand shell variables at build time
# instead of deferring to the child shell.
#
# Root cause: \$BASE_DIR, \$PROVIDER, and \$HYDRATED_PROMPT were escaped
# with backslash inside tmux command strings, so the child shell (bash -lc)
# received the literal \$VAR reference — but these variables were never
# exported, resulting in empty expansion → /runtime/runtime.env not found.

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "ai.sh tmux commands expand BASE_DIR at build time" {
    # Escaped \$BASE_DIR causes empty expansion in the tmux child shell.
    # All tmux commands must use inline $BASE_DIR so the parent shell
    # resolves the full path before handing the string to tmux.
    run grep -Fc '\$BASE_DIR' "$PROJECT_ROOT/scripts/ai/ai.sh"
    [ "$status" -eq 1 ]
}

@test "ai.sh tmux commands expand PROVIDER at build time" {
    # PROVIDER is needed as the first argument to ai-runtime.sh.
    # It must be expanded by the parent shell, not deferred.
    run grep -Fc '\$PROVIDER' "$PROJECT_ROOT/scripts/ai/ai.sh"
    [ "$status" -eq 1 ]
}

@test "ai.sh tmux commands expand HYDRATED_PROMPT at build time" {
    # HYDRATED_PROMPT is passed as the prompt argument to ai-runtime.sh.
    # It must be expanded by the parent shell, not deferred.
    run grep -Fc '\$HYDRATED_PROMPT' "$PROJECT_ROOT/scripts/ai/ai.sh"
    [ "$status" -eq 1 ]
}
