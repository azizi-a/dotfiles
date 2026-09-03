{ pkgs, ... }:
let
  theme = import ./theme.nix;
in
{
  # sway runs no settings daemon, so GTK2/3 need telling directly.
  # gnome.nix carries the same values for GTK4, which reads dconf.
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

  # Exports XCURSOR_*, which sway forwards to its seat and to clients.
  # Without it the pointer falls back to the X11 core cursor in places.
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };
}
