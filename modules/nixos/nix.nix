{ lib, inputs, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      # Anyone in this group may push to / pull from the store directly.
      trusted-users = [ "root" "@wheel" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # So `nix shell nixpkgs#foo` reuses the system nixpkgs.
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

  nixpkgs.config.allowUnfree = true;

  # Swap for the above to make a new unfree dependency an eval error
  # rather than something that slips in unnoticed.
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
