# Packages every TTF under fonts/ in this repo, currently:
#
#   fonts/LigaSrcPro/              family "LigaSrc Pro"
#   fonts/SourceCodeProNerdFonts/  families "SauceCodePro Nerd Font",
#                                  "SauceCodePro Nerd Font Mono", and
#                                  "SauceCodePro NF" (the Windows
#                                  Compatible files)
#
# The family names above were read straight from the font name tables, so
# they are what fontconfig and every app will see. New folders dropped
# into fonts/ get picked up automatically on the next rebuild.
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
