{ pkgs, ... }:
{
  # Everything setup_ubuntu.zsh installed via apt, snap or a curl script.
  # No install-scripts/ directory survives the move.
  home.packages = with pkgs; [
    # --- CLI -------------------------------------------------------------
    eza
    fd
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
    spotify
    vlc

    # --- Nix tooling -----------------------------------------------------
    nixfmt # formatter
    nixd # language server, for the nvim/VSCode Nix support
    nh # nicer wrapper around nixos-rebuild, see README

    # --- Toolchains ------------------------------------------------------
    # nvm is gone. Three options, in rough order of how well they fit:
    #
    #  1. A nodejs from nixpkgs for ad-hoc use (below), plus a per-project
    #     flake.nix + .envrc so each repo pins its own version. direnv is
    #     already enabled in zsh.nix, so entering the directory switches
    #     versions. This is the idiomatic answer.
    #  2. `fnm`, which behaves like nvm. Needs programs.nix-ld (already
    #     on) because the Node builds it downloads are not Nix-built.
    #  3. Keep nvm itself. Also works via nix-ld, but you are then
    #     managing a toolchain outside the config, which is the thing
    #     you are moving away from.
    nodejs_24
    pnpm
    # fnm

    # Same story for `. "$HOME/.cargo/env"`. rustup works under nix-ld;
    # for a fully declarative toolchain use the fenix or rust-overlay flake.
    rustup

    python3

    # --- Newer tools, not in the ubuntu branch ---------------------------
    # Included because they are in your current rotation. Delete freely.
    # zed-editor and helix are installed by their own modules
    # (zed.nix, helix.nix), so they are not listed here.
    code-cursor
    claude-code
  ];

  # --- Programs with their own HM modules --------------------------------
  programs.eza.enable = true;
  programs.fzf = {
    enable = true;
    # Replaces sourcing /usr/share/doc/fzf/examples/{key-bindings,completion}.zsh
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # replaces eval "$(direnv hook zsh)"
    nix-direnv.enable = true; # caches nix develop shells, much faster
  };

  # 20-20-20 break reminders. HM ships a user service, so it starts with
  # your session instead of needing an autostart entry.
  services.safeeyes.enable = true;
}
