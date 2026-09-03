{ pkgs, ... }:
{
  # Registers the wayland session so GDM lists it, and pulls in polkit,
  # dconf, both portals and pam.services.swaylock. Config is in home/.
  programs.sway = {
    enable = true;

    # Themes GTK apps sway launches itself, in practice the polkit dialog.
    wrapperFeatures.gtk = true;

    # extraPackages is left alone: assigning it replaces the module
    # default rather than adding to it, so extras go below.
  };

  environment.systemPackages = with pkgs; [
    # Tray and launcher icons are icon-theme lookups, not font glyphs,
    # and GNOME was supplying these. hicolor terminates the lookup chain.
    adwaita-icon-theme
    hicolor-icon-theme

    swaybg # sway shells out to this for the `output * bg` line
    slurp # region select, feeds grim
    wl-clipboard # sway-screenshot copies through wl-copy

    # sway ships no polkit agent; see the README. Ancient, but the one
    # that surfaces the fprintd prompt. Unit is in home/sway.nix.
    polkit_gnome
  ];

  # swaylock cannot answer a fingerprint prompt, so pam_fprintd sitting in
  # front of pam_unix would leave it accepting neither (nixpkgs#171136).
  # sudo, polkit and GDM keep the reader.
  security.pam.services.swaylock.fprintAuth = false;

  # programs.sway enables the backends but not the service; GNOME happens
  # to today, and this outlives GNOME being removed.
  xdg.portal.enable = true;
}
