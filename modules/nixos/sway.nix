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
    swaybg # sway shells out to this for the `output * bg` line
    slurp # region select, feeds grim
    wl-clipboard # services.cliphist does not put these on PATH itself

    # GNOME Shell has a polkit agent built in; sway has none, and without
    # one 1Password cannot authorise at all and pkexec prompts vanish
    # with no error. /etc/pam.d/polkit-1 already accepts a fingerprint
    # because security.pam.services.<name>.fprintAuth follows
    # services.fprintd.enable, so this is also the piece that makes
    # 1Password unlock with a finger. The user service that runs it is in
    # modules/home/sway.nix.
    #
    # polkit_gnome is ancient (0.105) but is the agent reported to
    # actually surface the fprintd prompt. If it misbehaves, swap in
    # `security.soteria.enable = true`, which is maintained and brings
    # its own user service, at the cost of unverified fingerprint support.
    polkit_gnome
  ];

  # programs.sway creates security.pam.services.swaylock for us, and
  # fprintAuth follows services.fprintd.enable, so pam_fprintd would sit
  # in front of pam_unix on the lock screen. swaylock only ever submits a
  # typed password, so it cannot answer the fingerprint conversation, and
  # nixpkgs#171136 is exactly this: fprintd in a graphical stack blocking
  # password entry. Turning it off here keeps the lock screen unlockable.
  # sudo, polkit and GDM are unaffected and still take a finger.
  security.pam.services.swaylock.fprintAuth = false;

  # programs.sway turns on the wlr and GTK portal backends but not the
  # portal service itself. GNOME happens to enable it today; spelling it
  # out means the sway session survives GNOME ever being removed.
  xdg.portal.enable = true;
}
