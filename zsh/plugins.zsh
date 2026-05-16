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

source ~/.zsh-plugins/powerlevel10k/powerlevel10k.zsh-theme
source ~/.zsh-plugins/zsh-defer/zsh-defer.plugin.zsh

zsh-defer source ~/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh-plugins/fzf-tab/fzf-tab.plugin.zsh
zsh-defer source ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#########################################
# TOOLS
#########################################

eval "$(zoxide init zsh)"

