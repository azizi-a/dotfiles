{ pkgs, ... }:
let
  theme = import ./theme.nix;
in
{
  # sway runs no settings daemon, so GTK2/3 have to be told directly or
  # apps come up in light Adwaita whatever dconf says. gnome.nix carries
  # the same values for GTK4/libadwaita, which read dconf instead.
  gtk = {
    enable = true;

    theme = {
      name = theme.gtkTheme;
      package = pkgs.yaru-theme;
    };

    iconTheme = {
      name = theme.iconTheme;
      package = pkgs.yaru-theme;
    };
  };

  # Sets the cursor for GTK and exports XCURSOR_THEME/XCURSOR_SIZE, which
  # sway forwards to its own seat config and to Wayland clients. Without
  # it the pointer falls back to the X11 core cursor over some surfaces,
  # which is the tiny black X you would otherwise see on the desktop.
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };
}
