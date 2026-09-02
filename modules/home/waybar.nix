{ pkgs, ... }:
let
  theme = import ./theme.nix;
in
{
  # Replaces the GNOME top bar and dash-to-dock. Runs as a systemd user
  # service rather than a sway exec line so it comes back if it crashes.
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "top";
      height = 30;

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
        # The bar is not a title bar; an empty workspace should look empty.
        format = "{title}";
      };

      tray.spacing = 10;

      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };

      # Framework enumerates the battery as BAT1, not BAT0. The same
      # quirk is why the TLP thresholds in modules/nixos/power.nix are
      # commented out.
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
        font-family: "${theme.font}";
        font-size: 13px;
      }

      window#waybar {
        background: #${theme.bg};
        color: #${theme.fg};
      }

      #workspaces button {
        padding: 0 8px;
        background: transparent;
        color: #${theme.dim};
        border-bottom: 2px solid transparent;
      }

      #workspaces button.focused {
        color: #${theme.fg};
        border-bottom: 2px solid #${theme.accent};
      }

      #workspaces button.urgent {
        color: #${theme.urgent};
      }

      #clock,
      #battery,
      #backlight,
      #pulseaudio,
      #tray {
        padding: 0 10px;
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
