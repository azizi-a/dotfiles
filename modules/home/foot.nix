{ ... }:
let
  theme = import ./theme.nix;
in
{
  # Replaces guake. Guake is GTK/X11: under Wayland it cannot take a
  # global hotkey or place its own window, both of which were the whole
  # point of it. sway's scratchpad does the same job natively, so the
  # drop-down behaviour moves into modules/home/sway.nix and this file is
  # just the terminal.
  #
  # Geometry lives in sway.nix's scratchpad rule; font and opacity carry
  # over from the old guake preferences.
  programs.foot = {
    enable = true;

    settings = {
      main = {
        font = "${theme.font}:size=13";
        pad = "8x8";
        # Terminfo that ships with foot is not on remote hosts; claiming
        # xterm-256color avoids breaking ssh into anything older.
        term = "xterm-256color";
      };

      # foot 1.26 deprecated [colors] and 1.28 removes it; nixpkgs pins
      # 1.27, which is why it warned rather than failed.
      colors-dark = {
        alpha = 0.9;
        background = theme.bg;
        foreground = theme.fg;
      };

      scrollback.lines = 10000;
    };
  };
}
