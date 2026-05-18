#########################################
# ALIASES
#########################################

alias ll='eza -lah --icons'

#### Git ####
alias gs='git status'
alias ga='git add .'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gcm='git commit -m'
alias gck='git checkout'
alias gb='git branch'

alias ls='lsd'

alias update='pkg update && pkg upgrade -y'

alias df='df -h'

alias cat='bat --theme=Dracula --style=plain --paging=never'

alias debian='proot-distro login debian'

alias deb='proot-distro login debian --bind /data/data/com.termux/files/home:/termux --user dev'

alias sshgithub='ssh-add -t 24h ~/.ssh/id_ed25519_github'
alias sshmain='ssh-add -t 24h ~/.ssh/id_ed25519'

