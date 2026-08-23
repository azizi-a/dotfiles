{ pkgs, ... }:
{
  # --- Timeshift ------------------------------------------------------------
  # Deliberately not installed. Timeshift snapshots the system so you can
  # roll back a bad update; on NixOS every rebuild already creates a new
  # generation, the old one stays bootable, and `nixos-rebuild
  # --rollback` or the boot menu gets you back. boot.nix keeps the last
  # 20 of those. Reinstalling from this repo is also a valid recovery
  # path, which was never true of the Ubuntu setup.
  #
  # If you want filesystem-level snapshots too, that is a btrfs question
  # rather than a Timeshift one: services.snapper or btrbk.

  # --- Deja Dup -------------------------------------------------------------
  # Still worth having, because generations do not protect ~/. This covers
  # your actual documents and code.
  environment.systemPackages = with pkgs; [ deja-dup ];
  services.gvfs.enable = true; # deja-dup needs this for remote targets

  # --- Declarative alternative ---------------------------------------------
  # If you would rather have backups that survive a reinstall without you
  # reconfiguring the GUI, restic is the usual choice. Sketch:
  #
  # services.restic.backups.home = {
  #   initialize = true;
  #   paths = [ "/home/azizi" ];
  #   exclude = [ "/home/azizi/.cache" "/home/azizi/**/node_modules" ];
  #   repository = "sftp:backup@server:/srv/restic";
  #   passwordFile = "/etc/restic/password";  # keep out of git
  #   timerConfig = { OnCalendar = "daily"; Persistent = true; };
  #   pruneOpts = [ "--keep-daily 7" "--keep-weekly 5" "--keep-monthly 12" ];
  # };
}
