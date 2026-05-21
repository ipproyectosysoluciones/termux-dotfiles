#########################################
# VARIABLES
#########################################

export GOPATH=$HOME/go
export PATH="$HOME/bin:$GOPATH/bin:$PATH"
export PATH="$HOME/bin:$PATH"

export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME/bin:$PATH"
export SHELL=/data/data/com.termux/files/usr/bin/zsh

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

export EDITOR=nvim
export VISUAL=nvim

export PROJECTS_DIR="$HOME/Projects"

[[ -d "$PROJECTS_DIR" ]] || mkdir -p "$PROJECTS_DIR"

typeset -U path PATH

