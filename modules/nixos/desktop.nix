{ pkgs, ... }:
{
  services.xserver.enable = true;

  # Note the paths: these moved out of services.xserver in 24.11.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # caps -> escape, shift+caps -> caps lock.
  # Set here as well as in dconf because GNOME reads its own copy; having
  # it at this level means it also applies at the GDM login screen and TTY.
  services.xserver.xkb = {
    layout = "gb";
    options = "caps:escape_shifted_capslock";
  };

  # Required for Home Manager's dconf.settings to be applied.
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-extension-manager

    # Ubuntu ships a patched dash-to-dock as part of the desktop; on
    # vanilla GNOME it is a normal extension you install and enable.
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator

    # Provides Yaru-viridian / Yaru-viridian-dark, so your gtk-theme and
    # icon-theme settings resolve to something real.
    yaru-theme
  ];

  # Trim the parts of stock GNOME you never used on Ubuntu.
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-music
    gnome-tour
    gnome-contacts
    gnome-maps
    totem
    yelp
  ];

  # Makes Electron and Chromium apps (VSCode, Cursor, Discord, Chromium)
  # run natively on Wayland. This is the declarative replacement for the
  # `--ozone-platform=wayland` flags scattered through your aliases.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # GNOME keyring, needed by 1Password and VSCode secret storage.
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;
}
