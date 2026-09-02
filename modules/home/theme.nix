# Shared palette and font names, so a retheme is one edit rather than six
# files drifting out of step with each other.
#
# Data, not a module: `import ./theme.nix`, never listed in the imports
# in default.nix. Colours are bare hex because the consumers disagree on
# the prefix - waybar and mako want #rrggbb, fuzzel wants rrggbbaa,
# swaylock and foot want bare.
{
  bg = "1d2021";
  fg = "ebdbb2";
  accent = "8ec07c";
  dim = "928374";
  selection = "3c3836";
  warning = "fabd2f";
  urgent = "fb4934";

  # See modules/nixos/fonts.nix for why this is the vendored v2 patch
  # rather than nixpkgs' nerd-fonts.sauce-code-pro.
  font = "SauceCodePro Nerd Font";

  gtkTheme = "Yaru-viridian-dark";
  iconTheme = "Yaru-viridian";
}
