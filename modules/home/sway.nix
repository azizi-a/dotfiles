{
  config,
  pkgs,
  ...
}:
let
  mod = "Mod4"; # Super. Mod1 (Alt) is left free for the scratchpad.

  # Rectangle-style snapping. This has to be a script rather than plain
  # bindsym lines for two reasons:
  #
  #  1. Snapping is scoped to floating windows, and sway cannot express
  #     that in a binding. A `[floating]` criteria prefix acts on every
  #     floating window in the tree, not the focused one.
  #  2. Without the guard a binding half-applies on a tiled window:
  #     `resize set` resizes it inside its split, then `move position`
  #     fails, leaving the layout disturbed.
  #
  # Geometry is in ppt (percentage points of the workspace). sway derives
  # the workspace rect from the output's usable area, which already has
  # waybar's exclusive zone subtracted, so no bar arithmetic is needed
  # here. ppt is integer-only, hence 33/34/33 for thirds.
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

  # Region select to a timestamped file, matching the ~/Screenshots ->
  # ~/Pictures/Screenshots symlink set up in modules/home/default.nix.
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

      case "$mode" in
        region) grim -g "$(slurp)" "$file" ;;
        output) grim "$file" ;;
        clip)   grim -g "$(slurp)" - | wl-copy; exit 0 ;;
        *) echo "sway-screenshot: unknown mode: $mode" >&2; exit 1 ;;
      esac

      wl-copy < "$file"
      notify-send "Screenshot saved" "$file" || true
    '';
  };

  snap = preset: "exec ${sway-snap}/bin/sway-snap ${preset}";
in
{
  home.packages = [
    sway-snap
    sway-screenshot
    pkgs.playerctl # media keys
  ];

  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = mod;
      terminal = "${pkgs.foot}/bin/foot";
      menu = "${pkgs.fuzzel}/bin/fuzzel";

      # An empty list suppresses the bar block entirely. The default is a
      # one-element list running swaybar with i3status, which would sit
      # underneath waybar reserving a second exclusive zone.
      bars = [ ];

      # Was services.xserver.xkb plus the dconf input-sources key. The
      # system-level setting still covers the GDM screen and TTYs; this
      # is sway's own copy.
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

      # 2256x1504 at 13.5" is ~201 DPI. 1.5 is the equivalent of the 150%
      # you would have picked in GNOME's Settings > Displays. Confirm the
      # connector name with `swaymsg -t get_outputs` if this ever moves.
      #
      # Wallpaper is a solid colour rather than an image on purpose: sway
      # config is validated in the Nix build sandbox, where a path under
      # $HOME does not exist and would fail the build.
      output."eDP-1" = {
        scale = "1.5";
        bg = "#1d2021 solid_color";
      };

      keybindings = {
        # --- Rectangle-style snapping (floating windows only) ----------
        # $mod+Shift+space floats the focused window, which is what makes
        # these apply. On a tiled window they deliberately do nothing.
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
        # sway wraps at the end of the layout, so these cycle rather than
        # stopping at the last screen. Unlike the snap keys, they work on
        # tiled and floating windows alike.
        "${mod}+comma" = "focus output left";
        "${mod}+period" = "focus output right";
        "${mod}+Shift+comma" = "move container to output left";
        "${mod}+Shift+period" = "move container to output right";

        # --- Clipboard history ------------------------------------------
        # GNOME had no equivalent, but losing the clipboard on app exit
        # is worse under a WM where you close things more freely.
        "${mod}+Shift+v" =
          "exec ${pkgs.cliphist}/bin/cliphist list | ${pkgs.fuzzel}/bin/fuzzel --dmenu"
          + " | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy";

        # --- Screenshots ------------------------------------------------
        "Print" = "exec ${sway-screenshot}/bin/sway-screenshot region";
        "Shift+Print" = "exec ${sway-screenshot}/bin/sway-screenshot output";
        "Ctrl+Print" = "exec ${sway-screenshot}/bin/sway-screenshot clip";

        # --- Media and brightness keys ----------------------------------
        # GNOME bound these for you; under sway they are just bindings.
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

    # Plain sway syntax for the things that have no Home Manager option,
    # kept here so there is one obvious place to look for them.
    extraConfig = ''
      # Dialogs and pickers are tiled by default under sway, which makes
      # them awkward. Floating them also means the snap keys work on them.
      for_window [window_role="dialog"] floating enable
      for_window [window_type="dialog"] floating enable
      for_window [app_id="pavucontrol"] floating enable
      for_window [app_id="blueman-manager"] floating enable
      for_window [app_id="1Password"] floating enable
    '';
  };

  # Watches the wayland clipboard and keeps a history. wl-clipboard is
  # installed at system level in modules/nixos/sway.nix because this
  # module calls wl-paste by store path but does not put it on PATH.
  services.cliphist.enable = true;

  # GNOME Shell ran a polkit agent for you. Without one 1Password cannot
  # authorise and pkexec fails silently. A systemd user unit rather than
  # a sway `exec` line so it restarts on crash, stops with the session,
  # and starts after the environment has actually propagated.
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
    };
  };
}
