# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Starship RS
eval "$(starship init zsh)"

# direnv
eval "$(direnv hook zsh)"

# nvm
export NVM_DIR="$HOME/.nvm"
  # This loads nvm
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
  # This loads nvm bash_completion
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"

#jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# pugins
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# aliases
source ~/.dotfiles/.aliases/.git-aliases

# bind arrow keys to search history
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward
# bindkey '^[OA' history-substring-search-up
# bindkey '^[OB' history-substring-search-down

# yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# kubernetes-cli
export PATH="/usr/local/opt/kubernetes-cli@1.22/bin:$PATH"
