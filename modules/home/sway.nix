{
  config,
  lib,
  pkgs,
  ...
}:
let
  theme = import ./theme.nix;

  mod = "Mod4"; # Super. Mod1 (Alt) is left free for the scratchpad.

  # A script because sway cannot scope a binding to the focused window
  # when it is floating; see the README. ppt is integer-only, hence 33/34/33.
  sway-snap = pkgs.writeShellApplication {
    name = "sway-snap";
    runtimeInputs = with pkgs; [
      sway
      jq
    ];
    text = ''
      if [ $# -ne 1 ]; then
        echo "usage: sway-snap <preset>" >&2
        exit 1
      fi

      focused=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .type')
      if [ "$focused" != "floating_con" ]; then
        exit 0
      fi

      # width height pos_x pos_y, all ppt
      snap() {
        swaymsg "resize set $1 ppt $2 ppt, move position $3 ppt $4 ppt" >/dev/null
      }

      case "$1" in
        left-half)        snap  50 100  0  0 ;;
        right-half)       snap  50 100 50  0 ;;
        top-half)         snap 100  50  0  0 ;;
        bottom-half)      snap 100  50  0 50 ;;

        top-left)         snap  50  50  0  0 ;;
        top-right)        snap  50  50 50  0 ;;
        bottom-left)      snap  50  50  0 50 ;;
        bottom-right)     snap  50  50 50 50 ;;

        first-third)      snap  33 100  0  0 ;;
        centre-third)     snap  34 100 33  0 ;;
        last-third)       snap  33 100 67  0 ;;
        first-two-thirds) snap  67 100  0  0 ;;
        last-two-thirds)  snap  67 100 33  0 ;;

        maximise)         snap 100 100  0  0 ;;
        centre)           swaymsg "move position center" >/dev/null ;;

        *) echo "sway-snap: unknown preset: $1" >&2; exit 1 ;;
      esac
    '';
  };

  # Writes where the ~/Screenshots symlink in default.nix points.
  sway-screenshot = pkgs.writeShellApplication {
    name = "sway-screenshot";
    runtimeInputs = with pkgs; [
      grim
      slurp
      wl-clipboard
      libnotify
    ];
    text = ''
      mode="''${1:-region}"
      dir="$HOME/Pictures/Screenshots"
      mkdir -p "$dir"
      file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

      # Selected here so cancelling slurp aborts rather than feeding grim.
      geom=""
      case "$mode" in
        region | clip)
          geom=$(slurp) || exit 0
          [ -n "$geom" ] || exit 0
          ;;
      esac

      case "$mode" in
        region) grim -g "$geom" "$file" ;;
        output) grim "$file" ;;
        clip)   grim -g "$geom" - | wl-copy; exit 0 ;;
        *) echo "sway-screenshot: unknown mode: $mode" >&2; exit 1 ;;
      esac

      wl-copy < "$file"
      notify-send "Screenshot saved" "$file" || true
    '';
  };

  # Live config, so it covers the Home Manager defaults and cannot drift.
  sway-keys = pkgs.writeShellApplication {
    name = "sway-keys";
    runtimeInputs = with pkgs; [
      sway
      jq
      fuzzel
      gnugrep
      gnused
      gawk
      coreutils
    ];
    text = ''
      swaymsg -t get_config \
        | jq -r '.config' \
        | grep -E '^[[:space:]]*bindsym' \
        | sed -E 's#^[[:space:]]*bindsym[[:space:]]+(--[a-z-]+[[:space:]]+)*##' \
        | sed -E 's#/nix/store/[a-z0-9]{32}-[^/]+/bin/##g' \
        | sed -E 's#\bMod4\b#Super#g; s#\bMod1\b#Alt#g' \
        | sort -f \
        | awk '{ key = $1; $1 = ""; sub(/^ /, ""); printf "%-26s %s\n", key, $0 }' \
        | fuzzel --dmenu --prompt 'keys: ' >/dev/null || true
    '';
  };

  snap = preset: "exec ${sway-snap}/bin/sway-snap ${preset}";
in
{
  home.packages = [
    sway-snap
    sway-screenshot
    sway-keys
    pkgs.playerctl # media keys
  ];

  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = mod;
      terminal = "${pkgs.foot}/bin/foot";
      menu = "${pkgs.fuzzel}/bin/fuzzel";

      window = {
        titlebar = false;
        border = 1;
      };
      floating = {
        titlebar = false;
        border = 1;
      };

      # Empty suppresses swaybar, which would reserve a second zone.
      bars = [ ];

      # sway's own copy; services.xserver.xkb still covers GDM and TTYs.
      input = {
        "type:keyboard" = {
          xkb_layout = "gb";
          xkb_options = "caps:escape_shifted_capslock";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
          tap = "enabled";
          dwt = "enabled"; # disable while typing
        };
      };

      # ~201 DPI. A colour not an image: the build-time config validator
      # cannot see a path under $HOME.
      output."eDP-1" = {
        scale = "1.5";
        bg = "#${theme.bg} solid_color";
      };

      # Spawned once and parked, or the first toggle has nothing to show.
      startup = [
        {
          # foot has no tabs; zellij is what supplies them.
          command = "${pkgs.foot}/bin/foot --app-id=scratchpad-term ${pkgs.zellij}/bin/zellij";
        }
      ];

      # mkOptionDefault, or this replaces every default binding rather
      # than adding to them: focus, move, workspaces, kill, the lot.
      keybindings = lib.mkOptionDefault {
        # --- Launching and discovering ----------------------------------
        # mkForce because this is the one key that collides with a default.
        "${mod}+space" = lib.mkForce "exec ${pkgs.fuzzel}/bin/fuzzel";
        "${mod}+Tab" = "focus mode_toggle";
        "${mod}+slash" = "exec ${sway-keys}/bin/sway-keys";

        # --- Rectangle-style snapping (floating windows only) ----------
        # Inert on tiled windows; $mod+Shift+space floats one first.
        "${mod}+Ctrl+Left" = snap "left-half";
        "${mod}+Ctrl+Right" = snap "right-half";
        "${mod}+Ctrl+Up" = snap "top-half";
        "${mod}+Ctrl+Down" = snap "bottom-half";

        "${mod}+Ctrl+u" = snap "top-left";
        "${mod}+Ctrl+i" = snap "top-right";
        "${mod}+Ctrl+j" = snap "bottom-left";
        "${mod}+Ctrl+k" = snap "bottom-right";

        "${mod}+Ctrl+d" = snap "first-third";
        "${mod}+Ctrl+f" = snap "centre-third";
        "${mod}+Ctrl+g" = snap "last-third";
        "${mod}+Ctrl+e" = snap "first-two-thirds";
        "${mod}+Ctrl+t" = snap "last-two-thirds";

        "${mod}+Ctrl+Return" = snap "maximise";
        "${mod}+Ctrl+c" = snap "centre";

        # --- Monitors ---------------------------------------------------
        # Wraps at the last screen. Works on tiled windows too.
        "${mod}+comma" = "focus output left";
        "${mod}+period" = "focus output right";
        "${mod}+Shift+comma" = "move container to output left";
        "${mod}+Shift+period" = "move container to output right";

        # Re-applied on show: sway re-centres and may drop the size.
        "Mod1+space" =
          "[app_id=\"scratchpad-term\"] scratchpad show,"
          + " resize set 40 ppt 67 ppt, move position 0 ppt 0 ppt";

        # Echoes macOS's Ctrl+Cmd+Q; $mod+Shift+q is already kill-window.
        "${mod}+Ctrl+q" = "exec ${config.programs.swaylock.package}/bin/swaylock -f";

        # --- Screenshots ------------------------------------------------
        "Print" = "exec ${sway-screenshot}/bin/sway-screenshot region";
        "Shift+Print" = "exec ${sway-screenshot}/bin/sway-screenshot output";
        "Ctrl+Print" = "exec ${sway-screenshot}/bin/sway-screenshot clip";

        # --- Media and brightness keys ----------------------------------
        "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";

        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
      };
    };

    # The things with no Home Manager option.
    extraConfig = ''
      # Parked at startup so Alt+Space toggles rather than spawning.
      for_window [app_id="scratchpad-term"] floating enable, resize set 40 ppt 67 ppt, move position 0 ppt 0 ppt, move scratchpad

      # Tiled dialogs are awkward, and floating them enables the snap keys.
      for_window [window_role="dialog"] floating enable
      for_window [window_type="dialog"] floating enable
      for_window [app_id="pavucontrol"] floating enable
      for_window [app_id="blueman-manager"] floating enable
      for_window [app_id="1Password"] floating enable
    '';
  };

  # No clipboard history: cliphist only skips entries with the password
  # manager MIME hint, which 1Password does not set, so secrets persist.

  # A unit rather than a sway `exec`, to restart on crash.
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome authentication agent";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      # Or systemd gives up after 5 restarts and prompts silently stop.
      StartLimitIntervalSec = 0;
    };
  };
}
