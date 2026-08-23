{ pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        # Keep the boot partition from filling up. Every one of these is a
        # bootable snapshot of the whole system, which is what makes
        # Timeshift redundant here.
        configurationLimit = 20;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    # Newer kernel than the LTS default. Drop this line for the stable one.
    kernelPackages = pkgs.linuxPackages_latest;

    tmp.cleanOnBoot = true;
  };
}
