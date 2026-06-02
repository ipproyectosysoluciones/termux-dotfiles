#!/usr/bin/env bash
# Common test helpers for phase tests

# Set PROJECT_ROOT at load time based on test file location
if [[ -n "${BATS_TEST_FILENAME:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
else
    SCRIPT_DIR="$(pwd)"
fi
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_TMPDIR="${BATS_TEST_TMPDIR:-/tmp/bats-test-$$}"

setup_test_env() {
    mkdir -p "$TEST_TMPDIR"
}

teardown_test_env() {
    if [[ -d "$TEST_TMPDIR" ]]; then
        rm -rf "$TEST_TMPDIR"
    fi
}

########################################
# Path Resolution Helpers
########################################

resolve_script() {
    local script_rel="$1"
    echo "$PROJECT_ROOT/$script_rel"
}

resolve_core() {
    echo "$PROJECT_ROOT/scripts/ai/core/$1.sh"
}

resolve_provider() {
    echo "$PROJECT_ROOT/scripts/ai/providers/$1.sh"
}

########################################
# Fixtures for Temporary Test Projects
########################################

create_fake_project() {
    local dir="$1"
    local type="$2"  # git, node, python, docker, rust

    mkdir -p "$dir/subdir/nested"

    case "$type" in
        git)
            mkdir -p "$dir/.git"
            ;;
        node)
            echo '{"name":"test-project"}' > "$dir/package.json"
            ;;
        python)
            echo "pytest==7.0.0" > "$dir/requirements.txt"
            ;;
        docker)
            echo "version: '3'" > "$dir/docker-compose.yml"
            ;;
        rust)
            echo "[package]" > "$dir/Cargo.toml"
            echo 'name = "test"' >> "$dir/Cargo.toml"
            ;;
    esac
}

########################################
# Mock Functions
########################################

create_mock_engram() {
    local mock_dir="${TEST_TMPDIR}/mock_bin"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/engram" <<'MOCK_SCRIPT'
#!/usr/bin/env bash
case "$1" in
    context)
        echo "[mock-engram] context: $2"
        exit 0
        ;;
    search)
        echo "[mock-engram] search results for: $2"
        echo "- prior work on $2"
        echo "- context from previous sessions"
        exit 0
        ;;
    save)
        echo "[mock-engram] saved: $2"
        exit 0
        ;;
    *)
        echo "[mock-engram] unknown command: $1" >&2
        exit 1
        ;;
esac
MOCK_SCRIPT
    chmod +x "$mock_dir/engram"
}

add_mocks_to_path() {
    local mock_dir="${TEST_TMPDIR}/mock_bin"
    if [[ -d "$mock_dir" ]]; then
        export PATH="$mock_dir:$PATH"
    fi
}

remove_mocks_from_path() {
    local mock_dir="${TEST_TMPDIR}/mock_bin"
    if [[ -d "$mock_dir" ]]; then
        export PATH="${PATH#$mock_dir:}"
    fi
}