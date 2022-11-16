# Prompt
eval "$(starship init zsh)"


# ZSH Options
# Key Binds
# bind arrow keys to search history
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
# bindkey '^[OA' history-substring-search-up
# bindkey '^[OB' history-substring-search-down


# Variables
# syntax highlighting for man pages using bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export NULLCMD=bat

# nvm
export NVM_DIR="$HOME/.nvm"
# This loads nvm
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
# This loads nvm bash_completion
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"


# Aliases
source ~/.dotfiles/aliases/aliases
source ~/.dotfiles/aliases/git-aliases

# Functions
fuction mkcd() {
    mkdir -p "$@" && cd "$_";
}


# $PATH Location
# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
# yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
# kubernetes-cli
export PATH="/usr/local/opt/kubernetes-cli@1.22/bin:$PATH"
#jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"


# Plugins
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh


# Completion
autoload -U compinit; compinit
# case-insensitive completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'


# Other
# direnv
eval "$(direnv hook zsh)"
