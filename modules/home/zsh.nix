{ config, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # The three plugins you were sourcing by absolute path from
    # /usr/share. Home Manager wires them up and, importantly, orders
    # syntax highlighting last so it applies to the others.
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch = {
      enable = true;
      searchUpKey = [ "^[[5~" ]; # PgUp
      searchDownKey = [ "^[[6~" ]; # PgDn
    };
    # This also removes the need for the vendored copy of
    # zsh-history-substring-search that was a git submodule in zsh/plugins.

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

    # initContent replaced initExtra in Home Manager 25.05. Ordering is by
    # mkOrder: 550 runs before compinit, 1000 after. On an older HM,
    # rename these to initExtraBeforeCompInit and initExtra respectively.
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

        # cd to parent directory, optionally into a sibling path.
        # Editing note: inside this Nix string, any dollar-brace must be
        # prefixed with two single quotes, or Nix tries to interpolate it.
        # The two below are escaped that way; zsh still receives the plain
        # parameter expansions. Do not write the unescaped form anywhere
        # in this string, not even in a comment - that is what broke the
        # build once already.
        function ..() {
            cd "../''${1:-.}" || return
        }
        _dotdot_complete() { _path_files -/ -W ''${PWD:h} }
        compdef _dotdot_complete ..

        # The oh-my-zsh-derived git aliases and helper functions. Kept as a
        # plain zsh file rather than translated into Nix: it is 400 lines
        # of shell that has nothing to gain from being an attribute set,
        # and this way it stays diffable against upstream.
        source ${../../config/zsh/git-aliases.zsh}
      '')
    ];
  };

  # No PATH entries needed for codium or cursor. Home Manager links every
  # package in home.packages into ~/.nix-profile/bin, which is already on
  # PATH, so the two hardcoded /usr/bin exports are gone.
}
