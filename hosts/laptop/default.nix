{ pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    # Suspend params, ambient light sensor, brightness keys, EC module.
    inputs.nixos-hardware.nixosModules.framework-12th-gen-intel

    ../../modules/nixos

    # gpu-nvidia.nix is not imported: this machine is Iris Xe only.
  ];

  networking.hostName = "nixos-laptop";

  # --- Framework specifics -------------------------------------------------

  # EC access through sysfs. Already the nixos-hardware default on 6.10+.
  hardware.framework.enableKmod = true;

  # Enrol as yourself - `sudo fprintd-enroll` registers the print against
  # root and every later check then fails. fprintAuth follows this option,
  # so sudo, polkit and the display manager need no further config.
  services.fprintd.enable = true;

  # Charge limits, fan curves, LEDs. Called fw-ectool on some channels.
  environment.systemPackages = with pkgs; [ framework-tool ];

  # Charge limit: the BIOS setting, or the sysfs interface below. TLP's
  # thresholds do not work here, the battery enumerating as BAT1.
  #
  # systemd.services.battery-charge-limit = {
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "multi-user.target" ];
  #   serviceConfig.Type = "oneshot";
  #   script = ''
  #     echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold
  #   '';
  # };

  # BIOS updates: `fwupdmgr refresh && fwupdmgr update`, with a live USB
  # to hand. fwupd is enabled in modules/nixos/hardware.nix.

  # Never bump: stateful services read it to know which migrations to run.
  system.stateVersion = "26.05";
}
