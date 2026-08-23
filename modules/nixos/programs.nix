{ pkgs, user, ... }:
{
  # Replaces install-scripts/1password.sh entirely: no apt repo, no GPG
  # key, no debsig policy. The GUI needs system-level setup for its
  # browser integration and polkit rules, so it cannot live in Home Manager.
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ user.name ];
  };

  # Was `apt install input-remapper` plus enabling the daemon.
  services.input-remapper.enable = true;

  # Lets dynamically linked binaries that were not built by Nix find their
  # libraries. You need this if you keep using nvm or rustup, or run
  # anything that ships a prebuilt ELF (some npm postinstall steps,
  # Cursor's own updater, language server binaries downloaded by editors).
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

  # Kept minimal on purpose. Anything that is "yours" rather than "the
  # machine's" belongs in modules/home/packages.nix, so it can be rebuilt
  # without sudo.
  environment.systemPackages = with pkgs; [
    curl
    git
    nano
    vim
    wget
    pciutils
    usbutils
  ];

  # Fixes the 5s hang on shutdown when NetworkManager waits for a network
  # that is already gone. Harmless to keep.
  systemd.services.NetworkManager-wait-online.enable = false;
}
