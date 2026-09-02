{ pkgs, ... }:
let
  theme = import ./theme.nix;
in
{
  # GNOME Shell applied the theme through its own settings daemon. sway
  # runs no such thing, so GTK has to be told directly or apps come up in
  # the default light Adwaita regardless of what dconf says.
  #
  # The dconf keys in gnome.nix are still what GTK4/libadwaita reads, so
  # the two files agree on purpose: this covers GTK2 and GTK3, which read
  # their own config files instead.
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
