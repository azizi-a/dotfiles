{ lib, ... }:
let
  theme = import ./theme.nix;
in
{
  # Replaces foot, which has no tabs and will not get them. Tabs are
  # Ctrl+Shift+T, close Ctrl+Shift+Q, cycle Ctrl+Shift+left/right.
  programs.kitty = {
    enable = true;

    font = {
      name = theme.font;
      size = 13;
    };

    settings = {
      # kitty's own terminfo is not on remote hosts, so ssh into anything
      # older breaks unless it claims something universal.
      term = "xterm-256color";

      background = "#${theme.bg}";
      foreground = "#${theme.fg}";
      background_opacity = "0.9";
      window_padding_width = 8;
      scrollback_lines = 10000;
    };

    # kitty ships no default for jumping straight to a numbered tab.
    keybindings = builtins.listToAttrs (
      map (n: {
        name = "ctrl+shift+${toString n}";
        value = "goto_tab ${toString n}";
      }) (lib.range 1 9)
    );
  };
}
