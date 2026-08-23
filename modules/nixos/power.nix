{ ... }:
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
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
    HandlePowerKey = "suspend";
  };
}
