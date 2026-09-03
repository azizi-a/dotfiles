{ pkgs, ... }:
{
  # No Timeshift: every rebuild leaves a bootable generation, 20 of which
  # boot.nix keeps. Deja Dup stays because generations do not cover ~/.
  environment.systemPackages = with pkgs; [ deja-dup ];
  services.gvfs.enable = true; # deja-dup needs this for remote targets

  # Declarative alternative, surviving a reinstall without GUI setup:
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
