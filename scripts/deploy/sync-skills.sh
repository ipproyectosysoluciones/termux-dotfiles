#!/usr/bin/env bash
# Sync skills to remote phone-ai device (or local copy)
# Usage: ./sync-skills.sh [remote-host] [ssh-port]
#        ./sync-skills.sh --local           # copy locally on the remote itself
#        ./sync-skills.sh --local --agents  # also add agent entries to opencode config

set -euo pipefail
shopt -s nullglob  # avoid literal glob on empty dirs

REMOTE_HOST="phone-ai"
SSH_PORT="8022"
REMOTE_USER="${REMOTE_USER:-root}"
REMOTE_BASE_DIR="~/.config/opencode/skills"
LOCAL_SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/skills/STACK-MEAN-MERN"
OPENCODE_CONFIG="${OPENCODE_CONFIG:-$HOME/.config/opencode/opencode.jsonc}"
LOCAL_MODE=false
DEPLOY_AGENTS=false

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

# Parse flags
parse_flags() {
    for arg in "$@"; do
        case "$arg" in
            --local)
                LOCAL_MODE=true
                ;;
            --agents)
                DEPLOY_AGENTS=true
                ;;
            --help|-h)
                echo "Usage: ./sync-skills.sh [remote-host] [ssh-port]"
                echo "       ./sync-skills.sh --local [--agents]"
                echo ""
                echo "Modes:"
                echo "  (no flags)   Sync skills to remote via SSH (default)"
                echo "  --local      Copy skills directly on local machine"
                echo "  --agents     Also deploy agent entries to opencode config"
                echo ""
                echo "Examples:"
                echo "  ./sync-skills.sh                         # remote to phone-ai:8022"
                echo "  ./sync-skills.sh --local                  # local copy"
                echo "  ./sync-skills.sh --local --agents         # local copy + agents"
                echo "  ./sync-skills.sh my-host 2222             # custom remote"
                exit 0
                ;;
        esac
    done
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

# Sync a single skill directory (remote mode)
sync_skill_remote() {
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

# Sync a single skill directory (local mode — copy directly)
sync_skill_local() {
    local skill_name="$1"
    local local_path="${LOCAL_SKILLS_DIR}/${skill_name}"
    local dest_dir="$HOME/.config/opencode/skills/${skill_name}"

    if [[ ! -d "$local_path" ]]; then
        log_warn "Skill directory not found: $local_path"
        return 1
    fi

    log_info "Copying skill: $skill_name"

    mkdir -p "$dest_dir"
    cp -r "$local_path/"* "$dest_dir/"

    log_info "Skill '$skill_name' copied to $dest_dir"
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

# Verify skills locally
verify_local_skills() {
    log_info "Verifying skills locally..."

    for skill_dir in "${LOCAL_SKILLS_DIR}"/*; do
        local skill_name="$(basename "$skill_dir")"
        local dest_path="$HOME/.config/opencode/skills/${skill_name}/SKILL.md"

        if [[ -f "$dest_path" ]]; then
            log_info "✓ $skill_name verified"
        else
            log_error "✗ $skill_name missing at $dest_path"
            return 1
        fi
    done

    log_info "All skills verified"
}

# Deploy agent entries to opencode config
deploy_agents() {
    local agents_dir="${LOCAL_SKILLS_DIR}/agents"
    local merged

    if [[ ! -d "$agents_dir" ]]; then
        log_warn "No agents directory found at $agents_dir"
        return 0
    fi

    log_info "Deploying agent entries to $OPENCODE_CONFIG..."

    if ! command -v python3 &> /dev/null; then
        log_warn "python3 not found, skipping agent deployment"
        log_info "Manually add agent entries from: $agents_dir"
        return 0
    fi

    merged=$(python3 -c "
import json, glob, os

agents_dir = '$agents_dir'
config_path = '$OPENCODE_CONFIG'
merged = {}

# Read existing config
if os.path.exists(config_path):
    with open(config_path) as f:
        try:
            cfg = json.load(f)
        except:
            cfg = {}
    existing_agents = cfg.get('agent', {})
    if existing_agents:
        merged.update(existing_agents)

# Load agent JSONs
for f in glob.glob(os.path.join(agents_dir, '*.json')):
    with open(f) as af:
        data = json.load(af)
        merged.update(data)

print(json.dumps(merged, indent=2))
")

    # Write back to config
    python3 -c "
import json, os

config_path = '$OPENCODE_CONFIG'
agent_data = json.loads('''$merged''')

if os.path.exists(config_path):
    with open(config_path) as f:
        cfg = json.load(f)
else:
    cfg = {}

cfg['agent'] = agent_data

with open(config_path, 'w') as f:
    json.dump(cfg, f, indent=2)

print(f'Deployed {len(agent_data)} agent(s) to {config_path}')
"
}

# Main execution
main() {
    parse_flags "$@"

    if [[ "$LOCAL_MODE" == "true" ]]; then
        log_info "Running in LOCAL mode (copying directly)"
        echo
        log_info "Local skills: $LOCAL_SKILLS_DIR"
        log_info "Destination: $HOME/.config/opencode/skills"
        echo

        # Sync each skill locally
        local synced=0
        local failed=0

        for skill_dir in "${LOCAL_SKILLS_DIR}"/*/; do
            if [ -d "$skill_dir" ] && [ "$(basename "$skill_dir")" != "agents" ]; then
                local skill_name="$(basename "$skill_dir")"
                if sync_skill_local "$skill_name"; then
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
            verify_local_skills
            log_info "All skills deployed successfully!"
            echo

            if [[ "$DEPLOY_AGENTS" == "true" ]]; then
                deploy_agents
            else
                log_info "Agents not deployed. Run with --agents to add them to opencode config."
                log_info "Agent JSONs available at: ${LOCAL_SKILLS_DIR}/agents/"
            fi
        else
            log_error "Some skills failed to sync"
            exit 1
        fi
    else
        # Remote mode (original behavior)
        # Shift parsed flags so positional args work
        local positional=()
        for arg in "$@"; do
            case "$arg" in
                --local|--agents) ;;
                *) positional+=("$arg") ;;
            esac
        done

        REMOTE_HOST="${positional[0]:-phone-ai}"
        SSH_PORT="${positional[1]:-8022}"

        log_info "Starting skill sync to ${REMOTE_USER}@${REMOTE_HOST}:${SSH_PORT}"
        log_info "Local skills: $LOCAL_SKILLS_DIR"
        log_info "Remote base: $REMOTE_BASE_DIR"
        echo

        check_prerequisites
        echo

        # Sync each skill
        local synced=0
        local failed=0

        for skill_dir in "${LOCAL_SKILLS_DIR}"/*/; do
            if [ -d "$skill_dir" ] && [ "$(basename "$skill_dir")" != "agents" ]; then
                local skill_name="$(basename "$skill_dir")"
                if sync_skill_remote "$skill_name"; then
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
            log_info "All skills deployed successfully!"
            log_info "Run tests on remote with: ssh -p $SSH_PORT ${REMOTE_USER}@${REMOTE_HOST} 'bats ~/dotfiles/tests/skills/'"

            if [[ "$DEPLOY_AGENTS" == "true" ]]; then
                log_info "To deploy agents, run this on the remote:"
                log_info "  ssh -p $SSH_PORT ${REMOTE_USER}@${REMOTE_HOST}"
                log_info "  cd ~/dotfiles && ./scripts/deploy/sync-skills.sh --local --agents"
            fi
        else
            log_error "Some skills failed to sync"
            exit 1
        fi
    fi
}

main "$@"
