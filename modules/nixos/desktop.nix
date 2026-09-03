{ pkgs, ... }:
{
  services.xserver.enable = true;

  # Note the paths: these moved out of services.xserver in 24.11.
  services.displayManager.gdm.enable = true;

  # Without this GDM has no reason to prefer sway over GNOME.
  services.displayManager.defaultSession = "sway";

  # Kept as the fallback, so a broken sway config is a session switch
  # rather than a trip to a TTY. Nothing here gates sway.
  services.desktopManager.gnome.enable = true;

  # Also covers the GDM screen and the TTYs, which dconf does not.
  services.xserver.xkb = {
    layout = "gb";
    options = "caps:escape_shifted_capslock";
  };

  # Required for Home Manager's dconf.settings to be applied.
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-extension-manager

    # Enabled in modules/home/gnome.nix.
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator

    # What theme.nix's gtkTheme and iconTheme names resolve to.
    yaru-theme
  ];

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

  # Electron and Chromium apps go native Wayland, no per-app flags.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # GNOME keyring, needed by 1Password and VSCode secret storage.
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;
}
