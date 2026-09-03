{ lib, ... }:
let
  # lib.gvariant on HM 25.05+; swap on "attribute 'hm' missing".
  inherit (lib.hm.gvariant) mkEmptyArray type;

  theme = import ./theme.nix;
in
{
  # GNOME is the fallback session now, so most of this only applies when
  # you pick it at GDM. Each block says which sessions it reaches. GTK2/3
  # theming is in gtk.nix, sway having no settings daemon.
  dconf.settings = {
    # GNOME only; sway and services.xserver.xkb carry their own copies.
    "org/gnome/desktop/input-sources" = {
      # caps -> esc, shift+caps -> caps lock
      xkb-options = [ "caps:escape_shifted_capslock" ];
    };

    # Both sessions: GTK4 reads these, and the portal reports color-scheme.
    "org/gnome/desktop/interface" = {
      gtk-theme = theme.gtkTheme;
      icon-theme = theme.iconTheme;
      color-scheme = "prefer-dark";
    };

    # GNOME only. sway's equivalent is the scale on output eDP-1.
    "org/gnome/mutter" = {
      center-new-windows = true;
      dynamic-workspaces = true;
      workspaces-only-on-primary = false;

      # ~201 DPI, and GNOME picks 200%. Unlocks the fractional steps.
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    # GNOME only. dash-to-dock is not vanilla, so it is listed here as
    # well as installed in modules/nixos/desktop.nix.
    "org/gnome/shell" = {
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "appindicatorsupport@rgcjonas.gmail.com"
      ];
      disable-user-extension = false;
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      autohide = true;
      autohide-in-fullscreen = false;
      dock-fixed = false;
      dock-position = "BOTTOM";
      isolate-monitors = false;
      isolate-workspaces = true;
    };

    "org/gnome/shell/keybindings" = {
      # Empty lists need an explicit type for the GVariant signature.
      shift-overview-up = mkEmptyArray type.string;
      shift-overview-down = mkEmptyArray type.string;
    };

    # Both sessions: GTK reads this for client-side decorations.
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
  };
}
