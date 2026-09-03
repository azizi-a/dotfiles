{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # --- CLI -------------------------------------------------------------
    eza
    fd
    gh # gbda's PR-state checks in config/zsh/git-aliases.zsh need it
    httpie
    jq
    less
    ripgrep
    tree
    unzip

    # --- Browsers --------------------------------------------------------
    brave
    chromium
    firefox
    librewolf

    # --- Apps ------------------------------------------------------------
    discord
    protonmail-desktop
    spotify
    vlc

    # --- Nix tooling -----------------------------------------------------
    nixfmt # formatter
    nixd # language server, for the nvim/VSCode Nix support
    nh # nicer wrapper around nixos-rebuild, see README

    # --- Toolchains ------------------------------------------------------
    # For per-project versions, use a flake plus .envrc rather than nvm;
    # direnv is already on. `fnm` also works, via nix-ld.
    nodejs_24
    pnpm
    # fnm

    # Works under nix-ld. fenix or rust-overlay for a declarative one.
    rustup

    python3

    # zed-editor and helix come from their own modules.
    code-cursor
    claude-code
  ];

  # --- Programs with their own HM modules --------------------------------
  programs.eza.enable = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # replaces eval "$(direnv hook zsh)"
    nix-direnv.enable = true; # caches nix develop shells, much faster
  };

  # 20-20-20 break reminders, as a user service.
  services.safeeyes.enable = true;
}
