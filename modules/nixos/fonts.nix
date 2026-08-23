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

      # Both vendored folders: fonts/LigaSrcPro and
      # fonts/SourceCodeProNerdFonts. See pkgs/local-fonts.nix for the
      # exact family names they install.
      #
      # For the record, nixpkgs does carry this nerd font as
      # nerd-fonts.sauce-code-pro, but that is the v3 patch and your
      # checked-in files are v2. Icon codepoints moved between the two,
      # so the vendored copy keeps glyphs exactly where your existing
      # guake config and prompt expect them. If you ever switch to the
      # nixpkgs one, drop the folder from the repo at the same time so
      # two versions of the same family are not fighting.
      (pkgs.callPackage ../../pkgs/local-fonts.nix { })
    ];

    fontconfig.defaultFonts = {
      # The nerd font leads so that anything asking for generic
      # "monospace" (terminals, mostly) gets the icon-capable font, while
      # the editors ask for LigaSrc Pro by name in their own configs.
      # Guake, the VSCode terminal and the Zed terminal all also name
      # "SauceCodePro Nerd Font" explicitly.
      monospace = [ "SauceCodePro Nerd Font" "LigaSrc Pro" "Fira Code" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
