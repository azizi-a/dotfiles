# ---------------------------------------------------------------------------
# Replacement for `sudo ubuntu-drivers autoinstall`.
#
# NOT imported by modules/nixos/default.nix. Import it from a host file only
# on machines that actually have an Nvidia card, otherwise you pull a large
# proprietary driver onto an Intel-only laptop.
# ---------------------------------------------------------------------------
{ config, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    modesetting.enable = true;
    nvidiaSettings = true;

    # Pascal (GTX 10xx) is not supported by the open kernel modules.
    # Set to true only on Turing (RTX 20xx) or newer.
    open = false;

    # Suspend/resume support. Helps on laptops, occasionally flaky.
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    # --- Hybrid graphics (Optimus) only ------------------------------------
    # Find the bus IDs with `lspci | grep -E "VGA|3D"` and convert the
    # hex address to the "PCI:bus:device:function" decimal form.
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
