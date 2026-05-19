#########################################
# COMPLETIONS
#########################################

fpath+=~/.zsh-plugins/zsh-completions

autoload -Uz compinit

if [[ ! -f ~/.zcompdump || ~/.zcompdump -nt ~/.zshrc ]]; then
    compinit
else
    compinit -C
fi

#########################################
# PLUGINS
#########################################

source "$HOME/.zsh-plugins/powerlevel10k/powerlevel10k.zsh-theme"
source "$HOME/.zsh-plugins/zsh-defer/zsh-defer.plugin.zsh"

zsh-defer source "$HOME/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOME/.zsh-plugins/fzf-tab/fzf-tab.plugin.zsh"
zsh-defer source "$HOME/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

#########################################
# TOOLS
#########################################

eval "$(zoxide init zsh)"


