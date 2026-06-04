#!/usr/bin/env bash
# Sync skills to remote phone-ai device
# Usage: ./sync-skills.sh [remote-host] [ssh-port]

set -euo pipefail

REMOTE_HOST="${1:-phone-ai}"
SSH_PORT="${2:-8022}"
REMOTE_USER="${REMOTE_USER:-root}"
REMOTE_BASE_DIR="~/.config/opencode/skills"
LOCAL_SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/skills/STACK-MEAN-MERN"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    if ! command -v ssh &> /dev/null; then
        log_error "ssh command not found"
        exit 1
    fi

    if ! command -v scp &> /dev/null; then
        log_error "scp command not found"
        exit 1
    fi

    if ! command -v rsync &> /dev/null; then
        log_warn "rsync not found, falling back to scp"
        RSYNC_AVAILABLE=false
    else
        RSYNC_AVAILABLE=true
    fi

    # Test SSH connection
    if ! ssh -p "$SSH_PORT" -o ConnectTimeout=5 -o BatchMode=yes "${REMOTE_USER}@${REMOTE_HOST}" "echo 'connection ok'" &> /dev/null; then
        log_error "Cannot connect to ${REMOTE_USER}@${REMOTE_HOST}:${SSH_PORT}"
        exit 1
    fi

    log_info "Prerequisites check passed"
}

# Sync a single skill directory
sync_skill() {
    local skill_name="$1"
    local local_path="${LOCAL_SKILLS_DIR}/${skill_name}"
    local remote_path="${REMOTE_BASE_DIR}/${skill_name}"

    if [[ ! -d "$local_path" ]]; then
        log_warn "Skill directory not found: $local_path"
        return 1
    fi

    log_info "Syncing skill: $skill_name"

    # Create remote directory
    ssh -p "$SSH_PORT" "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p ${remote_path}"

    # Sync using rsync or scp
    if [[ "$RSYNC_AVAILABLE" == "true" ]]; then
        rsync -az --progress -e "ssh -p ${SSH_PORT}" "$local_path/" "${REMOTE_USER}@${REMOTE_HOST}:${remote_path}/"
    else
        scp -r -P "$SSH_PORT" "$local_path/"* "${REMOTE_USER}@${REMOTE_HOST}:${remote_path}/"
    fi

    log_info "Skill '$skill_name' synced successfully"
    return 0
}

# Verify skills on remote
verify_remote_skills() {
    log_info "Verifying skills on remote..."

    for skill_dir in "${LOCAL_SKILLS_DIR}"/*; do
        local skill_name="$(basename "$skill_dir")"
        local remote_path="${REMOTE_BASE_DIR}/${skill_name}"

        if ssh -p "$SSH_PORT" "${REMOTE_USER}@${REMOTE_HOST}" "test -f ${remote_path}/SKILL.md"; then
            log_info "✓ $skill_name verified on remote"
        else
            log_error "✗ $skill_name missing on remote"
            return 1
        fi
    done

    log_info "All skills verified on remote"
}

# Main execution
main() {
    log_info "Starting skill sync to ${REMOTE_USER}@${REMOTE_HOST}:${SSH_PORT}"
    log_info "Local skills: $LOCAL_SKILLS_DIR"
    log_info "Remote base: $REMOTE_BASE_DIR"
    echo

    check_prerequisites
    echo

    # Sync each skill
    local synced=0
    local failed=0

    for skill_dir in "${LOCAL_SKILLS_DIR}"/*; do
        if [[ -d "$skill_dir" ]]; then
            local skill_name="$(basename "$skill_dir")"
            if sync_skill "$skill_name"; then
                ((synced++))
            else
                ((failed++))
            fi
            echo
        fi
    done

    echo
    log_info "Sync complete: $synced succeeded, $failed failed"
    echo

    if [[ "$failed" -eq 0 ]]; then
        verify_remote_skills
        log_info "All Phase 1 skills deployed successfully!"
        log_info "Run tests on remote with: ssh -p $SSH_PORT ${REMOTE_USER}@${REMOTE_HOST} 'bats ~/dotfiles/tests/skills/'"
    else
        log_error "Some skills failed to sync"
        exit 1
    fi
}

main "$@"