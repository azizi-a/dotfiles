{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      # Was fonts-firacode in apt.
      fira-code
      fira-code-symbols

      noto-fonts
      noto-fonts-color-emoji

      # v3. The Material Design icons waybar and mako use moved to
      # F0001+, so the v2 files this repo vendored rendered them as tofu.
      nerd-fonts.sauce-code-pro

      # Glyphs only, so apps not themselves set in a nerd font get them.
      nerd-fonts.symbols-only

      # Still vendored, because LigaSrc Pro is not in nixpkgs.
      (pkgs.callPackage ../../pkgs/local-fonts.nix { })
    ];

    # Only reaches requests for the generic families, never a config that
    # names one outright - waybar and mako do, so they carry their own
    # fallback lists. Naming a family elsewhere: use theme.nix.
    fontconfig.defaultFonts = {
      monospace = [
        "SauceCodePro Nerd Font"
        "Symbols Nerd Font Mono"
        "LigaSrc Pro"
        "Fira Code"
      ];
      sansSerif = [
        "Noto Sans"
        "Symbols Nerd Font"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
