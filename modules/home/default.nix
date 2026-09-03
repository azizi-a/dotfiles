{
  config,
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./aliases.nix
    ./bat.nix
    ./fuzzel.nix
    ./git.nix
    ./gnome.nix
    ./gtk.nix
    ./helix.nix
    ./kitty.nix
    ./kanshi.nix
    ./mako.nix
    ./neovim.nix
    ./packages.nix
    ./scripts.nix
    ./ssh.nix
    ./starship.nix
    ./sway.nix
    ./swaylock.nix
    ./vim.nix
    ./vscode.nix
    ./waybar.nix
    ./zed-editor.nix
    ./zsh.nix
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";

    # Same rule as system.stateVersion: set once, never bump.
    stateVersion = "26.05";

    sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
      NULLCMD = "bat";
    };
  };

  home.file = {
    "Code/.keep".text = "";
    "Code/Testbed/.keep".text = "";
    "Pictures/Screenshots/.keep".text = "";

    # Out of store, this being a directory you write into.
    "Screenshots".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Pictures/Screenshots";
  };

  xdg.enable = true;

  programs.home-manager.enable = true;
}
