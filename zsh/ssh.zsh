#########################################
# SSH AGENT
#########################################

export SSH_ENV="$HOME/.ssh/agent.env"

start_ssh_agent() {
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"

    chmod 600 "$SSH_ENV"

    source "$SSH_ENV" > /dev/null
}

if [[ -f "$SSH_ENV" ]]; then
    source "$SSH_ENV" > /dev/null

    if ! ps -p "$SSH_AGENT_PID" > /dev/null 2>&1; then
        start_ssh_agent
    fi
else
    start_ssh_agent
fi

if ! ssh-add -l >/dev/null 2>&1; then
    ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1
fi
