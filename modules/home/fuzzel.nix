{ pkgs, ... }:
let
  theme = import ./theme.nix;
in
{
  # Application launcher, in place of the GNOME overview. Bound to
  # $mod+d by sway's own default binding, which resolves to
  # wayland.windowManager.sway.config.menu.
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        font = "${theme.font}:size=12";
        terminal = "${pkgs.foot}/bin/foot";
        layer = "overlay";
        icons-enabled = true;
        icon-theme = theme.iconTheme;
        width = 45;
        lines = 12;
      };

      colors = {
        background = "${theme.bg}ee";
        text = "${theme.fg}ff";
        match = "${theme.accent}ff";
        selection = "${theme.selection}ff";
        selection-text = "${theme.fg}ff";
        border = "${theme.accent}ff";
      };

      border = {
        width = 2;
        radius = 4;
      };
    };
  };
}
