{ pkgs, ... }:
let
  theme = import ./theme.nix;
in
{
  # A user service rather than a sway exec, to restart on crash.
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "bottom";

      # No height: a fixed one forces a larger exclusive zone than the
      # contents need. Padding in the stylesheet sets it instead.
      spacing = 4;

      # Uncomment to reserve no space at all and show the bar on demand.
      # mode = "hide";

      modules-left = [
        "sway/workspaces"
        "sway/mode"
      ];
      modules-center = [ "sway/window" ];
      modules-right = [
        "tray"
        "pulseaudio"
        "backlight"
        "battery"
        "clock"
      ];

      "sway/workspaces".format = "{name}";
      "sway/mode".format = "<span style=\"italic\">{}</span>";
      "sway/window" = {
        max-length = 60;
        format = "{title}";
      };

      tray.spacing = 10;

      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };

      # Framework enumerates the battery as BAT1, not BAT0.
      battery = {
        bat = "BAT1";
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-icons = [
          "󰁺"
          "󰁽"
          "󰂀"
          "󰂂"
          "󰁹"
        ];
      };

      backlight = {
        format = "󰃟 {percent}%";
        on-scroll-up = "brightnessctl set 5%+";
        on-scroll-down = "brightnessctl set 5%-";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons.default = [
          "󰕿"
          "󰖀"
          "󰕾"
        ];
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      };
    };

    style = ''
      * {
        font-family: "${theme.font}", "Symbols Nerd Font Mono";
        font-size: 12px;
        /* Kills the default 4px of dead space above and below the text */
        min-height: 0;
        padding: 0;
        margin: 0;
      }

      window#waybar {
        background: #${theme.bg};
        color: #${theme.fg};
        /* Sets the bar height, there being none configured. */
        padding: 1px 6px;
      }

      #workspaces button {
        padding: 0 8px;
        background: transparent;
        color: #${theme.dim};
        border-top: 2px solid transparent;
      }

      #workspaces button.focused {
        color: #${theme.fg};
        border-top: 2px solid #${theme.accent};
      }

      #workspaces button.urgent {
        color: #${theme.urgent};
      }

      #clock,
      #battery,
      #backlight,
      #pulseaudio,
      #tray {
        padding: 0 8px;
      }

      #battery.warning {
        color: #${theme.warning};
      }

      #battery.critical {
        color: #${theme.urgent};
      }
    '';
  };

  home.packages = [ pkgs.pavucontrol ]; # the pulseaudio module's on-click
}
