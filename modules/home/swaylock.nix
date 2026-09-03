{
  config,
  pkgs,
  ...
}:
let
  theme = import ./theme.nix;

  # -f daemonises only once the lock surface is up, so nothing races it.
  lock = "${config.programs.swaylock.package}/bin/swaylock -f";
in
{
  # enable does not follow settings on a current stateVersion.
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
      ring-color = theme.bg;
      key-hl-color = theme.accent;
      line-color = "00000000";
      inside-color = "${theme.bg}88";
      separator-color = "00000000";
      text-color = theme.fg;
      fade-in = 0.2;
      ignore-empty-password = true;
    };
  };

  # Lock before the screen powers off, so waking never shows the desktop.
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

    # An attrset; the old list form still parses but warns.
    events = {
      before-sleep = lock;
      lock = lock;
    };
  };
}
