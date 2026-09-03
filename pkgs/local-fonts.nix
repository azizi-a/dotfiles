# Packages every TTF under fonts/, currently only LigaSrcPro, which
# registers the family "LigaSrc Pro". New folders are picked up on the
# next rebuild. Nerd fonts come from nixpkgs instead - see fonts.nix.
{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "dotfiles-fonts";
  version = "local";

  src = ../fonts;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    find "$src" -type f -name '*.ttf' \
      -exec install -Dm444 -t "$out/share/fonts/truetype/dotfiles" {} +
    runHook postInstall
  '';

  meta = {
    description = "Fonts vendored in the dotfiles repo";
    platforms = lib.platforms.all;
  };
}
