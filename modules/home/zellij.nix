{ ... }:
{
  # foot has no tabs and upstream will not add them, so the scratchpad in
  # sway.nix runs through this instead. zellij over tmux because it draws
  # its keybindings on screen rather than expecting you to know them.
  #
  # No settings: Home Manager writes YAML, current zellij reads KDL.
  programs.zellij.enable = true;
}
