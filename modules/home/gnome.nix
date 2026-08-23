{ lib, ... }:
let
  # On Home Manager 25.05+ this is lib.gvariant; lib.hm.gvariant is still
  # provided as an alias. Swap if you ever see "attribute 'hm' missing".
  inherit (lib.hm.gvariant) mkEmptyArray type;
in
{
  # Every `gsettings set` line from setup_ubuntu.zsh. The difference is
  # that these are reapplied on every activation, so a fresh machine or a
  # reset profile comes back to the same state without rerunning a script.
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      # caps -> esc, shift+caps -> caps lock
      xkb-options = [ "caps:escape_shifted_capslock" ];
    };

    "org/gnome/desktop/interface" = {
      gtk-theme = "Yaru-viridian-dark";
      icon-theme = "Yaru-viridian";
      color-scheme = "prefer-dark";
      # Ubuntu's default was already close to this; set explicitly since
      # vanilla GNOME defaults to light.
    };

    "org/gnome/mutter" = {
      center-new-windows = true;
      dynamic-workspaces = true;
      workspaces-only-on-primary = false;

      # The Framework 13 panel is 2256x1504 at 13.5", so ~201 DPI. GNOME
      # picks 200% by default, which is usually too big; this unlocks the
      # fractional steps so you can sit at 125% or 150% in Settings >
      # Displays. Wayland only.
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    # Vanilla GNOME does not ship dash-to-dock, so it has to be listed
    # here as well as installed in modules/nixos/desktop.nix.
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
      # Remove Super + Up/Down. An empty list needs an explicit element
      # type, otherwise dconf cannot work out the GVariant signature.
      shift-overview-up = mkEmptyArray type.string;
      shift-overview-down = mkEmptyArray type.string;
    };

    "org/gnome/desktop/wm/preferences" = {
      # Sensible defaults that were implicit on Ubuntu.
      button-layout = "appmenu:minimize,maximize,close";
    };
  };
}
