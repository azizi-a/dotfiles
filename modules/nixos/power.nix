{ config, pkgs, ... }:
{
  # The whole "install tlp, enable it, then stop/disable/mask
  # power-profiles-daemon" dance becomes two options. GNOME pulls in
  # power-profiles-daemon by default, so it has to be turned off
  # explicitly or the two fight over the same knobs.
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # Charge thresholds: on a Framework the battery enumerates as
      # BAT1, not BAT0, so the usual ThinkPad-style keys below do nothing.
      # See hosts/laptop/default.nix for the working options (BIOS setting
      # or the sysfs interface exposed by the Framework kernel module).
      # START_CHARGE_THRESH_BAT1 = 40;
      # STOP_CHARGE_THRESH_BAT1 = 80;
    };
  };

  # Replaces `sudo powertop --calibrate` plus remembering to re-run it.
  # This applies the tunables automatically at every boot.
  powerManagement.powertop.enable = true;

  services.thermald.enable = true; # Intel CPUs only, ignored otherwise

  # The freeform `settings` form replaced the individual options
  # (lidSwitch, powerKey, extraConfig) during the 25.x releases. On an
  # older Home Manager/NixOS these are:
  #   services.logind.lidSwitch = "suspend";
  #   services.logind.lidSwitchExternalPower = "lock";
  #   services.logind.powerKey = "suspend";
  #
  # HandleLidSwitch only fires when off external power, which is exactly
  # the "not plugged in" case: suspend first, then write the image and
  # power off. Plugged in, the lid still just locks.
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

  # How long to sit in suspend before hibernating. systemd treats this as
  # an upper bound and hibernates sooner if the battery is draining fast
  # enough to run out first. Note this is settings.Sleep - the older
  # systemd.sleep.extraConfig was removed, not deprecated.
  systemd.sleep.settings.Sleep.HibernateDelaySec = "25m";

  # Hibernation needs somewhere to write the image, and logind fails a
  # lid-close outright rather than falling back to plain suspend when it
  # cannot (systemd#10558). Without this the failure mode is a laptop
  # left awake in a bag, so fail the build instead.
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
