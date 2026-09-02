{ pkgs, ... }:
let
  # -f daemonises after the lock surface is up, so swayidle and the
  # sleep hook cannot race the screen going off before it is covered.
  lock = "${pkgs.swaylock-effects}/bin/swaylock -f";
in
{
  # GNOME's lock screen. programs.swaylock.enable does not follow
  # settings being set on a current home.stateVersion, so it is explicit.
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;

    settings = {
      screenshots = true;
      effect-blur = "8x5";
      effect-vignette = "0.4:0.4";
      clock = true;
      timestr = "%H:%M";
      datestr = "%a %d %b";
      indicator = true;
      indicator-radius = 110;
      indicator-thickness = 8;
      ring-color = "1d2021";
      key-hl-color = "8ec07c";
      line-color = "00000000";
      inside-color = "1d202188";
      separator-color = "00000000";
      text-color = "ebdbb2";
      fade-in = 0.2;
      ignore-empty-password = true;
    };
  };

  # Was GNOME's idle/blank/lock settings plus logind. Note the ordering:
  # lock before the screen powers off, so waking never shows the desktop.
  services.swayidle = {
    enable = true;

    timeouts = [
      {
        timeout = 300;
        command = lock;
      }
      {
        timeout = 600;
        command = "${pkgs.sway}/bin/swaymsg 'output * power off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on'";
      }
    ];

    # An attrset, not a list of { event; command; }. The list form still
    # parses but warns on activation.
    events = {
      before-sleep = lock;
      lock = lock;
    };
  };
}
