# Not imported by default. Import from a host file only where there is an
# Nvidia card, or you pull the proprietary driver onto an Intel laptop.
{ config, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    modesetting.enable = true;
    nvidiaSettings = true;

    # True only on Turing (RTX 20xx) or newer; Pascal has no open module.
    open = false;

    # Suspend/resume. Helps on laptops, occasionally flaky.
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    # Optimus only. Bus IDs from `lspci | grep -E "VGA|3D"`, hex address
    # converted to decimal "PCI:bus:device:function".
    #
    # prime = {
    #   offload = {
    #     enable = true;
    #     enableOffloadCmd = true;   # gives you `nvidia-offload <program>`
    #   };
    #   intelBusId = "PCI:0:2:0";
    #   nvidiaBusId = "PCI:1:0:0";
    # };
  };
}
