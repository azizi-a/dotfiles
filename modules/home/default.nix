{ config, pkgs, user, ... }:
{
  imports = [
    ./packages.nix
    ./zsh.nix
    ./aliases.nix
    ./starship.nix
    ./git.nix
    ./bat.nix
    ./neovim.nix
    ./vim.nix
    ./helix.nix
    ./zed.nix
    ./guake.nix
    ./vscode.nix
    ./gnome.nix
    ./scripts.nix
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";

    # Same rule as system.stateVersion: set once, never bump.
    stateVersion = "26.05";

    sessionVariables = {
      # Note `bat`, not `batcat`. Debian renamed the binary because of a
      # package name clash; nixpkgs does not, so the batcat alias is gone.
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
      NULLCMD = "bat";

      # MOZ_ENABLE_WAYLAND and ANKI_WAYLAND from your zshenv are no longer
      # needed: NIXOS_OZONE_WL in modules/nixos/desktop.nix covers the
      # Electron/Chromium side, and current Firefox picks Wayland itself.
    };
  };

  # This replaces the `- create:` and `- link:` blocks in install.conf.yaml.
  home.file = {
    "Code/.keep".text = "";
    "Code/Testbed/.keep".text = "";
    "Pictures/Screenshots/.keep".text = "";

    # ~/Screenshots -> ~/Pictures/Screenshots
    # mkOutOfStoreSymlink points at a real path rather than the nix store,
    # which is what you want for a directory you write into.
    "Screenshots".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Pictures/Screenshots";
  };

  xdg.enable = true;

  programs.home-manager.enable = true;
}
