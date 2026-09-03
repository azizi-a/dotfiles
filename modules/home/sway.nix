{
  config,
  lib,
  pkgs,
  ...
}:
let
  mod = "Mod4"; # Super. Mod1 (Alt) is left free for the scratchpad.

  # Halves and thirds resize in the tiling tree; quarters have no clean
  # equivalent and float. ppt is integer-only, hence 33/34/33.
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

      # Float and place, in percentages of the workspace.
      place() {
        swaymsg "floating enable, resize set $1 ppt $2 ppt, move position $3 ppt $4 ppt" >/dev/null
      }

      # Resize in the tree instead, shuffled to the requested end so the
      # siblings keep the rest. axis size first|centre|last
      tile() {
        if [ "$1" = h ]; then
          want_layout=splith; back=left; fwd=right; dim=width
        else
          want_layout=splitv; back=up;   fwd=down;  dim=height
        fi
        size=$2
        want=$3

        layout=""
        idx=0
        count=1
        info=$(swaymsg -t get_tree | jq -r 'first(.. | objects
          | select(.nodes? and (.nodes | map(.focused == true) | any))
          | "\(.layout) \(.nodes | map(.focused == true) | index(true)) \(.nodes | length)")')
        if [ -n "$info" ]; then
          read -r layout idx count <<< "$info"
        fi

        # A half-height means nothing in a row. Order survives the
        # conversion, so idx and count still hold.
        if [ "$layout" != "$want_layout" ]; then
          swaymsg "layout $want_layout" >/dev/null
        fi

        case "$want" in
          first) target=0 ;;
          last)  target=$((count - 1)) ;;
          *)     target=$(((count - 1) / 2)) ;;
        esac
        while [ "$idx" -gt "$target" ]; do
          swaymsg "move $back" >/dev/null
          idx=$((idx - 1))
        done
        while [ "$idx" -lt "$target" ]; do
          swaymsg "move $fwd" >/dev/null
          idx=$((idx + 1))
        done

        swaymsg "resize set $dim $size ppt" >/dev/null
      }

      # width pos want
      across() {
        if [ "$focused" = "floating_con" ]; then
          place "$1" 100 "$2" 0
        else
          tile h "$1" "$3"
        fi
      }

      # height pos want
      down() {
        if [ "$focused" = "floating_con" ]; then
          place 100 "$1" 0 "$2"
        else
          tile v "$1" "$3"
        fi
      }

      case "$1" in
        left-half)        across 50  0 first ;;
        right-half)       across 50 50 last ;;
        top-half)         down   50  0 first ;;
        bottom-half)      down   50 50 last ;;

        first-third)      across 33  0 first ;;
        centre-third)     across 34 33 centre ;;
        last-third)       across 33 67 last ;;
        first-two-thirds) across 67  0 first ;;
        last-two-thirds)  across 67 33 last ;;

        top-left)         place 50  50  0  0 ;;
        top-right)        place 50  50 50  0 ;;
        bottom-left)      place 50  50  0 50 ;;
        bottom-right)     place 50  50 50 50 ;;

        maximise)         place 100 100 0 0 ;;
        centre)           swaymsg "floating enable, move position center" >/dev/null ;;

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
      gnused
      gawk
      coreutils
    ];
    text = ''
      swaymsg -t get_config \
        | jq -r '.config' \
        | sed -E '
            s#/nix/store/[a-z0-9]{32}-[^/]+/bin/##g
            s/\bMod4\b/Super/g
            s/\bMod1\b/Alt/g
            s#\bslash\b#/#g
            s/\bcomma\b/,/g
            s/\bperiod\b/./g
            s/\bminus\b/-/g
            s/\bplus\b/+/g
            s/\bequal\b/=/g
            s/\bgrave\b/`/g
            s/\bbracketleft\b/[/g
            s/\bbracketright\b/]/g
            s/\bspace\b/Space/g
            s/\bLeft\b/←/g
            s/\bDown\b/↓/g
            s/\bUp\b/↑/g
            s/\bRight\b/→/g
          ' \
        | awk '
            /^mode "/ { m = $0; sub(/^mode "/, "", m); sub(/".*/, "", m); mode = m; next }
            /^}/      { mode = ""; next }
            /^[[:space:]]*bindsym/ {
              sub(/^[[:space:]]*bindsym[[:space:]]+/, "")
              sub(/^(--[a-zA-Z-]+[[:space:]]+)+/, "")
              key = $1; $1 = ""; sub(/^ /, "")
              if (mode != "") $0 = "(" mode " mode) " $0
              printf "%-22s %s\n", key, $0
            }
          ' \
        | sort -f \
        | fuzzel --dmenu --prompt 'keys: ' >/dev/null || true
    '';
  };

  sway-power = pkgs.writeShellApplication {
    name = "sway-power";
    runtimeInputs = with pkgs; [
      fuzzel
      sway
      systemd
    ];
    text = ''
      case "$(printf '%s\n' Lock Suspend Hibernate "Log out" Reboot "Shut down" \
                | fuzzel --dmenu --prompt 'power: ')" in
        Lock)         ${config.programs.swaylock.package}/bin/swaylock -f ;;
        Suspend)      systemctl suspend ;;
        Hibernate)    systemctl hibernate ;;
        "Log out")    swaymsg exit ;;
        Reboot)       systemctl reboot ;;
        "Shut down")  systemctl poweroff ;;
      esac
    '';
  };

  snap = preset: "exec ${sway-snap}/bin/sway-snap ${preset}";
in
{
  home.packages = [
    sway-snap
    sway-screenshot
    sway-keys
    sway-power
    pkgs.playerctl # media keys
  ];

  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = mod;
      terminal = "${pkgs.kitty}/bin/kitty";
      menu = "${pkgs.fuzzel}/bin/fuzzel";

      # smart, the default, only focuses a window already on screen; an
      # app on another workspace just went urgent.
      focus.newWindow = "focus";

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

      output = {
        # The same wallpaper the GNOME session shows: nixos-artwork's
        # dark variant, which is what NixOS pairs with prefer-dark. A
        # store path, so the build-time validator can see it.
        "*".bg = "${pkgs.nixos-artwork.wallpapers.simple-dark-gray.gnomeFilePath} fill";

        # ~201 DPI.
        "eDP-1".scale = "1.5";
      };

      # Matched case-insensitively: Electron apps do not all report the
      # app_id you would guess. `swaymsg -t get_tree` shows the real one.
      assigns = {
        "1" = [ { app_id = "(?i)firefox"; } ];
        "2" = [ { app_id = "(?i)proton"; } ];
        "3" = [ { app_id = "(?i)1password"; } ];
      };

      startup = [
        { command = "${pkgs.firefox}/bin/firefox"; }
        { command = "${pkgs.protonmail-desktop}/bin/proton-mail"; }
        # From the system module, which wraps it for its polkit helper.
        { command = "1password"; }
        {
          # Parked at startup, or the first toggle has nothing to show.
          # --class sets the app_id the rules below match.
          command = "${pkgs.kitty}/bin/kitty --class=scratchpad-term";
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
        "${mod}+Escape" = "exec ${sway-power}/bin/sway-power";

        # --- Rectangle-style snapping ------------------------------------
        # Halves and thirds resize in place; quarters float first.
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
