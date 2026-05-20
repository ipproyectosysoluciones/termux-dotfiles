#########################################
# SSH AGENT
#########################################

if [[ -d "/termux/.ssh" ]]; then
  export SSH_ENV="/termux/.ssh/agent.env"
else
  export SSH_ENV="$HOME/.ssh/agent.env"
fi

start_ssh_agent() {
    ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"

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

