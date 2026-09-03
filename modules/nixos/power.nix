{ config, pkgs, ... }:
{
  # GNOME pulls this in, and it fights tlp over the same knobs.
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # Inert here: the battery enumerates as BAT1, not BAT0. See
      # hosts/laptop/default.nix for what does work.
      # START_CHARGE_THRESH_BAT1 = 40;
      # STOP_CHARGE_THRESH_BAT1 = 80;
    };
  };

  # Applies the powertop tunables at boot, without the manual calibrate.
  powerManagement.powertop.enable = true;

  services.thermald.enable = true; # Intel CPUs only, ignored otherwise

  # HandleLidSwitch fires only off external power, which is exactly the
  # unplugged case. Plugged in, the lid still just locks.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "lock";
    HandlePowerKey = "suspend";
  };

  # fprintd loses its device claim across a sleep cycle: certain on
  # hibernate, intermittent on suspend. This runs on resume from both;
  # post-resume.target, which search results suggest, does not exist.
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl restart fprintd.service
  '';

  # An upper bound: systemd hibernates sooner if the battery will not
  # last. settings.Sleep, the older extraConfig having been removed.
  systemd.sleep.settings.Sleep.HibernateDelaySec = "25m";

  # logind fails a lid-close outright rather than falling back to suspend
  # when it cannot hibernate (systemd#10558) - a laptop awake in a bag.
  assertions = [
    {
      assertion = config.swapDevices != [ ];
      message = ''
        HandleLidSwitch is suspend-then-hibernate but swapDevices is
        empty, so hibernation cannot work. Add swap at least the size of
        RAM in hosts/laptop/hardware-configuration.nix and set
        boot.resumeDevice; see "Hibernation" in README.md. To go back to
        plain suspend instead, set HandleLidSwitch = "suspend" in
        modules/nixos/power.nix.
      '';
    }
  ];
}
