{ pkgs, user, ... }:
{
  # System level, the GUI needing polkit rules and browser integration.
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ user.name ];
  };

  services.input-remapper.enable = true;

  # Lets prebuilt ELFs find their libraries: rustup, Cursor's updater,
  # language servers editors download for themselves.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      curl
      icu
      libxml2
    ];
  };

  # Minimal on purpose: anything of yours goes in home/packages.nix,
  # which rebuilds without sudo.
  environment.systemPackages = with pkgs; [
    curl
    git
    nano
    vim
    wget
    pciutils
    usbutils
  ];

  # Fixes the 5s shutdown hang waiting on a network already gone.
  systemd.services.NetworkManager-wait-online.enable = false;
}
