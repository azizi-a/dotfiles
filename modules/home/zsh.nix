{ config, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Home Manager orders syntax highlighting last, as it must be.
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch = {
      enable = true;
      searchUpKey = [ "^[[5~" ]; # PgUp
      searchDownKey = [ "^[[6~" ]; # PgDn
    };
    history = {
      path = "${config.home.homeDirectory}/.zsh_history";
      size = 10000;
      save = 100000;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    completionInit = ''
      autoload -U compinit && compinit
      # case-insensitive and partial-word completion
      zstyle ':completion:*' matcher-list "" 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
    '';

    # mkOrder: 550 runs before compinit, 1000 after.
    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        # disable XON/XOFF so ^Q and ^S are usable as key binds
        stty -ixon
      '')

      (lib.mkOrder 1000 ''
        # arrow keys search history by what is already typed
        # (tip: use CTRL-V to find escape sequences)
        bindkey '^[OA' history-beginning-search-backward
        bindkey '^[OB' history-beginning-search-forward

        mkcd() {
          mkdir -p "$@" && cd "$_"
        }

        exists() {
          # `command -v` is similar to `which`
          command -v "$1" >/dev/null 2>&1
        }

        # Dollar-brace needs escaping anywhere in this string, comments
        # included, or Nix interpolates it. That has broken the build once.
        function ..() {
            cd "../''${1:-.}" || return
        }
        _dotdot_complete() { _path_files -/ -W ''${PWD:h} }
        compdef _dotdot_complete ..

        # Left as plain zsh so it stays diffable against upstream.
        source ${../../config/zsh/git-aliases.zsh}
      '')
    ];
  };
}
