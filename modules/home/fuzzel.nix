{ pkgs, ... }:
{
  # Application launcher, in place of the GNOME overview. Bound to
  # $mod+d by sway's own default binding, which resolves to
  # wayland.windowManager.sway.config.menu.
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        font = "SauceCodePro Nerd Font:size=12";
        terminal = "${pkgs.foot}/bin/foot";
        layer = "overlay";
        width = 45;
        lines = 12;
      };

      colors = {
        background = "1d2021ee";
        text = "ebdbb2ff";
        match = "8ec07cff";
        selection = "3c3836ff";
        selection-text = "ebdbb2ff";
        border = "8ec07cff";
      };

      border = {
        width = 2;
        radius = 4;
      };
    };
  };
}
