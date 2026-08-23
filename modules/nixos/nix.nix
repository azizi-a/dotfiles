{ lib, inputs, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      # Anyone in this group may push to / pull from the store directly.
      trusted-users = [ "root" "@wheel" ];
    };

    # `apt autoremove` equivalent, but scheduled and safe.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Pin the flake registry so `nix shell nixpkgs#foo` uses the same
    # nixpkgs as the system, instead of fetching a fresh one.
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

  # Ubuntu had no equivalent of this: on NixOS unfree packages must be
  # opted into explicitly. Listing them individually means a new unfree
  # dependency shows up as an evaluation error rather than sneaking in.
  # If you would rather not maintain the list, replace the whole block
  # with: nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowUnfreePredicate =
  #   pkg:
  #   builtins.elem (lib.getName pkg) [
  #     "1password"
  #     "1password-cli"
  #     "1password-gui"
  #     "claude-code"
  #     "code-cursor"
  #     "cursor"
  #     "discord"
  #     "nvidia-settings"
  #     "nvidia-x11"
  #     "spotify"
  #   ];
}
