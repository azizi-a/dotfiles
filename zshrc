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
export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
export NULLCMD=bat

# nvm
export NVM_DIR="$HOME/.nvm"
# This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# This loads nvm bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Aliases
source ~/.dotfiles/aliases/aliases
source ~/.dotfiles/aliases/git-aliases

# Functions
fuction mkcd() {
    mkdir -p "$@" && cd "$_";
}


# $PATH Location
# Add Visual Studio Code (code)
export PATH="$PATH:/snap/bin/code"


# Plugins
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# Completion
autoload -U compinit; compinit
# case-insensitive completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'


# Other
# direnv
eval "$(direnv hook zsh)"
