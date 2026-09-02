{ ... }:
{
  # Replaces guake. Guake is GTK/X11: under Wayland it cannot take a
  # global hotkey or place its own window, both of which were the whole
  # point of it. sway's scratchpad does the same job natively, so the
  # drop-down behaviour moves into modules/home/sway.nix and this file is
  # just the terminal.
  #
  # Sizes and font carry over from the old guake preferences: 67% wide,
  # 50% tall, 90% opaque, SauceCodePro Nerd Font at 13, no scrollbar.
  programs.foot = {
    enable = true;

    settings = {
      main = {
        font = "SauceCodePro Nerd Font:size=13";
        pad = "8x8";
        # Terminfo that ships with foot is not on remote hosts; claiming
        # xterm-256color avoids breaking ssh into anything older.
        term = "xterm-256color";
      };

      colors = {
        alpha = 0.9;
        background = "1d2021";
        foreground = "ebdbb2";
      };

      scrollback.lines = 10000;
    };
  };
}
