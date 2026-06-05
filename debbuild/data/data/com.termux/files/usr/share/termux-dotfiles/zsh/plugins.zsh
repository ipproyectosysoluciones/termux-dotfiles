#########################################
# PLUGINS PATH
#########################################

if [[ -d "/termux/.zsh-plugins" ]]; then
    export ZSH_PLUGINS="/termux/.zsh-plugins"
else
    export ZSH_PLUGINS="$HOME/.zsh-plugins"
fi

#########################################
# COMPLETIONS
#########################################

fpath+=${ZSH_PLUGINS}/zsh-completions

autoload -Uz compinit

if [[ ! -f ~/.zcompdump || ~/.zcompdump -nt ~/.zshrc ]]; then
    compinit
else
    compinit -C
fi

#########################################
# PLUGINS
#########################################

source "${ZSH_PLUGINS}/powerlevel10k/powerlevel10k.zsh-theme"
source "${ZSH_PLUGINS}/zsh-defer/zsh-defer.plugin.zsh"

zsh-defer source "${ZSH_PLUGINS}/zsh-autosuggestions/zsh-autosuggestions.zsh"

source "${ZSH_PLUGINS}/fzf-tab/fzf-tab.plugin.zsh"

zsh-defer source "${ZSH_PLUGINS}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

#########################################
# TOOLS
#########################################

eval "$(zoxide init zsh)"

