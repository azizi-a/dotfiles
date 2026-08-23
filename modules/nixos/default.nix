{ ... }:
{
  imports = [
    ./nix.nix
    ./boot.nix
    ./locale.nix
    ./networking.nix
    ./users.nix
    ./hardware.nix
    ./desktop.nix
    ./fonts.nix
    ./power.nix
    ./programs.nix
    ./backups.nix
  ];
}
