{ pkgs, ... }:
{
  # Sway needs enabling at system level even though the whole compositor
  # config lives in modules/home/sway.nix. This is what registers the
  # wayland session so GDM offers "Sway" alongside GNOME, and the shared
  # wayland-session module behind it also turns on polkit, dconf, the
  # wlroots portal, the GTK portal and security.pam.services.swaylock.
  programs.sway = {
    enable = true;

    # Themes GTK apps that sway itself launches; in practice the polkit
    # dialog, which is otherwise unstyled white.
    wrapperFeatures.gtk = true;

    # extraPackages is deliberately left alone. Assigning it replaces the
    # module default (brightnessctl, foot, grim, swayidle, swaylock,
    # wmenu) rather than adding to it, so extras go below instead.
  };

  environment.systemPackages = with pkgs; [
    # Tray and launcher icons are icon-theme lookups, not font glyphs,
    # and GNOME was supplying these. hicolor terminates the lookup chain.
    adwaita-icon-theme
    hicolor-icon-theme

    swaybg # sway shells out to this for the `output * bg` line
    slurp # region select, feeds grim
    wl-clipboard # sway-screenshot copies through wl-copy

    # sway ships no polkit agent; the README says what breaks without one.
    # polkit_gnome is ancient but is the one that surfaces the fprintd
    # prompt; security.soteria is the maintained fallback. The unit that
    # runs it is in modules/home/sway.nix.
    polkit_gnome
  ];

  # swaylock cannot answer a fingerprint prompt, so pam_fprintd sitting in
  # front of pam_unix would leave it accepting neither (nixpkgs#171136).
  # sudo, polkit and GDM keep the reader.
  security.pam.services.swaylock.fprintAuth = false;

  # programs.sway turns on the wlr and GTK portal backends but not the
  # portal service itself. GNOME happens to enable it today; spelling it
  # out means the sway session survives GNOME ever being removed.
  xdg.portal.enable = true;
}
